# frozen_string_literal: true

require 'test_helper'

describe SidekiqEvents::Configuration do
  before do
    @config = SidekiqEvents::Configuration.new
  end

  it 'defaults to enabled' do
    assert @config.enabled
  end

  it 'sets enabled to true with various true values' do
    @config.enabled = 'true'

    assert @config.enabled

    @config.enabled = 'TRUE'

    assert @config.enabled

    @config.enabled = 1

    assert @config.enabled

    @config.enabled = true

    assert @config.enabled
  end

  it 'sets enabled to false with various false values' do
    @config.enabled = 'false'

    refute @config.enabled

    @config.enabled = 'FALSE'

    refute @config.enabled

    @config.enabled = 0

    refute @config.enabled

    @config.enabled = false

    refute @config.enabled
  end

  it 'raises an error with invalid values' do
    assert_raises(ArgumentError) { @config.enabled = 'invalid' }
  end

  it 'tests class methods' do
    SidekiqEvents::Configuration.configure do |config|
      config.enabled = 'false'
    end

    assert_predicate SidekiqEvents::Configuration, :disabled?
    refute_predicate SidekiqEvents::Configuration, :enabled?

    SidekiqEvents::Configuration.configure do |config|
      config.enabled = 'true'
    end

    assert_predicate SidekiqEvents::Configuration, :enabled?
    refute_predicate SidekiqEvents::Configuration, :disabled?
  end
end
