---

layout: post
title: Faites vos outils avec npm et node
info : Faites vos outils avec npm et node

---

# Faites vos outils avec npm et node

Lorsque je code, j'ai souvent des tâches répétitives (quel que soit le langage), ie: 

- écrire des modèles et des collections Backbone
- écrire des modèles Play
- écrire des routes pour Express.js
- ...

Nul doute, que vous avez énormément d'autres exemples en tête. L'outil du moment pour régler ce type de problème est [Yeoman](http://yeoman.io/) (oui il y en a d'autres, mais Yeoman c'est "hype" ;)) et ensuite, ou vous avez de la chance, ou il faut écrire le plugin dont vous avez besoin. Dans certains cas, surtout si vous n'avez pas besoin de quelque chose de complexe, vous pouvez rapidement écrire un utilitaire avec uniquemnt node et npm.

## Spécifications (par exemple)

Je passe mon temps à écrire des modèles et des collections Backbone qui ressemblent à ceci :

{% highlight javascript %}
/*--- Human Model ---*/
var HumanModel = Backbone.Model.extend({
    defaults : function (){
      return {}
    },
    urlRoot : "humans"
});

/*--- Humans Collection ---*/
var HumansCollection = Backbone.Collection.extend({
  url : "humans",
  model: HumanModel
});
{% endhighlight %}

Et j'aimerais aller plus vite, juste taper `bb Human` et obtenir mon fichier généré.

## Juste fais-le ...

### package.json

Commencez par créer un répertoire `bbtools`. Ensuite dans ce répertoire, créez un fichier `package.json` avec le contenu suivant :

    {
     "name": "bbtools",
     "version": "0.0.0",
     "bin": { "bb": "bb.js"},
     "dependencies": {
       "underscore": "1.6.0"
      }
    }

L'objectif étant de disposer d'une commande `bb` qui exécutera le fichier `bb.js`. Notez `"underscore": "1.6.0"`, nous allons nous servir des capacités de "templating" de la librairie Underscore

### Notre template

Créez (dans le même répertoire) un fichier `bb.tpl` avec le contenu suivant :

{% highlight javascript %}
/*--- <%= modelName %> Model ---*/
var <%= modelName %>Model = Backbone.Model.extend({
    defaults : function (){
      return {}
    },
    urlRoot : "<%= modelName.toLowerCase() %>s"
});

/*--- <%= modelName %>s Collection ---*/
var <%= modelName %>sCollection = Backbone.Collection.extend({
  url : "<%= modelName.toLowerCase() %>s",
  model: <%= modelName %>Model
});
{% endhighlight %}

### Le code applicatif

Créez (dans le même répertoire) un fichier `bb.js` avec le contenu suivant :

{% highlight javascript %}
# !/usr/bin/env node

var fs = require('fs');
var _ = require('underscore');

require.extensions['.tpl'] = function (module, filename) {
  module.exports = fs.readFileSync(filename, 'utf8');
};

var tpl  = _.template(require("./bb.tpl"));
var model_name = process.argv[2]

fs.writeFileSync(
    process.cwd() +"/" + model_name + ".js"
  , tpl({modelName :model_name})
);
{% endhighlight %}

### #   Explications

- `# !/usr/bin/env node` : rendra le fichier exécutable
- `_.template(require("./bb.tpl"))` va lire notre fichier `bb.tpl` et le transforme en objet template pour Underscore
- `process.cwd()` permet de connaître le répertoire d'où l'on appelle la commande `bb`
- `process.argv[2]` permet d'obtenir le 1er argument passé à la commande `bb` (comme par exemple `bb Human`)
- `tpl({modelName :model_name })` : on "explique" au template que l'on passe le contenu de `model_name` à `modelName` définie dans le template


### Enregistrez votre outil

Pour que votre nouvelle commande soit disponible "partout" (pouvoir l'appeler de n'importe quel répertoire), tapez la commande suivante (on est toujours dans notre répertoire de développement) :

    npm link

Si ce n'est pas déjà fait, cela va télécharger les dépendances nécessaires (underscrore dans notre cas), puis créer un "lien symbolique" vers votre fichier `bb.js`

Maintenant, de n'importe où, dans une console (terminal), vous pouvez taper `bb Animal` et cela vous génèrera votre fichier `Animal.js` avec votre modèle et votre collection.

Voilà, c'est très simple et utile. Si vous sentez que votre outil devient une usine à gaz, passez quand même à Yeoman ;).



