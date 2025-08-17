---
title: "tmpfs: Операции с файловой системой в виртуальной памяти"
date: 2010-07-24T11:08:00Z
draft: false
tags: ["archive"]
# filename: "tmpfs"
# catigories: []
---

# tmpfs: Операции с файловой системой в виртуальной памяти

Для примонтирования при старте вносим в `/etc/fstab`:

```bash
tmpfs /tmp tmpfs size=500M,nr_inodes=1m,nosuid 0 0
tmpfs /var/lib/php5 tmpfs size=200M,nr_inodes=1m,nosuid 0 0
```

Первая строчка размещает в памяти `/tmp`, вторая — папку хранения сессий.

---

Для создания папки для сессий без рестарта системы нужно выполнить следующую последовательность команд в терминале:

```bash
mkdir /tmp/ses
/etc/init.d/nginx stop
mv /var/lib/php5/* /tmp/ses
mount tmpfs /var/lib/php5 -t tmpfs -o size=200M,nr_inodes=1m,nosuid
mv /tmp/ses/* /var/lib/php5
/etc/init.d/nginx start
rm -r /tmp/ses
```

> Предварительно лучше отредактировать `fstab`.

---

Вот более сложный вариант, когда данные сессий хранятся в `/tmp`:

```bash
mkdir /dev/shm/ses
/etc/init.d/nginx stop
/etc/init.d/php5-spawn stop
/etc/init.d/mysql stop
mv /tmp/* /dev/shm/ses
mount tmpfs /tmp -t tmpfs -o size=1g,nr_inodes=1m,nosuid
mount tmpfs /var/lib/php5 -t tmpfs -o size=200M,nr_inodes=1m,nosuid
mv /dev/shm/ses/* /tmp
/etc/init.d/mysql start
/etc/init.d/php5-spawn start
/etc/init.d/nginx start
rm -r /dev/shm/ses
du -hsx /tmp
```
