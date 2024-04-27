# frozen_string_literal: true

module Smolsrv
  class Log
    include Singleton
    extend Forwardable

    def_delegators :@logger, :debug, :info, :warn

    def initialize(dest=STDERR)
      @logger = Logger.new(dest)
    end

    def self.warn(msg)
      instance.warn(msg)
    end

    def self.debug(msg)
      instance.debug(msg)
    end

    def self.info(msg)
      instance.info(msg)
    end
  end
end
