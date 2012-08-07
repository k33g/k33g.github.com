---

layout: post
title: Jo and CoffeeScript, sample
info : Jo and CoffeeScript, sample

---

#Jo is absolutely "sexy" with Coffeescript !

I continue my investigations with Jo and Coffeescript. Here's another little example :


    <!DOCTYPE HTML PUBLIC>
    <html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <meta name="viewport" content="initial-scale=1.0,
              maximum-scale=1.0, user-scalable=no, width=device-width">
        <meta name="format-detection" content="false">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="black">
        <title>Jo and Coffeescript</title>
        <link rel="stylesheet" href="jo2.css" type="text/css">

    </head>
    <body>
    </body>

    <script src="jo.js" type="text/javascript" charset="utf-8"></script>
    <script src="coffee-script.js" type="text/javascript" charset="utf-8"></script>

    <script type="text/coffeescript">

        jo.load()

        stack = new joStackScroller
        nav = new joNavbar
        toolbar = new joToolbar "This is a footer, neat huh?"
        backbutton = new joButton "Back"

        scn = new joScreen new joContainer [
                (new joFlexcol [nav, stack]),
                toolbar
            ]

        scn.setStyle {
            position: "absolute",
            top: "0",
            left: "0",
            bottom: "0",
            right: "0"
        }

        nav.setStack stack

        html = new joHTML "<b>Hello world !!!</b><br>This is nice !"

        page1 = new joCard [
                (new joLabel "HTML Control" ),
                (new joGroup new joHTML "<b>Hello world !!!</b><br>This is nice !"),
                (new joCaption "Hi, i'm a joCaption." ),
                (new joFooter [ new joDivider, backbutton ])
            ]

        list = new joMenu [
            { title: "Hello", id: "hello" },
            { title: "Salut", id: "salut" },
            { title: "Morgen", id: "morgen" },
            { title: "Page 1", id: "page1"}
        ]

        list.selectEvent.subscribe (id)->
            console.log id

            if id == "hello" then scn.alert id, "Hello"
            if id == "salut" then scn.alert id, "Salut"
            if id == "morgen" then scn.alert id, "Morgen"
            if id == "page1" then stack.push page1

        backbutton.selectEvent.subscribe ->
            stack.pop()

        menu = new joCard [list]
        menu.setTitle "Kitchen Sink Demo"

        stack.push menu

    </script>
    </html>
