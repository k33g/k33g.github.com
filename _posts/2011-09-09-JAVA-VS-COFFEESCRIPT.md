---

layout: post
title: Java Classes versus Coffeescript Classes
info : "Lutte des classes"

---

# Java Classes versus Coffeescript Classes

![Alt "java_vs_coffeescript.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/java_vs_coffeescript.jpg)

Coffeescript provides classes in Javascript, which is useful for structuring the code in a more traditional object-oriented programming. To understand how this works, I tried to write Java classes and then write the equivalent in Coffeescript. I give you today the results of my work.

## First Class

### Java

### #   Definition :


    package java_versus_coffeescript;

    //Animal
    public class Animal {
        public String name;

        public Animal(String name) {
            this.name = name;
        }

        @Override
        public String toString() {
            return "My name is " + name;
        }
    }


### #   Use :


    package java_versus_coffeescript;

    public class Java_versus_coffeescript {

        public static void main(String[] args) {
            Animal animal = new Animal("First Animal");
            System.out.println(animal.toString());
        }
    }


### #   Results :

    My name is First Animal

### Coffeescript

**With Coffeescript, instance-level properties are declared inside the constructor.**

### #   Definition :


    # Animal
    class Animal
        constructor:(name)->
            @name = name

        toString:()->
            "My name is # {@name}"


### #   Use :


    # Use
    animal = new Animal "First Animal"
    console.log animal.toString()

### #   Results :

    My name is First Animal

### #   Remarks :

You can define members as parameters of the constructor and even set default values :


    # Animal
    class Animal
        constructor:(@name="???")->

        toString:()->
            "My name is # {@name}"

    # Use
    animal = new Animal "First Animal"
    anOtherAnimal = new Animal

    console.log animal.toString()
    console.log anOtherAnimal.toString()


*Output :*

    My name is First Animal
    My name is ???

## Inheritance

### Java

### #   Definition :


    package java_versus_coffeescript;

    public class Dog extends Animal{

        public Dog(String name) {
            /* call parent constructor */
            super(name);
        }

        public String wouaf() {
            /* call inherited method */
            return this.toString() + " wouaf! wouaf !";
        }
    
        @Override
        public String toString() {
            /* call parent method */
            return super.toString() + ", i'm a Dog" ;
        }
    }


### #   Use :


    package java_versus_coffeescript;

    public class Java_versus_coffeescript {

        public static void main(String[] args) {
            Dog wolf = new Dog("Wolf");
            System.out.println(wolf.toString());
            System.out.println(wolf.wouaf());
        }
    }


### #   Results :

    My name is Wolf, i'm a Dog
    My name is Wolf, i'm a Dog wouaf! wouaf !

### Coffeescript

### #   Definition :


    # Dog
    class Dog extends Animal
        constructor:(name)->
            # call parent constructor
            super name

        wouaf:->
            # call inherited method
            "# {@toString()}  wouaf! wouaf !"

        toString:()->
            # call parent method
            "# {super}, i'm a Dog"


### #   Use :


    # Use
    wolf = new Dog "Wolf"
    console.log wolf.toString()
    console.log wolf.wouaf()


### #   Results :

    My name is Wolf, i'm a Dog
    My name is Wolf, i'm a Dog  wouaf! wouaf !

## Static Variables (Class Variables) + Inheritance

I treat both on "static" and "inheritance" as the way "to do static" may affect the inheritance.

### Java

### #   Definition :


    public class Animal {
        public String name;
        //Static / class variable
        public static Integer animalCounter = 0;

        public Animal(String name) {
            this.name = name;
            animalCounter +=1;
        }

        @Override
        public String toString() {
            return "My name is " + name;
        }
    }

    public class Dog extends Animal{
        //Static / class variable
        public static Integer dogCounter = 0;

        public Dog(String name) {
            /* call parent constructor */
            super(name);
            dogCounter +=1;
        }

        public String wouaf() {
            /* call inherited method */
            return this.toString() + " wouaf! wouaf !";
        }

        @Override
        public String toString() {
            /* call parent method */
            return super.toString() + ", i'm a Dog" ;
        }
    }


### #   Use :


    public class Java_versus_coffeescript {

        public static void main(String[] args) {

            Animal animal = new Animal("First Animal");
            Dog wolf = new Dog("Wolf");
            Dog cookie = new Dog("Cookie");

            System.out.println("Total of animals : "+ Animal.animalCounter);
            System.out.println("Total of animals (from Dog Class) :"+ Dog.animalCounter);
            System.out.println("Total of dogs : "+ Dog.dogCounter);

        }
    }


### #   Results :

    Total of animals : 3
    Total of animals (from Dog Class) :3
    Total of dogs : 2

### Coffeescript

### #   Definition :


    # Animal
    class Animal
        # Static / class variable
        animalCounter : 0

        constructor:(name)->
            @name = name
            Animal::animalCounter++

        toString:()->
            "My name is # {@name}"

    # Dog
    class Dog extends Animal
        # Static / class variable
        dogCounter : 0

        constructor:(name)->
            # call parent constructor
            super name
            Dog::dogCounter++

        wouaf:->
            # call inherited method
            "# {@toString()}  wouaf! wouaf !"

        toString:()->
            # call parent method
            "# {super}, i'm a Dog"


### #   Use :


    # Use
    animal = new Animal "First Animal"
    wolf = new Dog "Wolf"
    cookie = new Dog "Cookie"

    console.log "Total of animals : # {Animal::animalCounter}"
    console.log "Total of animals (from Dog Class) : # {Dog::animalCounter}"
    console.log "Total of dogs : # {Dog::dogCounter}"


### #   Results :

    Total of animals : 3
    Total of animals (from Dog Class): 3
    Total of dogs : 2

## Static Methods + Inheritance

### Java

### #   Definition :


    public class Animal {
        public String name;
        //Static / class variable
        public static Integer animalCounter = 0;

        public Animal(String name) {
            this.name = name;
            animalCounter +=1;
        }

        @Override
        public String toString() {
            return "My name is " + name;
        }
        //Static method
        public static Integer getAnimalsCount() {
            return animalCounter;
        }
    }

    public class Dog extends Animal{
        //Static / class variable
        public static Integer dogCounter = 0;

        public Dog(String name) {
            /* call parent constructor */
            super(name);
            dogCounter +=1;
        }

        public String wouaf() {
            /* call inherited method */
            return this.toString() + " wouaf! wouaf !";
        }

        @Override
        public String toString() {
            /* call parent method */
            return super.toString() + ", i'm a Dog" ;
        }
        //Static method
        public static Integer getDogsCount() {
            return dogCounter;
        }
    }

### #   Use :


    public class Java_versus_coffeescript {

        public static void main(String[] args) {

            Animal animal = new Animal("First Animal");
            Dog wolf = new Dog("Wolf");
            Dog cookie = new Dog("Cookie");

            System.out.println("getAnimalsCount : "+ Animal.getAnimalsCount());
            System.out.println("getAnimalsCount (from Dog Class) :"+ Dog.getAnimalsCount());
            System.out.println("getDogsCount : "+ Dog.getDogsCount());
            System.out.println("getDogsCount from instance : "+ cookie.getDogsCount());

        }
    }


### #   Results :

    getAnimalsCount : 3
    getAnimalsCount (from Dog Class) :3
    getDogsCount : 2
    getDogsCount from instance : 2

### Coffeescript

### #   Definition :


    # Animal
    class Animal
        # Static / class variable
        animalCounter : 0

        constructor:(name)->
            @name = name
            Animal::animalCounter++

        toString:()->
            "My name is # {@name}"
        # Static method
        @getAnimalsCount:->
            Animal::animalCounter

    # Dog
    class Dog extends Animal
        # Static / class variable
        dogCounter : 0

        constructor:(name)->
            # call parent constructor
            super name
            Dog::dogCounter++

        wouaf:->
            # call inherited method
            "# {@toString()}  wouaf! wouaf !"

        toString:()->
            # call parent method
            "# {super}, i'm a Dog"
        # Static method
        @getDogsCount:->
            Dog::dogCounter


### #   Use :


    # Use
    animal = new Animal "First Animal"
    wolf = new Dog "Wolf"
    cookie = new Dog "Cookie"

    console.log "getAnimalsCount : # {Animal.getAnimalsCount()}"
    console.log "getAnimalsCount (from Dog Class) : # {Dog.getAnimalsCount()}"
    console.log "getDogsCount : # {Dog.getDogsCount()}"
    console.log "getDogsCount from instance : # {cookie.getDogsCount()}"


### #   Results :

    getAnimalsCount : 3
    getAnimalsCount (from Dog Class) : 3
    getDogsCount : 2
    TypeError: 'undefined' is not a function (evaluating 'cookie.getDogsCount()')

*With Coffescript, an instance of a class can't call static method (Personally, I find it logical)*

## Static & Inheritance : An other way ?

There is another way to do (with a different behavior from a heritage point of view) :

- Class level property `animalCounter` is defined as `@animalCounter : 0` instead of `animalCounter : 0`  (same thing for `dogCounter`)
- You can access the property like this : `Animal.animalCounter` instead of `Animal::animalCounter`


*Code :*

    # Animal
    class Animal
        # Static / class variable
        @animalCounter : 0

        constructor:(name)->
            @name = name
            Animal.animalCounter++

        toString:()->
            "My name is # {@name}"
        # Static method
        @getAnimalsCount:->
            Animal.animalCounter

    # Dog
    class Dog extends Animal
        # Static / class variable
        @dogCounter : 0

        constructor:(name)->
            # call parent constructor
            super name
            Dog.dogCounter++

        wouaf:->
            # call inherited method
            "# {@toString()}  wouaf! wouaf !"

        toString:()->
            # call parent method
            "# {super}, i'm a Dog"
        # Static method
        @getDogsCount:->
            Dog.dogCounter

    # Use
    animal = new Animal "First Animal"
    wolf = new Dog "Wolf"
    cookie = new Dog "Cookie"

    console.log "getAnimalsCount : # {Animal.getAnimalsCount()}"
    console.log "getAnimalsCount (from Dog Class) : # {Dog.getAnimalsCount()}"
    console.log "getDogsCount : # {Dog.getDogsCount()}"



**Warning :**

In a class-level method (not in an instance-level method as constructor) you can access class-level property with this : `@animalCounter` instead of `Animal.animalCounter` :

        # Static method
        @getAnimalsCount:->
            @animalCounter

But, then, the behavior change a little : when you call `getAnimalsCount()` from `Dog` (`Dog.getAnimalsCount()`),you'll get a 0 value instead of 3.

To understand this behavior, you have just to read the javascript compiled versions :

1- **Animal.animalCounter version :**

    Animal = (function() {
      Animal.animalCounter = 0;
      function Animal(name) {
        this.name = name;
        Animal.animalCounter++;
      }
      Animal.prototype.toString = function() {
        return "My name is " + this.name;
      };
      Animal.getAnimalsCount = function() {
        return Animal.animalCounter;  /* <-- it's here ! */
      };
      return Animal;
    })();

2- **@animalCounter version :**

    Animal = (function() {
      Animal.animalCounter = 0;
      function Animal(name) {
        this.name = name;
        Animal.animalCounter++;
      }
      Animal.prototype.toString = function() {
        return "My name is " + this.name;
      };
      Animal.getAnimalsCount = function() {
        return this.animalCounter;  /* <-- it's here ! */
      };
      return Animal;
    })();

3- **Animal::animalCounter version :**

    Animal = (function() {
      Animal.prototype.animalCounter = 0;  /* <-- it's here ! */
      function Animal(name) {
        this.name = name;
        Animal.prototype.animalCounter++;  /* <-- and here ! */
      }
      Animal.prototype.toString = function() {
        return "My name is " + this.name;
      };
      Animal.getAnimalsCount = function() {
        return Animal.prototype.animalCounter;  /* <-- and here ! */
      };
      return Animal;
    })();


## Private members ?

LOL ;)


Have a nice day ! *k33g_org*