---

layout: post
title: Open IOT Challenge, work in progress and MQTT Gateway
info : Open IoT Challenge, work in progress and MQTT Gateway
teaser: I participate in the Open IOT Challenge, my project is called "Atta", and today I completed a 1st version of the MQTT Gateway
---

#Open IOT Challenge: work in progress and MQTT Gateway

I participate in the Open IOT Challenge (see previous post [http://k33g.github.io/2015/12/10/IOT-CHALLENGE-01.html](http://k33g.github.io/2015/12/10/IOT-CHALLENGE-01.html)), my project is called "Atta", and today I completed a 1st version of the MQTT Gateway.

##According to me, what is a connected thing?

There are certainly many definitions. I give you my own definition (one that guides me in designing my DSL).

A connected thing is a device 

- composed of sensors (position, temperature, heart beat, ...)
- with an autonomy
- with (sometimes) a display (ie: screen of watch, Withing, ...)
- that can (sometimes) interact with other devices (ie: sending messages between 2 AppleWatch)
- that can connect to a network (internet)

Some devices can directly connect to internet because they directly embed a wifi component or a rj45 plug or they use a "gateway" (or a hub) to connect to the network (in the first case, the gateway is embedded).

In the case of Atta DSL, a connected thing is a Gateway class with a list of sensors. Each sensors is "autonomous" and publish data to the Gateway instance (and the Gateway instance is in charge to provide sensors' data to the world).

##The MQTT Gateway

Today, I've finalize a first (alpha) version of the MQTT Gateway class. I will commit source code soon, but here are some explanations:

the `MQTTGateway` class extends `MQTTDevice` class and implements `Gateway` interface and `commonGatewayAbilities` trait (I love traits).

###Create a sensor

`MQTTGateway` (and other Gateway implementations) can use pre-defined Atta sensors or you can create your own sensors:

{% highlight groovy %}
class TinySensor extends TemplateSensor {
  Integer value = 0
  Integer delay = 1000 // default delay is 5000 ms
  @Override
  void generateData() {
    this.value =  new Random().nextInt(500)
  }

  @Override
  Object data() {
    return [
        "id": this.id,
        "kind": "Tiny",
        "locationName": "@Home",
        "value": this.value,
        "unit": "something"
    ]
  }
}
{% endhighlight %}

Once the sensor is started (when its gateway is started), each 1000 ms, the `generateData()` is called and it updates the value of the sensor.
And when the sensor is notified by the gateway, it produces a message with data (`data() method`) and notifies the gateway with the message.

The sensor works in a thread.

###Use the sensor(s) with the MQTTGateway

First of all, you need a MQTT Broker. You can use for example [Moquette](https://github.com/andsel/moquette) (Java MQTT Broker) or [Mosca](https://github.com/mcollina/mosca) (NodeJS MQTT Broker)

This is a quick an dirty sample of MQTT broker with Mosca:
{% highlight javascript %}
import mosca from 'mosca';

let mqttBroker = new mosca.Server({
  port: 1883
});

mqttBroker.on('clientConnected', (client) => {
  console.log('client connected', client.id);
});

// When a message is received
mqttBroker.on('published', (packet, client) => {
  if(packet.cmd=="publish") {
    console.log(client.id, packet.payload.toString());
  }
});

// When a client subscribes to a topic
mqttBroker.on('subscribed', (topic, client) => {
  console.log('subscribed : ', topic, client.id);
});

mqttBroker.on('clientDisconnected', (client) => {
  console.log('clientDisconnected : ', client.id)
});

mqttBroker.on('ready', () => {
  console.log('I am listening on 1883');
})
{% endhighlight %}

It's very simple (I'm using ES2015, so you can run it with **babel**).

Once the broker is ready (and started), here's the groovy script to simulate gateway(s):

{% highlight groovy %}
// we need to connect to the mqtt broker
def broker = new MQTTBroker(protocol:"tcp", host:"localhost", port:1883)
// --- Define a MQTT Gateway
def gateway = new MQTTGateway(
  id:"g01",
  mqttId: "mqtt_g01",
  locationName: "somewhere",
  broker: broker
).sensors([ // add some sensors to the gateway
    new TinySensor(id:"001"),
    new TinySensor(id:"002")
])

gateway.connect(success: { token ->
  println "$gateway.mqttId is connected"

  gateway.start {
    // every 2 seconds, the gateway notifies the sensors to get data
    every().seconds(2).run {
      gateway.notifyAllSensors()

      // the gateway publishes the data on the "home/sensors" topic
      // lastSensorsData() method get last data published by the sensors
      gateway
        .topic("home/sensors")
        .jsonContent(gateway.lastSensorsData())
        .publish(success: {publishToken -> println "yeah!"})
    }
  }

})
{% endhighlight %}

So it's very easy to create a lot of sensors and a lot of gateways to **"stress"** your broker. :)

##Using the MQTT Gateway with Golo

**[Golo](http://golo-lang.org/)** is my favorite "tiny language" for the JVM (disclaimer: I commit sometimes on the Golo project). Golo is incubating at the **Eclipse Foundation**.

I try to develop Atta DSL, keeping in mind that it can be used with other languages. So, it is already possible to use it with Golo.

###Define a new sensor with Golo

There is no class in Golo, so we have to use *Adapters* (see [http://golo-lang.org/documentation/next/index.html#_adapters_helper](http://golo-lang.org/documentation/next/index.html#_adapters_helper)).

{% highlight golo %}
# --- Create your own sensor ---
function PoneySensor = |id| {

  let x = Observable(0)
  x: onChange(|value| -> println("# sensor "+ id + " x:"+value))

  let y = Observable(0)
  y: onChange(|value| -> println("# sensor "+ id + " x:"+value))

  let sensorDefinition = Adapter()
    : extends("org.typeunsafe.atta.sensors.TemplateSensor")
    : overrides("generateData", |super, this| {
        x: set(java.util.Random(): nextInt(500))
        y: set(java.util.Random(): nextInt(500))
    })
    : overrides("data", |super, this| {
        return map[
          ["id", this: id()],
          ["kind", "PoneySensor"],
          ["locationName", "@Rainbow"],
          ["x", x: get()],
          ["y", y: get()],
          ["unit", "coordinates"]
        ]
    })

  let sensorInstance = sensorDefinition: newInstance()

  sensorInstance: id(id)
  sensorInstance: delay(2000)

  return sensorInstance

}
{% endhighlight %}

###Define a MQTT gateway with Golo

The difficulty (for the moment) is that closures are not implemented in the same way with Golo or Groovy. So, I've created some methods in `MQTTGateway` class and `MQTTDevice` class to be used from Golo. I will create later modules to make the use with Golo more fluent.

{% highlight golo %}

function MqttPoneyGateway = |id, mqttId, locationName, broker| {
  let gatewayDefinition = Adapter()
    : extends("org.typeunsafe.atta.gateways.mqtt.MQTTGateway")
    : implements("onPublishSuccess", |this, token| {
        println("Publication is OK")
    })
    : implements("onStart", |this| {

        println(">>> the gateway is starting...")

        this: subscribeTo("huston/+")

        Timer.every(): seconds(2): run({

          this: notifyAllSensors()

          this: topic("poneys") # publication topic
            : jsonContent(this: lastSensorsData())
            : publish()

        })
    })
    : implements("onSuccess", |this, token| {
        println(this: id() + " is connected :)")
        # start the gateway when connection is ok
        this: start()
    })
    : implements("onFailure", |this, token, err| {
        println("Huston? We've got a problem!")
    })
    : implements("onMessageArrived", |this, topic, message| {
        println("You've got a message")
    })
    : implements("onSubscribeSuccess", |this, token| {
        println("Subscription is ok.")
    })

  let gatewayInstance = gatewayDefinition: newInstance()
  gatewayInstance: id(id)
  gatewayInstance: mqttId(mqttId)
  gatewayInstance: locationName(locationName)
  gatewayInstance: broker(broker)

  return gatewayInstance
}
{% endhighlight %}

And now we can use it like that: **I want 1000 connected poneys!**

{% highlight golo %}
function main = |args| {

  let broker = MQTTBroker(protocol="tcp", host="localhost", port=1883)

  1000: times(|index| {

    let gateway = MqttPoneyGateway(
      id="g"+index,
      mqttId="mqtt_g"+index,
      locationName="somewhere over the rainbow",
      broker=broker
    ): sensors(list[
      PoneySensor(id="PoneysFarm_"+index)
    ])

    gateway: connect()

  })

}
{% endhighlight %}

You can see that it's very easy to stress a MQTT Broker. Next time, we'll see the CoAP Gateway and this probably will be the opportunity to publish a first version of Atta.

Stay tuned :)






