# frozen_string_literal: true

module SidekiqEvents
  class Emitter
    include ::Wisper::Publisher

    attr_accessor :attributes

    # @param event [SidekiqEvents::Event]
    def call(event)
      @logger ||= SidekiqEvents::Configuration.configuration.logger
      @attributes = event.attributes

      if SidekiqEvents::Configuration.disabled?
        message = "SidekiqEvents is disabled, the event won't be emitted"
        @logger.info message
        return message
      end

      # Event classes support a "valid" method, that will be checked in case you have rules for emitting events
      raise ArgumentError, "Event #{event.class} (#{event.event_name}) was not valid" if event.respond_to?(:valid?) && !event.valid?

      attributes[:emitted_at] = ::DateTime.now
      attributes[:_event_class] = event.class.name
      attributes[:_event_source] = self.class.name

      event.channels.each do |channel|
        broadcast(channel, attributes)
      end

      true
    end

    def self.call(event)
      new.call(event)
    end
  end
end
