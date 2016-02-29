---

layout: post
title: Créer une application PhoneGap directement sur son smartphone Android
info : Créer une application PhoneGap directement sur son smartphone Android

---

# PhoneGap "Onboard" avec Android.

## Préambule

Peut-on coder directement une application Android sur son smartphone, et tant que l'on y est, peut-on aussi compiler l'apk (toujours sur le smartphone) ? ...

La réponse est **"OUI !"**. Je reconnais que ce n'est pas très pratique (plus confortable sur une tablette). Quels sont les avantages réels ? Je ne sais pas trop (quoique ... pour tester une idée rapido dans le train), en tous les cas c'est très geek. Voyons donc comment faire.

Nous allons faire une application hybride avec PhoneGap (on peut très bien faire une "pure" application native, mais je voulais vérifier que mon idée fonctionnait de bout en bout).

## Pré-Requis

Vous aurez besoin de 

- **AIDE** [https://play.google.com/store/apps/details?id=com.aide.ui](https://play.google.com/store/apps/details?id=com.aide.ui) qui est un mini IDE "Onboard" qui permet d'éditer un projet Android et de le compiler, qui sai se connecter à un repository GIT et à un compte Dropbox. Il existe une version payante et une version free (j'ai la payante, mais normalement cela devrait fonctionner avec la free).
- l'**Android SDK**, théoriquement, nous pourrions tout faire avec **AIDE**, vous n'avez pas besoin d'installer Eclipse et le plugin Android, juste le SDK (Pensez à mettre à jour vos variables d'environnement `%ANDROID_HOME%\tools;%ANDROID_HOME%\platforme-tools;`, où `ANDROID_HOME` est le chemin vers le répertoire d'installation du SDK).
- le framework **PhoneGap** qui permet de développer facilement des applications hybrides [http://phonegap.com/download](http://phonegap.com/download), downloadez, dézippez, nous y reviendrons plus tard.
- un compte **Dropbox** (il y a une version gratuite) [http://www.dropbox.com](http://www.dropbox.com)

Si vous n'avez pas de compte Dropbox, et que vous ne souhaitez pas en avoir, vous pouvez facilement adapter ce tuto et utiliser un cable USB pour transférer vos fichiers vers votre smartphone.

## Création du squelette de projet Android

- Allez dans votre répertoire Dropbox
- Positionnez vous où vous voulez (à la racine de Dropbox ou dans un sous répertoire)
- Tapez la commande : `android create project --target 1 --name demophonegap --path demophonegap --activity DemoPhoneGap --package org.k33g.demophonegap` (à adapter selon vos besoins, `--target` : la cible de compilation, 1 = par défaut, `--name` : nom du projet, `--path` : répertoire du projet, `--activity` : la classe principale de votre projet, `--package` : le package/domaine de votre projet )

>Remarque : j'ai créé le projet sur mon desktop, mais **AIDE** peut très bien le faire directement sur votre smartphone.

Maintenant, vous disposez d'un répertoire projet android que nous allons "préparer" pour qu'il fonctione avec **PhoneGap**.

## "Hybridons" notre projet Android

- Dans le répertoire `libs` de votre projet android, copiez la librairie `cordova-2.0.0.jar` que vous trouvez dans le répertoire `\lib\android` du framework **PhoneGap**.
- Dans le répertoire de votre projet android, créez un sous-répertoire `assets\www` dans lequel vous copierez la librairie javascript `cordova-2.0.0.js` que vous trouvez dans le répertoire `\lib\android` du framework **PhoneGap**.
- Copiez le répertoire `xml` que vous trouvez dans le répertoire `\lib\android` du framework **PhoneGap** dans le répertoire `res` de votre projet android

## Modifions DemoPhoneGap.java

Ouvrez avec votre éditeur de texte préféré `DemoPhoneGap.java` (plus tard vous pourrez le faire directement sur votre smartphone), vous devez avoir le code suivant :

	package org.k33g.demophonegap;

	import android.app.Activity;
	import android.os.Bundle;

	public class DemoPhoneGap extends Activity
	{
	    /** Called when the activity is first created. */
	    @Override
	    public void onCreate(Bundle savedInstanceState)
	    {
	        super.onCreate(savedInstanceState);
	        setContentView(R.layout.main);
	    }
	}

... que vous allez modifier de la façon suivante :

	package org.k33g.demophonegap;

	import android.app.Activity;
	import android.os.Bundle;
	import org.apache.cordova.*;

	public class DemoPhoneGap extends DroidGap
	{
	    /** Called when the activity is first created. */
	    @Override
	    public void onCreate(Bundle savedInstanceState)
	    {
	        super.onCreate(savedInstanceState);
	        super.loadUrl("file:///android_asset/www/index.html");
	    }
	}

... sauvegardez

Donc : 

- nous avons ajouté la référence à `import org.apache.cordova.*;`
- `DemoPhoneGap` hérite maintenant de `DroidGap` et non plus de `Activity`
- nous avons supprimé `setContentView(R.layout.main);` pour le remplacer par `super.loadUrl("file:///android_asset/www/index.html");`, ce qui signifie qu'au chargement de l'application, la page `index.html` sera chargée dans une UIWebview

## Modifions AndroidManifest.xml

Ouvrez `AndroidManifest.xml` qui est à la racine de votre projet android, et qui doit ressembler à ceci :

	<?xml version="1.0" encoding="utf-8"?>
	<manifest xmlns:android="http://schemas.android.com/apk/res/android"
	      package="org.k33g.demophonegap"
	      android:versionCode="1"
	      android:versionName="1.0">
	    <application android:label="@string/app_name" android:icon="@drawable/ic_launcher">
	        <activity android:name="DemoPhoneGap"
	                  android:label="@string/app_name">
	            <intent-filter>
	                <action android:name="android.intent.action.MAIN" />
	                <category android:name="android.intent.category.LAUNCHER" />
	            </intent-filter>
	        </activity>
	    </application>
	</manifest>


Juste avant le tag `<application>`, insérez ceci :

        <supports-screens 
            android:largeScreens="true" 
            android:normalScreens="true" 
            android:smallScreens="true" 
            android:resizeable="true" 
            android:anyDensity="true" />
        <uses-permission android:name="android.permission.VIBRATE" />
        <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
        <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
        <uses-permission android:name="android.permission.ACCESS_LOCATION_EXTRA_COMMANDS" />
        <uses-permission android:name="android.permission.READ_PHONE_STATE" />
        <uses-permission android:name="android.permission.INTERNET" />
        <uses-permission android:name="android.permission.RECEIVE_SMS" />
        <uses-permission android:name="android.permission.RECORD_AUDIO" />
        <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
        <uses-permission android:name="android.permission.READ_CONTACTS" />
        <uses-permission android:name="android.permission.WRITE_CONTACTS" />
        <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
        <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" /> 
        <uses-permission android:name="android.permission.GET_ACCOUNTS" />
        <uses-permission android:name="android.permission.BROADCAST_STICKY" />

Et pour le support des changements d'orientation, copiez ceci `android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale"` dans le tag `activity`.
Au final votre fichier devrait ressembler à ceci :

	<?xml version="1.0" encoding="utf-8"?>
	<manifest xmlns:android="http://schemas.android.com/apk/res/android"
	      package="org.k33g.demophonegap"
	      android:versionCode="1"
	      android:versionName="1.0">

	        <supports-screens 
	            android:largeScreens="true" 
	            android:normalScreens="true" 
	            android:smallScreens="true" 
	            android:resizeable="true" 
	            android:anyDensity="true" />
	        <uses-permission android:name="android.permission.VIBRATE" />
	        <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
	        <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
	        <uses-permission android:name="android.permission.ACCESS_LOCATION_EXTRA_COMMANDS" />
	        <uses-permission android:name="android.permission.READ_PHONE_STATE" />
	        <uses-permission android:name="android.permission.INTERNET" />
	        <uses-permission android:name="android.permission.RECEIVE_SMS" />
	        <uses-permission android:name="android.permission.RECORD_AUDIO" />
	        <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
	        <uses-permission android:name="android.permission.READ_CONTACTS" />
	        <uses-permission android:name="android.permission.WRITE_CONTACTS" />
	        <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
	        <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" /> 
	        <uses-permission android:name="android.permission.GET_ACCOUNTS" />
	        <uses-permission android:name="android.permission.BROADCAST_STICKY" />

	    <application android:label="@string/app_name" android:icon="@drawable/ic_launcher">
	        <activity android:name="DemoPhoneGap"
	                  android:label="@string/app_name"
	                  android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale">
	            <intent-filter>
	                <action android:name="android.intent.action.MAIN" />
	                <category android:name="android.intent.category.LAUNCHER" />
	            </intent-filter>
	        </activity>
	    </application>
	</manifest>

## Passons à la création de la partie "applicative" en html

Dans le répertoire `assets\www`, créez un fichier `index.html` avec le code suivant :

	<!DOCTYPE HTML>
	<html>
		<head>
		    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimum-scale=1.0, maximum-scale=1.0">		
			<title>DEMO</title>
			<script type="text/javascript" charset="utf-8" src="cordova-2.0.0.js"></script>
		</head>
		<body>
			<h1>PhoneGapDemo</h1>
			<p id="infos"></p>

		</body>
		<script>

			document.addEventListener("deviceready", onDeviceReady, false);
			function onDeviceReady() {
				document.querySelector("# infos").innerHTML = [
					device.name,
					device.cordova,
					device.platform,
					device.uuid,
					device.version
				].join("<br>");
			}

		</script>
	</html>

## Prenez votre smartphone

- Lancez AIDE, à la demande de création d'un nouveau projet, faites `Cancel`

![Alt "aide_001.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_001.jpg)

- Sélectionnez "Download Dropbox Folder here ..."

![Alt "aide_002.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_002.jpg)

- Sélectionnez le répertoire `demophonegap`

![Alt "aide_003.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_003.jpg)

- Vous obtenez le contenu du répertoire `demophonegap`, Sélectionnez `Download`

![Alt "aide_004.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_004.jpg)

- Patientez pendant la synchronisation ...

![Alt "aide_005.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_005.jpg)

- Une fois la synchronisation terminée, un nouveau répertoire projet android `demophonegap` est créé sur votre smartphone

![Alt "aide_006.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_006.jpg)

- Vous pouvez même aller vérifier que vous avez bien télécharger le bon code

![Alt "aide_007.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_007.jpg)

- Allez dans le menu et sélectionnez `Run`

![Alt "aide_008.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_008.jpg)

- Vous êtes maintenant en train de compiler une vraie application android directement sur votre smartphone !!!

![Alt "aide_009.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_009.jpg)

- Une fois la compilation terminée, AIDE vous propose d'installer votre nouvelle application

![Alt "aide_010.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_010.jpg)

- C'est compilé, vous pouvez lancer votre application

![Alt "aide_011.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_011.jpg)

- Résultat :

![Alt "aide_012.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_012.jpg)

## Maintenant ...

Vous pouvez modifier directement votre application sur le smartphone et la compiler, tout cela sans repasser par votre desktop.
Dans notre exemple, c'est même relativement facile, puisque l'essentiel du code à modifier est du HTML et du javascript.

Petit conseil pour la route, si vraiment cela vous tente de code "onboard", pour la partie HTML/JS, je préfère utiliser un éditeur externe : **DroidEdit** [https://play.google.com/store/search?q=droidedit&c=apps](https://play.google.com/store/search?q=droidedit&c=apps), voyez vous même :

![Alt "aide_013.jpg"](https://github.com/k33g/k33g.github.com/raw/master/images/aide_013.jpg)

## Conclusion ?

Geekerie ? Oui, certainement, mais pratique tout de même, si vous voulez tester/vérifier quelque chose d'urgence sans ordinateur sous la main (genre, durant un trop long repas de (belle)famille ;) ).

Si vous connaissez d'autres outils de ce genre, j'en suis friand :)
