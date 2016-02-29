---

layout: post
title: Enyo touch for Jo
info : Enyo touch for Jo

---

# Enyo touch for Jo

## Overriding joContainer.push()

This is just a little piece of code wich overrides `push()` method of `joContainer` (but keep previous mode) and so, allows you to describe GUI in an other way :


    joContainer.prototype.push =  function(data) {

        if(data.components) {
            for (var i = 0; i < data.components.length; i++) {
                this.push(data.components[i].kind);
                this[data.components[i].name] = data.components[i].kind;
            }

        } else {
            if (typeof data === 'object') {
                if (data instanceof Array) {
                    // we have a list of stuff
                    for (var i = 0; i < data.length; i++)
                        this.push(data[i]);
                }
                else if (data instanceof joView && data.container !== this.container) {
                    // ok, we have a single widget here
                    this.container.appendChild(data.container);
                }
                else if (data instanceof HTMLElement) {
                    // DOM element attached directly
                    this.container.appendChild(data);
                }
            }
            else if (typeof data === 'string') {
                // shoving html directly in does work
                var o = document.createElement("div");
                o.innerHTML = data;
                this.container.appendChild(o);
            }

            return this;
        }

    }

## Use it


    var row = new joFlexrow({ components : [
    	{ name : "btn1", kind : new JoButton("btn1") },
    	{ name : "btn2", kind : new JoButton("btn2") }
    ] });

    // or

    row.push({ { name : "btn3", kind : new JoButton("btn3") } });

    //so, now you can do that

    row.btn3.setData("<b>Hello i'm a button</b>");

## Bigger sample


    (function(){

        jo.load();

        /*--- Jo Application ---*/
        MyApp = this.MyApp = {};

        /*-[1]-- Main Scene aka application skeleton ---*/

        MyApp.scene = new joScreen({
            components : [
                { name : "mainContainer", kind : new joContainer({
                    components : [
                        { name : "flexCol", kind : new joFlexcol({
                            components : [
                                { name : "navBar", kind : new joNavbar() },
                                { name : "stack", kind : new joStackScroller() }
                            ]})
                        },
                        { name : "footer", kind : new joToolbar("I'm the footer") }

                    ]})
                }
            ]
        });

        MyApp.scene.mainContainer.flexCol.navBar.setStack(MyApp.scene.mainContainer.flexCol.stack);

        /*-[2]-- Main Screen ---*/

        MyApp.mainScreen = new joCard({
            components : [
                { name : "myGroup", kind : new joGroup({
                    components : [
                        { name : "cmd1", kind : new joButton("<b>CMD 1</b>") },
                        { name : "cmd2", kind : new joButton("<b>CMD 2</b>") },
                        { name : "txt1", kind : new joInput("…") }
                    ]
                }) }
            ]
        }).setTitle("Enyo touch demo");


        MyApp.mainScreen.myGroup.cmd1.selectEvent.subscribe(cmd1_OnClick,this);
        MyApp.mainScreen.myGroup.cmd2.selectEvent.subscribe(cmd2_OnClick,this);

        function cmd1_OnClick() {
            MyApp.mainScreen.myGroup.txt1.setData("cmd1_OnClick").focus();
        }

        function cmd2_OnClick() {
            MyApp.mainScreen.myGroup.txt1.setData("cmd2_OnClick").focus();
        }

        MyApp.scene.mainContainer.flexCol.stack.push(MyApp.mainScreen);

    }).call(this);


## Use it with CoffeeScript


    jo.load()

    window.MyApp = new Object()

    MyApp.scene = new joScreen
        components : [
            (name : "mainContainer", kind : new joContainer
                components : [
                    (name : "flexCol", kind : new joFlexcol
                        components : [
                            (name : "navBar", kind : new joNavbar),
                            (name : "stack", kind : new joStackScroller)
                        ]
                    ),
                    (name : "footer", kind : new joToolbar "I'm the footer")
                ]
            )
        ]

    MyApp.scene.mainContainer.flexCol.navBar.setStack MyApp.scene.mainContainer.flexCol.stack

    MyApp.mainScreen = new joCard
        components : [
            (name : "myGroup", kind : new joGroup
                components : [
                    ( name : "cmd1", kind : new joButton "<b>CMD 1</b>" ),
                    ( name : "cmd2", kind : new joButton "<b>CMD 2</b>" ),
                    ( name : "txt1", kind : new joInput "…" )
                ]
            )
        ]

    MyApp.mainScreen.setTitle "Enyo touch demo"

    MyApp.mainScreen.myGroup.cmd1.selectEvent.subscribe ->
        MyApp.mainScreen.myGroup.txt1.setData("cmd1_OnClick").focus()

    MyApp.mainScreen.myGroup.cmd2.selectEvent.subscribe ->
        MyApp.mainScreen.myGroup.txt1.setData("cmd2_OnClick").focus()

    MyApp.scene.mainContainer.flexCol.stack.push MyApp.mainScreen

*Have fun! :) @+ K33G_org*