#!/usr/bin/env bash
set -euo pipefail

# Использование: ./new-post.sh [имя_файла]
# Если имя не передано — спросим.

file_name="${1-}"

if [[ -z "$file_name" ]]; then
    read -r -p "Введите имя файла (slug): " file_name
fi

# Проверка на пустую строку (включая пробелы)
if [[ -z "${file_name// }" ]]; then
    echo "Ошибка: имя файла не может быть пустым." >&2
    exit 1
fi

# Проверка наличия Hugo
if ! command -v hugo >/dev/null 2>&1; then
    echo "Ошибка: команда 'hugo' не найдена. Установите Hugo или добавьте её в PATH." >&2
    exit 127
fi

# Выполнение команды, как вы указали
hugo new "posts/${file_name}/index.md"

