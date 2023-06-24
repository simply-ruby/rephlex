# frozen_string_literal: true

require_relative "../lib/rephlex"

class TestRephlex < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rephlex::VERSION
  end
end
