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
que, pese a ser yo mismo uno de sus notarios, tengo que decir que su éxito
ha sido siempre escaso, entre otras razones porque lleva ya bastantes años
con nosotros y aún no es reconocida por la mayoría de los navegadores.

Por otro lado, la renovación tiene otro problema: hay que estar pendiente
de ello. Para resolver ambos problemas, ha surgido una iniciativa, llamada
[*Let's Encrypt*][3].

![Let's Encrypt][4]

Lo primero, es que la reconocen todos los navegadores. El coste de conseguir
esto debe estar cubierto por la multitud de sponsors que tiene el proyecto.

En segundo lugar, utiliza un desafío, llamado *ACME*, para verificar que
la web que queremos cifrar es la dueña del dominio a usar (por ejemplo,
[https://dramor.net/][5]). Con esta verificación, se pueden emitir sin 
problemas, certificados sin coste (al ser generados automáticamente),
siempre que no necesitemos otras características como la validación de
identidad.

Veremos que con este proyecto, se pueden conseguir certificados de sitio
web de forma bastante sencilla. Veamos cómo se resuelve para Nginx.

## Implementación en los sitios de DrAmor.net ##

En general, lo siguiente nos vale en cualquier Linux o Unix que pueda
tener *git*, *python* y *nginx*. Lo primero que haremos es bajarnos
el repositorio de _Let's Encrypt_:

```
$ git clone https://github.com/letsencrypt/letsencrypt
```

Este repositorio trae _plugins_ para varios servidores web, pero como
Nginx no está aun bien soportado, debemos usar el plugin _webroot_.

Hemos seguido la documentación oficial y el [tutorial de Digital Ocean][6]
para hacernos una idea, aunque los pasos seguidos fueron, en primer
lugar crear un fichero de configuración llamado
/etc/letsencrypt/letsencrypt-dramor.net.ini:

```
rsa-key-size = 4096

email = Direccion-email-valida@gmail.com

webroot-map = {"dramor.net,www.dramor.net":"/var/www/dramor.net", "blog.dramor.net,www.blog.dramor.net":"/var/www/dramor_blog", "home.dramor.net":"/var/www/dramor_home"}
```

Por supuesto, el e-mail debe ser correcto. Lo oculto con el ánimo de evitar
un poco el spam, claro. Y el _webroot-map_ no es más que un formato _json_
donde especifica los dominios a firmar, junto con la carpeta raíz de cada
sitio, que debe incluir una subcarpeta publicada por nginx, para poder
ejecutar el desafío ACME.

La carpeta a publicar en nginx se debe llamar .well-known. Por ejemplo,
la podemos publicar en los sitios virtuales nginx con:

```
  location ~ /.well-known {
    allow all;
  }
```

Una vez configurado nginx, ya podemos generar los certificados:

```
cd letsencrypt

sudo ./letsencrypt-auto certonly -a webroot --renew-by-default --config /etc/letsencrypt/letsencrypt-dramor.net.ini
```

La primera vez creará un _virtualenv_ de la versión de Python requerida,
y actualizará algunos paquetes. Una vez generados los certificados, se
instalan en: /etc/letsencrypt/live/dramor.net. Si dio algún error, debemos
revisar que esté accesible .well-known en los sitios virtuales de nginx,
entre otras cosas. Los mensajes de error siempre son lo suficientemente
descriptivos como para no requerir más explicación ;-)

Usar los certificados en Nginx ya es cosa de usar las líneas de configuración
de nginx similares a:

```
	ssl_certificate /etc/letsencrypt/live/dramor.net/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/dramor.net/privkey.pem;
```

## Renovación automática ##

Los certificados así generados tienen una vigencia de solo tres meses. Pero
renovarlos consiste simplemente en volver a ejecutar el desafío ACME.

Para ello, solo hay que llamar a letsencrypt-auto con otro parámetro:

```
./letsencrypt-auto renew
```

Podemos hacer un script a ejecutar periódicamente (por ejemplo, una vez
a la semana), que realice esta acción y a continuación ejecute un _reload_
de nginx. De este modo, podemos olvidarnos de las renovaciones: tendrán lugar
cuando hagan falta.

Conviene probar todos los scripts antes de automatizarlo.
Por ejemplo, si nada más generar los certificados intentamos renovarlos:

```
./letsencrypt-auto renew
Checking for new version...
Requesting root privileges to run letsencrypt...
   sudo /home/jjamor/.local/share/letsencrypt/bin/letsencrypt renew
Processing /etc/letsencrypt/renewal/dramor.net.conf

The following certs are not due for renewal yet:
  /etc/letsencrypt/live/dramor.net/fullchain.pem (skipped)
No renewals were attempted.
```

Podemos forzar la renovación para verificar que funciona, con:

```
./letsencrypt-auto renew --force-renewal
```

Por último, indicar que si vamos a hacer muchas pruebas, mejor generemos
los certificados con la opción _staging_, para que que se generen
certificados no válidos. Si hacemos muchas pruebas seguidas, alcanzaremos
fácilmente el límite diario y no podremos generar más.

Si hemos hecho todo correctamente, podremos navegar por el sitio web
con cifrado; y si queremos, podemos comprobar la calidad del mismo aquí:
[SSLLabs][7].

[1]: https://security.googleblog.com/2014/08/https-as-ranking-signal_6.html

[2]: https://www.cacert.org/

[3]: https://letsencrypt.org/

[4]: {{ site.urlimg }}/articles/letsencrypt.png

[5]: https://dramor.net/

[6]: https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-14-04

[7]: https://www.ssllabs.com/ssltest/analyze.html?d=dramor.net&latest
