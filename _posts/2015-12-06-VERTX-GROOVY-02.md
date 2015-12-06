---

layout: post
title: Vert-X et Groovy, un excellent combo pour le web - Partie 2
info : Vert-X et Groovy, un excellent combo pour le web - Partie 2 
teaser: Dans l'épisode précédent vous avez vu pu voir la facilité de mise en oeuvre d'une application Vert-x avec Groovy. Aujourd'hui, nous faisons court (c'est dimanche) et nous voyons comment gérer des requête de type POST.
---


#Vert-X + Groovy: aujourd'hui: le POST

Aujourd'hui ce sera court: "comment répondre à une requête de type POST".


##Request body

Avant toute chose, il faut activer la capacité de Vert-x à lire le `body` au moment de la requête. Il faut donc ajouter ceci dans votre code:

{% highlight groovy %}
router.route().handler(BodyHandler.create())
{% endhighlight %}

Dans ce cas, nous activons la possibilité pour l'ensemble des routes, mais il est possible de le faire que pour une partie, par exemple ici, uniquement pour les "routes en dessous" de `/api/humans`:

{% highlight groovy %}
router.route().handler(BodyHandler.create("/api/humans*"))
{% endhighlight %}

##Gérer le POST

Notre code est très simple:

{% highlight groovy %}
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import io.vertx.groovy.ext.web.Router
import io.vertx.groovy.ext.web.handler.BodyHandler
import io.vertx.groovy.ext.web.handler.StaticHandler

def server = vertx.createHttpServer()
def router = Router.router(vertx)

// activate reading of request body
router.route().handler(BodyHandler.create())

router.post("/api/humans").handler({ context ->

  def jsonSlurper = new JsonSlurper()
  // create an object from the body content
  def obj = jsonSlurper.parseText(context.getBodyAsString())
  // add an id to the object
  obj.id = new Random().nextInt(100)

  // cast the object to json string and send the result
  context
      .response()
      .putHeader("content-type", "application/json")
      .end(JsonOutput.toJson(obj))
})

router.route("/*").handler(StaticHandler.create())

server.requestHandler(router.&accept).listen(8080)
{% endhighlight %}

- Nous avons eu juste à activer la lecture du "request body": `router.route().handler(BodyHandler.create())`
- Et ensuite à le lire et le transformer en une chaîne json: `jsonSlurper.parseText(context.getBodyAsString())`

Vous pouvez tester facilement votre route:

    curl -H "Content-Type: application/json" -X POST -d '{"firstName":"Bob","lastName":"Morane"}' http://localhost:8080/api/humans

Et vous devriez obtenir quelque chose comme ceci:

    {"firstName":"Bob","id":42,"lastName":"Morane"}


##Json selon Vert-x

Jusqu'ici, j'utilisais les capacités de Groovy à gérer le Json. Mais sachez que Vert-X propose aussi l'outillage json nécessaire par le biais du package `io.vertx.core.json.Json`, donc ajouter un import dans votre code: `import io.vertx.core.json.Json`. Puis continuons à coder.

Créez une classe `Human`:

{% highlight groovy %}
class Human {
  public Integer id
  public String firstName
  public String lastName
}
{% endhighlight %}

puis créez la route suivante:

{% highlight groovy %}
router.post("/api/2/humans").handler({ context ->

  Human bob = Json.decodeValue(context.getBodyAsString(), Human.class)
  bob.id = new Random().nextInt(100)

  context
      .response()
      .putHeader("content-type", "application/json")
      .end(Json.encodePrettily(bob))
})
{% endhighlight %}

- `Json.decodeValue` permet de "mapper" votre json sur une instance de classe
- `Json.encodePrettily` permet de transformer votre instance en une "jolie" json string

Vous pouvez tester facilement votre route:

    curl -H "Content-Type: application/json" -X POST -d '{"firstName":"Bob","lastName":"Morane"}' http://localhost:8080/api/2/humans

Et vous devriez obtenir quelque chose comme ceci:

    {
      "id" : 76,
      "firstName" : "Bob",
      "lastName" : "Morane"
    }

Je vous laisse découvrir seuls comment faire un `PUT` ou un `DELETE` (la doc et les exemples sont très bien faits). La prochaine fois nous verrons comment simplifier notre code grâce à quelques spécificités de Groovy.

Bon Dimanche :)
