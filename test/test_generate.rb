require "tty-prompt"
require "debug"

require_relative "test_helper"

class GeneratorTest < Minitest::Test
  include IoTestHelpers
  def setup
    require_relative "../lib/rephlex/commands/generate.rb"
  end

  #############################
  #         Data Model        #
  #############################
  def test_generate_data_model
    capture_io do
      simulate_stdin("users") do
        Rephlex::Commands::Generate.new({}).generate_data_model(verbose: false)
      end
    end

    assert File.exist?("app/users/data_model.rb"), "File was not created"
  end

  def test_generate_data_model_with_correct_inflection
    capture_io do
      simulate_stdin("users") do
        Rephlex::Commands::Generate.new({}).generate_data_model(verbose: false)
      end
    end
    assert_match(
      /DataModel < Sequel::Model\(DB\[:users\]\)/,
      File.read("app/users/data_model.rb"),
      "DataModel connection fucked up"
    )
  end

  #############################
  #         Routes            #
  #############################
  def test_generate_routes
    capture_io do
      simulate_stdin("users") do
        Rephlex::Commands::Generate.new({}).generate_routes(verbose: false)
      end
    end

    assert File.exist?("app/users/routes.rb"), "File was not created"
  end

  #############################
  #         Decorators        #
  #############################

  def test_generate_routes
    capture_io do
      simulate_stdin("users", "prefix") do
        Rephlex::Commands::Generate.new({}).generate_decorator(verbose: false)
      end
    end

    assert File.exist?("app/users/prefix_decorator.rb"), "File was not created"
  end

  #############################
  #         Providers         #
  #############################
  #############################
  #         Migration         #
  #############################
  #############################
  #         Allocation        #
  #############################

  def teardown
    FileUtils.rm_rf("app")
  end
end
