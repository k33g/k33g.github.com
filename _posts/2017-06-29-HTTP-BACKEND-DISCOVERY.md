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
  res.end()
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

Pour cela, j'ai créer un projet Maven (dont vous trouverez le code complet ici: https://github.com/botsgarden/vertx-service-discovery-backend-http)

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
          resultHandler.handle(Future.succeededFuture());
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



```java

```






