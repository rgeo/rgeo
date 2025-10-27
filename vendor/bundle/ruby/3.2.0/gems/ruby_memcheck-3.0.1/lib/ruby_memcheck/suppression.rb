# frozen_string_literal: true

module RubyMemcheck
  class Suppression
    attr_reader :root

    def initialize(configuration, suppression_node)
      @root = suppression_node
    end

    def to_s
      str = StringIO.new
      str << "{\n"
      str << "  #{root.at_xpath("sname").content}\n"
      str << "  #{root.at_xpath("skind").content}\n"
      root.xpath("./sframe/fun | ./sframe/obj").each do |frame|
        str << "  #{frame.name}:#{frame.content}\n"
      end
      str << "}\n"
      str.string
    end
  end
end
