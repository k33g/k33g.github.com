---

layout: post
title: BB plays with Play
info : How to connect Backbone Models to PlayFramework Models

---

#BackBone Models et Play Models jouent ensemble

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

##Un petit tour côté Play!>

Nous allons donc créer les méthodes qui répondrons aux requêtes de `Backbone.sync`.

Aller dans le fichier `conf/routes` et ajouter les routes suivantes :

    GET     /bb/bookmark		Application.getBookmark
    POST	/bb/bookmark 		Application.postBookmark
    PUT 	/bb/bookmark 		Application.putBookmark
    DELETE 	/bb/bookmark 		Application.deleteBookmark
    GET     /bb/bookmarks		Application.allBookmarks

Aller ensuite dans `controllers/Application.java` et ajouter les méthodes suivantes :

{% highlight java %}
	public class Application extends Controller {

	    public static void index() {
	        render();
	    }
	    /* GET */
	    public static void getBookmark(String model) {
	        System.out.println("getBookmark : "+model);
	    }

	    /* POST */
	    public static void postBookmark(String model) {
	        System.out.println("postBookmark : "+model);
	    }

	    /* PUT */
	    public static void putBookmark(String model) {
	       System.out.println("putBookmark : "+model);
	    }
	    /* DELETE */
	    public static void deleteBookmark(String model) {
	        System.out.println("deleteBookmark : "+model);
	    }

		/* GET */
	    public static void allBookmarks() {
	        System.out.println("allBookmarks");	
	    }

	}
{% endhighlight %}

##1er essai :

- Lancez l'application Bookmarks : `play run bookmarks`
- se connecter à l'application : [http://localhost:9000/](http://localhost:9000/)
- ouvrir la console du navigateur
- tapez les commandes suivantes : 

		b1 = new Bookmark({label:"K33g'sBlog",website:"www.k33g.org"});
	    b1.save(); //pas mis de callback pour le moment

**Console du navigateur :**

![Alt "bbplay001.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay001.png)

**Console du terminal (côté Play) :**

![Alt "bbplay002.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay002.png)

Et là c'est le drame !

on s'aperçoit que c'est la méthode postBookmark qui est appelée, mais par contre rien (`null` en fait) n'est retourné dans la console serveur. En fait Backbone n'envoie pas ce que l'on souhaite à la méthode Play!>.

Même pas mal !. Nous allons donc re-écrire/surcharger `Backbone.sync`. ... Et on va faire simple.

##Surcharge de Backbone.sync :

Dans public/javascripts, créer un nouveau fichier : `backbone.sync.js` :

{% highlight javascript %}
	(function() {
	    Backbone.sync = function(method, model, options) {

	        // sympa pour comprendre ce qu'il se passe 
	        console.log(method, model, options);

	        var methodMap = {
	            'create': 'POST',
	            'update': 'PUT',
	            'delete': 'DELETE',
	            'read':   'GET'
	        }, dataForServer = null;

	        if(model.models) {//c'est une collection
	            dataForTheServer:null
	        } else {//c'est un modèle
	            dataForServer = { model : JSON.stringify(model.toJSON()) };
	        }

	        return $.ajax({ 
	            type: methodMap[method],
	            url: model.url,
	            data: dataForServer,
	            dataType: 'json',
	            error: function (dataFromServer) { //vérifier que cela retourne une erreur
	                options.error(dataFromServer);
	            },
	            success: function (dataFromServer) {
	                options.success(dataFromServer);
	            }
	        });
	    };
	})();
{% endhighlight %}

Ensuite, aller dans `app/views/main.html` et inclure le nouveau fichier js à la suite des autres :

	<script src="@{'/public/javascripts/backbone.sync.js'}" type="text/javascript" charset="${_response_encoding}"></sc

##Prêts pour un 2ème essai ? "Playing with BB Models"

Rechargez tout d'abord la page de votre navigateur pour prendre les modifications en compte. Puis passez aux étapes suivantes ci-dessous :

###save()

Dans la console du navigateur tapez les commandes suivantes :

    b1 = new Bookmark({label:"K33g'sBlog",website:"www.k33g.org"});
    b1.save();

Dans la console Play!>, on obtient :

    postBookmark : {"id":null,"label":"K33g'sBlog","website":"www.k33g.org"}

Donc lorsque l'on sauvegarde un modèle BB c'est une requête `POST` qui est envoyée et la méthode `postBookmark` qui est appelée.

**Console du navigateur :**

![Alt "bbplay003.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay003.png)

*Au passage on peut voir dans la console que la méthode est de type `create`*

**Console du terminal (côté Play) :**

![Alt "bbplay004.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay004.png)

###save() again

Dans la console du navigateur tapez les commandes suivantes : 

    b1.set({id:1});
    b1.save();

Dans la console Play!>, on obtient :

    putBookmark : {"id":1,"label":"K33g'sBlog","website":"www.k33g.org"}

Donc lorsque l'on sauvegarde un modèle BB c'est une requête `PUT` qui est envoyée et la méthode `putBookmark` qui est appelée.
On a affecté un `id` au modèle, donc BB "estime" que le modèle existe, et donc que c'est une mise à jour.

**Console du navigateur :**

![Alt "bbplay005.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay005.png)

*Au passage on peut voir dans la console que la méthode est de type `update`*

**Console du terminal (côté Play) :**

![Alt "bbplay006.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay006.png)

###destroy()

Dans la console du navigateur tapez les commandes suivantes : 

    b1.destroy(); // b1.id = 1 sinon faire b1.set({id:1});

Dans la console Play!>, on obtient :

    deleteBookmark : {"id":1,"label":"K33g'sBlog","website":"www.k33g.org"}

Donc lorsque l'on détruit un modèle BB c'est une requête `DELETE` qui est envoyée et la méthode `deleteBookmark` qui est appelée.

###fetch()

Dans la console du navigateur tapez les commandes suivantes : 

    b1.fetch(); // b1.id = 1 sinon faire b1.set({id:1});

Dans la console Play!>, on obtient :

    getBookmark : {"id":1,"label":"K33g'sBlog","website":"www.k33g.org"}

Donc lorsque l'on utilise la méthode fetch() d'un modèle BB c'est une requête `GET` qui est envoyée et la méthode `getBookmark` qui est appelée.

###Bilan des courses :

Nous avons tout ce qu'il faut côté Backbone pour passer les bonnes informations à Play!>. Nous passerons aux `Backbone.Collection(s)` plus tard. Pour le moment nous allons coder le "pendant" Java de notre modèle Backbone, afin de pouvoir effectuer des actions en base de données.

##Créer un modèle Bookmark.java

Allez dans `app/models` et créez une classe `Bookmark.java` :

{% highlight java %}
	package models;

	import play.*;
	import play.db.jpa.*;
	import play.data.validation.*;
	import javax.persistence.*;
	import java.util.*;

	@Entity
	public class Bookmark extends Model {
	    @Required public String label;
	    @Required public String website;

	    public Bookmark(String label, String website) {
	        this.label = label;
	        this.website = website;
	    }

	    public Bookmark() {

	    }	

	    public String toString() {
	        return label;
	    }	
	}

Puis allons modifier les méthodes du contrôleur `Application.java` :

	package controllers;

	import play.*;
	import play.mvc.*;

	import java.util.*;

	import models.*;

	import com.google.gson.JsonObject;
	import com.google.gson.Gson;

	public class Application extends Controller {

	    public static void index() {
	        render();
	    }
	
	    /* GET */
	    public static void getBookmark(String model) {
	        System.out.println("getBookmark : "+model);
	        Gson gson = new Gson();
	        Bookmark bookmark = new Bookmark();
	        Bookmark forFetchBookmark = new Bookmark();
	        bookmark = gson.fromJson(model,Bookmark.class);

	        forFetchBookmark = Bookmark.findById(bookmark.id);
	        //tester if found ...
	        renderJSON(forFetchBookmark);
	    }

	    /* POST (CREATE) */
	    public static void postBookmark(String model) {
	        System.out.println("postBookmark : "+model);

	        Gson gson = new Gson();
	        Bookmark bookmark = new Bookmark();
	        bookmark = gson.fromJson(model,Bookmark.class);
	        bookmark.save();
	        renderJSON(bookmark);
	    }

	    /* PUT (UPDATE) */
	    public static void putBookmark(String model) {
	       System.out.println("putBookmark : "+model);

	        Gson gson = new Gson();
	        Bookmark bookmark = new Bookmark();

	        Bookmark updatedBookmark = new Bookmark();

	        bookmark = gson.fromJson(model,Bookmark.class);

	        updatedBookmark = Bookmark.findById(bookmark.id);
	        updatedBookmark.label	= bookmark.label;

	        updatedBookmark.save();

	        renderJSON(updatedBookmark);
	    }
	
	    /* DELETE */
	    public static void deleteBookmark(String model) {
	        System.out.println("deleteBookmark : "+model);
	        Gson gson = new Gson();
	        Bookmark bookmark = new Bookmark();
	        Bookmark bookmarkToBeDeleted = new Bookmark();
	        bookmark = gson.fromJson(model,Bookmark.class);

	        bookmarkToBeDeleted = Bookmark.findById(bookmark.id);
	        //tester if found ...
	        bookmarkToBeDeleted.delete();

	        renderJSON(bookmarkToBeDeleted);
	    }
	
	    /* GET */
	    public static void allBookmarks() {
	        System.out.println("allBookmarks");

	        List<Bookmark> bookmarks = Bookmark.findAll();
	        renderJSON(new Gson().toJson(bookmarks));	
	    }

	}

**Notez bien :** les imports `com.google.gson.*` qui nous permettent de "traduire" le JSON.

**Ne pas oublier :** allez dans le fichier `conf/application.conf` et dans la rubrique `Database configuration` ajouter la ligne `db=fs`. (normal, on va utiliser la base de données)

Arrêtez & relancez l'application (ça ne peut pas faire de mal).

Rechargez tout d'abord la page de votre navigateur pour remettre "à zéro" les variables/objets/modèles javascript (Backbone) et relancer la compilation des classes côté Play!>.

###save()

Dans la console du navigateur tapez les commandes suivantes :

    b1 = new Bookmark({label:"K33g'sBlog",website:"www.k33g.org"});
    b1.save();

Attendez un petit peu (je n'ai pas mis de callback pour attendre la réponse du serveur). Vous voyerz une ligne `Objet` dans la console, en fait c'est la réponse de Play!> qui a renvoyé un objet de type JSON.

Si vous tapez la commande : `b1.get("id")` vous obtenez `1`. C'est Play!> qui lors de la sauvegarde a affecté un id automatiquement à l'objet JSON renvoyé, et Backbone qui a mappé le résultat sur son modèle b1.

![Alt "bbplay007.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay007.png)

On vérifie ?

###save again()

Dans un 1er temps, on change une valeur d'une propriété de notre modèle et on sauve à nouveau :

	b1.set({label:"Le blog de K33G"})
	b1.save();

![Alt "bbplay008.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay008.png)

On voit bien que cette fois ci, c'est un update, si vous surveillez votre terminal vous pouvez vérifier que c'est bien la méthode `putBookmark` qui a été appelée avec le changement de `label` qui est pris en compte.

Oui mais est-ce que ça a bien enregistré mes données en base ? Allons vérifier ...

###fetch()

Rechargez une nouvelle fois la page de votre navigateur pour remettre "à zéro" les variables/objets/modèles javascript (Backbone). Puis tapez les commandes suivantes :

	b1 = new Bookmark({id:1})
	b1.fetch()

Une fois que le serveur a répondu, vous pouvez vérifier que vous avez bien récupéré vos données :

	b1.get("label")

![Alt "bbplay009.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay009.png)

Donc, nos données ont bien été enregistrées en base.

###On ajoute quelques modèles avant de passer aux collections :

	b2 = new Bookmark({label:"Coffee Bean",website:"http://coffeebean.loicdescotte.com/"});
	b3 = new Bookmark({label:"blog.mklog",website:"http://blog.mklog.fr/"});
	b4 = new Bookmark({label:"LyonJS",website:"http://lyonjs.org/"});
	
	b2.save();
	b3.save();
	b4.save();

##Passons donc aux collections

Rechargez une nouvelle fois la page de votre navigateur pour remettre "à zéro" les variables/objets/modèles javascript (Backbone). Puis tapez les commandes suivantes :

	bookmarksCollection = new Bookmarks()
	bookmarksCollection.fetch()

Une fois que le serveur a répondu :

	bookmarksCollection.models
	bookmarksCollection.models.forEach(function(model){ console.log(model.get("label")); })

![Alt "bbplay010.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay010.png)

On a bien retrouvé nos données :) et finalement ce n'est pas si compliqué que ça.

##Derniers coups de tournevis pour la route

c'est mieux d'utilise des callbacks lorsque l'on fait des appels aux serveurs (ben oui on bosse en mode asynchrone) :

###Par exemple pour un save()

{% highlight javascript %}
	b = new Bookmark({label:"Google", website:"www.google.fr"})
	b.save({},
		{
			success:function(data){ console.log("Gagné : ", data); }, 
			error : function() { console.log("Oups! y'a un blem"); } 
		})
{% endhighlight %}

###Ou pour un fetch()

{% highlight javascript %}
	bookmarksCollection.fetch({
		success:function(data){ 
			console.log("Gagné : "); 
			bookmarksCollection.models.forEach(function(model){ console.log(model.get("label")); })
		}, 
		error : function() { console.log("Oups! y'a un blem"); }
	})
{% endhighlight %}

##Voilà, c'est fini pour aujourd'hui.

Bon je vous laisse déjà bricoler avec ça, et dans un prochain article, nous irons un peu plus loin : comment gère-t-on les relations ? (par exemple, on associe un thème ou une technologie à un bookmark). Et plus tard, je tenterais la même chose avec Play!> version 2.





