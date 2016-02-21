#!/bin/bash

fonts=(
  font-open-sans
  font-roboto-mono
  font-source-code-pro
)

# Install fonts
for i in ${fonts[@]}; do
  echo Installing $i...
  brew cask install $i
done
