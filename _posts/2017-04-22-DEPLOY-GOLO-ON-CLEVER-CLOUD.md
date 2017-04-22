---

layout: post
title: How to deploy Golo and Vert-x web app on Clever-Cloud
info : How to deploy Golo and Vert-x web app on Clever-Cloud
teaser: This is the user guide to deploy a Golo and Vert-x web application on the Clever-Cloud PaaS.
---

# How to deploy Golo and Vert-x web app on Clever-Cloud

Today, I explain how to create quickly a web application with [Golo](http://golo-lang.org/) and [Vert-x](http://vertx.io/), and then how to deploy it easyly on [Clever-Cloud](https://www.clever-cloud.com/).

- You need to install Golo (http://golo-lang.org/)

## Create a Golo project

In a terminal, type this commands:

```shell
golo new vertx.golo.demo --type maven
cd vertx.golo.demo
```

The Golo CLI has generated a Golo project:

```shell
.
├── pom.xml
├── src
│   └── main
│       └── golo
│           └── main.golo
```

## Update the pom.xml file

In order to compile correctly the project, you have to update the pom.xml file:

### Change the Golo version

Replace:

```xml
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <golo.version>3.2.0-SNAPSHOT</golo.version>
  </properties>
```

By:

```xml
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <golo.version>3.2.0-M6</golo.version>
    <vertx.version>3.4.1</vertx.version>
  </properties>
```

*Remark: `3.2.0-M6` is the current version number of the Golo project, and we'll need the Vert-x version number too.*

### Add some dependencies:

```xml
  <dependencies>
    <dependency>
      <groupId>org.eclipse.golo</groupId>
      <artifactId>golo</artifactId>
      <version>${golo.version}</version>
    </dependency>

    <dependency>
      <groupId>com.googlecode.json-simple</groupId>
      <artifactId>json-simple</artifactId>
      <version>1.1.1</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-core</artifactId>
      <version>${vertx.version}</version>
    </dependency>

    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-web</artifactId>
      <version>${vertx.version}</version>
    </dependency>

  </dependencies>
```

## Change the main.golo file

We are going to write a very simple Vert-x web application with Golo. For that, replace the content of `/src/main/golo/main.golo` with this:

```coffee
module vertx.golo.demo

import io.vertx.core.Vertx
import io.vertx.core.http.HttpServer
import io.vertx.ext.web.Router
import io.vertx.ext.web.handler

import gololang.JSON

let vertx = Vertx.vertx()

function main = |args| {

  let server = vertx: createHttpServer()
  let router = Router.router(vertx)
  router: route(): handler(BodyHandler.create())

  let port =  Integer.parseInt(System.getenv(): get("PORT") orIfNull "8080")

  router: get("/"): handler(|context| {
    context: response(): putHeader("content-type", "text/html;charset=UTF-8")
    context: response(): end("<h1>Hello 🌍</h1>", "UTF-8")
  })

  router: get("/hi"): handler(|context| {
    context: response(): putHeader("content-type", "application/json;charset=UTF-8")
    context: response(): end(JSON.stringify(DynamicObject(): message("Hi 😛")), "UTF-8")
  })

  server: requestHandler(|httpRequest| -> router: accept(httpRequest)): listen(port)

  println("listening on " + port)
}
```

## Running the web application

Before running the application, you have to build it:

```shell
mvn package
```

And then, you can launch the application:

```shell
mvn exec:java
```

Now, you can test your web application, by calling [http://localhost:8080](http://localhost:8080) and [http://localhost:8080/hi](http://localhost:8080/hi)

## Deploying the web application on Clever-Cloud

⚠️ *Remark: you need a Clever-Cloud account and you added your SSH key to [https://console.clever-cloud.com/users/me/ssh-keys](https://console.clever-cloud.com/users/me/ssh-keys) (eg: you can use `cat ~/.ssh/id_rsa.pub` to get your public key)*

### Prepare your project

You need to create in your project directory a `clevercloud` directory with the `jar.json` file:

```json
{
  "build": {
    "type": "maven",
    "goal": "package"
  },
  "deploy": {
    "jarName": "target/vertx.golo.demo-0.0.1-SNAPSHOT-jar-with-dependencies.jar"
  }
}
```

Now, your project looks like that:

```shell
.
├── clevercloud
│   └── jar.json
├── pom.xml
├── src
│   └── main
│       └── golo
│           └── main.golo
```



Then, at the root of the project directory, type:

```shell
git init
git add .
```

If you type the command: `git status`, you shoud get this:

```shell
On branch master

Initial commit

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

	new file:   .gitignore
	new file:   clevercloud/jar.json
	new file:   pom.xml
	new file:   src/main/golo/main.golo
```

Then type:

```shell
git commit -m "first version"
```

Now you have to switch to the Clever-Cloud web administration console

### Deploying

In the administration console of your Clever-Cloud account:

- select **Add an application**
- click on the **CREATE A BRAND NEW APP** button
- select the **Java + Maven** runtime
- in the *Scalability* step, click on the **NEXT** button
- fill in the name of the application in the *Information* step (eg: `Vert-x-Golo-Demo`)
- click on the **CREATE** button
- in the *Add-on creation Provider*, click on the **I DON'T NEED ANY ADD-ON** button
- don't change anything in the *Environment Variables* tab and click on the **NEXT** button

You'll get a message like that:

```shell
git remote add clever git+ssh://git@push-par-clevercloud-customers.services.clever-cloud.com/app_c57bf90a-239d-4b8a-9aa6-c6e1b13c0149.git
git push -u clever master
```

Type these commands in your terminal at the root of your project directory, and then the deployment will start.

Now, you can see in the applications list panel a new application: `Vert-x-Golo-Demo`, you can change its domain name in the **Domain Names** panel, eg: `vertx.golo.demo` and now you can access to the web application with this url [http://vertx.golo.demo.cleverapps.io/](http://vertx.golo.demo.cleverapps.io/).

And of course you can test the `hi` route: [http://vertx.golo.demo.cleverapps.io/hi](http://vertx.golo.demo.cleverapps.io/hi).

That's all. 😊 You have seen that it's very easy to create web application with **Golo** and **Vert-x**, and even easier to deploy it on the cloud.

*Disclaimer: I'm working at Clever-Cloud*.

