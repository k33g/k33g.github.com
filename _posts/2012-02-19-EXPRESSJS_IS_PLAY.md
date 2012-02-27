---

layout: post
title: Express.js comme PlayFramework
info : Express.js comme PlayFramework

---

#Express.js, le Play!>Framework du Javascript ?

Pas tout seul, mais en lui ajoutant 2 ou 3 petites choses, on s'en approche.

##Introduction

Pour démontrer ce que j'ai écrit dans mon titre, je vais "réaliser" une application à l'aide de :

- Node.js
- Express.js
- Backbone.js
- ... et d'autres, mais vous verrez ça plus loin

Cette application, permettra (pour cette fois) :

- de saisir des messages en markdown avec la possibilité de coloriser les portions de codes présentes dans les messages
- de garder ces messages en mémoire (je vais simuler un système de persistance en mémoire, mais je ré-initialise tous les 5 messages)

Donc, nous allons :

- créer des routes, des vues, des modèles, …
- faire des requêtes de types REST, avec des POST, PUT, GET, DELETE

Si vous arrivez au bout, vous aurez de quoi vous amuser. Et je tenterais d'aller plus loin pour les prochains articles (cf. fin de cet article).

*Par avance, désolé, je ne fait aucune gestion d'erreur, j'utilise les id dans mon code html, etc. …*

Bon, on s'y colle. J'ai appelé mon application **stykkekode** qui veut dire "bout de code" en norvégien.

##Installation côté serveur

###Pré-requis

Tout d'abord, vous devez installer **Nodejs** : [http://nodejs.org/#download](http://nodejs.org/#download), l'installeur en profite pour installer **npm** (node package manager), ce qui nous permettra d'installer le reste des composants.

Une fois **Nodejs** installé, nous allons installer **Express.js** ([http://expressjs.com/](http://expressjs.com/)), "petit" framework un peu dans le même esprit que **Play!>** qui permet de générer des applications web sous **Nodejs**.

Pour installer **Express.js**, ouvrez un terminal et tapez la commande suivante :

	npm install -g express

Ensuite nous allons générer le squelette de notre application :

	express stykkekode

Puis installer les dépendances :

	cd stykkekode
	npm install -d

Puis installer le moteur de template **ejs** : (express "arrive" avec le moteur **jade**, mais **ejs** à l'avantage de permettre l'utilisation de code html, ce qui permet de ne pas être trop perdu)

	npm install ejs

Ensuite, je vous conseille d'installer **nodemon** ([https://github.com/remy/nodemon](https://github.com/remy/nodemon)) qui démarre, arrête et redémarre automatiquement pour vous, votre application à chaque fois qu'il détecte un changement dans le code source (en fait à chaque fois que vous sauvegardez).

**Express.js** a généré pour vous tout le squelette et le code de départ de votre application (vous irez voir par vous même l'arborescence générée), pour lancer votre application il faudra, dans le répertoire de celle ci, tapez la commande `nodemon app.js`, où `app.js` et le script principal généré par **Express.js**.

**WARNING :** Dans le reste de l'article, je l'ai renommé `server.js` (c'est pour une question technique d'hébergement que je suis en train de tester). Donc vous même, n'oubliez pas de renommer `app.js` en `server.js`.

Voilà, voilà, nous pouvons commencer.

##1ère view & 1ère route … 1er contrôleur

Aller dans le répertoire `views`, et créer 2 fichiers `index.ejs` et `layout.ejs`

Dans `layout.ejs` saisissez le code suivant :

{% highlight html %}
	<html>
		<head>
			<title>styKKeKode</title>
		</head>
	 	<%- body %>
	</html>
{% endhighlight %}

Dans `index.ejs` saisissez le code suivant :

{% highlight html %}
	<H1>styKKeKode</H1>

	<% if (message) { %>
		<h2><%= message %></h2>
	<% } %>
{% endhighlight %}

si vous allez dans `server.js` (ou `app.js`) vous trouverez la ligne suivante :

	app.get('/', routes.index);

Qu'est ce que ça fait ? Dès que vous appeler votre "domaine" dans l'url (la page principale) c'est la méthode `index` de `routes` qui est appelée. Et vous trouvez l'implémentation de cette méthode dans `/routes/index.js`, que nous allons tout de suite modifier.
Remplacer le code de `/routes/index.js` par :

{% highlight javascript %}
	/*
	 * GET home page.
	 */

	exports.index = function(req, res){
	  res.render('index.ejs', { message : 'soon …' })
	};
{% endhighlight %}

On peut considérer que c'est l'équivalent de nos contrôleurs Java.

Donc à chaque appel de `http://localhost:3000/` vous serez redirigé vers la view/vue `index.ejs`. **Et on passe la variable message à la vue index.ejs**. Vous notez que je précise l'extension de la vue, cela signifie que l'on peut utiliser plusieurs moteurs de template dans la même application.

Pour essayer :

- ouvrez un terminal, positionnez vous dans le répertoire de votre application et tapez : `nodemon server.js`
- appelez `http://localhost:3000/` dans votre navigateur

Nous avons donc rapidement vu les aspects, routes, vue et contrôleur, nous reviendrons plus en détail dessus, mais maintenant, allons un peu plus loin dans la construction de notre "stack".

##Installer les librairies javascript

… Cela va nous servir pour plus tard

Dans le répertoire `public/javascripts` copiez les librairies suivantes :

- `underscore.js`, nécessaire pour faire tourner `backbone.js` : [http://documentcloud.github.com/underscore/](http://documentcloud.github.com/underscore/)
- jquery.js : [http://docs.jquery.com/Downloading_jQuery](http://docs.jquery.com/Downloading_jQuery)
- `backbone.js` : [http://documentcloud.github.com/backbone/](http://documentcloud.github.com/backbone/)
- `tempo.js` : moteur de template côté client, simple, mais puissant (+ que mustache) : [http://tempojs.com/](http://tempojs.com/)
- `showdown.js` : qui permet de transformer des chaînes au format markdown en code html [https://github.com/coreyti/showdown/tree/master/src](https://github.com/coreyti/showdown/tree/master/src)
- `highlight.min.js` : librairie magique qui permet de "coloriser" le code dans les pages html [http://softwaremaniacs.org/soft/highlight/en/](http://softwaremaniacs.org/soft/highlight/en/)

Dans le répertoire `public/stylesheets` copiez les css suivantes :

- `bootstrap.css` ([http://twitter.github.com/bootstrap/](http://twitter.github.com/bootstrap/))
- ainsi que `bootstrap-responsive.css`
- `default.min.css` la  feuille de style qui "vient" avec `highlight.min.js`

Twitter Bootstrap nous permettra de donner une "bonne tête" à notre application, sans effort.


Allons ensuite déclarer les librairies javascript dans `views/index.ejs` :

{% highlight html %}
	<H1>styKKeKode</H1>

	<% if (message) { %>
		<h2><%= message %></h2>
	<% } %>


	<!-- js libs client -->
	<script src="javascripts/jquery.js"></script>
	<script src="javascripts/underscore.js"></script>
	<script src="javascripts/backbone.js"></script>
	<script src="javascripts/tempo.js"></script>
	<script src="javascripts/showdown.js"></script>
{% endhighlight %}

Puis les feuilles de styles dans `views/layout.ejs` :

{% highlight html %}
	<html>
		<head>
			<title>styKKeKode</title>
			<link rel="stylesheet" href="stylesheets/bootstrap.css">
			<link rel="stylesheet" href="stylesheets/bootstrap-responsive.css">
	    	<link rel="stylesheet" href="stylesheets/default.min.css">
            <style type="text/css">
                body {
                    padding-top: 60px;
                    padding-bottom: 40px;
                }
                .sidebar-nav {
                    padding: 9px 0;
                }
            </style>
		</head>
		 <%- body %>
	</html>
{% endhighlight %}

##Les modèles

On ne vas pas s'occuper tout de suite de la persistance, mais nous allons créer des modèles et simuler cette persistance dans un 1er temps.

Créer dans votre répertoire applicatif un répertoire `models` sans lequel vous allez ajouter un fichier `snippet.js` qui sera donc notre modèle, avec le code suivant :

{% highlight javascript %}
	/* SNIPPET MODEL */
	var snippetsCounter = 1;

	var snippet = function(title, code, user) {
		this.id = null;
		this.title = title ? title : "";
		this.code = code ? code : "";
		this.user = user ? user : "";
	}

	//static
	snippet.list = [];

	snippet.prototype.save = function(callBack) {
		if(this.id === undefined || this.id === null || this.id === "") {
		//new snippet to save

			//Je ré-initialise tous les 5 snippets
			if(snippetsCounter > 5) {
				snippet.list = [];
				snippetsCounter = 1;
			}

			this.id = snippetsCounter++;

			snippet.list.push(this)
		} else {//snippet exists => to be updated in list
			var
				that = this,
				tmp = snippet.list.filter(function(record){ return record.id === that.id; })[0];
				if(tmp){
					snippet.list.splice(snippet.list.indexOf(this), 1);
					snippet.list.push(this) ;
				}
		}

		callBack(this);
	};

	snippet.prototype.delete = function(callBack) {
		var
			that = this,
	    	tmp = snippet.list.filter(function(record){ return record.id === that.id; })[0];
	    	if(tmp){
	    		snippet.list.splice(snippet.list.indexOf(this), 1);
	    	}
	    callBack(this);
	}

	//static
	snippet.findAll = function(callBack) {
		callBack(snippet.list);
	}

	//static
	snippet.findById = function(id, callBack) {
		var tmp = snippet.list.filter(function(record){ return record.id === id; })[0];
		console.log("snippet.findById", tmp)
		callBack(tmp);
	}


	/*=== Bootstrap with data ===*/

	var snippet_one = new snippet("essai 1","//FOO","k33g_org");
	var snippet_tow = new snippet("essai 2","//Hello World","k33g_org");
	var snippet_three = new snippet("essai 3","//Me again !","k33g_org");

	snippet_one.save(function(m){console.log(m);});
	snippet_tow.save(function(m){console.log(m);});
	snippet_three.save(function(m){console.log(m);});

	exports.snippet = snippet;
{% endhighlight %}

Dans `routes/index.js`, ajoutez la ligne suivante en tout début de fichier (on fait un include) :

	var snippet = require('../models/snippet').snippet;

Sauvegardez. Si votre application tourne encore (sinon relancez) vous pourrez voir dans la console la liste des données "bootstrapées".

![Alt "express01.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express01.png)

Maintenant allons écrire quelques routes et contrôleur(s)

##Routes et Contrôleurs

###Routes

Préparons le travail pour Backbone.

Allez dans `server.js` (ou `app.js`) et copiez les routes suivantes (juste après `app.get('/', routes.index);`) :

{% highlight javascript %}
	app.post("/snippet", routes.createSnippet);
	app.put("/snippet", routes.updateSnippet);
	app.get("/snippet", routes.getSnippet);
	app.del("/snippet", routes.deleteSnippet);

	app.get("/snippets", routes.allSnippets);
{% endhighlight %}

###Contrôleurs

Allez dans `routes/index.js` et modifiez le code comme ceci :

{% highlight javascript %}
	var snippet = require('../models/snippet').snippet;

	/*
	 * GET home page.
	 */

	exports.index = function(req, res){
	  res.render('index.ejs', { message : 'soon …' });
	};


	exports.createSnippet = function(req, res) {
		console.log("CREATE SNIPPET");

		var model_from_client = JSON.parse(req.param("model", null));
		console.log(model_from_client);

		var server_model = new snippet(model_from_client.title, model_from_client.code, model_from_client.user);

		server_model.save(function(m){
			console.log(m);
			res.json(m);
		});

	};

	exports.updateSnippet = function(req, res) {
		console.log("UPDATE SNIPPET");

		var model_from_client = JSON.parse(req.param("model", null));
		console.log(model_from_client);

		var server_model = new snippet(model_from_client.title, model_from_client.code, model_from_client.user);

		server_model.id = model_from_client.id;

		server_model.save(function(m){
			console.log(m);
			res.json(m);
		});


	};

	exports.getSnippet = function(req, res) {
		console.log("GET SNIPPET");

		var model_from_client = JSON.parse(req.param("model", null));
		console.log(model_from_client);

		var server_model = snippet.findById(model_from_client.id, function(m) {
			console.log(m);
			res.json(m);
		});

	};

	exports.deleteSnippet = function(req, res) {
		console.log("DELETE SNIPPET");
		var model_from_client = JSON.parse(req.param("model", null));
		console.log(model_from_client);

		var server_model = snippet.findById(model_from_client.id, function(model) {
			console.log(model);

			model.delete(function(m){
				res.json(m);
			});
		});


	};

	exports.allSnippets = function(req, res) {
		console.log("ALL SNIPPETS");

	  	snippet.findAll(function(snippets){
			res.json(snippets);
		});
	};
{% endhighlight %}

###Testons :

Allez dans votre navigateur, ouvrez la console, et essayez les commandes suivantes :

####createSnippet

{% highlight javascript %}
	$.ajax({
		type: "POST",
		url: "/snippet",
		data: {"model":JSON.stringify({
			title:"Hello World in Kotlin",
			code : "println('Hello world')",
			user : "@BobMorane"
		})},
		dataType: 'json',
		error: function () {
			console.log("oups");
		},
		success: function (dataFromServer) {
			console.log(dataFromServer);
		}
	});
{% endhighlight %}

![Alt "express02.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express02.png)

on peut voir que le serveur nous a affecté un id

####updateSnippet

{% highlight javascript %}
	$.ajax({
		type: "PUT",
		url: "/snippet",
		data: {"model":JSON.stringify({
			id : 4, /*vérifier que l'id existe*/
			title:"Hello World in Kotlin",
			code : "println('Hello world $name')",
			user : "@BOBMORANE"
		})},
		dataType: 'json',
		error: function () {
			console.log("oups");
		},
		success: function (dataFromServer) {
			console.log(dataFromServer);
		}
	});
{% endhighlight %}

![Alt "express03.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express03.png)

Le serveur nous a renvoyé notre modèle modifié

####getSnippet

{% highlight javascript %}
	$.ajax({
		type: "GET",
		url: "/snippet",
		data: {"model":JSON.stringify({id:1})},
		dataType: 'json',
		error: function () {
			console.log("oups");
		},
		success: function (dataFromServer) {
			console.log(dataFromServer);
		}
	});
{% endhighlight %}

![Alt "express04.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express04.png)

Le serveur nous a renvoyé le modèle ayant l'id 1

####deleteSnippet

{% highlight javascript %}
	$.ajax({
		type: "DELETE",
		url: "/snippet",
		data: {"model":JSON.stringify({id:1})},
		dataType: 'json',
		error: function () {
			console.log("oups");
		},
		success: function (dataFromServer) {
			console.log(dataFromServer);
		}
	});
{% endhighlight %}

![Alt "express05.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express05.png)

Et maintenant nous allons appeler la liste de l'ensemble de nos "snippets" pour vérifier que nos modifications ont bien été prises en compte.

####allSnippets

{% highlight javascript %}
	$.ajax({
		type: "GET",
		url: "/snippets",
		data: null,
		dataType: 'json',
		error: function () {
			console.log("oups");
		},
		success: function (dataFromServer) {
			dataFromServer.forEach(function(model){
				console.log(model)
			});
		}
	});
{% endhighlight %}

![Alt "express06.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express06.png)

##Mise en musique avec BackBone.js

###On re-écrit Backbone.sync

Vous devez donc créer un fichier `backbone.sync.js` au même endroit que `backbone.js` :

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
	            dataForServer:null
	        } else {//c'est un modèle

	            dataForServer = { model : JSON.stringify(model.toJSON()) };

	            console.log(dataForServer);
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
					if(!model.models){
						dataFromServer.id = dataFromServer._id;
						console.log(dataFromServer);
					} else {
						//collection
						dataFromServer.reverse();
					}
	                options.success(dataFromServer);
	            }
	        });
	    };
	})();
{% endhighlight %}

Il faudra penser à ajouter dans 'index.ejs' :

	<script src="javascripts/backbone.sync.js"></script>


Nous allons donc modifier la vue `index.ejs` :

###HTML

{% highlight html %}
	<!-- ma barre de titre -->
	<div class="navbar navbar-fixed-top">
		<div class="navbar-inner">
			<div class="container">

				<a class="brand" href="#">styKKeKode
					<% if (message) { %>
						<%= message %>
					<% } %>
				</a>

	        </div>
		</div>
	</div>

	<div class="container">

		<!-- mon formulaire de saisie -->
	   	<div id="snippet-form">
	   		<h2>Go ...</h2>
	       <form action="/" class="well">
	       		<label>Title : </label>
	           	<input id="title" type="text" class="span3" placeholder="title"/>
	           	<label>Code Snippet : (with markdown) </label>
	           	<textarea id="code" placeholder="code" style="width:100%" rows="5"></textarea>
	           	<label>User : </label>
	           	<input id="user" type="text" placeholder="user"/>
	           	<button type="submit" class="btn">Ajouter un Snippet</button>
	           	<!--<input type="submit" value="Ajouter un Snippet" />-->
	       </form>
	   	</div>

		<ul id="snippet-list" style="list-style: none;">
	       <li data-template>
	       	<h2>{{title}} by {{user}}</h2><br>
	       	{{code}}<hr>
	       </li>
	   	</ul>

	</div>

	<!-- js libs client -->
	<script src="javascripts/jquery.js"></script>
	<script src="javascripts/underscore.js"></script>
	<script src="javascripts/backbone.js"></script>
	<script src="javascripts/backbone.sync.js"></script>
	<script src="javascripts/tempo.js"></script>
	<script src="javascripts/showdown.js"></script>
	<script src="javascripts/highlight.min.js"></script>
{% endhighlight %}


###Javascript (Backbone & co)

Donc à la suite :

{% highlight html %}
	<!-- Application BackBone -->

	<script type="text/javascript">
		$(document).ready(function() {

	        window.Snippet = Backbone.Model.extend({
	            url : 'snippet',
	            defaults : {
	                id: null,
	                title : "",
	                code : "",
					user : ""
	            }
	        });

	        window.Snippets = Backbone.Collection.extend({
	            model : Snippet,
	            url : 'snippets'
	        });

			/*=== VIEWS ===*/
			window.SnippetsView = Backbone.View.extend({

		        initialize : function() {
		            this.template = Tempo.prepare('snippet-list');
		        },

		        render : function() {
		            this.template.render(this.collection.toJSON());
		            return this;
		        }

		    });


			window.converter = new Showdown.converter();

			window.SnippetFormView = Backbone.View.extend({
		        el : $('#snippet-form'),

		        initialize : function() {
		            this.form = arguments[0].form;
		        },
		        events : {
		            'submit form' : 'addSnippet'
		        },
		        addSnippet : function(e) {
		            e.preventDefault();
					var that = this;
					var tmpSnippet = new Snippet({
						title : this.$('#title').val(),
						code : converter.makeHtml(this.$('#code').val()),
						user : this.$('#user').val()
					});

					tmpSnippet.save({},{
						success : function() {
							that.collection.fetch({
								success: function() {
									that.form .render();
									$('pre code').each(function(index,e) {hljs.highlightBlock(e, '    ')});
								}
							})
						}
					});
					//on vide le form
		            this.$('input[type="text"]').val('');
		            this.$('textarea').val('');
		        },
		        error : function(model, error) {
		            console.log(model, error);
		            return this;
		        }

		    });

			/*=== ROUTER ===*/

		    window.SnippetsRouter = Backbone.Router.extend({

		        initialize : function() {
		            /* 1- Création d'une collection */
		            window.snippets = new Snippets();
					this.collection = snippets;
					var that = this;
		            /* 2- Chargement de la collection */
		            snippets.fetch({
						success:function() {
							/* 3- Création des vues + affichage */
							window.snippetsView = new SnippetsView({ collection : snippets });
							window.snippetForm = new SnippetFormView({ collection : snippets, form : snippetsView });
							snippetsView.render();
							/*4- un peu de couleur */
							$('pre code').each(function(index,e) {hljs.highlightBlock(e, '    ')});

						},
						error:function(){

						}
					});

		        },
				routes : {}

		    });

	        /*--- initialisation du router ---*/

	        router = new SnippetsRouter();

	    });
	</script>
{% endhighlight %}

**Remarques :**

- `window.converter = new Showdown.converter();` et `converter.makeHtml(this.$('#code').val())` servent à transformer le code markdown saisi en code html
- `$('pre code').each(function(index,e) {hljs.highlightBlock(e, '    ')});` sert à "coloriser" les parties "code source"


###Allez on teste :

- Vérifiez que votre application est lancée
- Ouvrez l'url `localhost:3000/` dans votre navigateur

![Alt "express07.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express07.png)

On voit que l'on a encore nos données "bootstrapées".

Saisissons des données au format markdown :

![Alt "express08.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express08.png)

On ajoute et on obtient :

![Alt "express09.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express09.png)

Vous pouvez allez vérifier dans un autre navigateur que vos données sont bien là.


##That's all ...

Pour aujourd'hui, mais la prochaine fois, nous verrons comment "socialiser" notre application : seules les personnes authentifiées avec Twitter, pourront saisir des snippets. Nous mettrons quelques contrôles de validation. Et enfin (pas forcément dans le même article), nous verrons comment ajouter une véritable persistance avec une base NOSQL (je n'ai pas encore fait mon choix, mais j'ai un gros penchant pour CouchDB).

Si vous voulez voir tourner l'application "en vrai", je l'ai hébergée ici : [http://stykkekode.cloudno.de/](http://stykkekode.cloudno.de/).

@+ & Bon code.











