---
title: "Установка LaTeX в Linux Ubuntu"
date: 2010-09-08T14:30:00+00:00
draft: false
tags: ["archive"]
# tags: ["archive", "LaTeX", "linux"]
# filename: "latex-linux-ubuntu"
# catigories: ["LaTeX", "linux"]
---

Как утверждает [Википедия](http://ru.wikipedia.org/wiki/TeX_Live), с 2006-го года пакет teTeX более не поддерживается, а вместо него поддерживается TeX Live. Его и ставим.

Инструкцию по установке подглядел здесь: [http://linuxandfriends.com/2009/10/06/install-latex-in-ubuntu-linux/](http://linuxandfriends.com/2009/10/06/install-latex-in-ubuntu-linux/)

Ставим:

```bash
sudo su
apt-get install texlive texlive-full texlive-fonts-recommended latex-beamer texlive-pictures texlive-latex-extra
```

`texlive-full` попросил достаточно много места на диске (около 700 МБ). Место у меня было, поэтому я его всё же установил, но, при необходимости, можно не устанавливать `texlive-full`, а установить только нужные пакеты, которые входят в `texlive-full`.

В качестве IDE были на пробу установлены LyX, gedit-latex-plugin и TeXmaker.  
Про них пока ничего сказать не могу, т.к. ещё не юзал.

**PS:** это была моя первая установка LaTeX в Линуксе, до этого я устанавливал [MiKTeX](http://ru.wikipedia.org/wiki/MiKTeX) под виндой. Как всегда, небо и земля. Вот уж что действительно танцы с бубном, так это ставить МикТех под винду.
