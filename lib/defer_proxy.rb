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
  # In order to proxy the most methods, remove this object's instance methods
  # so that calls will be sent to #method_missing for forwarding.
  instance_methods.each { |m| undef_method(m) unless m =~ /^__/ || m == :object_id }

  # Create proxy that, when called, will return a value by callling the block.
  def initialize(&block)
    @__defer_proxy_callback = block
  end

  # Return true if asked if this is a kind of DeferProxy else fallback to
  # +kind_of?+ behavior of proxied object.
  def kind_of?(klass)
    return(klass == DeferProxy || method_missing(:kind_of?, klass))
  end

  # Materialize the proxied object and call it.
  def method_missing(name, *args, &block)
    return(__materialize.send(name, *args, &block))
  end

  # Return the proxied object, materializing it if needed.
  def __materialize(*args, &block)
    return(@__defer_proxy_value ||= @__defer_proxy_callback.call(*args, &block))
  end
end

# Return a DeferProxy instance for the given +block+.
def Defer(&block)
  return DeferProxy.new(&block)
end

# Return the content of a value, be it a Defer or not.
def Undefer(value)
  return value.kind_of?(DeferProxy) ? value.__materialize : value
end

# Self-test
if __FILE__ == $0
  require 'test/unit'
  class DeferProxyTest < Test::Unit::TestCase
    def test_should_proxy_an_integer
      assert_equal(1, Defer{1})
    end

    def test_should_proxy_an_array
      assert_equal([1,2,3], Defer{[1,2,3]}.map{|t| t})
    end

    def test_should_proxy_an_array_for_use_with_map
      assert_equal([1,2,3], Defer{[1,2,3]}.map{|t| t})
    end

    def test_should_be_able_to_use_kind_of_on_proxied_object
      assert(Defer{[1,2,3]}.kind_of?(Array))
    end

    def test_should_be_able_to_use_kind_of_on_self
      assert(Defer{[1,2,3]}.kind_of?(DeferProxy))
    end

    def test_should_provide_access_to_proxied_object
      assert_equal([1,2,3], Undefer(Defer{[1,2,3]}))
    end

    def test_should_provide_access_to_proxied_object_thats_not_a_defer
      assert(Undefer(Defer{[1,2,3]}).respond_to?(:__materialize) == false)
    end
  end
end
