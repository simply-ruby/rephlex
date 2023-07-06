require "thor"
require "pastel"
require "tty-font"
require "debug"

require_relative "commands/database"

module Rephlex
  class CLI < Thor
    class << self
      attr_accessor :root_path
    end

    def self.exit_on_failure?
      true
    end

    def help(*args)
      binding.break
      font = TTY::Font.new(:standard)
      pastel = Pastel.new(enabled: !options["no-color"])
      puts pastel.magenta(font.write("Rephlex"))
      super
    end

    class_option :"no-color",
                 type: :boolean,
                 default: false,
                 desc: "Disable colorization in output"

    desc "generate", "Code generator"
    method_option :help,
                  aliases: "-h",
                  type: :boolean,
                  desc: "Display usage information"
    def generate
      if options[:help]
        invoke :help, ["generate"]
      else
        require_relative "commands/generate"
        Rephlex::Commands::Generate.new(options).execute
      end
    end

    desc "remove", "Remove generated files"
    method_option :help,
                  aliases: "-h",
                  type: :boolean,
                  desc: "Display usage information"
    def remove
      if options[:help]
        invoke :help, ["remove"]
      else
        require_relative "commands/remove"
        Rephlex::Commands::Remove.new(options).execute
      end
    end

    desc "db", "Manage creation and migration of your database."
    subcommand "db", Commands::Database
  end
end
