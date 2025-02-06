# frozen_string_literal: true

require 'test_helper'

class MockEvent < SidekiqEvents::Event
  event_name 'my_custom_event'

  sidekiq_options queue: 'default', retry: 3

  attribute :foo, Types::String.optional
end

describe SidekiqEvents::Event do
  it 'correctly set the attributes using .new' do
    event = MockEvent.new(foo: 'test')

    # Emitted At and Event Source are set when the event is actually emitted by the emitter
    assert_equal({ foo: 'test', _id: event._id, emitted_at: nil, _event_source: nil }, event.attributes)
  end

  it 'correctly set the channels' do
    event = MockEvent.new(foo: 'test')

    assert_equal(['my_custom_event'], event.channels)
  end

  it 'correctly set the event_name' do
    event = MockEvent.new

    assert_equal('my_custom_event', event.event_name)
  end

  it 'correctly set the sidekiq_options' do
    event = MockEvent.new

    assert_equal({ queue: 'default', retry: 3 }, event.sidekiq_options)
  end
end
