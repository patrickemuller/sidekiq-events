# frozen_string_literal: true

require 'minitest/autorun'
require 'sidekiq/events/event'
require 'sidekiq/events/emitter'

class MockEmitter < Sidekiq::Events::Emitter
  # Used to test if the _event_source is set to the inherited class, or this one
end

class MockEmitterEvent < Sidekiq::Events::Event
  event_name :bar

  def foo
    'foo'
  end
end

describe Sidekiq::Events::Emitter do
  it 'extracts event name, attributes, and event source class from an event and publishes them over wisper' do
    event = MockEmitterEvent.new(foo: 'test')
    emitter = MockEmitter.new

    assert(emitter.call(event))
    assert_equal({ foo: 'test', _id: event._id, emitted_at: event.emitted_at, _event_source: 'MockEmitter' },
                 emitter.attrs)
  end
end
