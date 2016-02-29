---

layout: post
title: Golo, Java, Maven ... and MongoDb
info : Golo, Java, Maven ... and MongoDb

---

# Golo, Java, Maven ... and MongoDb

The last time (["Golo, Think different"](http://k33g.github.io/2014/06/22/GOLO-GOLO.html)), i tried to quickly introduce "Golo", and i explained that Golo was playing very well with Java. You can even generate a **Maven** project, add java source code and frameworks dependencies!

## Create Golo Maven Project

Try this command:

    golo new --type maven contacts

It creates a directory `contacts`:

    contacts/
    ├── src/
    |   └── main/      
    |       └── golo/
    |           └── main.golo
    └── pom.xml

You can open `main.golo`:

{% highlight coffeescript %}
module contacts

function main = |args| {
  println("Hello contacts!")
}
{% endhighlight %}

Now, open `pom.xml` and search `<plugin>` node about `exec-maven-plugin`:

      <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>exec-maven-plugin</artifactId>
        <version>1.1</version>
        <executions>
          <execution><goals><goal>java</goal></goals></execution>
        </executions>
        <configuration>
          <mainClass>contacts</mainClass>
        </configuration>
      </plugin>

You can see that `contacts` is considered as the main class, like the module name of `main.golo` with a `main` method.

## Compile your new Golo project

search `<plugin>` node about `maven-assembly-plugin`, and add `<outputDirectory>./</outputDirectory>` in the `<configuration>` node:

      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-assembly-plugin</artifactId>
        <version>2.4</version>
        <configuration>
          <archive>
            <manifest>
              <mainClass>contacts</mainClass>
            </manifest>
          </archive>
          <descriptorRefs>
            <descriptorRef>jar-with-dependencies</descriptorRef>
          </descriptorRefs>
          <outputDirectory>./</outputDirectory>

        </configuration>
        <executions>
          <execution>
            <id>make-my-jar-with-dependencies</id>
            <phase>package</phase>
            <goals>
              <goal>single</goal>
            </goals>
          </execution>
        </executions>
      </plugin>

*Remark: it's just handier to do that, i agree it's not probably a very good practice*

And now, run the command `mvn` and you'll get a new jar file: `contacts-0.0.1-SNAPSHOT-jar-with-dependencies.jar` that you can run like that:

    java -jar contacts-0.0.1-SNAPSHOT-jar-with-dependencies.jar  

## Add some java code

In the `main` directory, create a `java` directory, and a package inside, ie `org.k33g.tools` with a java class `Hello.java`:

{% highlight java %}
package org.k33g.tools;

public class HelloWorld {
  public void en() {
    System.out.println("Hello World!");
  }
  public void fr() {
    System.out.println("Salut à Tous!");
  }
}
{% endhighlight %}

This is your project:

    contacts/
    ├── src/
    |   └── main/      
    |       └── golo/
    |       |   └── main.golo
    |       └── java/
    |           └── org/
    |               └── k33g/    
    |                   └── tools/ 
    |                       └── HelloWorld.java       
    └── pom.xml

### Modifiy your main.golo file

{% highlight coffeescript %}
module contacts

import org.k33g.tools.HelloWorld

function main = |args| {
  let hello = HelloWorld()
  
  hello: en()
  hello: fr()
}
{% endhighlight %}

Build your project: `mvn` and run it: `java -jar contacts-0.0.1-SNAPSHOT-jar-with-dependencies.jar `, you'll get this:

    Hello World!
    Salut à Tous!

## Use an "external" java framework

### MongoDB

I love to use MongoDB and it would be fine to "play with it in Golo" ;) then add this dependency inside the `<dependencies>` node:

    <dependency>
      <groupId>org.mongodb</groupId>
      <artifactId>mongo-java-driver</artifactId>
      <version>2.11.4</version>
      <type>jar</type>
      <scope>compile</scope>
    </dependency>

In `golo` directory, create a `mongo.golo` file and copy this content:

{% highlight coffeescript %}
module mongo

import com.mongodb.MongoClient
import com.mongodb.MongoException
import com.mongodb.WriteConcern
import com.mongodb.DB
import com.mongodb.DBCollection
import com.mongodb.BasicDBObject
import com.mongodb.DBObject
import com.mongodb.DBCursor
import com.mongodb.ServerAddress
import org.bson.types.ObjectId

struct mongo = {
  _mongoClient,
  _db
}

augment mongo {
  function initialize = |self, databaseName, host, port| {
    self: _mongoClient(MongoClient(host, port))
    self: _db(self: _mongoClient(): getDB(databaseName))
    return self
  }

  function db = |self| -> self: _db()
  function collection = |self, collectionName| {
    let dbCollection = self: _db(): getCollection(collectionName)
    let newCollection = mongoCollection(
      dbCollection,
      null, null, null
    )
    return newCollection
  }

  function model = |self, collectionName| {
    let dbCollection = self: _db(): getCollection(collectionName)
    let newModel = mongoModel(dbCollection, BasicDBObject())
    return newModel
  }
}

struct mongoCollection = {
  _collection,
  skip,
  limit,
  sort
}

augment mongoCollection {
  function options = |self, cursor| {
    if self: sort() isnt null {
      cursor: sort(BasicDBObject(self: sort(): get(0), self: sort(): get(1)))
      self: sort(null)
    }
    if self: skip() isnt null {
      cursor: skip(self: skip()): limit(self: limit())
      self: skip(null): limit(null)
    }
    return cursor
  }
  #  helpers :
  function cursorToListOfMaps = |self, cursor| { #  return list of HashMaps
    let models = list[]
    cursor: each(|doc| {
      let map = doc: toMap()
      let id = doc: getObjectId("_id"): toString()
      map: put("_id", id)
      models: add(map)
    })
    return models
  }
  #  helpers :
  function cursorToList = |self, cursor| { #  return list of MongoModels
    let models = list[]
    cursor: each(|doc| {
      let newModel = mongoModel(self: _collection(), BasicDBObject())
      newModel: fromMap(doc: toMap())
      models: add(newModel)
    })
    return models
  }

  function fetch = |self| {
    let cursor = self: _collection(): find()
    self: options(cursor)
    return self: cursorToList(cursor)
  }
  function fetchMaps = |self| {
    let cursor = self: _collection(): find()
    self: options(cursor)
    return self: cursorToListOfMaps(cursor)
  }
  function find = |self, fieldName, value| {
    let query = BasicDBObject(fieldName, value)
    let cursor = self: _collection(): find(query)
    self: options(cursor)
    return self: cursorToList(cursor)
  }
  function findMaps = |self, fieldName, value| {
    let query = BasicDBObject(fieldName, value)
    let cursor = self: _collection(): find(query)
    self: options(cursor)
    return self: cursorToListOfMaps(cursor)
  }
  function like = |self, fieldName, value| {
    let query = BasicDBObject(fieldName, java.util.regex.Pattern.compile(value))
    let cursor = self: _collection(): find(query)
    self: options(cursor)
    return self: cursorToList(cursor)
  }
  function likeMaps = |self, fieldName, value| {
    let query = BasicDBObject(fieldName, java.util.regex.Pattern.compile(value))
    let cursor = self: _collection(): find(query)
    self: options(cursor)
    return self: cursorToListOfMaps(cursor)
  }
  function query = |self, query| {
    let cursor = self: _collection(): find(query)
    self: options(cursor)
    return self: cursorToList(cursor)
  }
  function queryMaps = |self, query| {
    let cursor = self: _collection(): find(query)
    self: options(cursor)
    return self: cursorToListOfMaps(cursor)
  }
}

struct mongoModel = {
  _collection,
  _basicDBObject
}

augment mongoModel {
  function id = |self| -> self: _basicDBObject(): getObjectId("_id"): toString()

  function field = |self, fieldName, fieldValue| {
    self: _basicDBObject(): put(fieldName, fieldValue)
    return self
  }
  function field = |self, fieldName| -> self: _basicDBObject(): get(fieldName)

  function insert = |self| {
    self: _collection(): insert(self: _basicDBObject())
    return self
  }

  function update = |self| {
    let id = self: _basicDBObject(): get("_id")
    self: _basicDBObject(): removeField("_id")
    let searchQuery = BasicDBObject(): append("_id", ObjectId(id))
    self: _collection(): update(searchQuery, self: _basicDBObject())
    self: _basicDBObject(): put("_id", ObjectId(id))
    return self
  }

  function fetch = |self, id| {
    let searchQuery = BasicDBObject(): append("_id", ObjectId(id))
    self: _collection(): find(searchQuery): each(|doc| {
      self: _basicDBObject(): putAll(doc)
    })
    return self
  }
  function fetch = |self| {
    return self: fetch(self: id())
  }
  function remove = |self, id| {
    let searchQuery = BasicDBObject(): append("_id", ObjectId(id))
    let doc = self: _collection(): find(searchQuery): next()
    self: _basicDBObject(): putAll(doc)
    self: _collection(): remove(doc)
    return self
  }
  function remove = |self| {
    return self: remove(self: id())
  }
  function toMap = |self| {
    let map = self: _basicDBObject(): toMap()
    map: put("_id", self: id())
    return map
  }
  function fromMap = |self, fieldsMap| {
    self: _basicDBObject(BasicDBObject(fieldsMap))
    return self
  }
  function toJsonString = |self| -> JSON.stringify(self: toMap())

  function fromJsonString = |self, jsonString| {
    let bo = BasicDBObject()
    bo: putAll(JSON.parse(jsonString))
    self: _basicDBObject(bo)
    return self
  }
}
{% endhighlight %}

### Modify main.golo to play with MongoDB

Change the content of `main.golo` by this:

{% highlight coffeescript %}
module contacts

import mongo

function main = |args| {

  let mongocli = mongo(): initialize("ducksdb", "localhost", 27017)

  let riri = mongocli: model("ducks")
    : field("firstName", "Riri")
    : field("lastName", "Duck")
    : insert()

  let fifi = mongocli: model("ducks")
    : field("firstName", "Fifi")
    : field("lastName", "Duck")
    : insert()

  let loulou = mongocli: model("ducks")
    : field("firstName", "Loulou")
    : field("lastName", "Duck")
    : insert()

  let ducks = mongocli: collection("ducks")

  ducks: fetch(): each(|duck| {
    println(duck: toJsonString())
  })

  ducks: fetchMaps(): each(|duck| {
    println(duck)
  })

  ducks: like("firstName", ".*i.*"): each(|duck| {
    println(duck: toJsonString())
  })

}
{% endhighlight %}

Now, build your project: `mvn`, launch MongoDb server (`mongod`) and run your jar: `java -jar contacts-0.0.1-SNAPSHOT-jar-with-dependencies.jar `, you'll get something like this:

    {"firstName":"Riri","lastName":"Duck","_id":"53a9514b30043a04aa8f1cb5"}
    {"firstName":"Fifi","lastName":"Duck","_id":"53a9514b30043a04aa8f1cb6"}
    {"firstName":"Loulou","lastName":"Duck","_id":"53a9514b30043a04aa8f1cb7"}
    {_id=53a9514b30043a04aa8f1cb5, firstName=Riri, lastName=Duck}
    {_id=53a9514b30043a04aa8f1cb6, firstName=Fifi, lastName=Duck}
    {_id=53a9514b30043a04aa8f1cb7, firstName=Loulou, lastName=Duck}
    {"firstName":"Riri","lastName":"Duck","_id":"53a9514b30043a04aa8f1cb5"}
    {"firstName":"Fifi","lastName":"Duck","_id":"53a9514b30043a04aa8f1cb6"}

So you can see it's very easy to create hybrid projects (Golo+Java+Mongo+ ... and so on).

Have fun with Golo!




