---
title: "Баним ботов. Часть 1"
date: 2013-01-20T11:07:00+00:00
draft: false
tags: ["archive"]
# filename: "pma-bot-ban"
# catigories: ["fail2ban", "web", "linux"]
---

В один прекрасный день мне надоело видеть у себя в логах такое вот безобразие:

```
113.204.67.51 - - [19/Jan/2013:07:22:08 +0400] "GET /phpmyadmin/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:12 +0400] "GET /PMA/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:17 +0400] "GET /pma/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:17 +0400] "GET /admin/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:18 +0400] "GET /dbadmin/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:19 +0400] "GET /sql/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:20 +0400] "GET /mysql/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:20 +0400] "GET /myadmin/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:21 +0400] "GET /phpmyadmin2/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:22 +0400] "GET /phpMyAdmin2/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:23 +0400] "GET /phpMyAdmin-2/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:23 +0400] "GET /php-my-admin/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:24 +0400] "GET /sqlmanager/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:25 +0400] "GET /mysqlmanager/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:26 +0400] "GET /p/m/a/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:26 +0400] "GET /php-myadmin/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:27 +0400] "GET /phpmy-admin/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:28 +0400] "GET /webadmin/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:29 +0400] "GET /sqlweb/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:30 +0400] "GET /websql/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:31 +0400] "GET /webdb/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:31 +0400] "GET /mysqladmin/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
113.204.67.51 - - [19/Jan/2013:07:22:32 +0400] "GET /mysql-admin/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
```

и решил я всех этих мерзких ботов забанить.

Для чего был создан fail2ban-скрипт `phpmyadmin.conf` следующего содержания:

> # Fail2Ban configuration file  
> #  
> # Author: Valmat  
> #
> [Definition]
> failregex = ^<host> - - \[.*\] "GET /(phpmyadmin|PMA|pma|admin|dbadmin|sql|mysql|myadmin|phpmyadmin2|phpMyAdmin2|phpMyAdmin-2|php-my-admin|sqlmanager|mysqlmanager|p/m/a|php-myadmin|phpmy-admin|webadmin|sqlweb|websql|webdb|mysqladmin|mysql-admin)/ HTTP/1.1" 404
>
> ignoreregex =

В `/etc/fail2ban/jail.conf` нужно добавить секцию:

> [phpmyadmin]
>
> enabled = true  
> port    = http,https  
> filter  = phpmyadmin  
> logpath = /var/log/nginx/localhost.access.log  
> bantime = 86400  
> maxretry = 1

За основу для построения скрипта был взят список:

```
phpmyadmin
PMA
pma
admin
dbadmin
sql
mysql
myadmin
phpmyadmin2
phpMyAdmin2
phpMyAdmin-2
php-my-admin
sqlmanager
mysqlmanager
p/m/a
php-myadmin
phpmy-admin
webadmin
sqlweb
websql
webdb
mysqladmin
mysql-admin
2phpmyadmin
MyAdmin
admin/db
admin/pMA
admin/phpMyAdmin
admin/phpmyadmin
admin/sqladmin
admin/sysadmin
admin/web
administrator/PMA
administrator/admin
administrator/db
administrator/phpMyAdmin
administrator/phpmyadmin
administrator/pma
administrator/web
database
db
mysql/admin
mysql/db
mysql/dbadmin
mysql/mysqlmanager
mysql/pMA
mysql/pma
mysql/sqlmanager
mysql/web
phpMyAdmin
phpMyadmin
phpmy
phpmyAdmin
phppma
program
sql/myadmin
sql/php-myadmin
sql/phpMyAdmin
sql/phpMyAdmin2
sql/phpmanager
sql/phpmy-admin
sql/phpmyadmin2
sql/sqladmin
sql/sqlweb
sql/webadmin
sql/webdb
sql/websql
PMA2005
pma2005
phpmanager
```

Учитывая логику работы ботов, то что в первую очередь они простукивают каталоги первого уровня, а лишь затем уровнем выше, этот список можно сократить до такого:

```
phpmyadmin
PMA
pma
admin
dbadmin
sql
mysql
myadmin
phpmyadmin2
phpMyAdmin2
phpMyAdmin-2
php-my-admin
sqlmanager
mysqlmanager
p/m/a
php-myadmin
phpmy-admin
webadmin
sqlweb
websql
webdb
mysqladmin
mysql-admin
2phpmyadmin
MyAdmin
PMA2005
administrator
database
db
phpMyAdmin
phpMyadmin
phpmanager
phpmy
phpmyAdmin
phppma
pma2005
program
```

В результате получается приведённый выше конфиг.

Для проверки используем команду:

```
fail2ban-regex '113.204.67.51 - - [19/Jan/2013:07:22:25 +0400] "GET /mysqlmanager/ HTTP/1.1" 404 564 "-" "Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"' '^<host> - - \[.*\] "GET /(phpmyadmin|PMA|pma|admin|dbadmin|sql|mysql|myadmin|phpmyadmin2|phpMyAdmin2|phpMyAdmin-2|php-my-admin|sqlmanager|mysqlmanager|p/m/a|php-myadmin|phpmy-admin|webadmin|sqlweb|websql|webdb|mysqladmin|mysql-admin|2phpmyadmin|MyAdmin|PMA2005|administrator|database|db|phpMyAdmin|phpMyadmin|phpmanager|phpmy|phpmyAdmin|phppma|pma2005|program)/ HTTP/1.1" 404'
```
