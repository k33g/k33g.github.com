---

layout: post
title: Redis et les HashMaps
info : Redis et les HashMaps

---

# Redis et les HashMaps

Je viens de visionner le TIA (tool in action) de [Nicolas Martignole](https://twitter.com/nmartignole) lors de **Devoxx FR 2014** sur Redis : [Redis, une base Not Only NoSQL](http://parleys.com/play/535e4ed8e4b03397a8eee8d4/chapter0/about). Je l'avais loupé, je passais juste après et du coup, "légèrement tendu" je me préparais "psychologiquement" ;). Je vous engage vivement à le visionner, c'est une très bonne présentation de Redis, qui en plus "sent" le vécu, puis Nicolas nous parle de son expérience réelle avec Redis.

Et du coup, ça m'a donné une idée de post pour mon Blog. Le sujet et court, mais pourra en intéresser certains.

C'est probablement du à l'influence de **Backbone** (oui oui, le framework javascript), mais souvent je représente mes modèles avec une propriété `fields` qui est une hashmap, généralement comme ceci:

{% highlight java %}
public class Human {
  public HashMap<String, Object> fields = new HashMap<>();
  public Object get(String fieldName) { return this.fields.get(fieldName); }
  public void set(String fieldName, Object value) { this.fields.put(fieldName, value); }
}
{% endhighlight %}

Alors, on aime ou pas, mais je trouve ça pratique.

**Pré-requis**: avoir visionné le TIA de Nicolas.

## HMSET

Il se trouve que la commande `HMSET` de Redis permet d'enregistrer des hashs (associés à une clé): [http://redis.io/commands/hmset](http://redis.io/commands/hmset) et que le driver Java **Jedis** ([https://github.com/xetorthio/jedis](https://github.com/xetorthio/jedis)) possède la méthode "helper" `hmset(key, map)` qui permet de sauvegarder des hashmaps de ce type `HashMap<String, String>`. *(1)*

Un petit exemple ici sur le repo Jedis : [https://github.com/xetorthio/jedis/blob/master/src/test/java/redis/clients/jedis/tests/commands/HashesCommandsTest.java# L81](https://github.com/xetorthio/jedis/blob/master/src/test/java/redis/clients/jedis/tests/commands/HashesCommandsTest.java# L81) 

*(1): il n'y a que des types `String` avec Redis, donc oubliez le type `Object`.*

## Application en Java

Donc en java, si j'avais des hashmaps qui représenteraient des humains, j'aurais le code suivant:

### Connexion à Redis et définition des "humains"

{% highlight java %}
Jedis jedis = new Jedis("localhost", 6379);

HashMap<String, String> bob = new HashMap<String, String>() {% raw %}{{
  put("firstName", "Bob");
  put("lastName", "Morane");
}}{% endraw %};

HashMap<String, String> john = new HashMap<String, String>() {% raw %}{{
  put("firstName", "John");
  put("lastName", "Doe");
}}{% endraw %};

HashMap<String, String> jane = new HashMap<String, String>() {% raw %}{{
  put("firstName", "Jane");
  put("lastName", "Doe");
}}{% endraw %};
{% endhighlight %}

### Sauvegarde des "humains"

{% highlight java %}
/* === save all humans to the redis server === */

jedis.hmset("bob:male", bob);
jedis.hmset("john:male", john);
jedis.hmset("jane:female", jane);
{% endhighlight %}

### Retrouver un "humain"

On utilise la méthode `hgetAll`en lui passant la clé de "l'humain" recherché

{% highlight java %}
/* === get Jane === */

System.out.println(jedis.hgetAll("jane:female"));
{% endhighlight %}

En sortie, nous aurons ceci:

    {lastName=Doe, firstName=Jane}

### Lister toutes les clés

{% highlight java %}
/* === get All Humans keys === */

jedis.keys("*").forEach((key)->System.out.println(key));
{% endhighlight %}

En sortie, nous aurons ceci:

    bob:male
    john:male
    jane:female

### Lister toutes les "humains"

Pour cela nous passerons par la liste des clés:

{% highlight java %}
/* === get All Humans === */

jedis.keys("*").forEach((key)->System.out.println(jedis.hgetAll(key)));
{% endhighlight %}

En sortie, nous aurons ceci:

    {firstName=Bob, lastName=Morane}
    {firstName=John, lastName=Doe}
    {lastName=Doe, firstName=Jane}

### Ne lister que les garçons

{% highlight java %}
/* === get only males === */
jedis.keys("*:male").forEach((key)->System.out.println(jedis.hgetAll(key)));
{% endhighlight %}

En sortie, nous aurons ceci:

    {firstName=Bob, lastName=Morane}
    {firstName=John, lastName=Doe}

**Remarquez** la façon d'utiliser la méthode `keys` : on utilise comme paramètre `*:male` qui signifie: *"je veux toutes les clés qui se termine par `:male`"*.

Ce qui signifie que la **clé est porteuse d'informations** et qu'il est important de bien réfléchir à la manière de la construire.


Vous trouverez le code source ici: [https://github.com/java-experiments/try-redis-with-jedis](https://github.com/java-experiments/try-redis-with-jedis)

## En Golo pour la route

Juste le listing Golo, qui se passe d'explication (la logique reste la même)

(Cela faisait en partie partie de mon TIA [Golo, de la sucrette syntaxique pour vos applications Java](http://cfp.devoxx.fr/devoxxfr2014/talk/HUY-998/Golo,%20de%20la%20sucrette%20syntaxique%20pour%20vos%20applications%20Java))

{% highlight coffeescript %}
let jedis = Jedis("localhost", 6379)

let bob = map[["firstName", "Bob"], ["lastName", "Morane"]]
let john = map[["firstName", "John"], ["lastName", "Doe"]]
let jane = map[["firstName", "Jane"], ["lastName", "Doe"]]

#  === save all humans to the redis server ===

jedis: hmset("bob:male", bob)
jedis: hmset("john:male", john)
jedis: hmset("jane:female", jane)

#  === get Jane ===

println(jedis: hgetAll("jane:female"))

#  === get All Humans keys ===

jedis: keys("*"): each(|key| -> println(key))

#  === get All Humans ===

jedis: keys("*"): each(|key| -> println(jedis: hgetAll(key)))

#  === get only males ===

jedis: keys("*:male"): each(|key| -> println(jedis: hgetAll(key)))
{% endhighlight %}

Vous trouverez le code source ici: [https://github.com/golo-sandbox/try-redis-with-golo](https://github.com/golo-sandbox/try-redis-with-golo)

Demain, je vous parle encore de Redis mais avec du Node.js.


