---
title: "Clang vs gcc performance"
date: 2014-05-31T21:18:00Z
draft: false
tags: ["archive"]
filename: "clang-vs-gcc-performance"
catigories: []
---

Стало мне интересно, и решил я провести такую глупую проверку: сравнить производительность программ, откомпилированных Clang'ом и gcc.

Для эксперимента взял первую попавшуюся реализацию пузырьковой сортировки с GitHub'а.

Компилировал с опциями `-g`, `-O1`, `-O2`, `-O3` и без опций.

Получилось интересно и неожиданно.

Для запуска тестов использовал такой скрипт:

```bash
#!/bin/bash

OPT="-O3"
g++ $OPT bubble.cpp -o bubble1
clang++ $OPT bubble.cpp -o bubble2   # -stdlib=libstdc++
clang++ $OPT -stdlib=libc++ bubble.cpp -o bubble3 # -stdlib=libc++

# ls -slh
# exit;

sleep 3
time ./bubble1 > /dev/null
sleep 3
time ./bubble2 > /dev/null
sleep 3
time ./bubble3 > /dev/null
```

Меняя параметр `OPT`.

Поясню, что здесь компилируется:

- `g++ $OPT bubble.cpp -o bubble1`  
  Используется **gcc**

- `clang++ $OPT bubble.cpp -o bubble2`  
  Используется **clang** со стандартной библиотекой **libstdc++** от gcc

- `clang++ $OPT -stdlib=libc++ bubble.cpp -o bubble3`  
  Используется **clang** со своей собственной стандартной библиотекой **libc++**

### Результаты производительности

| Опция        | gcc                        | clang -stdlib=libstdc++ (gcc) | clang -stdlib=libc++         |
|--------------|----------------------------|-------------------------------|------------------------------|
| -g           | real **0m3.337**s<br>user 0m3.335s<br>sys 0m0.004s | real **0m3.294**s<br>user 0m3.296s<br>sys 0m0.000s | real **0m3.323**s<br>user 0m3.325s<br>sys 0m0.000s |
| без опций    | real **0m3.334**s<br>user 0m3.336s<br>sys 0m0.000s | real **0m3.293**s<br>user 0m3.295s<br>sys 0m0.000s | real **0m3.320**s<br>user 0m3.318s<br>sys 0m0.004s |
| -O1          | real **0m1.735**s<br>user 0m1.735s<br>sys 0m0.000s | real **0m1.485**s<br>user 0m1.486s<br>sys 0m0.000s | real **0m1.493**s<br>user 0m1.494s<br>sys 0m0.000s |
| -O2          | real **0m1.516**s<br>user 0m1.517s<br>sys 0m0.000s | real **0m1.522**s<br>user 0m1.523s<br>sys 0m0.000s | real **0m1.495**s<br>user 0m1.492s<br>sys 0m0.004s |
| -O3          | real **0m1.510**s<br>user 0m1.506s<br>sys 0m0.004s | real **0m1.534**s<br>user 0m1.535s<br>sys 0m0.000s | real **0m1.498**s<br>user 0m1.499s<br>sys 0m0.000s |

### Размеры бинарников

| Опция        | gcc   | clang -stdlib=libstdc++ (gcc) | clang -stdlib=libc++ |
|--------------|-------|-------------------------------|----------------------|
| -g           | 22K   | 28K                           | 65K                  |
| без опций    | 9,2K  | 8,3K                          | 15K                  |
| -O1          | 8,9K  | 8,4K                          | 12K                  |
| -O2          | 8,9K  | 8,1K                          | 12K                  |
| -O3          | 8,9K  | 8,1K                          | 12K                  |

Понятно, что по такому примеру корректно сравнивать компиляторы нельзя, но для меня, как для приверженца GNU компилятора, результаты получились неожиданными.

По сути, clang превзошёл gcc во всех направлениях.

Для меня основной вывод такой:  
Clang заслуживает внимания и заслуживает того, чтобы к нему присмотреться. Тем более, сообщения об ошибках, которые он выдаёт, информативнее, чем сообщения, выдаваемые gcc.

До этого я никогда не пользовался клэнгом (силангом). Столкнулся с ним по необходимости. Думаю, что стоит попробовать использовать его в своей работе.

Мои версии clang и gcc:

- **gcc version 4.8.1** (Ubuntu/Linaro 4.8.1-10ubuntu9)
- Debian **clang version 3.2**-7ubuntu1 (tags/RELEASE_32/final) (based on LLVM 3.2)
