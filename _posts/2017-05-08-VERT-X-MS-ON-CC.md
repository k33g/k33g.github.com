---

layout: post
title: Microservices avec Vert-x en Scala
info : Microservices avec Vert-x en Scala et déploiement sur Clever-Cloud
teaser: 1ers pas dans le monde des microservices avec Vert-x et Scala
---

# Microservices avec Vert-x en Scala

Je viens de passer une semaine très "microservices": 

J'ai enfin eu l'occasion de voir le talk de Quentin sur les microservices [https://twitter.com/alexandrejomin/status/860443891971088384](https://twitter.com/alexandrejomin/status/860443891971088384) lors de notre passage chez [@Xee_FR](https://twitter.com/Xee_FR) à Lille (vous pouvez aussi voir aussi ceci à Devoxx France [Problèmes rencontrés en microservice (Quentin Adam)](https://www.youtube.com/watch?v=mvKeCsxGZhE) et [Comment maintenir de la cohérence dans votre architecture microservices (Clément Delafargue)](https://www.youtube.com/watch?v=Daburx0jSvw)).

J'ai lu l'excellent [Building Reactive Microservices in Java](https://developers.redhat.com/promotions/building-reactive-microservices-in-java/) par [@clementplop](https://twitter.com/clementplop), où Clément explique comment écrire des microservices en Vert-x. (à voir aussi: [Vert.X: Microservices Were Never So Easy (Clement Escoffier)](https://www.youtube.com/watch?v=c5zKUqxL7n0)

Du coup, je n'ai plus le choix, il faut que je m'y mette sérieusement et que je prépare quelques démos MicroServices pour mon job. Et autant que je vous en fasse profiter. 🙀 J'ai décidé de le faire en Scala (mon auto-formation), mais je vais tout faire pour que cela reste le plus lisible possible.

## Architecture de mon exemple

⚠️ note: cette "architecture" est pensée pour être le plus simple possible à comprendre - cela ne signifie pas que ce soit ce qu'il faut utiliser en production - l'objectif est d'apprendre simplement. (je vais faire des microservices http) - je ne traiterais pas de des "Circuit Breakers", ou des "Health Checks and Failovers".

Lorsque vous avez un ensemble de microservices, c'est bien d'avoir un système qui permetten de référencer ces microservices pour facilement les "trouver". Une application qui "consomme" un microservice doit avoir moyen de le référencer et l'utiliser sans pour autant connaître à l'avance son adresse (par ex: l'url du microservice). On parle de **"location transparency"** et de pattern **"service discovery"**. C'est à dire qu'un microservice, doit être capable d'expliquer lui-même comment on peut l'appeler et l'utiliser et ces informations sont stockées dans une **"Service Discovery Infrastructure"**.

### Vert.x Service Discovery

Vert.x fournit tout un ensemble d'outils pour faire ça et se connecter à un service Consul, Zookeeper, ... Mais Vert.x fournit aussi un **"Discovery Backend - Redis"** qui vous permet d'utiliser une base Redis comme annuaire de microservices (cf. [Discovery Backend with Redis](http://vertx.io/docs/vertx-service-discovery-backend-redis/groovy/)). C'est ce que je vais utiliser pour mon exemple.







