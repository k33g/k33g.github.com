---

layout: post
title: BB plays with Play
info : How to connect Backbone Models to PlayFramework Models

---

#BackBone Models & Play!> Models jouent ensemble

##Objectifs :

Nous allons voir comment faire discuter des modèles Backbone avec des modèles Play!> (version 1) et persister les données client côté serveur. C'est simple, mais concentrez vous quand même.

##Prérequis :

- avoir installé Playframework : [http://www.playframework.org/](http://www.playframework.org/)
- Télécharger Backbone : [http://documentcloud.github.com/backbone/](http://documentcloud.github.com/backbone/)
- Télécharger Underscore : [http://documentcloud.github.com/underscore/](http://documentcloud.github.com/underscore/) (c'est une dépendance de Backbone.js)
- Télécharger la dernière version de jQuery (optionnel) : [http://jquery.com/](http://jquery.com/) (c'est aussi une dépendance de Backbone.js, mais cela fonctionnerait aussi avec Zepto)
- Utiliser un navigateur "à base" de Webkit (Chrome, Safari) ou Firefox : il faut une console digne de ce nom pour suivre ce tuto.

##Préparation :

Tout d'abord, il faut créer une application Play. Donc positionnez vous dans un répertoire et tapez la commande suivante :

	play new bookmarks

Cela va donc créer un répertoire `bookmarks`. 

Aller dans `public/javascripts` et copier dans le répertoire : 

- jquery.js
- underscore.js
- backbone.js

Ensuite, aller dans `app/views/main.html` et changer les includes javascript :

{% highlight html %}
	<script src="@{'/public/javascripts/jquery.js'}" type="text/javascript" charset="${_response_encoding}"></script>
	<script src="@{'/public/javascripts/underscore.js'}" type="text/javascript" charset="${_response_encoding}"></script>
	<script src="@{'/public/javascripts/backbone.js'}" type="text/javascript" charset="${_response_encoding}"></script>
{% endhighlight %}

C'est bon, vous êtes prêts. On commence.

##Création d'un modèle et d'une collection BackBone :

Aller dans `app/views/Application`, et modifier `index.html` :

{% highlight html %}
	#{extends 'main.html' /}
    #{set title:'Home' /}

    <script type="text/javascript">

        window.Bookmark = Backbone.Model.extend({
            url : 'bb/bookmark',
            defaults : {
                id: null,
                label : "",
                website : ""
            }
        });

        window.Bookmarks = Backbone.Collection.extend({
            model : Bookmark,
            url : 'bb/bookmarks'
        });

    </script>
{% endhighlight %}

Un modèle Backbone possède plusieurs méthodes. Nous allons nous concentrer sur celles-ci :

- `save()`
- `destroy()`
- `fetch()`

et en ce qui concerne la collection Backbone :

- `fetch()`

Lorsque ces méthodes sont appelées, c'est l'objet `Backbone.sync` qui est appelé/utilisé et se charge de faire des requêtes au serveur si la propriété `url` des modèles et collections est renseignée. Donc dans notre cas (et nous allons le vérifier plus loin), `Backbone.sync` enverra les requêtes de ce type au serveur :

- `POST` ou `PUT` pour `save()`
- `DELETE` pour `destroy()`
- `GET` pour `fetch()`


