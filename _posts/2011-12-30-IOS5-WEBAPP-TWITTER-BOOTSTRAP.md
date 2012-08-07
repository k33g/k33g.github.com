---

layout: post
title: ipad, iphone webapp with twitter bootstrap
info : ipad, iphone webapp with twitter bootstrap

---

#ipad, iphone webapp with twitter bootstrap

By adding a small matter, it is possible to very easily a mobile webapp (for iPad or iPhone) with "Twitter Bootstrap".

##What we need ?

###First, html skeleton

We have to :

- declare some `meta tag` about Safari Mobile
- include Twitter Bootstrap style sheet
- include jQuery
- include **tabs** javascript plugin of Twitter Bootstrap



        <!DOCTYPE HTML>
        <html>
        <head>
            <title>my webapp</title>
            <meta name="apple-mobile-web-app-capable" content="yes">
            <meta name="viewport" content="user-scalable=no, width=device-width, initial-scale=1.0, maximum-scale=1.0;" />
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />

        	<link rel="apple-touch-icon" href="icon.png"/>

            <!-- twitter bootstrap stylesheet -->
            <link rel="stylesheet" href="http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css">

            <!-- we need jQuery -->
            <script src="http://code.jquery.com/jquery-1.7.1.min.js"></script>

            <!-- we need tabs javascript plugin of twitter bootstrap -->
            <script src="http://twitter.github.com/bootstrap/1.4.0/bootstrap-tabs.js"></script>

        </head>
        <body>

        </body>
        <script>

        </script>
        </html>


###Add a few new css styles

To the end of the `<head>` tag :


    <style type="text/css">

        @media all {
        	.panel {
        	    overflow                    : hidden;
        	    position                    : absolute;
        	    display                     : block;
        	    width                       : 100%;
        	    padding-top                 : 60px;
        	    padding-bottom              : 60px;
        	    top                         : 0;
                /*height: 100%; */ /* uncomment if desktop */
        	}

        	.scrollable {
        	    overflow                    : scroll;
        		-webkit-overflow-scrolling  : touch;
        	}

            .insideScrollablePanel {
                margin-left                 : 5%;
                margin-right                : 5%;
                width                       : 90%;
            }

        } /* end of medial all */

        /*--- ipad ---*/
        /*--- full screen mode ---*/
        @media (device-width: 768px) and (orientation: portrait) {
        	.panel {
        		height						: 934px; /*1004-80*/
        	}
        }
        /*--- browser mode ---*/
        @media (device-width: 768px) and (orientation: landscape) {
        	.panel {
        		height						: 668px; /*748-80*/
        	}
        }

        /*--- iphone ---*/
        /*--- full screen mode ---*/
        @media (max-width: 480px) and (orientation: portrait) {
        	.panel {
        		height						: 380px; /*460-80*/
        	}
        }
        /*--- browser mode ---*/
        @media (max-width: 480px) and (orientation: landscape) {
        	.panel {
        		height						: 220px; /*300-80*/
        	}
        }
    </style>


What have we done ?

- we are playing with new css property `-webkit-overflow-scrolling : touch;` of iOS5 Safari Mobile, that allows [http://johanbrook.com/browsers/native-momentum-scrolling-ios-5/]("native momentul scrolling")
- we are using `@media queries` to change size of the webapp sides when rotating.

##Now, adding some html content

We need :

- a main div panel, surrounding :
 - a fixed toolbar (on top)
 - a scrollable panel (with tabs inside)

###Main skeleton :


    <body>
    <!-- MAIN PANEL -->
    <div class="panel">
        <!-- panel style is a twitter bootstrap style -->

        <!-- TOP BAR -->
        <div class="topbar">
            <!-- topbar style is a twitter bootstrap style -->
            <!-- here, tool bar definition -->
        </div>

        <!-- SCROLLABLE PANEL -->
        <div class="scrollable panel">
            <!-- scrollable and panel styles are new styles -->
            <!-- here, content -->
        </div>

    </div>
    </body>


###ToolBar :


    <body>
    <!-- MAIN PANEL -->
    <div class="panel">
        <!-- panel style is a twitter bootstrap style -->

        <!-- TOP BAR -->
        <div class="topbar">
            <div class="topbar-inner">
                <div class="container-fluid">
                    <a class="brand" href="#">WebAPP</a>
                    <ul class="nav">
                        <li><a href="#">Hello</a></li>
                        <li><a href="#">World</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- SCROLLABLE PANEL -->
        <div class="scrollable panel">
            <!-- scrollable and panel styles are new styles -->
            <!-- here, content -->
        </div>

    </div>
    </body>


###Scrollable panel with tabs :


    <body>
    <!-- MAIN PANEL -->
    <div class="panel">
        <!-- panel style is a twitter bootstrap style -->

        <!-- TOP BAR -->
        <div class="topbar">
            <div class="topbar-inner">
                <div class="container-fluid">
                    <a class="brand" href="#">WebAPP</a>
                    <ul class="nav">
                        <li><a href="#">Hello</a></li>
                        <li><a href="#">World</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- SCROLLABLE PANEL -->
        <div class="scrollable panel">
            <!-- CONTENT -->
            <div class="content insideScrollablePanel">
                <ul class="tabs" data-tabs="tabs">
                    <li class="active"><a href="#home">Home</a></li>
                    <li class=""><a href="#message">Message</a></li>
                </ul>

                <div id="my-tab-content" class="tab-content">

                    <div class="tab-pane active" id="home">
                        <!-- here some content -->
                    </div>

                    <div class="tab-pane" id="message">
                        <!-- here some content -->
                    </div>

                </div>
                <footer>
                    <p>I'm the footer</p>
                </footer>
            </div>
        </div>

    </div>
    </body>


###Activate tabs management with javascript

We are using `bootstrap-tabs.js` and `jquery-1.7.1.min.js`. Just after the `<body>` tag, add some javascript :


    <script>
        $('.tabs').tabs();
        $('.tabs').bind('change', function (e) {
          e.target;         // activated tab
          e.relatedTarget;  // previous tab
        });
    </script>


###Last step : add content in tabs


        <!-- SCROLLABLE PANEL -->
        <div class="scrollable panel">
            <!-- CONTENT -->
            <div class="content insideScrollablePanel">
                <ul class="tabs" data-tabs="tabs">
                    <li class="active"><a href="#home">Home</a></li>
                    <li class=""><a href="#message">Message</a></li>
                </ul>

                <div id="my-tab-content" class="tab-content">

                    <div class="tab-pane active" id="home">
                        <div class="hero-unit">
                            <h1>Hello, world!</h1>
                            <p>
                                Vestibulum id ligula porta felis euismod semper.
                                Integer posuere erat a ante venenatis dapibus posuere velit aliquet.
                                Duis mollis, est non commodo luctus, nisi erat porttitor ligula,
                                eget lacinia odio sem nec elit.
                            </p>
                            <p>
                                <a class="btn primary large">Learn more »</a>
                            </p>
                        </div>
                    </div>

                    <div class="tab-pane" id="message">
                        <div class="span5">
                            <h2>Heading</h2>
                            <p>
                                Donec id elit non mi porta gravida at eget metus.
                                Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh,
                                ut fermentum massa justo sit amet risus.
                                Etiam porta sem malesuada magna mollis euismod.
                                Donec sed odio dui.
                            </p>
                            <p>
                                <a class="btn" href="#">View details »</a>
                            </p>
                        </div>
                        <div class="span5">
                            <h2>Heading</h2>
                            <p>
                                Donec id elit non mi porta gravida at eget metus.
                                Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh,
                                ut fermentum massa justo sit amet risus.
                                Etiam porta sem malesuada magna mollis euismod.
                                Donec sed odio dui.
                            </p>
                            <p>
                                <a class="btn" href="#">View details »</a>
                            </p>
                        </div>
                    </div>

                </div>
                <footer>
                    <p>I'm the footer</p>
                </footer>
            </div>
        </div>


###What it looks like ?

![Alt "twittios501.png"](https://github.com/k33g/k33g.github.com/raw/master/images/twittios501.png)
![Alt "twittios502.png"](https://github.com/k33g/k33g.github.com/raw/master/images/twittios502.png)

##And now ... Splitted view for iPad !

###Change our styles

Add this :


    @media (orientation: portrait) {
        .left {
            float                       : left;
            left                        : 0%;
            width                       : 0%;

        }
        .right {
            float                       : right;
            left                        : 0%;
            width                       : 100%;
        }
    }

    @media (orientation: landscape) {
        .left {
            float                       : left;
            left                        : 0%;
            width                       : 30%;

        }
        .right {
            float                       : right;
            left                        : 30%;
            width                       : 70%;
            border-left                 : 1px solid black;
        }
    }


###Change our skeleton

We need :

- two panels (left and right), each surrounding :
 - a fixed toolbar (on top)
 - a scrollable panel (one with list and one with tabs inside)


        <body>

        <!-- LEFT PANEL -->
        <div class="panel left">

            <!-- TOP BAR -->
            <div class="topbar">
                <!-- ... -->
            </div>

            <!-- SCROLLABLE PANEL -->
            <div class="scrollable panel">
                <div class="sidebar insideScrollablePanel">
                    <!-- ... -->
                </div>
            </div>
        </div>

        <!-- RIGHT PANEL -->
        <div class="panel right">

            <!-- TOP BAR -->
            <div class="topbar right">
            <!-- don't forget adding right style -->
                <!-- ... -->
            </div>

            <!-- SCROLLABLE PANEL -->
            <div class="scrollable panel">
                <!-- CONTENT -->
                <div class="content insideScrollablePanel">
                    <!-- ... -->
                </div>
            </div>

        </div>
        </body>


###Final code (add some content) :


    <body>
    <!-- LEFT PANEL -->
    <div class="panel left">
        <!-- TOP BAR -->
        <div class="topbar">
            <div class="topbar-inner">
                <div class="container-fluid">
                    <a class="brand" href="#">WebAPP</a>
                </div>
            </div>
        </div>

        <!-- SCROLLABLE PANEL -->
        <div class="scrollable panel">

            <div class="sidebar insideScrollablePanel">
                <div class="well">
                    <h5>Sidebar</h5>
                    <ul>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                    </ul>
                    <h5>Sidebar</h5>
                    <ul>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                    </ul>
                    <h5>Sidebar</h5>
                    <ul>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                    </ul>

                    <h5>Sidebar</h5>
                    <ul>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                    </ul>
                    <h5>Sidebar</h5>
                    <ul>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                    </ul>
                    <h5>Sidebar</h5>
                    <ul>
                        <li><a href="#">Link</a></li>
                        <li><a href="#">Link</a></li>
                    </ul>

                </div>
            </div>
        </div>
    </div>

    <!-- RIGHT PANEL -->
    <div class="panel right">

        <!-- TOP BAR -->
        <div class="topbar right">
            <div class="topbar-inner">
                <div class="container-fluid">
                    <ul class="nav">
                        <li><a href="#">Hello</a></li>
                        <li><a href="#">World</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- SCROLLABLE PANEL -->
        <div class="scrollable panel">
            <!-- CONTENT -->
            <div class="content insideScrollablePanel">
                <ul class="tabs" data-tabs="tabs">
                    <li class="active"><a href="#home">Home</a></li>
                    <li class=""><a href="#message">Message</a></li>
                </ul>

                <div id="my-tab-content" class="tab-content">

                    <div class="tab-pane active" id="home">
                        <div class="hero-unit">
                            <h1>Hello, world!</h1>
                            <p>
                                Vestibulum id ligula porta felis euismod semper.
                                Integer posuere erat a ante venenatis dapibus posuere velit aliquet.
                                Duis mollis, est non commodo luctus, nisi erat porttitor ligula,
                                eget lacinia odio sem nec elit.
                            </p>
                            <p>
                                <a class="btn primary large">Learn more »</a>
                            </p>
                        </div>
                    </div>

                    <div class="tab-pane" id="message">
                        <div class="span5">
                            <h2>Heading</h2>
                            <p>
                                Donec id elit non mi porta gravida at eget metus.
                                Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh,
                                ut fermentum massa justo sit amet risus.
                                Etiam porta sem malesuada magna mollis euismod.
                                Donec sed odio dui.
                            </p>
                            <p>
                                <a class="btn" href="#">View details »</a>
                            </p>
                        </div>
                        <div class="span5">
                            <h2>Heading</h2>
                            <p>
                                Donec id elit non mi porta gravida at eget metus.
                                Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh,
                                ut fermentum massa justo sit amet risus.
                                Etiam porta sem malesuada magna mollis euismod.
                                Donec sed odio dui.
                            </p>
                            <p>
                                <a class="btn" href="#">View details »</a>
                            </p>
                        </div>
                    </div>

                </div>
                <footer>
                    <p>I'm the footer</p>
                </footer>
            </div>
        </div>

    </div>
    </body>


###What it looks like ?

![Alt "twittios503.png"](https://github.com/k33g/k33g.github.com/raw/master/images/twittios503.png)
![Alt "twittios504.png"](https://github.com/k33g/k33g.github.com/raw/master/images/twittios504.png)

**The Left side panel disappears when rotating (with portrait orientation).**

Your turn now ! ;)