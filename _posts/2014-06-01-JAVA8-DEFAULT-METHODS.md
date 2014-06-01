---

layout: post
title: Java 8, méthodes par défaut dans les interfaces
info : Java 8, méthodes par défaut dans les interfaces

---

#Java 8, méthodes par défaut dans les interfaces

1er jour de juin, pas beaucoup de temps, levé à la bourre, mais un truc en tête lié à l'excellente présentation de [José Paumard](https://twitter.com/JosePaumard) au dernier Lyon JUG ([http://www.lyonjug.org/evenements/java-8](http://www.lyonjug.org/evenements/java-8)) : avec l'arrivée de Java 8, nous avons maintenant la possibilité de définir des méthodes par défaut dans les interfaces. Je ne vais pas vous expliquer tous les tenants et aboutissants de la chose (il faudrait déjà que je le fasse pour moi), mais je vais vous faire un exemple rapide sur le sujet.

*J'utiliserais plus tard cette manière de faire pour faire un mini "helper" pour Redis (et Jedis), mais cela fera l'objet d'un autre article sur "faire sa lib java from scratch".*

##Une première interface : Identification

Je définis une 1ère interface `Identification`

{% highlight java %}
package org.k33g.properties;

public interface Identification {
  String getName();
}
{% endhighlight %}

Jusque là rien de bien nouveau, j'ai juste besoin d'une méthode `getName` pour plus tard.

##Une deuxième interface : FlyingAbility

C'est maintenant que j'utilise les méthodes par défaut:

{% highlight java %}
package org.k33g.abilities;

import org.k33g.properties.Identification;

public interface FlyingAbility extends Identification {

  default void fly() {
    System.out.println(this.getName() +" is flying");
  }
}
{% endhighlight %}

Pour cela j'utilise le mot-clé `default`, et vous remarquez que mon interface "hérite" de `Identification` ce qui me permet d'utiliser `getName()`

Cela signifie que toute classe qui implémentera `FlyingAbility`aura une nouvelle méthode `fly()` `\o/`!!!

##Une troisième interface avant l'exemple final : SwimmingAbility

Sur le même principe que la précédente:

{% highlight java %}
package org.k33g.abilities;

import org.k33g.properties.Identification;

public interface SwimmingAbility extends Identification {

  default void swim() {
    System.out.println(this.getName() +" is swimming");
  }
}
{% endhighlight %}

*... Donc vous me voyez venir ...*

##L'exemple final : une classe Duck

*... Oui, je sais, je suis original le matin ...*. Donc notre classe `Duck`:

{% highlight java %}
package org.k33g.sandbox;

import org.k33g.abilities.FlyingAbility;
import org.k33g.abilities.SwimmingAbility;

public class Duck implements FlyingAbility, SwimmingAbility {
  private String name = null;
  @Override
  public String getName() {
    return this.name;
  }

  public Duck(String name) {
    this.name = name;
  }
}
{% endhighlight %}

Que nous utiliserons de la façon suivante:

{% highlight java %}
package org.k33g.sandbox;

public class Abilities {

  public static void main(String[] list) {

    Duck Donald = new Duck("Donald");

    Donald.fly();
    Donald.swim();

  }
}
{% endhighlight %}

Et nous aurons donc:

    Donald is flying
    Donald is swimming

Cela rappelle beaucoup ce que l'on peut déjà faire avec Groovy : les `Traits` ([http://beta.groovy-lang.org/docs/groovy-2.3.0-SNAPSHOT/html/documentation/core-traits.html](http://beta.groovy-lang.org/docs/groovy-2.3.0-SNAPSHOT/html/documentation/core-traits.html)). 

Voilà, c'est fini pour aujourd'hui *(c'est BBQ)*.



