---

layout: post
title: Développer son propre Service Discovery Backend en mode REST pour Vert.x avec Node et Express
info : Comment développer son propre discovery backend pour Vert.x et comment l'utiliser
teaser: le mode d'emploi complet pour implémenter ServiceDiscoveryBackend
---

# Développer son propre Service Discovery Backend pour Vert.x avec Node et Express

Par défaut, le mode de recherche de services de Vert.x utilise une structure de données distribuée (http://vertx.io/docs/vertx-service-discovery/java/#_backend). Vert.x propose d'autres moyens de "découverte de services", et notamment un backend s'appuyant sur **Redis** (http://vertx.io/docs/vertx-service-discovery/java/#_redis_backend) que j'utilise habituellement.

La documentation de Vert.x explique qu'il est possible d'implémenter son propre `ServiceDiscoveryBackend SPI` (SPI pour Service Provider Interface). J'ai donc décidé comme exercice de faire mon propre backend de discovery pour les microservices Vert-x. C'est très formateur, et je remercie au passage [Clément Escoffier](https://twitter.com/clementplop) et [Julien Viet](https://twitter.com/julienviet) qui ont eu la patience de répondre à mes questions.

## Quel type de Service Discovery Backend?

Avec ma forte appétence pour le JavaScript, vous ne serez pas surpris, j'ai décidé d'enregistrer mes microservices (et de permettre de les rechercher) avec une application **Express**.

Un système de discovery de microservices Vert.x doit proposer les fonctionnalités suivante:

- enregistrer un nouveau service
- modifier un service
- supprimer un service
- donner la liste des services

Le code pour faire cela est extrêmement simple:

- mon backend va écouter sur le port 8080
- il va gérer la liste des microservices en mémoire dans `let services = []`

```javascript
const express = require("express");
const bodyParser = require("body-parser");

let port = process.env.PORT || 8080;

let app = express();
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended: false}))

let services = []

// update informations about the service
app.put('/update/:registration', (req, res) => {
  let service = services.find(service => service.registration == req.params.registration)
  let index = services.indexOf(service)
  services[index] = req.body
  console.log("Services updated", services[index])
  res.end()
})

// unregister a service
app.delete('/remove/:registration', (req, res) => {
  let service = services.find(service => service.registration == req.params.registration)
  services.splice(services.indexOf(service), 1)
  res.status(202).end(req.params.registration)

})

// get all the services
app.get('/records', (req, res) => {
  res.send(services);
})

// register a service
app.post('/register', (req, res) => {
  let serviceInformations = req.body
  services.push(serviceInformations)
  console.log("🐼 New service added", serviceInformations)
  res.end()
})

app.listen(port)
console.log("🌍 Discovery Server is started - listening on ", port)
```

> vous trouverez le code complet du backend ici: https://github.com/botsgarden/ms-http-backend

## Implémenter ServiceDiscoveryBackend

Maintenant que nous avons un backend qui tourne, il faut implémenter la classe qui va nous permettre d'interagir avec ce backend.

Pour cela, j'ai créer un projet **Maven** (dont vous trouverez le code complet ici: https://github.com/botsgarden/vertx-service-discovery-backend-http)

### mon fichier pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>org.typeunsafe</groupId>
  <artifactId>vertx-service-discovery-backend-http</artifactId>
  <version>1.0-SNAPSHOT</version>

  <properties>
    <vertx.version>3.4.2</vertx.version>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.1</version>
        <configuration>
          <source>1.8</source>
          <target>1.8</target>
        </configuration>
      </plugin>
    </plugins>
  </build>

  <dependencies>
    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-core</artifactId>
      <version>${vertx.version}</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-web-client</artifactId>
      <version>${vertx.version}</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-service-discovery</artifactId>
      <version>${vertx.version}</version>
    </dependency>
  </dependencies>
</project>

```

### Implémentation de `HttpBackendService`

Voici donc le code Java de l'implémentation du `ServiceDiscoveryBackend`:

```java
package org.typeunsafe;

import io.vertx.core.AsyncResult;
import io.vertx.core.Future;
import io.vertx.core.Handler;
import io.vertx.core.Vertx;
import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import io.vertx.servicediscovery.Record;
import io.vertx.servicediscovery.spi.ServiceDiscoveryBackend;

import io.vertx.ext.web.client.WebClient;

import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;
```
> ma classe doit implémenter l'interface `ServiceDiscoveryBackend`

```java
public class HttpBackendService implements ServiceDiscoveryBackend {

  private Integer httpBackendPort;
  private String httpBackendHost;
  private String registerUri;
  private String removeUri;
  private String updateUri;
  private String recordsUri;
  private WebClient client;

```
> au moment de l'initialisation du ServiceDiscoveryBackend, je passe les informations de configuration nécessaire pour accéder au backend REST (la partie en Node/Express). J'instancie un `WebClient` qui me permettra d'envoyer des requêtes à mon backend.

```java
  @Override
  public void init(Vertx vertx, JsonObject configuration) {
    client = WebClient.create(vertx);

    httpBackendPort = configuration.getInteger("port");
    httpBackendHost  = configuration.getString("host");
    registerUri  = configuration.getString("registerUri"); 
    removeUri  = configuration.getString("removeUri");
    updateUri  = configuration.getString("updateUri");  
    recordsUri  = configuration.getString("recordsUri"); 

    System.out.println("🤖 HttpBackendService initialized");

  }
```
> la méthode `store` est appelée lorsqu'un microservice s'enregistre dans le backend. Et donc mon client va faire une requête de type `POST` au backend en lui passant `record` qui contient les informations fournies par le microservice pour s'enregistrer et c'est là que l'on affecte un numéro unique d'enregistrement au microservice (`record.setRegistration(uuid)`)

```java
  @Override
  public void store(Record record, Handler<AsyncResult<Record>> resultHandler) {
    
    if (record.getRegistration() != null) {
      resultHandler.handle(Future.failedFuture("The record has already been registered"));
      return;
    }
    String uuid = UUID.randomUUID().toString();
    record.setRegistration(uuid);

    client.post(this.httpBackendPort, this.httpBackendHost, this.registerUri)
      .sendJsonObject(record.toJson(), ar -> {
        System.out.println("Hey Oh!!!");
        if (ar.succeeded()) {
          resultHandler.handle(Future.succeededFuture(record));
        } else {
          resultHandler.handle(Future.failedFuture(ar.cause()));
        }
      });
  }
```
> la méthode `remove` va supprimer l'enregistrement de la liste des microservices maintenue par le backend (l'application Express)

```java
  @Override
  public void remove(Record record, Handler<AsyncResult<Record>> resultHandler) {
    Objects.requireNonNull(record.getRegistration(), "No registration id in the record");
    remove(record.getRegistration(), resultHandler);
  }

  @Override
  public void remove(String uuid, Handler<AsyncResult<Record>> resultHandler) {
    Objects.requireNonNull(uuid, "No registration id in the record");

    client.delete(this.httpBackendPort, this.httpBackendHost, this.removeUri + "/" + uuid)
      .send(ar -> {
        if (ar.succeeded()) {
          resultHandler.handle(Future.succeededFuture(
            new Record(new JsonObject().put("registration",uuid))
          ));
        } else {
          resultHandler.handle(Future.failedFuture(ar.cause()));
        }
      });

  }
```
> Il est tout à fait possible de modifier les informations relatives au microservice et de les mettre à jour par une requête de type `PUT`

```java
  @Override
  public void update(Record record, Handler<AsyncResult<Void>> resultHandler) {
    Objects.requireNonNull(record.getRegistration(), "No registration id in the record");

    client.put(this.httpBackendPort, this.httpBackendHost, this.updateUri + "/" + record.getRegistration())
      .sendJsonObject(record.toJson(), ar -> {
        if (ar.succeeded()) {
          resultHandler.handle(Future.succeededFuture());
        } else {
          resultHandler.handle(Future.failedFuture(ar.cause()));
        }
      });
  }
```
> Et enfin, avec `getRecords` je peux demander la liste des microservices enregistrés

```java
  @Override
  public void getRecords(Handler<AsyncResult<List<Record>>> resultHandler) {
    client.get(this.httpBackendPort, this.httpBackendHost, this.recordsUri).send(resp -> {

      if(resp.succeeded()) {
        try {
          JsonArray entries = resp.result().bodyAsJsonArray();
          List<Record> records = entries.stream().map(item -> new Record(JsonObject.mapFrom(item)))
              .collect(Collectors.toList());
                    
          resultHandler.handle(Future.succeededFuture(records));
        } catch (Exception e) {
          e.printStackTrace();
        }

      } else {
        resultHandler.handle(Future.failedFuture(resp.cause()));
      }
    });
  }

  @Override
  public void getRecord(String uuid, Handler<AsyncResult<Record>> resultHandler) {
    // TODO
  }

}
```

Voilà, ce n'est pas plus compliqué que cela (ok, je fais le malin maintenant 😉 )

### 1ère utilisation de `HttpBackendService`, écrivons un test

Tout d'abord, il faut ajouter ceci au `pom.xml`:

```xml
<dependency>
  <groupId>junit</groupId>
  <artifactId>junit</artifactId>
  <version>4.12</version>
  <scope>test</scope>
</dependency>

<dependency>
  <groupId>com.jayway.awaitility</groupId>
  <artifactId>awaitility</artifactId>
  <version>1.7.0</version>
  <scope>test</scope>
</dependency>
```

Puis codons une classe de test `HttpBackendServiceTest` largement inspirée de https://github.com/vert-x3/vertx-service-discovery/blob/master/vertx-service-discovery/src/test/java/io/vertx/servicediscovery/spi/ServiceDiscoveryBackendTest.java


```java
package org.typeunsafe;

import io.vertx.core.Vertx;
import io.vertx.core.json.JsonObject;
import io.vertx.servicediscovery.types.HttpEndpoint;
import io.vertx.servicediscovery.Record;
import org.junit.Before;
import org.junit.Test;
import junit.framework.TestCase;
import java.util.concurrent.atomic.AtomicReference;
import static com.jayway.awaitility.Awaitility.await;

public class HttpBackendServiceTest extends TestCase {
  Vertx vertx;
  HttpBackendService httpBackend;

  @Before
  public void setUp() {
    vertx = Vertx.vertx();
```
> J'initialise mon nouveau `HttpBackendService` et lui passe les information nécessaires pour accéder au seveur Express

```java
    httpBackend = new HttpBackendService();
    httpBackend.init(Vertx.vertx(), new JsonObject()
      .put("host", "localhost")
      .put("port", 8080)
      .put("registerUri", "/register")
      .put("removeUri", "/remove")
      .put("updateUri", "/update")
      .put("recordsUri", "/records"));
  }
```
> Je crée un `Record` pour simuler l'enregistrement d'un microservice et enduite je m'enregistre dans le backend avec `httpBackend.store(record, handler)`. `await().until(() -> reference.get() != null);` me permet d'attendre le retour de ma requête pour enfin faire mon assertion.

```java
  @Test
  public void testServiceInsertion() throws Exception {
    // create the microservice record
    Record record = HttpEndpoint.createRecord(
      "000",
      "127.0.0.1",
      9090,
      "/api"
    );
    AtomicReference<Record> reference = new AtomicReference<>();
    httpBackend.store(record, res -> {
      if(!res.succeeded()) {
        res.cause().printStackTrace();
      }
      reference.set(res.result());
    });    

    await().until(() -> reference.get() != null);
    System.out.println(reference.get().getName());
    System.out.println(reference.get().getRegistration());
    assertEquals("000", reference.get().getName());
  }
}

```

⚠️ Avant de lancer un `mvn test`, n'oubliez pas de lancer le backend Express avec la commande `npm start` ou `node index.js`

Donc normalement, si tout va bien vous devez avoir un backend et un `ServiceDiscoveryBackend` fonctionnels. Il est donc temps d'implémenter les microservices qui vont utiliser tout cela.

### Publier votre nouvelle librairie

Pour que votre librairie/jar soit utilisable et "reconnaissable" par **Maven**, vous avez besoin de la publier en local:

```shell
mvn install:install-file -Dfile=target/vertx-service-discovery-backend-http-1.0-SNAPSHOT.jar \
-DgroupId=org.typeunsafe \
-DartifactId=vertx-service-discovery-backend-http \
-Dversion=1.0-SNAPSHOT  \
-Dpackaging=jar
```

> je vous laisse adapter les noms au besoin

Il est temps de développer un microservice qui va aller s'enregistrer dans notre nouveau backend

## Mise en oeuvre d'un 1er microservice

Nous allons faire un microservice "réactif" car c'est plus joli 😉. Je vais à nouveau créer un projet **Maven** (vous trouverez le code complet par ici: https://github.com/botsgarden/simple-microservice)

### Avant toute chose ⚠️

Pour que votre microservice sache utiliser votre nouveau `ServiceDiscoveryBackend`, dans votre projet vous devez ajouter:

- un répertoire `src/main/resources/META-INF/sevices`
- dans ce répertoire un ficier `io.vertx.servicediscovery.spi.ServiceDiscoveryBackend`
- avec le contenu suivant: `org.typeunsafe.HttpBackendService` (votre implémentation de `ServiceDiscoveryBackend`)

### Un fichier `pom.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>org.typeunsafe</groupId>
  <artifactId>simple-microservice</artifactId>
  <version>1.0-SNAPSHOT</version>

  <properties>
    <vertx.version>3.4.2</vertx.version>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <main.verticle>org.typeunsafe.Hey</main.verticle>
  </properties>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.1</version>
        <configuration>
          <source>1.8</source>
          <target>1.8</target>
        </configuration>
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
              <outputFile>${project.build.directory}/${project.artifactId}-${project.version}-fat.jar
              </outputFile>
            </configuration>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>

  <dependencies>
    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-core</artifactId>
      <version>${vertx.version}</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-web</artifactId>
      <version>${vertx.version}</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-web-client</artifactId>
      <version>${vertx.version}</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-service-discovery</artifactId>
      <version>${vertx.version}</version>
    </dependency>
```
> ici nous avons la référence à notre nouvelle librairie de discovery

```xml
    <dependency>
      <groupId>org.typeunsafe</groupId>
      <artifactId>vertx-service-discovery-backend-http</artifactId>
      <version>1.0-SNAPSHOT</version>
    </dependency>
  </dependencies>
</project>
```

Nous sommes maintenant prêts à développer notre microservice

### Microservice `Hey.java`

```java
package org.typeunsafe;

import io.vertx.rxjava.core.AbstractVerticle;
import io.vertx.core.Future;
import io.vertx.rxjava.core.http.HttpServer;
import io.vertx.core.json.JsonObject;

import io.vertx.rxjava.ext.web.Router;
import io.vertx.rxjava.ext.web.handler.StaticHandler;
import io.vertx.rxjava.ext.web.handler.BodyHandler;

import io.vertx.rxjava.servicediscovery.types.HttpEndpoint;
import io.vertx.rxjava.servicediscovery.ServiceDiscovery;

import io.vertx.servicediscovery.ServiceDiscoveryOptions;
import io.vertx.servicediscovery.Record;

import java.util.Optional;

public class Hey extends AbstractVerticle {
  
  private ServiceDiscovery discovery;
  private Record record;

  private void setDiscovery() {
    ServiceDiscoveryOptions serviceDiscoveryOptions = new ServiceDiscoveryOptions();

    // how to access to the backend
```
> ici je donne les informations pour se connecter au backend **Express** et je crée une umstance de `ServiceDiscovery`

```java
    Integer httpBackendPort = Integer.parseInt(Optional.ofNullable(System.getenv("HTTPBACKEND_PORT")).orElse("8080"));
    String httpBackendHost = Optional.ofNullable(System.getenv("HTTPBACKEND_HOST")).orElse("127.0.0.1");
    
    // Mount the service discovery backend (my http backend)
    discovery = ServiceDiscovery.create(
      vertx,
      serviceDiscoveryOptions.setBackendConfiguration(
        new JsonObject()
          .put("host", httpBackendHost)
          .put("port", httpBackendPort)
          .put("registerUri", "/register")
          .put("removeUri", "/remove")
          .put("updateUri", "/update")
          .put("recordsUri", "/records")
      ));
  }

```
> je définis les informations relatives à mon microservice

```java
  private void setRecord() {
    // Settings to record the service
    String serviceName = Optional.ofNullable(System.getenv("SERVICE_NAME")).orElse("hey");
    String serviceHost = Optional.ofNullable(System.getenv("SERVICE_HOST")).orElse("localhost"); // domain name
    Integer servicePort = Integer.parseInt(Optional.ofNullable(System.getenv("SERVICE_PORT")).orElse("9091")); 
    String serviceRoot = Optional.ofNullable(System.getenv("SERVICE_ROOT")).orElse("/api");

    // create the microservice record
    record = HttpEndpoint.createRecord(
      serviceName,
      serviceHost,
      servicePort,
      serviceRoot
    );
    // add some meta data
    record.setMetadata(new JsonObject()
      .put("kind", "http")
      .put("message", "Hello 🌍")
      .put("uri", "/ping")
    );

  }
```
> la méthode `stop` du microservice permet de le désenregistrer du backend quand on arrête le microservice

```java
  public void stop(Future<Void> stopFuture) {
    System.out.println("Unregistration process is started ("+record.getRegistration()+")...");

    discovery
      .rxUnpublish(record.getRegistration())
      .subscribe(
        successfulResult -> {
          System.out.println("👋 bye bye " + record.getRegistration());
          stopFuture.complete();
        },
        failure -> {
          failure.getCause().printStackTrace();
          System.out.println("😡 Unable to unpublish the microservice: " + failure.getMessage());
        }
      );
  }

```
> je définis la ou les routes de mom microservice

```java
  private Router defineRoutes(Router router) {
    
    router.route().handler(BodyHandler.create());

    router.get("/api/ping").handler(context -> {
      context.response()
        .putHeader("content-type", "application/json;charset=UTF-8")
        .end(
          new JsonObject().put("message", "🏓 pong!").toString()
        );
    });

    // serve static assets, see /resources/webroot directory
    router.route("/*").handler(StaticHandler.create());

    return router;
  }

  public void start() {

    setDiscovery();
    setRecord();

    /* === Define routes and start the server === */
    Router router = Router.router(vertx);
    defineRoutes(router);
    Integer httpPort = record.getLocation().getInteger("port");
    // if you use container or VM the httpPort and the servicePort could be different
    HttpServer server = vertx.createHttpServer();

    server
      .requestHandler(router::accept)
      .rxListen(httpPort)
      .subscribe(
        successfulHttpServer -> {
          System.out.println("🌍 Listening on " + successfulHttpServer.actualPort());
          /* === publish the microservice to the discovery backend === */
```
> une fois mon microservice démarré, je le publie sur le backend

```java          
          discovery
            .rxPublish(record)
            .subscribe(
              succesfulRecord -> {
                System.out.println("😃 Microservice is published! " + succesfulRecord.getRegistration());
              },
              failure -> {
                System.out.println("😡 Not able to publish the microservice: " + failure.getMessage());
              }
            );
        },
        failure -> {
          System.out.println("😡 Houston, we have a problem: " + failure.getMessage());
        }
      );
  }
}

```

Maintenant vous pouvez builder puis lancer votre microservice:

```shell
java  -jar target/simple-microservice-1.0-SNAPSHOT-fat.jar
```

Si tout se passe bien, côté microservice, dans votre console vous devriez obtenir quelaue chose conmme ceci:

```shell
🤖 HttpBackendService initialized
Jun 29, 2017 12:43:03 PM io.vertx.core.impl.BlockedThreadChecker
WARNING: Thread Thread[vert.x-eventloop-thread-0,5,main] has been blocked for 2886 ms,
time limit is 2000
Jun 29, 2017 12:43:04 PM io.vertx.core.impl.BlockedThreadChecker
WARNING: Thread Thread[vert.x-eventloop-thread-0,5,main] has been blocked for 3889 ms,
time limit is 2000
Jun 29, 2017 12:43:05 PM io.vertx.core.impl.BlockedThreadChecker
WARNING: Thread Thread[vert.x-eventloop-thread-0,5,main] has been blocked for 4892 ms,
time limit is 2000
Jun 29, 2017 12:43:06 PM io.vertx.core.impl.launcher.commands.VertxIsolatedDeployer
INFO: Succeeded in deploying verticle
🌍 Listening on 9091
😃 Microservice is published! a9165560-56f1-48be-a872-6954e244facc
```

Et côté du backend **Express** vous devriez voir apparaître ceci:

```shell
🐼 New service added { location:
   { endpoint: 'http://localhost:9091/api',
     host: 'localhost',
     port: 9091,
     root: '/api',
     ssl: false },
  metadata: { kind: 'http', message: 'Hello 🌍', uri: '/ping' },
  name: 'hey',
  registration: 'a9165560-56f1-48be-a872-6954e244facc',
  status: 'UP',
  type: 'http-endpoint' }
```

Maintenant, codons une webapp qui va utiliser le backend pour trouver le microservice et enfin l'utiliser

## Mise en oeuvre d'une WebApp

Une fois de plus, j'ai créé un projet **Maven**.
Vous trouverez l'ensemble du code source ici: https://github.com/botsgarden/call-simple-microservice

### Avant toute chose ⚠️

comme pour le microservice, pour utiliser votre nouveau `ServiceDiscoveryBackend`, dans votre projet vous devez ajouter:

- un répertoire `src/main/resources/META-INF/sevices`
- dans ce répertoire un ficier `io.vertx.servicediscovery.spi.ServiceDiscoveryBackend`
- avec le contenu suivant: `org.typeunsafe.HttpBackendService` (votre implémentation de `ServiceDiscoveryBackend`)

### Un fichier `pom.xml`

Le fichier `pom.xml` est quasi identique au précédent (à part les noms d'artifcat et de classe)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>org.typeunsafe</groupId>
  <artifactId>call-simple-microservice</artifactId>
  <version>1.0-SNAPSHOT</version>

  <properties>
    <vertx.version>3.4.2</vertx.version>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <main.verticle>org.typeunsafe.Hello</main.verticle>
  </properties>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.1</version>
        <configuration>
          <source>1.8</source>
          <target>1.8</target>
        </configuration>
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
              <outputFile>${project.build.directory}/${project.artifactId}-${project.version}-fat.jar
              </outputFile>
            </configuration>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>

  <dependencies>
    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-core</artifactId>
      <version>${vertx.version}</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-rx-java</artifactId>
      <version>${vertx.version}</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-web</artifactId>
      <version>${vertx.version}</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-web-client</artifactId>
      <version>${vertx.version}</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-service-discovery</artifactId>
      <version>${vertx.version}</version>
    </dependency>

    <dependency>
      <groupId>org.typeunsafe</groupId>
      <artifactId>vertx-service-discovery-backend-http</artifactId>
      <version>1.0-SNAPSHOT</version>
    </dependency>
  </dependencies>
</project>

```

### WebApplication `Hello.java`

Et donc le code de notre webapp sera le suivant:

```java
package org.typeunsafe;

import io.vertx.rxjava.core.AbstractVerticle;
import io.vertx.rxjava.core.http.HttpServer;
import io.vertx.core.json.JsonObject;

import io.vertx.rxjava.ext.web.Router;
import io.vertx.rxjava.ext.web.handler.BodyHandler;

import io.vertx.rxjava.servicediscovery.ServiceDiscovery;
import io.vertx.servicediscovery.ServiceDiscoveryOptions;
import io.vertx.rxjava.servicediscovery.ServiceReference;
import io.vertx.rxjava.ext.web.client.WebClient;


import java.util.Optional;

public class Hello extends AbstractVerticle {
```
> Comme pour le microservice, j'ai besoin des informations pour accéder au backend

```java
  private ServiceDiscovery discovery;

  private void setDiscovery() {
    ServiceDiscoveryOptions serviceDiscoveryOptions = new ServiceDiscoveryOptions();

    // how to access to the backend
    Integer httpBackendPort = Integer.parseInt(Optional.ofNullable(System.getenv("HTTPBACKEND_PORT")).orElse("8080"));
    String httpBackendHost = Optional.ofNullable(System.getenv("HTTPBACKEND_HOST")).orElse("127.0.0.1");
    
    // Mount the service discovery backend (my http backend)
    discovery = ServiceDiscovery.create(
      vertx,
      serviceDiscoveryOptions.setBackendConfiguration(
        new JsonObject()
          .put("host", httpBackendHost)
          .put("port", httpBackendPort)
          .put("registerUri", "/register")
          .put("removeUri", "/remove")
          .put("updateUri", "/update")
          .put("recordsUri", "/records")
      ));
  }

  public void start() {
    
    setDiscovery();

    Router router = Router.router(vertx);

    Integer httpPort = Integer.parseInt(Optional.ofNullable(System.getenv("PORT")).orElse("9095"));
    HttpServer server = vertx.createHttpServer();
    router.route().handler(BodyHandler.create());

    server
      .requestHandler(router::accept)
      .rxListen(httpPort)
      .subscribe(
        successfulHttpServer -> {
          System.out.println("🌍 Listening on " + successfulHttpServer.actualPort());
```
> une fois mon serveur http démarré, je recherche mon microservice (que j'ai appelé **"hey"**): avec ce filtre `r -> r.getName().equals("hey")`
>- si je le trouve, je crée un client web qui me permet d'appeler mon microservice
>- et je crée une route pour la webapp qui déclenchera l'appel du microservice (`client.get("/api/ping").send(...)`)
>- vous n'avez qu'à tester dans votre navigateur en appelant http://localhost:9095/call/ping et vous obtiendrez `{"message":"🏓 pong!"}
`

```java
          discovery
            .rxGetRecord(r -> r.getName().equals("hey"))
            .subscribe(
              successfulRecord -> {
                ServiceReference reference = discovery.getReference(successfulRecord);
                WebClient client = reference.getAs(WebClient.class);
                
                router.get("/call/ping").handler(context -> {
                  client.get("/api/ping").send(resp -> {

                    context.response()
                      .putHeader("content-type", "application/json;charset=UTF-8")
                      .end(
                        resp.result().body()
                      );

                  });
                });

              },
              failure -> {
                System.out.println("😡 Unable to discover the services: " + failure.getMessage());
              }
            );
        },
        failure -> {
          System.out.println("😡 Houston, we have a problem: " + failure.getMessage());
        }
      );
  }

}

```




