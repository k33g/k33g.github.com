#Créer un langage pour enfants à partir de Golo

##Introduction

Mes enfants (7 & 8 ans) me voient collé à mon micro plus qu'il ne faudrait. Un jour, ils ont souhaité que je leur explique la "programmation". C'est ma fille qui a commencé à 5 ans avec du Ruby, mais les concepts ne sont pas forcément simples, qui plus est quand à l'école ils n'ont pas encore toutes les notions de math ou de logique, sans parler de l'anglais! Donc, même si ça les attire (imaginez un truc qui compte à votre place!), ils peinent un peu (il doit aussi y avoir la pédagogie de leur père en cause).

En étudiant **Golo**, et au fur et à mesure de ma compréhension (merci [@jponge](@jponge) pour ses patientes explications), je me suis dit *"et si je me servais de Golo pour apprendre le dév à mes rejetons ?"*. Du coup je leur ai demandé de commencer à me "spécifier" un langage sur papier (vu qu'ils sont punis de télé, de tablette, d'ordi pour 4 semaines, ça les occupe bien). A ma grande surprise, ils sont en train de le faire, et en plus ils avancent bien et ils ont choisi le thème du Zoo.

Je me retrouve donc dans une situation, où il va falloir faire ce langage pour enfants! Donc ce matin, j'ai voulu qualifier la faisabilité de ce projet (et ma capacité à le faire).

**Et bien, je vous l'affirme, Golo est un parfait "générateur" de langage!!!** ... et je ne vais pas passer pour un incapable auprès de mes 2 dictateurs préférés :).

Voci donc la recette du jour (et je m'amuse comme un petit fou) pour créer un langage, et se la jouer grave ensuite :)

Pour ceux qui ne connaisse pas **Golo**, c'est par ici [http://golo-lang.org/](http://golo-lang.org/).

Allez, c'est parti, nous allons voir :

- comment ajouter des "objets" utilisables dans Golo
- comment ajouter des fonctions prédéfinies
- et même comment changer certains verbes de base

**Pas d'inquiétude, c'est ULTRA-FACILE.**

##Préparation

Commencez donc par cloner le repository de golo :

    git clone https://github.com/golo-lang/golo-lang.git

vous disposez maintenant de tout ce qu'il faut pour vous amuser :)

##Ajouter des animaux

... je vous rappelle que le thème, c'est le **Zoo**.

Nous allons donc déjà ajouter simplement de nouveaux "objets" à Golo, que nous allons implémenter dans le package `gololang.zoo`, pour cela dans le projet **Golo**, vous devez, au sein du package `gololang`, créer un package `zoo` :

![](https://raw.github.com/k33g/k33g.github.com/master/images/zoogolo.jpg)

Ensuite, nous développons quelques classes et interfaces qui seront la base de notre langage pour enfants :

![](https://raw.github.com/k33g/k33g.github.com/master/images/zoodiag.jpg)

**Animal.java :**
```java
package gololang.zoo;

public interface Animal {
    public void sePositionne(Integer x, Integer y);
}
```

**Position.java**
```java
package gololang.zoo;

public class Position {
    private Integer _x = null;
    private Integer _y = null;

    public Integer x() { return _x; }
    public Position x(Integer value) { _x = value; return this; }

    public Integer y() { return _y; }
    public Position y(Integer value) { _y = value; return this; }

    public Position(Integer _x, Integer _y) {
        this._x = _x;
        this._y = _y;
    }

    public Position() {}
}
```

**Mammifere.java**
```java
package gololang.zoo;

public class Mammifere implements Animal {

    private Position _position = null;
    private String _nom = null;

    @Override
    public void sePositionne(Integer x, Integer y) {
        _position.x(x);
        _position.y(y);
    }

    public Mammifere(String nom) {
        this._nom = nom;
    }

    public Mammifere(String nom, Position position) {
        this._position = position;
        this._nom = nom;
    }

    public String nom() {
        return _nom;
    }

    public Animal nom(String nom) {
        this._nom = nom;
        return this;
    }

    public Position position() {
        return _position;
    }

    public Animal position(Position _position) {
        this._position = _position;
        return this;
    }
}
```

**Lion.java**
```java
package gololang.zoo;

public class Lion extends Mammifere {
    public Lion(String nom) {
        super(nom);
    }

    public Lion(String nom, Position position) {
        super(nom, position);
    }

    public String rugir() { return "Groooooaaaaaarrrrr!!!";}
    public String rugir(String paroles) { return paroles + "Groooooaaaaaarrrrr!!!";}
}
```

##Compiler

Nous pouvons déjà recompiler Golo. Vous vous positionnez dans le répertore `/golo-lang` et "lancez" la commande suivante :

    rake special:bootstrap

Au bout de quelques instants (quand c'est terminé donc) vous obtenez le répertoire `/<chez_vous>/golo-lang/target/golo-0-preview3-SNAPSHOT-distribution/golo-0-preview3-SNAPSHOT` (en fonction des version les noms peuvent changer) qui contient un Golo utilisable. Faites donc pointer vos variables d'environnement dessus :

    GOLO_HOME=/<chez_vous>/golo-lang/target/golo-0-preview3-SNAPSHOT-distribution/golo-0-preview3-SNAPSHOT; export GOLO_HOME
    export PATH=$PATH:$GOLO_HOME/bin


##Utiliser

Nous allons maintenant créer un script `zoo.golo` :

```coffeescript
module zoo

import gololang.zoo.Lion
import gololang.zoo.Position

function main = |args| {

    let leo = Lion("Léo le lion")

    println(leo:nom())

    let pos = Position(4, 7)

    leo:position(pos)

    println("x: " + leo:position():x() + " y: " + leo:position():y())

    println(leo:rugir())
    println(leo:rugir("Je suis " + leo:nom() + "... "))

}
```

Lancez : `gologolo zoo.golo`, et ... :

    Léo le lion
    x: 4 y: 7
    Groooooaaaaaarrrrr!!!
    Je suis Léo le lion... Groooooaaaaaarrrrr!!!

N'êtes vous pas déjà un peu fier, là ?

##Ajouter une fonction prédéfinie

Le projet **Golo** a une classe très pratique `Predefined.java` dans le package `gololang`, qui permet d'ajouter des sortes de mots-clé. C'est là que vous avez l'implémentation de `println()` par exemple. Pour résumer, `Predefined.java` comporte un ensemble de méthodes statiques réutilisables en **Golo** comme mots-clé. Voyon donc comment ajouter des mots-clé :

Je n'aime définitivement pas concaténer des chaînes de caractères, donc à la place de `"x: " + leo:position():x() + " y: " + leo:position():y()` j'aimerais pouvoir écrire `"x: %s y: %s", leo:position():x(), leo:position():y()` ou à la place de `"Je suis " + leo:nom() + "... "` avoir `"Je suis %s ... ",leo:nom()`. Allons-y!

Ajoutez les 2 méthodes ci-dessous dans `Predefined.java` :

**formater:**
```java
public static String formater(String message, Object... args) {
    return String.format(message, args);
}
```

**afficher:**
```java
public static void afficher(String message, Object... args) {
    System.out.println(formater(message, args));
}
```

Maintenant, compilez à nouveau **Golo** (`rake special:bootstrap`) et modifiez votre script `zoo.golo` de la manière suivante :

```coffeescript
module zoo

import gololang.zoo.Lion
import gololang.zoo.Position

function main = |args| {

    let leo = Lion("Léo le lion")

    afficher("Mon est %s", leo:nom())

    let pos = Position(4, 7)

    leo:position(pos)

    afficher("x: %s y: %s", leo:position():x(), leo:position():y())
    afficher("x: %03d y: %03d", leo:position():x(), leo:position():y())

    afficher("Léo va rugir : %s"
        , leo:rugir(
            formater("Je suis %s ... ",leo:nom())
        )
    )
}
```

Lancez : `gologolo zoo.golo`, et ... :

    Mon est Léo le lion
    x: 4 y: 7
    x: 004 y: 007
    Léo va rugir : Je suis Léo le lion ... Groooooaaaaaarrrrr!!!

Et là, au sentiment de fierté précédent, s'ajoute un début d'impression, voire d'intelligence "inhabituelle" ;) De là à dire que **Golo** rend intelligent, il n'y a qu'un pas ... que je franchis allègrement :)))

##Encore un peu plus loin

Depuis un moment, vous devez vous dire que ma manie de mettre du français dans mon code est un peu bizarre, voire c'est mal, ça ne se fait pas, je suis un hérétique! Je vous rappelle que le besoin initial, c'est apprendre la programmation à de jeunes enfants, alors si en plus, ils doivent apprendre l'anglais, ils vont devenir chèvres.

Avez-vous essayé d'expliquer le concept de variable et valeur de variable à des enfants de 8 ans et moins de 8 ans (5 ans!) ? En ce qui me concerne, la notion de **boîte d'alumettes**, marche pas mal (avec un nombre d'alumettes dans la boîte) ou la notion de **case** peut aussi faire l'affaire.

Donc à la place de `let leo = Lion("Léo le lion")` je voudrais `la_case leo = Lion("Léo le lion")` et comme j'ai pris de l'assurance dans les paragraphes précédents, à la place de `if {} else {}`, je veux `si {} sinon {}`. Voui Monsieur!

Eh bien, c'est extrêment facile :

Allez faire un tour dans le projet **Golo** par ici : `/src/main/jjtree/Golo.jjt` :

- cherchez `< LET: "let" >` et remplacez par `< LET: ("let" | "la_case") >` (vous pourrez ainsi continuer à utiliser `let`)
- cherchez `< IF: "if" >` et remplacez par `< IF: ("if" | "si") >`
- cherchez `< ELSE: "else" >` et remplacez par `< ELSE: ("else" | "sinon") >` 

Compilez à nouveau **Golo** (`rake special:bootstrap`), et maintenant vous pouvez écrire des choses comme celle-ci :

```coffeescript
module zoo

import gololang.zoo.Lion
import gololang.zoo.Position

function main = |args| {

    la_case leo = Lion("Léo le lion")

    la_case pos = Position(4, 7)

    leo:position(pos)

    si leo:position():x() > 3 {
        afficher("x: %s (est supérieur à 3) y: %s", leo:position():x(), leo:position():y())
    } sinon {
        afficher("x: %s (est inférieur à 3) y: %s", leo:position():x(), leo:position():y())
    }

}
```

Je n'ai maintenant plus qu'à tester avec mes petits bouts. Je vous en donnerais des nouvelles. De votre côté, plus d'excuses pour vous mettre à **Golo**, *augmenter Golo ...* ;)

 *42.* ;)