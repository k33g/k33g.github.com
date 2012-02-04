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


