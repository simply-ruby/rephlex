require "pathname"

module PathHelper
  def find_root_with_flag(flag, root_path, default = nil)
    while root_path && File.directory?(root_path) &&
            !File.exist?("#{root_path}/#{flag}")
      parent = File.dirname(root_path)
      root_path = parent != root_path && parent
    end

    root = File.exist?("#{root_path}/#{flag}") ? root_path : default
    raise "Could not find root path for #{self}" unless root

    Pathname.new(File.realpath(root))
  end

  def grep_app_name_from_config(file)
    file = File.open(file, "r") unless file.is_a?(File)

    regex = /.freeze\.app/
    file.grep(regex) do |line|
      variable = line.match(/run\s+(\w+)\.freeze\.app/)[1]
      return variable
    end
    nil
  ensure
    file.close if file.is_a?(File) && file != $stdin
  end
end
