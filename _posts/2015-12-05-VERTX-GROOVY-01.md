---

layout: post
title: Vert-X et Groovy, un excellent combo pour le web - Partie 1
info : Vert-X et Groovy, un excellent combo pour le web - Partie 1 
teaser: Ces dernières années, ma vie de développeur a été très largement influencée par PlayFramework 1 (en Java) puis par Express (Node, donc du JavaScript) après avoir compris que Play 2 n'était pas pour moi (disparition de la magie). Cependant, même si Node c'est très bien et que cela répond à 80% des besoins, pour les 20% restant j'en reviens à Java ... Mais avec une petite perte de souplesse ... Jusqu'au jour où ...
---


# Vert-X + Groovy: un excellent combo pour le web 

Ces dernières années, ma vie de développeur a été très largement influencée par **PlayFramework 1** (en Java) puis par **Express** (Node, donc du JavaScript) après avoir compris que **Play 2** n'était pas pour moi *(disparition de la magie)*. Cependant, même si Node c'est très bien et que cela répond à 80% des besoins, pour les 20% restant j'en reviens à Java ... Mais avec une petite perte de souplesse ... 
Jusqu'au jour où j'ai décidé de redonner une chance à Vert-X (un projet modulaire pour faire des webapps "réactives"). Je regardais ce projet régulièrement, mais à chaque fois que je creusais, au bout d'un moment je "bloquais" sur tel ou tel point et je passais à autre chose parce que je ne trouvais pas de solution. 

Le renforcement récent de l'équipe Vert-X (je pense à [@julienviet](https://twitter.com/julienviet) et [@clementplop](https://twitter.com/clementplop), et ceux que je ne connais pas) a contribué à l'apparition de plus de "samples", plus de documentation "humainement lisible", ...

Donc, aujourd'hui, nous allons voir comment **rapidement** créer un projet web avec **Vert-X**, **Maven** et **Groovy**. Et au fur et à mesure de mes découvertes je rajouterais un article.

**Pourquoi Groovy?**: parce qu'à l'usage, je le trouve bien plus agréable à coder et à lire que **Java**, et que quelques fonctionnalités comme l'augmentation des classes et les traits sont bien pratiques.

Mais après cette trop longue introduction, passons à l'action.

Je vous engage quand même à parcourir la documentation [http://vertx.io/docs/](http://vertx.io/docs/)

## Création du projet

Créez une structure de projet Maven:

    my-app/
    ├── src/ 
    |   └── main/   
    |       └── groovy/ 
    |           └── Starter.groovy          
    ├── pom.xml  

### Contenu de `pom.xml`

Je me suis **entièrement inspiré** de ce projet [https://github.com/vert-x3/vertx-examples/tree/master/maven-verticles/maven-verticle-groovy-compiled](https://github.com/vert-x3/vertx-examples/tree/master/maven-verticles/maven-verticle-groovy-compiled)

Ce qui est important, c'est cette ligne `<main.verticle>groovy:Starter</main.verticle>`. Elle permettra de lancer le code de `Starter.groovy` lorsque vous lancerez votre jar (`java -jar target/mywebapp-1.0-SNAPSHOT-fat.jar`).

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>org.typeunsafe</groupId>
  <artifactId>mywebapp</artifactId>
  <version>1.0-SNAPSHOT</version>

  <properties>
      <main.verticle>groovy:Starter</main.verticle>
  </properties>

  <dependencies>
    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-core</artifactId>
      <version>3.1.0</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-lang-groovy</artifactId>
      <version>3.1.0</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-web</artifactId>
      <version>3.1.0</version>
    </dependency>

  </dependencies>


  <build>

    <plugins>

      <plugin>
        <groupId>org.codehaus.groovy</groupId>
        <artifactId>groovy-eclipse-compiler</artifactId>
        <version>2.9.1-01</version>
        <extensions>true</extensions>
      </plugin>

      <plugin>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.1</version>
        <configuration>
          <compilerId>groovy-eclipse-compiler</compilerId>
        </configuration>
        <dependencies>
          <dependency>
            <groupId>org.codehaus.groovy</groupId>
            <artifactId>groovy-eclipse-compiler</artifactId>
            <version>2.9.1-01</version>
          </dependency>
          <!-- for 2.8.0-01 and later you must have an explicit dependency on groovy-eclipse-batch -->
          <dependency>
            <groupId>org.codehaus.groovy</groupId>
            <artifactId>groovy-eclipse-batch</artifactId>
            <version>2.3.7-01</version>
          </dependency>
        </dependencies>
      </plugin>

      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-shade-plugin</artifactId>
        <version>2.3</version>
        <executions>
          <execution>
            <phase>package</phase>
            <goals>
              <goal>shade</goal>
            </goals>
            <configuration>
              <transformers>
                <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                  <manifestEntries>
                    <Main-Class>io.vertx.core.Launcher</Main-Class>
                    <Main-Verticle>${main.verticle}</Main-Verticle>
                  </manifestEntries>
                </transformer>
                <transformer implementation="org.apache.maven.plugins.shade.resource.AppendingTransformer">
                  <resource>META-INF/services/io.vertx.core.spi.VerticleFactory</resource>
                </transformer>
              </transformers>
              <artifactSet>
              </artifactSet>
              <outputFile>${project.build.directory}/${project.artifactId}-${project.version}-fat.jar</outputFile>
            </configuration>
          </execution>
        </executions>
      </plugin>


    </plugins>
  </build>

</project>
{% endhighlight %}

### Contenu de `Starter.groovy`

Aujourd'hui je veux faire simple. Il me faut:

- un service qui me renvoie de l'html (requête de type `GET`)
- un service auquel je puisse passer un paramètre et qui me renvoie du json (requête de type `GET`)
- pouvoir servir des pages statiques


### Initialisation du server http et du router

{% highlight groovy %}
import groovy.json.JsonOutput // nous en aurons besoin plus loin
import io.vertx.groovy.ext.web.Router
import io.vertx.groovy.ext.web.handler.StaticHandler

def server = vertx.createHttpServer()
def router = Router.router(vertx)

// mon code viendra ici ...

server.requestHandler(router.&accept).listen(8080)
{% endhighlight %}

Vous le voyez, rien de plus simple. Maintenant, ajoutons un service

### Notre 1er service

Créons notre première route:

{% highlight groovy %}
import groovy.json.JsonOutput
import io.vertx.groovy.ext.web.Router
import io.vertx.groovy.ext.web.handler.StaticHandler

def server = vertx.createHttpServer()
def router = Router.router(vertx)

router.get("/api/yo").handler({ context ->
  context.response().putHeader("content-type", "text/html").end("<h1>YO!</h1>")
})

server.requestHandler(router.&accept).listen(8080)
{% endhighlight %}

- Maintenant, il vous suffit de "builder" votre projet: `mvn package`
- Puis de lancer la commande: `java -jar target/mywebapp-1.0-SNAPSHOT-fat.jar`
- Et enfin d'appeler [http://localhost:8080/api/yo](http://localhost:8080/api/yo)

**Simple!**

### Service Json

Ajoutons une nouvelle route:

{% highlight groovy %}
import groovy.json.JsonOutput
import io.vertx.groovy.ext.web.Router
import io.vertx.groovy.ext.web.handler.StaticHandler

def server = vertx.createHttpServer()
def router = Router.router(vertx)

router.get("/api/yo").handler({ context ->
  context.response().putHeader("content-type", "text/html").end("<h1>YO!</h1>")
})

// notre nouvelle route pour un service json
router.get("/api/hi/:name").handler({ context ->
  String name = context.request().getParam("name").toString()

  context
      .response()
      .putHeader("content-type", "application/json")
      .end(JsonOutput.toJson([
      "message":"Hi!",
      "name": name
  ]))
})

server.requestHandler(router.&accept).listen(8080)
{% endhighlight %}

Donc si j'appelle: [http://localhost:8080/api/hi/bob](http://localhost:8080/api/hi/bob), la variable `name` prendra la valeur `bob` et mon service me retournera une chaîne json comme celle-ci:

{% highlight json %}
{
  "message":"Hi!",
  "name":"bob"
}
{% endhighlight %}

- Donc, vous devez "builder" à nouveau votre projet: `mvn package`
- Puis de re-lancer la commande: `java -jar target/mywebapp-1.0-SNAPSHOT-fat.jar`
- Et enfin appeler [http://localhost:8080/api/hi/bob](http://localhost:8080/api/hi/bob)

**Toujours simple!**

### Servir du contenu statique

Pour cela, il vous suffit d'ajouter comme dernière route, ceci:

{% highlight groovy %}
router.route("/*").handler(StaticHandler.create())
{% endhighlight %}

Et de créer un répertoire `webroot` à la racine de votre projet, dans lequel vous pourrez déposer vos pages statiques, JavaScript, etc ...

## Un dernier pour la route ...

Ce que j'aimais beaucoup dans **Play**, c'était ça capacité à rebuilder et recharger l'application à chaque modification de code. **Sachez que c'est possible avec Vert-X**.

Voici comment faire:

Tout d'abord, créez un fichier de script `build.sh` avec le contenu suivant:

    # !/usr/bin/env bash
    mvn package

Rendez le exécutable (`chmod a+x build.sh`)

Ensuite créez un nouveau fichier de script `go.sh` (lui aussi exécutable `chmod a+x go.sh`) avec le contenu suivant:

    # !/usr/bin/env bash
    ./build.sh
    java -jar target/atta-1.0-SNAPSHOT-fat.jar --redeploy="**/*.groovy" --onRedeploy="./build.sh"

Vous lancez `go.sh`, une première fois il va builder le projet et ensuite à chaque modification de code groovy, vert-x relancera un build et une exécution.

**Plutôt pratique.**

Voilà. C'est tout pour aujourd'hui, la suite bientôt.

## Remerciements

Un grand merci à [@clementplop](https://twitter.com/clementplop) pour ses explications et sa patience ;)



