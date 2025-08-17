---
title: "Установка сертификатов LetsEncript"
date: 2018-05-20T12:00:00+03:00
draft: false
tags: ["useful"]
---

# Установка сертификатов LetsEncript

Можно установить несколько сертификатов для разных доменов. Если по каким то причинам конфиг Nginx не позволяет вычленить домены то в site-avaible нужно поместить временный конфиг, в котором перечислены домены.
потом его убрать и всё будет работать

Описание установки тут: 
* https://certbot.eff.org/#ubuntuxenial-nginx
* https://certbot.eff.org/docs/using.html#renewal

Установка пакетов:
```bash
apt-get install software-properties-common
add-apt-repository ppa:certbot/certbot
apt-get update
apt-get install certbot python-certbot-nginx
```

Затем можно устанавливать сертификат
Что бы получить список опций certbot набираем certbot --help
```bash
certbot [SUBCOMMAND] [options] [-d DOMAIN] [-d DOMAIN] ...
```

Установка тодлко сертификата без правок конфига:
```bash
certbot --nginx certonly
```

При создании сертификата можно указать домены:
```bash
certbot --nginx certonly  -d avtogs.ru -d www.avtogs.ru -d msk.avtogs.ru
```

Если набрать `certbot --nginx`
То certbot попытается в конец конфига дописать включение сертификата

Проверка обновления:
```bash
certbot renew --dry-run
```

Ручное обновление:
```bash
certbot renew
```
Ручное обновление с перезапуском конфигов:
```bash
certbot -q renew --post-hook "service nginx reload"
certbot renew --pre-hook "service nginx stop" --post-hook "service nginx start"
certbot renew -a nginx --cert-name /etc/letsencrypt/renewal/my-domain.org
```

посмотреть сертификаты
```bash
certbot certificates
```

Проверим полученный сертификат
```bash
openssl x509 -text -in /etc/letsencrypt/live/avtogs.ru/cert.pem
```

После установки можно попдправить Cron скрипт в /etc/cron.d  (  /etc/cron.d/certbot )
```bash
22 */12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(3600))' && certbot -q renew --post-hook "service nginx reload"
```

Что бы сертификаты заработали в конфиг Nginx нужно добваить
```lua
server {
    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/biotrapeza.ru/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/biotrapeza.ru/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ...
}
server {
    listen  80;
    server_name  plazan.ru en.plazan.ru www.plazan.ru;
    return 301 https://$host$request_uri;
}
```
--

См ещё:
https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04


[Источник](https://gist.github.com/valmat/1a1b29459a815cb85ea9dd0e0db9cf6c)