# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class MockEmitter < SidekiqEvents::Emitter
  # Used to test if the _event_source is set to the inherited class, or this one
end

class MockHandlerEvent < SidekiqEvents::Event
  event_name :bar

  attribute :foo, Types::String.optional
end

class ClassThatHandlesAnEvent
  include SidekiqEvents::Handler

  attr_accessor :bar

  def update_bar
    self.bar = 'handled the event'
  end

  handle MockHandlerEvent do |_event|
    update_bar
  end
end

describe SidekiqEvents::Handler do
  before do
    @handler = ClassThatHandlesAnEvent.new
    @event = MockHandlerEvent.new(foo: 'test')
    @emitter = MockEmitter.new
  end

  it 'checking handles? the correct event' do
    @handler.handles?(@event)
  end

  it 'using handle! handles a particular event' do
    assert_nil(@handler.bar)
    @handler.handle!(@event)

    assert_equal('handled the event', @handler.bar)
  end

  it 'logs a message when SidekiqEvents is disabled' do
    SidekiqEvents::Configuration.stub :disabled?, true do
      assert_equal("SidekiqEvents is disabled, the event won't be emitted", @emitter.call(@event))
    end
  end
end
