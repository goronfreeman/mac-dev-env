#!/bin/bash

# Brew Apps
brew_apps=(
  chruby
  fzf
  gifify
  git
  gti
  heroku-toolbelt
  imagemagick
  lame
  mysql
  node
  postgresql
  ruby-install
  sqlite
  terminal-notifier
  the_silver_searcher
  tig
  youtube-dl
)

# Cask Apps
cask_apps=(
  airmail-beta
  alfred
  appcleaner
  atom
  bettertouchtool
  daisydisk
  dash
  dropbox
  flux
  google-chrome
  google-chrome-canary
  google-drive
  google-photos-backup
  heroku-toolbelt
  imageoptim
  istat-menus
  iterm2-beta
  kaleidoscope
  linear
  mysqlworkbench
  openemu
  paw
  scroll-reverser
  spotify
  steam
  the-unarchiver
  transmission
  vlc
)

echo "Installing brew apps..."
for i in ${brew_apps[@]}; do
  echo Installing $i...
  brew install $i
done

echo "Installing cask apps..."
for i in ${cask_apps[@]}; do
  echo Installing $i...
  brew cask install $i
done
