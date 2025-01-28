# frozen_string_literal: true

require 'minitest/autorun'
require 'sidekiq_events'

class MockEmitter < SidekiqEvents::Emitter
  # Used to test if the _event_source is set to the inherited class, or this one
end

class MockEmitterEvent < SidekiqEvents::Event
  event_name :bar

  attribute :foo, Types::String.optional
end

describe SidekiqEvents::Emitter do
  it 'extracts event name, attributes, and event source class from an event and publishes them over wisper' do
    event = MockEmitterEvent.new(foo: 'test')
    emitter = MockEmitter.new

    assert(emitter.call(event))
    assert_equal({ foo: 'test', _id: event._id, emitted_at: event.emitted_at, _event_class: event.class.name, _event_source: 'MockEmitter' }, emitter.attributes)
  end
end
