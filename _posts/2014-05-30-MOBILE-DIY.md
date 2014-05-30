---

layout: post
title: Web Mobile, faîtes votre framework!
info : Web Mobile, faîtes votre framework!

---

#Web Mobile, faîtes votre framework!

Hier, je vous parlais des possibilités de Chrome pour Android. Il est très possible vous l'avez deviné de faire des webapps très fonctionnelles. Lorsque je fais de la veille à propos du web mobile, je tombe sur de nombreux frameworks (de différente qualité), mais un bon nombre d'entre-eux essayent de reproduire l'aspect natif du terminal mobile et souvent c'est malheureux (un petit côté "cheap"), surtout lors d'upgrade de l'OS qui change d'IHM. D'autres ne le font pas mais sont souvent très "typés".

Il y a de très bonnes applications natives qui ne reproduise pas l'aspect imposé par l'OS, par exemple **Evernote** qui est très reconnaissable et qui a son propre style.

De la même manière, je pense qu'une webapp doit être "freestyle".

Du coup mon petit exercice d'hier, m'a donné envie d'aller plus loin et de créer les bases d'un "walking-skeleton" mobile, en essayant de rester le plus sobre possible (je suis une bille en design) mais en fournissant un quick-start d'application "web" mobile. De plus il faudra qu'il reste le plus simple possible pour être "customisé/brandé" le plus facilement possible.

Dans un 1er temps, je viserais essentiellement la plateforme Android, mais les adaptations pou iOS sont prévues. Cet article n'est que le début.

Aujourd'hui, je souhaite juste avoir le cadre de base pour:

- afficher du html correctement au format mobile 
- avoir une barre de titre "fixe" (le contenu en dessous peut scroller)
- s'afficher en plein écran comme une application
- avoir une icône pour le lancer

la prochaine fois, je tenterais d'angulariser mon projet.

##Côté html

Dans un répertoire, créez 2 sous-répertoires `js` et `css`, dans `js` créez un fichier `kiss.js` et dans `css` créez un fichier `kiss.css`.

A la racine du répertoire, créez une page `index.html` avec le contenu suivant:

{% highlight html %}
<!DOCTYPE html>
<html>
<head lang="en">
  <meta charset="UTF-8">
{% endhighlight %}

Les attributs de `<meta name="viewport"/>` permettent d'afficher le texte à la bonne échelle. `user-scalable=0` empêchera l'utilisateur de zoomer sur le contenu de la webapp, ou le système comme par exemple lors du focus d'une zone texte.

{% highlight html %}
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
{% endhighlight %}

Cette portion permet d'affecter une icône au raccourcis de notre webapp (voir l'article précédent ["Chrome Android et les Webapps"](http://k33g.github.io/2014/05/29/ANDROID-WEBAPP.html)).

{% highlight html %}
  <link rel="icon" sizes="196x196" href="html5.png">
{% endhighlight %}

Cette portion permettra l'affichage en plein écran (sans la barre d'url du navigateur):

{% highlight html %}
  <meta name="mobile-web-app-capable" content="yes">
{% endhighlight %}

Ensuite nous décrivons notre IHM:

{% highlight html %}
  <title>kiss</title>
  <link rel="stylesheet" href="css/kiss.css">
</head>
<body>

  <header>
    <a href="#home" class="title">KISS</a>
  </header>

  <div id="main" class="card">
    <p> Main Page</p>
    <p><a name="go_to_second" href="#second">next screen ...</a></p>
  </div>

  <div id="second" class="card">
    <p>Cras mattis consectetur purus sit amet fermentum.</p>
    <p><a name="go_to_first" href="#first">previous screen ...</a></p>
    <form id="informations" onsubmit="return false;"> <ul>
      <li><input type="text" name="firstName" placeholder="FirstName"/></li>
      <li><input type="text" name="lastName" placeholder="LastName"/></li>
      <li><textarea name="about" placeholder="About you" rows="5"></textarea></li>
      <li class="no-border"><input type="submit" name="Save" /></li> </ul>
    </form>
  </div>

  <script src="js/kiss.js"></script>
</body>
</html>
{% endhighlight %}

##Coté css

Dans le fichier `kiss.css`, nous avons:

Des styles pour les éléments de base:

{% highlight css %}
body {
  margin: 0px;
  min-height: 480px;
  font-family: Arial;
}

p {
  padding: 6px;
}

a:active,
a:hover {
  outline: 0;
}
{% endhighlight %}

Des styles liés aux formulaires et aux listes afin de pouvoir facilement positionné les élément du formulaire avec des tags `<li></li>`:

{% highlight css %}
form ul {
  margin: 0px;
  padding: 6px;
  list-style-type: none;
}
form ul li {
  margin: 0 0 4px 0;
  -webkit-border-radius: 4px;
  border: 1px solid #979797;
  padding: 4px;
}
form ul li.no-border {
  -webkit-border-radius: 0px;
  border: 0;
  padding: 0;
}

input {
  font-size: 0.9em;
  -webkit-appearance: none;
  border: 0;
  width: 95%;
}
textarea {
  font-size: 0.9em;
  -webkit-appearance: none;
  border: 0;
  width: 99%;
}

input[type=submit] {
  font-size: 0.9em;
  border: 1px solid #AAAAAA;
  background: #AAAAAA;
  -webkit-border-radius: 6px;
  width: 100%;
  padding: 6px;
}
{% endhighlight %}

Ensuite, **la partie importante**, ce qui va nous permettre d'avoir un barre de titre "fixe":

{% highlight css %}
header {
  position: fixed;
  z-index: 3;
  width: 100%;
  left: 0;
  top: 0;
  padding: 6px;
  background: #333333;
  color: #AAAAAA;
  border-bottom: 4px solid #205eaa;
  margin: 0 0 4px 0;
}
{% endhighlight %}

La possibilité de styler un lien `<a>` pour en faire un titre dans la barre de titre:

{% highlight css %}
a.title {
  -webkit-tap-highlight-color: rgba(0,0,0,0);
  text-decoration: none;
  font-weight: bold;
  color: #fff;
  float: left;
}
{% endhighlight %}

Et enfin, pour les "cards" qui représenteront les différents écrans de notre application:

{% highlight css %}
div.card {
  margin-top: 40px;
  display: none;
  padding: 0px;
}

div#main {
  display: block;
}
{% endhighlight %}

Ces 2 derniers styles signifient qu'au chargement de la page `index.html`:

- `<div id="main" class="card"></div>` est visible (`div#main {display: block;}`)
- `<div id="second" class="card">` n'est pas affiché (`display: none;`)

##Côté javascript

Je n'ai pas voulu utiliser de framework pour le moment pour ne pas avoir d'effet de bord avec Angular pour la suite, donc le code va rester très simple:

{% highlight javascript %}
(function () {

  var $ = function(selector) {
    var all = [].slice.apply(document.querySelectorAll(selector));
    return {
      results: all,
      result: all[0]
    }
  }

  var firstScreen = $("#main").result;
  var secondScreen = $("#second").result;

  var linkGoToSecondScreen = $("a[name='go_to_second']").result;
  var linkGoToFirstScreen = $("a[name='go_to_first']").result;

  linkGoToSecondScreen.onclick = function() {
    firstScreen.style.display = "none";
    secondScreen.style.display = "block";
  }

  linkGoToFirstScreen.onclick = function() {
    secondScreen.style.display = "none";
    firstScreen.style.display = "block";
  }

}());
{% endhighlight %}

Nous avons donc:

- un pseudo sélecteur à la jquery avec l'astuce `[].slice.apply(document.querySelectorAll(selector));`
- ensuite nous attachons à l'événement `onclick` des liens, un traitement qui permet de changer l'attribut `display` des "cards" pour passer de l'une à l'autre.

Et c'est tout, et ça fonctionne. Je suis d'accord esthétiquement c'est pas le top, mais ça reste suffisamment simple pour laisser libre court à votre délire artistique.

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/webapp-01.jpg" height="40%" width="40%">

Vous trouverez le code ici [https://github.com/web-stacks/kiss-mobile](https://github.com/web-stacks/kiss-mobile).

à demain pour la suite