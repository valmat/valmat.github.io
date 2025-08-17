---
title: "Баним ботов. Часть 2"
date: 2013-01-23T14:21:00Z
draft: false
tags: ["archive"]
# tags: ["archive", "nginx", "400", "web", "Google Chrome"]
# filename: "ban-bot-2"
# catigories: ["nginx", "400", "web", "Google Chrome"]
---

Небольшой анализ логов сервера. Какие странные сущности обитают в Интернете. И как с ними бороться.

### Открытые подключения

В логах nginx'а обнаружил десятки тысяч записей вида:

```
1.1.1.1 - - [19/Jan/2013:07:19:23 +0400] "-" 400 0 "-" "-"
1.1.1.1 - - [19/Jan/2013:07:19:23 +0400] "-" 400 0 "-" "-"
1.1.1.1 - - [19/Jan/2013:07:19:23 +0400] "-" 400 0 "-" "-"
1.1.1.1 - - [19/Jan/2013:07:19:34 +0400] "-" 400 0 "-" "-"
1.1.1.1 - - [19/Jan/2013:07:19:34 +0400] "-" 400 0 "-" "-"
1.1.1.1 - - [19/Jan/2013:07:19:34 +0400] "-" 400 0 "-" "-"
1.1.1.1 - - [19/Jan/2013:07:19:34 +0400] "-" 400 0 "-" "-"
```

Судя по количеству и частоте запросов, достаточно большое число таких запросов сделано именно ботами.

Казалось бы, легко создать правило для fail2ban и забанить их всех.

Но такие записи могут создавать и обычные пользователи. Например, если пользователь остановит загрузку или при быстром переходе со страницы на страницу (у меня получилось [отловить такой эффект в Google Chrome](http://www.valmat.ru/2013/01/-400-0-.html)).

Суть таких записей такова: открытое и не закрытое соединение.

Например, если открыть соединение telnet'ом и оставить его, то по истечении таймаута появится именно такая запись.

**```$ telnet site.ru 80```**

```
Trying 127.0.0.1...
Connected to site.ru.
Escape character is '^]'.
```

Или можно так:

```php
php -r 'for($i=0;$i>500;$i++){$v="s".$i;$$v=socket_create(AF_INET,SOCK_STREAM,SOL_TCP);socket_connect($$v,"localhost", 80);}'
```

Особого вреда такие атаки нанести не могут, т.к. в силу своего асинхронного характера nginx может держать [достаточно](http://forum.nginx.org/read.php?21,129983,129986#msg-129986) [большое](http://nginx.org/ru/docs/ngx_core_module.html#worker_connections) число открытых соединений. Но специально для таких случаев (а также других недоатак) существуют такие вещи, как модули [ngx_http_limit_req_module](http://nginx.org/ru/docs/http/ngx_http_limit_req_module.html) и [ngx_http_limit_conn_module](http://nginx.org/ru/docs/http/ngx_http_limit_conn_module.html).

Про них написано достаточно много, простым гуглением все находится.

Можно только добавить — не забыть вставить в robots.txt строчку вроде этой:

```
Crawl-delay: 1
```

(можно дробные значения), чтобы ненароком не забанить поисковых роботов.

`limit_req_zone` должна обязательно стоять (в секции http) до подключения секций server, т.е. до

```
include /etc/nginx/conf.d/*.conf;
```

Еще некоторых ленивых роботов, передающих не все заголовки, можно развернуть вот таким кодом в секции server:

```nginx
if ( $http_user_agent = "" ){
    return 444;
}
```

### try proxy

Следующая разновидность ботов пытается использовать nginx в качестве открытого прокси-сервера. Точнее, пытается определить такую возможность.

Дело в том, что если, например, telnet'ом передать заголовок не

```
GET /index.htm HTTP/1.1
```

а

```
GET http://site.ru/index.htm
```

то nginx не разворачивает такой запрос с кодом 400, а обрабатывает его.

И дальше все зависит от настройки конфигов.

В некоторых случаях, таким образом можно получить [открытый http-прокси сервер](http://forum.nginx.org/read.php?21,226769,227097#msg-227097).

В общем случае, если site.ru определён в nginx как

```
server_name site.ru;
```

то дальше вашего сервера запрос не уйдет.

Вот реальный пример из log-файла:

```
178.77.67.27 - - [20/Jan/2013:19:09:43 +0400] "GET http://www.scanproxy.net:80/p-80.html HTTP/1.0" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; KuKu 0.65)"
82.145.35.123 - - [10/Jan/2013:08:11:20 +0400] "GET http://proxyjudge2.proxyfire.net/fastenv HTTP/1.1" 404 564 "-" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"
80.82.215.45 - - [01/Jan/2013:08:59:03 +0400] "GET http://www.scanproxy.net:80/p-80.html HTTP/1.0" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; KuKu 0.65)"
62.193.243.32 - - [01/Jan/2013:23:38:53 +0400] "GET http://www.scanproxy.net:80/p-80.html HTTP/1.0" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; KuKu 0.65)"
46.32.65.23 - - [11/Dec/2012:19:20:15 +0400] "GET http://www.santeh.ru/cgi-bin/textenv.pl HTTP/1.0" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 4.0)"
```

В основном, лечится это так: запретить использование дефолтного сервера и обработку запросов [без имени сервера](http://nginx.org/ru/docs/http/request_processing.html#how_to_prevent_undefined_server_names).

```
server {
    listen      80 default_server;
    server_name "";
    return      444;
}
```

Далее, при передаче заголовка (без HTTP/1.1 или HTTP/1.0):

```
GET http://site.ru/index.htm
```

Все остальные строки запроса будут проигнорированы.

Т.е. в запросе (вместо `GET /index.htm HTTP/1.1` написано `GET http://site.ru/index.htm`):

```
GET http://site.ru/index.htm
Accept:text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Charset:windows-1251,utf-8;q=0.7,*;q=0.3
Accept-Language:ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4
Cache-Control:max-age=0
Connection:keep-alive
Host:site.ru
Referer:site.ru/index.htm
User-Agent:TelnetTester
```

Будет учтена только первая строка. А значит, поможет уже знакомая нам конструкция:

```nginx
if ( $http_user_agent = "" ){
    return 444;
}
```

Но такая ситуация встречается не часто.

Кроме ботов, запросы вида `GET http://site.ru/index.htm HTTP/1.1` шлет Opera. Во всяком случае, у меня в логах достаточно много строк вроде этой:

```
188.162.15.86 - - [05/Jan/2013:09:18:41 +0400] "GET http://opera10beta-turbo.opera-mini.net:80//img/spb_b_1456.jpg HTTP/1.1" 404 162 "http://images.yandex.ru/yandsearch?p=..." "Opera/9.80 (Windows NT 5.1) Presto/2.12.388 Version/12.10"
```

#### Битые заголовки

```
94.41.37.135 - - [11/Jan/2013:08:51:57 +0400] "ЪьЪЮ\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00ЪЧ\x00;CREATOR: gd-jpeg v1.0 (using IJG JPEG v62), quality = 75" 400 166 "-" "-"
176.213.180.115 - - [07/Jan/2013:16:27:16 +0400] "ЪьЪЮ\x00\x10JFIF\x00\x01\x01\x01\x00`\x00`\x00\x00Ъш\x00C\x00\x02\x01\x01\x02\x01\x01\x02\x02\x02\x02\x02\x02\x02\x02\x03\x05\x03\x03\x03\x03\x03\x06\x04\x04\x03\x05\x07\x06\x07\x07\x07\x06\x07\x07\x08\x09\x0B\x09\x08\x08" 400 166 "-" "-"
```

Такие строки создают некоторые браузеры. Как это происходит — я так и не понял. Но нечто подобное я нашел в логах на локальной машине — там, где никаких ботов быть не может. Предположительно, Google Chrome.

Также весьма вероятно, подобные записи могут создаваться некоторыми ботами, ищущими уязвимости веб-сервера.

Вот, например, [http://disorder.ru/archives/908](http://disorder.ru/archives/908) — человек описал эксплоит для старых версий Nginx, а вот это:

```
188.138.88.171 - - [19/Jan/2013:20:05:45 +0400] "GET /w00tw00t.at.ISC.SANS.DFind:) HTTP/1.1" 400 166 "-" "-"

50.63.136.60 - - [19/Jan/2013:20:32:27 +0400] "GET /w00tw00t.at.ISC.SANS.Win32:) HTTP/1.1" 400 166 "-" "-"
```

явно адресовано IIS.

Такие записи просто можно игнорировать. В случае особой настойчивости помогает способ с `ngx_http_limit_req_module`, описанный в предыдущем пункте.

