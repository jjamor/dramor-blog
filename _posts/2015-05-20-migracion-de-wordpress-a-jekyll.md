---
layout: post
title:  "Migración de Wordpress a Jekyll"
categories:
- Frikadas
- Boring Stories
tags:
- jekyll
- wordpress
- blog responsive
- github
status: publish
type: post
published: true
author:
  login: Juanjo
  email: jjamorNOSPAM@gmail.com
  display_name: Juanjo
  first_name: Juanjo
  last_name: Amor
teaser: Migración a Jekyll del blog y publicación de todas las fuentes en Github
show_meta: true
---

Continuando con el trabajo comenzado con [mi página][1], y buscando como [objetivo hacerla *responsive* y compatible con móviles][2], procedí a realizar un trabajo de migración de Wordpress a Jekyll. Las razones para movernos a Jekyll están [bien justificadas aquí][3].

Jekyll es un sistema de blogs con páginas estáticas muy sencillos. Para empezar, no necesita *cookies* para nada, por lo que me olvido de estas [extrañas normas europeas][4].

![Antiguo Wordpress]({{ site.urlimg }}/articles/viejowp.jpg)

Un poco más en serio, el mantenimiento se simplifica enormemente. Me olvido de *plugins*, *versiones de PHP* (y sus problemas de seguridad). Y encima la página queda mucho mejor, y se puede alojar en cualquier proveedor de hosting, sin importarme si soporta o no PHP, cargando mucho más rápido. Como inconvenientes, no es tan fácil de usar para un *blogger* medio. Pero no me importa: a mí me basta.

Aunque en la [página de información][3] está descrita la tecnología usada, incluyo a continuación un resumen del proceso seguido:

- Creamos entorno Jekyll con el diseño [Feeling Responsive de Phlow][5] y lo adaptamos para nuestras necesidades. Para ello hemos hecho un [fork en github][6].
- Obtenemos de los blogs en Wordpress (y también, ya puestos, de Blogger) los ficheros XML de exportación completos.
- La importación de los ficheros anteriores las realizamos según estos consejos ([para wordpress][7], [para blogger][8]).
- Seguimos estos mismos consejos para [importar comentarios a Disqus][7].
- En los posts resultantes, usamos un pequeño script de *sed* para cambiar las URL de imágenes de artículos, ya que los moveremos a otro sitio.
- Por último, incluimos información que antes no existía (como la información para SEO), en algunos posts (sería mucho trabajo revisarlos todos ahora...).

Al final, casi con seguridad miraré de publicar el blog directamente en Github en lugar de usar un hosting propio, pero por ahora lo dejo aquí. Que ha llegado el séptimo día y hay que descansar :-)

Algunas de las modificaciones realizadas las propondré subir al repositorio original, pero por ahora si te interesan, [haz un fork de mi trabajo][6], que para eso está :-)

Para trabajar con Jekyll en múltiples sitios, me ha resultado bastante cómodo preparar un docker, así que si alguien lo quiere utilizar, [se encuentra aquí publicado][9] (y su [repositorio, aquí][10]).

[1]: http://dramor.net/
[2]: {{ site.url }}/2015/04/lavado-de-cara-a-la-web-del-dr-amor/
[3]: {{ site.url }}/info/
[4]: http://ec.europa.eu/ipg/basics/legal/cookies/index_en.htm
[5]: https://phlow.github.io/feeling-responsive/
[6]: http://github.com/jjamor/dramor-blog
[7]: http://blog.8thcolor.com/en/2014/05/migrate-from-wordpress/
[8]: http://import.jekyllrb.com/docs/blogger/
[9]: https://registry.hub.docker.com/u/jjamor/jekyll-env/
[10]: https://github.com/jjamor/jekyll-env

