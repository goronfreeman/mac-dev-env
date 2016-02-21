#!/bin/bash

gems=(
  bundler
  jekyll
  pry
  rails
  rubocop
  scss_lint
)

# Install gems
for i in ${gems[@]}; do
  echo Installing $i...
  gem install $i
done
