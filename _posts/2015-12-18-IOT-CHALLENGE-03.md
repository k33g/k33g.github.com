---

layout: post
title: Open IOT Challenge, new baby step with Atta
info : Open IoT Challenge, new baby step with Atta
teaser: I participate in the Open IOT Challenge, my project is called "Atta", and today I completed a 1st version of the CoAP Gateway
---

#Open IOT Challenge: work in progress and CoAP Gateway

I participate in the Open IOT Challenge (see post [http://k33g.github.io/2015/12/10/IOT-CHALLENGE-01.html](http://k33g.github.io/2015/12/10/IOT-CHALLENGE-01.html)), my project is called "Atta", in the previous post, I was taking about of the implementation of MQTT Gateway simulator ([http://k33g.github.io/2015/12/15/IOT-CHALLENGE-02.html](http://k33g.github.io/2015/12/15/IOT-CHALLENGE-02.html)) and today I completed a 1st **simple** version of the CoaP Gateway.

##What is CoAP?

CoAP (Constrained Application Protocol) is used as IOT protocol, it’s a restful protocol and it's used with simple devices. in fact with CoAP, there is no central server. "Servers" of resources are listening on each devices or gateway. 
To my mind it's a good solution for problems of "high availability" and "fault tolerance": you can easily add or replace a Gateway, and it's more difficult to replace a server ;).

So, CoAP is a RESTful protocol, used in/with very simple electronics devices (LoWPAN). And a CoAP client makes query to a "server" of "resources" like that:

    GET /status/led/red
    POST /control/switchon/red

That is why, I also wanted to include a CoAP simulator in Atta (you know, my little DSL [https://github.com/ant-colony/atta](https://github.com/ant-colony/atta)).

##The CoAP Gateway

It's a first version, and it's a simple version (`SimpleCoapGateway` class) (one gateway - one resource and one REST method: `GET`), in the future, I'll provide a `CoapGateway` with the ability to get several resources and all REST methods.

It's also easy to create a CoAP gateway instance than creating a MQTT gateway instance (see previous post):

{% highlight groovy %}
def coapGateway = new SimpleCoapGateway(
  id:"coapgw000", 
  coapPort: 5686, 
  locationName: "Work", 
  path:"work" // this is the resource coap://host:5686/work
)

//add some sensors and start

coapGateway.sensors([
  new DHTSensor(id:"dht1", locationName: "DESK1"),
  new LightSensor(id:"l1", locationName: "DESK1")
]).start {

  every().seconds(5).run {
    coapGateway.notifyAllSensors()
  }

}
{% endhighlight %}

**Remark:** I've used the **Californium** project [https://www.eclipse.org/californium/](https://www.eclipse.org/californium/) to create my gateways.

###Use a NodeJS CoAP client to query the gateway

It's very easy to create a JavaScript CoAP client with the **node-coap** project [https://github.com/mcollina/node-coap](https://github.com/mcollina/node-coap)

{% highlight javascript %}
import coap from 'coap';
import bl from 'bl';

setInterval(() => {

  let requestToCoapGateway   = coap.request('coap://127.0.0.1:5686/work');

  requestToCoapGateway.on('response', (res) => {
    res.pipe(bl((err, data) => {
      let json = JSON.parse(data);
      console.log(json);
    }));
  });
  requestToCoapGateway.end();

}, 1000);
{% endhighlight %}


###Use a Golo CoAP client to query the gateway

**Golo** [http://golo-lang.org/](http://golo-lang.org/)  plays very well with **Californium**:

{% highlight golo %}
module coapclient

import org.typeunsafe.atta.core.Timer
import gololang.Async

function APPLICATION_JSON = -> 50

augment org.eclipse.californium.core.CoapClient {
  function getJsonData = |this| ->  this: get(APPLICATION_JSON())
  function postJsonData = |this, message| -> this: post(message, APPLICATION_JSON())
}

function coapClient = |server| {
  return org.eclipse.californium.core.CoapClient(server)
}

function main = |args| {

  let request = |server, port, resource| -> promise(): initializeWithinThread(|resolve, reject| {

    try {
      let coapCli = coapClient(server+":"+port+"/"+resource)
      let response = coapCli: getJsonData(): getResponseText()
      resolve(response)
    } catch (err) {
        reject(err)
    }
  })

  Timer.every(): seconds(1): run({

    request(server="coap://127.0.0.1", port=5686, resource="work")
      : onSet(|response| {
        println(response)
      })
      : onFail(|err| {
          println(err: getMessage())
      })

  })

}
{% endhighlight %}

Once again, you can see that it's very easy to simulate "connected things" with **Atta**. Next time, we'll see the REST Gateway and/or some more sophisticated sensors simulators.

**Atta** project is here: [https://github.com/ant-colony/atta](https://github.com/ant-colony/atta) *yes, I know, it lacks a little bit of documentation*.

Stay tuned :)






