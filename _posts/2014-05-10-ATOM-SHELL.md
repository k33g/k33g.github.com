---

layout: post
title: Atom-shell, javascript everywhere
info : Atom-shell, javascript everywhere

---

#Atom-shell, javascript everywhere!

Depuis quelques jours, la release publique de **[Atom](https://atom.io/)** l'éditeur de code de **GitHub** est disponible. Atom, c'est un ide léger (éditeur de code) à la SublimeText qui a comme spécificité d'être développé en javascript, basé sur **node.js** et **Chromium**, avec la possibilité de développer "autour" en **Coffeescript** (donc faire des plugins), mais aussi en javascript. Certes, Atom n'a pas la vélocité d'une application développée "tout en C++", mais je trouve, à la vue de ses capacités que c'est à lui tout seul un cas d'usage démontrant que l'on peut aller très loin en javascript.

Mais ce que je trouve encore mieux, c'est que parallèlement, **GitHub** a publié **[Atom-shell](https://github.com/atom/atom-shell)** : le framework de base qui a permis de développer **Atom**. Cela signifie que vous avez à votre disposition les outils nécessaires pour faire des applications desktop "à la Atom".

D'autres projets de ce type existent, notamment **[Node-Webkit](https://github.com/rogerwang/node-webkit)** qui était dans la place avant **Atom-shell** et qui n'en n'est pas moins intéressant, reposant sur les mêmes composants, et le projet est toujours très actif.

Je vous explique donc rapidement comment vous pouvez faire une application avec **Atom-shell**. Pour démarrer, il vous faut node.js, npm et Grunt.

##Initialisation de l'application et installation d'Atom-shell

Commencez par créer un répertoire `myatom` avec un sous-répertoire `build` et un sous-répertoire `myatom-app`. Ensuite dans le sous répertoire `build`, créez 2 fichiers :

- `package.json`
- `Gruntfile.js`

###Contenu de `package.json`

    {
      "name": "myatom-app-atom-build",
      "version": "0.1.0",
      "devDependencies": {
        "grunt": "^0.4.4",
        "grunt-download-atom-shell": "^0.7.0"
      }
    }

###Contenu de `Gruntfile.js`

{% highlight javascript %}
module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    "download-atom-shell": {
      version: "0.12.3",
      outputDir: "./atom-shell",
      rebuild: true
    }
  });

  grunt.loadNpmTasks('grunt-download-atom-shell');

};
{% endhighlight %}

###Installer Atom-shell

Dans votre terminal préféré, allez dans le répertoire `build`, et tapez les commandes suivantes :

    npm install

Cela va télécharger les dépendances nécessaires, puis :

    grunt download-atom-shell

Cela va déclencher la tâche Grunt qui va télécharger les ressources nécessaires d'Atom-shell.

Au bout de quelques instants vous aurez 2 nouveaux répertoires dans votre répertoire `build` :

    build/
    ├── node_modules/
    └── atom-shell/

##Créer l'application

Donc normalement, vous devez avoir une structure de répertoires comme celle-ci :

    myatom/
    ├── build/
    |   ├── node_modules/
    |   └── atom-shell/
    └── myatom-app/

Créez dans le répertoire `myatom-app` 3 fichiers :

- `package.json`
- `index.html`
- `main.js`

###Contenu de  `package.json`

Vous précisez dans ce fichier le nom du script principal de votre application : `main.js`

    {
      "name": "myatom-app",
      "version": "0.1.0",
      "main": "main.js"
    }

###Contenu de  `index.html`

Aujourd'hui, nous allons rester simple :

{% highlight html %}
<!DOCTYPE html>
<html>
<head>
  <title>Hello World!</title>
</head>
<body>
  <h1>Hello World!</h1>
</body>
</html>
{% endhighlight %}

###Contenu de  `main.js`

Là nous avons un peu plus de choses :

{% highlight javascript %}
var app = require('app');
var BrowserWindow = require('browser-window');
var Menu = require('menu');
var dialog = require('dialog');

var mainWindow = null;

// Quit when all windows are closed.
app.on('window-all-closed', function() {
  if (process.platform != 'darwin')
    app.quit();
});

app.on('ready', function() {

  mainWindow = new BrowserWindow({width: 320, height: 200});
  mainWindow.loadUrl('file://' + __dirname + '/index.html');

  mainWindow.on('closed', function() {
    mainWindow = null;
  });

  var templateMenu = [
    {
      submenu: [
        {
          label: 'Quit',
          accelerator: 'Command+Q',
          click: function() { app.quit(); }
        }
      ]
    }
  ];

  menu = Menu.buildFromTemplate(templateMenu);
  Menu.setApplicationMenu(menu);

});
{% endhighlight %}

**à retenir** : `var BrowserWindow = require('browser-window');` sert à créer la fenêtre native du navigateur, donc la fenêtre principale de votre application, celle dans laquelle sera chargée la page `index.html`

###Lancez la bête!

Dans votre répertoire `myatom`, lancez la commande :

    ./build/atom-shell/Atom.app/Contents/MacOS/Atom ./myatom-app

Et votre killer app apparaît `\o/`:

![Alt "myatomapp.png"](https://github.com/k33g/k33g.github.com/raw/master/images/myatomapp.png)


**C'est fini pour aujourd'hui**, mais vous pouvez aller lire la documentation : [https://github.com/atom/atom-shell/tree/master/docs](https://github.com/atom/atom-shell/tree/master/docs)


