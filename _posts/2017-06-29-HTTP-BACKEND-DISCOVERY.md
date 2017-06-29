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


