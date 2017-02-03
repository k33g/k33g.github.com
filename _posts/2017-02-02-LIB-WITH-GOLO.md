---

layout: post
title: Faire une lib en Golo pour Java
info : Faire une lib en Golo pour Java
teaser: J'explique comment créer une librairie dans un jar avec Golo pour être utilisée avec Java.
---

# Faire une lib en Golo pour Java

Je vais vous expliquer comment créer une librairie en **Golo** re-utilisable ensuite avec vos autres projets **Golo**, ou **Java**.

Nous allons créer une librairie qui nous aide à utiliser les emojis dans nos applications 😛

- Rappel: Golo, le site, c'est par là [http://golo-lang.org/](http://golo-lang.org/)

## Créer une librairie avec Golo

Je pars du principe que vous avez installé Golo. Dans un terminal, tapez ceci:

```shell
golo new emoji --type maven
```

Golo va vous générer le squelette d'un projet **Maven** et vous allez obtenir cette arborescence:

```shell
.
└── emoji
    ├── LICENSE
    ├── README.md
    ├── pom.xml
    └── src
        └── main
            └── golo
                └── main.golo
```

Allez dans `main.golo` et modifiez le code:

```coffee
module org.typeunsafe.emoji

function panda_face = -> "🐼"
function alien = -> "👽"
function rabbit = -> "🐰"
```

### Build

Avant de builder notre librairie il faut aller modifier le fichier `pom.xml`:

#### Changer `mainClass`

Dans votre `pom.xml` vous avez 2 `<mainClass>emoji</mainClass>`, il faut les remplacer par :

```xml
<mainClass>org.typeunsafe.emoji</mainClass>
```

- *Remarque: juste avant je vous ai fait modifier le nom du module Golo qui est en fait une classe Java*

#### Changez le numero de version de Golo si nécessaire

Et remplacez, si besoin (tout dépend de la version de **Golo** utilisée):

```xml
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <golo.version>3.2.0-SNAPSHOT</golo.version>
  </properties>
```

par

```xml
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <golo.version>3.2.0-M5</golo.version>
  </properties>
```

- *Remarque 1: `3.2.0-M5` est la release courante de Golo*
- *Remarque 2: si vous avez une version snapshot (vous travaillez avec la version de dev), vous pouvez rencontrer des problèmes de gestion de dépendances au moment du build.*

#### Fixez un "bug" 🐝 du pom

Allez vérifier si les sections `repositories` et `pluginRepositories` existent et si ce n'est pas le cas ajoutez les:

```xml
  <repositories>
    <repository>
      <id>bintray</id>
      <name>Bintray</name>
      <url>https://jcenter.bintray.com</url>
    </repository>
  </repositories>

  <pluginRepositories>
    <pluginRepository>
      <id>bintray</id>
      <name>Bintray</name>
      <url>https://jcenter.bintray.com</url>
    </pluginRepository>
  </pluginRepositories>
```

- *Remarque 1: ce sera fixé dans la prochaine release*
- *Remarque 2: c'est fixé dans la version de développement* 🙂

#### Buildez ❗️

Il suffit d'utiliser la commande:

```shell
mvn package
```

et maintenant vous obtenez votre librairie au format `jar`:

```shell
/target/emoji-0.0.1-SNAPSHOT-jar-with-dependencies.jar
```

## Utiliser notre nouvelle librairie avec Golo

### Préalable

Pour pouvoir l'utiliser dans vos autres projet, il va falloir installer votre librairie dans votre maven local avec la commande `mvn install:install-file`:

```shell
mvn install:install-file  -Dfile=./target/emoji-0.0.1-SNAPSHOT-jar-with-dependencies.jar -DgroupId=org.typeunsafe -DartifactId=emoji -Dversion=0.0.1-SNAPSHOT -Dpackaging=jar -DgeneratePom=true
```

### Utiliser la librairie dans un projet Golo

- Créez un nouveau fichier **Golo**: `golo new golo.uses.emoji --type maven`
- modifiez le numero de version de **Golo** dans le fichier `pom.xml`
- ajoutez les sections `<repositories>` et `<pluginRepositories>`
- ajouter la dépendance à votre librairie:

  ```xml
    <dependency>
      <groupId>org.typeunsafe</groupId>
      <artifactId>emoji</artifactId>
      <version>0.0.1-SNAPSHOT</version>
    </dependency>
  ```

### Modifier le code de `src/main/golo/main.golo`

```coffee
module golo.uses.emoji

import org.typeunsafe.emoji

function main = |args| {
  println(panda_face())
  println(alien())
  println(rabbit())
}
```

### Buildez / Lancez

```shell
mvn package
mvn exec:java
🐼
👽
🐰
```

Et pour utiliser avec Java?

## Utiliser la librairie dans un projet Java

Alors je me suis créé un petit projet **Java**:

```shell
.
├── pom.xml
├── src
│   └── app
│       └── Application.java
```

avec ce `pom.xml` (⚠️ je ne suis pas un spécialiste Maven):


```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>org.typeunsafe</groupId>
  <artifactId>myapp</artifactId>
  <version>1.0-SNAPSHOT</version>
  <build>
    <sourceDirectory>src</sourceDirectory>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <configuration>
          <source>1.8</source>
          <target>1.8</target>
        </configuration>
      </plugin>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-assembly-plugin</artifactId>
        <version>2.2.2</version>
        <configuration>
          <descriptorRefs>
            <descriptorRef>jar-with-dependencies</descriptorRef>
          </descriptorRefs>

          <archive>
            <manifest>
                <mainClass>app.Application</mainClass>
            </manifest>
          </archive>

          <appendAssemblyId>false</appendAssemblyId>
          <outputDirectory>./</outputDirectory>
          <finalName>${project.artifactId}</finalName>
        </configuration>
      </plugin>

    </plugins>
  </build>

  <dependencies>
    <dependency>
      <groupId>org.typeunsafe</groupId>
      <artifactId>emoji</artifactId>
      <version>0.0.1-SNAPSHOT</version>
    </dependency>
  </dependencies>
</project>

```

⚠️: on n'oublie surtout pas la dépendance à notre librairie:

```xml
<dependency>
  <groupId>org.typeunsafe</groupId>
  <artifactId>emoji</artifactId>
  <version>0.0.1-SNAPSHOT</version>
</dependency>
```

### Le code Java:

En **Golo** un module (compilé) correspond à une classe **Java** avec des méthodes statiques qui sont les fonctions. Donc, nous faisons référence à notre librairie comme ceci `import static org.typeunsafe.emoji.*;` et notre code va ressembler à ceci:

```java
package app;

import static org.typeunsafe.emoji.*;

public class Application {
    public static void main(String[] args) {
      System.out.println(panda_face());
      System.out.println(alien());
      System.out.println(rabbit());
    }
}
```

### Buildez / Lancez

```shell
mvn compile assembly:single
java -jar myapp.jar
🐼
👽
🐰
```

Et voilà, vu les possibilités de **Golo** en termes de Promises, Workers, etc ,,, Vous pouvez apporter une touche "Dynamique" à vos projets **Java** très simplement. 🐼

Vous pouvez trouver les exemples de code ici:

- [https://github.com/TypeUnsafe/emoji](https://github.com/TypeUnsafe/emoji)
- [https://github.com/TypeUnsafe/golo.uses.emoji](https://github.com/TypeUnsafe/golo.uses.emoji)
- [https://github.com/TypeUnsafe/java.uses.emoji](https://github.com/TypeUnsafe/java.uses.emoji)
