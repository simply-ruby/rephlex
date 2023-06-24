require_relative "test_helper"

class PathHelpersTest < Minitest::Test
  include PathHelper

  def test_find_root_with_flag
    temp = Dir.mktmpdir
    path_to_root = find_root_with_flag("folders", temp)
    assert_equal Pathname.new("/private/var"), path_to_root, "Root not found"
  end

  def test_grep_app_name_from_config
    temp_file = Tempfile.new("config.ru")
    begin
      # Write the desired content into the temporary file
      temp_file.write("run TestApp.freeze.app\n")
      temp_file.rewind

      app_name = grep_app_name_from_config(temp_file)
      assert_equal "TestApp", app_name, "App Name could not be found"
    ensure
      temp_file.close
      temp_file.unlink
    end
  end
end
