## Sidekiq Events

This gem was heavily inspired by the [Wisper](https://github.com/krisleech/wisper) and [WisperSidekiq](https://github.com/krisleech/wisper-sidekiq) gems.

The main goal of this gem is to provide a simple way to publish events and subscribe to them.

Emitting new events is easy, and can be done like the following example:

First, you create a new event class:

```ruby
class MyEventName < Sidekiq::Events::Event
  # Optional, but also possible, keys should be a method/attribute that is present in the event class 
  sidekiq_options queue: 'should_be_this_queue', retry: 999

  def initialize(order_id)
    @order_id = order_id
  end
  
  def order_id
    @order_id
  end
  
  # You can also overwrite the event_name for the event class
  def self.event_name
    'my_event_name'
  end
end
```

Then, you can publish the event like this:
```ruby
event = MyEventName.new(order_id: 1)
# Call methods can be shortened to .() instead of call.()
Sidekiq::Events::Emitter.(event)
```

And then, finally, you define which classes will handle the emitted events.
This can be used for any class that process information.
Any class with "handle" will listen to those events and process them using the attributes you provided.

```ruby
class SomeOrderCommand
  def call(order_id, some_named_argument: nil)
    order = ::Order.find(order_id)
    # .... implementation
    order
  end

  handle ::MyEventName do |event|
    self.(event.order_id)
  end
  
  # OR
  
  handle [::MyEventName, ::AnotherEvent] do |event|
    self.(event.order_id)
  end
end
```