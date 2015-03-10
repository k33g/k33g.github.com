---

layout: post
title: Connecter une Sphero et un RaspberryPI
info : Connecter une Sphero et un RaspberryPI
teaser: En ce moment, pour les besoins d'une présentation sur l'IOT pour Devoxx France 2015, avec Laurent Huet, je "joue" avec MQTT, Mosca, CylonJS et des objets connectés: des faux pour des simulation avec Paho, mais aussi des vrais comme le Wiced mais aussi la Sphero. C'est mon RaspberryPI qui sert de "hub" (le lien avec les objets et le broker de messages). Et quand j'ai voulu connecter le RPI et la Sphero, ça n'a pas fonctionné du 1er coup, donc je vous donne ma recette.
image: <img src="https://github.com/k33g/k33g.github.com/raw/master/images/sphero.jpg" height="30%" width="30%">

---

#Connecter une Sphero & un RaspberryPI

##Introduction

En ce moment, pour les besoins d'une présentation sur l'IOT pour Devoxx France 2015, avec Laurent Huet (@lhuet35), je "joue" avec MQTT, Mosca, CylonJS et des objets connectés: des faux pour des simulation avec Paho, mais aussi des vrais comme le Wiced mais aussi la Sphero. C'est mon RaspberryPI qui sert de "hub" (le lien avec les objets et le broker de messages). Et quand j'ai voulu connecter le RPI et la Sphero, ça n'a pas fonctionné du 1er coup, donc je vous donne ma recette.

##Pré-requis

Nous partons du principe que:

- vous avez un raspberrypi avec une raspbian installée 
- qu'il est connecté à votre réseau
- qu'il a un dongle bluetooth v4 "aux fesses"


En ce qui me concerne, je me connecte à mon jouet uniquement en ssh à partir d'un mac, donc c'est assez facile, pour les autres utilisez Putty ou un client SSH.

###Support du bluetooth

Connectez vous en ssh à votre raspberrypi, pour moi ça sera comme ceci : `ssh pi@192.168.0.16`

Puis tapez les commandes suivantes:

- `sudo apt-get install --no-install-recommends bluetooth`
- puis pour vérifier que ça foncionne : `sudo service bluetooth status`, si rien ne se passe, re-bootez et relancez `sudo service bluetooth status` (en ce qui me concerne ça a marché du 1er coup)

(tips tiré d'ici: [http://www.raspberrypi.org/learning/robo-butler/bluetooth-setup.md](http://www.raspberrypi.org/learning/robo-butler/bluetooth-setup.md))

###Outils pour se connecter à la Sphero

Il va falloir installer **Gort** : [https://github.com/hybridgroup/gort](https://github.com/hybridgroup/gort), le plus simple c'est de télécharger le binaire pour arm : [https://s3.amazonaws.com/gort-io/0.3.0/gort_0.3.0_linux_arm.tar.gz](https://s3.amazonaws.com/gort-io/0.3.0/gort_0.3.0_linux_arm.tar.gz) que vous "dé-tarrez" dans un répertoire de travail sur votre raspberrypi (ie: `/things`). 

Donc vous aurez un executable `gort` dans votre répertoire (faites un `chmod a+x gort`) qui est codé en **go**.

Ensuite il vous faut aussi la dépendance **python-gobject**, donc tapez la commande suivante: `sudo apt-get install python-gobject`

Et normalement on est bon.

##Connexion à la Sphero

###Obtenir l'adresse de la Sphero

D'abord: **Tapez la boule** (pour la mettre en marche)

Ensuite, il faut chercher la boule ... Tapez `./gort scan bluetooth`, vous obtiendrez quelque chose comme ceci:

    pi@raspberrypi ~/mqttdemo/things $ ./gort scan bluetooth
    Scanning ...
            00:23:68:6A:22:92       WindowsCE
            68:86:E7:02:44:2E       Sphero-RRY 

Vous l'aurez devinez, l'adresse de la Sphero, c'est `68:86:E7:02:44:2E ` (le device WindowsCE, à mon avis c'est le téléphone de mon voisin)

**Si ça ne fonctionne pas avec `gort`**: essayez `hcitool scan` à la place

###"Pairer" la Sphero et le RaspberryPi

Il suffit de taper : `sudo ./gort bluetooth pair 68:86:E7:02:44:2E` (n'oubliez pas le `sudo` et `68:86:E7:02:44:2E` est l'adresse de **ma** Sphero pas la votre). Vous obtiendrez quelque chose comme ceci:

    pi@raspberrypi ~/mqttdemo/things $ sudo ./gort bluetooth pair 68:86:E7:02:44:2E
    Release
    New device (/org/bluez/2387/hci0/dev_68_86_E7_02_44_2E)

**Si ça ne fonctionne pas avec `gort`**: essayez `sudo bluez-simple-agent hci0 68:86:E7:02:44:2E scan` à la place.

###Et maintenant la connexion!

Tapez ceci : `sudo ./gort bluetooth connect 68:86:E7:02:44:2E`. Si tout va bien vous devriez obtenir ceci:

    pi@raspberrypi ~/mqttdemo/things $ sudo ./gort bluetooth connect 68:86:E7:02:44:2E
    Connected /dev/rfcomm0 to 68:86:E7:02:44:2E
    Press CTRL-C to disconnect

**TADA!!!**, la boule est connectée!

Maintenant avant d'allez plus loin, faites `CTRL-C` pour vous déconnecter.

##Un peu plus loin avec CylonJS

###Installer CylonJS et le driver pour la Sphero

L'objectif, c'est de jouer avec la Sphero, donc nous allons utiliser CylonJS ([http://cylonjs.com/](http://cylonjs.com/)).

Dans votre répertoire de travail, créez un fichier `package.json` avec le contenu suivant:

  {
    "name": "play-with-sphero",
    "dependencies": {
      "cylon": "^0.22.1",
      "cylon-sphero": "^0.18.0"
    }
  }

Faites : `npm install`

###Créer un script pour interagir avec la Sphero

Alors le but n'est pas de vous expliquer le fonctionnement, mais juste de vérifier que la Sphero et le RaspberryPi dialoguent bien ensembles.

Toujours dans le même répertoire, créez un fichier `sphero.js` avec le code suivant:

{% highlight javascript %}
var Cylon = require('cylon');

Cylon.robot({
  connections: {
    sphero: { adaptor: 'sphero', port: '/dev/rfcomm0' }
  },
  devices: {
    sphero: { driver: 'sphero' }
  },

  work: function(my) {

    // start sphero
    my.sphero.roll(5, Math.floor(Math.random() * 360));
    // sphero is started

    after((1).seconds(), function() {
      console.log("Setting up Collision Detection...");
      my.sphero.detectCollisions();

      var opts = {
        n: 200,
        m: 1,
        pcnt: 0
      };

      my.sphero.setDataStreaming(["locator", "accelOne", "velocity"], opts);
      
      my.sphero.setBackLED(192); // turns on the tail LED with 192 of brightness
      my.sphero.setRGB(0xff4500); // Orange
      my.sphero.stop();
    });

    my.sphero.on("data", function(data) {
      console.log("locator:", data);
    });

    my.sphero.on("collision", function() {
      console.log("Collision:");
      my.sphero.setRGB(0xff0000); // Res
      my.sphero.roll(128, Math.floor(Math.random() * 360));
    });

  }

}).start();
{% endhighlight %}


En gros, une fois lancé, la Sphero va changer de couleur au démarrage et bouger un chouilla, et une fois que vous la secouez un peu, ça affichera des données dans votre console.

###Lancer tout ça

Nous allons utiliser la commande `screen` pour pouvoir lancer des commandes en tâche de fond (si vous n'avez pas **screen** : `sudo apt-get install screen`)

####Connexion à la Sphero

Tapez `screen`, une fois que vous obtenez le prompt à nouveau, tapez la commande `sudo ./gort bluetooth connect 68:86:E7:02:44:2E`

####Discuter avec la Sphero

Une fois la connexion bluetooth obtenue, faites `ctrl+a` puis `c` pour "créer" un autre écran (une autre sortie tty) et lancez: `node sphero.js` et jonglez avec votre Sphero.

Si tout va bien il devrait se passer des choses.

Voilà! La suite ça sera pour plus tard (après Devoxx). Et amusez vous bien.


