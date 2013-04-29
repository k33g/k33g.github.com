---

layout: post
title: golo est encore un bébé
info : gologolo

---

#Proxy Dynamique en Golo

Golo est fait pour utiliser des classes Java. Si vous manipulez des classes qui implémentent des interfaces, il est tout à fait possible de "greffer" des comportements à vos méthodes de classes (celles déclarées dans une interface) grâce à `import java.lang.reflect.Proxy`. Voyons donc comment faire :

Imaginez une interface java :

```java
package org.k33g;

public interface Toon {
    public String hello(String message);
    public String speak(String message);
}
```

Imaginez une classe java qui implémente `Toon`

```java
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
```

```coffeescript


``