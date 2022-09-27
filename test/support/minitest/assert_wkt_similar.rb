# frozen_string_literal: true

module Minitest::AssertWktSimilar
  def assert_wkt_similar(a, b)
    assert_equal(Inner.normalize(a), Inner.normalize(b))
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


Minitest::Test.include Minitest::AssertWktSimilar
