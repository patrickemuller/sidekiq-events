# frozen_string_literal: true

require 'test_helper'

class MockMultiEmitter < SidekiqEvents::Emitter
  # Used to test if the _event_source is set to the inherited class, or this one
end

class MockMultiEmitterEvent < SidekiqEvents::Event
  event_name :bar

  attribute :foo, Types::String.optional
end

describe SidekiqEvents::MultiEmitter do
  before do
    @events = [
      MockMultiEmitterEvent.new(foo: 'test1'),
      MockMultiEmitterEvent.new(foo: 'test2')
    ]
    @multi_emitter = SidekiqEvents::MultiEmitter.new
  end

  it 'emits multiple events' do
    results = @multi_emitter.call(@events)

    results.each_with_index do |result, index|
      assert_equal @events[index], result[:event]
      assert result[:result]
    end
  end

  it 'returns a message if SidekiqEvents is disabled' do
    SidekiqEvents::Configuration.stub :disabled?, true do
      assert_equal "SidekiqEvents is disabled, events won't be emitted", @multi_emitter.call(@events)
    end
  end

  it 'sets the events attribute' do
    @multi_emitter.call(@events)

    assert_equal @events, @multi_emitter.events
  end

  it 'calls the class method' do
    results = SidekiqEvents::MultiEmitter.call(@events)

    results.each_with_index do |result, index|
      assert_equal @events[index], result[:event]
      assert result[:result]
    end
  end
end
