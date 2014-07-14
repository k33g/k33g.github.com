---

layout: post
title: ECMAScript 6 in action with the view
info : ECMAScript 6 in action with the view

---

#ECMAScript 6 in action with the view

Last time ([ECMAScript 6 in action with the inheritance and the models](http://k33g.github.io/2014/07/05/ES6-IN-ACTION-WITH-MODELS.html)) we've created an "humansView" quickly. Today we're going to use **Handlebars** to make something more "à la Backbone". **Handlebars** is a javascript templating library.

##Modify bower.json

{% highlight javascript %}
{
  "name": "es6-project",
  "version": "0.0.0",
  "dependencies": {
    "uikit": "~2.8.0",
    "jquery": "~2.1.1",
    "handlebars": "~1.3.0",
    "traceur": "~0.0.49"
  },
  "resolutions": {
    "jquery": "~2.1.1"
  }
}
{% endhighlight %}

We've had `"handlebars": "~1.3.0"` (handlebars dependency). Now, type this command: `bower update`.

##Update collection.js

We need to add a `toJson()` method to the collection, then we can pass simple json object to handlebars templates:

{% highlight javascript %}
toJson () {
  return this.models.map((model) => model.fields);
}
{% endhighlight %}

##Create a component ViewModel: `HumansList`

You can delete `js/app/views/humansView.js`, create a new directory: `components` in `js/app/views` with a new javascript file `humans-list.js`:

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
    |   |        ├── components/    
    |   |        |   └── humans-list.js      
    |   |        └── main.js
    |   └── index.html
    ├── .bowerrc
    ├── bower.json
    ├── package.json    
    └── app.js

with this content:

{% highlight javascript %}
class HumansList {

  view ()  { return `
    <ul>
      {% raw %}{{#each humans}}{% endraw %}
      <li>{% raw %}{{id}}{% endraw %} {% raw %}{{firstName}}{% endraw %} {% raw %}{{lastName}}{% endraw %}</li>
      {% raw %}{{/each}}{% endraw %}
    </ul>
  `;}

  constructor (humansCollection) {
    humansCollection.addObserver(this);
    this.humans = humansCollection;
    this.template = Handlebars.compile(this.view());
    this.el = document.querySelector("humans-list");
  }

  render () {
    this.el.innerHTML = this.template({humans: this.humans.toJson()});
  }

  update (context) {
    this.render();
  }
}

export default HumansList;
{% endhighlight %}

##Update main.js

{% highlight javascript %}
import Human from './models/human';
import Humans from './models/humans';
import HumansList from './components/humans-list';

class Application {

  constructor () {
    $("h1").html("E6 rocks!")

    var humans = new Humans();

    var list = new HumansList(humans)

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

We've changed:

- `import HumansList from './components/humans-list';`
- and `var list = new HumansList(humans)`

##Last update

Modify `index.html`, you have just to add handlebars reference: `<script src="bower_components/handlebars/handlebars.min.js"></script>`:

{% highlight html %}
<!DOCTYPE html>
<html>
<head lang="en">
  <meta charset="UTF-8">
  <title>es6-project</title>
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
  <link rel="icon" sizes="196x196" href="html5.png">
  <meta name="mobile-web-app-capable" content="yes">
  <link rel="stylesheet" href="bower_components/uikit/dist/css/uikit.almost-flat.min.css" />
</head>

<body style="padding: 20px">
  <h1></h1>
  <humans-list></humans-list>

  <script src="bower_components/jquery/dist/jquery.min.js"></script>
  <script src="bower_components/handlebars/handlebars.min.js"></script>
  <script src="bower_components/traceur/traceur.js"></script>

  <script>
    System.import('js/app/main');
  </script>
</body>
</html>
{% endhighlight %}

Now you can refresh [http://localhost:3000/](http://localhost:3000/) and you'll get a list of humans (again).

Next time we'll use Polymer instead of our "from scratch" viewmodel component.

**You can find source codes here** : [https://github.com/js-experiments/es6-project](https://github.com/js-experiments/es6-project)

Have a nice day!
