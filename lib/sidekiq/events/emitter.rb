# frozen_string_literal: true

require 'wisper/sidekiq'

module Sidekiq
  module Events
    class Emitter
      include ::Wisper::Publisher

      attr_accessor :attrs

      # @param event [Sidekiq::Events::Event]
      def call(event)
        @attrs = event.attributes

        return logger.info("Sidekiq::Events is disabled, the event won't be emitted") if Sidekiq::Events.configuration.disabled?

        # Event classes support a "valid" method, that will be checked in case you have rules for emitting events
        raise ArgumentError, "Event #{event.class} (#{event.event_name}) was not valid" if event.respond_to?(:valid?) && !event.valid?

        attrs[:_event_source] = self.class.to_s

        event.channels.each do |channel|
          broadcast(channel, attrs)
        end

        true
      end

      def self.call(event)
        new.call(event)
      end
    end
  end
end
