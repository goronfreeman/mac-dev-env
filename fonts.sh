#!/bin/bash
#Installing fonts
pretty_print "Installing some caskroom/fonts..."
brew tap caskroom/fonts

fonts=(
  font-open-sans
  font-roboto-mono
  font-source-code-pro
)

# install fonts
pretty_print "Installing the fonts..."
brew cask install ${fonts[@]}
