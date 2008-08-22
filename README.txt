= Expiration Date

  by Tim Pease
  http://codeforpeople.rubyforge.org/expiration-date

== DESCRIPTION:

Wandering the grocery aisle the other day I saw a package of bacon with a neon
green sticker screaming for all to hear "THIS BACON ONLY COSTS ONE DOLLAR!!!".
Screaming bacon always intrigues me, so I grabbed the nearest store manager. He
works at the coffee shop next door, but when I told him about the screaming
bacon he had to come and see for himself.

"Oh, it's a manager's special" he told me. "When products get too old the
manager will reduce the price so they sell more quickly. This allows new
products to be put on the shelves, and the store can make some money instead of
throwing out the expired products".

I stared at him blankly. He wandered back to the coffee shop and had a latte.

I continued to stand there thinking about expiring products and how Ruby could
benefit from neon green stickers and stale bacon. Eventually the grocery
store manager came by and asked me if everything was okay. I grabbed him by the
collar, pointed at the bacon and yelled "DO YOU KNOW WHAT THIS MEANS!?!?". I
ran from the store, grabbed my laptop, and whipped up this little gem.

EXPIRATION DATE (now with more neon green).

Now ruby can expire it's bacon, too, just like the grocery store, and make room
for more bacon from the delivery truck.

== SYNOPSIS:

The ExpirationDate module adds the "expiring_attr" method to a class. This
method is used to define an attribute that will expire after some period of
seconds have elapsed.

A simple example demonstrating how the block gets called after the expiration
time is passed.

  class A
    include ExpirationDate
    expiring_attr( :foo, 60 ) { 'foo' }
  end

  a = A.new
  a.foo                  #=> 'foo'
  a.foo.object_id        #=> 123456
  a.foo.object_id        #=> 123456

  sleep 61
  a.foo.object_id        #=> 654321

  a.foo = 'bar'
  a.foo                  #=> 'bar'
  sleep 61
  a.foo                  #=> 'foo'

A slightly more useful example. Here we are going to extract information from a
database every five minutes. This assumes you have the 'activesupport' and
'activerecord' gems installed.

  class MyModel < ::ActiveRecord::Base
    include ExpirationDate
    expiring_attr( :costly_data, 5.minutes ) {
      models = MyModel.find( :all, :conditions => ['costly query conditions'] )
      result = models.map {|m| # costly operations here}
      result
    }
  end

Attributes can be expired manually, and the time it takes them to expire can be
modified as well.

  class AgeDemo
    include ExpirationDate
    expiring_attr( :bar, 120 ) { Time.now }
  end

  demo = AgeDemo.new
  demo.bar               #=> now

  sleep 60
  demo.bar               #=> 60 seconds ago

  demo.expire_now(:bar)
  demo.bar               #=> now

  demo.alter_expiration_label(:bar, 10)
  demo.expire_now(:bar)
  demo.bar               #=> now
  sleep 11
  demo.bar               #=> now

== REQUIREMENTS:

This is a pure ruby library. There are no requirements for using this code.

== INSTALL:

  sudo gem install expiration-date

== LICENSE:

The MIT License

Copyright (c) 2008

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
