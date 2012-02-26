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

