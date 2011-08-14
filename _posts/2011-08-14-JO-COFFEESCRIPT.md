---

layout: post
title: Jo + CoffeeScript : the ultimate weapon for mobile development ?
info : Jo + CoffeeScript

---

#Jo + CoffeeScript : the ultimate weapon for mobile development ?

This weekend, i started reading **["CoffeeScript: Accelerated Development JavaScript (by Trevor Burnham)"](http://pragprog.com/book/tbcoffee/coffeescript)**. I use javascript to development mainly mobile, my favorite framework is **[Jo](http://joapp.com/)**, so my question is: can I use **Jo** with **CoffeeScript** ?
Looks like it works (i'll dig the topic) :


    {% highlight coffeescript %}

    <!DOCTYPE HTML PUBLIC>
    <html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no, width=device-width">
        <meta name="format-detection" content="false">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="black">
        <title>Jo App</title>
        <link rel="stylesheet" href="jo2.css" type="text/css">

    </head>
    <body>
    </body>

    <script src="jo.js" type="text/javascript" charset="utf-8"></script>
    <script src="coffee-script.js" type="text/javascript" charset="utf-8"></script>

    <script type="text/coffeescript">

        jo.load()

        class Form
            constructor:(title, caption)->
                @stack = new joStackScroller
                @scn = new joScreen @stack
                @title = new joTitle title
                @caption = new joCaption caption
                @divider = new joDivider

                @button = new joButton "OK"
                @button.selectEvent.subscribe ->
                    console.log "OK OK"

                @card = new joCard [ @title , @caption, @divider, @button]

            show:->
                @stack.push @card

        mainForm = new Form "Hello", "Hello World !!!"

        mainForm.show()

    </script>

    </html>

    {% endhighlight %}
