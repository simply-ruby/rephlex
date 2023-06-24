# frozen_string_literal: true

require_relative "rephlex/version"

module Rephlex
  class Error < StandardError
  end

  def self.root
    @root ||= Dir.pwd
  end

  def self.root=(path)
    @root = path
  end

  def self.app_name
    "Test"
  end
end
