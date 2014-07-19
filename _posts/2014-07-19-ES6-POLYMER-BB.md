---

layout: post
title: ECMAScript 6 + BackBone + Polymer
info : ECMAScript 6 + BackBone + Polymer

---

#ECMAScript 6 + BackBone + Polymer

Last time we've used **Handlebars** ([http://k33g.github.io/2014/07/15/ES6-IN-ACTION-WITH-VIEWS.html](http://k33g.github.io/2014/07/15/ES6-IN-ACTION-WITH-VIEWS.html)), but my favorite framework is **Backbone** because of the models and collections. But I hate the system of views and templating and I'm jealous of **Angular** or even **Knockout**. But fortunately, **Polymer** exists!.

##First refactoring our Models and Collections

Always in the same project:

###Update `bower.json`

We need Backbone and Polymer:

{% highlight javascript %}
{
  "name": "es6-project",
  "version": "0.0.0",
  "dependencies": {
    "uikit": "~2.8.0",
    "jquery": "~2.1.1",
    "traceur": "~0.0.49",
    "polymer": "Polymer/polymer#~0.3.3",
    "core-elements": "Polymer/core-elements#~0.3.3",
    "backbone": "~1.1.2"
  },
  "resolutions": {
    "jquery": "~2.1.1"
  }
}
{% endhighlight %}

And type `bower update` command.

Don't forget to reference *Polymer* (`platform.js`), **Underscore** and **Backbone** in your `index.html` file:

{% highlight html %}
<!-- 1. Load platform.js for polyfill support. -->
<script src="bower_components/platform/platform.js"></script>

<script src="bower_components/jquery/dist/jquery.min.js"></script>
<script src="bower_components/underscore/underscore.js"></script>
<script src="bower_components/backbone/backbone.js"></script>
<script src="bower_components/traceur/traceur.js"></script>
{% endhighlight %}

Then change a little bit the structure of our project.

###Change directory structure of the project

we no longer need:

- `core` directory (and `model.js` and `collection.js `)
- `humans-list.js` but keep `components/` directory

{% highlight text %}
es6-project/
├── node_modules/
├── public/   
|   ├── bower_components/  
|   ├── js/          
|   |   └── app/  
|   |        ├── models/
|   |        |   ├── human.js    
|   |        |   └── humans.js  
|   |        ├── components/    
|   |        |   └── ...    
|   |        └── main.js
|   └── index.html
├── .bowerrc
├── bower.json
├── package.json    
└── app.js
{% endhighlight %}

###Modify `human.js`

Modify your code like this:

**Note 1:** We can write `class Human extends Backbone.Model` because object model of **Backbone** is fully compliant with **ECMAScript 6**.

{% highlight javascript %}
class Human extends Backbone.Model {

  constructor (args) {
    super(args) /* mandatory */

    //Getters and Setters : properties
    
    Object.defineProperty(this, "firstName", {
      get: function (){ return this.get("firstName")} ,
      set: function (value) { this.set("firstName",value); }
    });

    Object.defineProperty(this, "lastName", {
      get: function (){ return this.get("lastName")} ,
      set: function (value) { this.set("lastName",value); }
    });

  }
}

export default Human;
{% endhighlight %}

**Note 2:** `Object.defineProperty(this, "firstName", {/* foo */})` allows to define property `firstName`, so now I can write `bob.firstName` instead of `bob.get("firstName")` or `bob.firstName = "Bob"` instead of `bob.set("firstName", "Bob")` (*and it will be useful with Polymer templates*).


###Modify `humans.js`

Modify your code like this:

{% highlight javascript %}
import Human from './human';

class Humans extends Backbone.Collection {

  constructor (args) {
    this.model = Human;
    this.url = "/humans";
    super(args) /* mandatory */
  }
}

export default Humans;
{% endhighlight %}

##Create our Polymer component

Create two new files in `components/` directory : `humans-list.html` and `humans-list.js`

    es6-project/
    ├── node_modules/
    ├── public/   
    |   ├── bower_components/  
    |   ├── js/          
    |   |   └── app/  
    |   |        ├── models/
    |   |        |   ├── human.js    
    |   |        |   └── humans.js  
    |   |        ├── components/    
    |   |        |   ├── humans-list.html    
    |   |        |   └── humans-list.js     
    |   |        └── main.js
    |   └── index.html
    ├── .bowerrc
    ├── bower.json
    ├── package.json    
    └── app.js

###Content of `humans-list.html`

Define a Polymer component is very easy:

{% highlight html %}
<link rel="import" href="../../../bower_components/polymer/polymer.html">

<polymer-element name="humans-list">
  <template>
    <ul>
      <template repeat="{% raw %}{{humans}}{% endraw %}">
        <li>{% raw %}{{firstName}}{% endraw %} {% raw %}{{lastName}}{% endraw %}</li>
      </template>
    </ul>
  </template>

  <script>
    /* Load ES6 script */
    System.import('../../js/app/components/humans-list');

    /* ok this part is weird, there is probably something to do about the path*/
  </script>

</polymer-element>
{% endhighlight %}

###Content of `humans-list.js`

I've decided to externalize the JavaScript code of the component because I want to write it with **ECMAScript 6** grammar:

{% highlight javascript %}
import Human from '../models/human';
import Humans from '../models/humans';

Polymer("humans-list",{
  ready: function () {

    this.humansCollection = new Humans();

    // subscribe to fetch event
    this.humansCollection.on({"fetch":this.update()});

    this.humansCollection.fetch().done(()=>{ /* get all humans from database */

      if(this.humansCollection.size()==0) { /* no human in database, then populate the collection */

        var bob = new Human({firstName:'Bob', lastName:'Morane'});
        var john = new Human({firstName:'John', lastName:'Doe'});
        var jane = new Human({firstName:'Jane', lastName:'Doe'});

        /* save models */
        bob.save().done(
          () => john.save().done(
            () => jane.save().done(
              ()=> this.humansCollection.fetch().done( /* fetch again */
                console.log("humans created:", this.humansCollection)
              )
            )
          )
        );

      } else { /* display humans */
        console.log("humans loaded:", this.humansCollection);
      }
    })
  },

  update: function() { // called when collection is "fetched"
    this.humans = this.humansCollection.models;
  }
});

{% endhighlight %}

###Reference the component

You've just to add this in `index.html`:

{% highlight html %}
<link rel="import" href="js/app/components/humans-list.html">
{% endhighlight %}

**And ... You've just to refresh your page** (*Dont' forget to run `node app.js`*).

The more I work with **ES6**, the more I love it.

Next time, I'll explain my workflow to "transpile" offline my project with **Traceur** and **Gulp**. 

Have a nice day.

