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
	maybe.isSome(), // == true
	maybe.isNone() // == false
)
```

ou bien:

```javascript
let maybe = monet.Maybe.None()

console.log(
	maybe.isSome(), // == false
	maybe.isNone() // == true
)
```

Mais lorsque l'on ne sait pas à l'avance si l'on va avoir `null` ou pas on utilise `fromNull` (une factory de Maybe):

```javascript
let maybe = monet.Maybe.fromNull(42)

console.log(
	maybe.isSome(), // == true
	maybe.isNone() // == false
)
```

### Obtenir la valeur d'une Maybe: `orSome`

Une **Maybe** n'a pas de méthode `get`, à la place nous avons `orSome`:

```javascript
let maybe = monet.Maybe.fromNull("😄")

console.log(
	maybe.orSome("😡") // maybe.orSome("😡") == 😄
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
	newMaybe, // { isValue: true, val: '😄' }
	newMaybe.isSome() // == true
)
```

#### dans le cas d'un `None`

```javascript
let maybe = monet.Maybe.fromNull(null)
let newMaybe = maybe.orElse(monet.Maybe.Some("🤢"))

console.log(
	newMaybe, // { isValue: true, val: '🤢' }
	newMaybe.isSome() // == true
)
```

⚠️ Donc `orElse` retourne la **Maybe** initiale si c'est un `Some` ou la **Maybe** proposée si un `None`.

## Ok, et en vrai, à quoi ça pourrait me servir?

... Pensez à une recherche en base de données:

```javascript
let users = [
    {id:1, name:"bob", avatar:"🐼"}
  , {id:2, name:"sam", avatar:"🐻"}
  , {id:3, name:"jane", avatar:"🐰"}
  , {id:4, name:"john", avatar:"🐱"}
]

let getUserById = id => monet.Maybe.fromNull(users.find(u => u.id == id))

console.log(
	getUserById(3) // { isValue: true, val: { id: 3, name: 'jane', avatar: '🐰' } }
)
console.log(
	getUserById(6) // { isValue: false, val: null }
)
```

Dans le 1er cas j'obtiens un `Some`, sans le 2ème un `None`... ok ... Mais comme c'est une monade, nous avons la méthode `map`❗️ et on peut faire plein de choses sympas

### Maybe et `map()`

Avant, pour obtenir l'avatar d'un utilisateur que l'on cherche par son `id`, on aurait fait quelaue chose comme ceci:

```javascript
users.find(u => u.id == 6).avatar
```

Et comme l'utilisateur n'existe pas, on obtient un joli:

```shell
TypeError: Cannot read property 'avatar' of undefined
```

**Qui n'a jamais oublié de tester si il avait récupéré quelque chose ou pas avant de jouer avec dans son code ⁉️**. Mais maintenant, vous pouvez faire ceci:

```javascript
let getUserById = id => monet.Maybe.fromNull(users.find(u => u.id == id))
let getAvatar = u => u.avatar

console.log("display avatar of 2:",
	getUserById(2).map(getAvatar).orSome("👻")
)

console.log("display avatar of 6:",
	getUserById(6).map(getAvatar).orSome("👻") // be careful Number six doesn't exist ... I'm not a number, I'm a free man!
)
```

et vous obtiendrez ceci:

```shell
display avatar of 2: 🐻
display avatar of 6: 👻
```

et sans "plantage" ❗️😊

- `getUserById` me retourne une monade Maybe **M1**
- avec `map` je peux appliquer une transformation à la valeur **M1** (sans la modifier)
- et obtenir une nouvelle monade Maybe **M2**
- sur laquelle je peux faire un `orSome`
- ✌️ donc plus de plantage idiot dans une recherche dans une base de données, collections, ...

## Un dernier pour la route 🍷

Une chose que j'adore ❤️ avec la **Maybe**, c'est le **catamorphisme** 🤦 (allez faire un tour ici [https://fr.wikipedia.org/wiki/Catamorphisme](https://fr.wikipedia.org/wiki/Catamorphisme) ça pique 🌵 hein?). Plus simplement (et même si étymologiquement parlant c'est tiré par les 💇), pensez à **catastrophe**.

Dans [monet.js]() la **Maybe** a une méthode `cata` qui va vous permettre de gérer les **catastrophe**. Cette méthode prend 2 arguments (en fait 2 callbacks ou 2 closures, appelez les comme vous le sentez), `cata(left(), right(value))`:

- le 1èr callback, que l'on appellera `left` (l'argument le plus à gauche) qui ne prend aucune valeur en argument et qui est appelé quand la **Maybe** est un `None`
- le 2ème callback, que l'on appellera `right`, qui prend comme argument la valeur de la **Maybe** quand c'est un `Some`

⚠️ `right` est aussi un moyen mémotechnique: right comme juste, "c'est ok, tu as tout juste 👍".

Mais avec un petit bout de code ce sera plus parlant, rappelez vous de notre `getUserById` qui nous retourne une **Maybe**:

```javascript
console.log(
	getUserById(3).cata(
		()=> {
			return "this 😡 does not exist"
		},
		(user) => {
			return `Hello ${user.avatar}`
		}
	)
)
```

Dans ce cas là, nous obtiendrons: `Hello 🐰`

```javascript
console.log(
	getUserById(6).cata(
		()=> {
			return "this 😡 does not exist"
		},
		(user) => {
			return `Hello ${user.avatar}`
		}
	)
)
```

Dans ce cas là, nous obtiendrons: `this 😡 does not exist`

Fin de ce chapitre. **Maybe** est très pratique, mais dès fois, on aurait besoin qu'elle en fasse un tout petit peu plus. Donc la prochaine fois, je vous parlerais de `Either`.

Bon Dimanche 🍗 🍰 🍷
