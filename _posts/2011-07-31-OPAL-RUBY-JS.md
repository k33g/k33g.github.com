---

layout: post
title: Opal, du Ruby dans votre navigateur
info : Ruby en js en mode runtime (pas compilé)

---

#Un bijou : Opal, un runtime ruby en javascript

Sur le même principe que CoffeeScript, [Opal](http://adambeynon.github.com/opal/) est un runtime ruby écrit en JS. Vous pouvez compiler le code ruby en JS, ou l'utiliser directement dans votre navigateur avec le runtime et le parser (ça va être un peu lent mais ça reste utilisable). C'est ce 2ème mode que nous allons tester.

##Mise en oeuvre, Classes et héritage

Récupérez [http://adambeynon.github.com/opal/js/opal.js](http://adambeynon.github.com/opal/js/opal.js) et [http://adambeynon.github.com/opal/js/opal-parser.js](http://adambeynon.github.com/opal/js/opal-parser.js).

Puis créez une page comme ci-dessous :


    <!DOCTYPE HTML>
    <html>
    <head>
        <title></title>
        <script src="opal.js"></script>
        <script src="opal-parser.js"></script>
    </head>
    <body>

    </body>

    <script type="text/ruby" charset="utf-8">

        class Human

            def initialize(firstname, lastname)
                @firstname = firstname
                @lastname = lastname
            end

            def setFirstName(firstname)
                @firstname = firstname
            end

            def setLastName(lastname)
                @lastname = lastname
            end

            def getFirstName
                return @firstname
            end

            def getLastName
                return @lastname
            end

        end

        Bob = Human.new "Bob", "Morane"

        puts Bob.getFirstName + " " + Bob.getLastName

        Bob.setLastName "MORANE"

        puts Bob.getFirstName + " " + Bob.getLastName

        Sam = Human.new "Sam", "LePirate"

        puts Sam.getFirstName + " " + Sam.getLastName
        puts Bob.getFirstName + " " + Bob.getLastName

        class SuperHeroe < Human

            def fly
                return @firstname + " " + @lastname + " is flying"
            end
        end

        Clark = SuperHeroe.new "Clark", "Kent"

        puts Clark.fly

    </script>
    </html>


Lancez dans le navigateur, avec la console ouverte, vous devriez voir apparaître ceci :

    Bob Morane
    Bob MORANE
    Sam LePirate
    Bob MORANE
    Clark Kent is flying

Funny !, non ?

##Interagir avec javascript

Modifiez ou créez une nouvelle page, comme celle ci :


    <!DOCTYPE HTML>
    <html>
    <head>
        <title></title>
        <script src="opal.js"></script>
        <script src="opal-parser.js"></script>
    </head>
    <body>

    </body>

    <script>

        function test(args) {
            console.log(args);
        }

    </script>

    <script type="text/ruby" charset="utf-8">
        #Bridge between JS and Ruby

        #exec global js code
        def tryThat(args)
            `test(args);`
        end

        tryThat "Hello, i'm called by Opal"
    </script>
    </html>


Lancez dans le navigateur, avec la console ouverte, vous devriez voir apparaître ceci :

    Hello, i'm called by Opal

**REMARQUE IMPORTANTE :**

Pour appeler du code js "inline", il faut l'entourer de **backticks**, à ne pas confondre avec des guillemets simples :

    donc `test(args);` et pas 'test(args);'


##Interagir avec le dom

Si, c'est possible aussi!

Modifiez ou créez une nouvelle page, comme celle ci :


    <!DOCTYPE HTML>
    <html>
    <head>
        <title></title>
        <script src="opal.js"></script>
        <script src="opal-parser.js"></script>
    </head>
    <body>
        <h1>---Hello---</h1>
    </body>

    <script type="text/ruby" charset="utf-8">
        #Bridge between JS and Ruby
        class rQuery
            def setHtml(selector,txt)
                `document.querySelector(selector).innerHTML = txt;`
            end

            def getHtml(selector)
                `return document.querySelector(selector).innerHTML;`
            end
        end

        rq = rQuery.new
        rq.setHtml "h1", "Playing with Opal"
    </script>
    </html>


Lancez dans le navigateur, une fois le runtime chargé, le contenu de la balise `<h1></h1>` devrait changer.

##Conclusion

Opal est assez jeune, mais à suivre pour les ruby's lovers.
Une fois de plus, cela démontre la puissance de JS (non ce n'est pas du troll)

Allez, bon dimanche à tous.