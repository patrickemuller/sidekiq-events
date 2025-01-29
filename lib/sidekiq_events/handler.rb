# frozen_string_literal: true

module SidekiqEvents
  module Handler
    def self.included(base)
      base.extend(ClassMethods)
    end

    def handle!(event)
      raise SidekiqEvents::Errors::NoHandlerError, "Expected to handle at least one of #{event.channels.join(', ')}" unless handles?(event)

      event.handlers.each do |handler_name|
        next unless respond_to?(handler_name)

        handler = method(handler_name)
        handler.arity.zero? ? send(handler_name) : send(handler_name, event)
      end
    end

    def handles?(event)
      event.handlers.any? { |handler_name| respond_to?(handler_name) }
    end

    module ClassMethods
      attr_accessor :logger

      def handle(*klass, async: true, event_name: nil, sidekiq_options: { queue: 'events' }, prevent_loops: true, &)
        @logger ||= SidekiqEvents::Configuration.configuration.logger

        klass.each do |klass_name|
          handle_event(klass_name, async: async, event_name: event_name, sidekiq_options: sidekiq_options, prevent_loops: prevent_loops, &)
        end
      end

      private

      def handle_event(klass, async: true, event_name: nil, sidekiq_options: { queue: 'events' }, prevent_loops: true, &)
        handler_name = event_name ? "handle_#{event_name}" : klass.handler_name
        event_name ||= klass.event_name
        event_sidekiq_options ||= sidekiq_options || klass.sidekiq_options
        event_queue ||= event_sidekiq_options[:queue]

        log_subscription(event_queue, event_name, async)
        ::Wisper.subscribe(self, async: async, on: event_name)
        define_event_handler(event_name, klass, prevent_loops, event_queue)

        define_method(handler_name, &)

        define_sidekiq_options(event_sidekiq_options) if sidekiq_options
      end

      def log_subscription(event_queue, event_name, async)
        logger.info("[#{event_queue}] Subscribing #{self} to #{event_name} #{async ? 'asynchronously' : 'synchronously'}")
      end

      def define_event_handler(event_name, event_klass, prevent_loops, event_queue)
        define_singleton_method(event_name) do |event|
          # If it's a class, the attributes method should be available
          # If not, it means this is a hash with the attributes already
          event = event.attributes if event.respond_to?(:attributes)

          event = event_klass.new(event)
          raise ArgumentError, "[#{event_queue}] Event #{event.event_name} was not valid" unless event.valid?

          logger.info("[#{event_queue}] Handling Event #{event_name}")
          logger.info("[#{event_queue}] attributes: #{event.attributes}")

          self.class.new.handle!(event) unless event.emitted_by_class?(self) && prevent_loops
        end
      end

      def define_sidekiq_options(event_sidekiq_options)
        define_singleton_method(:sidekiq_options) { event_sidekiq_options }
      end
    end
  end
end
