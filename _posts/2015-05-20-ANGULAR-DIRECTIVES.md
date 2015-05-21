---

layout: post
title: My small arrangements with Angular
info : My small arrangements with Angular
teaser: How to use Angular 1.x like Polymer (only with directives)
image: <img src="https://github.com/k33g/k33g.github.com/raw/master/images/angular_logo.png">

---

#My small arrangements with Angular

*Angular* (1.x) isn't my favorite tool. I love (and prefer) of Backbone, essentially because of Models and Collection, but I don't like Views, I prefer **web components** as Polymer or even better **Riot** (Riot is more about *custom tags* than *web components*, but functionally, it's almost the same thing).

However, I do not always have a choice. As I do not master Angular, I looked for a long time how to use only the Angular directives for making *custom tags*. I wanted:

- to use some kind of custom tags (with templating)
- to work with Backbone Models and Collections
- to forget Angular controllers, services, rootscope etc ...

##And this is the sample of my experiments

My requirements are very simple, I want to display the content of a Backbone collection thanks a tag `<humans></humans>` :

{% highlight html %}
<div>
    <humans></humans>
</div>

<script>
  var Human = Backbone.Model.extend();
  var Humans = Backbone.Collection.extend({
      model: Human
  });

  var humansCollection = new Humans([
      {id:"001", firstName:"Bob", lastName: "Morane"},
      {id:"002", firstName:"Jane", lastName: "Doe"},
      {id:"003", firstName:"John", lastName: "Doe"}
  ]);
</script>

{% endhighlight %}

So, I've created 2 directives:

###Human directive (human.js): display a model

{% highlight javascript %}
var humanTag = angular.module('human.directive', []);

humanTag.directive('human',function() {
  return {
    template: '<h2>firstName: {% raw %}{{human.get("firstName")}}{% endraw %} lastName: {% raw %}{{human.get("lastName")}}{% endraw %}</h1>',
    scope : {
      human: '=model'
    },
    link: function (scope, element, attributes) {
      scope.human.on("change", function() {
        scope.$apply()
      })
    }
  };
});
{% endhighlight %}

We have to bind a human model to the directive (`scope : {human: '=model'}`) and the display is updated when the model change.

###Humans directive (humans.js): display models of the collection

{% highlight javascript %}
var humansTag = angular.module('humans.directive', []);

humansTag.directive('humans',['humansCollection', function(humansCollection) {
  return {
    template: '<div ng-repeat="human in humans"><human model="human"></human></div>',
    scope : {},
    link: function (scope, element, attributes) {
      scope.humans = humansCollection.models

      humansCollection.on("add", function() {
        scope.$apply()
      });
    }
  };
}]);
{% endhighlight %}

The previous directive is nested in this directive (`<human model="human"></human>`) and we bind the model with each instance of the human directive when parsing the collection. The display is update when we add a model (or when a model change, but it's only the nested item that is updated).

###Updates of my html page

{% highlight html %}
<div ng-app="app">
    <humans></humans>
</div>

<script>
  // declaration of the two directives
  var app = angular.module("app", ['human.directive', 'humans.directive']);

  var Human = Backbone.Model.extend();
  var Humans = Backbone.Collection.extend({
      model: Human
  });

  var humansCollection = new Humans([
      {id:"001", firstName:"Bob", lastName: "Morane"},
      {id:"002", firstName:"Jane", lastName: "Doe"},
      {id:"003", firstName:"John", lastName: "Doe"}
  ]);

  // I add my collection as a value of app, then
  // the collection is "visible" for the humans directive
  app.value("humansCollection", humansCollection);

</script>
{% endhighlight %}

And that's all!






