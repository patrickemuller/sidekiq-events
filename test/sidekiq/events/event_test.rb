# frozen_string_literal: true

require 'minitest/autorun'
require 'sidekiq/events/event'

class MockEmitterEvent < Sidekiq::Events::Event
  event_name 'my_custom_event'

  sidekiq_options queue: 'default', retry: 3

  def foo
    'foo'
  end
end

describe Sidekiq::Events::Event do
  it 'correctly set the attributes using .new' do
    event = MockEmitterEvent.new(foo: 'test')

    assert_equal({ foo: 'test', _id: event._id, emitted_at: event.emitted_at }, event.attributes)
  end

  it 'correctly set the channels' do
    event = MockEmitterEvent.new(foo: 'test')

    assert_equal(['my_custom_event'], event.channels)
  end

  it 'correctly set the event_name' do
    event = MockEmitterEvent.new

    assert_equal('my_custom_event', event.event_name)
  end

  it 'correctly set the sidekiq_options' do
    event = MockEmitterEvent.new

    assert_equal({ queue: 'default', retry: 3 }, event.sidekiq_options)
  end
end
