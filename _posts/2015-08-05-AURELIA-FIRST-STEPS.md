---

layout: post
title: Aurelia, premiers pas
info : Aurelia, premiers pas
teaser: Aurelia est un framework web, sucesseur de Durandal, créé par Rob Eisenberg, un ex de la team Angular 2. Voyons un peu à quoi ça ressemble afin d'être armés pour décider quel n-ième framework vous pourriez prendre pour vos futurs projets. ...
image: <img src="https://github.com/k33g/k33g.github.com/raw/master/images/aurelia-logo.png">
---

#Aurelia, premiers pas

Il semblerait que tout nouveau framework javascript qui sorte se doive d'avoir le plus de dépendances et d'outils possibles, ce qui fait que pour écrire un simple "Hello World!", vous allez souvent récupérer plusieurs centaines de megas de fichiers et autres outils pour minifier, tester, déployer, ... Après, il faut juste comprendre comment cela fonctionne (ou pourquoi cela ne fonctionne pas), et si vous ne connaissez pas Grunt, Gulp, npm, Less, Sass, ... vous ne serez pas capable d'écrire et de démarrer votre simple "Hello World!".
Heureusement, il y a des gens sympas qui "fabriquent" des "quicks tarters". C'est déjà le cas pour Angular2 en ce moment. Je vous conseille ces 2 là:

- [https://github.com/pkozlowski-opensource/ng2-play.ts](https://github.com/pkozlowski-opensource/ng2-play.ts)
- [https://github.com/pkozlowski-opensource/ng2-play](https://github.com/pkozlowski-opensource/ng2-play)

Bon, revenons à nos moutons:

Ces derniers jour, j'ai voulu commencer à qualifier Aurelia (globalement, Aurelia a la même vocation qu'Angular: fournir tous les outils nécessaires pour faire une webapp). Je trouve que le tutorial de départ fait installer énormément de choses inutiles dans le cadre d'un apprentissage de départ. Je vous ai donc créé un "quick starter" pour Aurelia, que vous trouverez ici [https://github.com/k33g/aurelia-discovery](https://github.com/k33g/aurelia-discovery) pour démarrer rapidement.

##Installation

    git clone https://github.com/k33g/aurelia-discovery.git
    npm install
    jspm install

##Démarrage

C'est une application Express qui fait office de serveur http:
    
    cd aurelia-discovery
    node app.js

##Structure du "quick starter"

La structure de notre projet ressemble à ceci:

    aurelia-discovery/
    ├── public/ 
    |   ├── css/   
    |   |   └─── main.css/
    |   ├── index.html     
    |   ├── app.html 
    |   ├── app.js          
    |   └── config.js (configuration pour jspm - ne pas toucher)
    ├── app.js
    ├── config.js (configuration du serveur http)

###Ouvrir index.html

`index.htm` est notre point de départ, il n'y a pas grand chose dedans, tout se jouera dans `app.html` et `app.js`.

{% highlight html %}
<html>
<head>
  <meta charset="UTF-8">
  <title>Hello from Aurelia</title>
  <link rel="stylesheet" type="text/css" href="css/main.css">

</head>
<body aurelia-app>

  <script src="jspm_packages/system.js"></script>
  <script src="config.js"></script>
  <script>
    System.import("aurelia-bootstrapper");
  </script>
</body>
</html>
{% endhighlight %}

Donc ne touchez à rien. Remarquez l'attribut du tag body: `<body aurelia-app>` indispensable pour "expliquer" à Aurelia que votre application commence ici.

###Ouvrir app.html et app.js

`app.html` et `app.js` représentent le coeur de votre application (le composant principal). 

*`app.html`*
{% highlight html %}
<template>
  <h1>${message}</h1>
</template>
{% endhighlight %}

*`app.js`*
{% highlight javascript %}
export class App {

  constructor() {
    this.message = "...";
  }
  activate() {
    this.message = "Playing with Aurelia and Express";
  }
}
{% endhighlight %}

**Donc:**

- Un composant Aurelia se compose donc de 2 fichiers, un avec votre template html et l'autre avec le code javascript associé (`mon-composant.html` et `mon-composant.js`)
- Une application Aurelia commence par un composant principal qui va contenir dans son template le contenu de `<body>` (souvenez vous de `<body aurelia-app>`)
- Le composant "Application" possède une méthode `activate` qui déclenchée une fois le document chargé dans le navigateur. Donc dans notre cas `${message}`sera remplacé par `"Playing with Aurelia and Express"` au moment de l'activation.
- Dans le code javascript, vous faites référence aux variables décrites dans le template, en les utilisant comme une propriété du composant (donc pour `${message}` nous aurons `this.message`) 

**Vous pouvez tester:**

Ouvrez [http://localhost:8080/](http://localhost:8080/) avec votre navigateur (ce sera un peu long car tout est fait dynamiquement)

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/aurelia-01.png">

Il est temps maintenant de faire notre 1er composant (custom component)

##1er composant

J'aimerais pouvoir faire un composant de type `<hello-world mytext="yo"></hello-world>`, que je pourrais utiliser comme un tag html de base et qui afficherait le contenu de mon attribut `myext`.

- Créez un répertoire `public/components`
- Créez un fichier `hello-world.html` (dans `components`)
- Créez un fichier `hello-world.js` (dans `components`)

###Déclaration du composant dans `app.html`

Nous allons modifier le code de `app.html` pour référencer notre futur composant:

*`app.html`*
{% highlight html %}
<template>
  <require from='./components/hello-world'></require>
  
  <h1>${message}</h1>
  
  <hello-world mytext="yo"></hello-world>
  <hello-world mytext="hi"></hello-world>
  <hello-world mytext="hello"></hello-world>
  
</template>
{% endhighlight %}

- Vous notez donc l'utilisation du tag `<require from='...'></require>` pour référencer un composant
- Et nous allons utiliser 3 fois notre composant

###Ecriture de notre composant

Commençons par le plus simple:

*`hello-world.html`*
{% highlight html %}
<template>
  <h2>${helloWorldTitle}</h2>
</template>
{% endhighlight %}

Et ensuite:

*`hello-world.js`*
{% highlight javascript %}
import {inject} from 'aurelia-framework';

@inject(Element)
export class HelloWorld {
  constructor(element) {
    this.helloWorldTitle = "Hello World: " + element.getAttribute("mytext");
  }

}
{% endhighlight %}

**Donc:**

- `import {inject} from 'aurelia-framework';` nous permet d'utiliser le "decorateur" `@inject(Element)` pour injecter `element` à notre constructeur et avoir accès ainsi aux propriétés des éléments du composant
- ainsi, pour récupérer la valeur de l'élément, nous pouvons maintenant utiliser `element.getAttribute("mytext")`

**Et ça se teste:**

Faites un "refresh" dans votre navigateur, et vous obtiendrez ceci:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/aurelia-02.png">

##Un 2ème composant pour la route

Je voudrais un composant qui m'affiche une liste à partir d'un tableau de valeurs, et pouvoir ajouter un élément à la liste lorsque je clique sur un lien:

- Créez un fichier `my-list.html` (dans `components`)
- Créez un fichier `my-list.js` (dans `components`)

*`my-list.html`*
{% highlight html %}
<template>

  <ul>
    <li repeat.for="item of items">
      <template replaceable>
        ${item}
      </template>
    </li>
  </ul>

  <a href="#" click.trigger="updateList()">updateList</a>

</template>
{% endhighlight %}

- Pour parcourir une liste d'items, utiliser `repeat.for`
- l'item est lui même "rendu" dans un template : `<template replaceable>`
- capturer un évènement : utiliser le mot clé `trigger`, dans notre cas `click.trigger`
- la méthode `updateList()` est une méthode du composant définie dans `my-list.js`

*`my-list.js`*
{% highlight javascript %}
export class MyList {
  constructor() {
    this.items = ["Clark Kent", "Peter Parker", "Bob Morane"];
  }
  updateList() {
    this.items.push("John Doe")
  }
}
{% endhighlight %}

Pas grand chose à dire, le code parle de lui même.

**Pensez à déclarer et inclure le composant dans `app.html`:**

*`app.html`*
{% highlight html %}
<template>
  <require from='./components/hello-world'></require>
  <require from='./components/my-list'></require>

  <h1>${message}</h1>

  <hello-world mytext="yo"></hello-world>
  <hello-world mytext="hi"></hello-world>
  <hello-world mytext="hello"></hello-world>

  <hr>

  <my-list></my-list>

</template>
{% endhighlight %}

**Testez à nouveau:**

Faites un "refresh" dans votre navigateur, et vous obtiendrez ceci (cliquez pour tester):

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/aurelia-03.png">

**Voilà. C'est tout simple. A suivre.**

##Ressources

- suivre [Rob Eisenberg](https://twitter.com/eisenbergeffect)
- lire [http://eisenbergeffect.bluespire.com/leaving-angular/](http://eisenbergeffect.bluespire.com/leaving-angular/)
