#!/bin/bash

set -e

# Получаем дату и время
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Получаем последний тег (или no-tag)
TAG=$(git describe --tags --always 2>/dev/null || echo "v0.0.0")

# Собираем сообщение коммита
COMMIT_MSG="Deploy: $DATE ($TAG)"

rm -rf public/
# hugo --minify
hugo
cd public
echo "valmat.ru" > ./CNAME
git init
git add .
git commit -m "$COMMIT_MSG"
git branch -M gh-pages
git remote add origin git@github.com:valmat/valmat.github.io.git
git push -f origin gh-pages
cd ..
