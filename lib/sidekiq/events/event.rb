# frozen_string_literal: true

require 'date'
require 'securerandom'
require 'forwardable'

module Sidekiq
  module Events
    class Event
      extend Forwardable

      attr_accessor :_id, :_event_source, :emitted_at, :attributes

      def_delegators 'self.class', :event_name, :i18n_event_name, :handler_name, :handler_name_for_channel,
                     :sidekiq_options

      # @param [Hash] attrs
      def initialize(attrs = {})
        attrs[:_id] ||= ::SecureRandom.uuid
        attrs[:emitted_at] ||= ::DateTime.now

        @attributes = attrs

        attrs.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end

      # Collection of channel names to try for this event
      #
      # @return [Array[String]]
      def channels
        [event_name]
      end

      # Collection of handler names to try for this event
      #
      # @return [Array[String]]
      def handlers
        channels.map { |channel| handler_name_for_channel(channel) }
      end

      def valid?
        !event_name.nil?
      end

      def equals?(event, except: [])
        instance_of?(event.class) && attributes.except(:_id, *except) == event.attributes.except(:_id, *except)
      end

      def emitted_by?(instance)
        emitted_by_class?(instance.class)
      end

      def emitted_by_class?(klass)
        event_source.present? && event_source == klass
      end

      def event_source
        _event_source&.safe_constantize
      end

      def self.event_name(event_name = nil)
        @event_name = event_name unless event_name.nil?

        # either we've set the event name, or we use the baked in one
        @event_name || name.underscore.to_sym
      end

      def self.i18n_event_name(event_name = nil)
        @i18n_event_name = event_name unless event_name.nil?

        # either we've set the event name, or we use the baked in one
        @i18n_event_name || name.underscore.tr('/', '.')
      end

      def self.handler_name
        handler_name_for_channel(event_name)
      end

      def self.handler_name_for_channel(channel)
        :"handle_#{channel}"
      end

      # @param [Hash{Symbol->String}] sidekiq_options
      # @example
      #   sidekiq_options(queue: 'events', retry: 3, debounce: { in_seconds: 10, keys: [:my_identifier] })
      # @return { queue: 'events', retry: 3,  }
      def self.sidekiq_options(sidekiq_options = { queue: 'events' })
        @sidekiq_options ||= sidekiq_options
      end
    end
  end
end
