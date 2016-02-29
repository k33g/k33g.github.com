---

layout: post
title: Open IOT Challenge, last step
info : Open IoT Challenge, last step
teaser: I participate in the Open IOT Challenge, my project is called "Atta" (an IOT simulator), and today I I summarize my project.
---

#AttA, last step (for the moment)

I participate in the Open IOT Challenge [http://iot.eclipse.org/open-iot-challenge/](http://iot.eclipse.org/open-iot-challenge/) . And my project is a simulator of things (connected devices and gateways). It names **AttA**, and it's a DSL written with **Groovy** [http://www.groovy-lang.org/](http://www.groovy-lang.org/) and **Golo** [http://golo-lang.org/](http://golo-lang.org/).

##Sensors and Gateways

**AttA** can work with MQTT and CoAP. You can easily simulate sensors:

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

and gateways:

{% highlight groovy %}
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
  gateway.start {
    // every 2 seconds, the gateway notifies the sensors to get data
    every().seconds(2).run {
      gateway.notifyAllSensors()
      // the gateway publishes the data on the "home/sensors" topic
      gateway
        .topic("home/sensors")
        .jsonContent(gateway.lastSensorsData())
        .publish(success: {publishToken -> println "yeah!"})
    }
  }
})
{% endhighlight %}

If you need to embed your simulator, you can use Golo too:

{% highlight golo %}
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

## Use "abilities" to add features to your sensors

Thanks Groovy's traits you can easily add abilities to a simulator, For example, this is the **temperature** ability:

{% highlight groovy %}
trait temperature {
  Double minTemperature = -10.0
  Double maxTemperature = 10.0
  Double B = Math.PI / 2
  Double unitsTranslatedToTheRight = new Random().nextInt(5).toDouble()
  String temperatureUnit = "Celsius"

  Double temperatureValue = null

  Double amplitude() { return (maxTemperature-minTemperature)/2 }
  Double unitsTranslatedUp() { return minTemperature + amplitude() }

  Double getTemperatureLevel(Double t) {
    return amplitude() * Math.cos(B *(t-unitsTranslatedToTheRight)) + unitsTranslatedUp()
  }

}
{% endhighlight %}

Then the **TemperatureSensor** is very easy to implements:

{% highlight groovy %}
class TemperatureSensor extends TemplateSensor implements temperature, location {
  String topic = "temperatures" // emission topic

  @Override
  void generateData() {
    LocalDateTime now = LocalDateTime.now()
    Double t = now.getMinute() + now.getSecond() / 100
    this.temperatureValue = this.getTemperatureLevel(t)
  }

  @Override
  Object data() {
    return [
        "kind": "TC°",
        "locationName":this.locationName,
        "temperature":["value": this.temperatureValue, "unit": this.temperatureUnit]
    ]
  }
}
{% endhighlight %}

##More complicated things

You can simulate more complicated things, like this:

<iframe width="600" height="400" frameborder="0" 
src="http://www.youtube.com/embed/dqOj3wRVC4s">
</iframe>

##Atta and me?

I use Atta to create scenario for my personal projects like [BoB:next](https://github.com/ZeiraCorp/bob.next.rtc) which is a project of "remote presence robot". And I use MQTT to send message to **"BoB"** (to move it for example), or to get message from **"BoB"**.

I know, **"BoB"** is ugly, but I can exchange data and test automatically some scenarios thanks to **AttA**, like sending some movement command whenan obstacle is detected.

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/bob-next.JPG" height="70%" width="70%">

I'm already thinking of the next version of **Atta** (probably a only Golo version).

Stay tuned!













