# frozen_string_literal: true
require_relative "rephlex/version"
require_relative "rephlex/helpers/path_helper"
module Rephlex
  extend PathHelper
  class Error < StandardError
  end

  def self.root
    @root ||= find_root_with_flag("Gemfile", Dir.pwd)
  end

  def self.root=(path)
    @root = path
  end

  def self.app_name
    # Todo: Replace with method that will locate the base path and
    # Todo: infer a name from the root file
    grep_app_name_from_config(File.join(root, "config.ru"))
  end
end
