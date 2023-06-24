require "pastel"

require_relative "../rephlex"
require_relative "helpers/template_helper"
require_relative "helpers/path_helper"
require_relative "helpers/tty_helper"

module Rephlex
  class Command
    include TemplateHelper
    include PathHelper
    include TTYHelper
    # Execute this command
    #
    # @api public
    def execute(*)
      raise(
        NotImplementedError,
        "#{self.class}##{__method__} must be implemented"
      )
    end

    def add_color(str, color)
      if @options["no-color"] || color == :none
        str
      else
        Pastel.new.decorate(str, color)
      end
    end

    def base_path(path)
      File.join(Rephlex.root, path)
    end

    def create_prompt(input, output)
      TTY::Prompt.new(
        prefix: "<#{add_color("Re", :magenta)}💪 => ",
        input: input,
        output: output,
        interrupt: -> do
          puts
          exit 1
        end,
        enable_color: !@options["no-color"]
      )
    end
  end
end
