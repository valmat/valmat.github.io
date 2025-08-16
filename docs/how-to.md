# Шпаргалка: Как запустить блог на **Hugo** (для опытных разработчиков)

---

## Установить Hugo

### Linux Mint (и большинство дистрибутивов):

**Через apt (обычно старая версия, но можно):**
```sh
sudo apt update
sudo apt install hugo
```

**Рекомендую: скачать актуальный релиз с GitHub:**
1. Перейди на [страницу релизов Hugo](https://github.com/gohugoio/hugo/releases/latest).
2. Скачай архив для Linux (`hugo_extended_*_Linux-64bit.tar.gz`).
3. Распакуй, положи бинарник `hugo` в `~/bin` или `/usr/local/bin`.

Проверь:
```sh
hugo version
```

---

## Создать новый сайт Hugo

В новой или очищенной ветке (`hugo`):

```sh
hugo new site . --force
```
или в новой директории:
```sh
hugo new site myhugoblog
cd myhugoblog
```

---

## Установить тему

На сайте [themes.gohugo.io](https://themes.gohugo.io/) — огромный каталог тем.

**Для примера возьмём популярную тему Ananke:**

```sh
git init
git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke
```

В конфиге (`config.toml`):
```toml
theme = "ananke"
```

---

## Создать первый пост

```sh
hugo new posts/my-first-post.md
```
В каталоге `content/posts/` появится файл. Открой и пиши в Markdown!

---

## Структура проекта

```
.
├── config.toml        # Главный конфиг (можно .yaml/.json)
├── content/           # Все статьи и страницы
│   └── posts/
│       └── my-first-post.md
├── themes/            # Темы (лучше как submodule)
│   └── ananke/
├── static/            # Статичные файлы (изображения, favicon и т.д.)
├── resources/         # Кэш Hugo, не трогай
└── public/            # Генерируется Hugo (готовый сайт)
```

---

## Локальный запуск

```sh
hugo server -D
```
Откроется сайт:  
http://localhost:1313

`-D` — показывает драфты (черновики).

---

## Генерация готового сайта

```sh
hugo
```
Будет создана папка `public/` — это полностью статический сайт (HTML, CSS, JS).

---

## Публикация на GitHub Pages

1. Удали/очисти ветку `main` (или сделай новую ветку `hugo`).
2. Добавь всё, кроме `public/`:
    - Обычно генерированный сайт не хранят в репозитории, кроме ветки для деплоя.
    - Или можно использовать [gh-pages branch](https://gohugo.io/hosting-and-deployment/hosting-on-github/), где содержится только содержимое из `public/`.
3. Для автоматизации публикации можно настроить GitHub Action ([пример для Hugo](https://github.com/peaceiris/actions-hugo)), чтобы после пуша сайт сам генерировался и выкладывался.

**Самый простой путь:**  
1. Сгенерируй сайт:
    ```sh
    hugo
    ```
2. Перейди в папку `public`:
    ```sh
    cd public
    git init
    git remote add origin git@github.com:valmat/valmat.github.io.git
    git checkout -b main
    git add .
    git commit -m "Deploy Hugo blog"
    git push -f origin main
    ```
3. Или используй отдельную ветку `gh-pages` для деплоя, а исходники храни в ветке `hugo`.

---

## Куда складывать черновики, скрипты и личные заметки

- Черновики:  
  При создании поста добавить в самом верху front matter:
  ```toml
  draft = true
  ```
  Такой пост не попадёт в релизную сборку, если не использовать флаг `-D` при запуске сервера.

- Документация для себя:  
  Сохраняй в папке вне `content/` (например, `_docs/`, `notes/`, `scripts/`) — Hugo их не публикует.

---

## Markdown и кодовые блоки

Hugo поддерживает стандартный Markdown для кода:

```go
fmt.Println("Hello, Hugo!")
```

Никаких `{% ... %}`!

---

## Пример минимального конфига

`config.toml`:
```toml
baseURL = "https://valmat.github.io/"
languageCode = "ru-ru"
title = "Valmat blog"
theme = "ananke"
```

---

## Быстрый стартовый алгоритм

1. `hugo new site . --force`
2. `git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke`
3. В `config.toml`: `theme = "ananke"`
4. `hugo new posts/my-first-post.md`
5. Пиши/редактируй Markdown в `content/posts/`
6. `hugo server -D`
7. Готово? → `hugo` → всё в `public/`
8. Залей содержимое `public/` на `main` или `gh-pages` ветку в `valmat.github.io`

## Загрузка

```bash
#!/bin/bash
hugo
cd public
git init
git add .
git commit -m "Deploy"
git branch -M gh-pages
git remote add origin https://github.com/valmat/valmat.github.io.git
git push -f origin gh-pages
cd ..
```

---

## Полезные ссылки
- Официальная дока: https://gohugo.io/documentation/
- Темы: https://themes.gohugo.io/
- Готовые шаблоны: https://github.com/gohugoio/hugoBasicExample

## Ссылки от меня
- Официальная дока: https://gohugo.io/documentation/
- Темы: https://themes.gohugo.io/
- Готовые шаблоны: https://github.com/gohugoio/hugoBasicExample

