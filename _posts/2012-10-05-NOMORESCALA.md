---

layout: post
title: Comment se passer des templates Scala dans Play
info : Comment se passer des templates Scala dans Play

---

#Comment se passer des templates Scala dans Play!> 2

>*Qu'allons nous voir ?*

>	- *Comment créer des méthodes de contrôleurs **Play!>** qui vont répondre à des requêtes **REST***
>	- *Comment "appeler" ces méthodes via ajax avec **jQuery***
>	- *Comment "encapsuler" tout ça grâce à **Backbone***
>	- *... et comment utiliser le templating côté client avec **Mustache** ou **Underscore**.*

*... Il y aura même un peu de **YepNope**.*

*Code source : [https://github.com/k33g/samples/tree/master/spa](https://github.com/k33g/samples/tree/master/spa)*


>*Corrections & Ajouts du 06.10.2012*

>	- *Modifications du contrôleur `Humans` : suppression de `save()`, ajout de `create()` & `update()`*
>	- *Mise en conformité de `routes`*
>	- *Ajout d'un § : "Optimisation du code du contrôleur"*

##Avertissement

L'introduction (§ Prélude) est longue, c'est un "petit" coup de gueule, mais vous pouvez franchement passer directement à la partie ***§ "Faites du Play!>, pas du Scala, ou comment je me passe des templates ?"*** si vous voulez mettre les mains dedans tout de suite.

**Cet article est destiné aux :**

- développeurs Play!> allergiques à Scala
- développeurs Javascript & Backbone : il n'y a pas que Javascript dans la vie, Play!> est une techno backend excellente
- développeurs JEE, Java & Play!> en général : on peut faire autrement, il n'y a pas que Java dans la vie

Bonne lecture & remarques attendues.

*P.*

##Prélude

Cela va faire presque un an maintenant que je faisais ma première présentation en publique en compagnie de [@loic_d](https://twitter.com/loic_d) sur **PlayFramework 1** *(j'insiste sur le 1)* lors d'un **LyonJUG**. Alors, triple stress pour moi :

- d'habitude je m'adresse à des clients, là je me retrouve fasse à une foule de développeurs (1)
- je ne suis pas un développeur java
- la présentation est une sorte de "battle" : "Stateless versus Statefull", et notre "adversaire" est le brillant orateur, que dis-je ! Tribun ! [@antoine_sd](https://twitter.com/antoine_sd) de chez Ippon. Je rêve d'avoir son aisance en public. Donc, **Stateless**, [@loic_d](https://twitter.com/loic_d) et moi, **Statefull**, c'est [@antoine_sd](https://twitter.com/antoine_sd).

Concernant [@loic_d](https://twitter.com/loic_d), au moins un motif de stress : je (moi donc) ne suis pas un développeur java ;)

En dépit d'une grosse envie de reculer, mais n'ayant trouvé aucune excuse réellement sérieuse, nous sommes partis "au front", et finalement cela ne s'est pas trop mal passé ... Jusqu'à la séance de questions/réponses, pendant laquelle, en ce qui me concerne j'ai vécu un "petit" moment de solitude.

*(1): je suis avant-vendeur = faux commercial + faux développeur*

###Solitude, ou comment Play!> 2 m'a tué

Ma vision Play!> **1** de  était la suivante :

- Play!>, c'est mettre Java+"le Web" à la portée de tous (mon argument principal : *"même moi j'y arrive"*)
- Play!>, c'est donner de l'espoir aux jeunes développeurs débutants effrayés par JEE
- Play!>, m'a fait comprendre et aimer **MVC** (faites du STRUTS vous comprendrez)
- Play!>, pourrait même faire kiffer un développeur .Net
- Et enfin Play!>, c'est productif ! (là c'est surtout pour mes clients, patrons, directeurs de projets, CTO, ...)

Il se trouve qu'au moment de notre présentation, la version **2** de Play!> était en train de pointer le bout de son nez. Et que :

- apparaissait une version Scala de Play!> **2**,
- mais que même dans la version Java de Play!> **2**, tu (on se tutoie) est obligé de faire du Scala, car les templates (les vues) se codent en Scala, et que c'est génial, car comme c'est typé, ça limite les erreurs !!!

Eh bien, **NON !**, ce n'est pas génial, parce que :

- j'ai du mal avec Scala (je pense ne pas être le seul),
- j'ai déjà eu du mal à vendre une techno qui s'appelle "Play", si en plus il faut vendre une nouvelle techno (qui en plus s'appelle "Scala"), que personne ne connaît (je rappelle que je suis en province) ...
- Et ... Oh purée ! *(expression stéphanoise)* Comment fait-on pour la migration ?

Et c'est cette dernière question qui nous a été posée ! 

Et là, Guillaume Bort, si je t'avais eu sous la main (désolé, on ne se connaît pas, je me permets tout de même de te tutoyer), je crois que je t'aurais lâchement laissé répondre à cette foule de développeurs anxieux de connaître le devenir de ce qu'ils pensaient être le graal du développement "java web" *(petite référence à Grails) ...*. D'un framework présenté comme l'outil de développement des **masses**, accessible à tous, on passait à un outil destiné à **l'élite !!!** *PS : je suis du côté des masses*.

Je crois même me souvenir d'avoir vu passer un tweet de [@juliendubois](https://twitter.com/juliendubois) pendant la prez, qui ricannait (gentiment) sur le sujet.

Je ne suis plus sûr de ce que nous avons répondu, mais sur le coup : "Solitude !" *(Ah! [@loic_d](https://twitter.com/loic_d) me dit dans l'oreillette qu'il avait parlé du module de template Groovy en préparation à l'époque)*. Je comprend mieux pourquoi, nous n'arrivons pas à faire un ["Cast-it"](http://www.cast-it.fr/) avec toi sur le sujet, au bout de presqu'un an, Guillaume, tu dois être super embêté de nous avoir mis dans cette situation :)))

###Tristesse et renaissance

Ce soir là, j'étais prêt à abandonner Play!>. Après quelques semaines (mois ?) d'errements et d'égarements, j'ai quand même appris à utiliser node.js et express.js !!! *(soit-dit en passant, c'est pas mal du tout)*, j'ai décidé que je n'allais pas m'avouer vaincu aussi facilement, **moi aussi je veux faire partie de l'élite !**, et je me suis "collé" dans Play!> **2** (j'ai un peu gratté sur ce que j'arrivais à apprendre : [http://3monkeys.github.com/play.rules/livre.play.deux.web/play2.rules.return.html](http://3monkeys.github.com/play.rules/livre.play.deux.web/play2.rules.return.html)).*([@loic_d](https://twitter.com/loic_d) devrait vous concocter quelques trucs supplémentaires dans un futur proche ... sur du Scala justement)*.

####Résultats ???

Alors, je suis arrivé à retrouver mes petits en ce qui concerne les modèles et les contrôleurs, mais pour les vues, décidément je ne m'y fais pas, Scala, je n'y arrive pas (le 1er qui me dit que c'est comme javascript a intérêt à courrir vite), en dépit des efforts de [@loic_d](https://twitter.com/loic_d) pour me vendre le bouzin, pour le moment ce n'est pas pour moi *(Mais ne jamais dire jamais)*.

Malgré, cette légère problématique à propos des vues, **j'ai appris à nouveau à aimer Play!>** (Guillaume, si un jour tu me lis, j'espère que tu es rassuré ;)) et que le concept initial était respecté.

... Et je me suis trouvé mon propre arrangement (avec moi-même) pour continuer à faire du Play!> avec la version **2** ... Mais **Sans les vues "Scala** *(Oh purée ! L'hérétique !!!)*

Nous voilà donc enfin dans le vif du sujet de cet article. Certes, c'était long, mais cela fait un an que je rumine :)

##Faites du Play!>, pas du Scala, ou comment je me passe des templates ?

Il se trouve que je suis très fan (et j'y crois) du modèle [**"Single Page Application"**](http://en.wikipedia.org/wiki/Single-page_application). En gros entre la page web et le serveur, seules les données circulent, vous n'avez potentiellement qu'une seule page html (avec pas mal d'intelligence en javascript) et côté serveur, vos contrôleurs vous crachent du json. Un exemple ? **Gmail !!!** *(donc ne me dites pas que l'idée est "débile")*.

J'ai donc poussé l'exercice jusqu'au bout ;), j'ai même supprimé le répertoire `views` de mon projet Play!> 2.

###Objectifs & Préparation du projet

####Objectifs

Mon but est de faire une application Play!> 2 sur les principes REST (Representational State Transfer) qui permettra de faire des opérations de type **CRUD** sur un modèle java en utilisant des services basés sur le protocole http avec les verbes suivants :

- **C**reate : POST
- **R**ead : GET
- **U**pdate : PUT
- **D**elete : DELETE

Si cela vous paraît obscur, pas d'inquiétude, la partie pratique du tuto devrait vous éclairer. Mais je vous engage fortement à lire [http://naholyr.fr/2011/08/ecrire-service-rest-nodejs-express-partie-1/](http://naholyr.fr/2011/08/ecrire-service-rest-nodejs-express-partie-1/) de [@naholyr](https://twitter.com/naholyr).

####Génération du squelette de l'application

Commencez donc par créer une application java Play!> 2 :

- dans une console ou un terminal, tapez `play new spa` *(spa pour single page application)*
- à la question `What is the application name ?`, validez le choix par défaut
- ensuite choisissez l'alternative `2 - Create a simple Java application`, donc tapez `2` et validez
- puis faites `cd spa`, puis `play ~run` pour démarrer votre application *(vous n'êtes pas obligés de le faire tout de suite)* *(le `~` permet à Play!> de scruter tous les changements et de compiler "en live")*.

Faites un peu de rangement :

- supprimez le répertoire `spa\app\views` (et donc son contenu)
- supprimez le contrôleur `Application.java` du répetoire `spa\app\controllers`
- créez un répertoire `spa\app\models`

#####Paramétrage de la persistance des données

Aller dans `spa\conf\application.conf` et changez (vers la ligne 25) :

	# db.default.driver=org.h2.Driver
	# db.default.url="jdbc:h2:mem:play"

par 

	db.default.driver=org.h2.Driver
	db.default.url="jdbc:h2:file:play"

puis décommentez :

	# ebean.default="models.*"

... enregistrez.

#####Définition d'une route statique

Aller dans `spa\conf\routes` et supprimer la "route Home" :

	# Home page
	GET     /                           controllers.Application.index()

Et ajoutez celle-ci à la fin :

	GET / controllers.Assets.at(path="/public", file="index.html")

Cela signifie, maintenant, que lorsque nous appellerons [http://localhost:9000](http://localhost:9000), ce sera la page statique `index.html` qui sera chargée.

####Préparation des éléments statiques du projet

Avant de "coder" notre page `index.html` nous aurons besoin des éléments suivants :

- la dernière version de jQuery : [http://code.jquery.com/jquery-1.8.2.js](http://code.jquery.com/jquery-1.8.2.js)
- la dernière version d'Underscore  : [http://underscorejs.org/underscore.js](http://underscorejs.org/underscore.js)
- la dernière version de Backbone : [http://backbonejs.org/backbone.js](http://backbonejs.org/backbone.js)
- la dernière version de Mustache : [https://raw.github.com/janl/mustache.js/master/mustache.js](https://raw.github.com/janl/mustache.js/master/mustache.js)
- la dernière version de YepNope : [https://raw.github.com/SlexAxton/yepnope.js/master/yepnope.js](https://raw.github.com/SlexAxton/yepnope.js/master/yepnope.js)

Et collez moi tout ça pour le moment dans `spa\public\javascripts` (vous pouvez supprimer `jquery-1.7.1.min.js`).

**Remarque :** YepNope est un loader de script, certains me diront que Play!> apporte le support de Require.js, mais je préfère YepNope, donc après vous pourrez adapter.

####Codons notre page index.html

Pour le moment pas besoin de grand chose, créez une page index.html dans `spa\public` avec le code suivant :

	<!DOCTYPE html>

	<html>
	    <head>
	        <title>Single Page Application</title>
	        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	    </head>
	    <body>
	    	<h1>My Single Page Application</h1>
	    	<h2>by K33G_org</h2>

	    </body>

	    <script src="assets/javascripts/yepnope.js"></script>
	    <script src="assets/main.js"></script>

	</html>

Rien de très violent, jusqu'ici. Nous allons faire un peu plus de chose avec `main.js`.

####Codons le fichier main.js de chargement de script :

Créez un fichier main.js dans `spa\public` avec le code suivant :

	yepnope({
	    load: {
	        jquery              : 'assets/javascripts/jquery-1.8.2.js',
	        underscore          : 'assets/javascripts/underscore.js',
	        backbone            : 'assets/javascripts/backbone.js',
	        mustache            : 'assets/javascripts/mustache.js',
	    },
	    complete : function () {
	        $(function (){
	            console.log("Application chargée ...");

	        });  
	    }
	});

Je pense que vous me voyez venir, je vais vous parler de Backbone, mais dans un premier temps c'est surtout jQuery qui va nous être utile.

Vous pouvez d'ores et déjà tester votre page pour vérifier que les scripts javascript sont bien chargés.

###Enfin un peu de Java : le modèle !

Codons notre 1er (et seul modèle), dans le répertoire `spa\app\models` donc. Et je ne vais pas être original pour 2 sous : `Human.java` :

	package models;

	import play.db.ebean.Model;
	import javax.persistence.*;

	@Entity
	public class Human extends Model{

	    @Id
	    public Long id;
	    public String firstName;
	    public String lastName;
	    public Long age;

	    public static Finder<Long, Human> find = 
	            new Finder<Long, Human>(Long.class, Human.class);

	}

###Et maintenant ... Le contrôleur !

Là aussi, nous allons coder notre seul et unique contrôleur `Humans.java` dans `spa\app\controllers`. Cette fois, il y a un peu plus de code, donc soyez attentifs. J'explique en commentaire dans le code à quoi vont servir les méthodes :

	package controllers;

	import models.*;
	import play.data.*;
	import play.mvc.*;

	import java.util.List;

	import static play.libs.Json.toJson;

	public class Humans extends Controller {

	    /*
	        Retourner une liste (au format JSON) de Humans
	        cela correspond à un appel http de type GET
	    */
	    public static Result getAll() { // GET

	        List<Human> list = Human.find.orderBy("lastName").findList();
	        return ok(toJson(list));
	    }

	    /*
	        Retrouver un "Human" (au format JSON) par son id
	        Cela correspond à un appel http de type GET
	        Si il n'existe pas on génère une erreur
	    */
	    public static Result getById(Long id) { // GET

	        Human modelToFind = Human.find.byId(id);

	        if(modelToFind!=null) {
	            return ok(toJson(modelToFind));
	        } else {
	            return badRequest("not found");
	        }
	        
	    }

	    /*
	        Créer ou sauvegarder un "Human", c'est une requête de type POST ou PUT.
	        - On récupère les paramètres grâce à bindFromRequest
	        - si l'id du modèle n'est pas null c'est une mise à jour (PUT)
	        - sinon c'est une création (POST)
	    */
	    public static Result create() { //POST

	        Form<Human> form = form(Human.class).bindFromRequest();
	        Human model = form.get();
			model.save();
	        return ok(toJson(model));
	    }

	    public static Result update(Long id) { //PUT

	        Form<Human> form = form(Human.class).bindFromRequest();
	        Human model = form.get();
	        model.id = id;
	        model.update();
	        return ok(toJson(model));
	    }	    


	    /*
	        Retrouver un "Human" (au format JSON) par son id
	        Puis le supprimer
	        Cela correspond à un appel http de type DELETE
	        Si il n'existe pas on génère une erreur
	    */
	    public static Result delete(Long id) { // DELETE

	        Human modelToFind = Human.find.byId(id);
	        if(modelToFind!=null) {
	            modelToFind.delete();
	            return ok(toJson(true));
	        } else {
	            return badRequest("not found");
	        }

	    }

	    /*
	        Requêtes de type GET pour ne ramener qu'un certain nombre d'enregistrements
	    */
	    public static Result query(String fieldName, String value) { // GET
	        //humans/lastName/equals/morane
	        List<Human> list = Human.find.where().eq(fieldName, value).findList();
	        return ok(toJson(list));
	    }      
	}

... ça c'est fait.

###Ensuite l'écriture indispensable des routes correspondantes (pour chacune des méthodes du contrôleur) :

On ajoute ceci dans le fichier `routes` :

	#Création
	POST /humans  controllers.Humans.create()

	#Mise à jour
	PUT /humans/:id  controllers.Humans.update(id: Long)		

	#Rechercher par Id
	GET  /humans/:id  controllers.Humans.getById(id: Long)

	#Supprimer par Id
	DELETE /humans/:id  controllers.Humans.delete(id: Long)

	#Retrouver tous les éléments
	GET /humans controllers.Humans.getAll()

	#Retrouver certains éléments
	GET /humans/:fieldName/equals/:value controllers.Humans.query(fieldName: String, value: String)

Nous avons maintenant tout ce qu'il faut pour faire nos 1ères requêtes ajax. Vous pouvez Raffraîchir votre page (Play!> va vous proposer de créer votre modèle de données. Ne refusez pas.)

###De l'Ajax dans la console

Maintenant, ouvrez la console de votre navigateur, et nous allons essayer diverses requêtes ajax (avec l'aide de jQuery).

####Créer des "Humans"

Une 1ère création :

	$.ajax({
	    type:"POST", 
	    url:"/humans", data:{firstName:"John", lastName:"Doe"}, 
	    error : function(err){console.log("Erreur", err);}, 
	    success : function(data){ console.log(data);}
	});

Vous devriez obtenir une sortie de ce type dans la console. Vous notez au passage qu'un id a été automatiquement affecté au modèle :

![Alt "img"](https://github.com/k33g/k33g.github.com/raw/master/images/001-ajax.png)

Une 2ème création :

	$.ajax({
	    type:"POST", 
	    url:"/humans", data:{firstName:"Bob", lastName:"Morane"}, 
	    error : function(err){console.log("Erreur", err);}, 
	    success : function(data){ console.log(data);}
	});

Et enfin une 3ème :

	$.ajax({
	    type:"POST", 
	    url:"/humans", data:{firstName:"Tom", lastName:"Jones"}, 
	    error : function(err){console.log("Erreur", err);}, 
	    success : function(data){ console.log(data);}
	});

A chaque fois vous pourrez noter que l'on obtient automatiquement un Id pour le model.

####Retrouver tous les enregistrements :

C'est très simple : (notez le changement d'url : `/humans` à la place de `/human`)

    $.ajax({
        type:"GET", 
        url:"/humans", 
        error : function(err){console.log("Erreur", err);}, 
        success : function(data){ console.log(data);}
    });

Vous devriez obtenir une sortie de ce type dans la console :

![Alt "img"](https://github.com/k33g/k33g.github.com/raw/master/images/002-ajax.png)

####Modification des modèles

J'ai oublié de renseigner l'âge :

	$.ajax({
	    type:"PUT", 
	    url:"/humans/1", data:{age: 43, firstName : "John", lastName : "DOE"}, 
	    error : function(err){console.log("Erreur", err);}, 
	    success : function(data){ console.log(data);}
	});

**Remarque :** l'id est passé dans l'url.

**Remarque :** je suis allé au plus simple dans mon exemple (code côté java), donc vous devez penser à bien renseigner l'ensemble des champs lors de la mise à jour.

####Faire une reqûete : je veux toute la famille "DOE"

Tout d'abord, ajouter un modèle avec un lastName égal à "DOE"

	$.ajax({
	    type:"POST", 
	    url:"/humans", data:{age: 22, firstName : "Jane", lastName : "DOE"}, 
	    error : function(err){console.log("Erreur", err);}, 
	    success : function(data){ console.log(data);}
	});

Puis : 

	$.ajax({
	    type:"GET", 
	    url:"/humans/lastName/equals/DOE", 
	    error : function(err){console.log("Erreur", err);}, 
	    success : function(data){ console.log(data);}
	});

Donc, là si tous va bien vous obtiendrez cette sortie :

![Alt "img"](https://github.com/k33g/k33g.github.com/raw/master/images/003-ajax.png)

####Suppression d'un modèle :

Par exemple, je souhaite supprimer le modèle d'Id 4 (Jane) :

	$.ajax({
	    type:"DELETE", 
	    url:"/humans/4", 
	    error : function(err){console.log("Erreur", err);}, 
	    success : function(data){ console.log(data);}
	});

Et si vous tentez une seconde fois de supprimer le même modèle, vous récupèrerez bien une erreur dans la console javascript. avec une propriété `responseText` égale à `"not found"` et une propriété `statusText` égale à `"Bad Request"`.

Nous pourrions bien sûr programmer bien d'autres types de requêtes, mais pour l'exercice, les requêtes "de base" sont amplement suffisantes.

###Backbone <3 Play!>

Il est temps de faire du MVC côté client avec Backbone.js.

####Création d'un Backbone.Model et d'une Backbone.Collection

Dans `main.js`, ajoutez `application         : 'assets/app.js'`

	yepnope({
	    load: {
	        jquery              : 'assets/javascripts/jquery-1.8.2.js',
	        underscore          : 'assets/javascripts/underscore.js',
	        backbone            : 'assets/javascripts/backbone.js',
	        mustache            : 'assets/javascripts/mustache.js',
	        application         : 'assets/app.js' 						//<-- l'ajout est ici
	    },
	    complete : function () {
	        $(function (){
	            console.log("Application chargée ...");
	            App.start();	 										//<-- et ici aussi

	        });  
	    }
	});

puis créez un fichier `app.js` qui contiendra notre application Backbone dans le répertoire `spa\public` :

	/* Module */
	var App = {
		Models : {},
		Collections : {},
		Views : {},
		start : function() { start(); }

	}

	App.Models.Human = Backbone.Model.extend({
		urlRoot : "/humans"
	});

	App.Collections.Humans = Backbone.Collection.extend({
		url : "/humans"
	});


	function start() {
		console.log("Démarrage de l'application Backbone");
	}

####Testons notre modèle et notre collection dans la console

Toujours dans la console du navigateur :

	var angelina = new App.Models.Human({firstName:"Angelina", lastName:"Jolie"});
	var sam = new App.Models.Human({firstName:"Sam", lastName:"LePirate"});

puis :

	angelina.save({}, {
		success : function(data) { console.log(data); },
		error : function(err) { throw err; }
	});

	sam.save({}, {
		success : function(data) { console.log(data); },
		error : function(err) { throw err; }
	});

Jusqu'ici, normalement, si tout s'est bien passé, vous devriez avoir 2 "humans" supplémentaires en base de données. Nous allons le vérifier en créant une collection Backbone (encore dans la console) :

	var humans = new App.Collections.Humans();

Puis :

	humans.fetch({
		success : function(data) { console.log(data); },
		error : function(err) { throw err; }
	});

puis faites un :

	humans.each(function(human){
		console.log(human.get("id"),human.get("firstName"), human.get("lastName"));
	})

Et vous obtiendrez la liste complète des enregistrements :

![Alt "img"](https://github.com/k33g/k33g.github.com/raw/master/images/004-ajax.png)

Donc vous pouvez voir que nos "objets" Backbone savent très bien "discuter" avec nos services REST Play!> 2 (sans rin re-écrire, ce qui est assez pratique).

Nous pouvons donc passer à la partie affichage.

####Templating côté client

Pour cela nous utiliserons **Mustache.js**. 

Nous allons décrire notre template d'affichage dans la page `index.html` :

	        <!-- définition du template -->
	        <script type="text/template" id="humans_list_template">

	            <ul>{ {#humans} }
	                <li>{ {id} } { {firstName} } { {lastName} } { {age} }</li>
	            { {/humans} }</ul>
	            
	        </script>
	        <!-- les résultats viendront ici -->
	        <div id="humans_list"></div>

**PS: Supprimez les espace entre { et { ou } } : j'ai un problème d'affichage avec Jekyll, et l'option raw semble ne pas fonctionner.**

Donc au final, notre page html aura le code suivant :

	<!DOCTYPE html>

	<html>
	    <head>
	        <title>Single Page Application</title>
	        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	    </head>
	    <body>
	    	<h1>My Single Page Application</h1>
	    	<h2>by K33G_org</h2>

	        <!-- définition du template -->
	        <script type="text/template" id="humans_list_template">

	            <ul>{ {#humans} }
	                <li>{ {id} } { {firstName} } { {lastName} } { {age} }</li>
	            { {/humans} }</ul>
	            
	        </script>
	        <!-- les résultats viendront ici -->
	        <div id="humans_list"></div>

	    </body>

	    <script src="assets/javascripts/yepnope.js"></script>
	    <script src="assets/main.js"></script>

	</html>

Ensuite, allons coller notre code Backbone dans `app.js` :

Nous allons ajouter une vue `HumansListView` :

	App.Views.HumansListView = Backbone.View.extend({
	    el : $("#humans_list"),
	    initialize : function () {
	        this.template = $("#humans_list_template").html();

	        //dès que la collection "change" j'actualise le rendu de la vue
	        _.bindAll(this, 'render');
	        this.collection.bind('reset', this.render);
	        this.collection.bind('change', this.render);
	        this.collection.bind('add', this.render);
	        this.collection.bind('remove', this.render);

	    },
	    render : function () {
	        var renderedContent = Mustache.to_html(this.template, {humans : this.collection.toJSON()} );
	        this.$el.html(renderedContent);
	    }
	});

que nous allons utiliser dans la fonction `start()` qui est appelée une fois la page html chargée (cf. méthode `complete()` de **yepnope** dans `main.js`) :

	function start() {

		console.log("Démarrage de l'application Backbone");

		window.humansCollection = new App.Collections.Humans();

		window.humansListView = new App.Views.HumansListView({collection : humansCollection});

		humansCollection.fetch({
			success : function(data) { console.log(data); },
			error : function(err) { throw err; }
		});

	}

**Code final d'app.js**

	/* Module */
	var App = {
		Models : {},
		Collections : {},
		Views : {},
		start : function() { start(); }

	}

	App.Models.Human = Backbone.Model.extend({
		urlRoot  : "/humans"
	});

	App.Collections.Humans = Backbone.Collection.extend({
		url : "/humans",
		model : App.Models.Human
		
	});

	App.Views.HumansListView = Backbone.View.extend({
	    el : $("#humans_list"),
	    initialize : function () {
	        this.template = $("#humans_list_template").html();

	        //dès que la collection "change" j'actualise le rendu de la vue
	        _.bindAll(this, 'render');
	        this.collection.bind('reset', this.render);
	        this.collection.bind('change', this.render);
	        this.collection.bind('add', this.render);
	        this.collection.bind('remove', this.render);

	    },
	    render : function () {
	        var renderedContent = Mustache.to_html(this.template, {humans : this.collection.toJSON()} );
	        this.$el.html(renderedContent);
	    }
	});

	function start() {

		console.log("Démarrage de l'application Backbone");

		window.humansCollection = new App.Collections.Humans();

		window.humansListView = new App.Views.HumansListView({collection : humansCollection});

		humansCollection.fetch({
			success : function(data) { console.log(data); },
			error : function(err) { throw err; }
		});
	}

Maintenant, enregistrez et raffraichissez la page de votre navigateur, et **"tadaaaa !"** :

![Alt "img"](https://github.com/k33g/k33g.github.com/raw/master/images/005-ajax.png)

#####Attendez ce n'est pas fini :

Dans la console de votre navigateur, essayez ceci :

	humansCollection.add(new App.Models.Human({
		firstName : "K33g_org",
		lastName : "GrosGeek",
		age : 43 
	}))

La liste va se mettre à jour automatiquement.

Maintenant (toujours dans la console du navigateur), essayez ceci :

	var philippe = new App.Models.Human({
		firstName : "Philippe",
		lastName : "Charrière",
		age : 43 
	})

puis :

	philippe.save({},{
		success : function () { humansCollection.fetch(); },
		error : function (err){ throw err; }
	})

Cette fois, le modèle est enregistré en base, la collection rechargée et la liste remise à jour automatiquement.

Backbone, vous permet beaucoup d'autres petits tours de magie, mais ce n'est pas l'objet de ce tuto.

#####Une dernière remarque à propos du templating

Le template que nous avons utilisé est "passif", nous ne pouvons pas décrire de fonctions dans le template, tout est préparé en amont par l'objet `Backbone.View`. Si vous avez besoin de faire autrement (un peu comme avec les templates Scala ;)), c'est à dire "mettre" un peu d'intelligence dans le template (par exemple, afficher un message quand `age` n'est pas renseigné), sachez que la librairie **Underscore** possède elle aussi un moteur de template.

Si vous voulez essayez, votre template ressemblera à ceci :

    <!-- définition du template -->
    <script type="text/template" id="humans_list_again_template">

        <ul>
            <% _.each(humans ,function(human){ %>
                <li> 
                    <%= human.get("id") %> 
                    <%= human.get("firstName") %> 
                    <%= human.get("lastName") %> 
                    <%= human.get("age") ? human.get("age") : "<b>???</b>" %>
                </li>
            <% }); %>
        </ul>

    </script>
    <!-- les résultats viendront ici -->
    <div id="humans_list_again"></div>

Votre nouvelle vue `HumansListAgainView` aura cette tête :

	App.Views.HumansListAgainView = Backbone.View.extend({
		el : $("#humans_list_again"),
		initialize : function (blog) {
			this.template = _.template($("#humans_list_again_template").html());

	        _.bindAll(this, 'render');
	        this.collection.bind('reset', this.render);
	        this.collection.bind('change', this.render);
	        this.collection.bind('add', this.render);
	        this.collection.bind('remove', this.render);
		},
		render : function () {
	        var renderedContent = this.template({humans : this.collection.models });
	        this.$el.html(renderedContent);			
		}			
	});

Vous l'instanciez comme la précédente : `window.humansListAgainView = new App.Views.HumansListAgainView({collection : humansCollection});`

Sauvegardez, testez :

![Alt "img"](https://github.com/k33g/k33g.github.com/raw/master/images/006-ajax.png)

####Optimisation du code du contrôleur

Finalement, nous savons que nous n'échangeons que du JSON entre le client et le serveur, donc nous allons faire la même chose que `Form<Human> form = form(Human.class).bindFromRequest();` et `Human model = form.get();` mais en plus simple. Vous pouvez remplacer ces 2 lignes par `Human model = fromJson(request().body().asJson(), Human.class);` et nous aurons finalement le code suivant :

	package controllers;

	import models.*;
	import play.data.*;
	import play.mvc.*;

	import java.util.List;

	import static play.libs.Json.toJson;

	//Ajout de 2 imports
	import static play.libs.Json.fromJson;
	import org.codehaus.jackson.JsonNode;


	public class Humans extends Controller {

	    /*
	        Retourner une liste (au format JSON) de Humans
	        cela correspond à un appel http de type GET
	    */
	    public static Result getAll() { // GET

	        List<Human> list = Human.find.orderBy("lastName").findList();
	        return ok(toJson(list));
	    }

	    /*
	        Retrouver un "Human" (au format JSON) par son id
	        Cela correspond à un appel http de type GET
	        Si il n'existe pas on génère une erreur
	    */
	    public static Result getById(Long id) { // GET

	        Human modelToFind = Human.find.byId(id);

	        if(modelToFind!=null) {
	            return ok(toJson(modelToFind));
	        } else {
	            return badRequest("not found");
	        }
	        
	    }

	    /*
	        Créer ou sauvegarder un "Human", c'est une requête de type POST ou PUT.
	        - On récupère les paramètres grâce à bindFromRequest
	        - si l'id du modèle n'est pas null c'est une mise à jour (PUT)
	        - sinon c'est une création (POST)

	    */
	    public static Result create() { //POST

	        Human model = fromJson(request().body().asJson(), Human.class);        
	        model.save();
	        return ok(toJson(model));	        
	    }

	    public static Result update(Long id) { //PUT
	        
	        Human model = fromJson(request().body().asJson(), Human.class);
	        model.id = id;
	        model.update();
	        return ok(toJson(model));
	    }

	    /*
	        Retrouver un "Human" (au format JSON) par son id
	        Puis le supprimer
	        Cela correspond à un appel http de type DELETE
	        Si il n'existe pas on génère une erreur
	    */
	    public static Result delete(Long id) { // DELETE

	        Human modelToFind = Human.find.byId(id);
	        if(modelToFind!=null) {
	            modelToFind.delete();
	            return ok(toJson(true));
	        } else {
	            return badRequest("not found");
	        }

	    }

	    /*
	        Requêtes de type GET pour ne ramener qu'un certain nombre d'enregistrements
	    */
	    public static Result query(String fieldName, String value) { // GET
	        //humans/lastName/equals/morane
	        List<Human> list = Human.find.where().eq(fieldName, value).findList();
	        return ok(toJson(list));
	    }    
	  
	}

**Remarque :** N'oubliez pas d'ajouter :

	import static play.libs.Json.fromJson;
	import org.codehaus.jackson.JsonNode;

Voilà, c'est tout pour aujourd'hui.

*(Promis, j'essaierais un jour de faire la même chose en Scala)*.

