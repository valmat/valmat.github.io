---
title: "Сериализация в PHP"
date: 2013-12-15T19:08:00Z
draft: false
tags: ["archive"]
# filename: "serialize-php"
# catigories: ["php", "web", "benchmark"]
---

Будут сравниваться 4 способа сериализации:

1. Стандартная сериализация `serialize`
2. JSON
3. msgpack
4. igbinary

## Кратко об установке

**JSON** раньше шел в стандартной поставке PHP. Сейчас нужно поставить дополнительное расширение `php5-json`.

**msgpack**  
Сайт: http://msgpack.org/  
Исходники: [github.com/msgpack/msgpack-php](https://github.com/msgpack/msgpack-php) и http://pecl.php.net/package/msgpack  
Ставим:

```sh
cd /tmp
wget http://pecl.php.net/get/msgpack-0.5.5.tgz
tar xzf msgpack-0.5.5.tgz
cd msgpack-0.5.5
phpize
./configure
make
make test
```

Если тесты прошли нормально, то создаем пакет и ставим:

```sh
sudo checkinstall -D --install=no
sudo dpkg -i msgpack_0.5.5-1_amd64.deb
```

**igbinary**  
Исходники: [github.com/phadej/igbinary](https://github.com/phadej/igbinary/tree/master) и http://pecl.php.net/package/igbinary  
Далее опять:

```sh
cd /tmp
wget http://pecl.php.net/get/igbinary-1.1.1.tgz
tar xzf igbinary-1.1.1.tgz
cd igbinary-1.1.1
phpize
./configure
make
make test
sudo checkinstall -D --install=no
sudo dpkg -i igbinary_1.1.1-1_amd64.deb
```

msgpack добавляет функции:

```php
BinData msgpack_pack(phpValue);
phpValue msgpack_unpack(BinData);
```

igbinary добавляет функции:

```php
BinData igbinary_serialize(phpValue);
phpValue igbinary_unserialize($BinData);
```

Чтобы они заработали, нужно не забыть включить их в php.ini:

```ini
[igbinary]
extension=igbinary.so

; Enable or disable compacting of duplicate strings
; The default is On.
;igbinary.compact_strings=On

[msgpack]
extension=msgpack.so
```

## Что еще важно отметить

- `serialize` — стандартная функция PHP.
- JSON — старое и стабильное расширение.
- igbinary — тоже достаточно старая библиотека, давно вышедшая в стабильную ветку.
- msgpack — на данный момент все еще находится в стадии beta. С msgpack мне реально доводилось ловить глюки в ее предыдущих релизах. И если я решусь внедрять ее в продакшен, то только там, где ее ошибки не принесут фатального ущерба.

## Собственно тесты

---

### 1. Массив вида

```php
array (
  'v0' => 
    array (
      0 => 0,
      1 => 1,
      2 => 2,
      ...
      3 => 3,
      23 => 23,
      24 => 24,
    ),
  'rnd0' => '2e0c883df6e2cb771103f4409f053549094d6787',
  ...
)
```
c 16384 элементами

|                | Время сериализации (msec) | Время десериализации (msec) | Размер упакованных данных (Kb) |
|----------------|:------------------------:|:---------------------------:|:------------------------------:|
| MessagePack    |           9              |            25               |             678                |
| igbinary<br>compact_strings=Off | 9      | 32                          | 1278                           |
| igbinary<br>compact_strings=On  | 16     | 32                          | 1120                           |
| JSON           |           14             |           318               |            1022                |
| SERIALIZE      |           62             |            39               |           2486                 |

---

### 2. Массив вида

```php
array (
  0 => 3183,
  1 => 4527,
  2 => 4084,
  3 => 4032,
  4 => 3920,
  ...
  262144 => 4455,
)
```

|                | Время сериализации (msec) | Время десериализации (msec) | Размер упакованных данных (Kb) |
|----------------|:------------------------:|:---------------------------:|:------------------------------:|
| MessagePack    |           8              |            30               |             769                |
| igbinary<br>compact_strings=Off | 9      | 33                          | 1920                           |
| igbinary<br>compact_strings=On  | 9      | 33                          | 1920                           |
| JSON           |           15             |           107               |            1281                |
| SERIALIZE      |           86             |            44               |           3988                 |

---

### 3. Массив вида

```php
array (
  0 => 7679461759223599104,
  1 => 4898705982311625344,
  2 => 5880628818820227328,
  ...
  262144 => 6940876209816891904,
)
```

|                | Время сериализации (msec) | Время десериализации (msec) | Размер упакованных данных (Kb) |
|----------------|:------------------------:|:---------------------------:|:------------------------------:|
| MessagePack    |           10             |            29               |            2305                |
| igbinary<br>compact_strings=Off | 11     | 33                          | 3456                           |
| igbinary<br>compact_strings=On  | 11     | 33                          | 3456                           |
| JSON           |           20             |           172               |            5121                |
| SERIALIZE      |           92             |            49               |           7828                 |

---

### 4. Массив вида

```php
array (
  0 => 0.00038631346578366,
  1 => 0.00016131634134538,
  2 => 0.00043595779928503,
  3 => 0.00011754334410814,
  4 => 0.00049353469548909,
  5 => 5.2391680201184E-5,
  ...
  262144 => 0.00041876046901173,
)
```

|                | Время сериализации (msec) | Время десериализации (msec) | Размер упакованных данных (Kb) |
|----------------|:------------------------:|:---------------------------:|:------------------------------:|
| MessagePack    |           9              |            28               |            2305                |
| igbinary<br>compact_strings=Off | 11     | 33                          | 3456                           |
| igbinary<br>compact_strings=On  | 11     | 33                          | 3456                           |
| JSON           |           75             |           197               |            5061                |
| SERIALIZE      |           264            |           176               |           8538                 |

---

### 5. Массив вида

```php
array (
  0 => 'f7df8cb47630b8cd7eb73d0da7a23b9c01aaaa84f718499c1c8cef6730f9fd03c8125cab',
  1 => 'd30f79cf7fef47bd7a5611719f936539bec0d2e93bcf6eecb2611212e088d0d91f2ade9c',
  2 => '86bce22a4d2805649853ac7909c4efb4dd18f255086af6e4641abb18caafc151b9aa95c8',
  3 => '63afd0edc0371ad842d7a7ecc76260be4bc3e8c0da6cb383f8f9e58f2c8af88a8c0eb65e',
  4 => '13c80015875a668e8fc059517ffd124abbda63c12d95666e2649fcfc6e3af75e09f5adb9',
  ...
  32768 => '0e3808238b738aafc13a2a62f36d2a49dec4e191c22abfa379f38b5b0411bc11fa9bf92f',
)
```

|                | Время сериализации (msec) | Время десериализации (msec) | Размер упакованных данных (Kb) |
|----------------|:------------------------:|:---------------------------:|:------------------------------:|
| MessagePack    |           4              |            5                |            2401                |
| igbinary<br>compact_strings=Off | 4      | 6                           | 2464                           |
| igbinary<br>compact_strings=On  | 21     | 6                           | 2463                           |
| JSON           |           28             |           16                |            2401                |
| SERIALIZE      |           10             |            7                |           2806                 |

---

Замечу, что приведенные в таблицах данные являются примерными и зависят от данных. Так как данные у меня заполнялись случайным образом, то цифры получались разные, но разница несущественна и в целом эти цифры отражают реальную картину.
