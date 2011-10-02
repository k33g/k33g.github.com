---

layout: post
title: SenchaTouch becomes more readable and easier with Coffeescript
info : SenchaTouch and Coffeescript

---

#SenchaTouch becomes more readable and easier with Coffeescript

I always thought **SenchaTouch** is a fantastic mobile framework. But it quickly becomes difficult to code, especially if you do not master completely.

Fortunately, the birth of **Coffeescript** really changed the game.

This post is just a quick sample source code to illustrate my point. This a simple "splitview" sample.
I just want to see a list of choices, allowing me to view multiple screens.

Something like that :

![Alt "sencha-coffee.png"](https://github.com/k33g/k33g.github.com/raw/master/images/sencha-coffee.png)

##Initialize the html page :

Before, you need (of course) :

- to download **SenchaTouch** ([http://www.sencha.com/products/touch/download/](http://www.sencha.com/products/touch/download/)), then copy `sencha-touch.css` and `sencha-touch.js` in your working directory
- to download Coffeescript run-time ([https://raw.github.com/jashkenas/coffee-script/master/extras/coffee-script.js](https://raw.github.com/jashkenas/coffee-script/master/extras/coffee-script.js).) (or you can install Coffeescript and transpile to Javascript)

Then, create an html page :

{% highlight html %}

	<!DOCTYPE html>
	<html>
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
			<link rel="stylesheet" href="sencha/sencha-touch.css" type="text/css">
			<script src="coffee-script.js" type="text/javascript" charset="utf-8"></script>
			<script type="text/javascript" src="sencha/sencha-touch.js"></script>
		<head>
		<body></body>
		<script src = "sencha.demo.coffee" type="text/coffeescript"></script>

	</html>

{% endhighlight %}

And, now, create a `sencha.demo.coffee` file in which we will enter the code that follows.

##First, "Model & Models"

###Define them

{% highlight coffeescript %}

	class Model extends Ext.regModel
		constructor:(name, fields)->
			super name, 
				fields : fields
			@name = name

{% endhighlight %}

{% highlight coffeescript %}

	class Models extends Ext.data.JsonStore
		constructor:(model, sorters, data)->
			super
				model : model.name
				sorters : sorters
				data : data

{% endhighlight %}

###Initialize "Model & Models"

{% highlight coffeescript %}

	menuChoice = new Model 'menuChoice', ['code', 'label', 'item']

	menu = new Models menuChoice, 
		(property:'code',direction:'ASC'),
		[
			(code : '01', label : 'Card One',   item : 0)
	        (code : '02', label : 'Card Two',   item : 1)
			(code : '03', label : 'Card Three', item : 2)
		]

{% endhighlight %}

##Next, UI Components

###Header and Footer

{% highlight coffeescript %}

	class Header extends Ext.Toolbar
		constructor:(title)->
			super
				title : title
				dock : 'top'

{% endhighlight %}

{% highlight coffeescript %}

	class Footer extends Ext.Toolbar
		constructor:(title)->
			super
				title : title
				dock : 'bottom'

{% endhighlight %}

###Card (the screen that appears on the right side)

{% highlight coffeescript %}

	class Card extends Ext.Panel
		constructor:(html)->
			super
				margin : '10px'
				scroll : 'vertical'
				height : '100%'
				style  : 'background-color:white;'
				html   : html

{% endhighlight %}

###Right split view (a Card container)

{% highlight coffeescript %}

	class RightView extends Ext.Carousel
		constructor:(cards)->
			super
				height : '100%'
				layout : 'fit'
				direction : 'vertical'
				style : 'background-color:white;'
				items : cards # this is an array of cards

{% endhighlight %}

###Left split view  (a kind of menu or list)

{% highlight coffeescript %}

	class LeftView extends Ext.List
		constructor:(template, models, linkedView, fieldItemIndex)->
			super
				scroll : 'vertical'
				dock : 'left'
				style : "border-right:solid black 1px;"
				width : 250
				itemTpl : template
				store : models
				listeners :
					itemtap : (subList, subIdx)->
						store = subList.getStore()
						record = store.getAt subIdx
						#When i "tap" a item menu, i activate the corresponding card
						linkedView.setActiveItem record.get fieldItemIndex

{% endhighlight %}

###The main screen (it will encapsulate all the elements of the UI)

{% highlight coffeescript %}

	class MainScreen extends Ext.Panel
		constructor:(items)->
			super
				fullscreen : true
				dockedItems: [items.header,items.footer,items.leftSidePanel]
				items : [items.rightSidePanel]

{% endhighlight %}

##Last step : initialize the application

{% highlight coffeescript %}

	Ext.setup 
		onReady: ->
			header = new Header "Sencha <3 Coffeescript"
			footer = new Footer "by k33g_org"
			card1 = new Card "
				<b>Card 1</b>
				<p>
					Donec sed odio dui. Maecenas sed diam eget risus varius blandit sit amet non magna. 
				<p>
			"
			card2 = new Card "
				<b>Card 2</b>
				<p>
					Morbi leo risus, porta ac consectetur ac, vestibulum at eros. 
				<p>
			"
			card3 = new Card "
				<b>Card 3</b>
				<p>
					Maecenas sed diam eget risus varius blandit sit amet non magna. 
				<p>
			"

			rightView = new RightView [card1, card2, card3]
			leftView = new LeftView '{code} {label}', menu, rightView, 'item'
			mainScreen = new MainScreen 
				header : header 
				footer : footer
				leftSidePanel : leftView
				rightSidePanel : rightView

{% endhighlight %}

That's all. Launch it ! 

If you don't know SenchaTouch, try to do it in javascript ... ;)
