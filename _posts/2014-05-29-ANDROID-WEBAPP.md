---

layout: post
title: Chrome Android et les Webapps
info : Chrome Android et les Webapps

---

#Chrome Android et les Webapps

Depuis la version beta 31 de Chrome Android, il est enfin possible d'ajouter un raccourcis vers une webapp sur la home de son terminal et de l'afficher en plein écran comme une véritable application (comme ce que fait iOS depuis longtemps).

Avec la puissance qu'atteignent maintenant les terminaux android, une webapp est tout à fait viable en tant qu'application, et selon les contextes suffit amplement par rapport à une application native.

##Offline ?

Il y a peu, j'étais dans le métro de ma ville, et j'ai eu besoin de consulter le plan du métro. Je sors donc mon téléphone, je lance l'application des transports en commun de ma ville. Et là c'est le drame : sans connexion web (ce qui est souvent le cas en sous-sol) impossible de consulter le plan du métro. Comment dire ...

Je me souviens, avant 2000, j'habitais Paris et j'avais un Palm Vx qui embarquait le plan du métro parisien (et là pas de connexion data à l'époque), il y avait même un moteur de calcul d'itinéraire!!! *Développé par un passionné*.

Ben mince alors, les applications mobiles sont en train de régresser. A l'heure du tout connecté on oublie que "ça capte pas partout" ;)

##C'est le prétexte pour tester les Webapps sous Android

Je me suis donc codé une webapp qui utilise [Leaflet](http://leafletjs.com/) et le principe de **"Image Overlay"** pour afficher une image en lieu et place d'une map (d'un point de vue SIG). J'affiche un plan stylisé du métro de ma ville. Je l'ai dessiné moi même pour ne pas avoir de problèmes:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/lugdunum.png" height="70%" width="70%">


Alors pour qu'une Webapp puisse "se prendre" pour une application il y a quelques règles à respecter:

###S'afficher en plein écran et avoir un comportement "mobile"

Dans le header, vous aurez besoin de ceci:

{% highlight html %}
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="mobile-web-app-capable" content="yes">
{% endhighlight %}

Ainsi votre webapp s'affichera en plein écran, sans la barre d'url de Chrome

###Associer une icône à votre "application"

Créez une icône de taille `196x196` pixels au format `.png`, puis ajoutez le tag suivant au header de votre page:

{% highlight html %}
<link rel="icon" sizes="196x196" href="rocket.png">
{% endhighlight %}

###Et pour la partie "offline" ?

Il suffit de créer un fichier avec l'extension `.appcache` au même niveau que la page html de votre webapp et de décrire dans ce fichier toutes les ressources que l'on souhaite mettre en cache. Comme cela, même sans connexion, l'application sera utilisable (toutes les ressources sont téléchargées à la 1ère connexion). Voici à quoi va ressembler mon fichier `lugdunum.appcache`:

    CACHE MANIFEST
    # 537bNHNmyCLSmx5RpSB5W2gLn1g=

    CACHE:
    js/leaflet/leaflet.js
    js/leaflet/leaflet.css
    js/leaflet/images/layers.png
    js/leaflet/images/layers-2x.png
    js/leaflet/images/marker-icon.png
    js/leaflet/images/marker-icon-2x.png
    js/leaflet/images/marker-shadow.png
    css/styles.js
    images/lugdunum.png
    index.html
    rocket.png

    # catch-all for anything else
    NETWORK:
    *
    http://*
    https://*

où `images/lugdunum.png` est mon plan de métro.

et vous déclarez le fichier dans votre page html: `<html lang="en" manifest="lugdunum.appcache">`

###Le code pour afficher la map du métro avec Leaflet

{% highlight javascript %}
var mapMinZoom = 1;
var mapMaxZoom = 3;
var map = L.map('map', {
  maxZoom: mapMaxZoom,
  minZoom: mapMinZoom,
  crs: L.CRS.Simple
}).setView([0, 0], mapMaxZoom);

var mapBounds = new L.LatLngBounds(
  map.unproject([-800, 2816], mapMaxZoom),
  map.unproject([3072, -800], mapMaxZoom));

map.fitBounds(mapBounds);

L.imageOverlay("images/lugdunum.png", mapBounds).addTo(map);
{% endhighlight %}

**Leaflet** va aller chercher l'élément du dom qui a un id `map` et il affichera la map du métro dans cet élément.

**Au final vous pouvez voir à quoi cela ressemble ici**: [http://lugdunum.github.io/metro/](http://lugdunum.github.io/metro/)

Si vous voulez l'installer sur votre terminal android, connectez vous à cette url, puis dans le menu de Chrome pour Android, sélectionnez "Ajouter à l'écran d'accueil".

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/lugdumetro.jpg" height="40%" width="40%">

Et le code est ici: [https://github.com/lugdunum/metro](https://github.com/lugdunum/metro).

Bon faudra angulariser tout ça ;)



