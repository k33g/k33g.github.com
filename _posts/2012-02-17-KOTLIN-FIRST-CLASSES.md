---

layout: post
title: Faites vos classes en Kotlin
info : Faites vos classes en Kotlin

---

#Faites vos classes en Kotlin

Juste quelques bouts de code pour montrer de quelle manière on peut faire ses 1ères classes en Kotlin.

##Mode rapide

	class Human(val firstName : String, val lastName : String) {

	    fun sayHello() {
	        println("Hello $firstName $lastName")
	    }
	}

	fun main(args : Array<String>) {
	    var bob = Human("bob", "morane")
	    bob.sayHello()

	    println(bob.firstName+" "+bob.lastName)

	}

###Exécution :

	Hello bob morane
	bob morane

###A noter :

- typage : à droite
- mot clé pour une fonction ou méthode : `fun`
- possibilité de déclarer les membres en paramètres de la classe (on parle de "primary constructor")
- propriétés générées automatiquement
- notez le mot-clé `val`, vous ne pourrez pas par exemple dans la méthode `sayHello` faire un `firstName = "Hello"` ou un `this.firstName = "Hello"` (vous ne pouvez pas "ré-assigner" les `val`)
- si bous n'utilisez pas `val` (ou `var`) en paramètre du constructeur primaire, vous n'aurez pas de propriété générée
- pas de `;`, mais vous pouvez quand même en mettre
- pas de `new`, instanciation à l'affectation
- pas d'obligation de "typer" `bob`, mais vous pourriez écrire `var bob : Human = Human("bob", "morane")`

##On ajoute un constructeur

	class Human(val firstName : String, val lastName : String) {

	    Human() {
	        println("I'm the constructor of $firstName $lastName")
	    }

	    fun sayHello() {
	        println("Hello $firstName $lastName")
	    }
	}

###Exécution :

	I'm the constructor of bob morane
	Hello bob morane
	bob morane

##Cool : les propriétés ! (mais qu'est ce que vous foutez chez Oracle/Java !?!)

	class Human(first : String, last : String) {
	    private var _firstName = first
	    private var _lastName = last

	    public var FirstName : String
	    get() {
	        return _firstName
	    }
	    set(value) {
	        _firstName = value
	    }

	    public var LastName : String
	    get() { return _lastName }
	    set(value) { _lastName = value }

	    Human() {
	        println("I'm the constructor of $_firstName $_lastName")
	    }

	    fun sayHello() {
	        println("Hello $_firstName $_lastName")
	    }

	}

	fun main(args : Array<String>) {
	    var bob  = Human("bob", "morane")
	    bob.sayHello()

	    println(bob.FirstName+" "+bob.LastName)
	    bob.FirstName = "BOB"
	    bob.LastName = "MORANE"
	    println(bob.FirstName+" "+bob.LastName)

	}

###A noter :

- j'ai enlevé `val` dans les paramètres de la classe (du constructeur "primaire") sinon nous aurions des propriétés `first` et `last` en plus des propriétés `FirstName` et `LastName`

###Exécution :

	I'm the constructor of bob morane
	Hello bob morane
	bob morane
	BOB MORANE

##Héritage

Alors de base, les classes sont `final`, il faut donc les préfixer par le mot-clé `open` si l'on souhaite en hériter :

	//ajouter open devant la classe
	
	open class Human(first : String, last : String) {
	    private var _firstName = first
	    private var _lastName = last

	    public var FirstName : String
	    get() {
	        return _firstName
	    }
	    set(value) {
	        _firstName = value
	    }

	    public var LastName : String
	    get() { return _lastName }
	    set(value) { _lastName = value }

	    Human() {
	        println("I'm the constructor of $_firstName $_lastName")
	    }

	    fun sayHello() {
	        println("Hello $_firstName $_lastName")
	    }

	}

	class SuperHero(first : String, last : String, val HeroName : String) : Human(first,last) {

	}

	fun main(args : Array<String>) {

	    var Clark = SuperHero("Clark","Kent", "Super Man")
	    Clark.sayHello()
	    println(Clark.HeroName)

	}

###Exécution :

	I'm the constructor of Clark Kent
	Hello Clark Kent
	Super Man

##Surcharge

Comme pour la classe, il faudra utiliser le mot-clé `open` avant un membre de la classe pour pouvoir le surcharger (il faudra aussi que la classe soit `open` : pas de membre `open` dans une classe `final`, et un membre "surchargé" est par défaut `open`, à moins de le préfixé par `final`), donc si on veut surcharger `sayHello` de `Human` :

	open class Human(first : String, last : String) {
	    private var _firstName = first
	    private var _lastName = last

	    public var FirstName : String
	    get() {
	        return _firstName
	    }
	    set(value) {
	        _firstName = value
	    }

	    public var LastName : String
	    get() { return _lastName }
	    set(value) { _lastName = value }

	    Human() {
	        println("I'm the constructor of $_firstName $_lastName")
	    }
		
		//ajouter open devant la méthode
		
	    open fun sayHello() {
	        println("Hello $_firstName $_lastName")
	    }

	}

	class SuperHero(first : String, last : String, val HeroName : String) : Human(first,last) {
		
	    final override fun sayHello() {
	        println("Hello " +  FirstName + " " + LastName + ", " + HeroName)
	    }
	}

	fun main(args : Array<String>) {

	    var Clark = SuperHero("Clark","Kent", "Super Man")
	    Clark.sayHello()

	}

###Exécution :

	I'm the constructor of Clark Kent
	Hello Clark Kent, Super Man

##One more thing : Super !

Si vous voulez appeler la méthode de la classe mère dans votre surcharge, utilisez `super<supertype_name>.overrided_method()` :

	class SuperHero(first : String, last : String, val HeroName : String) : Human(first,last) {
	    final override fun sayHello() {
	        super<Human>.sayHello()
	        println("Your HeroName is $HeroName")
	    }
	}

###Exécution :

	I'm the constructor of Clark Kent
	Hello Clark Kent
	Your HeroName is Super Man

##Multi-héritage ?

... Nous verrons ça dans un prochain article ... Il faut que j'aille bosser.

##1ères impressions

Je ne sais pas vous, mais en ce qui me concerne, ce nouveau langage me plaît beaucoup, une touche de Java, une touche de Javascript, une touche de C# (les propriétés !, ... qui existent aussi en Javascript ;) ).

Et le bruit qui court du moment : la Team Kotlin voudrait utiliser Play!Framework :) ça va être une bonne année !




