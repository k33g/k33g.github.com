---

layout: post
title: React Backbone Browserify
info : React Backbone Browserify

---

#React - Backbone - Browserify : Que du bonheur!

J'ai eu beau essayer d'autres frameworks (Angular, Polymer, Ember ...), j'en reviens toujours à Backbone : son modèle objet, ses modèles et collections, associés à de la légèreté et de la simplicité, je n'arrive pas à m'en passer. Par contre, je trouve lourds les "Backbone Views" et les templates (Mustache et les autres), et probablement encore plus lourd, le système de gestion de dépendances et de module RequireJS.

##Remplacer Backbone.View

Il y a peu j'ai découvert [React](http://facebook.github.io/react/) qui permet de se substituer aux "Views" Backbone d'une façon tout à fait "concurrentielle". J'y gagne en visibilité (facilité de développement et de maintenance) et en puissance (plus rapide, plus léger). (cf. mon post ["React : La Révolution des Views (?) (côté front)"](http://k33g.github.io/2014/01/30/V.html) pour une initiation rapide).

##Remplacer RequireJS

J'ai mis un moment à l'accepter, mais pour développer de "grosses" application javascript (surtout si l'on bosse en équipe), un gestionnaire de modules et de dépendances est **OBLIGATOIRE**!.
Mais être obligé de déclarer l'ensemble des dépendances dans un fichier (avec le risque dans oublier si on ajoute une librairie), la notation utilisée dans chacun des modules (avec le risque d'oublier une dépendance là aussi), ... tout ça me "pompe l'air"!
J'aime bien me simplifier la vie, et j'ai fini par tester quelque chose que j'avais mis de côté depuis un moment : [Browserify](http://browserify.org/). Pour faire court, cela permet d'avoir un système de gestion de module côté front identique à celui de **Nodejs** et donc d'utiliser **npm** pour télécharger vos librairies javascript préférées. Par exemple pour "récupérer" Backbone, préférez un `npm install backbone` à un `bower install backbone`. Ensuite, lorsque vous aurez besoin de Backbone dans un module, il suffira d'écrire `var Backbone = require("backbone");` dans votre fichier javascript. Vous n'aurez pas de tag `<script></script>` à ajouter dans votre page html, puisque la commande `browserify something.js -o bundle.js` permettra de créer un fichier javascript unique avec toutes les dépendances "mergée".

##Oui, et comment fait-on?

Le but de cet article n'est pas de vous expliquer de A à Z comment construire l'ensemble de la stack et des éléments nécessaires pour faire une 1ère application, mais de vous permettre de découvrir simplement et facilement comment tout ceci fonctionne. Pour ce faire j'ai créé un générateur pour **[Yeoman](http://yeoman.io/)** *(1)* qui va vous permettre facilement (et automatiquement) de créer un projet avec toutes les dépendances nécessaires pour commencer à jouer avec :

- React
- Backbone
- Browserify
- Bootstrap
- et accessoirement Express, Mongoose (et donc MongoDb que vousdevrez installer)

Ce générateur s'appelle **generator-react-app**, vous pouvez le trouver ici : [https://www.npmjs.org/package/generator-react-app](https://www.npmjs.org/package/generator-react-app), il est "accompagné" de quelque "subs-generators" permettant de générer des bouts de code automatiquement (ie: des modèles, des composants backbones, ...), mais aussi de quelques mécaniques Grunt (grunt-react, grunt-browserify, grunt-watch) permettant de transformer automatiquement vos composants React en javascript mais aussi de générer le "bundle browserifiy javascript final".

Tout ceci peut paraître un peu abstrait, donc passons directement à la pratique.

##Installer generator-react-app

*Bien sûr vous avez besoin de Yeoman (et donc node et npm).*

Dans un terminal, tapez `sudo npm install -g generator-react-app`

##Créer le squelette de votre projet

- créez un répertoire : `mkdir humans-demo`
- "allez" dans le répertoire : `cd humans-demo`
- lancez "mon killer generator" *(2)* : `yo react-app` et donnez un nom à votre application et à votre base de données :

     _____             _       _____
    | __  |___ ___ ___| |_ ___|  _  |___ ___
    |    -| -_| .'|  _|  _|___|     | . | . |
    |__|__|___|__,|___|_|     |__|__|  _|  _|
                                    |_| |_|
    Hi! This is a React-Express-Mongoose Generator :) Enjoy!
    [?] Application name? HumansDemo
    [?] DataBase name? DemoDb

- ... attendez : le générateur va créer la structure de votre projet et télécharger via **npm** et **bower** toutes les dépendances nécessaires à votre projet.

##Lancez votre application (pour voir)

Vous devez maintenant avoir l'arborescence suivante :

![Alt "000.png"](https://github.com/k33g/k33g.github.com/raw/master/images/react-000.png)

- lancez MongoDb : dans un terminal tapez `mongod`
- lancez votre application : `node app.js` (un conseil installez **nodemon** [https://github.com/remy/nodemon](https://github.com/remy/nodemon) cela permet d'écouter les changements des fichiers et de re-démarrer node à chaque changement)
- lancez `grunt browserify` (cela va créer un fichier `public/js/app.built.js`)
- lancez `grunt-watch` pour que Grunt écoute les changements
- allez à [http://localhost:3000](http://localhost:3000)
 
Si tout va bien vous devriez obtenir ceci :

![Alt "001.png"](https://github.com/k33g/k33g.github.com/raw/master/images/react-001.png)

*Si tout va mal, "pinguez" moi ...*

##Créez des services CRUD pour Express (côté back)

Dans un terminal, tapez : `yo react-app:mgroutes Human` et répondez aux questions :

    [?] mongoose schema (ie: name: String, remark: String)? firstName: String, lastName: String
    [?] url? humans
       create models/Human.js
       create routes/Humans.routes.js
       create controllers/HumansCtrl.js

Nous venons de renseigner le schema Mongoose : `firstName: String, lastName: String`, l'url (gardez la valeur par défaut) de base des routes sera `/humans` et 3 fichiers ont été créés **automatiquement** :

###models/Human.js

{% highlight javascript %}
var mongoose = require('mongoose');

var HumanModel = function() {

  var HumanSchema = mongoose.Schema({
    firstName: String, lastName: String
  });

  return mongoose.model('Human', HumanSchema);
}

module.exports = HumanModel;
{% endhighlight %}

###controllers/HumansCtrl.js

{% highlight javascript %}
var Human = require("../models/Human")();

var HumansCtrl = {
  create : function(req, res) {
    var human = new Human(req.body)
      human.save(function (err, human) {
      res.send(human);
    });
  },
  fetchAll : function(req, res) {
    Human.find(function (err, humans) {
      res.send(humans);
    });
  },
  fetch : function(req, res) {
    Human.find({_id:req.params.id}, function (err, humans) {
      res.send(humans[0]);
    });
  },
  update : function(req, res) {
    delete req.body._id
    Human.update({_id:req.params.id}, req.body, function (err, human) {
      res.send(human);
    });
  },
  delete : function(req, res) {
    Human.findOneAndRemove({_id:req.params.id}, function (err, human) {
      res.send(human);
    });
  }
}

module.exports = HumansCtrl;
{% endhighlight %}

###routes/Humans.routes.js

{% highlight javascript %}
var HumansCtrl = require("../controllers/HumansCtrl");

var HumansRoutes = function(app) {

  app.post("/humans", function(req, res) {
    HumansCtrl.create(req, res);
  });

  app.get("/humans", function(req, res) {
    HumansCtrl.fetchAll(req, res);
  });

  app.get("/humans/:id", function(req, res) { //try findById
    HumansCtrl.fetch(req, res);
  });

  app.put("/humans/:id", function(req, res) {
    HumansCtrl.update(req, res);
  });

  app.delete("/humans/:id", function(req, res) {
    HumansCtrl.delete(req, res);
  });

}

module.exports = HumansRoutes;
{% endhighlight %}

Je vous ai déjà fait gagner beaucoup de temps non ? ;)

##Créez les modèles et collections Backbone (côté front)

Dans un terminal, tapez : `yo react-app:bbmc Human` et répondez aux questions : (gardez les valeurs par défaut quand elles sont proposées)

    [?] model name (ie: Book) Human
    [?] defaults (ie: name: 'John Doe', remark: 'N/A')? firstName: "John", lastName: "Doe"
    [?] url? humans
       create public/js/modules/models/HumanModel.js
       create public/js/modules/models/HumansCollection.js

Nous avons donc obtenu toujours automatiquement un modèle et une collection.

###public/js/modules/models/HumanModel.js

{% highlight javascript %}
var Backbone = require("backbone");

var HumanModel = Backbone.Model.extend({
  defaults : function (){
    return {
      firstName: "John", lastName: "Doe"
    }
  },
  urlRoot : "humans",
  idAttribute: "_id"
});

module.exports = HumanModel;
{% endhighlight %}

###public/js/modules/models/HumansCollection.js

{% highlight javascript %}
var Backbone = require("backbone");
var HumanModel = require("./HumanModel");

var HumansCollection = Backbone.Collection.extend({
  url : "humans",
  model: HumanModel
});

module.exports = HumansCollection;
{% endhighlight %}

###Vous avez vu ?!

Nous sommes côté client, et nous déclarons les dépendances comme avec **Node** : `var HumanModel = require("./HumanModel");`, c'est tout de même plus simple qu'avec **Require**, c'est la magie de **Browserify**!

Il ne faut pas oublier d'exporter chacun des modules pour pouvoir les utiliser : `module.exports = HumanModel;` et `module.exports = HumansCollection;`.

##Passons à l'IHM avec React ou comment remplacer les "Views" Backbone

Nous voulons pouvoir saisir des informations et les afficher, nous allons donc créer un formulaire et une table.

Dans un terminal, tapez : `yo react-app:formbb HumanForm Human` et répondez aux questions : (gardez les valeurs par défaut quand elles sont proposées)

    [?] model name (ie: Book) Human
    [?] fields (for UI) (ie : title, author)? firstName, lastName
    [?] url? humans
       create public/js/react_components/HumanForm.js

Ensuite, `yo react-app:tablebb HumansTable Human`

    [?] model name (ie: Book) Human
    [?] fields (for UI) (ie : title, author)? firstName, lastName
    [?] url? humans
       create public/js/react_components/HumansTable.js

Nous avons donc maintenant 2 composants **React** (toujours automatiquement)

###public/js/react_components/HumanForm.js

{% highlight javascript %}
/** @jsx React.DOM */

var React = require('react')
  , HumanModel = require("../modules/models/HumanModel");

var HumanForm = React.createClass({

  getInitialState: function() {
    return {data : [], message : ""};
  },

  render: function() {
    return (
      <form role="form" className="form-horizontal" onSubmit={% raw %}{this.handleSubmit}{% endraw %}>
        <div className="form-group">
            <input className="form-control" type="text" placeholder="firstName" ref="firstName"/>
        </div>
        <div className="form-group">
            <input className="form-control" type="text" placeholder="lastName" ref="lastName"/>
        </div>
        
        <div className="form-group">
          <input className="btn btn-primary" type="submit" value="Add Human" />
        </div>
        <div className="form-group"><strong>{% raw %}{this.state.message}{% endraw %}</strong></div>
      </form>
    );
  },
  handleSubmit : function() {
    var firstName = this.refs.firstName.getDOMNode().value.trim();
    var lastName = this.refs.lastName.getDOMNode().value.trim();
    
    if (!firstName) {return false;}
    if (!lastName) {return false;}
    
    var data = {};
    data.firstName = firstName;
    data.lastName = lastName;
    

    var human= new HumanModel(data);

    human.save()
      .done(function(data) {
        this.setState({
          message : human.get("_id") + " added!"
        });
        this.refs.firstName.getDOMNode().value = '';
        this.refs.lastName.getDOMNode().value = '';
        
        this.refs.firstName.getDOMNode().focus();
      }.bind(this))
      .fail(function(err) {
        this.setState({
          message  : err.responseText + " " + err.statusText
        });
      }.bind(this));

    return false;
  }

});

module.exports = HumanForm;
{% endhighlight %}

###public/js/react_components/HumansTable.js

{% highlight javascript %}
/** @jsx React.DOM */

var React = require('react')
  , Backbone = require("backbone")
  , HumanModel = require("../modules/models/HumanModel")
  , HumansCollection = require("../modules/models/HumansCollection");

var HumansTable = React.createClass({

  getInitialState: function() {
    return {data : [], message : ""};
  },

  render: function() {

    var humansRows = this.state.data.map(function(human){
      var deleteLink = "#delete_human/" + human._id;

      return (
        <tr>
          <td>{% raw %}{human.firstName}{% endraw %}</td>
          <td>{% raw %}{human.lastName}{% endraw %}</td>
          
          <td><a href={% raw %}{deleteLink}{% endraw %}>delete{% raw %}{" "}{% endraw %}{% raw %}{human._id}{% endraw %}</a></td>
        </tr>
      );
    });

    return (
      <div className="table-responsive">
        <strong>{% raw %}{this.state.message}{% endraw %}</strong>
        <table className="table table-striped table-bordered table-hover" >
          <thead>
            <tr>
              <th>firstName</th><th>lastName</th>
              <th>_id</th>
            </tr>
          </thead>
          <tbody>
            {% raw %}{humansRows}{% endraw %}
          </tbody>
        </table>
      </div>
    );
  },  

  getHumans : function() {

    var humans = new HumansCollection();

    humans.fetch()
      .done(function(data){
        this.setState({data : humans.toJSON(), message : Date()});
      }.bind(this))
      .fail(function(err){
        this.setState({
          message  : err.responseText + " " + err.statusText
        });
      }.bind(this))
  },
  
  componentWillMount: function() {
    this.getHumans();
    setInterval(this.getHumans, this.props.pollInterval);
  },

  componentDidMount: function() {
    var Router = Backbone.Router.extend({
      routes : {
        "delete_human/:id" : "human"
      },
      initialize : function() {
        console.log("Initialize router of HumansTable component");
      },
      human : function(id){
        console.log("=== delete human ===", id);
        new HumanModel({_id:id}).destroy();
        this.navigate('/');
      }
    });
    this.router = new Router()
  }

});

module.exports = HumansTable;
{% endhighlight %}

###Vous avez vu là aussi ... ?!

Nous déclarons là aussi les dépendances de la même manière que pour les modèles et collection Backbone :

{% highlight javascript %}
var React = require('react')
  , Backbone = require("backbone")
  , HumanModel = require("../modules/models/HumanModel")
  , HumansCollection = require("../modules/models/HumansCollection");
{% endhighlight %}

Et surtout ne pas oublier : `/** @jsx React.DOM */` pour que les composants soit bien transformés par **grunt-react**.

###One more thing!

Une dernière petite remarque, dans la méthode `componentDidMount` de mon composant React, j'ai pu créer un "Router" Backbone complètement associé au composant.

##Il ne nous reste plus qu'à afficher tout ça

###Modifiez public/js/modules/main.js`

Ouvrez le fichier `public/js/modules/main.js` et remplacez son contenu par :

{% highlight javascript %}
/** @jsx React.DOM */
var React   = require('react');
var Backbone = require("backbone");

var HumanForm = require('../react_components/HumanForm');
var HumansTable = require('../react_components/HumansTable');

Backbone.history.start();

React.renderComponent(
  <HumanForm/>,
  document.querySelector('HumanForm')
);

React.renderComponent(
  <HumansTable pollInterval={500}/>,
  document.querySelector('HumansTable')
);
{% endhighlight %}

###Modifiez public/index.html

Modifiez le contenu du fichier `index.html` de la manière suivante :

{% highlight html %}
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>HumansDemo</title>
  <meta name="description" content="react application">
  <meta name="author" content="John Doe">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <link rel="stylesheet" href="js/bower_components/bootstrap/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="js/bower_components/bootstrap/dist/css/bootstrap-theme.min.css">
</head>
<body>
  <div class="container">
    <h1>HumansDemo</h1>
  </div>
  <div class="container">
    <div class="row">
      <div class="col-md-6">
        <HumanForm/>
      </div>
      <div class="col-md-6">
        <HumansTable/>
      </div>
    </div>
  </div>

  <script src="js/app.built.js"></script>

</body>
</html>
{% endhighlight %}

**Vous pouvez remarquer** que l'on n'insère qu'un seul script `js/app.built.js` qui est construit et mis à jour au fur et à mesure que l'on travail grâce aux tâches Grunt.

Et vous pouvez rafraîchir la page de votre navigateur et jouez avec :

![Alt "002.png"](https://github.com/k33g/k33g.github.com/raw/master/images/react-002.png)

Je joue avec tout cela depuis quelques jours et je trouve que marier **React** et **Browserify** simplifie le code, et en prime je peux conserver ce que je préfère dans **Backbone** : les modèles et les collections.

A l'usage, je trouve que l'utilisation des tâches `grunt-react` et `grunt-browserify` lancées via `grunt-watch` me permet de détecter rapidement (et de manière assez explicite) certaine erreurs.

Si vous avez des idées d'améliorations (notamment pour la partie Grunt) ou d'ajouts, n'hésitez pas à contribuer à mon générateur : [https://github.com/k33g/generator-react-app](https://github.com/k33g/generator-react-app). (*PS: j'ai aussi en projet d'en faire une version pour PlayFramework dès que j'ai un peu de temps*).

Tous les retours sont bienvenus :)

*(1): je sais que j'avais dit que je trouvais Yeoman "pas très léger", mais une fois que l'on a fait son premier générateur, on s'aperçoit qu'il est diablement pratique.*
*(2) un peu d'autosatisfaction n'a jamais fait de mal.*


