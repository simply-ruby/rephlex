require "dry-inflector"
require "tty-prompt"
require "tty-file"
require "debug"
require_relative "../../rephlex"
require_relative "../command"

module Rephlex
  module Commands
    class Generate < Rephlex::Command
      def initialize(options)
        @options = options
        @prompt = create_prompt($stdin, $stdout)
      end

      def execute(input: $stdin, output: $stdout)
        @prompt = create_prompt(input, output)
        generator =
          @prompt.select(
            "What do you want to generate?",
            filter: true,
            cycle: true
          ) do |m|
            m.default 1
            m.choice "Allocation", :allocation
            m.choice "Data Model", :data_model
            m.choice "Decorator", :decorator
            m.choice "Provider", :provider
            m.choice "Migration", :migration
            m.choice "Route", :route
          end

        case generator
        when :allocation
          generate_allocation
        when :data_model
          context, modules = setup_data_model
          generate_data_model(context: context, modules: modules)
        when :decorator
          context, modules = setup_decorator
          generate_decorator(context: context, modules: modules)
        when :migration
          generate_migration
        when :provider
          # provider_name =
          #   prompt.ask("What is the provider name?") { |q| q.required true }
          # invoke Generator, "provider", provider_name: provider_name
        when :route
          context, modules = setup_routes
          generate_routes(context: context, modules: modules)
        end
      end

      #############################
      #         Allocation        #
      #############################
      #...
      # └───allocs
      # │   │
      # │   └─── users
      # │   │    │   data_model.rb
      # │   │    │   routes.rb
      # │   │    └─── services
      # │   │    └─── views
      # │   │    │   └─── components
      # │   │    │   │   │ card.rb
      # │   │    │   │   │ sidebar.rb
      # │   │    │   │   │ form.rb
      # │   │    │   │
      # │   │    │   └─── pages
      # │   │    │   │   │ show.rb
      # │   │    │   │   │ index.rb
      # │   │    │   │   │ edit.rb
      # │   │    │   │
      # │   │    │   └─── layouts
      # │   │    │   │   │ account.rb
      # │   │    │   │   │ dashboard.rb
      # ...
      def generate_allocation(verbose: true)
        input = identify_resource("allocation")
        generate_data_model_for_alloc(input: input, verbose: verbose)
        generate_routes_for_alloc(input: input, verbose: verbose)
        TTY::File.create_dir("allocs/#{input}/services")
        TTY::File.create_dir("allocs/#{input}/views")
        TTY::File.create_dir("allocs/#{input}/views/pages")
        TTY::File.create_dir("allocs/#{input}/views/layouts")
        TTY::File.create_dir("allocs/#{input}/views/components")
      end

      def generate_data_model_for_alloc(input:, verbose:)
        generate_data_model(
          context: data_model_context(input),
          modules: modulify(input),
          verbose: verbose
        )
      end

      def generate_routes_for_alloc(input:, verbose:)
        generate_routes(
          context: routes_context(input),
          modules: modulify(input),
          verbose: verbose
        )
      end

      #############################
      #         Data Model        #
      #############################
      def setup_data_model
        input = identify_resource("data model")
        [data_model_context(input), modulify(input)]
      end

      def data_model_context(input)
        context = Struct.new(:path, :table_name, :inflector)
        context.new(input, input.gsub("/", "_"), Dry::Inflector.new)
      end

      # Context
      # path: 'user/accounts'
      # table_name: Sequel(DB[:table_name])
      # inflector: Dry::Inflector
      def generate_data_model(context:, modules:, verbose: true)
        TTY::File.copy_file(
          base_path("lib/rephlex/templates/data_model.erb"),
          base_path("allocs/%path%/data_model.rb"),
          context: context,
          verbose: verbose
        ) { |content| wrap_modules(modules) { content } }
      end

      #############################
      #         Decorator         #
      #############################
      def setup_decorator
        input = identify_resource("decorator")
        modules = modulify(input)
        prefix =
          @prompt.ask(
            "Input the prefix for the #{input} decorator. (<prefix>_decorator.rb)"
          ) { |q| q.required true }
        [decorator_context(input, prefix), modules]
      end

      def decorator_context(input, prefix)
        context = Struct.new(:path, :inflector, :prefix)
        context.new(input, Dry::Inflector.new, prefix)
      end

      def generate_decorator(context:, modules:, verbose: true)
        TTY::File.copy_file(
          base_path("lib/rephlex/templates/decorator.erb"),
          base_path("allocs/%path%/%prefix%_decorator.rb"),
          context: context,
          verbose: verbose
        ) do |content|
          wrap_modules(modules, requires: ["delegate"]) { content }
        end
      end

      #############################
      #         Migration         #
      #############################

      def generate_migration(verbose: true)
        migration_name =
          @prompt.ask("Enter migration name (format snake_case): ")
        TTY::File.copy_file(
          base_path("lib/rephlex/templates/migration.erb"),
          base_path("system/db/migration/#{timestamp}_#{migration_name}.rb")
        )
      end

      #############################
      #         Provider          #
      #############################

      def generate_provider(verbose: true)
        # res =
        #   @prompt.ask("Input the name of the provider.") { |q| q.required true }
        # details = Struct.new(res)
        # TTY::File.copy_file(base_path)
      end

      #############################
      #         Routes            #
      #############################

      def setup_routes(verbose: true)
        input = identify_resource("routes")
        modules = modulify(input)
        [routes_context(input), modules]
      end

      def routes_context(input)
        inflector = Dry::Inflector.new
        context = Struct.new(:path, :modules, :nested?, :instance_name, :class_name)
        modules = modulify(input)
        nested = modules.length > 1

        context.new(
          input,
          modules,
          nested,
          input.gsub("/", "_"),
          inflector.classify(input)
        )
      end

      # Context
      # path: 'user'
      # res_name: last of path as a module, but lowercase
      # inflector: Dry::Inflector
      def generate_routes(context:, modules:, verbose: true)
        TTY::File.copy_file(
          base_path("lib/rephlex/templates/routes.erb"),
          base_path("allocs/%path%/routes.rb"),
          context: context,
          verbose: verbose
        ) do |content|
          wrap_route_modules(modules, Rephlex.app_name) { content }
        end
      end

      private

      def identify_resource(resource)
        @prompt.ask(
          "Input the name as a path for the #{resource}. (#{help_format_message})"
        ) { |q| q.required true }
      end

      def timestamp
        Time.now.strftime("%Y%m%d%H%M%S")
      end
    end
  end
end
