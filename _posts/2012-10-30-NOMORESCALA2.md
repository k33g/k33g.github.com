---

layout: post
title: Comment se passer des templates Scala dans Play
info : Comment se passer des templates Scala dans Play

---

#Je continue à me passer des templates Scala dans Play!> 2

>*Qu'allons nous voir ?*

>	- *Que Coffeescript ça peut servir à quelque chose*
>	- *rien d'autre, on fait court aujourd'hui*

##Préambule

C'est promis, cette fois, je vais être plus court. Restant persuadé (et ce n'est pas faute d'avoir investiguer d'autres pistes) que Play!> est le framework java web le plus facile à mettre en oeuvre (entendez par là, *même si tu es nul tu dois y arriver*), mais que je ne suis pas fait pour Scala, j'ai continué ma petite expérience de la dernière fois.

J'ai lu quelque part que mettre ses templates Mustache (ou autres) "inline" via des balises `<script type="tewt/bidule"></script>` était une hérésie (m'enfin ... c'est quand même bien pratique), que de le charger à partir d'un fichier externe via une requête ajax, ce n'était quand même pas "top" optimisé (yep ... mais là aussi c'est pratique) ... Donc, pour faire simple, je suis un gros "goret" du code.

**Mais Play!> m'a sauvé !**

Vous savez (ou pas) que Play!>2, sait aussi transpiler automatiquement du **Coffeescript**. Nous allons donc profiter de la fonctionnalité **Block Strings** de **Coffeescript**. Kézako ? C'est un des rêves de beaucoup de développeurs, pouvoir écrire ses p... de chaînes de caractères beaucoup trop longue sur plusieurs lignes sans être obligé de se farcir un StringBuilder à la c... (*En plus dêtre un goret, je suis une faignasse*), comme ceci par exemple :

	mySong = """

	Ce soir, tu t'es couchée à neuf heures
	Dans ton pti coeur c'est le bonheur
	Les draps légers te carressent la raie....... des cheveux
	L'immeuble avec toi c'est endormi
	Seule, au troisième, une lueur luit.
	Pauvre espagnol sans soleil,
	Ramon Perez n'a pas sommeil

	"""

Et là camarade insomniaque, je vois tes yeux briller ...

##Comment on fait ?

Ce n'est pas difficile. Commencez par céer un répertoire `assets` dans le répertoire `app` de votre projet (j'oubliais : repartez du projet de l'article précédent : [http://k33g.github.com/2012/10/05/NOMORESCALA.html](http://k33g.github.com/2012/10/05/NOMORESCALA.html)).

Ensuite, allez faire un tour dans votre page html, vous devez (si vous avez fait l'exercice jusqu'au bout) avoir 2 déclarations de template (une au formalisme **Mustache**, l'autre au formalisme **Underscore**) :

pour Mustache :

        <!-- définition du template -->
        <script type="text/template" id="humans_list_template">

            <ul>{ {#humans} }
                <li>{ {id} } { {firstName} } { {lastName} } { {age} }</li>
            { {/humans} }</ul>
            
        </script>
        <!-- les résultats viendront ici -->
        <div id="humans_list"></div>

        <hr>

et pour Underscore :

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

Vous pouvez (devez) vous débarrasser des balises `<script>` et de leur contenu, vous n'aurez donc plus que ceci :

        <div id="humans_list"></div>

        <hr>

        <div id="humans_list_again"></div>


###Externalisation des templates

Vous allez créer dans `app/assets` deux fichiers `.coffee` :

- `humans_list_template.coffee`
- `humans_list_again_template.coffee`

avec les contenus suivants (on prend les définitions de template de la page `index.html`):

**<u>humans_list_template.coffee</u>**

	App.Templates.humans_list_template = """
	    <ul>{ {#humans} }
	        <li>{ {id} } { {firstName} } { {lastName} } { {age} }</li>
	    { {/humans} }</ul>
	"""


**<u>humans_list_again_template.coffee</u>**

	App.Templates.humans_list_again_template = """
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
	"""

Au lancement Play!> va transformer nos templates coffeescript en bons vieux fichiers javascript que nous allons pouvoir déclarer à notre script loader, et en plus on s'évite le fait d'aller interroger le DOM pour retrouver le contenu des balises `<script>`.


###Modification du code javascript

Il va falloir modifier `main.js` & `app.js` :

**<u>main.js</u>** : nous allons ajouter le chargement de nos templates :

	yepnope({
	    load: {
	        jquery              : 'assets/javascripts/jquery-1.8.2.js',
	        underscore          : 'assets/javascripts/underscore.js',
	        backbone            : 'assets/javascripts/backbone.js',
	        mustache            : 'assets/javascripts/mustache.js',
	        application         : 'assets/app.js',

	        //Templates
	        humans_list_template         : 'assets/humans_list_template.js',
	        humans_list_again_template   : 'assets/humans_list_again_template.js'  
	    },
	    complete : function () {
	        $(function (){
	            console.log("Application chargée ...");
	            App.start();

	        });  
	    }
	});

**<u>app.js</u>** : 1ère modification, ajoutons un "namespace" `Templates` :

	/* Module */
	var App = {
		Models : {},
		Collections : {},
		Views : {},
		start : function() { start(); },

	    Templates : {} /* <--- la modif est ici */

	}


**<u>app.js</u>** : 2ème modification, il faut re-écrire la partie des vues qui allait interroger le DOM pour récupérer le template. Maintenant, on ne fait plus appel à jQuery pour ceci, les template sont dans des variables et Play!> aura "pré compilé" les templates.

	App.Views.HumansListView = Backbone.View.extend({
	    el : $("#humans_list"),
	    initialize : function () {
	        //this.template = $("#humans_list_template").html();

	        this.template = App.Templates.humans_list_template;

	        //dès que la collection "change" j'actualise le rendu de la vue
	        _.bindAll(this, 'render');
	        this.collection.bind('reset', this.render);
	        this.collection.bind('change', this.render);
	        this.collection.bind('add', this.render);
	        this.collection.bind('remove', this.render);

	    },
	    render : function () {
	        var renderedContent = Mustache.to_html(this.template, { humans : this.collection.toJSON() } );
	        this.$el.html(renderedContent);
	    }
	});

et :

	App.Views.HumansListAgainView = Backbone.View.extend({
		el : $("#humans_list_again"),
		initialize : function (blog) {
	        //this.template = _.template($("#humans_list_again_template").html());

			this.template = _.template(App.Templates.humans_list_again_template);

	        _.bindAll(this, 'render');
	        this.collection.bind('reset', this.render);
	        this.collection.bind('change', this.render);
	        this.collection.bind('add', this.render);
	        this.collection.bind('remove', this.render);
		},
		render : function () {
	        var renderedContent = this.template({ humans : this.collection.models });
	        this.$el.html(renderedContent);			
		}			
	});

Enregistrez, testez, normalement cela fonctionne. En plus vous avez économisé 2 appels jQuery et allégé votre page index.html, donc vous avez optimisez votre code.

Voilà voilà ...
