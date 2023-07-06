require_relative "../test_helper"

class TestDataModelGenerator < TestGenerate
  include IoTestHelpers
  def setup
    super
    @context = @generator.data_model_context("user")
    @modules = @generator.modulify("user")
  end

  #############################
  #     Generate Data Model   #
  #############################
  def test_generate_data_model
    capture_io do
      @generator.generate_data_model(
        context: @context,
        modules: @modules,
        verbose: false
      )
    end

    assert File.exist?("allocs/user/data_model.rb"), "File was not created"
  end

  def test_generate_data_model_with_user_input
    simulate_stdin("user") do
      capture_io do
        @generator.generate_data_model(
          context: @context,
          modules: @modules,
          verbose: false
        )
      end
    end
    assert File.exist?("allocs/user/data_model.rb"), "File was not created"
  end

  def test_generate_data_model_with_correct_inflection
    capture_io do
      @generator.generate_data_model(
        context: @context,
        modules: @modules,
        verbose: false
      )
    end

    assert_match(
      /DataModel < Sequel::Model\(DB\[:users\]\)/,
      File.read("allocs/user/data_model.rb"),
      "DataModel connection fucked up"
    )
  end

  #############################
  #     Remove Data Model     #
  #############################

  def test_remove_data_model
    Dir.mkdir("allocs") unless File.directory?("allocs")
    Dir.mkdir("allocs/user") unless File.directory?("allocs/user")
    FileUtils.touch("allocs/user/data_model.rb")

    capture_io do
      simulate_stdin("user", keypress(:y)) do
        Rephlex::Commands::Remove.new({}).remove_data_model(verbose: false)
      end
    end

    refute File.exist?("allocs/user/data_model.rb"), "File was not removed"
  end

  def test_on_second_thought_about_removing_that_data_model
    Dir.mkdir("allocs") unless File.directory?("allocs")
    Dir.mkdir("allocs/user") unless File.directory?("allocs/user")
    FileUtils.touch("allocs/user/data_model.rb")

    capture_io do
      simulate_stdin("user", keypress(:n)) do
        Rephlex::Commands::Remove.new({}).remove_data_model(verbose: false)
      end
    end
    assert File.exist?("allocs/user/data_model.rb"), "File was removed!"
  end

  def teardown
    super
  end
end
