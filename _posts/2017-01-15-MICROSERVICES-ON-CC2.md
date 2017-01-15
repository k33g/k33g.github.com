---

layout: post
title: Micro services
info : Micro services
teaser: Comment développer des microservices avec @SenecaJS, un service discovery avec Redis et les "hoster" facilement chez @Clever_Cloud, la partie II avec un "home made service discovery"
---

# Microservices avec @SenecaJS chez @Clever_Cloud - PART II

Cet article est la suite de la partie I: [http://k33g.github.io/2017/01/14/MICROSERVICES-ON-CC.html](http://k33g.github.io/2017/01/14/MICROSERVICES-ON-CC.html)

## Comment découvrir les services?

En fait c'est bien (et pratique) d'avoir une sorte de "catalogues de services" plutôt que de devoir donner les `hostname`, `port`,...

**@SenecaJS** propose déjà plusieurs solutions comme:

- https://github.com/senecajs/seneca-mesh qui peut s'utiliser par exemple avec **[Consul](https://www.consul.io/)** (service registry) (mais j'ai besoin de quelque chose de plus simple)
- https://github.com/senecajs/seneca-redis-pubsub-transport (mais avec le "mappage" des ports dans @Clever_Cloud, j'ai quelques problèmes à le faire fonctionner - 💭 mais à suivre)
- ...

Du coup je vais 🚧 fabriquer mon propre système:

1. quand un service démarre il publie ses informations dans une base **Redis** (avec un identifiant comme clé)
2. quand un client démarre, il va chercher les infos du service dans la base **Redis** par son id

Très simple, mais ça fera l'affaire 😄

Nous allons donc utiliser les Add-Ons Clever pour avoir une base **Redis**

## Ajouter un Add-On Redis dans Clever

- Clickez sur `+ Add an add-on`
- Sélectionnez Redis

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-16.png" height="95%" width="95%">

- Sélectionnez la plus petite option:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-17.png" height="95%" width="95%">

- Vous n'avez pas besoin de "linker" votre application à l'add-on
- Clickez sur `NEXT`

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-18.png" height="95%" width="95%">

- Payez (ah ben oui quand même de temps en temps)

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-19.png" height="95%" width="95%">

- Donnez un nom à votre add-on

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-20.png" height="95%" width="95%">

- Vous avez maintenant une base Redis
- Copiez l'url dans un coin (de la forme: `redis://:youpee@zul-redis.services.clever-cloud.com:3002`)

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-21.png" height="95%" width="95%">

## Un nouveau microservice

Nous allons créer un nouveau microservice (prévoyez de le publier sur GitHub pour faciliter le déploiement):

```shell
mkdir yo-seneca-service
cd yo-seneca-service
npm init -y
npm install seneca --save
npm install redis --save
```

Créez un fichier `index.js`:

```javascript
const seneca = require('seneca')()
```

- `process.env.PORT` prendra la valeur `8080` si hébergement sur Clever
- `process.env.MAPPEDPORT` prendra la valeur `80` si hébergement sur Clever, c'est le "port vu de l'extérieur"
- `process.env.HOST` le nom de domaine utilisé

```javascript
const port = process.env.PORT || 8084
const mappedport = process.env.MAPPEDPORT || 8084
const host = process.env.HOST || 'localhost'
```

- `serviceId`: l'identifiant du service

```javascript
const serviceId = "yo-service"
```

- on crée un client redis
- `process.env.REDIS_URL` prendra la valeur `redis://:youpee@zul-redis.services.clever-cloud.com:3002`

```javascript
const rediscli = require("redis").createClient({
  url: process.env.REDIS_URL
});
```

- notre super microservice 😜

```javascript
function yo(options) {
  this.add({role: "hello", cmd: "yo"}, (message, reply) => {
    reply(null, {answer: "yo 🌍❗️"})
  })
}

seneca
  .use(yo)
  .listen({
    host: '0.0.0.0',
    port: port
  })
```

- on "pousse" dans la base Redis les informations du microservice

```javascript
rediscli.set(serviceId, JSON.stringify({
  host: host, port: mappedport
}));

console.info(`🌍 service is listening on ${host}:${mappedport}`)
```

## Un nouveau client de notre microservice

Nous allons créer une nouvelle webapp cliente (prévoyez de la publier lui aussi sur GitHub pour faciliter le déploiement):

```shell
mkdir use-yo-seneca-service
cd use-yo-seneca-service
npm init -y
npm install seneca --save
npm install redis --save
npm install promise --save
npm install express --save
npm install body-parser --save
```

Créez un fichier `index.js`:

```javascript
const express = require("express");
const bodyParser = require("body-parser");
const Promise = require('promise');
const seneca = require('seneca')

const port = process.env.PORT || 8080;

const app = express();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));
```

- on se connecte à notre base Redis (la même que pour le microservice)

```javascript
const rediscli = require("redis").createClient({
  url:process.env.REDIS_URL
});
```

- nous créons une promise qui nous permet d'aller récupérer les infos du microservice

```javascript
let getClient = (serviceId) => {
  return new Promise((resolve, reject) => {
    rediscli.get(serviceId, function (err, reply) {
      if(err) reject(err)
      let serviceInfos = JSON.parse(reply.toString())
      let client = seneca().client(serviceInfos)
      resolve(client)
    });
  })
}

app.get('/services/yo', (req, res) => {
```

- utilisation de la "promise" pour recupérer un client "seneca"
- utilisation du microservice

```javascript
  getClient("yo-service").then(clientYo => {
    clientYo.act({role: "hello", cmd: "yo"}, (err, item) => {
      res.send(item)
    })
  })

});

app.listen(port);
console.log(`🌍 Web Server is started - listening on ${port}`);
```

## Pour tester en local

### Le microservice "yo-seneca-service"

Lancer dans le répertoire du microservice:

```shell
REDIS_URL="redis://:youpee@zul-redis.services.clever-cloud.com:3002" node index.js
```

Puis dans un navigateur, ouvrez [http://localhost:8084/act?role=hello&cmd=yo](http://localhost:8084/act?role=hello&cmd=yo)

Vous devriez obtenir:

```json
{"answer":"yo 🌍❗️"}
```

### La webapp cliente

Lancer dans le répertoire de la webapp:

```shell
REDIS_URL="redis://:youpee@zul-redis.services.clever-cloud.com:3002" node index.js
```

Puis dans un navigateur, ouvrez [http://localhost:8080/services/yo](http://localhost:8080/services/yo)

Vous devriez obtenir:

```json
{"answer":"yo 🌍❗️"}
```

## Déployer chez Clever

Si vous avez lu la partie I ([http://k33g.github.io/2017/01/14/MICROSERVICES-ON-CC.html](http://k33g.github.io/2017/01/14/MICROSERVICES-ON-CC.html)) ça ne devrait pas vous poser de problème.

Il faudra juste bien remplir les variables d'environnement:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-22.png" height="95%" width="95%">

Et voilà 🐼

Vous trouverez les codes des projets ici:

- [https://github.com/wey-yu/yo-seneca-service](https://github.com/wey-yu/yo-seneca-service)
- [https://github.com/wey-yu/use-yo-seneca-service](https://github.com/wey-yu/use-yo-seneca-service)
