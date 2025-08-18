#!/bin/bash

set -e

rm -rf public/
# hugo --minify
hugo
cd public
git init
git add .
git commit -m "Deploy"
git branch -M gh-pages
git remote add origin git@github.com:valmat/valmat.github.io.git
git push -f origin gh-pages
cd ..
