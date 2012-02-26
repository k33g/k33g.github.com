---

layout: post
title: stykkekode la suite
info : stykkekode la suite

---

#Express.js, le Play!>Framework du Javascript ? La suite ...

Aujourd'hui, ce sera l'authentification twitter, mais tout d'abord un peu de cosmétique.

##Codemirror

Etant donné que nous saisissons du markdown, allons jusqu'au bout et proposons un éditeur de code avec un peu de couleur. Pour cela nous allons utiliser CodeMirror, un éditeur de code en js assez sympa à utiliser (et surtout facile à utiliser) : [http://codemirror.net/](http://codemirror.net/)

###Installation

Il faut récupérer ici : [https://github.com/marijnh/CodeMirror2](https://github.com/marijnh/CodeMirror2)

- `codemirror.js`, que vous aller copier dans `public/javascripts`
- le mode markdown de codemirror : `markdown.js` , que vous aller copier dans `public/javascripts`
- ainsi que `xml.js` (encore dans `public/javascripts`)

puis dans `public/stylesheets` :

- `codemirror.css`
- `rubyblue.css` (le thème)

###Utilisation

Dans `/views/layout.ejs`, ajouter les références aux feuilles de style :

	<html>
		<head>
			<title>styKKeKode</title>
			<link rel="stylesheet" href="stylesheets/bootstrap.css">
			<link rel="stylesheet" href="stylesheets/bootstrap-responsive.css">
			<link rel="stylesheet" href="stylesheets/default.min.css">
			<link rel="stylesheet" href="stylesheets/codemirror.css">
			<link rel="stylesheet" href="stylesheets/rubyblue.css">
			<style type="text/css">
		  		body {
					padding-top: 60px;
					padding-bottom: 40px;
		  		}
		  		.sidebar-nav {
					padding: 9px 0;
		  		}
			</style>
			<style type="text/css">
				.CodeMirror {border-top: 1px solid gray; border-bottom: 1px solid gray;}
				pre { color:white; }
			</style>
		</head>
		 <%- body %>
	</html>

**Remarque :** j'ai modifié(surcharché) `.CodeMirror` (vous n'êtes pas obligé) et changé l'attribut `color` de `pre` (il y avait un "conflit de couleurs" avec bootstrap)

On retourne dans `/views/index.ejs`,

####HTML :

Dans notre formulaire html, il n'y a pas grand chose qui change, nous allons juste ajouter un "compteur" pour le nombre de caractères à saisir :

	<!-- mon formulaire de saisie -->
	<div id="snippet-form">
		<h2>Go ...</h2>
	   <form action="/" class="well">
			<label>Title : </label>
			<input id="title" type="text" class="span3" style="width:100%" placeholder="title"/>
			<label>Code Snippet : (with markdown) </label>
			<textarea id="code" placeholder="code" style="width:100%" rows="5"></textarea>

			<!-- on ajoute un compteur -->
				<b><div id="counter">0/1455</div></b>
			<!-- -->

			<label>User : </label>
			<input id="user" type="text" placeholder="user"/>
			<button id="postsnippet" type="submit" class="btn">Ajouter un Snippet</button>
			<!--<input type="submit" value="Ajouter un Snippet" />-->
	   </form>
	</div>

####Javascript :

Là on on a un peu plus de boulot :

Premièrement, pensez à ajouter les références au librairies codemirror :

	<script src="javascripts/codemirror.js"></script>
	<script src="javascripts/xml.js"></script>
	<script src="javascripts/markdown.js"></script>

Ensuite, on ajoute le code nécessaire :

Juste après `$(document).ready(function() { ` ajouter ceci :

	//le compteur
	var counter = $("#counter");

	//une référence à notre bouton d'ajout
	var postSnippetButton = $("#postsnippet");

	counter.css("color","green");

	//on transforme notre textarea en super éditeur de code
	window.editor = CodeMirror.fromTextArea(document.getElementById("code"), {
		mode: 'markdown',
		lineNumbers: true,
		matchBrackets: true,
		indentUnit : 4,
		theme: "rubyblue",
		lineWrapping : true,
		//on vérifie que l'on ne saisi pas plus de 1455 caractère
		//il faudra quand même vérifier aussi côté serveur
		onChange : function() {
			counter.html(editor.getValue().length + "/1455");
			if(editor.getValue().length > 1455) {
				counter.css("color","red");
				postSnippetButton.hide();
			} else {
				postSnippetButton.show();
				counter.css("color","green");
			}
		}
	});
	editor.getScrollerElement().style.height = "170px";
	editor.getGutterElement().style.height = "170px";

Une dernière petite modification : dans notre vue `window.SnippetFormView`, nous allons modifier le code qui permet de récupérer la saisie faites dans la textarea, puis de vider celle-ci. Remplacez donc :

- `code : converter.makeHtml(this.$('#code').val())` par `code : converter.makeHtml(editor.getValue())`
- et `this.$('textarea').val('')` par `editor.setValue('')`

Et voilà pour la partie cosmétique, si tout va bien vous devriez obtenir ceci :

![Alt "express10.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express10.png)


##Authentification Twitter

Pour cette partie, je dois reconnaître que cela m'a pris un peu plus de temps. Alors je ne fais pas le tour complet de l'authentification via Twitter, mais ça devrait vous donner assez de billes pour creuser plus loin.
L'objectif de cette partie est le suivant :

- pouvoir s'authentifier via Twitter
- ne pouvoir poster qu'une fois autentifié

###Pré-requis

Nous n'allons pas ré-inventer la roue (je ne suis même pas sûr d'y arriver), pour gérer les sessions et s'authentifier avec un compte de rseau social, il existe l'excellente librairie **everyauth** : [https://github.com/bnoguchi/everyauth](https://github.com/bnoguchi/everyauth). Je n'ai rien fait de génial, je me suis juste inspirré des codes d'exemples [https://github.com/bnoguchi/everyauth/blob/master/example/server.js](https://github.com/bnoguchi/everyauth/blob/master/example/server.js) (j'ai juste customisé à ma sauce).

- aller dans le répertoire de votre application : `cd stykkekode`
- tapez la commande `npm install everyauth`

####Aller enregistrer son application chez Twitter

- aller sur le site des développeurs : [https://dev.twitter.com/](https://dev.twitter.com/)
- "signer" vous
- sélectionnez "Create an App" : [https://dev.twitter.com/apps/new](https://dev.twitter.com/apps/new)

Voici comment j'ai rempli les informations :

- Name : `stykkekode_dev`
- Description : `tutorial about authentication with express.js`
- Website : `http://dev.k33g.org` (pour le moment vous n'avez pas à mettre un véritable nom de domaine)
- Callback URL : `http://dev.k33g.org:3000/auth/twitter/callback` (il est important de garder le même nom de domaine)
- Acceptez les conditions d'utilisation
- Clickez sur "Create your twitter application"
- Votre application vient d'être créée
- Notez quelque part dans un fichier votre **Consumer key** et votre **Consumer secret**

Ensuite :

- Clickez sur "Create my access token"

####Paramétrer son poste : "fake http://dev.k33g.org"

En mode commande, tapez : `sudo pico /etc/hosts` et ajoutez la ligne suivante :

	127.0.0.1       dev.k33g.org

Et sauvegardez, puis quittez.

Donc à partir de maintenant, si vous lancez votre application : `nodemon server.js `
et que vous tapez l'url [http://dev.k33g.org:3000/](http://dev.k33g.org:3000/) vous serez dirigés sur votre application locale.
Et donc cela va vous permettre de tester le callback de twitter en local

... ça c'est fait.

Retournons maintenant dans le code.


###Déclaration et paramétrage de everyauth

Nous allons tout d'abord créer un fichier `config.js` à la racine de l'application. Et nous allons renseigner dans ce fichier les informations nécessaires à la connexion avex Twitter :

	module.exports = {
		twit: {
			consumerKey: 'ICI VOTRE CONSUMER KEY'
		  , consumerSecret: 'ICI VOTRE CONSUMER SECRET'
		}
	};

Ensuite allons dans `server.js` :

Ajoutons les références à everyauth et config.js :

	var express = require('express')
	  , routes = require('./routes')
	  ,	everyauth = require('everyauth')    /* AUTHENTICATION */
	  , conf = require('./config');         /* AUTHENTICATION */

	everyauth.debug = true;

Dans la partie "Configuration", modifier de la manière suivante : (on utilise le mécanisme de gestion de session d'everyauth)

	app.configure(function(){
		/* === start of authentication === */
		app.use(express.cookieParser());
		app.use(express.session({
			secret:'bobmorane',
			"store":  new express.session.MemoryStore({ reapInterval: 60000 * 10 })
		}));
		app.use(everyauth.middleware());
		/* === end of authentication === */

		app.set('views', __dirname + '/views');
		app.set('view engine', 'jade');
		app.use(express.bodyParser());
		app.use(express.methodOverride());
		app.use(app.router);
		app.use(express.static(__dirname + '/public'));
	});

En fin de fichier juste avant `app.listen(3000);` ajouter `everyauth.helpExpress(app);`

	everyauth.helpExpress(app);
	app.listen(3000);


###Utilisation d'everyauth

####Modèle "user"

Premièrement, allez créer un "model" `user.js` dans le répertoire `models` avec le code suivant

	/* USER MODEL */

	var user = function(id, source, sourceUser) {
		console.log("New User : ", id, source);
		this.id;
		this.source = source;
		this.sourceUser = sourceUser;
	}

	//static members

	user.listById = {};
	user.twitterListById = {};
	/*
		user.list : tous les users quel que soit le mode d'authentification
		user.twitterList : les users authentifiés via twitter
		everyauth permet de nombreux modes d'authentification (google par exemple)
		cela permettra d'ajouter d'autres modes si on le souhaite
	 */
	user.nextUserId = 0;

	//static methods
	user.add = function(source, sourceUser) {
		user.nextUserId+=1;
		var authenticatedUser = new user(user.nextUserId, source, sourceUser);
		console.log("#################################");
		console.log(authenticatedUser);
		console.log("#################################");
		user.listById[authenticatedUser.id] = authenticatedUser;
		return authenticatedUser;
	};

	user.findById = function(id) {
		return user.listById[id];
	};

	user.findByTwitterId = function(id) {
		return user.twitterListById[id];
	};

	exports.user = user;


####Utilisation dans server.js

Entre `var app = module.exports = express.createServer();` et `app.configure(...)` ajoutez :

	/* === start of authentication === */

	var user = require('./models/user').user;

	//toujours surcharger ceci :
	everyauth.everymodule
		.findUserById( function (id, callback) {
			callback(null, user.findById(id));
		});

	//s'authentifier chez twitter
	everyauth
		.twitter
		.consumerKey(conf.twit.consumerKey)
		.consumerSecret(conf.twit.consumerSecret)
		.findOrCreateUser( function (sess, accessToken, accessSecret, twitUser) {

			var tmp = user.findByTwitterId(twitUser.id);
			if(tmp) {
				// ne rien faire
			} else {
				tmp = user.add('twitter', twitUser);
				user.twitterListById[twitUser.id] = tmp;
			}

			return tmp;
		})
		.redirectPath('/'); //une fois authentifié rediriger vers "/"


	/* === end of authentication === */


####Utilisation dans la vue index.ejs

Ajoutons un peu de code à notre vue juste après `<div class="container">` :

<script src="https://gist.github.com/1914862.js"> </script>

Donc si vous n'êtes pas authentifié dans twitter, cela vous affichera un lien pour aller vous connecter. Une fois authentifié cela affichera les infos twitter de votre compte. On teste :

- relancez votre application : `nodemon server.js`
- si vous êtes connecté à twitter dans votre navigateur, déconnectez vous (c'est mieux pour le test)

Vous devriez obtenir ceci :

![Alt "express11.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express11.png)

Authentifiez vous :

![Alt "express12.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express12.png)

Vous êtes redirigé vers votre application :

![Alt "express13.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express13.png)

C'est cool ça fonctionne (en tous cas chez moi, c'est ok) mais ce n'est pas beau.

###Derniers réglages

Toujours dans `index.ejs` on modifie le code précédent :

<script src="https://gist.github.com/1914881.js"> </script>

Puis, vous modifiez le code html pour ne permettre de poster qu'une fois authentifié (le bouton n'apparaît que si vous êtes authentifié) :

<script src="https://gist.github.com/1914883.js"> </script>

Et pensez à déactiver le "vidage" des zones de texte (on veut conserver le pseudo utilisateur) :

	//this.$('input[type="text"]').val('');

et remplacez par :

	this.$('#title').val('');

(oui, je sais, les id cémal)

Et enfin, vous pouvez testez : juste raffraîchir la page, ça devrait suffire : **Tada !!!**

![Alt "express14.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express14.png)

Voilà, vous avez de quoi vous amuser. Vous pouvez tester l'application en vrai ici : [http://stykkekode.cloudno.de/](http://stykkekode.cloudno.de/).

Et pour la prochaine fois, nous verrons comment utiliser **CouchDB** pour sauvegarder et retrouver les messages.

Bon dimanche à tous.