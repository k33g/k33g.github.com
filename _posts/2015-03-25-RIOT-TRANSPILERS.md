---

layout: post
title: Riot and in-browser ECMAScript 6 transpilation
info : Riot and in-browser ECMAScript 6 transpilation
teaser: I love Riot, and to my mind it's useful that we don't need to pre-compile tags. But you have to do that if you want work with ECMAScript 6 or Coffeescript. That'a pity, because, these transpilers can make in-browser transpilation.
image: <img src="https://github.com/k33g/k33g.github.com/raw/master/images/riot240x.png" height="30%" width="30%">

---

# Riot and in-browser ECMAScript 6 transpilation (and Coffeescript)

I love Riot, and to my mind it's useful that we don't need to pre-compile tags. But you have to do that if you want work with ECMAScript 6 or Coffeescript. That'a pity, because, these transpilers can make in-browser transpilation.

## Problem

When you make a riot custom tag like this:

{% highlight javascript %}
<yo-bob>
  <h1>{% raw %}{label}{% endraw %}</h1>
  <h2>{% raw %}{subLabel}{% endraw %}</h2>
  <script type="es6">
    let firstName = "Bob";
    let lastName = "Morane";
    
    this.label = '--- Yo! ---';
    this.subLabel = `Yo ${% raw %}{firstName}{% endraw %} ${% raw %}{lastName}{% endraw %}`;

    this.on('mount', () => {
      this.root.querySelector("h1").style.color = "red";
      this.root.querySelector("h2").style.color = "green";
    });
  </script>
</yo-bob>
{% endhighlight %}

Then, you have to use riot executable to pre-compile the tag (see: [https://muut.com/riotjs/compiler.html# pre-compilation](https://muut.com/riotjs/compiler.html# pre-compilation)) and use a pre-processor (for my example it's **Babel**, because I want to develop with ES6), (see: [https://muut.com/riotjs/compiler.html# ecmascript-6](https://muut.com/riotjs/compiler.html# ecmascript-6))

I would like to do that but with a in-browser "transpilation". If you read the source code of `compiler.js` : [https://github.com/muut/riotjs/blob/master/compiler.js# L113](https://github.com/muut/riotjs/blob/master/compiler.js# L113), you can see this method which is called when "es6" (`<script type="es6">`) is detected:

{% highlight javascript %}
  function es6(js) {
    return require('babel').transform(js, { blacklist: ['useStrict'] }).code
  }
{% endhighlight %}

The browser can't use `es6()` because of `require()` method (which is a nodejs method).

## Trick

If you want in browser transpilation with **Babel**, first you have to include these two scripts in you html page:

- `browser-polyfill.js`
- `browser.js`

You can get these files when installing **Babel** (`npm install babel`) and after take the files in this directory `node_modules/babel`. Then, your page should look something like this:

{% highlight html %}
<!DOCTYPE html>
<html>
<head lang="en">
  <meta charset="UTF-8">
  <!-- babel -->
  <script src="js/browser-polyfill.js"></script>
  <script src="js/browser.js"></script>

  <script src="js/web-components/yo-bob.html" type="riot/tag"></script>

</head>
<body>
  <yo-bob></yo-bob>


  <script src="js/bower_components/riot/riot.js"></script>
  <script src="js/bower_components/riot/compiler.js"></script>

  <script>
      riot.mount("yo-bob");
  </script>

</body>
</html>
{% endhighlight %}

And now, we have to provide a `require()` method to the browser. It' simple, insert this code before `<script src="js/bower_components/riot/riot.js"></script>`:

{% highlight html %}
<script>
  window.require = function (module) {
    if (module=='babel') {
      this.transform = function (js, param) {
        return babel.transform(js, param);
      }
    }
    return this;
  }
</script>
{% endhighlight %}

And, it just works!

## Same thing with Coffeescript

It's simple too. Don't forget to include the transpiler in your page ([https://raw.githubusercontent.com/jashkenas/coffeescript/master/extras/coffee-script.js](https://raw.githubusercontent.com/jashkenas/coffeescript/master/extras/coffee-script.js)) and update the previous trick like that:

{% highlight html %}
<script>
  window.require = function (module) {
    if (module=='babel') {
      this.transform = function (js, param) {
        return babel.transform(js, param);
      }
    }
    if (module=='coffee-script') {
      this.compile = function (js, param) {
        return CoffeeScript.compile(js, param)
      }
    }
    return this;
  }
</script>
{% endhighlight %}

And now you can write your tag like that:

{% highlight html %}
<hi-bob>
  <h1>{label}</h1>
  <h2>{subLabel}</h2>

  <script type="text/coffeescript">
    firstName = "Bob"
    lastName = "Morane"

    @label = '--- Yo! ---'
    @subLabel = "Yo # {% raw %}{ firstName }{% endraw %} # {% raw %}{ lastName }{% endraw %}"

    @on 'mount', ->
      @root.querySelector('h1').style.color = 'orange'
      @root.querySelector('h2').style.color = 'blue'
  </script>
</hi-bob>
{% endhighlight %}

"Et voilà!" :)
