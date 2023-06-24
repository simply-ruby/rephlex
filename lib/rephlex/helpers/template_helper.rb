require "dry/inflector"

module TemplateHelper
  def classify(el)
    inflector = Dry::Inflector.new
    inflector.classify(el)
  end

  def modulify(string)
    string.split("/").map { |el| classify(el) }
  end

  def wrap_modules(modules, requires: [], &block)
    result = "# frozen_string_literal: true\n"
    result << requires.map { |el| "require '#{el}'\n" }.join if !requires.empty?

    modules.each_with_index do |mod, index|
      result << "  " * index + "module #{mod}\n"
    end

    if block_given?
      result << block
        .call
        .each_line
        .map { |c| ("  " * (modules.size + 1)) + c }
        .join
    end
    result << "  " * modules.size + "end\n"

    (modules.size - 1).downto(0) { |index| result << "  " * index + "end\n" }

    result
  end

  def wrap_route_modules(modules, app_name, &block)
    result = "# frozen_string_literal: true\n"

    modules.each_with_index do |mod, index|
      result << "  " * index + "module #{mod}\n"
    end

    result << "  " * modules.size + "class Routes < #{app_name}\n"
    if block_given?
      result << block
        .call
        .each_line
        .map { |c| ("  " * (modules.size + 1)) + c }
        .join
    end
    result << "  " * modules.size + "end\n"

    (modules.size - 1).downto(0) { |index| result << "  " * index + "end\n" }

    result
  end
end
