# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require 'tempfile'
require "rephlex/cli"
require "minitest/autorun"
require "rephlex/helpers/path_helper"
require "rephlex/helpers/template_helper"

require_relative "helpers/string_io_helper"
Minitest.load_plugins
Minitest::PrideIO.pride!
