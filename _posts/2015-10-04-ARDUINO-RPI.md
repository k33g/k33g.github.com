---

layout: post
title: Premiers pas avec un Arduino (Uno), JavaScript (Johnny-Five) et un RaspBerry
info : Premiers pas avec un Arduino (Uno), JavaScript (Johnny-Five) et un RaspBerry
teaser: Je n'aime pas coder en C, j'aime le JavaScript, je veux "bidouiller" avec un Arduino, mais en JS, je veux faire ça à partir d'un RaspBerry ... Et en plus, c'est possible, avec Johnny-Five voyons donc comment faire.
image: <img src="https://github.com/k33g/k33g.github.com/raw/master/images/arduino-000.png" height="50%" width="50%">
---

# Premiers pas avec un Arduino, JavaScript et un RaspBerry

## Intro & Objectifs

Je n'aime pas coder en C, j'aime le JavaScript, je veux "bidouiller" avec un Arduino, mais en JS, je veux faire ça à partir d'un RaspBerry ... Et en plus, c'est possible, avec Johnny-Five voyons donc comment faire.

Vous aurez besoin de:

- Un Raspberry avec un dongle wifi (ou alors connecté au réseau via un cable ethernet)
- Un Arduino Uno
- Une Led

... C'est parti!

## Paramétrage du RaspBerry

### Connexion Wifi

Dans un 1er temps, paramétrons la connexion wifi du RaspBerry:

"Sur" le RaspBerry ouvrez une console, ou à partir de votre desktop (avec le RaspBerry connecté sur le même réseau) dans un terminal, (1) connectez vous en SSH sur le RaspBerry (par exemple sur MAC `ssh pi@IP_DU_RASPBERRY`). Ensuite, ouvrez en mode "super utilisateur", le fichier `wpa_supplicant.conf`:

    sudo nano /etc/wpa_supplicant/wpa_supplicant.conf

Et ajouter les informations correspondant à votre routeur wifi, par exemple:

    network={
      ssid="skynet"
      psk="SarahConnor"
    }

Sauvegardez.

*(1): cela fonctionne aussi avec une connexion ethernet directe: le RPI connecté directement avec un cable ethernet RJ45 à votre desktop.*

*PS: il vous faut un dongle wifi pour votre RaspBerry.*

### Modifions le hostname

Donnons un petit nom réseau à notre RaspBerry, cela nous garantira de pouvoir le "contacter" sans forcément connaître son adresse IP.

Nous sommes toujours connectés au RaspBerry. Editez `/etc/hosts`:

    sudo nano /etc/hosts

Dans le fichier, ajoutez la ligne:

    127.0.1.1       bob

Enregistrez, fermez.

*Remarque: j'ai donc décidé d'appeler mon RaspBerry, bob.*

Ensuite, éditez `/etc/hostname`:

    sudo nano /etc/hostname 

Et ajouter juste la ligne:

    bob

Enregistrez, fermez.

Lancez les commandes suivantes pour prendre en compte les modifications : 

    sudo /etc/init.d/hostname.sh
    sudo reboot

A partir de maintenant, vous devez pouvoir vous connecter à votre RaspBerry en SSH comme ceci:

    ssh pi@bob.local

### Installation de NodeJS

J'aurais besoin d'installer la dernière (ou une récente) version de NodeJS.
Tout d'abord, ajoutons le "repository" `apt.adafruit.com`à la liste des sources de notre RaspBerry (dans la console SSH):

    curl -sLS https://apt.adafruit.com/add | sudo bash

... Patientez ...

Puis:

    sudo apt-get install node

### Installation de Johnny-Five

**Johnny-Five** ([https://github.com/rwaldron/johnny-five](https://github.com/rwaldron/johnny-five)) est un framework JavaScript (pour node) qui permet de "discuter" avec votre Arduino via le protocole **Firmata** (plus d'informations par ici: [https://github.com/firmata/protocol](https://github.com/firmata/protocol)).

Donc sur votre RaspBerry (en mode console via SSH):

- Créer un répertoire `skynet`: `mkdir skynet`, puis:

    cd skynet
    npm install johnny-five

    
## Paramétrage de l'Arduino

Pour permettre à l'Arduino de "discuter" avec Johnny-Five, il faut installer le programme "Firmata" sur l'Arduino.

- Installez l'Arduino IDE [https://www.arduino.cc/en/Main/Software](https://www.arduino.cc/en/Main/Software)
- Branchez votre Arduino sur votre Desktop avec le cable USB approprié : "USB cable type A/B" ([https://store.arduino.cc/product/M000006](https://store.arduino.cc/product/M000006))
- Lancez l'IDE
- Choisir le port de communication : Menu **Tools/Port** + port
- Choisir le "board" : Menu **Tools/Board** + Arduino Uno
- Charger le sketch "Firmata" : Menu **Files/Examples/Firmata** + Choisir "StandardFirmata"
- Ensuite uploader sur l'Arduino : Menu **Sketch/Upload**

Si vous voulez une version en image, vous pouvez aller ici: [http://www.instructables.com/id/Arduino-Installing-Standard-Firmata/?ALLSTEPS](http://www.instructables.com/id/Arduino-Installing-Standard-Firmata/?ALLSTEPS)

### Vérifications

Ajouter une diode sur l'Arduino comme ceci:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/arduino-001.png" height="50%" width="50%">

Ensuite branchez l'Arduino sur le RaspBerry (lui même branché sur le secteur ou sur une batterie de téléphone).

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/arduino-002.png" height="50%" width="50%">

Dans le répertoire initialement créé (`skynet`), créez un fichier `led.js` avec le contenu suivant:

{% highlight javascript %}
var five = require("johnny-five");
var board = new five.Board();

board.on("ready", function() {
  var led = new five.Led(13);
  led.blink(500);
});
{% endhighlight %}

Dans votre console (SSH), tapez `node led.js` et si tout va bien, votre led devrait clignoter.

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/arduino-003.png" height="50%" width="50%">

Voilà, maintenant, vous pouvez piloter votre Arduino à partir de votre RaspBerry.











