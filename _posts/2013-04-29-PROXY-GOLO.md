---

layout: post
title: Proxy Dynamique en Golo
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

Nous obtiendrons à l'exécution la sortie suivante :

	HELLO I'M Babs : HI !!!
	BLABLA BY Babs : IT'S SO CUTE

**Maintenant, nous allons créer notre proxy de `TinyToon` :**

Nous allons maintenant utiliser `Proxy.newProxyInstance()` :

{% highlight coffeescript %}
import java.lang.reflect.InvocationHandler
import java.lang.reflect.Proxy

import org.k33g.TinyToon

function main = |args| {

	let toon = TinyToon("Babs")

	let toonProxy = Proxy.newProxyInstance(
        toon:getClass():getClassLoader(),
        toon:getClass():getInterfaces(),
        (|proxy, method, args...| {
	
        	println("You've called : " + method:getName())
        	
        	let result = null

        	if method:getName() is "hello" {
                println("hello from proxy")
        		result = toon:hello(args:get(0))
        	}

        	if method:getName() is "speak" {
                println("speak from proxy")
        		result = toon:speak(args:get(0))
        	}

        	return result

        }):to(InvocationHandler.class))

	println(toonProxy:hello("HI !!!"))
	println(toonProxy:speak("IT'S SO CUTE"))

}
{% endhighlight %}

**Remarquez** que nous "castons" notre closure `|proxy, method, args...| { ... }` en `InvocationHandler`, en utilisant `():to(InvocationHandler.class)`.

Nous obtiendrons à l'exécution la sortie suivante :

	You've called : hello
	hello from proxy
	HELLO I'M Babs : HI !!!
	You've called : speak
	speak from proxy
	BLABLA BY Babs : IT'S SO CUTE

Et voilà, vous venez de faire de l'AOP avec Golo. Ce qui vous démontre une fois de plus la puissance de ce langage.

Vous trouverez ici une version "générique" réutilisable d'un proxy dynamique : [https://github.com/k33g/DynoGolo](https://github.com/k33g/DynoGolo).

 *42.* ;)

*à venir : comment modifier directement Golo. Stay tuned*






