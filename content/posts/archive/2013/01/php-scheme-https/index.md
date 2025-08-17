---
title: "Как в PHP узнать протокол (https)"
date: 2013-01-17T16:07:00Z
draft: false
tags: ["archive"]
# filename: "php-scheme-https"
# catigories: ["nginx", "php"]
---

Оказывается, узнать, что сайт использует **SSL** и страница открыта по протоколу **https** — не настолько тривиальная задача, чтобы решить её с наскока.  
Однако, решение оказалось достаточно простое.

Проблема заключается в том, что для определения протокола могут быть использованы переменные:

```php
$_SERVER['HTTPS']
$_SERVER['HTTP_SCHEME']
$_SERVER['HTTP_X_FORWARDED_PROTO']
```

И косвенно:

```php
$_SERVER['SERVER_PORT']
```

Но все эти переменные, кроме номера порта, почти наверняка будут отсутствовать.  
Определять http-схему, основываясь только на номере порта — приемлемое, но не очень гибкое решение.

Я сделал так:

```php
$scheme = isset($_SERVER['HTTP_SCHEME']) ? $_SERVER['HTTP_SCHEME'] : (
    (
        (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off')
        || 443 == $_SERVER['SERVER_PORT']
    ) ? 'https' : 'http'
);
```

И для надёжности, чтобы `$_SERVER['HTTP_SCHEME']` была определена, в `nginx.conf` добавил строчку:

```nginx
# for SSL
fastcgi_param HTTP_SCHEME  $scheme;
```
