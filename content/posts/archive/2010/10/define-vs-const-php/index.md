---
title: "define vs const в PHP"
date: 2010-10-28T19:00:00Z
draft: false
tags: ["archive"]
# tags: ["archive", "php", "benchmark"]
# filename: "define-vs-const-php"
# catigories: ["php", "benchmark"]
---

Как известно, при разработке крупных веб-приложений помимо архитектуры постоянно приходится задумываться также и о производительности. Этим постом я хотел бы открыть серию публикаций по тестированию PHP на производительность.

Речь пойдет о сравнении способов хранения констант в приложении на PHP.  
А именно сравниваются два подхода:

```php
define('CONST1', 'val11');
define('CONST2', 'val12');
define('CONST2', 'val13');
```

и

```php
class Consts {
    const CONST1 = 'val1';
    const CONST2 = 'val2';
    const CONST3 = 'val3';
}
```

В первом случае, вроде бы как должна использоваться специальная область памяти, и такой способ уж если и не экономит память, так точно должен быть быстрее. Второй способ в некоторых случаях существенно удобнее, так как позволяет не захламлять глобальную область видимости.

В общем, чтобы не гадать, я провел тесты.

## Тест 1. Инициализация

Инициализируем 100 констант при помощи **define**:

```php
define('CACHER_TYPE_1', 'b60861c4492f88589429aab0c67abdd4');
/*     ...    */
define('CACHER_TYPE_100', 'a66aedeafbc3f1e9fcbaa6a9e8060739');
```

- memory_start: 114.7578125 Кб
- time: **0.442981719971** ms
- memory_finish: 120.8515625 Кб
- memory_diff: **6.09375 Кб**

Тестирование через ab:

```
$ ab -n 1000 http://test/test/mem_class.php
Requests per second:    714.52 [#/sec] (mean)
Time per request:       **1.400** [ms] (mean)
```

Теперь инициализируем через константы класса:

```php
class SlotType {
    const TYPE_CACHER_1 = 'b60861c4492f88589429aab0c67abdd4';
    /*     ...    */
    const TYPE_CACHER_100 = 'a66aedeafbc3f1e9fcbaa6a9e8060739';
}
```

- memory_start: 114.7578125 Кб
- time: **0.0340938568115** ms
- memory_finish: 114.9921875 Кб
- memory_diff: **0.234375 Кб**

Тестирование через ab:

```
$ ab -n 1000 http://test/test/mem_class.php
Requests per second:    818.27 [#/sec] (mean)
Time per request:       **1.222** [ms] (mean)
```

## Тест 2. Чтение

Считываем все константы, определённые через **define**:

```php
$var = CACHER_TYPE_1 . CACHER_TYPE_2 . /*...*/ . CACHER_TYPE_100;
```

- time: **0.4** ms
- memory_diff: **9.3 Кб**

ab -n1000:

```
Requests per second:    488.63 [#/sec] (mean)
Time per request:       **2.047** [ms] (mean)
```

Считываем через константы класса:

```php
$var = SlotType::TYPE_CACHER_1 . SlotType::TYPE_CACHER_2 . /*...*/ . SlotType::TYPE_CACHER_100;
```

- time: **0.12** ms
- memory_diff: **3.5 Кб**

ab -n1000:

```
Requests per second:    609.62 [#/sec] (mean)
Time per request:       **1.640** [ms] (mean)
```

## Вывод

Надо сказать, результат меня несколько удивил. Я ожидал, что по крайней мере скорость обработки с define будет выше. Оказывается, использование варианта

```php
class Consts {
    const CONST1 = 'val1';
    const CONST2 = 'val2';
    const CONST3 = 'val3';
}
```

не только удобнее, но и эффективнее как по скорости исполнения, так и по расходу памяти.
