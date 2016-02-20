#!/bin/bash
# Apps
apps=(
  airmail-beta
  alfred
  appcleaner
  atom
  bettertouchtool
  daisydisk
  dash
  dropbox
  flux
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

# Install apps to /Applications
# Default is: /Users/$user/Applications
echo "installing apps..."
brew cask install --appdir="/Applications" ${apps[@]}
