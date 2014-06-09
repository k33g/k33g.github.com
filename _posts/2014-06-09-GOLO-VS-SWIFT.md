---

layout: post
title: Golo et Swift, étude comparée
info : Golo et Swift, étude comparée

---

#Golo et Swift, étude comparée

##Introduction

Le 2 juin 2014, lors de la keynote de la WWDC d'Apple, un nouveau langage pour créer des applications iOS, OSX, appelé **Swift** a été présenté. Il rappelle beaucoup **Groovy** (voir le comparatif **Groovy** versus **Swift**: [http://glaforge.appspot.com/article/apple-s-swift-programming-language-inspired-by-groovy](http://glaforge.appspot.com/article/apple-s-swift-programming-language-inspired-by-groovy) par Guillaume Laforge). 

Golo (non typé) n'a certainement pas inspiré Swift (typé), mais je retrouve quelques aspects fonctionnels similaire. Voyons de quelle manière à travers quelques exemples de codes comparés.

*Pour ceux qui ne connaissent pas Golo, c'est un langage dynamique pour la JVM. Plus d'informations ici: [http://golo-lang.org/](http://golo-lang.org/).*

##Fonctions

###Une fonction qui ne retourne rien (void)

**Swift:**

{% highlight groovy %}
func printHello(message: String) {
  println("hello \(message)")
}

printHello("world")
{% endhighlight %}

**Golo:**

{% highlight coffeescript %}
function printHello = |message| {
  println("hello " + message)
}

printHello("world")
{% endhighlight %}

ou:

{% highlight coffeescript %}
function printHello = |message| -> println("hello " + message)
{% endhighlight %}

###Une fonction qui retourne quelque chose

**Swift:**

{% highlight groovy %}
func hello(message: String) -> String {
  return "hello \(message)"
}

hello("world")
{% endhighlight %}

**Golo:**

{% highlight coffeescript %}
function hello = |message| {
  return "hello " + message
}
{% endhighlight %}

ou:

{% highlight coffeescript %}
function hello = |message| -> "hello " + message
{% endhighlight %}

##Nested functions (ou Closures ?)

Les "nested functions" sont des définitions de fonctions à l'intérieur de fonctions, ce qui signifie qu'elles ne sont accessibles qu'à l'intérieur de la fonction qui les contient.

###Exemple simple

**Swift:**

{% highlight groovy %}
func salut(message: String) -> String {
  func nestedHello(message: String) -> String {
    return "Hello \(message)"
  }
  return nestedHello(message)
}

salut("World !!!")
{% endhighlight %}

**Golo:**

{% highlight coffeescript %}
function salut = |message| {
  let nestedHello = |message| -> "hello " + message
  return nestedHello(message)
}

salut("World !!!")
{% endhighlight %}

Mais une fonction peut aussi retourner une fonction.

###Une fonction qui retourne une fonction

**Swift:**

{% highlight groovy %}
func hola(startMessage: String) -> String -> String { 

  func nestedHello(endMessage: String) -> String {
    return "\(startMessage) \(endMessage)"
  }
  return nestedHello
}
{% endhighlight %}

Et cette fois ci l'appel de notre méthode `hola` se fera de la façon suivante:

{% highlight groovy %}
hola("Hello")("World !!!")
{% endhighlight %}

**Golo:**

{% highlight coffeescript %}
function hola = |startMessage| {
  let nestedHello = |endMessage| -> startMessage + " " + endMessage
  return nestedHello
}
{% endhighlight %}

ou

{% highlight coffeescript %}
function hola = |startMessage| ->
  |endMessage| -> startMessage + " " + endMessage    
{% endhighlight %}

Qui sera aussi appelé de cette manière:

{% highlight coffeescript %}
hola("Hello")("World !!!")
{% endhighlight %}

###Une fonction comme paramètre

**Swift:**

{% highlight groovy %}
func morgen(startMessage:String, endMessage: String -> String) -> String {
  let param = "World"
  return "\(startMessage) \(endMessage(param))"
}

func message(msg: String) -> String {
  return "\(msg) !!!"
}

morgen("Hello", message)
{% endhighlight %}

**Golo:**

{% highlight coffeescript %}
function morgen = |startMessage, endMessage| {
  return startMessage + " " + endMessage("World")
}
{% endhighlight %}

puis:

{% highlight coffeescript %}
let message = |msg| -> msg + " !!!"
morgen("Hello", message)
{% endhighlight %}

##"Closures Expressions"

Selon Apple, une "Closure Expression" est un moyen "synthétique" pour écrire/définir une closure. C'est plus simplement ce qui va nous permettre de "simplifier" notre exemple précédent en définissant "inline" le paramètre `endMessage` sans passer par la fonction intermédiaire `message` de la façon suivante:

**Swift:**

{% highlight groovy %}
morgen("Hello", { (msg: String) -> String in
  return "\(msg) !!!"
})
{% endhighlight %}

**Golo:**

{% highlight coffeescript %}
morgen("Hello", |msg| -> msg + " !!!")
{% endhighlight %}

*Lire les "Closures en Golo" : [http://golo-lang.org/documentation/next/#_closures](http://golo-lang.org/documentation/next/#_closures).*

##Un peu plus loin, avec les extensions

Les **"extensions"** dans **Swift** permettent d'ajouter des fonctionnalités (méthodes) à des types (Classes, Structures ...), ce qui permet "d'augmenter" le langage lui même en alliant les "extensions" aux "closures expressions" et aux "generics".

En **Golo** on parle des **"augmentations"** (le principe est le même).

###Méthode first()

Il n'y a pas de méthode `first` sur le type `Array`. Qu'à cela ne tienne, il suffit d'écrire ceci:

**Swift:**

{% highlight groovy %}
extension Array{

  func first() -> (T) {
    return self[0]
  }
}

var villes = ["Lyon", "Valence", "Chambéry"]

villes.first()
{% endhighlight %}

Et `villes.first()` retournera `Lyon`, et c'est plus "joli" (question de point de vue) que villes[0].

**Golo:**

{% highlight coffeescript %}
augment java.util.List {
  function first = |self| -> self: get(0)
}
{% endhighlight %}

et on l'utilise comme ceci:

{% highlight coffeescript %}
var villes = list["Lyon", "Valence", "Chambéry"]

villes: first() # retourne "Lyon"
{% endhighlight %}

###Méthode each()

En **Swift** pour parcourir un tableau, il faut écrire ceci:

{% highlight groovy %}
for ville: String in villes {
  println(ville)
}
{% endhighlight %}

Je souhaite avoir une méthode `each` pour le type `Array`, je vais donc modifier mon `extension Array`:

{% highlight groovy %}
extension Array{

  func each(each: (T) -> ()){
    for object: T in self {
      each(object)
    }
  }
  
  func first() -> (T) {
    return self[0]
  }
}
{% endhighlight %}

Et maintenant, je peux écrire ceci:

{% highlight groovy %}
villes.each({ (item: String) in
  println(item)
})
{% endhighlight %}

L'inférence de **Swift** me permet même d'écrire ceci:

{% highlight groovy %}
villes.each({ item in
  println(item)
})
{% endhighlight %}

**Golo:**

En Golo cette augmentation existe déjà:

{% highlight coffeescript %}
villes: each(|ville| -> println(ville))
{% endhighlight %}

##Les classes

La définition d'une classe en **Swift** reste somme toute très classique:

{% highlight groovy %}
class Human {
  
  var _firstName: String
  var _lastName: String
  
  init(firstName: String, lastName: String) {
    _firstName = firstName
    _lastName = lastName
  }
  
  init() {
    _firstName = "John"
    _lastName = "Doe"
  }
  
  func hello() -> String {
    return "Hello, i'm \(_firstName) \(_lastName)"
  }

}

let John = Human()

John.hello()

let Bob = Human(firstName:"Bob", lastName:"Morane")

Bob.hello()
{% endhighlight %}

En **Golo:**, il n'y a pas de classe ni d'interface, mais il existe les **DynamicObjects** qui couplés à une fonction comme constructeur peuvent "faire office de classe":

{% highlight coffeescript %}
function Human =  ->
  DynamicObject()
    : firstName("John")
    : lastName("Doe")
    : define("hello", |self| {
        return "Hello, i'm " + self: firstName() + " " + self: lastName()
      })

let John = Human()

John: hello() # retourne "Hello, i'm John Doe"

let Bob = Human(): firstName("Bob"): lastName("Morane")

Bob: hello() # retourne "Hello, i'm Bob Morane"
{% endhighlight %}

**Remarque:** En Swift comme en Golo il n'y a pas le concept de variable privée (sauf un cas particulier en Golo), il faut donc encapsuler les Classes dans des fonctions pour Swift, et les DynamicObjects dans des fonctions pour Golo.

###Propriétés

Avec **Swift**, comme en Objective-C, le concept de **propriétés** existe et notamment celui de **Computed Properties** (pour remplacer les getters et les setters):

{% highlight groovy %}
var firstName: String {
  get {return _firstName}
  set(value) {
    _firstName = value
  }
}

var lastName: String {
  get {return _lastName}
  set(value) {
    _lastName = value
  }
}
{% endhighlight %}

En **Golo**, de fait, les membres d'un DynamicObject qui ne sont pas des méthodes sont des propriétés (des getters et setters):

{% highlight coffeescript %}
let Bob = DynamicObject(): name("Bob")
Bob: name() # retourne "Bob"
Bob: name("Bob Morane") # change la valeur de name
{% endhighlight %}

###Héritage

En ce qui concerne l'héritage, en **Swift** il suffit de déclarer juste après le nom de la classe le type (la classe) dont elle hérite:

{% highlight groovy %}
class SuperHero: Human {
  var power = "walking"
  var nickName = "Kick-Ass"
  
  override func hello() -> String {
    return super.hello() + ", my Hero name is \(nickName) and i'm \(power)"
  }
}

let Clark = SuperHero(firstName: "Clark", lastName: "Kent")
Clark.nickName = "SuperMan"
Clark.power = "flying"

Clark.hello() // retourne "Hello, i'm Clark Kent, my Hero name is SuperMan and i'm flying"
{% endhighlight %}

En **Golo:**, nous n'avons pas de classe mais nous pouvons "faire des **mixins**" de DynamicObject() :

{% highlight coffeescript %}
function Human =  -> DynamicObject()
  : firstName("John")
  : lastName("Doe")         
  : define("hello", |self| {
      return "Hello, i'm " + self: firstName() + " " + self: firstName()
    })

function SuperHero = -> DynamicObject()
  : power("walking")
  : nickName("Kick-Ass")
  : define("hello", |self| {
      return "Hello, i'm " + self: firstName() + " " + self: firstName() +
        ", my Hero name is " + self: nickName() + " and i'm " + self: power()
    })

let Clark = Human(): mixin(SuperHero())
  : firstName("Clark"): lastName("Kent")
  : nickName("SuperMan"): power("flying")

Clark: hello() # retourne "Hello, i'm Clark Clark, my Hero name is SuperMan and i'm flying"
{% endhighlight %}

##Les Structures

En plus des classes, **Swift** propose les structures. La déclaration se fait de la même manière que les classes, une structure peut implémenter un protocole (interface), être étendue par une extension, par contre elle ne peut hériter. Mais le plus important c'est que les classes sont des types par **référence** et les structures des types par **valeur**:

{% highlight groovy %}
let Donald = Duck(firstName: "Donald", lastName: "Duck")
var Daffy = Donald

Daffy.firstName = "Daffy"

Donald.hello() // retourne Hello, i'm Donald Duck
Daffy.hello() // retourne Hello, i'm Daffy Duck
{% endhighlight %}

`Donald.hello()` retournera toujours `Hello, i'm Donald Duck`. `Daffy` est une copie de `Donald` et donc devient indépendant de `Donald`. Vous pouvez notez que les structures disposent d'un constructeur par défaut que nous ne sommes pas obligés de définir.

En **Golo:**, il existe aussi des structures qui ne contiennent pas de méthode dans leur définition, mais qui peuvent être augmentées. Elles disposent aussi d'un constructeur par défaut. Mais **attention**, les structures Golo, à la différence de Swift, sont des types par référence, il faudra donc utiliser la méthode `copy()` des structures Golo pour faire une copie "par valeur":

{% highlight coffeescript %}
struct Duck =  { firstName, lastName }

augment Duck {
  function hello = |self| -> "Hello, i'm " + self: firstName() + " " + self: lastName()
}

let Donald = Duck("Donald", "Duck")
let Daffy = Donald: copy()

Daffy: firstName("Daffy")

println(Donald: hello()) # retourne "Hello, i'm Donald Duck"
println(Daffy: hello()) # retourne "Hello, i'm Daffy Duck"
{% endhighlight %}

*Remarque: on peut avoir des membres privés dans les structures en préfixant les noms des membres par `_`, ils deviendrons ainsi inaccessibles. Cf. [http://golo-lang.org/documentation/next/#_private_members](http://golo-lang.org/documentation/next/#_private_members)*

##Conclusion

Il y a quand même une distance entre les 2 langages qui n'ont pas la même vocation. Cependant le côté fonctionnel des 2 me permet de calquer ma logique de programmation dans les 2.




