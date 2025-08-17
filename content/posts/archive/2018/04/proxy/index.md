---
title: "Proxy для Telegram"
date: 2018-04-14T12:00:00+03:00
draft: false
tags: ["useful"]
---

# В связи с попытками блокировок Telegram

Проверено на  5 баксовом тарифе DigitalOcean

----
1) 
Создаём proxy пользователя для аутентификации по паролю:

```
useradd -d /dev/null teleg
passwd teleg
```
----
2) 

Сразу же закрываем этому пользователю вход по SSH:
(ещё лучше всегда менять ssh порт с дефолтного на кастомный)

`nano /etc/ssh/sshd_config`

```bash
#Port 22
Port 4251

Match User teleg
PasswordAuthentication no
Match all
```
Рестартим ssh:

```
/etc/init.d/ssh restart
```

Проверяем:
```
ssh -p4251 teleg@<ip>
```

Должно быть
```
Permission denied (publickey).
```
----
3) 

В репах Убунту старый и глючный `dante-server`
Поэтому берём свежий пакет

```bash
cd /tmp
wget http://ppa.launchpad.net/dajhorn/dante/ubuntu/pool/main/d/dante/dante-server_1.4.1-1_amd64.deb
dpkg -i dante-server_1.4.1-1_amd64.deb
rm dante-server_1.4.1-1_amd64.deb
```
Редактируем настройки Данте-сервера:

```
cp /etc/danted.conf  /etc/danted~.conf
nano /etc/danted.conf
```
Конфиг:
```bash
logoutput: syslog /var/log/danted.log
user.privileged: root
user.unprivileged: teleg

# The listening network interface or address.
internal: 0.0.0.0 port=1180

# The proxying network interface or address.
external: eth0

# socks-rules determine what is proxied through the external interface.
# The default of "none" permits anonymous access.
socksmethod: username

# client-rules determine who can connect to the internal interface.
# The default of "none" permits anonymous access.
clientmethod: none

client pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: connect disconnect error
}

socks pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: connect disconnect error
}
```

Здесь 
`user.unprivileged: teleg` -- имя пользователя, которого мы создали выше
`port=1180` мржете указать сами. Номер должен быть больше 1000

Сетевой интерфейс:
`external: eth0`
Имя сетевого интерфейса может отличаться. Обычно eth0
Что бы посмотреть имя используемого сетевого интерфейса нужно набрать
```bash
ifconfig
```

Перезапускаем dante-server:
```bash
/etc/init.d/danted stop
/etc/init.d/danted start
```
Проверяем работает ли proxy:
```bash
curl -v -x socks5://teleg:<psw>@<ip>:<port> http://ya.ru/
```
<psw>,<ip> и <port> нужно указать свои

Если всё нормально, то Ok
Ссылка для включения прокси в телеграме:
```bash
https://t.me/socks?server=<ip>&port=<port>&user=teleg&pass=<psw>
```

Если что-то пошло не так, то смотрим логи:
```bash
cat /var/log/danted.log
```
----
Инструкцию эту собрал сам из разных источников. Лично мной проверена.

[Источник](https://gist.github.com/valmat/9b49ad02dac3941e47c442221ce852bb)
