# frozen_string_literal: true

module SidekiqEvents
  # @example
  #  SidekiqEvents::Configure.configure do |config|
  #    config.enabled = true
  #  end
  class Configuration
    attr_accessor :logger
    attr_reader :enabled

    def initialize
      @enabled = true
      @logger = Logger.new($stdout)
    end

    def enabled=(value)
      @enabled = to_boolean(value)
    end

    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end

      def disabled?
        !configuration.enabled
      end

      def enabled?
        configuration.enabled
      end
    end

    private

    def to_boolean(value)
      case value
      when true, 'true', 'TRUE', '1', 1
        true
      when false, 'false', 'FALSE', '0', 0
        false
      else
        raise ArgumentError, "Invalid value for boolean: #{value}"
      end
    end
  end
end
