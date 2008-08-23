
require 'thread'

module ExpirationDate

  # :stopdoc:
  VERSION = '1.0.0'
  ExpirationLabel = Struct.new(:mutex, :age, :expires_on)
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # This method is called whenever this module is included by another
  # module. It is used to add class methods to the other module.
  #
  def self.included( other )
    other.extend ClassMethods
  end

  # Container for the class methods to add to including modules.
  #
  module ClassMethods

    # Declares a new instance attribute that will expire after _age_ seconds
    # and be replaced by the results of running the _block_. The block is
    # lazily evaluated when the attribute is accessed after the expiration
    # time.
    #
    # Obviously this scheme will only work if the attribute is only accessed
    # using the setter and getter methods defined by this function.
    #
    #   class A
    #     include ExpirationDate
    #     expiring_attr( :foo, 60 ) { 'foo' }
    #   end
    #
    #   a = A.new
    #   a.foo.object_id    #=> 123456
    #   sleep 61
    #   a.foo.object_id    #=> 654321
    #
    def expiring_attr( name, age, &block )
      raise ArgumentError, "a block must be given" if block.nil?

      name = name.to_sym
      age = Float(age)
      _managers_specials[name] = block

      self.class_eval <<-CODE, __FILE__, __LINE__
        def #{name}
          now = Time.now
          label = expiration_labels[#{name.inspect}]
          if label.expires_on.nil? || now >= label.expires_on
            label.mutex.synchronize {
              break unless label.expires_on.nil? || now >= label.expires_on
              block = ::#{self.name}._managers_specials[#{name.inspect}]
              @#{name} = instance_eval(&block)
              label.age ||= #{age}
              label.expires_on = now + label.age
            }
          end
          @#{name}
        end

        def #{name}=( val )
          now = Time.now
          label = expiration_labels[#{name.inspect}]
          label.mutex.synchronize {
            @#{name} = val
            label.age ||= #{age}
            label.expires_on = now + label.age
          }
          @#{name}
        end
      CODE
    end

    # :stopdoc:
    # Class-level hash used to hold the initialization blocks for the
    # expiring attributes.
    #
    def _managers_specials
      @_managers_specials ||= Hash.new
    end
    # :startdoc:
  end

  # Immediately expire an attribute so that it will be refreshed the next
  # time it is requested.
  #
  #    expire_now( :foo )
  #
  def expire_now( name )
    name = name.to_sym
    if expiration_labels.key?(name)
      now = Time.now
      label = expiration_labels[name]
      label.mutex.synchronize {
        label.expires_on = now - 1
      }
    end
  end

  # Alter the _age_ of the named attribute. This new age will be used the
  # next time the attribute expries to determine the new expiration date --
  # i.e. the new age does not immediately take effect. You will need to
  # manually expire the attribute if you want the new age to take effect
  # immediately.
  #
  # Modify the 'foo' attribute so that it expires every 60 seconds.
  #
  #    alter_expiration_label( :foo, 60 )
  #
  # Modify the 'bar' attribute so that it expires every two minutes. Make
  # this new age take effect immediately.
  #
  #    alter_expiration_label( :bar, 120 )
  #    expire_now( :bar )
  #
  def alter_expiration_label( name, age )
    name = name.to_sym
    if expiration_labels.key?(name)
      label = expiration_labels[name]
      label.mutex.synchronize {
        label.age = Float(age)
      }
    end
  end

  # Accessor that returns the hash of ExpirationLabel objects.
  #
  def expiration_labels
    @expiration_labels ||= Hash.new do |h,k|
      h[k] = ExpirationLabel.new(Mutex.new)
    end
  end

end  # module ExpirationDate

# EOF
