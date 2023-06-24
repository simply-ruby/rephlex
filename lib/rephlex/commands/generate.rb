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
        context = Struct.new(:path, :inflector, :res_name, :app_name)
        @context = context.new("default", Dry::Inflector.new, "users")
        @context[:app_name] = Rephlex.app_name
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
            m.choice "Route (CRUD)", :route_crud
          end

        case generator
        when :allocation
          # result = prompt_migration("What resource are we allocating?")
          # index = result[:columns].map { |c| c[:name] if c[:index] }
          # invoke Generator,
          #        "migration",
          #        table_name: result[:table],
          #        columns: result[:columns],
          #        index: index
          # invoke Generator, "data_model", model_name: result[:table]
          # invoke Generator, "crud_routes", model_name: result[:table]
        when :data_model
          generate_data_model
        when :decorator
          generate_decorator
        when :migration
          generate_migration
        when :provider
          # provider_name =
          #   prompt.ask("What is the provider name?") { |q| q.required true }
          # invoke Generator, "provider", provider_name: provider_name
        when :route
          generate_routes
        end
      end

      def get_input(res)
        input = identify_resource(res)
        modules = modulify(input)
        @context[:path] = input
        [input, modules]
      end

      def generate_data_model(verbose: true)
        input, modules = get_input("data model")
        @context[:res_name] = input.gsub("/", "_")
        TTY::File.copy_file(
          base_path("lib/rephlex/templates/data_model.erb"),
          base_path("app/%path%/data_model.rb"),
          context: @context,
          verbose: verbose
        ) { |content| wrap_modules(modules) { content } }
      end

      def generate_decorator(verbose: true)
        input, modules = get_input("decorator")
        details = Struct.new(:path, :inflector, :parent, :prefix)
        prefix =
          @prompt.ask(
            "Input the prefix for the #{input} decorator. (<prefix>_decorator.rb)"
          ) { |q| q.required true }

        context = details.new(input, Dry::Inflector.new, modules.first, prefix)

        TTY::File.copy_file(
          base_path("lib/rephlex/templates/decorator.erb"),
          base_path("app/%path%/%prefix%_decorator.rb"),
          context: context,
          verbose: verbose
        ) do |content|
          wrap_modules(modules, requires: ["delegate"]) { content }
        end
      end

      def generate_migration(verbose: true)
        migration_name = @prompt.ask("Enter migration name (format snake_case): ")
        TTY::File.copy_file(
          base_path("lib/rephlex/templates/migration.erb"),
          base_path("db/migrations/#{timestamp}_#{migration_name}.rb")
        )
      end

      def generate_provider(verbose: true)
        res =
          @prompt.ask("Input the name of the provider.") { |q| q.required true }
        details = Struct.new(res)
        TTY::File.copy_file(base_path)
      end

      def generate_routes(verbose: true)
        input, modules = get_input("routes")
        @context[:res_name] = modules.last.downcase
        TTY::File.copy_file(
          base_path("lib/rephlex/templates/routes.erb"),
          base_path("app/%path%/routes.rb"),
          context: @context,
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
