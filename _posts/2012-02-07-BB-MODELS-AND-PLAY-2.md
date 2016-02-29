---

layout: post
title: BB plays with Play, la suite
info : How to connect Backbone Models to PlayFramework Models

---

# BackBone Models & Play!> Models jouent ensemble : La suite

## Pré-requis (indispensable!)

Avoir lu la 1ère partie : [http://k33g.github.com/2012/02/04/BB-MODELS-AND-PLAY.html](http://k33g.github.com/2012/02/04/BB-MODELS-AND-PLAY.html)

## Problématique : 

Je souhaite affecter une technologie à un bookmark (je classe mes bookmarks par techno).

C'est à dire que côté Backbone, je vais avoir ceci :

Dans `app/views/Application/index.html`, je vais avoir un nouveau modèle `Techno` : 


	window.Techno = Backbone.Model.extend({
        url : 'bb/techno',
        defaults : {
            id: null,
            label : ""
        }
    });

    window.Technos = Backbone.Collection.extend({
        model : Techno,
        url : 'bb/technos'
    });


Et je voudrais pouvoir faire des "choses" comme celles-ci :


	var jstechno = technosCollection.find(function(techno){ return techno.get("label") == "Javascript";})

	var LyonJS = new Bookmark({
		label : "LyonJS",
		website : "http://lyonjs.org/",
		techno : jstechno
	});

	var ChezMoi = new Bookmark({
		label : "ChezWouam",
		website : "http://www.maison.fr",
		techno : new Techno({ label : "NOTECHNO" })
	});


Mais avant d'en arriver là, il va  falloir aller coder en conséquence côté Play!>.

## Préparation :

### Créer un modèle Play!> : Techno.java

Donc dans `app/models`, créer une classe Java, `Techno.java` :


	package models;

	import javax.persistence.Entity;
	import play.data.validation.Required;
	import play.db.jpa.Model;

	@Entity
	public class Techno extends Model {
	    @Required public String label = "???";

	    public Techno(String label) {
	        this.label = label;
	    }

	    public Techno() {

	    }

	    @Override
	    public String toString() {
	        return label;
	    }
	}


### Créer une relation entre Bookmark.java & Techno.java

Donc dans `app/models`, modifier la classe Java, `Bookmark.java` en ajoutant un membre `techno` de type `Techno` et annoté avec `@ManyToOne` (pour la relation) :


	package models;

	import javax.persistence.Entity;
	import javax.persistence.ManyToOne;
	import play.data.validation.Required;
	import play.db.jpa.Model;

	@Entity
	public class Bookmark extends Model {
	    @Required public String label;
	    @Required public String website;

		//La modif c'est par là

	    /* === Relations ===
	        - un Bookmark est lié à une techno 
	    */
	    @ManyToOne
	    public Techno techno;
	
		//Fin de la modif.

	    public Bookmark(String label, String website) {
	        this.label = label;
	        this.website = website;
	    }

	    public Bookmark() {

	    }	

	    @Override
	    public String toString() {
	        return label;
	    }	
	}


### Modification conf/routes :

Modifions le fichier `conf/routes` : (là même chose que pour le tuto précédent avec les bookmarks)

	#  Technos routes
	GET     /bb/techno		Application.getTechno
	POST	/bb/techno 		Application.postTechno
	PUT 	/bb/techno 		Application.putTechno
	DELETE 	/bb/techno 		Application.deleteTechno

	GET     /bb/technos		Application.allTechnos

### Modifions le contrôleur Application.java :

Dans la classe `app/controllers/Application.java`, ajoutons les méthodes nécessaires pour gérer les opérations de CRUD des technos lorsque Backbone "envoie" des informations : (c'est exactement le même principe que pour le tuto précédent) :


	/*=== dans Application.java ===*/

	/* TECHNOS */
    /* GET */
    public static void getTechno(String model) {
        System.out.println("getTechno : "+model);
        
        Gson gson = new Gson();
        Techno techno = gson.fromJson(model,Techno.class);
        Techno forFetchtechno = Techno.findById(techno.id);
        //tester if found ...
        renderJSON(forFetchtechno);
    }

    /* POST (CREATE) */
    public static void postTechno(String model) {
        System.out.println("postTechno : "+model);

        Gson gson = new Gson();
        Techno techno = gson.fromJson(model,Techno.class);
        techno.save();
        
        renderJSON(techno);
    }

    /* PUT (UPDATE) */
    public static void putTechno(String model) {
        System.out.println("putTechno : "+model);
       
        Gson gson = new Gson();
        Techno techno = gson.fromJson(model,Techno.class);
        Techno updatedTechno = Techno.findById(techno.id);
        updatedTechno.label	= techno.label;
        updatedTechno.save();

        renderJSON(updatedTechno);
    }
    /* DELETE */
    public static void deleteTechno(String model) {
        System.out.println("deleteTechno : "+model);
        
        Gson gson = new Gson();
        Techno techno = gson.fromJson(model,Techno.class);
        Techno technoToBeDeleted = Techno.findById(techno.id);
        //tester if found ...
        technoToBeDeleted.delete();
        
        renderJSON(technoToBeDeleted);
    }
    /* GET */
    public static void allTechnos() {
        System.out.println("allTechnos");
        
        List<Techno> technos = Techno.findAll();
        renderJSON(new Gson().toJson(technos));	
    }


Maintenant, passons aux choses sérieuses :

## Gestion de la relation côté Play!>

Nous allons modifier les méthodes relatives aux bookmarks dans `Application.java`.

Les méthodes suivantes ne changent pas (pour ce qui concerne ce tuto, car je ne traîte pas tous les cas de figure) :

- `public static void getBookmark(String model) // GET-read`
- `public static void deleteBookmark(String model) // DELETE-delete`
- `public static void allBookmarks() // GET`

Seules changent : `postBookmark` et `putBookmark`

Que fait on ?

Lorsque Play!> (en fait le contrôleur) reçoit un bookmark "JSONisé" de Backbone, on vérifie :

- si il a une techno (si il est lié à une techno), 
- et si cette techno a un `id` renseigné
- si cet `id` n'est pas renseigné, on crée/persiste la techno en base : `bookmark.techno.save();`
- dans le cas d'un `update`, avant de faire un `save`, on associe l'instance techno à l'instance bookmark (sinon Hibernate va g.....r au moment du `save()`) : `updatedBookmark.techno = techno;`


		/*=== dans Application.java ===*/

		/* BOOKMARKS */

	    /* POST (CREATE) */
	    public static void postBookmark(String model) {
	        System.out.println("postBookmark : "+model);

	        Gson gson = new Gson();
	        Bookmark bookmark = gson.fromJson(model,Bookmark.class);
	        
	        if(bookmark.techno!=null){
	            Techno techno = bookmark.techno;
	            //si la techno n'existe pas on la crée
	            if(bookmark.techno.id == null) {
	                bookmark.techno.save();
	            }
	        }
	        
	        bookmark.save();
	        
	        renderJSON(bookmark);
	    }

	    /* PUT (UPDATE) */
	    public static void putBookmark(String model) {
	        System.out.println("putBookmark : "+model);
	       
	        Gson gson = new Gson();
	        Bookmark bookmark = gson.fromJson(model,Bookmark.class);

	        Bookmark updatedBookmark = Bookmark.findById(bookmark.id);
	        
	        updatedBookmark.label	= bookmark.label;
	        
	        if(bookmark.techno!=null){
	            Techno techno = bookmark.techno;
	            //si la techno n'existe pas on la crée
	            if(bookmark.techno.id == null) {
	                bookmark.techno.save();
	            }
	            updatedBookmark.techno = techno;
	        }

	        updatedBookmark.save();

	        renderJSON(updatedBookmark);
	    }


## Allons faire un tour chez Backbone

Maintenant que tout est prêt côté serveur, on peut aller s'amuser côté client.

### Ajoutons quelques technos :

Dans la console de votre navigateur préféré :


	t1 = new Techno({label:"Javascript"}).save();
	t2 = new Techno({label:"Coffeescript"}).save();
	t3 = new Techno({label:"Java"}).save();
	t4 = new Techno({label:".Net"}).save();
	t5 = new Techno({label:"Scala"}).save();
	t6 = new Techno({label:"HTML5"}).save();
	t7 = new Techno({label:"CSS3"}).save();
	t8 = new Techno({label:"Kotlin"}).save();
	t9 = new Techno({label:"Ceylon"}).save();
	//Oui je sais, normalement il faut que j'utilise des callbacks, mais on s'en fout, c'est une démo

	
Puis on vérifie que "tout s'est bien passé" :


	technosCollection = new Technos();
	technosCollection.fetch({success: function() {
	        technosCollection.each(function(techno){ console.log(techno.get("id"),techno.get("label")); });
	}});


![Alt "bbplay_2_001.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay_2_001.png)

### Création d'un nouveau bookmark avec une techno existante

Toujours dans la console :


	var jstechno = technosCollection.find(function(techno){ return techno.get("label") == "Javascript";})

	var LyonJS = new Bookmark({
		label : "LyonJS",
		website : "http://lyonjs.org/",
		techno : jstechno
	});
	
	LyonJS.save();


### Création d'un nouveau bookmark avec une nouvelle techno

Toujours dans la console :


	var ChezMoi = new Bookmark({
		label : "ChezWouam",
		website : "http://www.maison.fr",
		techno : new Techno({ label : "NOTECHNO" })
	});
	
	ChezMoi.save();


### Vérifications :

Encore dans la console :


	bookmarks = new Bookmarks();
	bookmarks.fetch({
		success: function() {
			bookmarks.each(function(bookmark) { console.log(bookmark.get("id"), bookmark.get("label")); });
		}
	});


On voit que nos bookmarks ont bien été ajoutés :

![Alt "bbplay_2_002.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay_2_002.png)

Vérifions aussi les technos :


	technosCollection = new Technos();
	technosCollection.fetch({
		success: function() {
	        technosCollection.each(function(techno){ console.log(techno.get("id"),techno.get("label")); });
		}
	});


![Alt "bbplay_2_003.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay_2_003.png)

### Vérification ultime :

On reste dans la console :


	var LyonJS = bookmarks.find(function(bookmark){ return bookmark.get("label") == "LyonJS";});


Puis faites :


	LyonJS.get("techno");


ça c'est bon, donc on continue :


	LyonJS.get("techno").get("label");


Arghhhh ! Et là, c'est le drame (encore) :

Vous obtenez un **"horrible"** `TypeError: Object # <Object> has no method 'get'`

![Alt "bbplay_2_004.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay_2_004.png)

### Mais que s'est-il donc passé ?

En fait, lorsque que vous avez fait un `fetch()` du bookmark, il a bien "récupéré" les infos du serveur, mais n'a pas "casté" la techno du bookmark en `Backbone.Model`, donc votre techno (du bookmark) existe bien, mais est un simple `Object`. Les données sont bien là, vous pouvez vérifier en faisant ceci : `LyonJS.get("techno").label;`

### Mais ça m'arrange pas ! Comment fait-on ?

Je vais vous présenter une méthode "à l'arrache", pas forcément la plus éléguante, mais qui a le mérite d'être simple et donc de vous éviter beaucoup de soucis (d'effets de bord) pour finalement pas beaucoup d'effort.
Nous allons ajouter une méthode `fetchWithTechno` à notre modèle `Bookmark` (nous sommes toujours côté Backbone pour mémoire) :


	window.Bookmark = Backbone.Model.extend({
	    url : 'bb/bookmark',
	    defaults : {
	        id: null,
	        label : "",
	        website : ""
	    },
	    initialize : function Bookmark(){
	        console.log("Hello i'am a bookmark ...");
	        return this;
	    },

	    fetchWithTechno : function (callbck) {
	        this.fetch({success:function(model){
	                if(model.get("techno")){
	                    var techno = new Techno({id:model.get("techno").id});
	                    techno.fetch({
	                        success:function(technoModel){
	                            delete model.techno;
	                            model.set({techno : technoModel});
	                            if(callbck) callbck(model);
	                        }
	                    })
	                } else {
	                    if(callbck) callbck(model);
	                }
	        }});
	    }
	});


### #   Que fait donc `fetchWithTechno()` ?

Cette méthode, fait un fetch du bookmark, vérifie s'il a une techno, et si c'est la cas, fait un fetch de cette techno afin de la "caster" en `Backbone.Model`.

### #   On vérifie ? (penser à raffraîchir la page de votre navigateur)


	//on récupère la liste des bookmarks
	
	var bookmarks = new Bookmarks();
	bookmarks.fetch({
		success: function() {
			bookmarks.each(function(bookmark) { 
				console.log(bookmark.get("id"), bookmark.get("label")); 
			});
		}
	});
	
	//on récupère notre bookmark :
	
	var LyonJS = bookmarks.find(function(bookmark){ return bookmark.get("label") == "LyonJS";});
	
	//on le "fetch" mais avec la nouvelle méthode
	
	LyonJS.fetchWithTechno(function(model){ console.log(model.get("techno").get("label"));})
	//ou
	LyonJS.fetchWithTechno(function(){ console.log(LyonJS.get("techno").get("label"));})


Et là la techno de notre bookmark est bien un `Backbone.Model`. :)
	
### Allez, un dernier pour la route, on fait la même chose pour la collection :


	window.Bookmarks = Backbone.Collection.extend({
	    model : Bookmark,
	    url : 'bb/bookmarks',
	    fetchWithTechnos : function(callbck) {
	        var that = this; // c'est important (on conserve le contexte)
	        this.fetch({
	            success : function() {
	                that.each(function(bookmark){
	                    if(bookmark.get("techno")) {
	                        var techno = new Techno({id : bookmark.get("techno").id}); 
	                        techno.fetch({
	                            success:function(technoModel){
	                                delete bookmark.techno;
	                                bookmark.set({techno : technoModel});
	                                console.log("model with techno : ", bookmark, bookmark.get("techno").get("label"));
	                            } // end success
	                        }); // end fetch techno
	                    } // end if
	                }); // end each
	                if(callbck) callbck(that);
	            } // end success
	        }); //end fetch collection

	    }
	});


### #   Et on se fait une dernière vérification :


	var bookmarks = new Bookmarks();
	bookmarks.fetchWithTechnos(function(){ console.log("Rahhhh ! Lovely ! ça fonctionne ...");})


Et ça marche !

![Alt "bbplay_2_005.png"](https://github.com/k33g/k33g.github.com/raw/master/images/bbplay_2_005.png)

Bon, c'est terminé. Maintenant à vous de bosser ! Il reste plein de choses à faire : par exemple si vous tentez de supprimer une techno qui est attachée à un ou des bookmarks, ça va p***r côté serveur.

**PS:** : Si vous relevez des erreurs, si vous avez quelque chose de plus "élégant" pour le faire, etc. ... Allez-y, je ne me vexerais pas, bien au contraire.

## @+

*... tiens avec Play!> v°2, ça donnerait quoi ? ... ;)*




