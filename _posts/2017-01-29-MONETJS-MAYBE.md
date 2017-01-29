---

layout: post
title: monet.js - Maybe Monad
info : monet.js - Maybe Monad
teaser: Découverte de monet.js (la suite) avec Maybe Monad
---

# MonetJS - Maybe Monad

Donc la dernière fois nous avons parlé de la monade **Identity** avec le framework **[monet.js](https://cwmyers.github.io/monet.js)** ([monet.js - Maybe Monad](http://k33g.github.io/2017/01/27/MONETJS-IDENTITY.html)). Pour ce Dimanche matin, je vais faire une 2ème partie un peu plus courte où je vais vous parler de **Maybe**.

## Maybe?

Qu'est-ce qu'une **Maybe**? Pensez à un type qui peut changer de type 😜 ou à un type qui a 2 sous types. En fait une Maybe est une "boîte" 📦 qui contient une valeur (comme un container donc), et elle (la boîte) peut être de type `None`, c'est à dire que sa valeur est nulle ou de type `Some`, c'est à dire que sa valeur n'est pas nulle. Concrètement la **Maybe** est faite pour aider à gérer les `null(s)` et nous éviter pas mal d'exceptions/erreur, ... En fait c'est la même chose que le type `Option` en Scala ou Java.

## Utilisation

Voici quelques exemples simples pour montrer le fonctionnement de base:

### Constructor(s)

```javascript
let maybe = monet.Maybe.Some(42)

console.log(
	maybe.isSome(),	// == true
	maybe.isNone()	// == false
)
```

ou bien:

```javascript
let maybe = monet.Maybe.None()

console.log(
	maybe.isSome(),	// == false
	maybe.isNone()	// == true
)
```

Mais lorsque l'on ne sait pas à l'avance si l'on va avoir `null` ou pas on utilise `fromNull` (une factory de Maybe):

```javascript
let maybe = monet.Maybe.fromNull(42)

console.log(
	maybe.isSome(),	// == true
	maybe.isNone()	// == false
)
```

### Obtenir la valeur d'une Maybe: `orSome`

Une **Maybe** n'a pas de méthode `get`, à la place nous avons `orSome`:

```javascript
let maybe = monet.Maybe.fromNull("😄")

console.log(
	maybe.orSome("😡")	// maybe.orSome("😡") == 😄
)
```

ou dans le cas d'un `None`:

```javascript
let maybe = monet.Maybe.fromNull(null)

console.log(
	maybe.orSome("😡") // maybe.orSome("😡") == 😡
)
```

### Obtenir une Maybe d'une Maybe: `orElse`

`orElse` ne retourne pas une valeur mais une **Maybe**:

#### dans le cas d'un `Some`

```javascript
let maybe = monet.Maybe.fromNull("😄")
let newMaybe = maybe.orElse(monet.Maybe.Some("🤢"))

console.log(
	newMaybe,					// { isValue: true, val: '😄' }
	newMaybe.isSome()	// == true
)
```

#### dans le cas d'un `None`

```javascript
let maybe = monet.Maybe.fromNull(null)
let newMaybe = maybe.orElse(monet.Maybe.Some("🤢"))

console.log(
	newMaybe,					// { isValue: true, val: '🤢' }
	newMaybe.isSome()	// == true
)
```

⚠️ Donc `orElse` retourne la **Maybe** initiale si c'est un `Some` ou la **Maybe** proposée si un `None`.

## Ok, et en vrai, à quoi ça pourrait me servir?

... Pensez à une recherche en base de données:

```javascript

```
