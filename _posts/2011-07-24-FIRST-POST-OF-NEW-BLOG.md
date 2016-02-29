---

layout: post
title: Parce que c'est plus Geek ...
info : Fin des vacances, j'en profite pour refaire mon blog

---

#  Parce que c'est plus Geek ...

Voilà, c'est fait, mon blog change de plateforme et passe chez [GitHub](https://github.com/), ... parce que c'est plus "Geek", mais aussi parce que je trouve cela plus pratique : je peux saisir l'ensemble de mes billets en [markdown](https://github.com/3monkeys/play.rules), les gérer en conf (via Git & GitHub), un "commit, et hop ! c'est publié.

Le tout est propulsé par [Jekyll](https://github.com/mojombo/jekyll/wiki) qui lui aussi est utilisé par GitHub, ce qui vous permet de créer un blog facilement pour chacun de vos repository GitHub (vous pouvez aussi l'installer chez vous en mode stand-alone).

Certes ce n'est pas Wordpress, Drupal ou autres plateformes de blog, mais c'est très très pratique, facile à utiliser, et finalement, je vais pouvoir passer plus de temps "fignoler" mes articles, plutôt que d'en perdre à administrer mon site (enfin j'espère).

**Le petit truc sympa & bien geek : vous pouvez forker le blog et faire des pullrequests pour proposer des amélioration et des corrections (du contenu et du code). ;)**

Pour la gestion d'un blog technique c'est top, ne serait ce que l'affichage de codes source :

       //à la zepto
        z = function(selector) {
            return {
                elements : [].slice.apply(document.querySelectorAll(selector)),
                html : z.html, attr : z.attr
            }
        };
        z.html = function(html_code) {
            if(html_code) {
                this.elements.forEach(function(el) { el.innerHTML = html_code; });
                return this;
            } else { return this.elements[0].innerHTML; }
        };
        z.attr = function(attr_name, value) {
            if(attr_name && value) {
                this.elements.forEach(function(el) { el.setAttribute(attr_name, value); });
                return this;
            } else { return this.elements[0].getAttribute(attr_name); }
        };

        z("a").html("haked").attr("href","http://www.k33g.org");

        //ce bout de code donnera lieu à un article


En ce qui concerne les commentaires, j'utilise la plateforme "sociale" [Disqus](http://disqus.com/welcome/).

Voilà, j'espère que cette nouvelle version vous plaira. Un grand merci à [@mklabs](http://twitter.com/mklabs/) pour m'avoir fait découvrir Jekill & Disqus.

## Un peu de teasing

###  à venir ... pas forcément dans l'ordre

- un tuto sur *"comment créer un blog Jekyll chez/sur GitHub"*
- la suite du tuto BackBone : *"le même mais en plus propre"*
- un autre tuto BackBone : *"aller + loin avec"*
- bientôt un nouveau chapitre Play! pour [Play.Rules (by 3Monkeys)](https://github.com/3monkeys/play.rules)
- utiliser [zepto.js](http://zeptojs.com/) et faire son propre zepto

Stay tuned ...

*L'ancien Blog est toujours consultable pour le moment : [www.k33g.org](http://www.k33g.org), k33g.org restera, mais sous une autre forme.*