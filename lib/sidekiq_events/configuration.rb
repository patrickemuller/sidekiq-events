# frozen_string_literal: true

module SidekiqEvents
  # @example
  #  SidekiqEvents::Configure.configure do |config|
  #    config.enabled = true
  #  end
  class Configuration
    attr_accessor :enabled

    def initialize
      @enabled = true
    end

    class << self
      # Provides a global configuration instance
      def configuration
        @configuration ||= Configuration.new
      end

      # Yields the configuration instance for easy customization
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
  end
end
