# = DeferProxy
#
# Create a proxy for lazy-loading objects.
#
# == Example for Ruby
#
# In the example below, we create an @array variable that behaves just like an
# Array instance, but is actually a proxy that will return array content. The
# proxy materialies this content the first time that an instance method is
# called on it:
#
#   # Create a proxy using either the DeferProxy class or Defer method:
#   @array = DeferProxy.new { p "zzz"; sleep 1; p "yawn"; [1,2,3] }
#   @array = Defer { p "zzz"; sleep 1; p "yawn"; [1,2,3] }
#
#   # Access proxy to materialize results, it will execute slowly:
#   @array.size
#   # "zzz"
#   # "yawn"
#   # => 3
#
#   # Access proxy again, it will return materialized results immediately:
#   @array.size
#   # => 3
#
# == Example for Rails
#
# Deferred-instantiation proxies are useful in Rails applications because they
# help avoid slow operations while preserving MVC encapsulation.
#
# In the example below, the +Record+ class has a ::slow_operation method that
# we wish to avoid calling if possible. We create a proxy called @records in
# the #index controller action to describe how to fetch data. The view then
# uses the @records object within a #cache block that captures HTML emitted
# within that scope. If the view finds the fragment cache for this block, then
# the @records proxy object will never be used and the ::slow_operation never
# called, thus making the action much faster.
#
#   # Model
#   class Record < ActiveRecord::Base
#     def self.slow_operation
#       puts "Performing slow operation...."
#       sleep 3
#       puts "Completed slow operation!"
#       return [1,2,3]
#     end
#   end
#
#   # Action
#   def index
#     @records = Defer { Record.slow_operation }
#   end
#
#   # View
#   <% cache "record_index" do %>
#     <%= @records.size %>
#   <% end %>
class DeferProxy
  attr_accessor :__called
  attr_accessor :__callback
  attr_accessor :__value

  def initialize(&block)
    @__callback = block
  end

  def method_missing(method, *args, &block)
    unless @__called
      @__value = @__callback.call
      @__called = true
      Rails.logger.debug("DeferProxy materialized by: #{@__value.class.name}##{method}") if defined?(Rails)
    end
    return @__value.send(method, *args, &block)
  end
end

# Return a DeferProxy instance for the given +block+.
def Defer(&block)
  return DeferProxy.new(&block)
end

__END__

# Test
load 'lib/defer_proxy.rb'
x = Defer { [1,2,3] }
x.each{|v| p v}
