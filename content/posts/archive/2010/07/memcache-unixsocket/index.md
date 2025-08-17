---
title: "Запуск memcache через unix.socket"
date: 2010-07-24T11:04:00+00:00
draft: false
tags: ["archive"]
# filename: "memcache-unixsocket"
# catigories: ["php", "memcache"]
---

## Запуск memcache через unix.socket

В файл `/etc/memcached.conf` добавляем строчки:
```bash
#-s <file>     unix socket path to listen on (disables network support)
-s /tmp/memcached.socket
#-a <mask>     access mask for unix socket, in octal (default 0700)
-a 0777
```

Последняя нужна, чтобы пользователь, от которого работает веб-сервер (у меня `www-data`), смог прочитать сокет.

Перезапускаем демон мемкеша:

```bash
/etc/init.d/memcached restart
```

Подключаемся к Memcache из PHP-скрипта:

```php
$memcache = new Memcache;
$memcache->connect('unix:///tmp/memcached.socket', 0);
```

Теперь memcache не должен уступать по производительности `tmpfs` или `/dev/shm`.

**Правда, в этом случае перестают работать сессии в memcached.**  
То есть следующая конструкция работать не будет:

```php
$session_save_path = 'localhost:11211';
$session_save_path = 'localhost:11211,unix:///tmp/memcached.socket:0';

ini_set('session.save_handler', 'memcache');
ini_set('session.save_path', $session_save_path);
```

Но для сессий лучше всего всё-таки использовать [tmpfs](http://ufabiz.blogspot.com/2010/07/tmpfs.html).
