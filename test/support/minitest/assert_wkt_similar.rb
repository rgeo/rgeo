# frozen_string_literal: true

module Support
  module Minitest
    module AssertWktSimilar
      def assert_wkt_similar(a, b)
        assert_equal(Inner.normalize(a), Inner.normalize(b), "Normalized WKT differs")
      end

      module Inner
        module_function

        def normalize(wkt)
          generator.generate(parser.parse(wkt))
        end

        def parser
          @parser ||= RGeo::WKRep::WKTParser.new
        end

        def generator
          @generator ||= RGeo::WKRep::WKTGenerator.new
        end
      end
      private_constant :Inner
    end
  end
end

Minitest::Test.include Support::Minitest::AssertWktSimilar
