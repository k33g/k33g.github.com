---

layout: post
title: Open IOT Challenge, what's up with Atta for Christmas?
info : Open IoT Challenge, what's up with Atta for Christmas?
teaser: I participate in the Open IOT Challenge, my project is called "Atta", and today I added 2 new sensors and logging abilities for the gateways
---

#Open IOT Challenge: what's up with Atta for Christmas?

Today (these last days in fact) I added 2 new sensors and logging features for the gateways.

##New sensors

I added 2 new "sensor abilities" (Groovy Traits) to Atta that produce less random data (I want more realistic data):

- temperature
- humidity

I've used this kind of formula:

    y = Amplitude * cos B(x - C) + D

*(where y is the value of the sensor, x is the time and the Amplitude is calculate with the min and max values.)*

For example, this is the **temperature** ability:

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

You can see that we model fluctuations in temperature data throughout the time:

{% highlight groovy %}
LocalDateTime now = LocalDateTime.now()
Double t = now.getMinute() + now.getSecond() / 100
this.temperatureValue = this.getTemperatureLevel(t)
{% endhighlight %}

And, of course, these sensors are very easy to use:

{% highlight groovy %}
def T = new TemperatureSensor(id:"001", minTemperature: -5.0, maxTemperature: 10.0, delay: 1000, locationName:"RoomA")
def H = new HumiditySensor(id:"H003", locationName:"Garden")
{% endhighlight %}

##Logging (and monitoring) features

I added a new object: **Supervisor**, that allows several things:

- display some data to the console about time: `-> [test](g002):emitting start:06:55:04.468 end:06:55:50.472 delay:46004 ms`
- log data to file
- get data from gateways with REST API or SSE streaming

*Remark: (the gateway has to implement `supervisable` trait).*

###Logging

For example, if you want to display informations:

{% highlight groovy %}
Supervisor supervisor = new Supervisor(scenarioName:"test")
    .loggerName("LOG01").loggerFileName("temperatures.humidity.log");
supervisor.gateways([gateway1, gateway2])
{% endhighlight %}

You have to get an instance of `Supervisor` and "assign" the gateways to the supervisor. Then if tou only want display informations, you can do something like that:

{% highlight groovy %}
gateway1.connect(success: { token ->

  gateway1.start {

    gateway1.startLog("emitting") // start logging

    every(2000).milliSeconds().run {
      gateway1.notifyAllSensors()

      gateway1.startLog("publication") // start logging

      gateway1
        .topic("home/sensors")
        .jsonContent(gateway1.lastSensorsData())
        .publish(success: {publishToken ->
          def res = gateway1.updateLog("publication", true, false) // only display informations
        })

      gateway1.updateLog("emitting", true, false) // only display informations
    }
  }

})
{% endhighlight %}

And then you'll get displayed informations like that:

    -> [test](g001):emitting start:07:38:30.856 end:07:38:34.870 delay:4014 ms
    -> [test](g001):publication start:07:38:34.868 end:07:38:34.871 delay:3 ms
    -> [test](g002):emitting start:07:38:30.853 end:07:38:34.872 delay:4019 ms
    -> [test](g002):publication start:07:38:34.869 end:07:38:34.873 delay:4 ms

**Remark**: `gateway1.updateLog("publication", true, false)` return a `Map`,  ie: `[scenarioName:test, gatewayId:g002, gatewayType:MQTT, task:publication, start:07:38:34.869, end:07:38:34.873, delay:4]
`

If you want to log data to a file (see `loggerFileName("temperatures.humidity.log")`), you have just to do that : `gateway1.updateLog("publication", true, true)` or even simpler `gateway1.updateLog("publication")`. Then you will find a log file (`temperatures.humidity.log`) that will look like this:

{% highlight xml %}
<record>
  <date>2015-12-28T07:38:33</date>
  <millis>1451284713065</millis>
  <sequence>204</sequence>
  <logger>LOG01</logger>
  <level>INFO</level>
  <class>java_util_logging_Logger$info$2</class>
  <method>call</method>
  <thread>14</thread>
  <message>[scenarioName:test, gatewayId:g001, gatewayType:MQTT, task:emitting, start:07:38:30.856, end:07:38:33.041, delay:2185]</message>
</record>
<record>
  <date>2015-12-28T07:38:33</date>
  <millis>1451284713065</millis>
  <sequence>205</sequence>
  <logger>LOG01</logger>
  <level>INFO</level>
  <class>java_util_logging_Logger$info$3</class>
  <method>call</method>
  <thread>15</thread>
  <message>[scenarioName:test, gatewayId:g002, gatewayType:MQTT, task:emitting, start:07:38:30.853, end:07:38:33.041, delay:2188]</message>
</record>
{% endhighlight %}

###"Monitoring"

I added two helpers if you want to make a web application to follow the gateways and their data. If you want to use it, you just have to do this:

{% highlight groovy %}
supervisor.startHttpServer(9090)
{% endhighlight %}

**Remark**: this part has been develop with **[Vert.x](http://vertx.io/)**.

####REST API

Then you can query gateways like that:

Open a browser with [http://localhost:9090/api/gateways](http://localhost:9090/api/gateways) and you'll get a JSON Array of data:

{% highlight json %}
[ {
  "id" : "g001",
  "kind" : "MQTT",
  "location" : "somewhere",
  "lastSensorsData" : {
    "001" : {
      "temperature" : {
        "unit" : "Celsius",
        "value" : 9.867154380465175
      },
      "locationName" : "RoomA",
      "when" : 1451285293203,
      "kind" : "TC°"
    },
    "002" : {
      "temperature" : {
        "unit" : "Celsius",
        "value" : 11.873813145857225
      },
      "locationName" : "RoomB",
      "when" : 1451285293203,
      "kind" : "TC°"
    },
    "H003" : {
      "humidity" : {
        "unit" : "%",
        "value" : 1.6094271405406957
      },
      "locationName" : "Garden",
      "when" : 1451285293204,
      "kind" : "H%°"
    }
  }
}, {
  "id" : "g002",
  "kind" : "MQTT",
  "location" : "somewhere",
  "lastSensorsData" : {
    "T004" : {
      "temperature" : {
        "unit" : "Celsius",
        "value" : 0.17712749271309214
      },
      "locationName" : "RoomB",
      "when" : 1451285293169,
      "kind" : "TC°"
    },
    "T003" : {
      "temperature" : {
        "unit" : "Celsius",
        "value" : 9.867154380465175
      },
      "locationName" : "RoomA",
      "when" : 1451285293168,
      "kind" : "TC°"
    },
    "H002" : {
      "humidity" : {
        "unit" : "%",
        "value" : 1.6094271405406957
      },
      "locationName" : "Garden",
      "when" : 1451285293169,
      "kind" : "H%°"
    }
  }
} ]
{% endhighlight %}

**Remark**: If you want to query a specific gateway, you can use the api with the id of the gateway: [http://localhost:9090/api/gateways/g002](http://localhost:9090/api/gateways/g002)

Of course you can use it with JavaScript like that (with jQuery):

{% highlight javascript %}
setInterval(function() {
  $.get("api/gateways").then(function(data) {
    console.log(data)
  });
}, 2000);
{% endhighlight %}

####SSE Streaming

If you prefer streaming than polling, **Supervisor** instance streams data to thanks SSE. You can open [http://localhost:9090/sse/all](http://localhost:9090/sse/all) to test it.

You'll obtain a flux like that:

    event: message
    data: [{"id":"g001","kind":"MQTT","location":"somewhere","lastSensorsData":{"001":{"temperature":{"unit":"Celsius","value":7.9672647056605905},"locationName":"RoomA","when":"2015-12-28T06:55:53+0000","kind":"TC\u00b0"},"002":{"temperature":{"unit":"Celsius","value":3.15452894071316},"locationName":"RoomB","when":"2015-12-28T06:55:53+0000","kind":"TC\u00b0"},"H003":{"humidity":{"unit":"%","value":15.498214331266041},"locationName":"Garden","when":"2015-12-28T06:55:53+0000","kind":"H%\u00b0"}}},{"id":"g002","kind":"MQTT","location":"somewhere","lastSensorsData":{"T004":{"temperature":{"unit":"Celsius","value":2.710313725785902},"locationName":"RoomB","when":"2015-12-28T06:55:53+0000","kind":"TC\u00b0"},"T003":{"temperature":{"unit":"Celsius","value":7.9672647056605905},"locationName":"RoomA","when":"2015-12-28T06:55:53+0000","kind":"TC\u00b0"},"H002":{"humidity":{"unit":"%","value":15.498214331266041},"locationName":"Garden","when":"2015-12-28T06:55:53+0000","kind":"H%\u00b0"}}}]

    event: message
    data: [{"id":"g001","kind":"MQTT","location":"somewhere","lastSensorsData":{"001":{"temperature":{"unit":"Celsius","value":7.9672647056605905},"locationName":"RoomA","when":"2015-12-28T06:55:53+0000","kind":"TC\u00b0"},"002":{"temperature":{"unit":"Celsius","value":3.15452894071316},"locationName":"RoomB","when":"2015-12-28T06:55:53+0000","kind":"TC\u00b0"},"H003":{"humidity":{"unit":"%","value":15.498214331266041},"locationName":"Garden","when":"2015-12-28T06:55:53+0000","kind":"H%\u00b0"}}},{"id":"g002","kind":"MQTT","location":"somewhere","lastSensorsData":{"T004":{"temperature":{"unit":"Celsius","value":2.710313725785902},"locationName":"RoomB","when":"2015-12-28T06:55:53+0000","kind":"TC\u00b0"},"T003":{"temperature":{"unit":"Celsius","value":7.9672647056605905},"locationName":"RoomA","when":"2015-12-28T06:55:53+0000","kind":"TC\u00b0"},"H002":{"humidity":{"unit":"%","value":15.498214331266041},"locationName":"Garden","when":"2015-12-28T06:55:53+0000","kind":"H%\u00b0"}}}]

And it's very easy to use it with JavaScript:

{% highlight javascript %}
var source = new EventSource('sse/all');
source.addEventListener('message', function(message) {
    console.log(JSON.parse(message.data));
}, false);
{% endhighlight %}

You can find a complete sample here: [https://github.com/ant-colony/atta/blob/master/sandbox/mqtt_samples/groovy/mqtt_temp_hum.groovy](https://github.com/ant-colony/atta/blob/master/sandbox/mqtt_samples/groovy/mqtt_temp_hum.groovy).

"Et voilà!", that's all for today. Next time, I will introduce you a new sensor to simulate **a herd of animals**. So stay tuned. :)



