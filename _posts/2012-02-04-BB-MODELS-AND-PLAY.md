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

