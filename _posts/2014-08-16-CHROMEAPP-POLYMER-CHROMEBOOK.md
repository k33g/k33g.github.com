---

layout: post
title: Develop Polymer Chrome Apps on a ChromeBook
info : Develop Polymer Chrome Apps on a ChromeBook
teaser: Learn how to develop <b>Chrome Apps</b> directly on a <b>ChromeBook</b> with <b>Polymer</b> with a great IDE <b>Chrome Dev Editor</b>
image: <img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-14.png" height="50%" width="50%">

---

#Develop Polymer Chrome Apps on a ChromeBook with Chrome Dev Editor and deal with Content Security Policies

After watching this video **[Google I/O 2014 - How we built Chrome Dev Editor with the Chrome platform](https://www.youtube.com/watch?v=NNLnTz6yIc4)**, i decides to give a (serious) try to **[Chrome Dev Editor](https://chrome.google.com/webstore/detail/chrome-dev-editor-develop/pnoffddplpippgcfjdhbmhkofpnaalpg)**: 

*"Chrome Dev Editor (CDE) is a developer tool for building apps on the Chrome platform - Chrome Apps and Web Apps."*

It was an opportunity to learn how to develop **Chrome Apps**, but **directly** on a **ChromeBook**. The aim is also to see if a "low cost" computer as C720P Chromebook can be used as development workstation.

##1st contact

First good surprise CDE offers project templates, and especially for Chrome App Dart:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-01.png" height="80%" width="80%">

So, i tried the Dart template:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-02.png" height="80%" width="80%">

It's very interesting, you even have a list of methods in the right panel.

Now it's time to build our application, and then run it. I clicked on the **"run"** button ... and wait ...

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-03.png" height="80%" width="80%">

to finally get my first Chrome App (in more than **30 seconds!**):

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-04.png" height="80%" width="80%">

More than **30 seconds** (and 26 seconds on a MacBook pro), it's too long! **Chrome Dev Editor** is still not the right tool to train me with **Dart**.

So I decided to try the JavaScript version. So I repeated the same manipulations, but with the javascript project template, and the launch is instantaneous, which is normal, there is no code to "transpile". It will be much more comfortable to code, even if I lose the perks (goodies) related to Dart (as methods right panel).

##It's time to code!

It's been a while since I played with Polymer. And I am convinced that this is the ideal model for apps. So I would use Polymer.

Add a `bower.json` file to your project, with this content:

{% highlight json %}
{
  "name": "second-contact",
  "version": "0.0.0",
  "dependencies": {
    "polymer": "Polymer/polymer#~0.3.5"
  }
}
{% endhighlight %}

And, right click on the `bower.json` file and choose "Bower Install":

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-05.png" height="80%" width="80%">

This is a pleasant surprise, you can use Bower from CDE even with a ChromeBook. And you can see that all dependencies have been downloaded:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-06.png" height="80%" width="80%">

###First Web Component

First, create a `components` directory and a new file `my-title.html` (in the `components` directory) with this content:

{% highlight html %}
<link rel="import" href="../bower_components/polymer/polymer.html">

<polymer-element name="my-title">

  <template>
    <h1>{% raw %}{{label}}{% endraw %}</h1>
  </template>
  
  <script>
    Polymer("my-title", {
      ready: function() {
        this.label = "I <3 my ChromeBook";
      }
    });
  </script>

</polymer-element>
{% endhighlight %}

And, now prepare the main file of your application (`window.html`) to host your new component

{% highlight html %}
<!-- windows.html -->
<!DOCTYPE html>
<html>
  <head>
    <title>second-contact</title>
    <link rel="stylesheet" href="styles.css">
    <script src="bower_components/platform/platform.js"></script>
    <!-- your component -->
    <link rel="import" href="components/my-title.html">
  </head>

  <body>

    <my-title></my-title>
    
  </body>
</html>
{% endhighlight %}

**Remark**: you can delete `window.js` if you want.

And now ... Launch the Chrome App! ... **And nothing!!!**:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-07.png" height="80%" width="80%">

Right click on the screen application and choose **"Inspect element"**:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-08.png" height="80%" width="80%">

###Content Security Policy

If you read this [http://www.polymer-project.org/resources/faq.html#chromeapp](http://www.polymer-project.org/resources/faq.html#chromeapp), it is explained that *"Chrome Apps have a strict Content Security Policy (CSP) which prevents the use of inline script elements"*. So, you have to turn inline script elements into external files. You can use **[Vulcanize](http://www.polymer-project.org/articles/concatenating-web-components.html)** your components, but we are on a Chrome Book, so it's impossible. Then change content of `my-title.html` like that:

{% highlight html %}
<link rel="import" href="../bower_components/polymer/polymer.html">

<polymer-element name="my-title">

  <template>
    <h1>{% raw %}{{label}}{% endraw %}</h1>
  </template>
  
  <script src="my-title.js"></script>

</polymer-element>
{% endhighlight %}

And create (at the same location) a `my-title.js`:

{% highlight javascript %}
Polymer("my-title", {
  ready: function() {
    this.label = "I <3 my ChromeBook";
  }
});
{% endhighlight %}

And run again your application:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-09.png" height="80%" width="80%">

####Consequences

You can't use all existing components (core-components, paper-components) on a ChromeBook unless to vulcanize them before. But you still get the templating and data binding, and the "Web Component" way. So there are other constraints due to this security policy. We will see in the next paragraph.

##Second component

Let's create an other Polymer Component : `my-cute-button.htm` (and `my-cute-button.js`):

**`my-cute-button.htm`**:
{% highlight html %}
<link rel="import" href="../bower_components/polymer/polymer.html">

<polymer-element name="my-cute-button">

  <template>
    <button onclick="{% raw %}{{buttonClick}}{% endraw %}">{% raw %}{{label}}{% endraw %}</button>
  </template>
  
  <script src="my-cute-button.js"></script>

</polymer-element>
{% endhighlight %}

**`my-cute-button.js`**:
{% highlight javascript %}
Polymer("my-cute-button", {
  ready: function() {
    this.label = "I'm a button";
  },
  buttonClick: function() {
    this.label += " Clicked!";
  }
});
{% endhighlight %}

Add your new component to `window.html`:

{% highlight html %}
<!-- windows.html-->
<!DOCTYPE html>
<html>
  <head>
    <title>second-contact</title>
    <link rel="stylesheet" href="styles.css">
    <script src="bower_components/platform/platform.js"></script>
    <!-- yours components -->
    <link rel="import" href="components/my-title.html">
    <link rel="import" href="components/my-cute-button.html">
  </head>

  <body>

    <my-title></my-title>
    <my-cute-button></my-cute-button>

  </body>
</html>
{% endhighlight %}

Launch your application:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-10.png" height="80%" width="80%">

It's nice but if you click on the cute button, nothing happens. So, Right click on the screen application and choose **"Inspect element"**:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-11.png" height="80%" width="80%">

**It's still the fault of the CSP!!!** We've seen that inline scripts are forbidden, and it applys to inline event handlers too. See this [https://developer.chrome.com/extensions/contentSecurityPolicy#JSExecution](https://developer.chrome.com/extensions/contentSecurityPolicy#JSExecution).

###But, there is always a solution :)

See how to get around this problem and modify the Web Component "my-cute-button" :

- Remove `onclick="{% raw %}{{buttonClick}}{% endraw %}"` from the button
- Add an `id` to the button

**`my-cute-button.html`**:
{% highlight html %}
<link rel="import" href="../bower_components/polymer/polymer.html">

<polymer-element name="my-cute-button">

  <template>
    <button id="mybutton">{% raw %}{{label}}{% endraw %}</button>
  </template>
  
  <script src="my-cute-button.js"></script>

</polymer-element>
{% endhighlight %}

And add a listener to "click event" on the button:

**`my-cute-button.js`**:
{% highlight javascript %}
Polymer("my-cute-button", {
  ready: function() {
    this.label = "I'm a button";
    
    this.$.mybutton.addEventListener("click", function(event) {
      this.buttonClick();
    }.bind(this));
  },
  buttonClick: function() {
    this.label += " Clicked!";
  }
});
{% endhighlight %}

Run again the application, it works!:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-12.png" height="80%" width="80%">

##One More Thing: communication between components

I would change the title of the first component when I click on the 2nd. For that, the `<core-signals>` Polymer component is perfect (see [http://www.polymer-project.org/articles/communication.html#using-ltcore-signalsgt](http://www.polymer-project.org/articles/communication.html#using-ltcore-signalsgt)), but we've seen that the Chrome Apps CSP prohibit inline scripts and unless to "vulcanize" it, you have to use an other solution.

This is a quick and dirty solution (a parent controller and observer pattern are "advisable"), but it runs:

**Add a listener to "yo" event in `my-title.js`**:
{% highlight javascript %}
Polymer("my-title", {
  ready: function() {
    console.log("Hello")
    this.label = "I <3 my ChromeBook";
    
    document.addEventListener('yo', function(event) {
      this.label += " Clicked!"
    }.bind(this));
  }
});
{% endhighlight %}


**Fire "yo" event when button is clicked in `my-cute-button.js`**:
{% highlight javascript %}
Polymer("my-cute-button", {
  ready: function() {
    this.label = "I'm a button";
    
    this.$.mybutton.addEventListener("click", function(event) {
      this.buttonClick();
    }.bind(this));
  },
  buttonClick: function() {
    document.dispatchEvent(new CustomEvent("yo", {action:"clicked"}));
  }
});
{% endhighlight %}

And it runs!:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-13.png" height="80%" width="80%">

So, with some adjustments, it is entirely possible to use Polymer directly on a ChromeBook to develop Chrome Apps.
If you want to give your application an "attractive appearance", I advise you to use the **[Google Web Starter-Kit](https://developers.google.com/web/starter-kit/)**. If you want a sample, i've made a "quick start" here [https://github.com/metals/adamantium](https://github.com/metals/adamantium) and it looks like this on a Chrome Book:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-14.png" height="80%" width="80%">

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/chromeapp-15.png" height="80%" width="80%">

##To conclude

It's pretty nice to develop javascript Chrome applications with CDE, and especially the possibility to launch the application directly from CDE. Unfortunately, Dart transpilation is too long, but CDE (already transpiled) is a very good example of what is possible (with Dart but also with JavaScript) on a Chrome Book. So, I think my little C720P is a very interesting computer, and Chrome OS a very good OS.

I'm waiting deeply about native HTML Imports, then we'll can use Polymer with all its abilities.

I <3 Chrome* ;)
