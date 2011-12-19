---

layout: post
title: CoffeeScript Model Classes like Playframework's Models
info : CoffeeScript Model Classes like Playframework's Models

---

#Write CoffeeScript Model Classes like Playframework's Models

I love how models operate in Playframewok [http://www.playframework.org/documentation/1.2.4/model](http://www.playframework.org/documentation/1.2.4/model). In this article I will try to do the same with Coffeescript.

**Warning** : My "POC" works only with recent browsers

So, we are going create a class model step by step.

##Automatically generate properties from public fields

{% highlight coffeescript %}
    class Model
      constructor:(args)->
        fields = Object.keys @
        that = @
        fields.forEach (item) ->
          propertyName = item.toString()
          that["_"+propertyName] = that[propertyName]
          Object.defineProperty that, propertyName,
            get: ->
              console.log "Get : ", propertyName, that["_"+propertyName]
              that["_"+propertyName]
            set: (value)->
              console.log "Set : ", propertyName, value
              that["_"+propertyName] = value
            enumerable: true
            configurable: true
{% endhighlight %}


###What's going on?

- The class constructor parses each field of itself (`Object.keys @`)
- Create (for each field) a new field prefixed with "_"
- Create (instead of each field) a property (with the same name)

Then, when you write `bob.name` it's `bob._name` wich is returned, when you write `bob.name="Bob"` it's `bob._name` wich equals `"Bob"`.

**Remark** :

You shoul have noticed that i use : `that = @`, it's a javascript habit. In fact, it's better using "fat arrow", see [http://jashkenas.github.com/coffee-script/#fat_arrow](http://jashkenas.github.com/coffee-script/#fat_arrow), and then, there is no need to use the artificial `that = @` :

{% highlight coffeescript %}
    class Model
      constructor:(args)->
        fields = Object.keys @

        fields.forEach (item) =>
          propertyName = item.toString()
          @["_"+propertyName] = @[propertyName]
          Object.defineProperty @, propertyName,
            get: =>
              console.log "Get : ", propertyName, @["_"+propertyName]
              @["_"+propertyName]
            set: (value)=>
              console.log "Set : ", propertyName, value
              @["_"+propertyName] = value
            enumerable: true
            configurable: true
{% endhighlight %}


###Use it

{% highlight coffeescript %}
    #Human Model
    class Human  extends Model
      constructor:(name)->
        @name = name
        super

    #Task Model
    class Task extends Model
      constructor:(label)->
        @label = label
        @priority = "strong"
        super

    task1 = new Task "Milk"
    task2 = new Task "Butter"

    bob = new Human "BOB"
    sam = new Human "SAM"

    task1.label = "Remember the milk"
    bob.name = "Bobby"

    console.log sam.name

    console.log task1, task2, bob, sam
{% endhighlight %}

I launch this code in a navigator (you can use node.js too if you want), and i get this :

![Alt "coffeemods01.png"](https://github.com/k33g/k33g.github.com/raw/master/images/coffeemods01.png)

##I want to subscribe to "changes"

This approach is more "javascript/coffescript" than "playframework" but it's interesting for the development of web pages.

###Create a Event class :

{% highlight coffeescript %}
    class Event
      @send:(eventName, data)->
        evt = document.createEvent("Event")
        evt.initEvent eventName, false, false
        evt.data = data
        document.dispatchEvent evt
{% endhighlight %}

###Update the Model class :

{% highlight coffeescript %}
    class Model
      constructor:(args)->
        fields = Object.keys @

        fields.forEach (item) =>
          propertyName = item.toString()
          @["_"+propertyName] = @[propertyName]
          Object.defineProperty @, propertyName,
            get: =>
              console.log "Get : ", propertyName, @["_"+propertyName]
              @["_"+propertyName]
            set: (value)=>
              #save old value
              old = @["_"+propertyName]
              console.log "Set : ", propertyName, value
              @["_"+propertyName] = value

              #fire change event
              Event.send "Change",
                property: propertyName
                newValue : value
                oldValue : old

            enumerable: true
            configurable: true
{% endhighlight %}

###Use it

{% highlight coffeescript %}
    #Human Model
    class Human  extends Model
      constructor:(name)->
        @name = name
        super

    #Task Model
    class Task extends Model
      constructor:(label)->
        @label = label
        @priority = "strong"
        super


    document.addEventListener "Change", ((e) ->
      console.log "Change", e.data
    ), false

    task1 = new Task "Milk"
    bob = new Human "BOB"

    task1.label = "Remember the milk"
    bob.name = "Bobby"
{% endhighlight %}

I launch this code in a navigator, and i get this :

![Alt "coffeemods02.png"](https://github.com/k33g/k33g.github.com/raw/master/images/coffeemods02.png)

##I want a list of models for each child class model

I mean, if i have a Task class Model, i want something like that : `ask.list`, if i have a Human class Model, i want : `Human.list`.

I'll do it this way: in the constructor of the model, I will check if the field list exists for the parent class of the instance. If not, I add it (creepy ? yes a little, but useful).

Therefore, modify our Model class : (see last two lines of the class)

{% highlight coffeescript %}
    class Model
      constructor:(args)->
        fields = Object.keys @

        fields.forEach (item) =>
          propertyName = item.toString()
          @["_"+propertyName] = @[propertyName]
          Object.defineProperty @, propertyName,
            get: =>
              console.log "Get : ", propertyName, @["_"+propertyName]
              @["_"+propertyName]
            set: (value)=>
              #save old value
              old = @["_"+propertyName]
              console.log "Set : ", propertyName, value
              @["_"+propertyName] = value

              #fire change event
              Event.send "Change",
                property: propertyName
                newValue : value
                oldValue : old

            enumerable: true
            configurable: true

        #create static list of models
        if not @.__proto__.constructor.list
          @.__proto__.constructor.list = []
{% endhighlight %}

###Add a save method (in memory) to the class Model

What i want ? If i save a model, it adds itself to the list, if it's a new model, an id (guid) is automatically generated (if not exists) and the model is pushed to the list. If id exists, we check if model exists in the list, if not it is pushed too, if it exists, updates are automatically reflected (the magic of javascript ;) (*) ).

Then, i add a save method and a static guid method (to generate GUID) to the Model class :

{% highlight coffeescript %}
      @guid : ->
        S4 = ->
          (((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1
        S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4()

      save:->
        list = @.__proto__.constructor.list
        if @id is `undefined` or @id is null or @id is ""
          @id = Model.guid()
          list.push @
        else
          tmp = list.filter((record) =>
            record.id is @.id
          )[0]
          (if not tmp then list.push(@))
        @
{% endhighlight %}

(*) : Once the model was saved (and therefore added to the list), you do not have to call the save method at each change (because it is in memory). But it is good practice, especially if we add persistence capabilities in the local storage, for example.

###Use it

{% highlight coffeescript %}
    task1 = new Task "Milk"
    task2 = new Task "Beer"

    bob = new Human "BOB"
    sam = new Human "SAM"

    task1.save()
    task2.save()
    bob.save()
    sam.save()

    console.log Task.list, Human.list
{% endhighlight %}

I launch this code in a navigator, and i get this :

![Alt "coffeemods03.png"](https://github.com/k33g/k33g.github.com/raw/master/images/coffeemods03.png)

###Add a delete method (in memory) to the class Model

{% highlight coffeescript %}
      delete:->
        list = @.__proto__.constructor.list
        list.splice list.indexOf(@), 1
        @
{% endhighlight %}

##I want to query my models !!!

###First all() and fetch() methods

I add those statics methods to the Model class :

{% highlight coffeescript %}
      @all:->
        @result = @list
        @

      @fetch:->
        @result
{% endhighlight %}

###Use it

{% highlight coffeescript %}
    #get all tasks
    Task.all().fetch()

    #get all humans
    Human.all().fetch()
{% endhighlight %}

###Add a find method

I add this static method to the Model class :

{% highlight coffeescript %}
      @find:(fieldOrFunction, value) ->
         if value
           @result = @list.filter((record) ->
             record[fieldOrFunction] is value
           )
         else
           @result = @list.filter(fieldOrFunction)
         @
{% endhighlight %}

###Use it

{% highlight coffeescript %}
    Human.find("name", "SAM").fetch()

    Human.find((record) ->
      record.name == "SAM" or record.name == "BOB"
    ).fetch()
{% endhighlight %}

###Add first, last and from methods

I add those statics methods to the Model class :

{% highlight coffeescript %}
      @first:->
        @result[0]

      @last:->
        @result[@result.length-1]

      @from:(from, howmuch) ->
        @_from = from
        if @_from >= 0
          @result = @result.slice(@_from, @_from + howmuch)
          delete @_from
        else
          @result = @result.slice(0, howmuch)  if howmuch >= 0
        @
{% endhighlight %}

###Use it

{% highlight coffeescript %}
    bob = new Human "BOB"
    sam = new Human "SAM"
    peter = new Human "PETER"
    clark = new Human "CLARK"

    peter.save()
    clark.save()
    bob.save()
    sam.save()

    console.log "First Human : ", Human.all().first()
    console.log "Last Human : ", Human.all().last()

    console.log "First Two Humans from first : ", Human.from(0,2).fetch()
{% endhighlight %}

I launch this code in a navigator, and i get this :

![Alt "coffeemods04.png"](https://github.com/k33g/k33g.github.com/raw/master/images/coffeemods04.png)

##I want to sort my models !!!

I add this static method to the Model class :

{% highlight coffeescript %}
      @orderBy:(what, order) ->
        if @list
          if @list.length > 0
            if typeof @list[0][what] is "string"
              @list.sort (s, t) ->
                a = s[what].toLowerCase()
                b = t[what].toLowerCase()
                return -1  if a < b
                return 1  if a > b
                0

              @list.reverse()  if order is "DESC"
            else
              #numerical sort
              if order is "DESC"
                @list.sort (a, b) ->
                  b[what] - a[what]
              else
                @list.sort (a, b) ->
                  a[what] - b[what]
        @
{% endhighlight %}

###Use it :

{% highlight coffeescript %}
    Human.all().orderBy("name","DESC").fetch()
{% endhighlight %}

##Next time ...

We will see how to use localstorage of navigator with our models.