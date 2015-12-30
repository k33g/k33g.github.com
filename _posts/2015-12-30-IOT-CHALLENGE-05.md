---

layout: post
title: Open IOT Challenge, AttA and the SpaceCows
info : Open IoT Challenge, AttA and the SpaceCows
teaser: I participate in the Open IOT Challenge, my project is called "Atta", and today I explain how to simulate a herd of animals (in movement)
---

#Open IOT Challenge, AttA and the SpaceCows

In the real world, a lot of connected things (like wearables) are moving. Think about this (virtual) use case:

- you are a space cowboy
- you have to manage a lot of space cows 
- you have to know in real time the position of each space cow (it's important, especially, for example, if some of them are under veterinary treatment)

To solve this kind of use case, I have created a new sensor: the **BoidSensor**, a sensor for work with several other sensors. I was inspired for this: [https://en.wikipedia.org/wiki/Boids](https://en.wikipedia.org/wiki/Boids).

*Boids is an artificial life simulation originally developed by Craig Reynolds. The aim of the simulation was to replicate the behavior of flocks of birds. Instead of controlling the interactions of an entire flock, however, the Boids simulation only specifies the behavior of each individual bird. With only a few simple rules, the program manages to generate a result that is complex and realistic enough to be used as a framework for computer graphics applications such as computer generated behavioral animation in motion picture films* ([source](http://cs.stanford.edu/people/eroberts/courses/soco/projects/2008-09/modeling-natural-systems/boids.html))

See it in action:

<iframe width="600" height="400" frameborder="0" 
src="http://www.youtube.com/embed/Bp8NkVVQ8uk">
</iframe>

Now, let see how to play with it.

##Extend the BoidSensor

You have first to extend `BoidSensor` class:

- extend `BoidSensor`
- add some specific properties
- override some properties (`kind`, `delay`, `locationName`)
- override `data()` method

That's all!

{% highlight groovy %}
class SpaceCowSensor extends BoidSensor {
  String nickName
  String kind = "Cow"
  String locationName = "Dallas"
  String sex = null

  // each cow has a size, I use it to display the cow in a webapp
  Double size = 5.0 

  Integer delay = 1000 // refresh rate

  @Override
  Object data() {

    return [
        "kind": this.kind,
        "locationName": this.locationName,
        "position": ["x": this.x, "y": this.y],
        "size": this.size,
        "id": this.id,
        "nickName": this.nickName,
        "sex": this.sex,
        "xVelocity": this.xVelocity,
        "yVelocity": this.yVelocity
    ]
  }

}
{% endhighlight %}

Now you can create several "spacecows" and link them to a MQTT Gateway:

{% highlight groovy %}
MQTTBroker broker = new MQTTBroker(protocol:"tcp", host:"localhost", port:1883)

// the playground spacecows
Constraints constraints = new Constraints(
    border:5,
    width: 800,
    height: 600,
    maxVelocity: 5
)

List<Boid> cows = []

Gateway g = new MQTTGateway(
    id:"g001",
    mqttId: "g001",
    locationName: "somewhere",
    broker: broker
).sensors([
  new SpaceCowSensor(id: "001", nickName:"Prudence", sex:"female", size:5, x: 5.0, y: 5.0, constraints: constraints, boids: cows),
  new SpaceCowSensor(id: "002", nickName:"Hazel", sex:"female", size:5, x: 5.0, y: 5.0, constraints: constraints, boids: cows),  
  new SpaceCowSensor(id: "002", nickName:"Kargo", sex:"male", size:5, x: 5.0, y: 5.0, constraints: constraints, boids: cows)
])

g.connect(success: { token ->

  g.start { // this is a thread

    every(1000).milliSeconds().run {
      g.notifyAllSensors()

      g.topic("cows/move")
          .jsonContent(g.lastSensorsData())
          .publish(success: {publishToken ->
            println(g.lastSensorsData())
          })

    } // end every

  } // end start

})
{% endhighlight %}

You can see a complete example here: [https://github.com/ant-colony/atta/blob/master/sandbox/boids_samples/spacecows.groovy](https://github.com/ant-colony/atta/blob/master/sandbox/boids_samples/spacecows.groovy).

To launch it, you have to:

- run a MQTT Broker (`./broker.sh`) created with **Mosca**: [https://github.com/ant-colony/atta/blob/master/sandbox/boids_samples/mqtt-broker.js](https://github.com/ant-colony/atta/blob/master/sandbox/boids_samples/mqtt-broker.js)
- run a Web application (`./webapp.sh`) that's using **Express**, **MQTT.js** and **Socket.io** (to communicate with the browser): [https://github.com/ant-colony/atta/blob/master/sandbox/boids_samples/webapp.js](https://github.com/ant-colony/atta/blob/master/sandbox/boids_samples/webapp.js)

The Web application (with a MQTT client) subscribes to `cows/+` and then receive all messages published by the gateway, remember:

{% highlight groovy %}
g.topic("cows/move")
    .jsonContent(g.lastSensorsData())
    .publish(success: {publishToken ->
      println(g.lastSensorsData())
    })
{% endhighlight %}

- then you can run the simulation: `./spacecows.sh` (that run the groovy script)

And if you want to see the result, you just have to open [http://localhost:8080/](http://localhost:8080/)

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/spacecows.png" height="70%" width="70%">

The Web application is using **Socket.io client** and **RaphaelJS**. You can see the code here: [https://github.com/ant-colony/atta/blob/master/sandbox/boids_samples/public/index.html](https://github.com/ant-colony/atta/blob/master/sandbox/boids_samples/public/index.html)

##An other sample

In the previous sample, I've used only one gateway and several sensors for this gateway, but we can imagine that each spacecow is connected, then for each spacecow (sensor) we have a gateway:

In this sample, every one second, we create a gateway and a spacecow, and every one second, each gateway publish her position:

{% highlight groovy %}
MQTTBroker broker = new MQTTBroker(protocol:"tcp", host:"localhost", port:1883)

Constraints constraints = new Constraints(
    border:5,
    width: 800,
    height: 600,
    maxVelocity: 5
)

Double random(Double value) {
  return (new Random()).nextInt(value.toInteger()).toDouble()
}

String uuid() {
  return java.util.UUID.randomUUID().toString()
}

List<Boid> cows = []
Integer counter = 1
String sex = "female"

every(1).seconds().run({

  MQTTGateway g =new MQTTGateway(
      id:"g${counter}",
      mqttId: "g${counter}",
      locationName: "somewhere",
      broker: broker
  ).sensors([
      new SpaceCowSensor(id: uuid(), nickName:"cow-${counter}", sex:sex, size:5, x: random(constraints.width), y: random(constraints.height), constraints: constraints, boids: cows),
  ])
  counter+=1
  if (sex=="female") sex="male" else sex="female"

  g.connect(success: { token ->

    g.start { // this is a thread

      every(1).seconds().run {
        g.notifyAllSensors()
        g.topic("cows/move")
            .jsonContent(g.lastSensorsData())
            .publish(success: {publishToken ->
          println(g.lastSensorsData())
        })
      } // end every
    } // end start
  })
})
{% endhighlight %}

You can find the complete sample here: [https://github.com/ant-colony/atta/blob/master/sandbox/boids_samples/spacecows2.groovy](https://github.com/ant-colony/atta/blob/master/sandbox/boids_samples/spacecows2.groovy).

**Pay attention!**: the front end is different, so you have to open [http://localhost:8080/index2.html](http://localhost:8080/index2.html)


here's what you'll get:

<iframe width="600" height="400" frameborder="0" 
src="http://www.youtube.com/embed/dqOj3wRVC4s">
</iframe>

Have a nice day! :)
Soon, something about **Node Red** and AttA. Stay tuned!

