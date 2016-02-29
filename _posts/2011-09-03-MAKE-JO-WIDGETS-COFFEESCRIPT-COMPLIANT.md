---

layout: post
title: Make the Jo widgets "Coffeescript compliant"
info : Jo and Coffeescript does not share the same model of Class

---

# Make the Jo widgets "Coffeescript compliant"

## What is the problem ?

Unfortunately for me, Jo and Coffeescript does not share the same model of Class.
I wish to do something like this (to add some behaviors to my joButton , for example)


    class Button extends joButton
        constructor:(args)->
            super args

        changeBackGroundColor:(color)->
		    @setStyle({background : color})


... But ... Coffeescript disagrees. Indeed, the [Jo Class pattern](http://joapp.com/docs/# Class%20Patterns) is different from the Coffeescript model :

A "pure" implementation of joButton in coffeescript would probably look like this (after JS comilation):


      joButton = (function() {
        function joButton(data, classname) {
          joButton.__super__.constructor.call(this, args);
          this.enabled = true;
          if (classname) {
            this.container.classname = classname;
          }
        }
        joButton.prototype.createContainer = function() {};
        //etc. ...
        return joButton;
      })();

and a "daughter" class of joButton :


      Button = (function() {
        __extends(Button, joButton);
        function Button(args) {
          Button.__super__.constructor.call(this, args);
        }
        Button.prototype.changeBackGroundColor = function(color) {
          return this.setStyle({
            background: color
          });
        };
        return Button;
      })();


But in reality :

**joButton implementation :**


    joButton = function(data, classname) {
        // call super
        joControl.apply(this, arguments);
        this.enabled = true;

        if (classname)
            this.container.className = classname;
    };
    joButton.extend(joControl, {
        tagName: "jobutton",

        createContainer: function() {
            //...
        },
        //etc. ...

**SubClass of joButton :**


    Button = function(args) {
    	joButton.apply(this, args);
    }
    Button.extend(joButton,{
        changeBackGroundColor : function(color) {
          return this.setStyle({background: color});
        }
    });

And it works fine, but my problem now, is that it is not really compatible with Coffeescript :(
or Coffeescript isn't compatible with that ;)

- I don't think that [@balmer](https://twitter.com/# !/balmer) (Dad's Jo) is fun to rewrite Jo, even to please me.
- I did not want to rewrite my favorite framework (I'm not even sure to happen)

But, **I want "class", "extends", "CoffeScript" and "Jo" !!!**


## A Solution

I don't know if this is the best solution, but it works for me.

### In the first place

- I create a "base Widget Class" that copies all members of a "Jo Widget"
- I add a property `isCoffeeWidget` setted to `true` (we will see later why)


    class Widget
        constructor:(args)->
            for item of @joWidget
                @[item] = @joWidget[item]
            @isCoffeeWidget = true


- Now we can write Classes that inherit `Widget` and that retrieve the properties and methods of Jo widgets :



    # fake joButton
    class JOButton extends Widget
        constructor:(args)->
            @joWidget = new joButton args
            super args

    # fake joInput
    class JOInput extends Widget
        constructor:(args)->
            @joWidget = new joInput args
            super args

    # and so on ...


### In the second place

If you want to do something like that : `myJoGroup.push myNewFakedButton`, it will not work.
Indeed, the `joContainer.push()` method is waiting for an `Object` or an `Array` (of `Objects`). So, we have to override `joContainer.push()` method. Write this code (duplicate the code and patch it) :


	joContainer.prototype.push = function(data) {

        /* START --- working with Coffeescript ---*/
    	if (data.isCoffeeWidget) {
    		this.container.appendChild(data.container);
    	}
	    /* END --- working with Coffeescript ---*/

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


**Remark :** the only update/patch is :


        /* START --- working with Coffeescript ---*/
    	if (data.isCoffeeWidget) {
    		this.container.appendChild(data.container);
    	}
	    /* END --- working with Coffeescript ---*/



### And finally ...

You can do that :


    class Button extends JOButton
	    constructor:(args)->
		    super args

	    changeBackGroundColor:(color)->
		    @setStyle({background : color})

	myCuteButton = new Button "Hi! I'm a cute button"

	anyJoContainer.push myCuteButton

	# you can push Arrays of faked widgets

	myCuteButton.changeBackGroundColor "red"


## To conclude

- If you have a better idea, feel free to contact me
- You have no excuse not to do "Jo + Coffeescript"


*Have a nice day! [@k33g_org](https://twitter.com/# !/k33g_org)*
