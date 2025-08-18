---
title: "Установка Redis via unix.socket"
date: 2011-12-03T07:05:00+00:00
draft: false
tags: ["archive"]
# tags: ["archive", "redis", "linux"]
# filename: "redis-via-unixsocket"
# catigories: ["redis", "linux"]
---

## О том, как установить Redis в качестве сервера на Linux и обращаться к нему через Unix.socket

По мотивам куцей доки: [http://redis.io/topics/quickstart](http://redis.io/topics/quickstart) и [http://redis.io/download](http://redis.io/download)

От рута делаем:

```bash
mkdir /usr/src/redis
cd /usr/src/redis
```

```bash
wget http://redis.googlecode.com/files/redis-2.4.4.tar.gz
tar xzf redis-2.4.4.tar.gz
cd redis-2.4.4
make && make test
```

Если тесты прошли нормально (должно быть написано что-то вроде этого: "\o/ All tests passed without errors!"), то двигаемся дальше.

```bash
mv ../redis-2.4.4.tar.gz ./redis-2.4.4.tar.gz
```

```bash
cp src/redis-server /usr/local/bin/
cp src/redis-cli /usr/local/bin/
```

```bash
mkdir /etc/redis
mkdir /var/redis
```

Далее в доке предлагается сделать `cp utils/redis_init_script /etc/init.d/redis_6379`, где 6379 — номер дефолтного порта, но я планирую, что Redis будет работать у меня через unix.socket, поэтому будет так (везде далее нолик появляется именно по этой же причине):

```bash
cp utils/redis_init_script /etc/init.d/redis_0
```

Теперь нужно подредактировать конфиг:

```bash
nano /etc/init.d/redis_0
```

Редактированию там подлежит только номер порта (6-я строка):

```
REDISPORT=6379  -->  REDISPORT=0
```

Если номер порта не менять, то и редактировать ничего не нужно.

Но в моем случае, поскольку я планирую запускать редис через unix socket, то нужно еще внести несколько изменений:

- Добавляем переменную:
  ```
  UNIXSOCK=/tmp/redis.sock
  ```
- Выражение `$CLIEXEC -p $REDISPORT shutdown` в секции "stop" заменяем на `$CLIEXEC -s $UNIXSOCK shutdown`.

Вот что получилось:

```bash
#!/bin/sh

REDISPORT=0
#REDISPORT=6379
UNIXSOCK=/tmp/redis.sock
OWNER=nobody

EXEC=/usr/local/bin/redis-server
CLIEXEC=/usr/local/bin/redis-cli

PIDFILE=/var/run/redis_${REDISPORT}.pid
CONF="/etc/redis/${REDISPORT}.conf"

case "$1" in
  start)
      if [ -f $PIDFILE ]
      then
              echo "$PIDFILE exists, process is already running or crashed"
      else
              echo "Starting Redis server..."
              $EXEC $CONF
      fi
      ;;
  stop)
      if [ ! -f $PIDFILE ]
      then
              echo "$PIDFILE does not exist, process is not running"
      else
              PID=$(cat $PIDFILE)
              echo "Stopping ..."
              #$CLIEXEC -p $REDISPORT shutdown
              $CLIEXEC -s $UNIXSOCK shutdown
              while [ -x /proc/${PID} ]
              do
                  echo "Waiting for Redis to shutdown ."
                  sleep 0.5
                  echo -n ".."
                  sleep 0.5
                  echo -n ".."
              done
              echo "Redis stopped"
      fi
      ;;
  restart)
      if [ ! -f $PIDFILE ]
      then
              echo "$PIDFILE does not exist, process is not running"
      else
              PID=$(cat $PIDFILE)
              echo "Stopping ..."
              #$CLIEXEC -p $REDISPORT shutdown
              $CLIEXEC -s $UNIXSOCK shutdown
              while [ -x /proc/${PID} ]
              do
                  echo "Waiting for Redis to shutdown ..."
                  sleep 1
              done
              echo "Redis stopped"
      fi
      echo "Starting Redis server..."
      $EXEC $CONF
      ;;
  *)
      echo "Please use start or stop as first argument"
      ;;
esac
```

Далее нам нужно скопировать файл конфига:

```bash
cp redis.conf /etc/redis/0.conf
```

И отредактировать его:

```bash
nano /etc/redis/0.conf
```

В нем меняем следующее:

```ini
#daemonize no
daemonize yes

#pidfile /var/run/redis.pid
pidfile /var/run/redis_0.pid

#port 6379
port 0

bind 127.0.0.1

unixsocket /tmp/redis.sock
unixsocketperm 755

#loglevel verbose
loglevel warning

#logfile stdout
logfile /var/log/redis_0.log

#databases 16
databases 1
```

В секции "SNAPSHOTTING" можно поменять стратегию дампов. Я сделал так:

```ini
save 54000 10
save 3600 5000

dir /var/redis/dumps/
dbfilename dump_0.rdb
```

Поскольку в сеть смотреть мой редис не будет, то репликацию я в нем отключил (секция 'REPLICATION'):

```ini
#slave-serve-stale-data yes
slave-serve-stale-data no
```

Далее, поскольку, как и сказано в конфиге, я собираюсь использовать редис не в качестве основной БД, а в качестве кеша, то стоит установить maxmemory, чтобы редис ненароком не сожрал всю память:

```ini
# 256 MB
maxmemory 268435456
```

Поскольку maxmemory установлен, то нужно установить и maxmemory-policy:

```ini
# maxmemory-policy volatile-lru
maxmemory-policy volatile-ttl
```

Выбрал `volatile-ttl`, потому что не знаю, как работает алгоритм LRU.

Отключаем appendfsync:

```ini
appendfsync no
```

Все, на этом правки конфига закончены.

Для логов мы указывали каталог `/var/redis/dumps`. Его нужно не забыть создать:

```bash
mkdir /var/redis/dumps
```

Проверяем, все ли работает. Проверить можно так:

Запускаем:

```bash
/etc/init.d/redis_0 start
```

Потом:

```bash
redis-cli -s /tmp/redis.sock
```

В консоли redis:

```
SET key1 "Test"
OK
GET key1
"Test"
```

Если все нормально, то добавляем в автозагрузку:

```bash
update-rc.d redis_0 defaults
```

---

**PS**  
В логах редиса он сообщил мне следующее предупреждение:

```
WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
```

Поскольку я готов мириться с тем, что он не будет дампить себя на диск, то это предупреждение проигнорирую.
А вообще решение вижу таким:

В `/etc/sysctl.conf` ничего, естественно, не вносим, но в `/etc/init.d/redis_0`  
В секции старт, перед запуском редиса, сохраняем системное значение overcommit_memory:

```bash
touch /tmp/overcommit_memory_bfr_redis
chmod 0600 /tmp/overcommit_memory_bfr_redis
cat /proc/sys/vm/overcommit_memory > /tmp/overcommit_memory_bfr_redis
sysctl vm.overcommit_memory=1
```

А в секцию стоп возвращаем системное значение:

```bash
OCMSYS=$(cat /tmp/overcommit_memory_bfr_redis)
sysctl vm.overcommit_memory=$OCMSYS
```

Примерно так:

```bash
#!/bin/sh

REDISPORT=0
#REDISPORT=6379
UNIXSOCK=/tmp/redis.sock
OWNER=nobody

EXEC=/usr/local/bin/redis-server
CLIEXEC=/usr/local/bin/redis-cli

PIDFILE=/var/run/redis_${REDISPORT}.pid
CONF="/etc/redis/${REDISPORT}.conf"

#fix WARNING about overcommit_memory
FWOBOM=FALSE

case "$1" in
  start)
      if [ -f $PIDFILE ]
      then
              echo "$PIDFILE exists, process is already running or crashed"
      else
              echo "Starting Redis server..."
              # -- fix WARNING about overcommit_memory
              if [ "TRUE" = $FWOBOM ]
              then
                touch /tmp/overcommit_memory_bfr_redis
                chmod 0600 /tmp/overcommit_memory_bfr_redis
                cat /proc/sys/vm/overcommit_memory > /tmp/overcommit_memory_bfr_redis
                sysctl vm.overcommit_memory=1
              fi
              # <--
              $EXEC $CONF
      fi
      ;;
  stop)
      if [ ! -f $PIDFILE ]
      then
              echo "$PIDFILE does not exist, process is not running"
      else
              PID=$(cat $PIDFILE)
              echo "Stopping ..."
              #$CLIEXEC -p $REDISPORT shutdown
              $CLIEXEC -s $UNIXSOCK shutdown
              while [ -x /proc/${PID} ]
              do
                  echo "Waiting for Redis to shutdown ."
                  sleep 0.5
                  echo -n ".."
                  sleep 0.5
                  echo -n ".."
              done
              # -- fix WARNING about overcommit_memory
              if [ "TRUE" = $FWOBOM ]
              then
                OCMSYS=$(cat /tmp/overcommit_memory_bfr_redis)
                sysctl vm.overcommit_memory=$OCMSYS
              fi
              # <--
              echo "Redis stopped"
      fi
      ;;
  restart)
      if [ ! -f $PIDFILE ]
      then
              echo "$PIDFILE does not exist, process is not running"
      else
              PID=$(cat $PIDFILE)
              echo "Stopping ..."
              #$CLIEXEC -p $REDISPORT shutdown
              $CLIEXEC -s $UNIXSOCK shutdown
              while [ -x /proc/${PID} ]
              do
                  echo "Waiting for Redis to shutdown ..."
                  sleep 1
              done
              echo "Redis stopped"
      fi
      echo "Starting Redis server..."
      # -- fix WARNING about overcommit_memory
      if [ "TRUE" = $FWOBOM ]
      then
        touch /tmp/overcommit_memory_bfr_redis
        chmod 0600 /tmp/overcommit_memory_bfr_redis
        cat /proc/sys/vm/overcommit_memory > /tmp/overcommit_memory_bfr_redis
        sysctl vm.overcommit_memory=1
      fi
      # <--
      $EXEC $CONF
      ;;
  *)
      echo "Please use start or stop as first argument"
      ;;
esac
```

---

**PPS**  
- overcommit_memory влияет на выделение памяти ядром и на работу OOM Killer.  
`vm.overcommit_memory=0` — более безопасный вариант, т.к. кто его знает, кого грохнет OOM Killer, если память кончится.

- Если tcp сокет устраивает, а нужно только (возможно задать порт), то в каталоге utils с исходниками есть скрипт `install_server.sh`, запуск которого сделает большую часть грязной работы, описанной выше.

- По поводу maxmemory-policy volatile-lru vs volatile-ttl: [статья на хабре про LRU](http://habrahabr.ru/blogs/development/136758/)

