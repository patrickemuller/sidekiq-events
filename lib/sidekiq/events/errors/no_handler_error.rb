# frozen_string_literal: true

module Sidekiq
  module Events
    module Errors
      class NoHandlerError < NoMethodError; end
    end
  end
end
