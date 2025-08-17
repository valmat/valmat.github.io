---
title: "Принтер Canon LBP 3200 в Ubuntu"
date: 2010-09-20T16:10:00Z
draft: false
tags: ["archive", "ubuntu", "lbp3200", "hardware", "linux", "printer"]
# filename: "canon-lbp-3200-ubuntu"
# catigories: ["ubuntu", "lbp3200", "hardware", "linux", "printer"]
---

К великому моему сожалению, принтер Canon LBP 3200 не заработал в Ubuntu 9.10 "из коробки".

Драйверов для него в стандартной поставке нет. Просто скачать и установить [драйвер](http://files.canon-europe.com/files/soft31118/software/CAPTDRV180.tar.gz) тоже сразу не получилось. Поэтому я решил поискать ответ в интернете.

Мне удалось найти две адекватные ссылки:

- [http://forum.ubuntu.ru/index.php?topic=87445.0](http://forum.ubuntu.ru/index.php?topic=87445.0)
- [http://help.ubuntu.ru/wiki/%D0%BF%D1%80%D0%B8%D0%BD%D1%82%D0%B5%D1%80%D1%8B_canon_capt](http://help.ubuntu.ru/wiki/%D0%BF%D1%80%D0%B8%D0%BD%D1%82%D0%B5%D1%80%D1%8B_canon_capt)

Собственно, моя инструкция полностью написана, руководствуясь этими ссылками. К сожалению, обе они по отдельности результата не дали.

Все, что написано ниже, у меня дало положительный результат.

## Инструкция для Ubuntu 9.10

Открываем терминал:

```sh
sudo su
```

Удаляем:

- libcupsys2 и libstdc++5:

```sh
/usr/sbin/ccpdadmin -x LBP3200
sudo /usr/sbin/lpadmin -x LBP320
sudo dpkg -P cndrvcups-capt
sudo dpkg -P cndrvcups-common
```

Далее скачиваем и устанавливаем `libcupsys2` и `libstdc++5`:

- [libcupsys2](https://launchpad.net/ubuntu/karmic/+package/libcupsys2)
- [libstdc++5](http://packages.ubuntu.com/jaunty/libstdc++5)

Далее надо скачать драйвер принтера:

```sh
sudo su
cd /tmp
wget http://files.canon-europe.com/files/soft31118/software/CAPTDRV180.tar.gz
tar -xzf CAPTDRV180.tar.gz
cd ./CANON_UK/Driver/Debian
dpkg -i cndrvcups-common_1.80-1_i386.deb
dpkg -i cndrvcups-capt_1.80-1_i386.deb
```

Далее надо отредактировать файл `/etc/ccpd.conf`:

```sh
sudo gedit /etc/ccpd.conf
```

Меняем строки:

```
#<Printer  LBP3200>
#DevicePath /dev/usb/lp0
#</Printer>
```

на

```
<Printer  LBP3200>
DevicePath /dev/usblp0
</Printer>
```

Перегружаем сервер печати:

```sh
sudo /etc/init.d/cups restart
sudo /etc/init.d/ccpd stop && sudo /etc/init.d/ccpd start
```

Регистрируем принтер в ccpd:

```sh
sudo /usr/sbin/ccpdadmin -p LBP3200 -o /dev/usblp0
sudo /etc/init.d/ccpd stop && sudo /etc/init.d/ccpd start
```

Окно статуса принтера можно открыть так:

```sh
captstatusui -P LBP3200
```

---

## UPDATE

Поставил Linux Mint 16 64bit (~ Ubuntu 13.10), и в нем моя инструкция, конечно, не подходит.

Пришлось проходить этот квест заново. К счастью, Canon выпустил новые драйверы, что немного облегчает задачу.

Итак, имеем названную систему.

1. Скачиваем и устанавливаем deb-пакеты с [драйверами от производителя](http://www.canon-europe.com/Support/Consumer_Products/products/printers/Laser/Laser_Shot_LBP3200.aspx).
2. Подключаем и включаем принтер. Смотрим, на какой usb-порт он подключился (у меня `/dev/usb/lp1`). Смотреть нужно тут: `/dev/usb`
3. Правим `/etc/ccpd.conf`:

    ```sh
    sudo gedit /etc/ccpd.conf
    ```

    Меняем строки:

    ```
    #<Printer  LBP3200>
    #DevicePath /dev/usb/lp0
    #</Printer>
    ```

    на

    ```
    <Printer  LBP3200>
    DevicePath /dev/usb/lp1
    </Printer>
    ```

4. Добавляем принтер (в архиве с драйверами есть README, можно посмотреть откуда взялись эти строки и на что их менять, если принтер отличается):

    ```sh
    sudo /usr/sbin/lpadmin -p LBP3200 -P /usr/share/cups/model/CNCUPSLBP3200CAPTK.ppd -v ccp://localhost:59687 -E
    sudo /usr/sbin/lpadmin -p LBP3200 -m CNCUPSLBP3200CAPTK.ppd -v ccp://localhost:59787 -E
    sudo /usr/sbin/ccpdadmin -p LBP3200 -o /dev/usb/lp1
    ```

5. Перегружаем сервер печати (см. выше)
6. Печатаем пробную страницу.

Все!

---

**PS**

Что еще обнаружилось:

- Нужно добавить `/etc/init.d/ccpd` в автозагрузку:

    ```sh
    update-rc.d ccpd defaults 20;
    ```

    Причем, даже после добавления в автозагрузку, нужно перезагружать ccpd. Поэтому еще нужно в `/etc/rc.local` перед `exit 0` добавить:

    ```sh
    /etc/init.d/ccpd restart
    ```

- Кроме того выяснилось, что в зависимости от того, был ли подключен включенный принтер до загрузки системы или нет, принтеру назначаются разные файлы устройства. Если включен после загрузки ОС, то `/dev/usb/lp1`, если до — то `/dev/usb/lp0`.

Чтобы преодолеть эту неприятность, я изобрел следующий костыль:

В `/etc/init.d/ccpd` в начало секций `ccpd_start()` и `ccpd_stop()` (только `ccpd_start` недостаточно) добавил следующий блок:

```sh
###############################
# Fix гуляние портов
if [ -e /dev/usb/lp0 ]; then
    echo "Exist /dev/usb/lp0"
    if [ ! -e /dev/usb/lp1 ]; then
        echo "NOT exist /dev/usb/lp1"
        echo "ln -s /dev/usb/lp0 /dev/usb/lp1"
        ln -s /dev/usb/lp0 /dev/usb/lp1
    fi
fi
###############################
```

Этот блок создает символическую ссылку в случаях, когда система загружается с уже включенным принтером.
