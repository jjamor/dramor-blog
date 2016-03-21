---
layout: post
title:  "¡Cifremos la web!"
date: 2016-03-19 13:41:00.000000000 +01:00
categories:
- Boring Stories
- Frikadas
tags:
- letsencrypt
- seguridad
status: publish
type: post
published: true
author:
  login: Juanjo
  email: jjamorNOSPAM@gmail.com
  display_name: Juanjo
  first_name: Juanjo
  last_name: Amor
teaser: Cifra fácilmente tu web, gratis y de forma automática.
show_meta: true
---

## Qué es Let's Encrypt ##

Es bien sabido que conviene cifrar siempre que podamos, y la web
no lo es menos. De hecho, hace tiempo que [Google fomenta el uso de
web cifrada][1] amenazando con penalizar aquellas que no lo estén.

El caso es que, para tener una web cifrada, tenemos dos problemas: por un
lado, comprar un certificado a una entidad certificadora reconocida, y por
otro, renovarlo periódicamente (lo que suele tener un coste también). Desde
hace tiempo, iniciativas como [CaCert][2], intentaron crear una autoridad
certificadora libre de costes para sus usuarios y gestionada por la comunidad,
de la que, pese a ser yo mismo uno de sus notarios, tengo que decir que su éxito
ha sido siempre escaso, entre otras razones porque lleva ya bastantes años
con nosotros y aún no es reconocida por la mayoría de los navegadores.

Por otro lado, la renovación tiene otro problema: hay que estar pendiente
de ello. Para resolver ambos problemas, ha surgido una iniciativa, llamada
[*Let's Encrypt*][3].

![Let's Encrypt][4]

Lo primero que vemos es que la reconocen todos los navegadores. El coste
de conseguir esto debe estar cubierto por la multitud de sponsors que 
tiene el proyecto.

En segundo lugar, utiliza un desafío, llamado *ACME*, para verificar que
la web que queremos cifrar es la dueña del dominio a usar (por ejemplo,
[https://dramor.net/][5]). Con esta verificación, se pueden emitir sin 
problemas, certificados sin coste (al ser generados automáticamente),
siempre que no necesitemos otras características como la validación de
identidad.

Veremos que con este proyecto, se pueden conseguir certificados de sitio
web de forma bastante sencilla. Por ejemplo, veamos cómo se resuelve
para Nginx.

## Implementación en los sitios de DrAmor.net ##

Antes de nada, decir que no voy a dar la configuración completa de nginx,
entendiendo que el lector sabrá de lo que hablo, o podrá ayudarse de los
tutoriales mencionados en este artículo.

En general, lo que veremos nos vale en cualquier Linux o Unix que pueda
ejecutar *git*, *python* y *nginx*. Lo primero que haremos es bajarnos
el repositorio de _Let's Encrypt_:

{% highlight console %}
$ git clone https://github.com/letsencrypt/letsencrypt
{% endhighlight %}

Este repositorio trae _plugins_ para varios servidores web, pero como
Nginx no está aun bien soportado, debemos usar el plugin _webroot_.

Hemos seguido la documentación oficial y el [tutorial de Digital Ocean][6]
para hacernos una idea, aunque los pasos seguidos fueron, en primer
lugar crear un fichero de configuración llamado
/etc/letsencrypt/letsencrypt-dramor.net.ini:

{% highlight ini %}
rsa-key-size = 4096

email = Direccion-email-valida@gmail.com

webroot-map = {"dramor.net,www.dramor.net":"/var/www/dramor.net", "blog.dramor.net,www.blog.dramor.net":"/var/www/dramor_blog", "home.dramor.net":"/var/www/dramor_home"}
{% endhighlight %}

Por supuesto, el e-mail debe ser correcto. Lo oculto con el ánimo de evitar
un poco el spam, claro. Y el _webroot-map_ no es más que un formato _json_
donde especifica los dominios a firmar, junto con la carpeta raíz de cada
sitio, que debe incluir una subcarpeta publicada por nginx, para poder
ejecutar el desafío ACME.

La carpeta a publicar en nginx se debe llamar .well-known. Por ejemplo,
la podemos publicar en los sitios virtuales nginx con:

{% highlight nginx %}
location ~ /.well-known {
    allow all;
}
{% endhighlight %}

Una vez configurado nginx, ya podemos generar los certificados:

{% highlight console %}
$ cd letsencrypt

$ sudo ./letsencrypt-auto certonly -a webroot --renew-by-default --config /etc/letsencrypt/letsencrypt-dramor.net.ini
Checking for new version...
Requesting root privileges to run letsencrypt...
   sudo /home/jjamor/.local/share/letsencrypt/bin/letsencrypt certonly -a webroot --renew-by-default --config /etc/letsencrypt/letsencrypt-dramor.net.ini

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at
   /etc/letsencrypt/live/dramor.net/fullchain.pem. Your cert will
   expire on 2016-06-16. To obtain a new version of the certificate in
   the future, simply run Let's Encrypt again.
 - If you like Let's Encrypt, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
{% endhighlight %}

La primera vez creará un _virtualenv_ de la versión de Python requerida,
y actualizará algunos paquetes. Una vez generados los certificados, se
instalan en: /etc/letsencrypt/live/dramor.net. Si dio algún error, debemos
revisar que esté accesible .well-known en los sitios virtuales de nginx,
y que los DNS del dominio deseado apunten correctamente al servidor web, 
entre otras cosas. Los mensajes de error siempre son lo suficientemente
descriptivos como para no requerir más explicación. Por ejemplo, nos
puede avisar de que algún nombre DNS del dominio a asegurar no resuelve
correctamente el registro A o CNAME, o no apunta a nuestro servidor.

Usar los certificados en Nginx ya es cosa de usar las líneas de configuración
de nginx similares a:

{% highlight nginx %}
ssl_certificate /etc/letsencrypt/live/dramor.net/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/dramor.net/privkey.pem;
{% endhighlight %}

## Renovación automática ##

Los certificados así generados tienen una vigencia de solo tres meses. Pero
renovarlos consiste simplemente en volver a ejecutar el desafío ACME.

Para ello, solo hay que llamar a letsencrypt-auto con otro parámetro:

{% highlight console %}
$ ./letsencrypt-auto renew
{% endhighlight %}

Podemos hacer un script a ejecutar periódicamente (por ejemplo, un _cron_
semanal), que realice esta acción y a continuación ejecute un _reload_
de nginx. De este modo, podemos olvidarnos de las renovaciones: tendrán lugar
cuando hagan falta.

Conviene probar todos los scripts antes de automatizarlo con el _cron_.
Por ejemplo, si nada más generar los certificados intentamos renovarlos:

{% highlight console %}
$ ./letsencrypt-auto renew
Checking for new version...
Requesting root privileges to run letsencrypt...
   sudo /home/jjamor/.local/share/letsencrypt/bin/letsencrypt renew
Processing /etc/letsencrypt/renewal/dramor.net.conf

The following certs are not due for renewal yet:
  /etc/letsencrypt/live/dramor.net/fullchain.pem (skipped)
No renewals were attempted.
{% endhighlight %}

Podemos forzar la renovación para verificar que funciona, con:

{% highlight console %}
$ ./letsencrypt-auto renew --force-renewal
{% endhighlight %}

Por último, indicar que si vamos a hacer muchas pruebas, mejor generemos
los certificados con la opción _staging_, para que que se generen
certificados no válidos. Si hacemos muchas pruebas seguidas, alcanzaremos
fácilmente el límite diario y no podremos generar más hasta el día siguiente.

Si hemos hecho todo correctamente, podremos navegar por el sitio web
con cifrado; y si queremos, podemos comprobar la calidad del mismo aquí:
[SSLLabs][7]. Conseguir una buena puntuación ya es cosa de seguir determinadas
buenas prácticas con el servidor web, que no cubriré aquí.

[1]: https://security.googleblog.com/2014/08/https-as-ranking-signal_6.html

[2]: https://www.cacert.org/

[3]: https://letsencrypt.org/

[4]: {{ site.urlimg }}/articles/letsencrypt.png

[5]: https://dramor.net/

[6]: https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-14-04

[7]: https://www.ssllabs.com/ssltest/analyze.html?d=dramor.net&latest
