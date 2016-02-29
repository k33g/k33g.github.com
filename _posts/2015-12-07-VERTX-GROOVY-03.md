---

layout: post
title: Vert-X et Groovy, un excellent combo pour le web - Partie 3
info : Vert-X et Groovy, un excellent combo pour le web - Partie 3 
teaser: Ce qui est intéressant avec Groovy, c'est la "meta programmation", c'est à dire sa capacité à ajouter des comportements à des classes existantes (mais ce n'est pas que ça). Aujourd'hui voyons donc comment "commencer" un framework pour les "faignasses".
---

# Vert-X + Groovy: Faire un framework pour paresseux

Ce qui est intéressant avec Groovy, c'est la "meta programmation", c'est à dire sa capacité à ajouter des comportements à des classes existantes (mais ce n'est pas que ça). Aujourd'hui voyons donc comment "commencer" un framework pour les "faignasses".

Tout d'abord je remercie [https://twitter.com/glaforge](https://twitter.com/glaforge) qui m'a permis de faire les choses dans les règles de l'art.

Mon objectif est de simplifier le code à écrire, et dans un 1er temps je suis parti sur le concept d'**ExpandoMetaClass** [http://www.groovy-lang.org/metaprogramming.html# metaprogramming_emc](http://www.groovy-lang.org/metaprogramming.html# metaprogramming_emc) *(J'ajoute des méthodes aux classes de Vert-X au run-time)*.

Mais ma problématique, était de "charger/greffer" ses nouvelles méthodes de la façon la plus transparente possible. Avec le principe d'**ExpandoMetaClass**, il faut explicitement "exécuter" les "greffons" dans le code. Et si on souhaite modulariser ses extensions, il faudra créer une classe dans un package avec une méthode qui exécute les extensions et appeler explicitement cette méthode:

{% highlight groovy %}
class Augmentations {

  static pimpMyClasses() {

    String.metaClass.yo { ->
      return "yo " + delegate
    }

  }
}
{% endhighlight %}

Puis dans mon code j'appelerais:

{% highlight groovy %}
Augmentations.pimpMyClasses()
{% endhighlight %}

ça fonctionne, mais j'aurais bien aimé que mes classes soient "augmentées" de manière transparentes. Et c'est là que Guillaume m'a mis sur la piste des **Extension Modules** [http://www.groovy-lang.org/metaprogramming.html# _extension_modules](http://www.groovy-lang.org/metaprogramming.html# _extension_modules).
En gros, c'est le moyen de charger automatiquement vos extensions sans avoir à le faire de manière explicite dans votre code.

## Mise en oeuvre d'un module d'extension

Pour cela il vous faut danns votre projet un répertoire (et sous-répertoires) `/resources/META-INF/services` dans lequel vous aurez un fichier `org.codehaus.groovy.runtime.ExtensionModule`

    my-app/
    ├── src/ 
    |   └── main/   
    |       ├── groovy/ 
    |       |    └── Starter.groovy    
    |       └── resources/ 
    |           └── META-INF/ 
    |                └── services/ 
                          └── org.codehaus.groovy.runtime.ExtensionModule              

Dans ce fichier nous allons définir où sont nos extensions:

    moduleName=Some extensions for my framework
    moduleVersion=1.0-wip
    extensionClasses=my.extensions.WebExtensions

Ensuite créez une classe `WebExtensions` dans un package `my.extensions` et créons nos extensions.

## Extensions de classes


### 1ère extension: `param`

Lorsque je veux récupérer le paramètre d'une requête de type `GET` avec  Vert-x, je dois écrire:

{% highlight groovy %}
String name = context.request().getParam("name").toString()
{% endhighlight %}

Et que je crée ma classe d'extensions comme ceci:

{% highlight groovy %}
package my.extensions

import io.vertx.groovy.ext.web.RoutingContext
import io.vertx.groovy.ext.web.handler.StaticHandler

class WebExtensions {

  static Object param(RoutingContext self, String paramName) {
    return self.request().getParam(paramName)
  }
}
{% endhighlight %}

Maintenant je pourrais récupérer mes paramètres comme cela:

{% highlight groovy %}
String name = context.param("name").toString()
{% endhighlight %}

Je suis d'accord, je n'ai pas gagné grand chose, donc allons un peu plus loin.

### Nouvelle extension: `sendJson`

Pour renvoyer du Json à mon navigateur, avec vert-x je dois écrire:

{% highlight groovy %}
context
    .response()
    .putHeader("content-type", "application/json")
    .end(Json.encodePrettily([
      "message":"Hi!",
      "name": "Bob Morane"
    ]))
{% endhighlight %}

si j'ajoute cette méthode à ma classe d'extensions:

{% highlight groovy %}
//import io.vertx.core.json.Json

static void sendJson(RoutingContext self, content) {
  self.response()
    .putHeader("content-type", "application/json")
    .end(Json.encodePrettily(content))
}
{% endhighlight %}

Maintenant je pourrais écrire:

{% highlight groovy %}
context.sendJson([
    "message":"Hi!",
    "name": "Bob Morane"
])
{% endhighlight %}

Dans le même esprit, je voudrais pouvoir récupérer les données Json lors d'un `POST`.

### Nouvelle extension: `bodyAsJson`

Normalement je dois écrire ceci:

{% highlight groovy %}
Json.decodeValue(context.getBodyAsString(), Object.class)
{% endhighlight %}

si j'ajoute cette méthode à ma classe d'extensions:

{% highlight groovy %}
static Object bodyAsJson(RoutingContext self, klass) {
  return Json.decodeValue(self.getBodyAsString(), klass)
}
{% endhighlight %}

Maintenant je pourrais écrire:

{% highlight groovy %}
def obj = context.bodyAsJson(Object.class)
{% endhighlight %}

Mais allons encore un peu plus loin

### Nouvelles extensions: `GET` et `POST`

Actuellement je définis mes routes comme ceci:

{% highlight groovy %}
router.get("/api/hi/:name").handler({ context ->
  // foo
})
router.post("/api/humans").handler({ context ->
  // foo
})
{% endhighlight %}

si j'ajoute ces méthodes à ma classe d'extensions:

{% highlight groovy %}
//import io.vertx.groovy.ext.web.Router

static void GET(Router self, String uri, handler) {
  self.get(uri).handler(handler)
}

static void POST(Router self, String uri, handler) {
  self.post(uri).handler(handler)
}
{% endhighlight %}

Maintenant je pourrais écrire:

{% highlight groovy %}
router.GET("/api/hi/:name", { context -> 
  // foo
}

router.POST("/api/humans", { context -> 
  // foo
}
{% endhighlight %}

### Et enfin une dernière pour la route: `start`

Pour démarrer mon serveur http et lui expliquer où sont mes assets statiques, je fais ceci:

{% highlight groovy %}
router.route("/*").handler(StaticHandler.create())
server.requestHandler(router.&accept).listen(8080)
{% endhighlight %}

si j'ajoute ceci à ma classe d'extensions:

{% highlight groovy %}
/*
import io.vertx.groovy.core.http.HttpServer
import io.vertx.groovy.ext.web.handler.StaticHandler
*/

static void start(HttpServer self, Router router, Integer port, String staticPath) {
  println("HttpServer is listening on " + port)
  router.route(staticPath).handler(StaticHandler.create())
  self.requestHandler(router.&accept).listen(port)
}
{% endhighlight %}

Maintenant je démarre mon serveur comme cela:

{% highlight groovy %}
server.start(router, 8080, "/*")
{% endhighlight %}

Donc ...

## Au final le code de notre projet devrait ressembler à ceci

{% highlight groovy %}
def server = vertx.createHttpServer()
def router = Router.router(vertx)

router.route().handler(BodyHandler.create())

router.GET("/api/hi/:name", { context ->
  context.sendJson([
      "message":"Hi!",
      "name": context.param("name").toString()
  ])
})

router.POST("/api/humans", { context ->
  def obj = context.bodyAsJson(Object.class)
  obj.id = new Random().nextInt(100)
  context.sendJson(obj)
})

router.POST("/api/2/humans", { context ->
  Human bob = context.bodyAsJson(Human.class)
  bob.id = new Random().nextInt(100)
  context.sendJson(bob)
})

server.start(router, 8080, "/*")
{% endhighlight %}

Du bon code de faignasse, facile à lire et écrire ;)

@+

