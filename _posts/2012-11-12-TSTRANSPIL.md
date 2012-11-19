---

layout: post
title: continous typescript transpilation with grunt
info : continous typescript transpilation with grunt

---

#Continous Typescript "transpilation" with Grunt

I think **Typescript** is really a very good tool to develop good **Javascript**. I also think that **Typescript** can make you love **Javascript**. Of course, you can use Visual Studio on Windows, but you can also use **Typescript** with Linux or OSX (like me). We'll see how to do "Continuous Typescript Transpilation" thanks to **Grunt** (plus it also works under windows). I find it even more convenient with Visual Studio.

And it's very simple. 

> You can use your favorite text editor : you can find syntax highlighting support for SublimeText, Vim and Emacs here : [http://blogs.msdn.com/b/interoperability/archive/2012/10/01/sublime-text-vi-emacs-typescript-enabled.aspx](http://blogs.msdn.com/b/interoperability/archive/2012/10/01/sublime-text-vi-emacs-typescript-enabled.aspx)


##First Tools

- first install Typescript : `npm install -g typescript` *([http://www.typescriptlang.org/](http://www.typescriptlang.org/))*
- you need Grunt too : `npm install -g grunt` *([https://github.com/gruntjs/grunt](https://github.com/gruntjs/grunt))*

##First Project

Create your main directory project with sub-directories like that :

 	myapp-|
 		  |-ts\   <-- typescript files here + grunt.js
 		  |-app-\ <-- javascript files here


- Now, go to `ts` directory : `cd myapp/ts` and install typs-script grunt task locally : `npm install grunt-typescript` *[https://github.com/k-maru/grunt-typescript](https://github.com/k-maru/grunt-typescript)*
- Then, install "watch" grunt task : `npm install grunt-contrib-watch --save-dev` *([https://github.com/gruntjs/grunt-contrib-watch](https://github.com/gruntjs/grunt-contrib-watch))*

##grunt.js

In `ts` directory, create a `grunt.js` file with this content :

	module.exports = function(grunt) {

		grunt.loadNpmTasks('grunt-typescript');
		grunt.loadNpmTasks('grunt-contrib-watch');

		grunt.initConfig({

		    typescript: {
		      base: {
		        src: ['*.ts'],
		        dest: '../app',
		        options: {
		          target: 'es5' //or es3
		        }
		      }
		    },

			  watch: {
			    files: '**/*.ts',
			    tasks: ['typescript']
			  }

		});

		grunt.registerTask('default', 'watch');
	}

If you launch grunt in `ts` directory (from a terminal), typescript files will be compiled to javascript whenever you save your changes.

##Try it

- Open a terminal
- Go to `myapp/ts`
- run (type) command `grunt` *(under Windows, type `grunt.cmd`)*
- create a new typescript file `human.ts` in `ts` directory with this content :

		class Human {

			constructor (
				public firstName: string = "John", 
				public lastName: string = "Doe") {

				console.log("Hello ", firstName, lastName);
			}
		}

- save it
- `human.ts` is transpiled to `app/human.js` :

		var Human = (function () {
		    function Human(firstName, lastName) {
		        if (typeof firstName === "undefined") { firstName = "John"; }
		        if (typeof lastName === "undefined") { lastName = "Doe"; }
		        this.firstName = firstName;
		        this.lastName = lastName;
		        console.log("Hello ", firstName, lastName);
		    }
		    return Human;
		})();

- and `human.ts` will be transpiled, each time you save your changes. Compilation errors are displayed in the terminal.

