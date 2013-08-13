---

layout: post
title: Think Simple
info : Think Simple

---

#Think Simple, Yeoman, Bower, i <3 you but sometimes you're too heavy!

*(sorry for my english ;))*

Last week, I had to prepare a draft web application for a demonstration. I decided to play with Yeoman and Backbone Generator. After the `yo backbone` command, i'd get a big project of almost **150 MB**. ... I do not need all this. So, i'd try withn only Bower : **25 MB** ... I do not need all this.

So I decided to make lighter, i've created an other (again!) Backbone Boilerplate "manually" and i use the beautifully simple **Pulldown** [https://github.com/jackfranklin/pulldown](https://github.com/jackfranklin/pulldown) to load and update my javascript libraries.

I've called it **M33** and you can find it here : **[https://github.com/k33g/m33](https://github.com/k33g/m33)**. And it's very easy to use.

##How to use M33 ?

###First you have to install it ... And it's simple

Type `git clone --q --depth 0 git@github.com:k33g/m33.git killerapp` where `killerapp` is the directory name of your web application (the directory is created).

Then you've just get the skeleton of your webapp :

![](https://raw.github.com/k33g/k33g.github.com/master/images/m33-01.jpg)

###M33 structure

####index.html

Bootstrap css file an Requirejs are declared in the header :

{% highlight html %}
<link href="bootstrap3/css/bootstrap.css" rel="stylesheet" type="text/css">
<script data-main="js/main" src="js/vendors/require.min.js"></script>
{% endhighlight %}

`data-main="js/main"` explains that `main.js` is the main javascript file to load (with the configuration)

####main.js

In `main.js`, we declare the vendors javascript libraries and call the `initialize` method of `application` module :

{% highlight javascript %}
requirejs.config({
    baseUrl : "js/",
    paths   : {
        "jquery"        : "vendors/jquery.min",
        "underscore"    : "vendors/underscore-min", /*This is amd version of underscore */
        "backbone"      : "vendors/backbone-min",   /*This is amd version of backbone   */
        "text"          : "vendors/text",
        "bootstrap"     : "../bootstrap3/js/bootstrap.min"
    }
});

require(['application'], function (application) {
    application.initialize();
});
{% endhighlight %}

We explain that `application` module is in the `application.js` file : `require(['application']` and declare it as `application` with the parameter function : `function (application) {`.

####application.js

The `initialize` method of `application` module allows us to define dependencies : `define(['jquery', ...`, load the `Router.js` module : `'routers/Router'` and the `ApplicationView.js` module : `'views/ApplicationView'`. And we instanciate the `Router` and the `ApplicationView`(as parameter of the router).

{% highlight javascript %}
define([
    'jquery',
    'underscore',
    'backbone',
    'routers/Router',
    'views/ApplicationView'
], function ($, _, Backbone, Router, ApplicationView) {

    return {
        initialize: function () {

            var router = new Router({
                applicationView : new ApplicationView()
            });

            router.on('route:defaultAction', function (actions) {
                // We have no matching route, lets refresh something ...
                this.applicationView.render();
            });

            Backbone.history.start();
        }
    };
});
{% endhighlight %}

####views/ApplicationView.js

`ApplicationView` is a kind of pattern that allow to manage views, models and collections.

{% highlight javascript %}
define([
    'jquery',
    'underscore',
    'backbone',
    'bootstrap'
], function($, _, Backbone, bootstrap)
{

    var ApplicationView = Backbone.View.extend({
        initialize : function() { //initialize models, collections and views ...

        }
    });

    return ApplicationView;
});
{% endhighlight %}

####routers/Router.js

`Router.js` aims to check if there is an applicationView, and to define the "routes" and there actions.

{% highlight javascript %}
define([
    'jquery',
    'underscore',
    'backbone'
], function($, _, Backbone){

    var MainRouter = Backbone.Router.extend({
        initialize : function(args){
            this.applicationView = args.applicationView
            if (!this.applicationView) throw 'Requires an applicationView instance'
        },
        routes : {
            // Define some URL routes

            // Default
            '*actions': 'defaultAction'
        }
    });

    return MainRouter
});
{% endhighlight %}

Now let's code!

###A very quick little sample

We just want display a persons list.

####Data

Create a `humans.data.js` file at the root of your webapp directory, with some records :

{% highlight javascript %}
[{"id":"001", "firstName":"Bob", "lastName":"Morane"},{"id":"002", "firstName":"John", "lastName":"Doe"},{"id":"003", "firstName":"Jane", "lastName":"Doe"}]
{% endhighlight %}

####Models and Collections : Human and Humans

Create `Human.js` (model) and `Humans.js` (collection) in the `js/models` directory :

*Model : Human.js*

{% highlight javascript %}
define([
    'backbone'
], function(Backbone){

    var Human = Backbone.Model.extend({
        defaults : {
            firstName : "John",
            lastName : "Doe"
        }
    });

    return Human;

});
{% endhighlight %}

*Collection : Humans.js*

{% highlight javascript %}
define([
    'backbone',
    'models/Human'
], function(Backbone, Human){

    var Humans = Backbone.Collection.extend({
        model : Human,
        url : "/humans.data.js"
    });

    return Humans
});
{% endhighlight %}

You can note :

- `url : "/humans.data.js"` allows load data when we'll fetch the collection
- `'models/Human'` allows to declare the Humn model in the collection

Now we want to create the view to display the humans.

####Views, templates etc. ...

First, go to edit the `index.html` file, we want indicate where data will be displayed, inside the tag `<div class="human-view"></div>`: 

{% highlight html %}
<body>
    <div class="jumbotron">
        <h1>M33</h1>
        <p>Minimalistic Backbone BoilerPlate (with RequireJS)</p>
        <a class="label label-info" href="https://github.com/k33g/m33"> github.com/k33g/m33</a>
        <span class="label label-warning this-is-a-message">Hello world! :)</span>
    </div>
    <div class="container">
        <div class="row">
        	<!-- humans will be displayed here -->
            <div class="human-view"></div> 
        </div>
    </div>
</body>
</html>
{% endhighlight %}

*Remark: `class="human-view"` will allow to identify the `<div>` tag*

Now, we can create the template `humans.tpl.html` in the `js/templates` : *(i'm using undrescore templating)*

{% highlight html %}
<h3>Humans</h3>
<ul><% _.each(humans, function(human){ %>
    <li>
        <%= human.id %> : <%= human.firstName %> <%= human.lastName %>
    </li>
<%});%></ul>
{% endhighlight %}

And finally, we are going to create the `Backbone.View`. Create `HumansView.js` in the `js/views` directory :

{% highlight javascript %}
define([
    'jquery',
    'underscore',
    'backbone',
    'text!templates/humans.tpl.html'
], function($, _, Backbone, humansTpl){

    var HumansView = Backbone.View.extend({
        el  : $(".human-view"),
        initialize : function () {
            this.template = _.template(humansTpl);
            this.listenTo(this.collection, "sync", this.render)
        },
        render : function () {
            var renderedContent = this.template({ humans : this.collection.toJSON() });
            this.$el.html(renderedContent);
            this.trigger("humansAreRendered")
            return this;
        }
    });

    return HumansView;
});
{% endhighlight %}

**be careful:**

- `'text!templates/humans.tpl.html'` loads the template, and we can access it through the `humansTpl` variable
- `el  : $(".human-view")` allows to the view to "find" this : `<div class="human-view"></div> ` in `index.html`
- `this.listenTo(this.collection, "sync", this.render)` : the view listen to sync events (http request) of the collection, so, when we'll call the `fetch` (the `sync` event is fired) method of the collection, the `render` method of the view will be called.
- `this.trigger("humansAreRendered")` the view trigger a custom event when she has rendered the collection.

####Load data, instanciate the view, display humans

We are going to instanciate `HumansView` and `Humans` collection in the `initialize` method of `ApplicationView`.

In the first place, we have to declare the collection : `'models/Humans'`and the view : `'views/HumansView'`. Don't forget to add function parameters `Humans, HumansView` :

{% highlight javascript %}
define([
    'jquery',
    'underscore',
    'backbone',
    'bootstrap',
    'models/Humans',
    'views/HumansView'
], function($, _, Backbone, bootstrap, Humans, HumansView)
{
    var ApplicationView = Backbone.View.extend({
        initialize : function() { //initialize models, collections and views ...

            this.humans = new Humans();
            this.humansView = new HumansView({ collection : this.humans });
            this.listenTo(this.humansView, "humansAreRendered", this.sendMessage)
            this.humans.fetch();
        },
        sendMessage : function() {
            $(".this-is-a-message").html("Humans are loaded, so, all is OK, have fun!");
        }
    });

    return ApplicationView;
});
{% endhighlight %}

**be careful:**

- `this.humans = new Humans();` : we create a new collection
- `this.humansView = new HumansView({ collection : this.humans });` : we create a new view and set the collection property view whit `this.humans`.
- `this.listenTo(this.humansView, "humansAreRendered", this.sendMessage)`: the `ApplicationView` listen to the custom event `humansAreRendered` of the `humansView` and call `sendMessage` method when the event is fired.
- the `sendMessage` method display a message in the html page.

And, that'all!.

##How to test the webapp?

If you're working with OSX or Linux, you can (inside the webapp directory) run `python -m SimpleHTTPServer 8080` and then open [http://localhost:8080](http://localhost:8080).

Otherwise you can also install **http-server** : `npm install http-server -g`, then, run `http-server -p 8080`and, open [http://localhost:8080](http://localhost:8080).

##How to update vendors libraries of your webapp

It's easy, just run `./loadjs.sh` (OSX or Linux) or `loadjs.cmd` in the webapp directory. The script only call **pulldown** to load libraries.

Et voilà!

