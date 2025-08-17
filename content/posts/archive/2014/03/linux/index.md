---
title: "Отчетность в налоговую на Linux"
date: 2014-03-20T10:43:00+00:00
draft: false
tags: ["archive"]
# filename: "linux"
# catigories: []
---

Как я готовлю отчетность в налоговую.

Выписки у меня достаются в таком формате:

- `2014.01.20.rtf`
- `2014.01.20-1.rtf`
- ...

В первую очередь, нужно упорядочить по дате, поэтому переименовываем:

```bash
for i in `find . -type f -name "*.rtf*"`; do
  dst=`echo $i | sed -e :a -e 's/\(.*\)\([0-9]\{2\}\)\.\([0-9]\{2\}\)\.\([0-9]\{4\}\)\(.*\)/\1\4.\3.\2\5/;ta'`
  echo mv $i $dst
done
```

Потом конвертируем в PDF:

```bash
libreoffice --invisible --convert-to pdf *.rtf
```

И соединяем все в один файл:

```bash
gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=toprint.pdf -dBATCH `find . -type f -name "*.pdf" | sort`
```

Всё.
