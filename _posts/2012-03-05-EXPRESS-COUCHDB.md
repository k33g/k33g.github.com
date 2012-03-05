---

layout: post
title: stykkekode la suite
info : stykkekode la suite

---

#Express.js, le Play!>Framework du Javascript ? presque la Fin ...

##Il vous faut :

- avoir suivi les épisodes précédents : [Partie 1](http://k33g.github.com/2012/02/19/EXPRESSJS_IS_PLAY.html) et [Partie 2](http://k33g.github.com/2012/02/26/EXPRESSJS-RETURN.html)
- installer CouchDB : [http://couchdb.apache.org/index.html](http://couchdb.apache.org/index.html) vous pouvez trouver les binaires ici : [http://www.couchbase.com/download](http://www.couchbase.com/download)
- installer cradle dans votre répertoire applicatif [https://github.com/cloudhead/cradle](https://github.com/cloudhead/cradle)

**Cradle** est le client CouchDB pour node.js.

###Installer cradle :

    cd stykkekode
    npm install cradle

##Créer une base "snippets" dans couchdb

![Alt "express15.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express15.png)

![Alt "express16.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express16.png)

##Créer une vue dans couchdb :

Il suffit de créer un nouveau document dans la base "snippets" avec l'interface d'administration de CouchDB, avec le code suivant :

    {
       "_id": "_design/snippets",
       "language": "javascript",
       "views": {
           "all": {
               "map": "function(doc) { if (doc.user)  emit(doc) }"
           }
       }
    }

![Alt "express17.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express17.png)

##Modifions notre modèle "snippet.js" :

Remplacez le code existant par celui ci :

    /* SNIPPET MODEL */

    //utilisation de cradle
    var cradle = require('cradle');

    var snippet = function(title, code, user) {
        this.id = null;
        this.title = title ? title : "";
        this.code = code ? code : "";
        this.user = user ? user : "";
    }

    //déclaration de la connexion
    snippet.connection = new cradle.Connection ('localhost', 5984, { cache : true, raw : false });
    snippet.db = snippet.connection.database('snippets');


    //static
    snippet.list = [];

    snippet.prototype.save = function(callBack) {
        if(this.id === undefined || this.id === null || this.id === "") {
            var that = this;

                snippet.db.save(this, function(error, result) {
                    if( error ) { callBack(error) }
                    else {
                        console.log("Result : ", result);
                        that.id = result.id;
                        callBack(that);
                    }
                });

        } else {
            //snippet exists
        }
    };


    snippet.findAll = function(callback) {
        snippet.db.view('snippets/all',function(error, result) {
          if( error ){
            callback(error)
          }else{
            var docs = [];
            result.forEach(function (row){
              docs.push(row.key);
            });
            callback(docs);
          }
        });
    };


    exports.snippet = snippet;

##Modifions notre modèle "user.js"

On ajoute cette ligne `user.twitterListById[authenticatedUser.sourceUser.screen_name] = authenticatedUser;` dans la méthode `add`

    user.add = function(source, sourceUser) {
        user.nextUserId+=1;
        var authenticatedUser = new user(user.nextUserId, source, sourceUser);
        console.log("#################################");
        console.log(authenticatedUser.sourceUser.name);
        console.log(authenticatedUser.sourceUser.profile_image_url);
        console.log("#################################");
        user.listById[authenticatedUser.id] = authenticatedUser;

        user.twitterListById[authenticatedUser.sourceUser.screen_name] = authenticatedUser;

        return authenticatedUser;
    };

##Modifions routes/index.js

En début de fichier, ajouter la référence à `user` :

    var user = require('../models/user').user;

puis modifions `createSnippet` :

    exports.createSnippet = function(req, res) {
    	console.log("CREATE SNIPPET");

    	var model_from_client = JSON.parse(req.param("model", null));
    	console.log(model_from_client);

    	/*tronquer le code*/
    	model_from_client.code = model_from_client.code.substring(0,1455);

    	var server_model = new snippet(model_from_client.title, model_from_client.code, model_from_client.user);

    	//On ne sauvegarde uniquement si l'utilisateur est authentifié
    	if(user.findByTwitterId(model_from_client.user)) {
    		console.log("model_from_client.user",model_from_client.user);
    		server_model.save(function(m){
    			console.log(m);
    			res.json(m);
    		});
    	}

    };

##Vous pouvez tester !

- saisissez quelques données dans votre application
- puis allez voir dans la console d'administration de CouchDB

![Alt "express18.png"](https://github.com/k33g/k33g.github.com/raw/master/images/express18.png)

- Vos données sont bien persistées
- Vous remarquerez que nous n'avons rien eu pour le moment à changer dans le code concernant Backbone.

##La prochaine fois ...

Nous allons paginer, donc écrire de nouvelles vues pour CouchDB, et jouer un peu avec Backbone.

@+.

