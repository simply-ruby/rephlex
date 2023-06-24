# frozen_string_literal: true

require "test_helper"

class TemplateHelperTest < Minitest::Test
  include TemplateHelper

  def test_classify
    modules = "users/accounts/balance".split("/").map { |el| classify(el) }
    assert_equal modules, %w[User Account Balance]
  end

  def test_wrap_two_modules
    content = <<-CODE
def method1
  # Code here
end
def method2
  # Code here
end
  CODE

    modules = modulify("users/accounts")
    template = wrap_route_modules(modules, "Stuff") { content }

    expected_template = <<-CODE
# frozen_string_literal: true
module User
  module Account
    class Routes < Stuff
      def method1
        # Code here
      end
      def method2
        # Code here
      end
    end
  end
end
CODE
    assert_equal expected_template, template
  end

  def test_wrap_three_modules
    content = <<-CODE
def method1
  # Code here
end
def method2
  # Code here
end
  CODE
    modules = modulify("users/accounts/balance")
    template = wrap_route_modules(modules, "Things") { content }

    expected_template = <<-CODE
# frozen_string_literal: true
module User
  module Account
    module Balance
      class Routes < Things
        def method1
          # Code here
        end
        def method2
          # Code here
        end
      end
    end
  end
end
CODE
    assert_equal expected_template, template
  end
end
