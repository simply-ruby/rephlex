require "tty-prompt"
class TestGenerate < Minitest::Test
  include IoTestHelpers
  def setup
    File.open("config.ru", "w") { |file| file.write("run Test.freeze.app") }
    @generator = Rephlex::Commands::Generate.new({})
  end

  def teardown
    FileUtils.rm_rf("allocs")
    FileUtils.rm_rf("system")
    File.delete("config.ru") if File.exist?("config.ru")
  end
end
