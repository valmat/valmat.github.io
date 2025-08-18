---
title: "Пластилиновый мультик"
date: 2013-03-04T08:50:00.003Z
draft: false
tags: ["archive"]
# filename: "plastylynovyy-multik"
# catigories: []
---

Сделали с дочей мультик из пластилина.

Делается так:

```bash
convert -delay 20 -loop 0 *.jpg mygif.gif
```

Вот результат:

![Пластилиновый мультик](./myimage.gif)

Еще полезное:

Сделать из кадров ролик:

```bash
convert -delay 20 -loop 0 *.jpg mympg.mpg
```

MOV из gif:

```bash
convert mygif.gif mymov.mov
```

Видео на YouTube:

<iframe width="320" height="266" src="https://www.youtube.com/embed/_oHiKSMMwAA" title="Пластелиновый человечик" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

[Смотреть на YouTube](https://www.youtube.com/watch?v=_oHiKSMMwAA)
