---

layout: post
title: Vous avez moins d'une journée pour faire un ChatBot et le déployer sur Clever-Cloud
info : Vous avez moins d'une journée pour faire un ChatBot et le déployer sur Clever-Cloud
teaser: Un petit mode d'emploi pour déployer Hubot sur Clever-Cloud
---

# Vous avez moin d'une journée pour faire un ChatBot et le déployer

Challenge accepté?

Pour cela nous allons utiliser **Hubot** le bot bien connu de chez **GitHub** (cf. [https://hubot.github.com/](https://hubot.github.com/)), et voir comment le déployer sur la plateforme **Clever-Cloud** ([https://www.clever-cloud.com/](https://www.clever-cloud.com/)) et l'utiliser avec **Slack** ([https://slack.com/](https://slack.com/)).

Voici donc le mode d'emploi 😀

## Initialisation du bot

Pour initialiser un bot Hubot, il faudra installer le générateur Hubot pour Yeoman:

```shell
npm install -g yo generator-hubot
```

Puis tapez les commandes suivantes:

```shell
mkdir bob
cd bob
yo hubot
```

Répondez à toutes les questions.
⚠️ Lorsque le "wizard" vous pose la question `Bot adapter?` saisissez `slack`

Maintenant, le **yo generator** a créé le squelette de bot nécessaire dans votre répertoire.

### Réglages

#### package.json

Supprimez dans `package.json`:

```json
"engines": {
  "node": "0.10.x"
},
```

Ajoutez cette rubrique à votre fichier `package.json`: (cela permettra de lancer le bot)

```json
"scripts":{
  "start": "./bin/hubot -a slack"
}
```

⚠️ *remarque: nous allons utiliser l'adapter pour Slack, mais sachez qu'il en existe d'autre ou que vous pouvez écrire le votre simplement.*

Supprimez les lignes suivantes:

```json
"hubot-google-images": "^0.2.6",
"hubot-google-translate": "^0.2.0",
"hubot-heroku-keepalive": "^1.0.2",
"hubot-maps": "0.0.2",
"hubot-redis-brain": "0.0.3"
```

⚠️ *remarque: nous n'avons pas besoin de `hubot-redis-brain` pour notre exemple.*

#### external-scripts.json

Dans le fichier `external-scripts.json`, supprimez les lignes suivantes:

```json
"hubot-heroku-keepalive",
"hubot-google-images",
"hubot-google-translate",
"hubot-maps",
"hubot-redis-brain"
```

#### hubot-scripts.json

Supprimez tout simplement le fichier `hubot-scripts.json`

## Ecrire le cerveau du bot

Vous êtes maintenant prêts à coder "l'intelligence" de votre bot:

Dans le répertoire `/scripts`, supprimez le fichier `example.coffe` et créez au même endroit un fichier `bob.js`:

```javascript
// Description:
//   <description of the scripts functionality>
//   this is my clever bot
'use strict';

module.exports =  (robot) =>  {

  robot.hear(/hello bob/, (res) => {
    res.send(`bonjour ${res.message.user.name}`);
  });

  robot.hear(/flute|zut|💩/i, (res) => {
    res.send(`😡 ${res.message.user.name}`);
  });

  // ok bob ça roule
  robot.hear(/(?=.*ok)(?=.*bob)(?=.*roule)/i, (res) => {
    res.send(`😀 ${res.message.user.name}`);
  });

};
```

⚠️ *remarque: laissez bien la remarque d'en-tête, sinon Hubot va vous afficher un warning en vous expliquant que vous n'avez pas documenté.*


## Tester le bot

Vous pouvez tester votre bot directement sur votre poste. Mais tout d'abord, supprimez le répertoire `node_modules`, le 1er chargement de Hubot, chargera les dépendances (n'oubliez pas que nous avons modifé le fichier `package.json`), puis dans un terminal, tapez la commande suivante:

```shell
./bin/hubot
```

Après le chargement des dépendances, vous allez obtenir le prompt suivant:

```shell
bob>
```

Avec lequel vous allez pouvoir tester votre **ChatBot**

```shell
bob> hello bob
bob> bonjour Shell
zut
bob> 😡 Shell
bob> 💩
bob> 😡 Shell
ok bob tout roule?
bob> 😀 Shell
```

## Du côté de Slack

Maintenant que votre bot est vivant, vous allez préparer tout ce qu'il faut pour l'accueillir.

Il est donc temps maintenant de paramétrer un **"Slack"**

### Pré-requis

- Vous devez avoir créé une team dans Slack

### Ajouter l'application Hubot

- allez sur la page des intégration de votre team: [https://le-nom-de-votre-team.slack.com/apps](https://le-nom-de-votre-team.slack.com/apps)
- dans la zone de recherche tapez `hubot`
- vous allez arriver sur la page de l'application Hubot
- clickez sur **Install**
- choisissez un nom pour votre bot et clickez sur **Add Hubot Integration**
- vous allez arriver ensuite sur la page de setup qui vous propose un token de ce type (⚠️ que vous copiez pour utiliser plus loin)

```shell
HUBOT_SLACK_TOKEN=xoxb-1734567674356-f38scAAAtvuweHXXXXPCUoBJ
```

Si vous modifiez quelque chose, n'oubliez pas de clicker sur **Save Integration**

## Du côté de Clever-Cloud

Maintenant que Slack est prêt, nous allons déployer notre bot chez Clever-Cloud

## Préparation

Dans le dossier de votre bot (sur votre poste) tapez les commandes suivantes (pour transformer notre répertoire en repository git):

```shell
git init
git add .
git commit -m "first version"
```

⚠️ *Remarque: vous avez besoin d'un compte Clever-Cloud et d'avoir associé votre clé SSH cf. [https://console.clever-cloud.com/users/me/ssh-keys](https://console.clever-cloud.com/users/me/ssh-keys)*

## Déployer

Maintenant, connectez vous sur Clever-Cloud [https://console.clever-cloud.com](https://console.clever-cloud.com), puis dans l'administration, procédez aux actions suivantes:

- sélectionnez **Add an application**
- clickez sur le bouton **CREATE A BRAND NEW APP**
- sélectionnez runtime **Node**
- à l'étape **Scalability**, clickez sur le bouton **NEXT**
- donnez un nom à votre application (bob par exemple) à l'étape **Information**
- clickez sur le bouton **CREATE**
- à l'étape **Add-on creation Provider**, clickez sur le bouton **I DON’T NEED ANY ADD-ON**
- dans les variables d'environnement, ajoutez: `HUBOT_SLACK_TOKEN` avec la valeur du token slack et aussi `EXPRESS_PORT=8080` (Hubot est une application Express)
- clickez sur le bouton **NEXT**

Vous allez obtenir un message de ce type:

```shell
git remote add clever git+ssh://git@push-par-clevercloud-customers.services.clever-cloud.com/app_e7a90a22-accc-4dc9-9b15-b4f9b11386a5.git
git push -u clever master
```

Tapez ces commandes dans le terminall à la racine de votre projet, et le déploiement va commencer (le code est publié chez Clever-Cloud, et cela va ensuite déclencher le déploiement).

Une fois le déploiement réussi, vous verrez apparaître **Bob** dans votre team (dans Slack). Il ne vous reste plus qu'à "inviter" **Bob** dans un "channel" et à discuter avec lui.

C'est tout

Disclaimer: Je bosse chez Clever-Cloud 😊


