---

layout: post
title: Améliorez vos démos lors de vos présentations
info : Mettez un terminal dans vos slides
teaser: Faire des démos pendant un talk ce n'est pas toujours simple. J'ai donc commencé depuis peu à réfléchir à des outils qui pourraient me faciliter la vie, comme pouvoir afficher un terminal dans mes slides pour éviter de "switcher" constamment entre les slides, une console, un ide, ...
---


# Mettez un terminal dans vos slides

Le 6 novembre, j'ai eu la chance de pouvoir faire un talk au [DevFest Nantes](https://devfest.gdgnantes.com/) (je vous en parlerais dans un autre post) et je me suis bien fait plaisir. Mon talk abordait (pour résumer) les moyens de piloter des nano-computers et des micros-controllers en JavaScript [https://www.youtube.com/watch?v=zd3j6yPLmdY](https://www.youtube.com/watch?v=zd3j6yPLmdY), et pour que l'auditoire ne s'endorme pas, j'aime bien faire des démonstrations. Mais dans le cas de ce talk, je dois pour les démos, "sortir" du slideware, ouvrir une ou plusieurs consoles, tapez des commandes et montrer simultanément (avec une caméra - pour que les gens au fond de la salles puissent aussi voir ce qu'il se passe) le résultat des commandes sur les composants électroniques.

En découvrant [Wetty](https://github.com/krishnasrinivas/wetty) (un framework permettant de rediriger la sortie terminal d'un client ssh dans votre navigateur), je me suis dit qu'i serait intéressant de coupler cela avec [Tmux](https://tmux.github.io/) et [Teamocil](http://www.teamocil.com/) pour à terme "coller" ça dans une présentation HTML.

Plutôt que de vous expliquer toutes les étapes, j'ai "dockerisé" tout mon boulot que vous pourrez retrouver ici [https://github.com/k33g/preztools](https://github.com/k33g/preztools) (il suffit de décortiquer le Dockerfile pour comprendre ce que j'ai fait).

Et je vous explique comment l'utiliser (ensuite à vous de perfectionner l'outil)

## Utilisation de "PrezTools"

### Builder l'image

Dans un 1er temps, vous allez cloner le repository:

    git clone https://github.com/k33g/preztools.git

Ensuite vous tapez les commandes suivantes:

    cd preztools
    docker build -t preztools assets/ 

Et vous patientez. 
**Remarque**: `preztools` est le nom de votre image, `assets` est le répertoire contenant le `Dockerfile` et les éléments nécessaires à la construction de l'image.

### Lancer la bête

Une fois l'image construite, dans un terminal docker, lancez la commande suivante:

    docker run -v ~/complete_path_to/src:/src -p 9000:9000 -p 3000:3000 -i -t preztools

**Remarque**: `3000` est le port de communication de **Wetty**, `9000` est le port http utilisé par **http-server** qui va servir nos pages html.

Vous devriez obtenir ceci:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/term0.png" height="70%" width="70%">

### Vérification

- Maintenant dans votre navigateur, ouvrez [http://192.168.99.100:9000/](http://192.168.99.100:9000/)
- Sélectionnez le lien [http://192.168.99.100:9000/sample1.html](http://192.168.99.100:9000/sample1.html)

Vous devriez obtenir ceci:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/term1.png" height="70%" width="70%">

Pour vous connecter: le user est `term`, le password est `term`

Vous arrivez donc dans une session tmux pointant sur le répertoire `/src`: (`/src` est votre répertoire de travail, vous y avez accès même à partir du système hôte. C'est le dossier `/src` dans le repository que vous avez cloné)

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/term2.png" height="70%" width="70%">

Vous noterez la présence d'un fichier `myprez.yml` dans le répertoire. Si vous tapez la commande:

    teamocil --layout myprez.yml

Vous allez "splitter" en 4 votre terminal:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/term3.png" height="70%" width="70%">

Libre à vous maintenant d'écrire vos propre fichiers de configurations **teamocil** en vous inspirant de ça: [https://github.com/remiprev/teamocil# examples](https://github.com/remiprev/teamocil# examples).

## Et après

Je vais certainement ajouter d'autres outils. Par exemple si vous ouvrez le lien [http://192.168.99.100:9000/sample3.html](http://192.168.99.100:9000/sample3.html) vous pouvez voir que je peux déjà rediriger le flux de ma webcam tout en montrant du code avec **vi**.

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/term4.png" height="70%" width="70%">

En espérant que cela puisse vous aider et vous donner des idées.
@+



