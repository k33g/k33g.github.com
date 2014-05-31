---

layout: post
title: Redis, Jedis et les Sets
info : Redis, Jedis et les Sets

---

#Redis, Jedis et les Sets

Je continue ma découverte de Redis et Jedis (suite de l'article [http://k33g.github.io/2014/05/22/PLAYING-WITH-REDIS.html](http://k33g.github.io/2014/05/22/PLAYING-WITH-REDIS.html) sur Redis et les HashMaps). J'avais alors découvert la commande `keys(matchParameters)` que je trouvais assez géniale, mais l'on m'a fait remarquer à juste titre que ce n'était pas performant et qu'il valait mieux utiliser des `sets` pour classer ses données selon certains critères.

Le `sets`, voyez ça comme un "couple" clé, liste de valeurs *où les valeurs sont des strings*.

###Connexion à Redis et définition des "humains"

Ça c'est la même chose que la dernière fois (avec une fille en plus)

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

HashMap<String, String> wonderWoman = new HashMap<String, String>() {% raw %}{{
  put("firstName", "Lynda");
  put("lastName", "Carter");
}}{% endraw %};
{% endhighlight %}

Et je sauvegarde en base mes hashmaps:

{% highlight java %}
jedis.hmset("bob", bob);
jedis.hmset("john", john);
jedis.hmset("jane", jane);
jedis.hmset("lynda", wonderWoman);
{% endhighlight %}

##Classer mes données avec des sets

Je vais créer 3 `sets` : `"females"`, `"males"`, `"humans"` pour "classer" mes hasmaps, grâce à la commande `sadd` à laquelle je passe une clé unique pour identifier le `set` et une liste de valeurs sous forme de string (qui ici représentent les clés de mes hashs):

{% highlight java %}
jedis.sadd("females", "jane", "lynda");
jedis.sadd("males","bob", "john"); 
jedis.sadd("humans", "bob", "jane", "lynda", "john");
{% endhighlight %}

##Interroger mes sets

Maintenant si je souhaite avoir toutes les `"females"`, il me suffit d'écrire ceci en utilisant la commande `smembers` et en lui passant la clé du `set` que je veux parcourir:

{% highlight java %}
jedis.smembers("females").forEach((key) -> System.out.println(jedis.hgetAll(key)));
{% endhighlight %}

Et nous obtiendrons:

    {lastName=Carter, firstName=Lynda}
    {lastName=Doe, firstName=Jane}

Si je veux compter le nombre de `"males"`, j'utiliserais la commande `scard`

{% highlight java %}
System.out.println(jedis.scard("males")); // nous obtiendrons 2
{% endhighlight %}

##Suppressions

Si je supprime la "hash" Lynda:

{% highlight java %}
jedis.del("lynda");
{% endhighlight %}

Et que je relance le parcours du `set` `"females"`:

{% highlight java %}
jedis.smembers("females").forEach((key) -> System.out.println(jedis.hgetAll(key)));
{% endhighlight %}

Et nous obtiendrons:

    {}
    {lastName=Doe, firstName=Jane}

Notez bien que la suppression de la "hash" ne supprime pas l'enregistrement dans le `set`, ce qui est logique, mais tout le monde peut se tromper.

Pour supprimer un enregistrement du `set`, il suffit d'utiliser la commande `srem` en lui passant la clé du `set` et la valeur à supprimer:

{% highlight java %}
jedis.srem("females","lynda");
{% endhighlight %}

##Scan

On peut parcourir un `set` avec des critères de recherche avec la méthode `sscan` qui permet de parcourir les valeur d'un `set` et d'en extraire celles qui correspondent à au critère. Le critère fonctionne de la même façon qu'avec `keys` : par exemple, je veux toutes les valeurs qui contiennent le caractère `"a"`, alors mon critère sera : `*a*`. On retombe dans une problématique de performance, mais on aura beaucoup moins de clés à parcourir par rapport à avant où l'on scannait la base entière.

Donc, imaginons que je veuille tous les `"humans"` dont la clé contient `"a"`, j'écrirais ceci:

Je définis mon paramètre de recherche:

{% highlight java %}
ScanParams params = new ScanParams();
params.match("*a*");
{% endhighlight %}

J'interroge mon `set`

{% highlight java %}
jedis.sscan("humans", SCAN_POINTER_START , params)
      .getResult()
      .forEach((key) -> System.out.println("key " + key + " : " + jedis.hgetAll(key)));
{% endhighlight %}

J'obtiendrais:

    key jane : {lastName=Doe, firstName=Jane}
    key lynda : {lastName=Carter, firstName=Lynda}

*Remarque*: `SCAN_POINTER_START` (ou `redis.clients.jedis.ScanParams.SCAN_POINTER_START`) correspond à `String.valueOf(0)` : je scanne à partir du 1er enregistrement.

**Remarque bis**: à manier avec précaution et parcimonie [http://redis.io/commands/scan](http://redis.io/commands/scan), je cite *"It is important to note that the MATCH filter is applied after elements are retrieved from the collection, just before returning data to the client."*

Voilà, j'avance tout doucement, la prochaine fois je travaillerais sur les range (je pense).

