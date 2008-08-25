
require File.join(File.dirname(__FILE__), %w[spec_helper])

class TestA
  include ExpirationDate

  expiring_attr(:foo,  0.5) { 'foo' }
  expiring_attr('bar', 10 ) { 'bar' }
  expiring_attr(:me,   60 ) { self  }

  expiring_class_attr(:foo,  0.5) { 'class foo' }
  expiring_class_attr('bar', 10 ) { 'class bar' }
  expiring_class_attr(:me,   60 ) { self  }
end

describe ExpirationDate do
  it 'returns the same attribute before the expiration time' do
    a = TestA.new
    foo = a.foo
    foo.should be_equal(a.foo)
    foo.should == 'foo'
  end

  it 'returns a new attribute after the expiration time' do
    a = TestA.new
    foo = a.foo
    foo.should be_equal(a.foo)
    foo.should == 'foo'

    sleep 0.75
    foo.should_not be_equal(a.foo)
    a.foo.should == 'foo'
  end

  it 'can immediately expire an attribute' do
    a = TestA.new
    bar = a.bar
    bar.should be_equal(a.bar)
    bar.should == 'bar'

    a.expire_bar_now
    bar.should_not be_equal(a.bar)
    a.bar.should == 'bar'
  end

  it 'can assign an attribute' do
    a = TestA.new
    a.foo.should == 'foo'

    foobar = 'foobar'
    a.foo = foobar
    a.foo.should be_equal(foobar)

    sleep 0.75
    a.foo.should_not be_equal(foobar)
    a.foo.should == 'foo'
  end

  it "can alter an attribute's age" do
    a = TestA.new
    bar = a.bar
    bar.should be_equal(a.bar)
    bar.should == 'bar'

    # this alteration takes place only after the attribute expires
    a.alter_bar_age 0.5

    sleep 0.75
    bar.should be_equal(a.bar)

    # so now the age should only be 0.5 seconds
    a.expire_bar_now
    bar.should_not be_equal(a.bar)
    a.bar.should == 'bar'

    sleep 0.75
    bar.should_not be_equal(a.bar)
  end

  it 'executes the block in the context of the instance' do
    a = TestA.new
    a.me.should be_equal(a)
  end

  describe 'when used at the class level' do
    it 'returns the same attribute before the expiration time' do
      foo = TestA.foo
      foo.should be_equal(TestA.foo)
      foo.should == 'class foo'
    end

    it 'returns a new attribute after the expiration time' do
      foo = TestA.foo
      foo.should be_equal(TestA.foo)
      foo.should == 'class foo'

      sleep 0.75
      foo.should_not be_equal(TestA.foo)
      TestA.foo.should == 'class foo'
    end

    it 'can immediately expire an attribute' do
      bar = TestA.bar
      bar.should be_equal(TestA.bar)
      bar.should == 'class bar'

      TestA.expire_bar_now
      bar.should_not be_equal(TestA.bar)
      TestA.bar.should == 'class bar'
    end

    it 'can assign an attribute' do
      TestA.foo.should == 'class foo'

      foobar = 'foobar'
      TestA.foo = foobar
      TestA.foo.should be_equal(foobar)

      sleep 0.75
      TestA.foo.should_not be_equal(foobar)
      TestA.foo.should == 'class foo'
    end

    it "can alter an attribute's age" do
      bar = TestA.bar
      bar.should be_equal(TestA.bar)
      bar.should == 'class bar'

      # this alteration takes place only after the attribute expires
      TestA.alter_bar_age 0.5

      sleep 0.75
      bar.should be_equal(TestA.bar)

      # so now the age should only be 0.5 seconds
      TestA.expire_bar_now
      bar.should_not be_equal(TestA.bar)
      TestA.bar.should == 'class bar'

      sleep 0.75
      bar.should_not be_equal(TestA.bar)
    end

    it 'executes the block in the context of the class' do
      TestA.me.should be_equal(TestA)
    end

  end
end

# EOF
