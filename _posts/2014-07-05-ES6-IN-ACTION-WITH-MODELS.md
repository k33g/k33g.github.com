---

layout: post
title: ECMAScript 6 in action with the inheritance and the models 
info : ECMAScript 6 in action with the inheritance and the models 

---

#ECMAScript 6 in action with the inheritance and the models 

Last time, we saw a way to initialize an "ES6" project ([http://k33g.github.io/2014/06/26/ES6-READY.html](http://k33g.github.io/2014/06/26/ES6-READY.html)). Today, we'll see how to play with the inheritance by creating models and collections.

Initially, we've to update our nodejs application to serve data. I need a database, so I'll install **NeDB** ([http://blog.mongodb.org/post/55693224724/nedb-a-lightweight-javascript-database-using-mongodbs](http://blog.mongodb.org/post/55693224724/nedb-a-lightweight-javascript-database-using-mongodbs)).

##Server side

This is your project structure:

    es6-project/
    ├── node_modules/
    ├── public/   
    |   ├── bower_components/  
    |   ├── js/          
    |   |   └── app/
    |   |        ├── models/
    |   |        |   ├── human.js    
    |   |        |   └── humans.js   
    |   |        └── main.js
    |   └── index.html
    ├── .bowerrc
    ├── bower.json
    ├── package.json    
    └── app.js

###Install NeDB

Update `package.json`:

{% highlight javascript %}
{
  "name": "es6-project",
  "description" : "es6-project",
  "version": "0.0.0",
  "dependencies": {
    "express": "4.1.x",
    "body-parser": "1.0.2",
    "nedb": "0.10.5"
  }
}
{% endhighlight %}

And to install NeDB: type `npm install`

###REST API

Update `app.js`:

{% highlight javascript %}
var express = require('express')
  , http = require('http')
  , bodyParser = require('body-parser')
  , DataStore = require('nedb')
  , app = express()
  , http_port = 3000
  , humansDb = new DataStore({ filename: 'humansDb.nedb' });

app.use(express.static(__dirname + '/public'));
app.use(bodyParser());

// get all humans
app.get("/humans", function(req, res) {
  humansDb.find({}, function (err, docs) {
    res.send(docs);
  });

});

// get a human by id
app.get("/humans/:id", function(req, res) {
  humansDb.findOne({ _id: req.params.id }, function (err, doc) {
    res.send(doc)
  });
});

// delete human by id
app.delete("/humans/:id", function(req, res) {
  humansDb.remove({ _id: req.params.id }, {}, function (err, numRemoved) {
    res.statusCode = 200;
    res.send({res:numRemoved});
  });
});

// add a human
app.post("/humans", function(req, res) {
  var human = req.body;
  humansDb.insert(human, function (err, newDoc) {
    res.statusCode = 301;
    res.header("location", "/humans/"+newDoc._id).end();
  });

});

// update a human
app.put("/humans/:id", function(req, res) {
  humansDb.update({_id:req.params.id}, req.body, {}, function (err, numReplaced) {
    res.statusCode = 200;
    res.send({res:numReplaced});
  })
});

// run app when database loaded
humansDb.loadDatabase(function (err) {
  app.listen(http_port);
  console.log("Listening on " + http_port);
});
{% endhighlight %}

##Client side

Create the following directory: `public/js/app/core` with to javascript files:

- `model.js`
- `collection.js`

Now, your project structure is like that:

    es6-project/
    ├── node_modules/
    ├── public/   
    |   ├── bower_components/  
    |   ├── js/          
    |   |   └── app/
    |   |        ├── core/
    |   |        |   ├── model.js    
    |   |        |   └── collection.js      
    |   |        ├── models/
    |   |        |   ├── human.js    
    |   |        |   └── humans.js   
    |   |        └── main.js
    |   └── index.html
    ├── .bowerrc
    ├── bower.json
    ├── package.json    
    └── app.js

###Define our Model class

My model has fields (and url for REST calls):

{% highlight javascript %}
var model = new Model({firstName:"John", lastName:"Doe"}, "/humans");
{% endhighlight %}

My model has persistence methods : `save` (insert or update), `fetch`, `delete`:

{% highlight javascript %}
model.save()
  .done(() => /*victory!*/)
  .fail(() => /*ouch!*/)
  .always(() => /*that's all folks!*/);
{% endhighlight %}

My model has getters and setters:

{% highlight javascript %}
model.get("firstName");
model.set("firstName", "John").set("lastName", "Doe");
{% endhighlight %}

My model has an id too and it's set by the insert method of the server:
{% highlight javascript %}
// add a human
app.post("/humans", function(req, res) {
  var human = req.body;
  humansDb.insert(human, function (err, newDoc) {
    res.statusCode = 301;
    res.header("location", "/humans/"+newDoc._id).end();
  });

});
{% endhighlight %}

####Model implementation

{% highlight javascript %}
class Model {
  constructor (fields, url) {
    this.url = url !== undefined ? url : "";
    this.fields = fields !== undefined ? fields : {};
  }

  get (fieldName) {
    return this.fields[fieldName];
  }

  set (fieldName, value) {
    this.fields[fieldName] = value;
    return this;
  }

  id() { return this.get("_id");}

  save () {
     return this.id() == undefined
       ? $.ajax({
          url: this.url, 
          type: "POST", 
          data: this.fields, 
          success: (data) => { this.fields = data; }
         })
       : $.ajax({
          url: `${this.url}/${this.id()}`, 
          type: "PUT", 
          data: this.fields, 
          success: (data) => { /*foo*/ }
         });
  }

  fetch (id) {
    return id == undefined
      ? $.ajax({
          url: `${this.url}/${this.id()}`, 
          type: "GET", 
          data: this.fields, 
          success: (data) => { this.fields = data; }
        })
      : $.ajax({
          url: `${this.url}/${id}`, 
          type: "GET", 
          data: this.fields, 
          success: (data) => { this.fields = data; }
        });
  }

  delete (id) {
    return id == undefined
      ? $.ajax({
          url: `${this.url}/${this.id()}`, 
          type: "DELETE", 
          data: this.fields, success: (data) => { this.fields = data; }
        })
      : $.ajax({
          url: `${this.url}/${id}`, 
          type: "DELETE", 
          data: this.fields, 
          success: (data) => { this.fields = data; }
        });
  }
}

export default Model;
{% endhighlight %}

###Define our Collection class

My collection has:

- a property `model` (it's a collection of `model`),
- a property `models` (array of models),
- and a property `url` for REST calls

{% highlight javascript %}
var collection = new Collection(Model, "/humans", []);
{% endhighlight %}

My collection has methods:

- `add` to add models
- `size` to get the length of `collection.models`
- `fetch` to get models from server

{% highlight javascript %}
collection.fetch().done(() => {
  console.log(collection.size())
});
{% endhighlight %}

####Model implementation

{% highlight javascript %}
class Collection {
  constructor (model, url, models) {
    this.model = model;
    this.url = url !== undefined ? url : "";
    this.models = models !== undefined ? models : [];
  }

  add (model) {
    this.models.push(model);
    return this;
  }

  size () { return this.models.length; }

  fetch () {
    return $.ajax({url: this.url, type: "GET", data: this.fields, success: (models) => {
      models.forEach((fields) => {
        this.add(new this.model(fields));
      })
    }})
  }

}

export default Collection;
{% endhighlight %}

##Start with inheritance

It's now it gets interesting :)

###Define Human Model

Open `public/js/app/models/human.js` and update it like that:

{% highlight javascript %}
import Model from '../core/model';

class Human  extends Model {
  constructor (fields) {
    //superclass's constructor invocation
    super(fields, "/humans");
  }
}

export default Human;
{% endhighlight %}

No surprise, the keyword for inheritance is `extends`. And we've to import `Model` before. **Please note the use of super keyword**. You've to invoke superclass's constructor.

###Define Humans Collection

Open `public/js/app/models/humans.js` and update it like that:

{% highlight javascript %}
import Collection from '../core/collection';
import Human from './human';

class Humans extends Collection{

  constructor (humans) {
    super(Human,"/humans",humans);
  }
}

export default Humans;
{% endhighlight %}

##And now,let's play with Humans!

Open `public/js/app/main.js` and update it like that:

{% highlight javascript %}
import Human from './models/human';
import Humans from './models/humans';

class Application {

  constructor () {
    $("h1").html("E6 rocks!")

    var humans = new Humans();

    humans.fetch().done(()=>{ /* get all humans from database */

      if(humans.size()==0) { /* no human in database, then populate the collection */

        var bob = new Human({firstName:'Bob', lastName:'Morane'});
        var john = new Human({firstName:'John', lastName:'Doe'});
        var jane = new Human({firstName:'Jane', lastName:'Doe'});

        /* save models */
        bob.save().done(
          () => john.save().done(
            () => jane.save().done(
              ()=> humans.fetch().done(console.log(humans)) /* fetch again */
            )
          )
        );

      } else { /* display humans */
          console.log(humans);
      }
    })
  }
}

$(() => {
  new Application();
});
{% endhighlight %}

You can now test it, run `node app.js` and open [http://localhost:3000/](http://localhost:3000/) with your browser. There is nothing to display except **E6 rocks!**, but if you open the console browser (developper tools), you can see the `humans`collection with models:

    Humans {model: function, url: "/humans", models: Array[0], add: function, size: function…}
      model: function Human(fields) {}
      url: "/humans"
      models: Array[3]
        0: Human
          fields: Object
            _id: "IHNGU1BY7Vv14ORk"
            firstName: "John"
            lastName: "Doe"
        1: Human
          fields: Object
            _id: "WQpdowe3EAEbReuV"
            firstName: "Jane"
            lastName: "Doe"
        2: Human
          fields: Object
            _id: "hFPDywuRsPdJM7Fa"
            firstName: "Bob"
            lastName: "Morane"


##Display all Humans!

We'll temporarily display the humans. And in a later tutorial we will create "ViewModels".

This time, we're going to use the **"Observer Patern"** with our collection and a "View" object. The collection is a **"subject"** (observable subject) and the view is an **"observer"**.

We'll add an `observers` property (an array of observers) ans two methods:

- `addObserver` (add an observer to observers)
- `notifyObservers` (send message to all observers)

and we'll update `fetch` method to notify all observers when data are all fetched:

{% highlight javascript %}
class Collection {
  constructor (model, url, models) {
    this.model = model;
    this.url = url !== undefined ? url : "";
    this.models = models !== undefined ? models : [];

    this.observers = [];

  }

  addObserver (observer) {
    this.observers.push(observer);
  }

  notifyObservers (context) {
    this.observers.forEach((observer) => {
      observer.update(context)
    })
  }

  add (model) {
    this.models.push(model);
    return this;
  }

  size () { return this.models.length; }

  fetch () {
    return $.ajax({url: this.url, type: "GET", data: this.fields, success: (models) => {
      models.forEach((fields) => {
        this.add(new this.model(fields));
      })
      this.notifyObservers("fetch");
    }})
  }

}

export default Collection;
{% endhighlight %}

###The View

Now, we can create a new view class `HumansView` which is an observer and which will subscribe to humans collection notifications. Create a file `humansView.js` in `public/js/app/views`:

{% highlight javascript %}
class HumansView { // this is an observer

  constructor (humansCollection) {
    humansCollection.addObserver(this);
    this.collection = humansCollection;
    this.list = $("humansList");
  }

  render () {
    this.list.html(this.collection.models.reduce((previous, current) => {
      return previous +
        `<li><h3>
          ${current.id()} :
          ${current.get("firstName")}
          ${current.get("lastName")}
        </h3></li>`;
    }, "<ul>") + "</ul>");
  }

  update (context) {
    console.log(context);
    this.render();
  }
}

export default HumansView;
{% endhighlight %}

Update `index.html`:

- remove `<ul></ul>` tag
- add `<humansList></humansList>` tag to `<body>`

Update `public/js/app/main.js` like that:

{% highlight javascript %}

import Human from './models/human';
import Humans from './models/humans';
import HumansView from './views/humansView';

class Application {

  constructor () {
    $("h1").html("E6 rocks!")

    var humans = new Humans();

    var humansView = new HumansView(humans);

    humans.fetch().done(()=>{ /* get all humans from database */

      if(humans.size()==0) { /* no human in database, then populate the collection */

        var bob = new Human({firstName:'Bob', lastName:'Morane'});
        var john = new Human({firstName:'John', lastName:'Doe'});
        var jane = new Human({firstName:'Jane', lastName:'Doe'});

        /* save models */
        bob.save().done(
          () => john.save().done(
            () => jane.save().done(
              ()=> humans.fetch().done(console.log(humans)) /* fetch again */
            )
          )
        );

      } else { /* display humans */
          console.log(humans);
      }
    })
  }
}

$(() => {
  new Application();
});
{% endhighlight %}

We've only:

- add reference to `HumansView` : `import HumansView from './views/humansView';`
- create instance of `HumansView` : `var humansView = new HumansView(humans);`

Now you can refresh [http://localhost:3000/](http://localhost:3000/) and you'll get a list of humans.

That's all! I think it is easier with ECMAScript 6. Next time, we'll see how to create better "ViewModels" object with **Handlebars**.

**You can find source codes here** : [https://github.com/js-experiments/es6-project](https://github.com/js-experiments/es6-project)


Have a nice weekend!
