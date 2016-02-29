---

layout: post
title: Open IOT Challenge, introduction
info : Open IoT Challenge, introduction
teaser: I participate in the Open IOT Challenge
---

# Open IOT Challenge: start-up

I participate in the Open IOT Challenge [http://iot.eclipse.org/open-iot-challenge/](http://iot.eclipse.org/open-iot-challenge/) (of the Eclipse Foundation). For some time, I wondered: "How can I test my backends infrastructure with thousands of connected objects (or more) without these objects?". My idea is to develop a simulator of things. So, my project is a software simulator of connected devices and gateways. It will be a DSL with **Groovy** [http://www.groovy-lang.org/](http://www.groovy-lang.org/) and **Golo** [http://golo-lang.org/](http://golo-lang.org/) like this:

{% highlight groovy %}
def coapGateway001 = new CoapGateway(id:"coapgw001", coapPort: 5683, execEnv: env, locationName: "Home")
def coapGateway002 = new CoapGateway(id:"coapgw002", coapPort: 5686, execEnv: env, locationName: "Work")

coapGateway001.sensors([
        new DHTSensor(id:"dhtRoom1", locationName: "ROOM1"),
        new DHTSensor(id:"dhtRoom2", locationName: "ROOM2"),
        new LightSensor(id:"lightRoom9A", locationName: "ROOM9"),
        new LightSensor(id:"lightRoom9B", locationName: "ROOM9")
]).start {
    while (true) {
        Thread.sleep(5000)
        coapGateway001.notifyAllSensors()
    }
}

coapGateway002.sensors([
        new DHTSensor(id:"dhtRoom3",locationName: "OFFICE01"),
        new DHTSensor(id:"dhtRoom4",locationName: "OFFICE02"),
        new DHTSensor(id:"dhtRoom5",locationName: "OFFICE03"),
        new SoundSensor(id:"soundRoom6",locationName: "OFFICE02"),
        new DHTSensor(id:"dhtRoom7",locationName: "OFFICE04"),
        new DHTSensor(id:"dhtRoom8",locationName: "OFFICE05"),
        new SoundSensor(id:"soundRoom9",locationName: "OFFICE03"),
        new DHTSensor(id:"dhtRoom10",locationName: "OFFICE06"),
])
.start {
    while (true) {
        Thread.sleep(5000)
        coapGateway002.notifyAllSensors() // I want all data of my sensors each 5s
    }
}
{% endhighlight %}

Firstly, it will come with three kinds of Gateway simulators (software): 

- CoAP, 
- MQTT 
- and "Virtual" (for tests) 

and with some Sensors simulators (software) with random data (ie: DHT sensors, light, **and even a herd of animals**)

but the DSL will be extandable. This DSL will allow to test/stress existing IOT backend platforms too. For certain scenario, it will be scalable and with high availability (eg: create a virtual platform to query thousand of CoaP resources).

The implemented technologies will include:

- CoAP (Californium)
- MQTT (Paho)
- Groovy for the core DSL
- Golo to create specific DSL from the core DSL
- Vert-X and Hazelcast (high availability)
- Nodejs (and some frameworks)
- ...

The project name is **Atta**, and you will be able (soon) to follow its progress on [https://github.com/ant-colony/atta](https://github.com/ant-colony/atta).

Stay tuned :)


