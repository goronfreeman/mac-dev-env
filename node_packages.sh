#!/bin/bash

packages=(
  csslint
  eslint
  gulp-cli
  htmlhint
  js-yaml
  jsonlint
)

# Install node packages
for i in ${packages[@]}; do
  echo Installing $i...
  npm install -g $i
done
