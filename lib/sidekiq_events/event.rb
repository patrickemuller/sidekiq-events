# frozen_string_literal: true

module SidekiqEvents
  class Event < ::Dry::Struct
    module Types
      include Dry.Types()
    end

    extend Forwardable

    attribute :_id, Types::String.optional
    attribute :_event_source, Types::String.optional
    attribute :emitted_at, Types::DateTime.optional

    def_delegators 'self.class', :event_name, :i18n_event_name, :handler_name, :handler_name_for_channel, :sidekiq_options

    # rubocop:disable Style/OptionalBooleanParameter
    def self.new(attributes = default_attributes, safe = false, &)
      # if optional parameters are missing, set them to nil
      schema.each do |key|
        attributes[key.name] = nil if key.optional? && !attributes.key?(key.name)
      end

      attributes[:_id] = SecureRandom.uuid

      super
    end
    # rubocop:enable Style/OptionalBooleanParameter

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
      event_source && event_source == klass.to_s
    end

    def event_source
      _event_source
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
