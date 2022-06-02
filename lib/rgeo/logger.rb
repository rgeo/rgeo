# frozen_string_literal: true

require "logger"

module RGeo
  class << self
    def logger
      @logger ||= Logger.new($stdout).tap do |l|
        l.progname = name
      end
    end
    attr_writer :logger
  end
end
