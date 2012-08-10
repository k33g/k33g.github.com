---

layout: post
title: Etre productif avec SublimeText 2
info : Etre productif avec SublimeText 2

---

#Comment être plus productif avec Sublime Text 2

Je n'utilise pas moins de 5 éditeurs de texte différents sur mon Mac :

- Textmate
- Sublime Text 2
- Coda 2
- KomodoEdit
- Chocolat

mais j'avais besoin de quelque chose de commun à Win/OSX/Linux. Et VI, je n'y arrive décidément pas ...

##Avant toute chose : Installer "Sublime Package Control"

**Sublime Package Control** permet d'installer facilement de nouvelles fonctionnalités pour SublimeText (et ce à partir de l'IHM de SublimeText).

Cf. [http://wbond.net/sublime_packages/package_control](http://wbond.net/sublime_packages/package_control)

- Ouvrir la console : `View + Show Console` (Ctrl + Backquote)
- Copier/Coller le code ci-dessous dans la console

*code :*

	import urllib2,os; pf='Package Control.sublime-package'; ipp=sublime.installed_packages_path(); os.makedirs(ipp) if not os.path.exists(ipp) else None; urllib2.install_opener(urllib2.build_opener(urllib2.ProxyHandler())); open(os.path.join(ipp,pf),'wb').write(urllib2.urlopen('http://sublime.wbond.net/'+pf.replace(' ','%20')).read()); print 'Please restart Sublime Text to finish installation'

- Valider
- Re-démarrer Sublime Text

##Lire et créer des Gists avec "Sublime GitHub"

**Sublime GitHub** va vous permettre d'écrire, lire et mettre à jour vos Gist à partir de SublimeText.

Cf. [https://github.com/bgreenlee/sublime-github](https://github.com/bgreenlee/sublime-github)

- `Ctrl + Shift + P` (ou Tools + Command Palette ...) ou `Shift + Command + P` sous OSX
- Sélectionner :  "Package Control: Install Package"
- Chercher "sublime-github"
- Valider
- Attendre quelques secondes
- C'est installé

Maintenant si vous faites à nouveau `Ctrl + Shift + P` et que vous tapez `github`, vous bénéficiez de plusieurs commandes, vous permettant de cherger, créer, mettre à jour ... vos Gists (au 1er accèss "Open Gists in editor", il vous sera demandé vos informations GitHub).

Déjà, c'est très pratique, mais cela va aussi vous permettre de ...

##... Partager vos codes snippets avec vos différentes machines

Une fonctionnalité incontournable de SublimeText est de pouvoir créer des codes-snippets. Avec l'installation de **Sublime GitHub**, vous pouvez maintenant enregistrer vos snippets dans vos gists afin de pouvoir les ré-utiliser à partir d'une autre machine.

###Créer un code snippet dans un Gist :

Je suis fan de Backbone, donc pour cela je vais créer un snippet de Model + Collection. Aller dans `Tools + New Snippet ...`.
Saisissez :

	<snippet>
		<content><![CDATA[
	//${1:model_name}
	window.${1:model_name} = Backbone.Model.extend({//instance members
	     url : "",
	     idAttribute : "_id",
	     initialize : function () {

	     },
	     default : function () {

	     }
	},{//class members
	    
	});

	window.${1:model_name}Collection = Backbone.Collection.extend({//instance members
	     model : ${1:model_name},
	     url : "",
	},{//class members
	    
	});
	]]></content>
		<tabTrigger>bbmodel</tabTrigger>
	</snippet>

Ne sauvegardez rien pour le moment
Sélectionnez tout le texte

- `Ctrl + Shift + P`
- `github`
- sélectionnez "Public Gist from selection"
- la description du Gist est demandée : Backbone model snippet for Sublime Text 2
- le nom du fichier : `https://gist.github.com/3303698`

Fermez, sans sauvegarder (c'est pour l'exercice de style)

###Charger le snippet

- `Ctrl + Shift + P`
- `github`
- sélectionnez "Open Gists in editor"
- sélectionnez `bbmodel.sublime-snippet`
- Sauvegardez le sous le nom `bbmodel.sublime-snippet` dans le répertoire :

    - sous windows 7 : `LECTEUR:\Users\VOUS\AppData\Roaming\Sublime Text 2\Packages\User`
    - sous OSX : `~/Library/Application Support/Sublime Text 2/Packages/User`
    - sous Linux : ... je n'ai pas eu le temps de me monter une VM Linux

*PS : vous pouvez l'essayer directement en tapant dans un autre fichier : bbmodel suivi de la touche tabulation*

##Visualiser un rendu markdown

Le format markdown devient incontournable (pour rédiger la doc de vos projets par exemple). Pour voir à quoi va ressembler le rendu de vos fichiers markdown à partir de SublimeText, il y a 2 solutions :

###MarkdownPreview

####Installer

- `Ctrl + Shift + P` (ou Tools + Command Palette ...)
- Sélectionner :  "Package Control: Install Package"
- Chercher : markdowndpreview
- Installer

####Utiliser

Lorsque vous êtes en édition d'un fichier markdown : `Ctrl + Shift + P` puis taper `markdown preview` (vous aurez le choix entre la preview dans le navigateur ou le code source html généré dans l'éditeur) et valider.

###MarkdownBuild

####Installer

- `Ctrl + Shift + P` (ou Tools + Command Palette ...)
- Sélectionner :  "Package Control: Install Package"
- Chercher : markdowndbuils
- Installer

####Utiliser

Lorsque vous êtes en édition d'un fichier markdown : `Ctrl + B`, cela ouvrira la preview dans votre navigateur par défaut.

##Templates de projets avec STProjectMaker

**STProjectMaker** vous permet de créer des projets à partir de templates de projet.

Cf. [https://github.com/bit101/STProjectMaker](https://github.com/bit101/STProjectMaker)

####Installer

- `Ctrl + Shift + P` (ou Tools + Command Palette ...)
- Sélectionner :  "Package Control: Install Package"
- Chercher : stprojectmaker
- Installer

Aller ensuite dans le menu `Preferences/Key Bindings - User` et ajouter ceci :

	[
    	{ "keys": ["ctrl+shift+n"], "command": "project_maker" }
	]

Vous pourrez donc lancer **STProjectMaker** avec la combinaison de touches `ctrl+shift+n`.

*Vous pouvez très bien choisir un autre raccourcis clavier*

####Créer un template projet

Vous trouverez des exemples ici, c'est très facile :

- sous windows : `VOTRE_DISQUE:\Users\VOTRE_NOM\AppData\Roaming\Sublime Text 2\Packages\STProjectMaker\Templates`
- sous OSX : `~/Library/Application Support/Sublime Text 2/Packages/STProjectMaker/Templates/`
- sous linux : ... je n'ai pas eu le temps de me monter une VM Linux

Si vous voulez tester, je me suis créer un template pour mes projets Backbone [https://github.com/k33g/bb-total](https://github.com/k33g/bb-total). Pour l'installer, télécharger le zip [https://github.com/k33g/bb-total/zipball/master](https://github.com/k33g/bb-total/zipball/master), dézipper dans le répertoire `Templates` de **STProjectMaker**. Testez.

Sous OSX vous pouvez faire comme ceci :

	cd ~/"Library/Application Support/Sublime Text 2/Packages/STProjectMaker/Templates/"
	curl -L https://github.com/k33g/bb-total/tarball/master | tar xf -

*Pour une raison que j'ignore pour le moment, a*

Voilà. Vous avez vu une infime partie de ce qui est possible avec SublimeText. Mais j'espère vous avoir donné envie de l'essayer.





