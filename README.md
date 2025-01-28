## Sidekiq Events

The main goal of this gem is to provide a simple way to publish events and subscribe to them.
This gem was heavily inspired by the [Wisper](https://github.com/krisleech/wisper) and [WisperSidekiq](https://github.com/krisleech/wisper-sidekiq) gems.

### Use cases

### Installation

```ruby
gem 'sidekiq-events', github: 'patrickemuller/sidekiq-events'
```

### Usage

Emitting new events is easy, and can be done like the following example:

First, you create a new event class:

```ruby
class MyEventName < ::SidekiqEvents::Event
  # Optional, but also possible, you can overwrite the sidekiq options for the event
  sidekiq_options queue: 'should_be_this_queue', retry: 999

  # Define the custom attributes that will be used in the event, otherwise
  # it will use the default attributes from the parent class
  # Attributes are provided from the dry-types gem
  
  # attribute :_id, Types::String
  # attribute :_event_source, Types::String
  # attribute :emitted_at, Types::String
  # attribute :attributes, Types::Array
  attribute :order_id, Types::Integer
  attribute :order_uuid, Types::String
  
  # You can also overwrite the event_name for the event class
  # This is useful when you have multiple events that should fall
  # under the same "category" of events
  def self.event_name
    'my_event_name'
  end
end
```

Then, you can publish the event like this:
```ruby
event = MyEventName.new(order_id: 1, order_uuid: 'abcd1234')
# Call methods can be shortened to .() instead of call.()
SidekiqEvents::Emitter.(event)
```

And then, finally, you define which classes will handle the emitted events.
This can be used for any class that process information.
Any class with "handle" will listen to those events and process them using the attributes you provided.

The same applies for background jobs. You can have a class `class YouBackgroundJob < ActiveJob::Base` 
that will handle the events you emitted, and process them in the background.

```ruby
class SomeOrderCommand
  def call(order_identifier, some_named_argument: nil)
    order = ::Order.find_by(id: order_identifier).or(::Order.find_by(uuid: order_identifier))
    # .... your implementation
    order
  end

  handle ::MyEventName do |event|
    self.(event.order_id || event.order_uuid)
  end
  
  # OR
  
  handle [::MyEventName, ::AnotherEvent] do |event|
    self.(event.order_id || event.order_uuid)
  end
end
```

### Inspecting event/emitter attributes

It's possible to identify the origin of the event, and which attributes were used to emit the event.

```ruby
# Build the event and it's attributes
event = MyEventName.new(order_id: 1, order_uuid: 'abcd1234')
# Initialize the emitter
emitter = SidekiqEvents::Emitter.new
# Emit the event
emitter.(event)

# Inspecting the event attributes
event.attributes
#=> { order_id: 1, order_uuid: 'abcd1234' }
# Inspecting the emitter attributes
emitter.attrs
#=> { order_id: 1, order_uuid: 'abcd1234' }
```

### ROADMAP

- Add support for debouncing events so they don't process more than one time
- Add support for the Zeitwerk autoloader