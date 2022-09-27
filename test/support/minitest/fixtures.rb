# frozen_string_literal: true

require "pathname"

module Support
  module Minitest
    module Fixtures
      def fixtures
        return @fixtures if defined?(@fixtures)

        @fixtures = Pathname(__dir__)
                    .join("..", "fixtures")
                    .realpath
      end
    end
  end
end

Minitest::Test.include Support::Minitest::Fixtures
