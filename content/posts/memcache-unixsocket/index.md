---
title: "Запуск memcache через unix.socket"
date: 2010-07-24T04:04:00-07:00
draft: true
tags = ["rust", "linux", "cat"]
---

Запуск memcache через unix.socket
В файл `/etc/memcached.conf` добавляем строчки

```
#-s unix socket path to listen on (disables network support)
-s /tmp/memcached.socket
#-a access mask for unix socket, in octal (default 0700)
-a 0777
```

Последняя нужна, что бы пользователь от которого работает вебсервер (у меня www-data) смог прочитать сокет
Перезапускае деамон мемкеша /etc/init.d/memcached restart

Подключаемся к Memcache из php скрипта:
```php
$memcache = new Memcache;
$memcache->connect('unix:///tmp/memcached.socket',0);
```

Все теперь memcache не должен уступать по производительности tmpfs или /dev/shm

Правда в этом случае перестают работать сессии в мемкешед. Т.е. следующая конструкцияр работать не будет:
```php
$session_save_path = 'localhost:11211';
$session_save_path = 'localhost:11211,unix:///tmp/memcached.socket:0';

ini_set('session.save_handler', 'memcache');
ini_set('session.save_path', $session_save_path);
```

Но для сессиий лучше всего все таки tmpfs
