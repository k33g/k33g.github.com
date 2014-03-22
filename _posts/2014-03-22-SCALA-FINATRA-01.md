---

layout: post
title: J'apprends Scala avec Finatra
info : J'apprends Scala avec Finatra

---

#J'apprends Scala avec Finatra: Part I

Je suis obligé de reconnaître que je "trolle" sur Scala sans réellement en faire. Mais à chaque fois que j'ai essayé dans faire, je trouvais ça un peu obscur. Il y a peu [@loic_d](https://twitter.com/loic_d), connaissant mon intérêt pour les micro-frameworks m'a poussé ce lien [http://finatra.info/](http://finatra.info/). **Finatra** est un micro-framework web en Scala réalisé chez **Twitter**. En lisant le code d'exemple sur la home page j'ai trouvé ça tout de suite très lisible. 

{% highlight scala %}
class HelloWorld extends Controller {
  
  get("/hello/:name") { request =>
    val name = request.routeParams.getOrElse("name", "default user")
    render.plain("hello " + name).toFuture
  }
}
{% endhighlight %}

**Tiens, on peut faire du code Scala pas ésotérique !?**. En allant faire un tour ici [Scala School](http://twitter.github.io/scala_school/) (toujours chez Twitter, tiens tiens!), cela semble se confirmer.

Du coup (et vu que de grosses boutiques s'y collent), je me suis dit "redonnons une chance à Scala" ... ou plutôt, je me redonne une chance de comprendre ;).

Je vais donc juste faire un petit rappel sur la manière de faire son premier projet Scala et sa première classe et ensuite nous passerons directement à la réalisation d'une application web avec **Finatra** avec un mini service json (mais mini mini).

Nous verrons aussi que nous pouvons facilement mettre en œuvre une fonctionnalité de rechargement et compilation automatique de l'application lorsque nous modifions le code.

*Remarque: avez vous vu dans le code le mot clé `toFuture` ? Finatra est un framework web asynchrone.*

##Avertissement

Alors, attention, moi aussi j'apprends Scala (et Finatra), donc je peux dire des choses choquantes (ou peut-être fausses). Ce blog est propulsé par **GitHub** par ici : [https://github.com/k33g/k33g.github.com](https://github.com/k33g/k33g.github.com), ce qui veut dire que vous pouvez faire des [pull requests](https://help.github.com/articles/using-pull-requests) sur ce que j'écris pour m'aider à m'améliorer (merci d'avance), vous pouvez même déclarer des [issues](https://github.com/k33g/k33g.github.com/issues), mais je préfère les PR (comme ça vous bossez pour moi ;) ). Par contre il vous faudra un compte **GitHub** (et c'est l'occasion de le faire tout de suite si vous n'en avez pas).

##Pré-requis

- Vous devez installer Scala (facile)
- Vous devez installer **sbt** [http://www.scala-sbt.org/release/docs/Getting-Started/Setup.html#installing-sbt](http://www.scala-sbt.org/release/docs/Getting-Started/Setup.html#installing-sbt) (facile aussi)

*Remarque: sbt pour Scala Build Tools est un utilitaire destiner à vous faciliter la vie pour vos projets Scala.*

##Rappel : Classes & Objets

Avant de rentrer dans le dur, nous allons juste un peu "désacraliser" Scala et apprendre à faire une petite classe, pour bien vérifier que finalement, c'est simple.

###Création du projet

Tout d'abord, nous allons créer une rapide structure de projet Scala, compréhensible par **sbt**, ce qui nous permettra de compiler notre code facilement.

Créez l'arborescence suivante (adaptez selon vos besoins) : (là on le fait à la main mais il existe des outils rassurez vous)

     demo
     |--src
        |--main
           |--scala
              |--org
                 |--k33g
                    |--models
                           
####Référence(s) pour aller plus loin sur la notion de création de projet

- [http://scalatutorials.com/beginner/2013/07/18/getting-started-with-sbt/](http://scalatutorials.com/beginner/2013/07/18/getting-started-with-sbt/)

###Programme principal

Dans `demo/src/main/scala/org/k33g/` créez le fichier `Demo.scala` *(remarquez que le nom `Demo` versus le nom du répertoire `demo`, ce n'est pas obligatoire, mais c'est plus propre)* avec le code suivant :

{% highlight scala %}
package org.k33g

object Demo extends App {
  println("Hello World!")

}
{% endhighlight %}

Sauvegardez, ouvrez votre terminal ou votre console, allez dans `demo` (`cd demo`) et tapez `sbt run` (et validez). Ça va mouliner un peu (Scala n'est pas super green au démarrage), pour finir par vous afficher un splendide :

    Hello World!

`\o/`

###First Class : `Human`

Dans `demo/src/main/scala/org/k33g/models` créez le fichier `Human.scala` avec le code suivant :

{% highlight scala %}
package org.k33g.models

class Human(val firstName: String, val lastName: String) {

  def sayHello(): String = {
    return "Hello " + firstName + " " + lastName
  }
}
{% endhighlight %}

Nous venons juste de créer une classe `Human` avec 2 "propriétés" `firstName` et `lastName` et une méthode `sayHello` qui retourne une chaîne de caractères. Ce n'est pas trop violent, et vous remarquez que la définition des attributs de la classe par passage de paramètre au constructeur est assez élégante (je ne peux pas troller sur Scala constamment).

Modifiez ensuite le précédent fichier `Demo.scala` :

{% highlight scala %}
package org.k33g

import org.k33g.models._

object Demo extends App {

  var bob = new Human("Bob", "Morane")
  println(bob.sayHello())

}
{% endhighlight %}

Toujours dans `demo` lancez à nouveau un `sbt run`, vous allez obtenir :

    Hello Bob Morane

Voilà, vous savez tout ;), Scala c'est facile ... On peut maintenant aller faire une application web en Scala (avec Finatra).

##Ma première application Finatra

###Installer Finatra

- Téléchargez [https://github.com/capotej/finatra-example/archive/master.zip](https://github.com/capotej/finatra-example/archive/master.zip)
- Dé-zippez
- Mettez à jour votre `PATH` avec le chemin vers Finatra

Chez moi (sous OSX), cela ressemble à ça :

    FINATRA_HOME=/Users/k33g_org/finatra-1.5.2
    export FINATRA_HOME
    export PATH=$PATH:$FINATRA_HOME

###Générez votre 1er projet

- Tapez ceci : `finatra new org.k33g.DemoWeb`
- A la question `Install Bower components? (y/n)` répondez `y` (cela va permettre par défaut de télécharger **Bootstrap** et **jQuery**)

Vous obtenez donc votre squelette de projet dans le répertoire `DemoWeb`. Mais avant de lancez quoique ce soit procédons à quelques réglages.

####Préparez votre "stack front" avec Bower : un peu de javascript

Allez dans `DemoWeb` et modifiez `bower.json` en lui ajoutant 2 dépendances : `backbone` et `underscore`, de cette manière :

    {
      "name": "DemoWeb",
      "version": "0.0.1",
      "license": "MIT",
      "private": true,
      "ignore": [
        "**/.*",
        "node_modules",
        "bower_components",
        "test",
        "tests"
      ],
      "dependencies": {
        "bootstrap" : "twbs/bootstrap",
        "backbone" : null,
        "underscore" : null
      }
    }

Ensuite, lancez `bower update` (dans `DemoWeb`) et les frameworks javascript **Backbone** et **Underscore** seront téléchargés.

####Modifiez (préparez) la page d'accueil

Modifiez `src/main/resources/public/index.html` de cette façon :

{% highlight html %}
<!DOCTYPE html>
<html lang="en">
  <head>
    <link rel="icon" type="image/x-icon" href="/favicon.ico" />
    <title>Demo</title>
    <link rel="stylesheet" type="text/css" href="/components/bootstrap/dist/css/bootstrap.css">
  </head>
  <body>
    <div class="container">
      <header>
        <h1>Je me la joue en Scala</h1>
      </header>

    </div>
    <script src="/components/jquery/dist/jquery.js"></script>
    <script src="/components/underscore/underscore.js"></script>
    <script src="/components/backbone/backbone.js"></script>
    
  </body>
</html>
{% endhighlight %}

####Modifiez le code de démarrage de l'application

Ouvrez `src/main/scala/org/k33G/DemoWeb/App.scala` et simplifiez le code de cette manière :

{% highlight scala %}
package org.k33g.DemoWeb

import com.twitter.finatra._
import com.twitter.finatra.ContentType._

object App extends FinatraServer {

  class MyApp extends Controller {

    get("/") { request =>
      render.static("index.html").toFuture
    }

  }

  register(new MyApp())
}
{% endhighlight %}

Nous nous contentons donc de dire qu'il faut afficher `index.html` si l'on appelle la racine du site `/` dans le navigateur.

####Il est temps de tester

Il suffit de lancer la commande `sbt run`. La console **sbt** "va compiler" votre application et ensuite vous notifier que vous pouvez vous connecter : `finatra: http server started on port: :7070`, ouvrez donc [http://localhost:7070/](http://localhost:7070/). Tout roule ? On passe donc à la suite. Arrêtez l'application : `Ctrl + c`.

##Création d'un service json

>>DIRE CE QUE L'ON VA FAIRE, que fait le service

###Création de la classe Human

Tout d'abord créez un répertoire `models` dans le répertoire `src/main/scala/org/k33g`. Dans ce répertoire, créez une classe `Human.scala` avec le code source suivant :

{% highlight scala %}
package org.k33g.models

class Human(val id: String, val firstName: String, val lastName: String) {

}
{% endhighlight %}

###Création de notre service

Ouvrez à nouveau `src/main/scala/org/k33g/DemoWeb/App.scala`, nous allons rajouter une "routes" qui fournira du jso, au navigateur :

Premièrement, pensez à importer les modèles : `import org.k33g.models._` et ajoutez ceci :

{% highlight scala %}
get("/humans/:id") { request =>
  val id = request.routeParams.getOrElse("id", null)
  val bob = new Human(id, "Bob", "Morane")

  render.json(Map(
    "id" -> bob.id, 
    "firstName" -> bob.firstName, 
    "lastName" -> bob.lastName
  )).toFuture
}
{% endhighlight %}

Au final, vous aurez :

{% highlight scala %}
package org.k33g.DemoWeb

import com.twitter.finatra._
import com.twitter.finatra.ContentType._
import org.k33g.models._

object App extends FinatraServer {

  class MyApp extends Controller {

    get("/") { request =>
      render.static("index.html").toFuture
    }

    get("/humans/:id") { request =>
      val id = request.routeParams.getOrElse("id", null)
      val bob = new Human(id, "Bob", "Morane")

      render.json(Map(
        "id" -> bob.id, 
        "firstName" -> bob.firstName, 
        "lastName" -> bob.lastName
      )).toFuture
    }

  }

  register(new MyApp())
}
{% endhighlight %}

Testez en lançant `sbt run` et appelez [http://localhost:7070/humans/42](http://localhost:7070/humans/42) et vous obtiendrez dans votre navigateur :

    {"id":"42","firstName":"Bob","lastName":"Morane"}

*Vous pouvez changer l'id dans l'url pour tester*

Pas trop dur?

####Remarque:

Pour les faignasses, sachez que vous pouvez remplacer :

{% highlight scala %}
render.json(Map(
  "id" -> bob.id, 
  "firstName" -> bob.firstName, 
  "lastName" -> bob.lastName
)).toFuture
{% endhighlight %}

par :

{% highlight scala %}
render.json(bob).toFuture
{% endhighlight %}

###Utilisation du service json avec Backbone

Parce qu'une application web sans javascript n'est pas une vraie application web, retournez ouvrir `index.html` et ajouter le code suivant en vas de page juste avant la fermeture de la balise `<body>` (donc `</body>`) :

{% highlight html %}
<script>

  var HumanModel = Backbone.Model.extend({
      urlRoot : "humans"
  });      

  $(function() {
    var bob = new HumanModel({id:"42"})
    bob.fetch()
      .done(function(){
        $("h1").html(bob.get("firstName") + " " + bob.get("lastName"));
      })
  });

</script>
{% endhighlight %}

Rafraîchissez votre page, vous allez voir que votre titre se met à jour avec les données du service json.

##Auto-Reload

Ce qui me plaisez énormément dans Play!>1 (et 2), c'était le rechargement automatique (+compilation) lorsque l'on modifiait le code. Sachez que moyennant une petite "bidouille" ceci est très possible. Il suffit d'ajouter un plugin à **sbt**. Ce plugin est [sbt-revolver](https://github.com/spray/sbt-revolver).

Commencez par quitter la console **sbt** (`Ctrl + c`). Ensuite dans le répertoire `project` de votre application, créez un fichier `plugins.sbt` avec le contenu suivant :

    addSbtPlugin("io.spray" % "sbt-revolver" % "0.7.2")

puis à la racine de votre projet, dans le fichier `build.sbt` ajoutez la ligne `Revolver.settings` comme ceci :

    name := "DemoWeb"

    version := "0.0.1-SNAPSHOT"

    scalaVersion := "2.10.3"

    libraryDependencies ++= Seq(
      "com.twitter" %% "finatra" % "1.5.2"
    )

    Revolver.settings

    resolvers +=
      "Twitter" at "http://maven.twttr.com"

Relancez mais avec la commande duivante `sbt ~re-start` (qui va charger les dépendances nécessaires puis lancer votre application).

Maintenant à chaque fois que vous modifierez le code, **sbt** recompilera et relancera l'application.

Essayez ça par exemple : dans `App.scala`

{% highlight scala %}
get("/humans") { request =>
  val bob = new Human("42", "Bob", "Morane")
  val john = new Human("00", "John", "Doe")

  render.json(Array(bob, john)).toFuture
}
{% endhighlight %}

Sauvegardez, regardez votre console qui compile automatiquement, puis appelez [http://localhost:7070/humans](http://localhost:7070/humans) et vous obtenez :

    [{"id":"42","firstName":"Bob","lastName":"Morane"},{"id":"00","firstName":"John","lastName":"Doe"}]

Magique!

Vous avez donc tout ce qu'il faut pour tester un peu tout ça et la prochaine fois on fait la suite des services avec un peu de base de données.

Enjoy! (et bon WE pluvieux)

*Et encore merci [@loic_d](https://twitter.com/loic_d), j'ai fini par m'y mettre. ;)*

