---

layout: post
title: golo est encore un bébé
info : gologolo

---

#Proxy Dynamique en Golo

Golo est fait pour utiliser des classes Java. Si vous manipulez des classes qui implémentent des interfaces, il est tout à fait possible de "greffer" des comportements à vos méthodes de classes (celles déclarées dans une interface) grâce à `import java.lang.reflect.Proxy`. Voyons donc comment faire :

**Imaginez une interface java :**

{% highlight java %}
package org.k33g;

public interface Toon {
    public String hello(String message);
    public String speak(String message);
}
{% endhighlight %}

**Imaginez une classe java qui implémente `Toon` :**

{% highlight java %}
package org.k33g;

public class TinyToon implements Toon {

    private String name = null;

    public TinyToon(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String hello(String message) {
        return "HELLO I'M "+this.name+" : "+ message;
    }

    @Override
    public String speak(String message) {
        return "BLABLA BY "+this.name+" : "+ message;
    }
}
{% endhighlight %}

##Proxy dynamique

**Il est possible de créer un proxy de `TinyToon`, implémentant donc `Toon` et ce dynamiquement :**

Ce peut être très pratique, si vous avez des traitements (méthodes) qui "attendent" des objets de type `Toon`, et que vous souhaitez ajouter des comportements aux méthodes (ce n'est possible que pour les méthodes déclarées dans l'interface implémentée par la classe) :

Dans un 1er temps, si nous utilisons tout simplement `TinyToon` :

{% highlight coffeescript %}
import org.k33g.TinyToon

function main = |args| {

	let toon = TinyToon("Babs")

    println(toon:hello("HI !!!"))
    println(toon:speak("IT'S SO CUTE"))

}
{% endhighlight %}

Nous obtiendrons la sortie suivante :

	HELLO I'M Babs : HI !!!
	BLABLA BY Babs : IT'S SO CUTE

**Maintenant, nous allons créer notre proxy de `TinyToon` :*







