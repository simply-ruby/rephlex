require "dry-inflector"
require "tty-prompt"
require "tty-file"
require "pastel"
require "debug"
require_relative "../command"

module Rephlex
  module Commands
    class Remove < Rephlex::Command
      def initialize(options)
        @options = options
        @pastel = Pastel.new
        @prompt = create_prompt($stdin, $stdout)
      end

      def execute(input: $stdin, output: $stdout)
        @prompt = create_prompt(input, output)
        generator =
          @prompt.select(
            "What do you want to remove?",
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
          remove_allocation
        when :data_model
          remove_data_model
        when :decorator
          remove_decorator
        when :migration
          remove_migration
        when :provider
        when :route
          remove_routes
        end
      end

      def remove_allocation
        res = ask_for_resource(resource: "allocation")
        if @prompt.yes?(
             "Are you sure you want to delete allocs/#{res}.rb?"
           ) { |q| q.default false }
          FileUtils.rm_rf(File.join(Rephlex.root, "allocs/#{res}"))
        else
          puts add_color("removal canceled", :magenta)
        end
      end

      def remove_data_model(verbose: true)
        res = ask_for_resource(resource: "data model")
        remove(resource: res, file: "data_model", verbose: verbose)
      end

      def remove_decorator(verbose: true)
        res = ask_for_resource(resource: "decorator")
        prefix =
          @prompt.ask("What is the prefix of the decorator?") do |q|
            q.required true
          end
        remove(resource: res, file: "#{prefix}_decorator", verbose: verbose)
      end

      def remove_migration(verbose: true)
        migration_files =
          Dir.glob(base_path("system/db/migration/*.rb")).sort.reverse

        if migration_files.empty?
          puts add_color("No migration files found.", :red)
          return
        end

        yes =
          @prompt.yes?(
            "Remove last migration file? (This will not undo any databse actions)",
            verbose: verbose
          )
        if yes
          remove_last_migration_file(
            migration_files: migration_files,
            verbose: verbose
          )
        else
          remove_migration_by_name(
            migration_files: migration_files,
            verbose: verbose
          )
        end
      end
      def remove_migration_by_name(migration_files:, verbose: true)
        name =
          @prompt.ask(
            "what is the snake_case name of the file to remove? (No timestamp)"
          )

        pattern = Regexp.new(name, Regexp::IGNORECASE)
        target_file = migration_files.find { |file| file =~ pattern }
        migration_file_path =
          base_path("system/db/migration/#{last_migration_file}")

        if TTY::File.exist?(migration_file_path)
          TTY::File.remove_file(migration_file_path, verbose: verbose)
          puts "Migration file '#{target_file}' removed successfully!"
        else
          puts "Migration file '#{target_file}' not found."
        end
      end
      def remove_last_migration_file(migration_files:, verbose: true)
        last_migration_file = File.basename(migration_files.first)

        if last_migration_file =~ /(\d+)_/
          migration_file_path =
            base_path("system/db/migration/#{last_migration_file}")
          TTY::File.remove_file(migration_file_path, verbose: verbose)
        else
          puts "Unable to extract timestamp from the migration file name."
        end
      end

      def remove_routes(verbose: true)
        res = ask_for_resource(resource: "route")
        remove(resource: res, file: "routes", verbose: verbose)
      end

      def ask_for_resource(resource:)
        @prompt.ask(
          "What is the name the #{resource} to remove? (#{help_format_message})"
        ) { |q| q.required true }
      end

      def remove(resource:, file:, verbose:)
        if you_sure?(resource, file)
          TTY::File.remove_file(
            File.join(Rephlex.root, "allocs/#{resource}/#{file}.rb"),
            verbose: verbose
          )
        else
          puts add_color("removal canceled", :magenta)
        end
      end

      def you_sure?(resource, file)
        @prompt.yes?(
          "Are you sure you want to delete app/#{resource}/#{file}.rb?"
        ) { |q| q.default false }
      end
    end
  end
end
