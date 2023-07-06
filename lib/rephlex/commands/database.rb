require "dry-inflector"
require "tty-prompt"
require "tty-font"
require "tty-file"
require "pastel"
require "sequel"
require "logger"
require "debug"
require "thor"
require "tomlrb"
require_relative "../../rephlex"

module Rephlex
  module Commands
    class Database < Thor
      class_option "no-color",
                   type: :boolean,
                   default: false,
                   desc: "Disable colorization in output"

      desc "console",
           "Start an IRB session with your database and models loaded"
      def console
      end

      desc "annotate", "Annotate Sequel models"
      def annotate
        ENV["RACK_ENV"] = "development"

        models = Dir["allocs/**/data_model.rb"]
        models.each { |file| require_relative file }

        DB.loggers.clear
        require "sequel/annotate"
        Sequel::Annotate.annotate(models)
      end

      desc "create",
           "Creates a PostgreSQL database based on the configuration found at file path [-p]."
      option :env, aliases: "-e", desc: "Environment name"
      option :file_path,
             aliases: "-p",
             desc: "Path to the database configuration file"
      def create
        set_environment
        set_file_path
        set_config

        connect_to_database(@config.merge("database" => "postgres")) do |db|
          db.loggers << Logger.new($stdout) if db.loggers.empty?
          db.execute "DROP DATABASE IF EXISTS #{@config[:database]}"
          db.execute "CREATE DATABASE #{@config[:database]}"
        end
      end

      desc "test_up", "Migrate test database to latest version"
      option :file_path,
             aliases: "-p",
             desc: "Path to the database configuration file"
      def test_up
        @environment = "test"
        up
      end

      desc "test_down", "Migrate test database all the way down"
      option :file_path,
             aliases: "-p",
             desc: "Path to the database configuration file"
      def test_down
        @environment = "test"
        down
      end

      desc "test_bounce",
           "Migrate test database all the way down and then back up"
      option :file_path,
             aliases: "-p",
             desc: "Path to the database configuration file"
      def test_bounce
        @environment = "test"
        bounce
      end

      desc "dev_up", "Migrate development database to latest version"
      option :file_path,
             aliases: "-p",
             desc: "Path to the database configuration file"
      def dev_up
        @environment = "development"
        up
      end

      desc "dev_down", "Migrate development database to all the way down"
      option :file_path,
             aliases: "-p",
             desc: "Path to the database configuration file"
      def dev_down
        @environment = "development"
        down
      end

      desc "dev_bounce",
           "Migrate development database all the way down and then back up"
      option :file_path,
             aliases: "-p",
             desc: "Path to the database configuration file"
      def dev_bounce
        @environment = "development"
        bounce
      end

      desc "prod_up", "Migrate production database to latest version"
      option :file_path,
             aliases: "-p",
             desc: "Path to the database configuration file"
      def prod_up
        @environment = "production"
        up
      end

      no_tasks do
        def down
          set_file_path
          set_config
          migrate(0)
        end

        def up
          set_file_path
          set_config
          migrate(nil)
        end

        def bounce
          set_file_path
          set_config
          migrate(0)
          Sequel::Migrator.apply(DB, @file_path)
        end

        def set_environment
          env =
            (
              options[:env] ?
                options[:env] :
                ENV["RACK_ENV"] ? ENV["RACK_ENV"] : "development"
            )
          @environment = env.to_sym
        end

        def set_file_path
          @file_path =
            if options[:file_path]
              options[:file_path]
            else
              "system/db/config.toml"
            end
        end

        def set_config
          @config =
            Tomlrb.load_file(@file_path, symbolize_keys: true)[@environment]
          unless @config
            raise Thor::Error,
                  "Configuration for environment '#{@environment}' not found."
          end
          validate_config
        end

        def connect_to_database(config)
          Sequel.connect(
            config || ENV.delete("APP_DATABASE_URL") ||
              ENV.delete("DATABASE_URL")
          ) { |db| yield db if block_given? }
        end

        def validate_config
          unless @config.is_a?(Hash)
            say_error "Invalid configuration format. Expected a hash."
          end

          required_fields = %i[adapter database]
          missing_fields = required_fields - @config.keys

          if missing_fields.any?
            say_error "Missing configuration fields: #{missing_fields.join(", ")}"
          end
        end

        def migrate(version)
          @db = connect_to_database(@config)
          Sequel.extension :migration
          @db.loggers << Logger.new($stdout) if @db.loggers.empty?
          Sequel::Migrator.apply(@db, "system/db/migrate", version)
        end
      end
    end
  end
end
