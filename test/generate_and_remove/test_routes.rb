require_relative "../test_helper"

class TestRoutesGenerator < TestGenerate
  include IoTestHelpers
  def setup
    super
    @context = @generator.routes_context("user")
    @modules = @generator.modulify("user")
  end

  #############################
  #     Generate Routes       #
  #############################
  def test_generate_routes
    capture_io do
      @generator.generate_routes(
        context: @context,
        modules: @modules,
        verbose: false
      )
    end
  end

  def test_generate_routes_from_user_input
    capture_io do
      simulate_stdin("user") do
        @generator.generate_routes(
          context: @context,
          modules: @modules,
          verbose: false
        )
      end
    end

    assert File.exist?("allocs/user/routes.rb"), "File was not created"
  end

  #############################
  #     Remove Routes       #
  #############################

  def test_remove_date_model
    Dir.mkdir("allocs") unless File.directory?("allocs")
    Dir.mkdir("allocs/user") unless File.directory?("allocs/user")
    FileUtils.touch("allocs/user/routes.rb")

    capture_io do
      simulate_stdin("user", keypress(:y)) do
        Rephlex::Commands::Remove.new({}).remove_routes(verbose: false)
      end
    end

    refute File.exist?("allocs/user/routes.rb"), "File was not removed"
  end

  def test_on_second_thought_about_removing_those_routes
    Dir.mkdir("allocs") unless File.directory?("allocs")
    Dir.mkdir("allocs/user") unless File.directory?("allocs/user")
    FileUtils.touch("allocs/user/routes.rb")

    capture_io do
      simulate_stdin("user", keypress(:n)) do
        Rephlex::Commands::Remove.new({}).remove_routes(verbose: false)
      end
    end
    assert File.exist?("allocs/user/routes.rb"), "File was removed!"
  end

  def teardown
    super
  end
end
