# frozen_string_literal: true

require "test_helper"

class TestRephlex < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rephlex::VERSION
  end

  def test_the_begining
    assert ::Rephlex::the_beginning "This is start of something fun; now go, create!"
  end
end
