require_relative "../test_helper"

class TestMigrationGenerator < TestGenerate
  include IoTestHelpers
  def setup
    super
  end

  #############################
  #     Remove Migration      #
  #############################
  def test_remove_last_migration_file_success
    Dir.mkdir("system") unless File.directory?("system")
    Dir.mkdir("system/db") unless File.directory?("system/db")
    Dir.mkdir("system/db/migration") unless File.directory?("system/db/migration")
    FileUtils.touch("system/db/migration/20220101120000_migration1.rb")
    FileUtils.touch("system/db/migration/20220101130000_migration2.rb")

    capture_io do
      simulate_stdin(keypress(:y)) do
        Rephlex::Commands::Remove.new({}).remove_migration(verbose: false)
      end
    end

    refute File.exist?("system/db/migration/20220101130000_migration2.rb")
  end

  def test_remove_last_migration_file_no_files
    FileUtils.rm_rf("system/db/migration")

    assert_output("\e[31mNo migration files found.\e[0m\n") do
      simulate_stdin(keypress(:n), "no_migration_file") do
        Rephlex::Commands::Remove.new({}).remove_migration(verbose: false)
      end
    end
  end

  def test_remove_last_migration_file_invalid_timestamp
    Dir.mkdir("system") unless File.directory?("system")
    Dir.mkdir("system/db") unless File.directory?("system/db")
    Dir.mkdir("system/db/migration") unless File.directory?("system/db/migration")
    FileUtils.touch("system/db/migration/invalid_migration.rb")

    capture_io do
      simulate_stdin(keypress(:y)) do
        Rephlex::Commands::Remove.new({}).remove_migration(verbose: false)
      end
    end

    # Verify that the invalid migration file has not been removed
    assert File.exist?("system/db/migration/invalid_migration.rb")
  end

  def teardown
    super
  end
end
