---

layout: post
title: Jo and CoffeeScript
info : Jo and CoffeeScript

---

#Jo and CoffeeScript : the ultimate weapon for mobile development ?

This weekend, i started reading **["CoffeeScript: Accelerated Development JavaScript (by Trevor Burnham)"](http://pragprog.com/book/tbcoffee/coffeescript)**. I use javascript to development mainly mobile, my favorite mobile framework is **[Jo](http://joapp.com/)**, so my question is: can I use **Jo** with **CoffeeScript** ?
Looks like it works (i'll dig the topic) :


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
