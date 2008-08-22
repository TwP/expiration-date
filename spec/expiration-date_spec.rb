
require File.join(File.dirname(__FILE__), %w[spec_helper])

class TestA
  include ExpirationDate

  expiring_attr(:foo,  0.5) { 'foo' }
  expiring_attr('bar', 10 ) { 'bar' }
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

    a.expire_now(:bar)
    bar.should_not be_equal(a.bar)
    a.bar.should == 'bar'
  end

  it 'can alter an expiration label' do
    a = TestA.new
    bar = a.bar
    bar.should be_equal(a.bar)
    bar.should == 'bar'

    # this alteration takes place only after the attribute expires
    a.alter_expiration_label('bar', 0.5)

    sleep 0.75
    bar.should be_equal(a.bar)

    # so now the age should only be 0.5 seconds
    a.expire_now(:bar)
    bar.should_not be_equal(a.bar)
    a.bar.should == 'bar'

    sleep 0.75
    bar.should_not be_equal(a.bar)
  end

  it 'ignores requests on unknown expriation lables' do
    a = TestA.new

    h = a.expiration_labels
    h.keys.length == 2

    a.expire_now(:foobar)
    h.keys.length == 2

    a.alter_expiration_label(:foobar, 42)
    h.keys.length == 2
  end
end

# EOF
