---

layout: post
title: Riot and in-browser TRACEUR transpilation, ("React like")
info : Riot and in-browser TRACEUR transpilation, ("React like")
teaser: I love Riot (you know that), I love ECMAScript 6 (2015) (you know that), but I don't like "transpilation" (you know that). And I prefer to work with Traceur than Babel (to my mind, in-browser transpilation of Traceur is better). See how to do this
image: <img src="https://github.com/k33g/k33g.github.com/raw/master/images/riot240x.png" height="30%" width="30%">

---

#Riot and in-browser TRACEUR transpilation, ("React like")

This is the reading of this article that inspired me: [http://blog.srackham.com/posts/riot-es6-webpack-apps/](http://blog.srackham.com/posts/riot-es6-webpack-apps/).

##Prerequisite

You need:

- `traceur.min.js` (`bower install traceur`)
- `traceur.min.map`
- `rio.min.js` (`bower install riot`)
- you need an http server (this is very useful: [https://www.npmjs.com/package/http-server](https://www.npmjs.com/package/http-server))

So, you should have something like that:

    my-app/
    ├── public/ 
    |   ├── js/     
    |   |   ├── tags  
    |   |   |    └── yo-bob.js                
    |   |   └── bower_components/ 
    |   |        ├── riot/    
    |   |        |   └── riot.min.js   
    |   |        └── traceur/   
    |   |             └── traceur.min.js  
    |   ├── index.html      
    |   └── main.js
  
- create a `main.js` file in `public`
- create a `yo-bob.js` file in `public/js/tags`


##Prepare `index.html`

{% highlight html %}
<!DOCTYPE html>
<html>
<head lang="en">
    <meta charset="UTF-8">
</head>
<body>
    <!-- my very cute custom tag -->
    <yo-bob></yo-bob>

    <!-- traceur -->
    <script src="js/bower_components/traceur/traceur.min.js">
        traceur.options.experimental = true;
    </script>
    <!-- riot -->
    <script src="js/bower_components/riot/riot.min.js"></script>

    <script>
        System.import('main.js').catch(function (e) { console.error(e); });
    </script>

</body>
</html>
{% endhighlight %}

##Create ou tag `yo-bob`

We will not use the riot tags but describe our component in JavaScript (ES2015), using ES6 Template Strings like that:

Edit `yo-bob.js`:

{% highlight javascript %}
/* yo-bob tag */
riot.tag('yo-bob',
  `
    <h1>{label}</h1>
    <h2>{subLabel}</h2>
  `,
  function(opts) {

    let firstName = "Bob";
    let lastName = "Morane";

    this.label = '--- Yo! ---';
    this.subLabel = `Yo ${firstName} ${lastName}`;

    this.on('mount', () => {
      this.root.querySelector("h1").style.color = "red";
      this.root.querySelector("h2").style.color = "green";
    });
  }

);

export default {
  mount: (options) => {
    riot.mount('yo-bob', options);
  }
}
{% endhighlight %}

##Mount `yo-tag` in the package

Edit `main.js`:

{% highlight javascript %}
import yoBob from 'js/tags/yo-bob.js'

yoBob.mount({});
{% endhighlight %}

##"Run" it

    cd my-app
    http-server

Then, open [http://localhost:8080](http://localhost:8080)

That's all.












