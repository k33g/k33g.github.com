---

layout: post
title: Micro services
info : Micro services
teaser: Comment développer des microservices avec @SenecaJS, un service discovery avec Redis et les "hoster" facilement chez @Clever_Cloud
---

# Microservices avec @SenecaJS chez @Clever_Cloud - PART I

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

- clicker sur `+ Add an application`
- dans la liste `Select your GitHub repository`, sélectionner votre projet sur GitHub

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-01.png" height="95%" width="95%">

#### 2- Choisissez le type de l'application:

- dans notre cas, ce sera NodeJS

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-02.png" height="95%" width="95%">

#### 3- Editez le type d'instance

- Clicker sur `EDIT`

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-03.png" height="95%" width="95%">

- Choisir une instance de taille **pico**
- Clicker sur `NEXT`

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-04.png" height="95%" width="95%">

#### 4- Donnez un nom à votre service et créez l'application

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-05.png" height="95%" width="95%">

#### 5- Ne pas ajouter d'Add-On

- Pour cette partie nous n'avons pas besoin d'add-on

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-06.png" height="95%" width="95%">

#### 6- Les variables d'environnement

- Par défaut il y a toujours une variable `PORT` égale à `8080`
  - une application sur Clever doit **toujours** "écouter" sur le port http `8080`
  - le port http `8080` est mappé sur le port `80`
  - donc pour accéder à vos webapps de l'extérieur, vous utiliserez le port `80`
  - donc ne changez rien
- Clicker sur `NEXT`

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-07.png" height="95%" width="95%">

#### 7- La création de l'application commence

- Une application Node chez Clever doit posséder un fichier `package.json` indiquant comment démarrer

  ```json
  "scripts": {
    "start": "node index.js"
  }
  ```

- *Remarque*: `"main": "index.js"` peut suffire
- maintenant patientez un peu...

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-08.png" height="95%" width="95%">

- Vous pouvez ensuite suivre le déploiement de votre microservice:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-09.png" height="95%" width="95%">

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-10.png" height="95%" width="95%">

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-11.png" height="95%" width="95%">

#### 8- Donnez une url humainement lisible à votre microservice

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-12.png" height="95%" width="95%">

#### 9- Testez votre microservice

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-13.png" height="95%" width="95%">

#### 10- Exercice

Vous avez vu, c'est ultra facile, faites donc la même chose pour le 2ème microservice (pong)

### Nous avons donc maintenant 2 microservices hebergés

- 🏓 ping: http://mypingservice.cleverapps.io/act?role=sport&cmd=ping
- 🏓 et pong: http://mypongservice.cleverapps.io/act?role=sport&cmd=pong

Nous allons maintenant voir comment créer un client pour les utiliser.

### Utilisons nos microservices

Sur votre poste en local (vous pourrez l'héberger plus tard si vous le souhaitez), créez un nouveau projet Node, avec du Express:

```shell
npm init -y
npm install express --save
npm install body-parser --save
npm install seneca --save
```

Ensuite créez un fichier `index.js`:

```javascript
const express = require("express");
const bodyParser = require("body-parser");
const seneca = require('seneca')

const port = process.env.PORT || 8080;

const app = express();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));

let clientPong = seneca().client({host:'mypongservice.cleverapps.io', port:80})
let clientPing = seneca().client({host:'mypingservice.cleverapps.io', port:80})

app.get('/service/ping', (req, res) => {
  clientPing.act({role: "sport", cmd: "ping"}, (err, item) => {
    res.send(item)
  })
});

app.get('/service/pong', (req, res) => {
  clientPong.act({role: "sport", cmd: "pong"}, (err, item) => {
    res.send(item)
  })
});

app.listen(port);
console.log(`🌍 Web Server is started - listening on ${port}`);

```

*⚠️ Remarque: il existe une intégration Express-Seneca, mais là j'ai fait au plus simple.*

- Lancez `node index.js`
- ouvrez votre navigateur
  - essayez http://localhost:8080/service/ping
  - essayez http://localhost:8080/service/pong

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-14.png" height="95%" width="95%">

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/cc-15.png" height="95%" width="95%">

👏 génial, on a bien nos services distants utilisables (une petite 🕺).

Maintenant ce qui serait bien, cs serait d'avoir un système de **"service discovery"** pour éviter d'avoir à renseigner les urls des microservices.

Mais ce sera pour un prochain article (j'ai encore quelques coup de tournevis à donner 😃)
