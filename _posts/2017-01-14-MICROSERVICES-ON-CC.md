---

layout: post
title: Micro services
info : Micro services
teaser: Comment développer des microservices avec @SenecaJS, un service discovery avec Redis et les "hoster" facilement chez @Clever_Cloud
---

# Microservices avec @SenecaJS chez @Clever_Cloud

## Les origines de cet articles

Pour cette année 2017, j'ai décidé de me remettre à l'IOT et en cherchant les plateformes opensource(s?) de gestion d'objets connectés, provisionning, ... (en gros, un application web qui vous affiche la liste de vos objets connectés, les données associées, des graphiques temps réels, qui vous permet d'ajouter des objets, dans découvrir, ...) je n'ai rien trouvé qui me corresponde réellement, qui soit facile à utiliser, à "coder" et à **héberger**. Mon modèle c'est [thingworx](https://www.thingworx.com/) ... Mais ce n'est pas opensource. Donc finalement, pourquoi ne pas faire ma propre plateforme? :stuck_out_tongue_winking_eye: Ok, c'est ambitieux, mais c'est bien d'avoir un "side project" avec un "vrai sujet" et **c'est formateur**. En effet, au cours de ma quête et de mes réflexions j'ai notamment décidé d'utiliser le concept de **microservices** qui me semble bien se prêter à mes besoins de construction d'une plateforme modulaire, évolutive, ...

## Micro services?

Alors, cet article n'est pas un dossier sur les microservices, mais plutôt le journal de mes expérimentations avec les microservices.

Pour une présentation sympa je vous engage à lire l'article paru dans [Programmez](http://www.programmez.com/) paru en Décembre 2015, écrit par 2 consultants de chez Xebia: [Les nouvelles architectures logicielles](http://blog.xebia.fr/wp-content/uploads/2016/01/Microservices-Programmez1.pdf).

Pour moi, rapidement, un microservice, c'est une fonction ou un ensemble de fonctions que j'appelle de mon programme principal, mais qui ne sont pas localisées au même endroit que mon programme principal (eg: les microservices que j'utilise peuvent être hébergés sur différents serveurs et je vais les utiliser dans mon code comme si j'en disposais en local sans me préoccuper de savoir où ils sont). Un microservice est indépendant, ça a l'avantage de simplifier le travail en équipe sur un projet d'envergure, de faciliter le partage de fonctionnalités avec d'autres projets ... Sans parler des notions de haute dispo, scalabilité, ...

Mais lisez donc l'article dont je vous parlais plus haut.

## Mes 1ers microservices avec SenecaJS

J'ai une appétence pour le JavaScript, ce qui a donc influé tout naturellement mes recherches et mon choix s'est porté sur le projet **[SenectaJS](http://senecajs.org/)**. Cette vidéo et une bonne introduction à l'utilisation de SenecaJS: [Michele Capra - Microservices in practice with Seneca.js](https://vimeo.com/175121062).

### Préparation du 1er microservice

Le mieux est de directement créer un projet sur GitHub car je m'en sers pour déployer mes services. Donc une fois votre projet créé et cloné sur votre poste, dans votre projet créez un fichier `package.json`:

```shell
# on imagine que votre projet GitHub s'appelle ping-service 🏓
cd ping-service
npm init -y
npm install seneca --save
```

Votre fichier `package.json` devrait ressembler à minima à ceci:

```json
{
  "name": "ping-service",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "seneca": "^3.2.2"
  }
}
```

Ensuite (dans le répertoire `/ping-service`), créez un fichier `index.js`

```javascript
const seneca = require('seneca')()
const os = require('os')

const port = process.env.PORT || 8082

function pingpong(options) {
  this.add({role: "sport", cmd: "ping"}, (message, reply) => {
    reply(null, {answer: "pong"})
  })
}

seneca
  .use(pingpong)
  .listen({
    host: '0.0.0.0',
    port: port
  })

console.info(`🌍 service is listening on ${port}`)
```

Vous pouvez dès maintenant lancer votre formidable service:

```shell
node index.js # ou npm start
```

Et le tester dans votre navigateur en appelant `http://localhost:8082/act?role=sport&cmd=ping` et vous obtiendrez en réponse:

```json
{"answer":"pong"}
```

Ce qui vaut bien une petite 🕺 de victoire.

### Préparation du 2ème microservice

Là, vous êtes chaud comme la braise, on ne s'arrête pas, vous m'en faites un deuxième. Là aussi, il faudra créer un projet sur GitHub, et avec beaucoup d'imagination, appelons le `pong-service`:

```javascript
const seneca = require('seneca')()
const os = require('os')

const port = process.env.PORT || 8081

function pingpong(options) {
  this.add({role: "sport", cmd: "pong"}, (message, reply) => {
    reply(null, {answer: "ping"})
  })
}

seneca
  .use(pingpong)
  .listen({
    host: '0.0.0.0',
    port: port
  })

console.info(`🌍 service is listening on ${port}`)
```

Si vous prenez le temps de le tester, vous obtiendrez:

```json
{"answer":"ping"}
```

## On héberge les 2 services chez @Clever_Cloud

Plutôt que de tout faire en local, nous allons héberger nos services à l'extérieur. J'ai choisi de faire ça chez [@Clever_Cloud](https://www.clever-cloud.com/) pour plusieurs raisons:

- la **simplicité d'utilisation** pour le déploiement et la maintenance (je suis un dev, je n'ai pas envie de perdre mon temps avec des solutions compliquées pour héberger mes applis)
- la possibilité d'ajouter une base de données facilement
- la **gestion automatique des updates**, des fixes des failles de sécurité
- l'**autoscalabilité** (je vous rappelle que je veux faire de l'IOT ... et que je suis un dev)
- **"No-downtime deployment"**, ce qui est plutôt rare ou alors faut te le gérer toi-même
- le support utilisateurs fait par la core team (et en :fr: dans mon cas, même si mon job actuel m'oblige à pratiquer l'anglais presque tous les jours, c'est quand même super agréable et reposant de pouvoir utiliser sa langue natale)
- ...

### C'est parti

- Alors, nos deux microservices sont sur GitHub
- Pour les grosses faignasses vous pouvez les cloner par ici:
  - https://github.com/wey-yu/ping-service
  - https://github.com/wey-yu/pong-service
- il vous faudra vous enregistrer chez [@Clever_Cloud](https://www.clever-cloud.com/) (il y a une offre découverte gratuite)

Et maintenant on dit que vous avez un compte et que vous voulez déployer:

#### 1- Créer une application:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-01.png">



## Service discovery


<TODO>


## Dans les tuyaux















---
