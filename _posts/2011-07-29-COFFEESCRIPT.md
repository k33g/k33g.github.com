---

layout: post
title: Jouez avec CoffeeScript sans rien installer
info : Utiliser CoffeeScript en mode runtime (pas compilé)

---

#Jouez avec CoffeeScript sans rien installer

[CoffeeScript](http://jashkenas.github.com/coffee-script/), c'est le langage de script qui compile du JS et qui défraye la chronique en ce moment. On aime, on aime pas, mais il est un parfait exemple de ce qui est possible avec JS. Je n'accroche pas forcément avec la syntaxe (un peu trop python-like à mon goût), mais je peux encore changer d'avis. Néanmoins, c'est à suivre de très près : dernièrement le papa de JS (Brendan Eich) a expliqué qu'il allait s'inspirer de certaines partie du code pour [Traceur-Compiler](http://code.google.com/p/traceur-compiler/) donc pour une future version de JS (vous pouvez lire un ancien article que j'avais écrit : [Les Classes arrivent chez JavaScript](https://github.com/k33g/articles/blob/master/2011-05-06-TRACEUR-COMPILER.md))

Le but de ce post n'est pas de vous faire un tuto sur CoffeeScript, mais juste de vous expliquer comment le tester sans avoir à installer NodeJS. Normalement, vous codez en CoffeeScript, vous compilez en JS avec NodeJS et vous publiez votre code. Mais il existe aussi un mode runtime très pratique.

PS : le repo CoffeeScript est ici : [https://github.com/jashkenas/coffee-script](https://github.com/jashkenas/coffee-script)

##Comment on fait ?

Premièrement, vous récupérez le runtime CoffeeScript ici : [https://raw.github.com/jashkenas/coffee-script/master/extras/coffee-script.js](https://raw.github.com/jashkenas/coffee-script/master/extras/coffee-script.js).

Ensuite vous vous créez une page html avec le code suivant :


    <!DOCTYPE HTML>
    <html>
        <head>
            <title></title>
            <script src="coffee-script.js" type="text/javascript" charset="utf-8"></script>
        </head>
        <body>

        </body>
    </html>


Et pour insérer du code CoffeeScript, vous utilisez la balise `<script type="text/coffeescript">`, par exemple :

    <!DOCTYPE HTML>
    <html>
        <head>
            <title></title>
            <script src="coffee-script.js" type="text/javascript" charset="utf-8"></script>
        </head>
        <body>

        </body>
        <script type="text/coffeescript">
            # Some CoffeeScript
            Cars = ["Ford", "Dodge", "Chevy", "Toyota", "Honda"]
            console.log Cars
        </script>
    </html>


Et Hop! c'est fini

##Externaliser les scripts

Si vous êtes dans un "contexte http", donc si votre page est accessible via `http://mondomaine/mapage.html` plutôt que via `file:///mapage.html`, vous pouvez très bien faire ceci :


    <script src="test.coffee" type="text/coffeescript"></script>


en mode local vous obtiendrez un joli `XMLHttpRequest cannot load file://localhost/test.coffee. Cross origin requests are only supported for HTTP.`.

##Externaliser les scripts et les faire fonctionner en mode local

Si, c'est possible. Je vous montre comment je fais sous Chrome et sous OSX, après vous adaptez. En fait il faut lancer Chrome en mode `allow-file-access-from-files :

    open -b com.google.chrome --args --allow-file-access-from-files

Pour que cela fonctionne, il faut d'abord quitter complètement Chrome.

Vous pouvez maintenant ouvrir votre page en mode `file:///`.

**Et voilà, vous pouvez commencer à vous amusez avec CoffeeScript. :)**

Au fait vous saviez que l'on peut faire aussi du Ruby dans le navigateur ? ... ;)