# frozen_string_literal: true

module SidekiqEvents
  module Errors
    class NoHandlerError < NoMethodError; end
  end
end
