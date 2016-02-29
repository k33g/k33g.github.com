---

layout: post
title: Open IOT Challenge, AttA plays well with Node-RED
info : Open IoT Challenge, AttA plays well with Node-RED
teaser: I participate in the Open IOT Challenge, my project is called "Atta" (an IOT simulator), and today I explain how use it with Node-RED.
---

# AttA plays well with Node-RED

Today I explain how to test your AttA simulation scripts with Node-RED.

## Node-RED introduction

Node-RED is a project from IBM [http://nodered.org/](http://nodered.org/). This is a tool that allows to visually define connections, triggers, ... between things.

I wanted to check if AttA was compliant with Node-RED. But, first of all, we have to install Node-RED (you need NodeJS and npm):

    sudo npm install -g node-red

Then, you have to install CoAP support thanks to the project [node-red-contrib-coap](https://github.com/gatesense/node-red-contrib-coap):

    cd ~/.node-red
    npm install node-red-contrib-coap

Before running Node-RED, we are going to create an AttA script simulation. 

## AttA simulation

I want to simulate 2 MQTT Gateway and 1 CoAP Gateway:

{% highlight groovy %}
package iot_demo

import org.typeunsafe.atta.gateways.Gateway
import org.typeunsafe.atta.gateways.coap.SimpleCoapGateway
import org.typeunsafe.atta.gateways.mqtt.MQTTGateway
import org.typeunsafe.atta.gateways.mqtt.tools.MQTTBroker
import org.typeunsafe.atta.sensors.HumiditySensor
import org.typeunsafe.atta.sensors.LightSensor
import org.typeunsafe.atta.sensors.SoundSensor
import org.typeunsafe.atta.sensors.TemperatureSensor

import static org.typeunsafe.atta.core.Timer.every

MQTTBroker broker = new MQTTBroker(protocol:"tcp", host:"localhost", port:1883)

SimpleCoapGateway coapGateway0 = new SimpleCoapGateway(
    id:"coapgw0", 
    coapPort: 5686, 
    locationName: "Work", 
    path:"work"
)

coapGateway0.sensors([
    new SoundSensor(id:"soundRoom9",locationName: "OFFICE03"),
    new LightSensor(id:"lightRoom9A", locationName: "ROOM9")
]).start {
  every(5).seconds().run {
    coapGateway0.notifyAllSensors()
  }
}

Gateway gateway1 = new MQTTGateway(
    id:"g001",
    mqttId: "g001",
    locationName: "somewhere",
    broker: broker
).sensors([
    new TemperatureSensor(
        id:"001", 
        minTemperature: -5.0, maxTemperature: 10.0, 
        delay: 1000, locationName:"ChildrenRoom"
    ),
    new HumiditySensor(id:"H003", locationName:"Garden")
])

Gateway gateway2 = new MQTTGateway(
    id:"g002",
    mqttId: "g002",
    locationName: "somewhere",
    broker: broker
).sensors([
    new TemperatureSensor(
        id:"T003", 
        minTemperature: -5.0, maxTemperature: 10.0, 
        delay: 1000, locationName:"ParentsRoom"
    ),
    new HumiditySensor(id:"H002", locationName:"BathRoom")
])

gateway1.connect(success: { token ->

  gateway1.start {

    every(3).seconds().run {
      gateway1.notifyAllSensors()

      gateway1
        .topic("home/g1/sensors")
        .jsonContent(gateway1.lastSensorsData())
        .publish(success: {publishToken -> })

    }
  }

})

gateway2.connect(success: { token ->

  gateway2.start {

    every(4).seconds().run {
      gateway2.notifyAllSensors()

      gateway2
          .topic("home/g2/sensors")
          .jsonContent(gateway2.lastSensorsData())
          .publish(success: {publishToken -> })

    }
  }

})
{% endhighlight %}

You can find the source here: [https://github.com/ant-colony/atta/blob/master/sandbox/iot_demo/iot.groovy](https://github.com/ant-colony/atta/blob/master/sandbox/iot_demo/iot.groovy)

## MQTT Broker

You need a MQTT Broker:

{% highlight javascript %}
import mosca from 'mosca';

let mqttBroker = new mosca.Server({
  port: 1883
});

mqttBroker.on('clientConnected', (client) => {
  console.log('client connected', client.id);
});

mqttBroker.on('subscribed', (topic, client) => {
  console.log('subscribed : ', topic, client.id);
});

mqttBroker.on('clientDisconnected', (client) => {
  console.log('clientDisconnected : ', client.id)
});

mqttBroker.on('ready', () => {
  console.log('This is SKYNET listening on 1883');
})
{% endhighlight %}

You can find the source here: [https://github.com/ant-colony/atta/blob/master/sandbox/iot_demo/mqtt-broker.js](https://github.com/ant-colony/atta/blob/master/sandbox/iot_demo/mqtt-broker.js)

- start the broker (the complete sample [https://github.com/ant-colony/atta/blob/master/sandbox/iot_demo/](https://github.com/ant-colony/atta/blob/master/sandbox/iot_demo/)), run `npm install`, then `./broker.sh`
- start the simulation script: `./iot.sh` (you need Atta Project, and you have to build the project jar)

## Define connections with Node-RED

First, we have to run Node-RED:

    node-red

And now, open your browser [http://127.0.0.1:1880/](http://127.0.0.1:1880/)

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr01.png" height="70%" width="70%">

### Define our MQTT connection

 - **1:** Drag'n drop a mqtt input from the left column to the workspace

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr02.png" height="70%" width="70%">

- **2:** Double-Click on the mqtt node to setup the broker and to subscribe to a a topic

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr03.png" height="70%" width="70%">

Remember, the gateway publishes data on this topic: `home/g1/sensors`

{% highlight groovy %}
gateway1
  .topic("home/g1/sensors")
  .jsonContent(gateway1.lastSensorsData())
  .publish(success: {publishToken -> })
{% endhighlight %}

- **3:** Drag'n drop an output (debug) node from the left column to the workspace

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr04.png" height="70%" width="70%">

- **4:** Link the input node and the output node

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr05.png" height="70%" width="70%">

- **5:** Double-Click on the output node to setup the properties (notice the property `to` is set with `debug tab`)

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr06.png" height="70%" width="70%">

- **6:** Now, click on the **Deploy** button (at the top right corner), and then select the debug tab (in the right column)

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr07.png" height="70%" width="70%">

- **7:** You can do the same thing for the other MQTT gateway (don't forget to deploy to see data of the new gateway):

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr08.png" height="70%" width="70%">

### #   Add a log file

I want to store data in a log file:

- **1:** Drag'n drop a storage file node from the left column to the workspace

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr09.png" height="70%" width="70%">

- **2:** Double-Click on the file node to setup the properties

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr10.png" height="70%" width="70%">

- **3:** Link the file node to the 2 mqtt nodes, and deploy

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr11.png" height="70%" width="70%">

Now you have a `my.iot.log` file with all the data

### Define our CoAP connection

- **1:** To query a CoAP resource, drag'n drop a function "coap request" node from the left column to the workspace

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr12.png" height="70%" width="70%">

- **2:** Double-Click on the coap request node to setup the properties

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr13.png" height="70%" width="70%">

Remember, the path resource of the CoAP is `work` and the CoAP port is `5686`

{% highlight groovy %}
SimpleCoapGateway coapGateway0 = new SimpleCoapGateway(
    id:"coapgw0",
    coapPort: 5686,
    locationName: "Work",
    path:"work"
)
{% endhighlight %}

- **3:** You have to define a trigger to run the request: drag'n drop a input "inject" node to the workspace

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr14.png" height="70%" width="70%">

- **4:** Double-Click on the trigger node to setup the properties

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr15.png" height="70%" width="70%">

- **5:** Link the trigger node to the CoAP request node

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr16.png" height="70%" width="70%">

- **6:** Create an output (debug) node, link it to the CoAP request node and push the deploy button. Now you can see the CoAP data too:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/nr17.png" height="70%" width="70%">

That's all. Node-RED is a very interesting project, an now I'm sure that it plays well with Atta (a good test tool for me).

Stay tuned to the next episode. I think, I will play with **[Aedes](https://github.com/mcollina/aedes)** and AttA.

Have a nice day!