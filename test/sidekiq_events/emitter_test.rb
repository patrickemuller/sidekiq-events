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

  it 'does not emit event if SidekiqEvents is disabled' do
    event = MockEmitterEvent.new(foo: 'test')
    emitter = MockEmitter.new

    SidekiqEvents::Configuration.stub :disabled?, true do
      assert_equal("SidekiqEvents is disabled, the event won't be emitted", emitter.call(event))
    end
  end

  it 'raises an error if the event is invalid' do
    event = MockEmitterEvent.new(foo: nil) # Assuming nil is invalid for foo
    emitter = MockEmitter.new

    def event.valid?
      false
    end

    assert_raises(ArgumentError) { emitter.call(event) }
  end

  it 'sets emitted_at and _event_class attributes' do
    event = MockEmitterEvent.new(foo: 'test')
    emitter = MockEmitter.new

    emitter.call(event)

    assert_in_delta DateTime.now.to_time.to_i, emitter.attributes[:emitted_at].to_time.to_i, 1
    assert_equal 'MockEmitterEvent', emitter.attributes[:_event_class]
  end

  it 'broadcasts to all event channels' do
    event = MockEmitterEvent.new(foo: 'test')
    emitter = MockEmitter.new

    def event.channels
      %i[channel1 channel2]
    end

    emitter.stub :broadcast, true do
      assert emitter.call(event)
    end
  end
end
