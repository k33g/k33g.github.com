---

layout: post
title: Microservices avec Vert-x en Scala
info : Microservices avec Vert-x en Scala et déploiement sur Clever-Cloud
teaser: 1ers pas dans le monde des microservices avec Vert-x et Scala
---

# Microservices avec Vert-x en Scala

Je viens de passer 2 semaineé très "microservices":

J'ai enfin eu l'occasion de voir le talk de Quentin sur les microservices [https://twitter.com/alexandrejomin/status/860443891971088384](https://twitter.com/alexandrejomin/status/860443891971088384) lors de notre passage chez [@Xee_FR](https://twitter.com/Xee_FR) à Lille (vous pouvez aussi voir aussi ceci à Devoxx France [Problèmes rencontrés en microservice (Quentin Adam)](https://www.youtube.com/watch?v=mvKeCsxGZhE) et [Comment maintenir de la cohérence dans votre architecture microservices (Clément Delafargue)](https://www.youtube.com/watch?v=Daburx0jSvw)).

J'ai lu l'excellent [Building Reactive Microservices in Java](https://developers.redhat.com/promotions/building-reactive-microservices-in-java/) par [@clementplop](https://twitter.com/clementplop), où Clément explique comment écrire des microservices en Vert-x. (à voir aussi: [Vert.X: Microservices Were Never So Easy (Clement Escoffier)](https://www.youtube.com/watch?v=c5zKUqxL7n0)

J'ai pu assister à la présentation ["MODERNISEZ VOS APPLICATIONS AVEC RXJAVA ET VERT.X"](http://rivieradev.fr/session/128) par [Thomas Segismont](https://twitter.com/tsegismont).

Du coup, je n'ai plus le choix, il faut que je m'y mette sérieusement et que je prépare quelques démos MicroServices pour mon job. Et autant que je vous en fasse profiter. 🙀 J'ai décidé de le faire en Scala (mon auto-formation), mais je vais tout faire pour que cela reste le plus lisible possible.

## Architecture de mon exemple

⚠️ note: cette "architecture" est pensée pour être le plus simple possible à comprendre - cela ne signifie pas que ce soit ce qu'il faut utiliser en production - l'objectif est d'apprendre simplement. (je vais faire des microservices http) - je ne traiterais pas de des "Circuit Breakers", ou des "Health Checks and Failovers".

Lorsque vous avez un ensemble de microservices, c'est bien d'avoir un système qui permetten de référencer ces microservices pour facilement les "trouver". Une application qui "consomme" un microservice doit avoir moyen de le référencer et l'utiliser sans pour autant connaître à l'avance son adresse (par ex: l'url du microservice). On parle de **"location transparency"** et de pattern **"service discovery"**. C'est à dire qu'un microservice, doit être capable d'expliquer lui-même comment on peut l'appeler et l'utiliser et ces informations sont stockées dans une **"Service Discovery Infrastructure"**.

### Vert.x Service Discovery

Vert.x fournit tout un ensemble d'outils pour faire ça et se connecter à un service Consul, Zookeeper, ... Mais Vert.x fournit aussi un **"Discovery Backend - Redis"** qui vous permet d'utiliser une base Redis comme annuaire de microservices (cf. [Discovery Backend with Redis](http://vertx.io/docs/vertx-service-discovery-backend-redis/groovy/)). C'est ce que je vais utiliser pour mon exemple.

Donc pour résumer, je vais faire:

- microservice qui se "déclare" au "Discovery Backend"
- un "consumer" qui va aller interroger le "Discovery Backend" pour obtenir une référence au microservice et ensuite l'utiliser

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/ms01.png" height="60%" width="60%">

## Création du microservice

### Préparation

Tout d'abord nous allons créer un projet **calculator-vx-service**

```shell
mkdir calculator-vx-service
cd calculator-vx-service
mkdir -p src/{main,test}/{java,resources,scala}
mkdir lib project target
```

Créez un fichier `build.sbt` à la racine du projet:

```scala
name := "calculator-vx-service"

version := "1.0"

scalaVersion := "2.12.2"

libraryDependencies += "io.vertx" %% "vertx-web-scala" % "3.4.1"
libraryDependencies += "io.vertx" %% "vertx-service-discovery-scala" % "3.4.1"
libraryDependencies += "io.vertx" %% "vertx-service-discovery-backend-redis-scala" % "3.4.1"
```

Créez un fichier `project/build.properties`

```
sbt.version = 0.13.15
```

### Code

Ensuite créez un fichier `src/main/scala/Calculator.scala`:

```scala
import io.vertx.core.json.JsonObject
import io.vertx.scala.core.Vertx
import io.vertx.scala.ext.web.Router
import io.vertx.scala.servicediscovery.types.HttpEndpoint
import io.vertx.scala.servicediscovery.{ServiceDiscovery, ServiceDiscoveryOptions}
import scala.concurrent.ExecutionContext.Implicits.global
import scala.util.{Failure, Success}

object Calculator {

    val vertx = Vertx.vertx()

    def main(args: Array[String]): Unit = {

      val server = vertx.createHttpServer()
      val router = Router.router(vertx)

      val httpPort = sys.env.get ("PORT").getOrElse("8080").toInt

      router.get("/api/add/:a/:b").handler(context => {
        val res: Integer = context.request.getParam("a").get.toInt + context.request.getParam("b").get.toInt
        context
          .response()
          .putHeader("content-type", "application/json;charset=UTF-8")
          .end(new JsonObject().put("result", res).encodePrettily())
      })

      router.get("/api/multiply/:a/:b").handler(context => {
        val res: Integer = context.request.getParam("a").get.toInt * context.request.getParam("b").get.toInt
        context
          .response()
          .putHeader("content-type", "application/json;charset=UTF-8")
          .end(new JsonObject().put("result", res).encodePrettily())

      })

      // home page
      router.get("/").handler(context => {
        context
          .response()
          .putHeader("content-type", "text/html;charset=UTF-8")
          .end("<h1>Hello 🌍</h1>")
      })

      println(s"🌍 Listening on $httpPort  - Enjoy 😄")
      server.requestHandler(router.accept _).listen(httpPort)
    }
}
```

Si vous compilez et lancez vous avez votre microservice de calcul qui vous permet de faire des additions et des multiplications:

- http://localhost:8080/api/add/40/2
- http://localhost:8080/api/multiply/21/2

Maintenant, on souhaite que notre microservice soit "découvrable"

## Rendre le service "découvrable"

Pour cela, nous allons ajouter une méthode à notre objet `Calculator`


```scala

def discovery = {
  // Settings for the Redis backend
  val redisHost = sys.env.get("REDIS_HOST").getOrElse("127.0.0.1")
  val redisPort = sys.env.get("REDIS_PORT").getOrElse("6379").toInt
  val redisAuth = sys.env.get("REDIS_PASSWORD").getOrElse(null)
  val redisRecordsKey = sys.env.get("REDIS_RECORDS_KEY").getOrElse("scala-records")

  // Mount the service discovery backend (Redis)
  val discovery = ServiceDiscovery.create(vertx, ServiceDiscoveryOptions()
    .setBackendConfiguration(
      new JsonObject()
        .put("host", redisHost)
        .put("port", redisPort)
        .put("auth", redisAuth)
        .put("key", redisRecordsKey)
    )
  )

  // Settings for record the service
  val serviceName = sys.env.get("SERVICE_NAME").getOrElse("calculator")
  val serviceHost = sys.env.get("SERVICE_HOST").getOrElse("localhost") // domain name
  val servicePort = sys.env.get("SERVICE_PORT").getOrElse("8080").toInt // set to 80 on Clever Cloud
  val serviceRoot = sys.env.get("SERVICE_ROOT").getOrElse("/api")

  // create the microservice record
  val record = HttpEndpoint.createRecord(
    serviceName,
    serviceHost,
    servicePort,
    serviceRoot
  )

  discovery.publishFuture(record).onComplete{
    case Success(result) => println(s"😃 publication OK")
    case Failure(cause) => println(s"😡 publication KO: $cause")
  }
  // discovery.close() // or not
}
```

Et vous allez appeler cette méthode `discovery` dans la méthode main de `Calculator`

```scala
def main(args: Array[String]): Unit = {

  val server = vertx.createHttpServer()
  val router = Router.router(vertx)

  // use redis backend to publish service informations
  discovery

  val httpPort = sys.env.get ("PORT").getOrElse("8080").toInt

  // etc...

```

#### Pour résumer, qu'avons nous fait?

Nous créons un `ServiceDiscovery` (on se connecte à la base Redis - que vous n'oubliez pas de lancer):

```scala
val discovery = ServiceDiscovery.create(vertx, ServiceDiscoveryOptions()
  .setBackendConfiguration(
    new JsonObject()
      .put("host", redisHost)
      .put("port", redisPort)
      .put("auth", redisAuth)
      .put("key", redisRecordsKey)
  )
)
```

Nous créons un `Record` qui décrit notre microservice:

```scala
// create the microservice record
val record = HttpEndpoint.createRecord(
  serviceName,  // calculator
  serviceHost,  // localhost
  servicePort,  // 8080
  serviceRoot   // /api
)
```

Et ensuite on publie les informations du microservice vers Redis:

```scala
discovery.publishFuture(record).onComplete{
  case Success(result) => println(s"😃 publication OK")
  case Failure(cause) => println(s"😡 publication KO: $cause")
}

```

Si vous lancez, vous pouvez vérifier que les données du microservice sont bien présentes dans la base Redis:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/redis1.png" height="60%" width="60%">

Maintenant, nous allons créer un consommateur de ce microservice.


## Création du consommateur

### Préparation

Nous allons créer un autre projet **calculator-vx-invoke** qui appellera les 2 opérations de notre microservice.

```shell
mkdir calculator-vx-invoke
cd calculator-vx-invoke
mkdir -p src/{main,test}/{java,resources,scala}
mkdir lib project target
```

Créez un fichier `build.sbt` à la racine du projet:

```scala
name := "calculator-vx-service"

version := "1.0"

scalaVersion := "2.12.2"

libraryDependencies += "io.vertx" %% "vertx-web-client-scala" % "3.4.1"
libraryDependencies += "io.vertx" %% "vertx-service-discovery-scala" % "3.4.1"
libraryDependencies += "io.vertx" %% "vertx-service-discovery-backend-redis-scala" % "3.4.1"
```

Créez un fichier `project/build.properties`

```
sbt.version = 0.13.15
```

### Code


Ensuite créez un fichier `src/main/scala/InvokeCalculator.scala`:


```scala
import io.vertx.core.json.JsonObject
import io.vertx.scala.core.Vertx
import io.vertx.scala.ext.web.client.WebClient
import io.vertx.scala.servicediscovery.{ServiceDiscovery, ServiceDiscoveryOptions}
import scala.concurrent.ExecutionContext.Implicits.global
import scala.util.{Failure, Success}

object InvokeCalculator {

  val vertx = Vertx.vertx()

  def main(args: Array[String]): Unit = {

    // Settings for the Redis backend
    val redisHost = sys.env.get("REDIS_HOST").getOrElse("127.0.0.1")
    val redisPort = sys.env.get("REDIS_PORT").getOrElse("6379").toInt
    val redisAuth = sys.env.get("REDIS_PASSWORD").getOrElse(null)
    val redisRecordsKey = sys.env.get("REDIS_RECORDS_KEY").getOrElse("scala-records")

    val discoveryService = ServiceDiscovery.create(vertx, ServiceDiscoveryOptions()
      .setBackendConfiguration(
        new JsonObject()
          .put("host", redisHost)
          .put("port", redisPort)
          .put("auth", redisAuth)
          .put("key", redisRecordsKey)
      )
    )

    // search service by name
    discoveryService.getRecordFuture(new JsonObject().put("name", "calculator")).onComplete{
      case Success(result) => {
        val reference = discoveryService.getReference(result)
        val client = reference.getAs(classOf[WebClient])
        client.get("/api/add/40/2").sendFuture().onComplete{
          case Success(result) => {
            println(result.body())
          }
          case Failure(cause) => {
            println(cause)
          }
        }

        client.get("/api/multiply/2/21").sendFuture().onComplete{
          case Success(result) => {
            println(result.body())
          }
          case Failure(cause) => {
            println(cause)
          }
        }

      }
      case Failure(cause) => {
        println(cause)
      }
    }
  }
}

```

#### Qu'avons nous fait?

Nous avons une fois de plus créé un `ServiceDiscovery` (on se connecte à la base Redis - que vous n'oubliez toujours pas de lancer):


```scala
val discoveryService = ServiceDiscovery.create(vertx, ServiceDiscoveryOptions()
```

Puis nous avons recherché le service par son nom avec notre `discoveryService`:

```scala
discoveryService.getRecordFuture(new JsonObject().put("name", "calculator")).onComplete{...
```

Une fois le microservice trouvé, je vais créer une **référence** à ce microservice à partir de laquelle je vais pouvoir obtenir un **client** qui va me permettre d'invoquer les opérations du microservice "calculator":

```scala
val reference = discoveryService.getReference(result)
val client = reference.getAs(classOf[WebClient])
```

*Remarque: `classOf[WebClient]` car mon service est de type http*.

Et maintenant si je veux faire une addition, il me suffit d'écrire ceci:

```scala
client.get("/api/add/40/2").sendFuture().onComplete{
  case Success(result) => {
    println(result.body())
  }
  case Failure(cause) => {
    println(cause)
  }
}
```

Ou ceci pour une multiplication:

```scala
client.get("/api/multiply/2/21").sendFuture().onComplete{
  case Success(result) => {
    println(result.body())
  }
  case Failure(cause) => {
    println(cause)
  }
}
```

Voilà, vous n'avez plus qu'à lancer pour vérifier que cela fonctionne. Ce n'est pas plus compliqué que ça de faire du microservice avec Vert-x. 😁

## Astuce pour déployer chez Clever-Cloud

J'ai commencé à jouer avec les microservices parceque j'ai des démonstrations à préparer pour mon job. Du coup je vous donne juste la démarche à suivre pour déployer sur Clever-Cloud.

### Variables d'environnement

Vous devez bien sûr avoir un add-on Redis qui va vous fournir les variables d'environnement nécessaire, comme par exemple:

```shell
REDIS_HOST	yopyop-redis.services.clever-cloud.com
REDIS_PASSWORD	pouyoupouyou
REDIS_PORT	3062
REDIS_URL	redis://:pouyoupouyou@yopyop-redis.services.clever-cloud.com:3062
```

Une application web chez Clever doit écouter sur le port `8080`, et de l'extérieur vous attaquerez votre microservice avec le port `80`

Ce qui veut dire que quand vous allez déclarer votre microservice au backend Redis, il faudra préciser `80` comme port:

```scala
val record = HttpEndpoint.createRecord(
  "calculator",
  "your.domain.name",
  80,
  "/api"
)
```

Mais faire écouter le service sur `8080` lorsque vous le lancez:

```scala
server.requestHandler(router.accept _).listen(8080)
```

### Build

Il y a 2 petites choses à ajouter:

- dans `build.sbt` ajouter la ligne `packageArchetype.java_application`
- il vous faudra une fichier `projet/plugins.sbt` avec cette ligne `addSbtPlugin("com.typesafe.sbt" % "sbt-native-packager" % "0.8.0")`

Et vous avez tout ce qu'il faut pour héberger vos microservices chez Clever 😉.
