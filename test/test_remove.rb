require_relative "test_helper"
require_relative "../lib/rephlex/commands/generate.rb"
require_relative "../lib/rephlex/commands/remove.rb"

class RemoveTest < Minitest::Test
  include IoTestHelpers

  #############################
  #       Data Model          #
  #############################
  def test_remove_data_model
    capture_io do
      simulate_stdin("users") do
        Rephlex::Commands::Generate.new({}).generate_data_model(verbose: false)
      end
    end
    capture_io do
      simulate_stdin("users", keypress(:y)) do
        Rephlex::Commands::Remove.new({}).remove_data_model(verbose: false)
      end
    end
    refute File.exist?("app/users/data_model.rb"), "File was not removed"
  end

  def test_on_second_thought_about_removing_that_data_model
    capture_io do
      simulate_stdin("users") do
        Rephlex::Commands::Generate.new({}).generate_data_model(verbose: false)
      end
    end
    capture_io do
      simulate_stdin("users", keypress(:n)) do
        Rephlex::Commands::Remove.new({}).remove_data_model(verbose: false)
      end
    end
    assert File.exist?("app/users/data_model.rb"), "File was removed!"
  end

  #############################
  #         Routes            #
  #############################
  def test_remove_route
    capture_io do
      simulate_stdin("users") do
        Rephlex::Commands::Generate.new({}).generate_routes(verbose: false)
      end
    end
    capture_io do
      simulate_stdin("users", keypress(:y)) do
        Rephlex::Commands::Remove.new({}).remove_routes(verbose: false)
      end
    end
    refute File.exist?("app/users/routes.rb"), "Routes not removed"
  end

  def test_on_second_thought_about_removing_those_routes
    capture_io do
      simulate_stdin("users") do
        Rephlex::Commands::Generate.new({}).generate_routes(verbose: false)
      end
    end
    capture_io do
      simulate_stdin("users", keypress(:n)) do
        Rephlex::Commands::Remove.new({}).remove_routes(verbose: false)
      end
    end
    assert File.exist?("app/users/routes.rb"), "File was removed!"
  end

  #############################
  #         Decorators        #
  #############################

  def test_remove_decorator
    capture_io do
      simulate_stdin("users", "prefix") do
        Rephlex::Commands::Generate.new({}).generate_decorator(verbose: false)
      end
    end
    capture_io do
      simulate_stdin("users", "prefix", keypress(:y)) do
        Rephlex::Commands::Remove.new({}).remove_decorator(verbose: false)
      end
    end
    refute File.exist?("app/users/prefix_decorator.rb"), "Decorator not removed"
  end

  def test_on_second_thought_about_removing_that_decorator
    capture_io do
      simulate_stdin("users", "prefix") do
        Rephlex::Commands::Generate.new({}).generate_decorator(verbose: false)
      end
    end
    capture_io do
      simulate_stdin("users", "prefix", keypress(:n)) do
        Rephlex::Commands::Remove.new({}).remove_decorator(verbose: false)
      end
    end
    assert File.exist?("app/users/prefix_decorator.rb"), "File was removed!"
  end

  #############################
  #         Providers         #
  #############################
  #############################
  #         Migration         #
  #############################

  def test_remove_last_migration_file_success
    Dir.mkdir("db") unless File.directory?("db")
    Dir.mkdir("db/migrations") unless File.directory?("db/migrations")
    FileUtils.touch("db/migrations/20220101120000_migration1.rb")
    FileUtils.touch("db/migrations/20220101130000_migration2.rb")

    capture_io do
      simulate_stdin(keypress(:y)) do
        Rephlex::Commands::Remove.new({}).remove_migration(verbose: false)
      end
    end

    refute File.exist?("db/migrations/20220101130000_migration2.rb")
  end

  def test_remove_last_migration_file_no_files
    FileUtils.rm_rf("db/migrations")

    assert_output("\e[31mNo migration files found.\e[0m\n") do
      simulate_stdin(keypress(:n), "no_migration_file") do
        Rephlex::Commands::Remove.new({}).remove_migration(verbose: false)
      end
    end
  end

  def test_remove_last_migration_file_invalid_timestamp
    Dir.mkdir("db") unless File.directory?("db")
    Dir.mkdir("db/migrations") unless File.directory?("db/migrations")
    FileUtils.touch("db/migrations/invalid_migration.rb")

    capture_io do
      simulate_stdin(keypress(:y)) do
        Rephlex::Commands::Remove.new({}).remove_migration(verbose: false)
      end
    end

    # Verify that the invalid migration file has not been removed
    assert File.exist?("db/migrations/invalid_migration.rb")
  end
  #############################
  #         Allocation        #
  #############################
  def teardown
    FileUtils.rm_rf("app")
    FileUtils.rm_rf("db")
  end
end
