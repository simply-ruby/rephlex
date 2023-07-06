require_relative "../test_helper"

class TestDecoratorGenerator < TestGenerate
  include IoTestHelpers
  def setup
    super
  end

  #############################
  #    Generate Decorators    #
  #############################

  def test_generate_decorator
    @generator.generate_decorator(
      context: @generator.decorator_context("user", "prefix"),
      modules: @generator.modulify("user"),
      verbose: false
    )

    assert File.exist?("allocs/user/prefix_decorator.rb"),
           "File was not created"
  end

  def test_nested_file_decorator
    capture_io do
      @generator.generate_decorator(
        context: @generator.decorator_context("user/comment", "prefix"),
        modules: @generator.modulify("users/comment"),
        verbose: false
      )
    end

    assert File.exist?("allocs/user/comment/prefix_decorator.rb"),
           "File was not created"
  end

  #############################
  #     Remove Decorator      #
  #############################

  def test_remove_decorator
    capture_io do
      simulate_stdin("user", "prefix", keypress(:y)) do
        Rephlex::Commands::Remove.new({}).remove_decorator(verbose: false)
      end
    end
    refute File.exist?("allocs/user/prefix_decorator.rb"),
           "Decorator not removed"
  end

  def teardown
    super
  end
end
