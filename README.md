## Sidekiq Events

The main goal of this gem is to provide a simple way to publish events and subscribe to them.
This gem was heavily inspired by the [Wisper](https://github.com/krisleech/wisper) and [WisperSidekiq](https://github.com/krisleech/wisper-sidekiq) gems.

### Use cases

### Installation

This gem WON'T work with ruby 3.2 or 3.1 due to dependencies with Zeitwerk-2.7.1.
It's recommended to use ruby 3.3 or newer.
jRuby is also not tested, you should try yourself.

```ruby
gem 'sidekiq_events', github: 'patrickemuller/sidekiq-events'
```

It's also possible to enable/disable the gem in the application by setting the initializer for it:

```ruby
SidekiqEvents::Configuration.configure do |config|
  config.enabled = ENV.fetch('SIDEKIQ_EVENTS_ENABLED', true)
end
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
  include SidekiqEvents::Handler

  def call(order_identifier, some_named_argument: nil)
    order = ::Order.find_by(id: order_identifier).or(::Order.find_by(uuid: order_identifier))
    # .... your implementation
    order
  end

  handle ::MyEventName do |event|
    self.(event.order_id || event.order_uuid)
  end
  
  # OR
  
  handle [::MyEventName, ::AnotherEvent], sidekiq_options: { queue: 'events', retry: 123 } do |event|
    self.(event.order_id || event.order_uuid)
  end
end
```

### Using MultiEmitter

If you need to emit multiple events at once, you can use the `MultiEmitter` class. Here is an example:

```ruby
# Define your events
class EventOne < ::SidekiqEvents::Event
  attribute :data, Types::String
end

class EventTwo < ::SidekiqEvents::Event
  attribute :info, Types::String
end

# Create instances of your events
event_one = EventOne.new(data: 'example data')
event_two = EventTwo.new(info: 'example info')

# Emit multiple events at once
results = Sidekiq::Events::MultiEmitter.call([event_one, event_two])

# Inspect the results
results.each do |result|
  puts "Event: #{result[:event].class.name}, Result: #{result[:result]}"
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
#=> {:order_id=>1, :order_uuid=>"abcd1234", :_id=>"3580d0d8-9312-4fa8-9a3c-91e3288f0701", :_event_source=>nil, :emitted_at=>nil}
# Inspecting the emitter attributes
emitter.attributes
#=> {:order_id=>1, :order_uuid=>"abcd1234", :_id=>"3580d0d8-9312-4fa8-9a3c-91e3288f0701", :_event_source=>"SidekiqEvents::Emitter", :emitted_at=>Tue, 28 Jan 2025 16:12:44 -0800, :_event_class=>"MyEventName"}

# And after you emit the event, you can inspect the event attributes again to see the changes
# It will contain the same attributes from the emitter, and you can use that to
# check where the event was emitted from, useful for debugging
event.attributes
#=> {:order_id=>1, :order_uuid=>"abcd1234", :_id=>"3580d0d8-9312-4fa8-9a3c-91e3288f0701", :_event_source=>"SidekiqEvents::Emitter", :emitted_at=>Tue, 28 Jan 2025 16:12:44 -0800, :_event_class=>"MyEventName"}
```

### ROADMAP

- Add support for debouncing events so they don't process more than one time
- Add support for the Zeitwerk autoloader