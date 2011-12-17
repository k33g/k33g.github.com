---

layout: post
title: CoffeeScript and Properties
info : CoffeeScript and Properties

---

#CoffeeScript and Properties

With the latest browsers, you can set properties for your objects. And as CoffeScript makes your code more beautiful, the result is quite nice.

##First, create function "prop"

{% highlight coffeescript %}
    prop = (who, propName, getset) ->
      Object.defineProperty who, propName,
        get: getset.get
        set: getset.set
        enumerable: true
        configurable: true
{% endhighlight %}

##Now, you can write your classes like this :

{% highlight coffeescript %}
    class Human
      constructor:(name)->
        _name = name

        prop @,"Name",
          get:->
            console.log "get : ", _name
            _name

          set:(value)->
            _name = value
            console.log "set : ", _name

      hello:->
        console.log "Hi, i am #{@Name}"
{% endhighlight %}

##And, use "super" when extending classes

{% highlight coffeescript %}
    class SuperHeroe extends Human
      constructor:(name, power)->
        super name
        _power = power

        prop @,"Power",
          get:->
            _power
          set:(value)->
            _power = value
{% endhighlight %}

##Use it ...

{% highlight coffeescript %}
    bob = new Human "Bob"
    bob.Name = "Bobby"
    bob.hello()

    ### Output :
    set :  Bobby
    get :  Bobby
    Hi, i am Bobby
    ###
{% endhighlight %}

Personally, i find it pretty, and remember that the properties do not exist in java ;) (big troll).

Have a great weekend.

Stay tuned, coming soon:

- Play! ► 2: java tutorial
- Play! ► 2: scala tutorial
- And probably a small part of CouchDB
