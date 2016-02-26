#!/bin/sh

# Some things taken from here
# https://github.com/mathiasbynens/dotfiles/blob/master/.osx

pretty_print() {
  printf "\n%b\n" "$1"
}

checkFor() {
  type "$1" &> /dev/null ;
}

pretty_print "Setting up your development environment..."

# Set continue to false by default
CONTINUE=false

pretty_print "Have you read through the script you're about to run and understood that it will make changes to your computer? (y/n)"
read -r response
case $response in
  [yY]) CONTINUE=true
      break;;
  *) break;;
esac

if ! $CONTINUE; then
  # Check if we're continuing and output a message if not
  pretty_print "Please go read the script. It only takes a few minutes."
  exit
fi

# Ask for the administrator password upfront and run a
# keep-alive to update existing `sudo` time stamp until script has finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Xcode command line tools
pretty_print "Installing Xcode command line tools..."
if [ "$(checkFor pkgutil --pkg-info=com.apple.pkg.CLTools_Executables)" ]; then
  pretty_print "Xcode command line tools are not installed. Installing..." ;
  xcode-select --install
  sleep 1
  osascript -e 'tell application "System Events"' -e 'tell process "Install Command Line Developer Tools"' -e 'keystroke return' -e 'click button "Agree" of window "License Agreement"' -e 'end tell' -e 'end tell'
fi

# Oh My Zsh installation
pretty_print "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Clone config files
pretty_print "Cloning config repos from GitHub..."
  mkdir github
  cd github

  pretty_print "Cloning dotfiles..."
  git clone git@github.com:goronfreeman/dotfiles.git

  pretty_print "Cloning nvimfiles..."
  git clone git@github.com:goronfreeman/nvimfiles.git

  pretty_print "Cloning zsh-syntax-highlighting..."
  cd ~/.oh-my-zsh/custom/plugins/
  git clone git@github.com:zsh-users/zsh-syntax-highlighting.git

  pretty_print "cd back to home directory..."
  cd ~

# Symlink config files
pretty_print "Symlinking config files..."
  pretty_print "Symlinking .gitconfig..."
  ln -s ~/github/dotfiles/gitconfig ~/.gitconfig

  pretty_print "Symlinking .scss-lint.yml..."
  ln -s ~/github/dotfiles/linter_config/scss-lint.yml ~/.scss-lint.yml

  pretty_print "Symlinking .eslintrc..."
  ln -s ~/github/dotfiles/linter_config/eslintrc ~/.eslintrc

  pretty_print "Symlinking .agignore..."
  ln -s ~/github/dotfiles/agignore ~/.agignore

  pretty_print "Symlinking .zshenv..."
  ln -s ~/github/dotfiles/oh_my_zsh/zshenv ~/.zshenv

  pretty_print "Symlinking .zshrc..."
  ln -s ~/github/dotfiles/oh_my_zsh/zshrc ~/.zshrc

  pretty_print "Symlinking alias.zsh..."
  ln -s ~/github/dotfiles/oh_my_zsh/custom/alias.zsh ~/.oh-my-zsh/custom/

  pretty_print "Symlinking fzf.zsh..."
  ln -s ~/github/dotfiles/oh_my_zsh/custom/fzf.zsh ~/.oh-my-zsh/custom/

  pretty_print "Symlinking functions.zsh..."
  ln -s ~/github/dotfiles/oh_my_zsh/functions.zsh ~/.oh-my-zsh/lib/

###############################################################################
# Homebrew
###############################################################################

# Homebrew installation

if ! command -v brew &>/dev/null; then
  pretty_print "Installing Homebrew, an OSX package manager. Follow the instructions..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  pretty_print "You already have Homebrew installed!"
fi

pretty_print "Updating brew formulas..."
  brew update

# Homebrew Cask installation

pretty_print "Installing Homebrew Cask..."
  brew install caskroom/cask/brew-cask

pretty_print "Adding cask taps..."
  brew tap caskroom/versions
  brew tap caskroom/fonts
  brew tap neovim/neovim

pretty_print "Installing apps..."
  sh apps.sh

pretty_print "Installing fonts..."
  sh fonts.sh

# when done with cask
brew update && brew upgrade --cleanup && brew cleanup -s && brew prune && brew cask cleanup

###############################################################################
# Neovim
###############################################################################

pretty_print "Installing Neovim..."
  brew install --HEAD neovim
  sudo easy_install pip
  sudo -H pip install neovim

  pretty_print "Cloning Neovim config files..."
    ln -s ~/github/nvimfiles/nvimrc ~/.nvimrc
    ln -s ~/github/nvimfiles/autoload/ ~/.nvim/

  pretty_print "Installing Neovim plugins..."
    nvim +PluginInstall +qall

###############################################################################
# fzf
###############################################################################

pretty_print "Installing fzf..."
  /usr/local/opt/fzf/install

###############################################################################
# Ruby
###############################################################################

pretty_print "Installing the latest version of Ruby..."
  ruby_version="$(curl -sSL https://raw.githubusercontent.com/IcaliaLabs/kaishi/master/latest_ruby)"
  ruby-install ruby $ruby_version
  echo "ruby-$ruby_version" > ~/.ruby-version

pretty_print "Installing gems..."
  sh gems.sh

pretty_print "Configuring Rubocop with your preferences..."
  curl https://gist.githubusercontent.com/goronfreeman/b13d44c9d5c02e689a44/raw/a2f6c26e11081cd82a4b1937f4ac243f610d5bf3/default.yml > ~/.gem/ruby/$ruby_version/gems/rubocop-$(rubocop -v)/config/default.yml
  curl https://gist.githubusercontent.com/goronfreeman/b13d44c9d5c02e689a44/raw/a2f6c26e11081cd82a4b1937f4ac243f610d5bf3/disabled.yml > ~/.gem/ruby/$ruby_version/gems/rubocop-$(rubocop -v)/config/disabled.yml
  curl https://gist.githubusercontent.com/goronfreeman/b13d44c9d5c02e689a44/raw/a2f6c26e11081cd82a4b1937f4ac243f610d5bf3/enabled.yml > ~/.gem/ruby/$ruby_version/gems/rubocop-$(rubocop -v)/config/enabled.yml

# TODO: Move to better section
pretty_print "Installing Node packages..."
  sh node_packages.sh

pretty_print "Installing atom-sync-settings..."
  apm install sync-settings

###############################################################################
# MySQL
###############################################################################

# Start MySQL daemon on system startup

pretty_print "Installing MySQL launch daemon..."
  ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

###############################################################################
# General UI/UX
###############################################################################

echo ""
echo "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo ""
echo "Disable Mission Control shift binding"
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:34:enabled NO" ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:35:enabled NO" ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:37:enabled NO" ~/Library/Preferences/com.apple.symbolichotkeys.plist

###############################################################################
# Finder
###############################################################################

echo ""
echo "Allow text selection in Quick Look/Preview by default"
defaults write com.apple.finder QLEnableTextSelection -bool true

echo ""
echo "Enabling snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

echo ""
echo "Enabling the Develop menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

echo "Set a fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 1

echo "Set a shorter delay until key repeat"
defaults write NSGlobalDomain InitialKeyRepeat -int 12

###############################################################################
# Time Machine
###############################################################################

echo ""
echo "Prevent Time Machine from prompting to use new hard drives as backup volume? (y/n)"
read -r response
case $response in
  [yY])
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
    break;;
  *) break;;
esac

###############################################################################
# Transmission.app                                                            #
###############################################################################

echo ""
echo "Do you use Transmission for torrenting? (y/n)"
read -r response
case $response in
  [yY])
  echo ""
    echo "Use `~/Torrents` for default download location"
    defaults write org.m0k.transmission DownloadFolder -string "${HOME}/Torrents"

    echo ""
    echo "Don't prompt for confirmation before downloading"
    defaults write org.m0k.transmission DownloadAsk -bool false

    echo ""
    echo "Trash original torrent files"
    defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

    echo ""
    echo "Hide the donate message"
    defaults write org.m0k.transmission WarningDonate -bool false

    echo ""
    echo "Hide the legal disclaimer"
    defaults write org.m0k.transmission WarningLegal -bool false
    break;;
  *) break;;
esac

###############################################################################
# Finish
###############################################################################

echo ""
pretty_print "All done! You still need to install apps from the App Store, activate licenses, and restore app preferences."
pretty_print "You should restart your computer for all changes to take effect."
