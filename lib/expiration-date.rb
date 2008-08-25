
require 'thread'

module ExpirationDate

  # :stopdoc:
  VERSION = '1.1.0'
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
    # time. The block is evaluated in the context of the instance (as
    # opposed to being evaluated in the context of the class where the block
    # is declared).
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
    #   a.foo              #=> 'foo'
    #   a.foo = 'bar'
    #   a.foo              #=> 'bar'
    #   sleep 61
    #   a.foo              #=> 'foo'
    #
    def expiring_attr( name, age, &block )
      raise ArgumentError, "a block must be given" if block.nil?

      name = name.to_sym
      age = Float(age)
      _managers_specials[name] = block

      self.class_eval <<-CODE, __FILE__, __LINE__
        def #{name}
          now = Time.now
          label = _expiration_labels[#{name.inspect}]
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
          label = _expiration_labels[#{name.inspect}]
          label.mutex.synchronize {
            @#{name} = val
            label.age ||= #{age}
            label.expires_on = now + label.age
          }
          @#{name}
        end

        def expire_#{name}_now
          label = _expiration_labels[#{name.inspect}]
          label.mutex.synchronize {label.expires_on = Time.now - 1}
          @#{name}
        end

        def alter_#{name}_age( age )
          label = _expiration_labels[#{name.inspect}]
          label.mutex.synchronize {label.age = Float(age)}
        end
      CODE
    end

    # Declares a new class attribute that will expire after _age_ seconds
    # and be replaced by the results of running the _block_. The block is
    # lazily evaluated when the attribute is accessed after the expiration
    # time. The block is evaluated in the context of the class.
    #
    # Obviously this scheme will only work if the attribute is only accessed
    # using the setter and getter methods defined by this function.
    #
    #   class A
    #     include ExpirationDate
    #     expiring_class_attr( :foo, 60 ) { 'foo' }
    #   end
    #
    #   A.foo              #=> 'foo'
    #   A.foo = 'bar'
    #   A.foo              #=> 'bar'
    #   sleep 61
    #   A.foo              #=> 'foo'
    #
    def expiring_class_attr( name, age, &block )
      raise ArgumentError, "a block must be given" if block.nil?

      name = name.to_sym
      age = Float(age)
      _class_managers_specials[name] = block

      self.class_eval <<-CODE, __FILE__, __LINE__
        def self.#{name}
          now = Time.now
          label = _class_expiration_labels[#{name.inspect}]
          if label.expires_on.nil? || now >= label.expires_on
            label.mutex.synchronize {
              break unless label.expires_on.nil? || now >= label.expires_on
              block = ::#{self.name}._class_managers_specials[#{name.inspect}]
              @#{name} = instance_eval(&block)
              label.age ||= #{age}
              label.expires_on = now + label.age
            }
          end
          @#{name}
        end

        def self.#{name}=( val )
          now = Time.now
          label = _class_expiration_labels[#{name.inspect}]
          label.mutex.synchronize {
            @#{name} = val
            label.age ||= #{age}
            label.expires_on = now + label.age
          }
          @#{name}
        end

        def self.expire_#{name}_now
          label = _class_expiration_labels[#{name.inspect}]
          label.mutex.synchronize {label.expires_on = Time.now - 1}
          @#{name}
        end

        def self.alter_#{name}_age( age )
          label = _class_expiration_labels[#{name.inspect}]
          label.mutex.synchronize {label.age = Float(age)}
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

    def _class_managers_specials
      @_class_managers_specials ||= Hash.new
    end

    def _class_expiration_labels
      @_class_expiration_labels ||= Hash.new do |h,k|
        h[k] = ExpirationLabel.new(Mutex.new)
      end
    end
    # :startdoc:
  end

  # Accessor that returns the hash of ExpirationLabel objects.
  #
  def _expiration_labels
    @_expiration_labels ||= Hash.new do |h,k|
      h[k] = ExpirationLabel.new(Mutex.new)
    end
  end

end  # module ExpirationDate

# EOF
