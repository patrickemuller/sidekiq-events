# frozen_string_literal: true

require 'wisper/sidekiq'

module Sidekiq
  module Events
    # This class is responsible for emitting multiple events at once
    class MultiEmitter
      attr_accessor :events

      # @param events [Array<Sidekiq::Events::Event>] an array of event objects to be processed
      # @return [Array<Hash{event: Sidekiq::Events::Event, result: Object}>] an array of hashes, each containing the event and its processing result
      def call(events)
        @events = events

        return logger.info("Sidekiq::Events is disabled, events won't be emitted") if Sidekiq::Events.configuration.disabled?

        # Map returns [true, true, true], which is the result
        # of the iterations, and not the `.each` itself
        events.map do |event|
          { event: event, result: Sidekiq::Events::Emitter.call(event) }
        end
      end

      def self.call(events)
        new.call(events)
      end
    end
  end
end
