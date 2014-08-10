---

layout: post
title: Quick-start, mobile web application with Polymer and Material Design
info : Quick-start, mobile web application with Polymer and Material Design

---

#Mobile web application with Polymer and Material Design (quick-start)

>>We'll see how to create a mobile webapp for Android with Polymer (and a bit of "Material Design").

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/polymer-mob-00.jpg" height="40%" width="40%">

##Prepare the project

**Remark:** you need:

- bower [http://bower.io/](http://bower.io/)
- http-server [https://www.npmjs.org/package/http-server](https://www.npmjs.org/package/http-server) or any other http server

In a directory (ie: `my-project`) create 2 files:

- `.bowerrc`
- `bower.json`

with these contents:

###.bowerrc

{% highlight javascript %}
{
  "directory": "js/vendors"
}
{% endhighlight %}

###bower.json

{% highlight javascript %}
{
  "name": "my-project",
  "version": "0.0.0",
  "dependencies": {
    "polymer": "Polymer/polymer#~0.3.5",
    "core-elements": "Polymer/core-elements#~0.3.5",
    "paper-elements": "Polymer/paper-elements#~0.3.5"
  }
}
}
{% endhighlight %}

And type (in terminal or console application) : `bower install`, waiting ..., you're ready!

##Step 01: Our first component

**Specifications:**: "I want a web app with a main panel and a menu panel"

first create (at the root of `my-project`) a new html file named `index.html`:

{% highlight html %}
<!DOCTYPE html>
<!-- index.html -->
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, minimum-scale=1.0, initial-scale=1.0, user-scalable=yes">
  <meta name="mobile-web-app-capable" content="yes">
  <link rel="icon" sizes="196x196" href="rocket.png">
  <title>Copper</title>

  <!-- Polymer dependencies -->
  <script src="js/vendors/platform/platform.js"></script>

  <!-- core-elements dependencies -->
  <link rel="import" href="js/vendors/core-toolbar/core-toolbar.html">
  <link rel="import" href="js/vendors/core-menu/core-menu.html">
  <link rel="import" href="js/vendors/core-item/core-item.html">
  <link rel="import" href="js/vendors/core-header-panel/core-header-panel.html">
  <link rel="import" href="js/vendors/core-drawer-panel/core-drawer-panel.html">
  <link rel="import" href="js/vendors/core-scaffold/core-scaffold.html">
  <link rel="import" href="js/vendors/core-icons/core-icons.html">

  <!-- Reference to your component -->
  <link rel="import" href="js/components/main-screen.html">

</head>
<body>

  <!-- Your component -->
  <main-screen></main-screen>

</body>
</html>
{% endhighlight %}

So now, if you have followed, we will create a `main-screen` component.

###main-screen component

Firstly, create a `components` directory into `js` directory, and a new html file named `main-screen.html` inside `components` directory:

{% highlight html %}
<link rel="import" href="../vendors/polymer/polymer.html">

<polymer-element name="main-screen">

  <template>

    <core-scaffold>

      <core-header-panel navigation flex>
        <core-toolbar>
          <span>Menu</span>
        </core-toolbar>
        <core-menu>
          <core-item label="Android" icon="android"></core-item>
          <core-item label="Bug Report" icon="bug-report"></core-item>
          <core-item label="Account" icon="account-circle"></core-item>
        </core-menu>
      </core-header-panel>

      <span tool>
        My Killer Mobile Application
      </span>

      <div fit>
        <h1>Polymer Rocks!</h1>
      </div>

    </core-scaffold>
  </template>

  <script>

    Polymer("main-screen", {
      ready: function() {
        console.log("Main screen is ready!")
      }
    });

  </script>

</polymer-element>
{% endhighlight %}

My sample code is inspired from Polymer documentation [http://www.polymer-project.org/docs/elements/core-elements.html#core-scaffold](http://www.polymer-project.org/docs/elements/core-elements.html#core-scaffold) : *`core-scaffold` provides general application layout, introducing a responsive scaffold containing a header, toolbar, menu, title and areas for application content*.

**Note**: keyword `tool` in `<span tool>` tag allows the itle bar of the right panel.

You can test your web app now. Run your http sever (in my case, I run `http-server` from my project directory and I open [http://localhost:8080/](http://localhost:8080/) with **Chrome**). You get this:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/polymer-mob-01.png" height="60%" width="60%">

If you reduce width of browser window, left panel disappear, and a button appears inside the header:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/polymer-mob-02.png" height="60%" width="60%">

Click on the button, the left panel appears again (click outside the left panel to hide it):

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/polymer-mob-03.png" height="60%" width="60%">

**But it's ugly!**. We will have to make it a little prettier, this is "step 02".

You can find source code of this first step, here: [https://github.com/metals/copper/tree/master/creation-steps/step-01](https://github.com/metals/copper/tree/master/creation-steps/step-01).

##Step 02: something prettier

We will try to do something nicer. I will use the colors shown here: [http://www.google.com/design/spec/style/color.html#color-ui-color-palette](http://www.google.com/design/spec/style/color.html#color-ui-color-palette)

###Beautify the left panel

At the same location of your component (`main-screen.html`), create a css file `main-screen.css`. Add a reference to this file in your component code:

{% highlight html %}
<link rel="import" href="../vendors/polymer/polymer.html">

<polymer-element name="main-screen">

  <template>
    <link rel="stylesheet" href="main-screen.css">
    <core-scaffold>
    <!-- ... -->
{% endhighlight %}

**Remark:** you have to put `<link rel="stylesheet" href="main-screen.css">` inside `<template></template>`.

So, add some code to our css file:

{% highlight css %}
/* application font */
core-scaffold {
    font-family: sans-serif;
}

/* menu bar of the left panel */
core-toolbar {
    background: #000000;
    color: #fafafa;
}

/* content of the left panel */
core-header-panel {
    background: #616161;
    color: #fafafa;
}

.content {
    padding: 20px;
}
{% endhighlight %}

Add `content` class to the div "content" in `main-screen.html`:

{% highlight html %}
<div fit class="content">
  <h1>Polymer Rocks!</h1>
</div>
{% endhighlight %}

And test your web app again:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/polymer-mob-04.png" height="60%" width="60%">

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/polymer-mob-05.png" height="60%" width="60%">

It's better! ;)

###Beautify the right panel

`core-toolbar` and `core-header-panel`  are "difficult" to find because they are **inside the Shadow DOM**.

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/polymer-mob-06.png" height="60%" width="60%">

If you want to style these elements, you have to use this syntax: `::shadow` with your selector (try `document.querySelectorAll("core-scaffold::shadow core-toolbar")` with the browser console).

*(See this post: [http://stackoverflow.com/questions/24594333/polymer-core-scaffold-coloring-and-paper-button](http://stackoverflow.com/questions/24594333/polymer-core-scaffold-coloring-and-paper-button))*

Then, add this to `main-screen.css`:

{% highlight css %}
/* title bar of the right panel */
core-scaffold::shadow core-toolbar {
    background: #ff5722;
    color: #fafafa;
}
/* content of the right panel */
core-scaffold::shadow core-header-panel {
    background: #ffccbc;
    color: #212121;
}
{% endhighlight %}

And test your web app again:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/polymer-mob-07.png" height="60%" width="60%">

Nicer, no?

**But, there is not the shadow effect on the title bar of the right panel!!!**.

Add this `<link rel="import" href="js/vendors/paper-shadow/paper-shadow.html">` to the `index.html` file and update the `main-screen.html` file with `<paper-shadow z="1"></paper-shadow>` like that:

{% highlight html %}
<span tool>
  My Killer Mobile Application
  <paper-shadow z="1"></paper-shadow>
</span>
{% endhighlight %}

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/polymer-mob-08.png" height="60%" width="60%">

It's "more **Material Design**" ;)

Before we go any further, let's change two or three things. I want something "more reusable". Change the code of the component (`main-screen.html`):

{% highlight html %}
<link rel="import" href="../vendors/polymer/polymer.html">

{% endhighlight %}

**Add attributes for title bars: `attributes="menuTitle mainTitle"`**

{% highlight html %}
<polymer-element name="main-screen" attributes="menuTitle mainTitle">

  <template>
    <link rel="stylesheet" href="main-screen.css">
    <core-scaffold>

      <core-header-panel navigation flex>
        <core-toolbar>
{% endhighlight %}

**Value of `menuTitle` will be displayed here: `{% raw %}{{menuTitle}}{% endraw %}`**

{% highlight html %}     
   
          <span>{% raw %}{{menuTitle}}{% endraw %}</span>
        </core-toolbar>
        <core-menu>
          <core-item label="Android" icon="android"></core-item>
          <core-item label="Bug Report" icon="bug-report"></core-item>
          <core-item label="Account" icon="account-circle"></core-item>
        </core-menu>
      </core-header-panel>
{% endhighlight %}

**Value of `mainTitle` will be displayed here: `{% raw %}{{mainTitle}}{% endraw %}`**

{% highlight html %}      

      <span tool>
        {% raw %}{{mainTitle}}{% endraw %}
        <paper-shadow z="1"></paper-shadow>
      </span>

      <div fit class="content">
        <h1>Polymer Rocks!</h1>
      </div>

    </core-scaffold>
  </template>

  <script>

    Polymer("main-screen", {
      ready: function() {
        console.log("Main screen is ready!")
      }
    });

  </script>

</polymer-element>
{% endhighlight %}

And now you can (re)use your component like that (in `index.html`):

{% highlight html %}  
<main-screen 
  menuTitle="Menu" 
  mainTitle="My Killer Mobile Application">
</main-screen>
{% endhighlight %}


You can find source code of this second step, here: [https://github.com/metals/copper/tree/master/creation-steps/step-02](https://github.com/metals/copper/tree/master/creation-steps/step-02).

##Step 03: and now, some action 

Now I want to display different content in the right panel, when I click on the items in the left pane. For this I will use the component `core-pages` (see [http://www.polymer-project.org/docs/elements/core-elements.html#core-pages](http://www.polymer-project.org/docs/elements/core-elements.html#core-pages)).

We will once again change our component.

**Firstly**, add this `core-pages` reference to `index.html` : `<link rel="import" href="js/vendors/core-pages/core-pages.html">`.

Then, go back to our component (`main-screen.html`) to change the code:


{% highlight html %}  
<link rel="import" href="../vendors/polymer/polymer.html">

<polymer-element name="main-screen" attributes="menuTitle mainTitle">

  <template>
    <link rel="stylesheet" href="main-screen.css">
    <core-scaffold>

      <core-header-panel navigation flex>
        <core-toolbar>
          <span>{% raw %}{{menuTitle}}{% endraw %}</span>
        </core-toolbar>
{% endhighlight %}

**`core-menu` changes:**

- when an item is selected, we call `selectAction` method of `main-screen` : `on-core-select="{% raw %}{{selectAction}}{% endraw %}`
- I added a custom attribute `num` to each `core-item` : `num="0"`, `num="1"`, `num="2"`

{% highlight html %} 

        <core-menu on-core-select="{% raw %}{{selectAction}}{% endraw %}">
          <!-- num is personnalized attribute -->
          <core-item num="0" label="Android" icon="android"></core-item>
          <core-item num="1" label="Bug Report" icon="bug-report"></core-item>
          <core-item num="2" label="Account" icon="account-circle"></core-item>
        </core-menu>
      </core-header-panel>

      <span tool>
        {% raw %}{{mainTitle}}{% endraw %}
        <paper-shadow z="1"></paper-shadow>
      </span>

      <div fit class="content">
        <h1>Polymer Rocks!</h1>
{% endhighlight %}

**Add `core-pages` component:**

- first item is selected : `selected="0"`
- identify the component with `id="pages"`

{% highlight html %} 

        <core-pages id="pages" selected="0">
          <div>You have selected "Android"</div>
          <div>You have selected "Bug Report"</div>
          <div>You have selected "Account"</div>
        </core-pages>
      </div>

    </core-scaffold>
  </template>
{% endhighlight %}

**Add some code:**

- add reference to `pages` : `this.pages = this.$.pages; ` (`this.pages` becomes a property of `main-screen` component)
- get the value (`num` attribute) of the selected item: `selectedItem.attributes.num.nodeValue`
- select the "wanted" page: `this.pages.selected = selectedItem.attributes.num.nodeValue;`

{% highlight html %} 
  <script>

    Polymer("main-screen", {
      ready: function() {
        this.pages = this.$.pages; 
      },
      selectAction: function (e, detail) {
        if (detail.isSelected) {
          var selectedItem = detail.item;
          this.pages.selected = selectedItem.attributes.num.nodeValue;
        }
      }
    });

  </script>

</polymer-element>
{% endhighlight %}

You can try:

<img src="https://github.com/k33g/k33g.github.com/raw/master/images/polymer-mob-08.png" height="60%" width="60%">

Easy! :)

You can find source code of this third step, here: [https://github.com/metals/copper/tree/master/creation-steps/step-03](https://github.com/metals/copper/tree/master/creation-steps/step-03).

And now you can test it directly on your mobile: [http://metals.github.io/copper/](http://metals.github.io/copper/).

**Warning:** It's better with Chrome for Android, especially about styling, because there are no ShadowDom support on Safari Mobile (see [http://caniuse.com/shadowdom](http://caniuse.com/shadowdom)).

