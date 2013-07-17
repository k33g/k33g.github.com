---

layout: post
title: En attendant les classes
info : goloClasses

---

#Golo, en attendant les classes

Pendant la période estivale, le [Doc](https://github.com/jponge) ne reste pas inactif et **Golo** "augmente" gentiment ses capacités, notamment avec les [Collection literals](https://github.com/golo-lang/golo-lang/pull/61) et les [Structures](https://sourceforge.net/p/golo-lang/discussion/users/thread/84255b46/) (pas encore disponibles sur le repository officiel). Ces quelques nouveautés de juillet m'ont poussé à faire un petit exercice : en attendant d'avoir des classes, quelle est la meilleure solutions pour les simuler ?

Alors, jusqu'ici, mon mot-clé préféré dans **Golo** est `DynamicObject`, même si le [Doc](https://github.com/jponge) me déconseille (pour des raisons d'optimisation) de l'utiliser, j'en use et en abuse. Je commencerait donc par lui.

##Objectif

L'objectif premier, c'est de simuler une bonne vieille classe "à la Java" comme celle ci :

    public class Human {
        public String firstName;
        public String lastName;

        public Human(String firstName, String lastName) {
            this.firstName = firstName;
            this.lastName = lastName;
        }

        public String hello() {
            return "hello " + this.firstName + " " + this.lastName;
        }
    }

Pour cela, je vais vous proposer 3 solutions :

- avec un **DynamicObject** et une fonction (qui sert de constructeur)
- avec une **HashMap** (nous verrons ainsi la nouvelle notation des "Collection literals") et une fonction
- avec une **Structure** et une fonction

##DynamicObject par l'exemple

Le code sera celui-ci : 

    function DynamicHuman = |firstName, lastName| {
        return DynamicObject()
            :firstName(firstName)
            :lastName(lastName)
            :define("hello",|this|->
                "hello %s %s":format(this:firstName(), this:lastName())
            )
    }

Nous l'utiliserons comme ceci : 

    let bob = DynamicHuman("Bob", "Morane")
    println(bob:hello())

Pour plus d'informations sur les DynamicObjects, c'est par-ici [http://golo-lang.org/documentation/next/#_dynamic_objects](http://golo-lang.org/documentation/next/#_dynamic_objects).

##Une "pseudo-classe" avec une HashMap

Le code sera celui-ci : 

    function FakeHuman = |firstName, lastName| {
        let h = map[
            ["firstName", firstName],
            ["lastName", lastName]
        ]
        h:put("hello", -> "hello %s %s":format(h:get("firstName"), h:get("lastName")))
        return h
    }

**Remarque** : vous notez qu'un des éléments de la HashMap est une fonction (lambada)

Nous l'utiliserons comme ceci : 

    let bob = FakeHuman("Bob", "Morane")
    println(bob:get("hello"):invokeWithArguments())

**Remarque** : la notation est moins sexy qu'avec un DynamicObject, mais pourquoi pas ... A priori c'est plus optimisé qu'un DynamicObject.

##Struct / la nouveauté de la semaine

Lundi, apparaît un thread à propos d'une nouvelle fonctionnalité : `struct` [https://sourceforge.net/p/golo-lang/discussion/users/thread/84255b46/](https://sourceforge.net/p/golo-lang/discussion/users/thread/84255b46/). Et cette phrase : *"Indeed, it compiles to JVM classes, and as such, they are way faster than dynamic objects."* m'interpelle sur 2 points : 

- faster than dynamic objects
- it compiles to JVM classes

Donc plus rapide, ok ça se tente. **Golo** compile ça en classe, ça devrait pouvoir dire que l'on peut utiliser `augment` pour coller des méthodes aux structures. J'ai donc fait ceci (et ça marche) :
    
    module bench

    struct human = {firstName, lastName}

    function StructHuman = |firstName, lastName| {
        return human(firstName, lastName)
    }

    augment bench.types.human {
        function hello = |this| -> 
            "hello %s %s":format(this:firstName(), this:lastName())
    }

Et nous l'utiliserons comme ceci : 

    let bob = StructHuman("Bob", "Morane")
    println(bob:hello())

##Oui, et alors ?

Finalement que faut-il utiliser ? (rappelez-vous, je suis très fan des DynamicObjects).

Donc, nouvel exercice : **Benchmark**, je vais "instancier" et appeler la méthode `hello()` 100 000 fois pour chacune des solutions et calculer la durée dans chacun des cas. J'obtiens ceci :

    duration for 100000 DynamicHumans : 12206 ms
    duration for 100000 FakeHumans    : 867 ms
    duration for 100000 StructHumans  : 233 ms

... Y'a pas photo, `struct` wins! ... Je vais aller casser mes codes ;)

 *42.* ;)

*Vous trouverez le code de benchmark ici : [https://gist.github.com/k33g/6018173](https://gist.github.com/k33g/6018173)*


 