---

layout: post
title: monet.js - Identity Monad
info : monet.js - Identity Monad
teaser: Découverte de monet.js avec Identity Monad
---

# MonetJS - Identity Monad

Je trouve Scala de plus en plus intéressant, et certains concepts fonctionnels me manque en JavaScript. J'ai donc essayé divers frameworks JavaScript dits "fonctionnel" et j'en ai enfin trouvé un que je trouve simple à assimiler et à utiliser: **[monet.js](https://cwmyers.github.io/monet.js/)**. Donc, aujourd'hui nous parlon de la monad(e) Identity

## Rappel: Monad?

> ⚠️ Disclaimer: ma définition ne va pas plaire à tout le monde, mais c'est un autre débat (ma mission c'est de montrer que le fonctionnel c'est pas compliqué et que ça peut servir.)

Pour faire court: une monad(e) est un container qui contient une valeur que l'on ne peut pas modifier (vous pouvez replacer "immutabilité" dans une conversation). Un peu comme ceci:

```javascript
function monad(v) {
	let value = v
	this.get = () => value
	return this
}
```

et je peux l'utiliser comme ceci:

```javascript
let m = new monad(42)
console.log("value of m", m.get())
```

... et je ne pourrais **JAMAIS** modifier `value`
... mais en fait ce n'est pas une monade 😲

Pour que ce soit une monade,

il faut lui ajouter une méthode `map` qui permet d'appliquer à la valeur du container une opération (fonction/closure) retournant elle même une valeur et d'obtenir enfin une nouvelle monade sans changer la valeur de la précédente 😜:

```javascript
function monad(v) {
	let value = v
	this.get = () => value
	this.map = (operation) => new this.constructor(operation(value))
	return this
}
```

Et on l'utilisera comme cela:

```javascript
let m = new monad(40)
let m2 = m.map(n => n + 2)
m.get() == 40
m2.get() == 42
```

J'ai donc obtenu une nouvelle monade avec une valeur de `42` et ma 1ère monade reste avec une valeur de `40`.

... Mais, mais, mais 🦆 .... Ce n'est pas encore une monade, c'est uniquement un *Functor*

Il faut encore lui ajouter une méthode `flatMap`, c'est un peu la même chose que pour `map`, mais dans ce cas là l'opération appliquée ne retourne pas une valeur "simple" mais aussi une monade (ou éventuellement un functor ou un container ... mais ça peut se dicuter). Et du coup il faut "applatir" la monade retournée par l'opération pour éviter d'imbriquer des monades dans des monades (oui je sais 😜).

C'est à dire,
- que l'on applique l'opération sur la valeur de la monade
- on en récupère la nouvelle valeur
- on retourne une nouvelle monade avec la nouvelle valeur

En code, c'est peut être un peu plus clair:

```javascript
function monad(v) {
	let value = v
	this.get = () => value
	this.map = (operation) => new this.constructor(operation(value))
	this.flatMap = (operation) => new this.constructor(operation(value).get())
	return this
}
```

Et on l'utilisera comme cela:

```javascript
let m = new monad(40)
let add1 = n => new monad(n+1)
m.flatMap(add1).flatMap(add1).get() == 42
```

Et pour mieux comprendre, vous n'avez qu'à essayer de faire:

```javascript
m.map(add1).map(add1).get()
```

Maintenant passons à **monet.js**.

## Identity

Tout ce que je viens d'expliquer est déjà implémenté dans **monet.js** sous le nom de monad **Identity**.

> ⚠️ vous pouvez utiliser **monet.js** dans votre browser ou avec node.js

### Utilisation

C'est simple:

```javascript
const monet = require('monet');

let monadWith40 = monet.Identity(40) // number 40 wrapped in an Identity box
let addOne = n => n +1

monadWith40.map(addOne).map(addOne).get() == 42
```

### Et dans la vraie vie, est-ce que cela peut servir?

Alors, la monade **Identity** n'est pas forcément la monade la plus ✨ , mais oui elle peut servir.

Imaginons que vous ayez toutes les étapes d'un projet modélisées sous forme de fonctions comme ceci:

```javascript
let coding = p => ({total: p.total + p.dev, dev: p.dev})

/* on pourrait aussi écrire:
function coding(p) {
  return {
    total: p.total + p.dev,
    dev: p.dev
  }
}
*/

let specifications = p => ({total: p.total + p.dev * 8.72 / 100, dev: p.dev})
let architecture = p => ({total: p.total + p.dev * 16.46 / 100, dev: p.dev})
let integrationAndTests = p => ({total: p.total + p.dev * 15.48 / 100, dev: p.dev})
let buildingAndPackaging = p => ({total: p.total + p.dev * 15.48 / 100, dev: p.dev})
let documentation = p => ({total: p.total + p.dev * 7.25 / 100, dev: p.dev})
let environmentLogistics = p => ({total: p.total + p.dev * 13.51 / 100, dev: p.dev})
let managementAndQuality = p => ({total: p.total + p.dev * 28.13 / 100, dev: p.dev})
```

Donc si je souhaite par exemple, connaître le nombre de jours de spécifications pour un projet où le dev fait 100 jours, je ferais ceci:

```javascript
specifications({total:0,dev:100}).total == 8.72
```

si j'utilise **monet.js**, je "chiffrerais" mon projet comme ceci:

```javascript
let startEstimation = monet.Identity({total:0, dev:100})

let globalEstimation =
	startEstimation
		.map(coding)
		.map(specifications)
		.map(architecture)
		.map(integrationAndTests)
		.map(buildingAndPackaging)
		.map(documentation)
		.map(environmentLogistics)
		.map(managementAndQuality)

console.log("Total:", globalEstimation.get()) // 205.02999999999997
```

Si j'ai besoin de n'avoir que la charge de documentation:

```javascript
startEstimation.map(documentation).get()
```

### Il y a aussi du `flatMap`

Je rappelle que c'est une monade 😉

On imagine par exemple que le chef de projet veut se faire une petite provision pour risque de 5 jours et qu'il l'implémente de cette façon:

```javascript
let provision = p => monet.Identity({total: p.total + 5, dev: p.dev})
```

Comme cette fois-ci mon "étape" `provision` me retourne une monade, je vais utiliser `flatMap` pour l'intégrer dans mon chiffrage:

```javascript
let globalEstimation =
	startEstimation
		.map(coding)
		.flatMap(provision)   // <-- c'est ici
		.map(specifications)
		.map(architecture)
		.map(integrationAndTests)
		.map(buildingAndPackaging)
		.map(documentation)
		.map(environmentLogistics)
		.map(managementAndQuality)
```

Voilà, ce n'est pas plus compliqué que ça.

> *PS: en ce qui concerne `flatMap` vous pouvez en entendre aussi parler sous le nom de `bind` oud de `fmap`*.

A bientôt pour la suite avec `Maybe`, `Some` et `None`
