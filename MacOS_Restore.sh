#!/usr/bin/env bash
# 
# Script for setting up MacOS Preferences after a new MacOS install
#
# Notes:
# This script will make changes to your computer,
# read through and make changes as needed.
# Install Xcode first from the app store before running the setup script. 
# Homebrew needs to access the Xcode libraries.



######################################
#   Helper Functions and Variables   #
######################################

# Colors
red='\033[0;31m'
green='\033[0;32m'
cyan='\033[0;36m'
end='\033[0m'

# Color-echo
#   arg $1 = message
#   arg $2 = Color
function cecho {
    echo "${2}${1}${end}"
    return
}

# Presents a colored message centered in the terminal window 
#   arg $1 = message
#   arg $2 = Color
function message {
    columns=$(tput cols)
    printf "$2"
    printf '%*s' "$columns" | tr ' ' "#"
    printf "#"
    printf '%*s' "$(($columns - 2))" | tr ' ' " "
    printf "#"

    IFS=';' 
    for line in $1; do
        rBuffer=$(((($columns - ${#line}) / 2) - 1))
        lBuffer=$(($columns - ${#line} - $rBuffer - 2))
        printf "#"
        printf '%*s' "$lBuffer" | tr ' ' " "
        printf "$line"
        printf '%*s' "$rBuffer" | tr ' ' " "
        printf "#\n"
    done
    printf "#"
    printf '%*s' "$(($columns - 2))" | tr ' ' " "
    printf "#"
    printf '%*s' "$columns" | tr ' ' "#"
    printf  "$end\n\n"
    IFS=''
}



#######################################
#   Disclaimer, get user permission   #
#######################################

message "DO NOT RUN THIS SCRIPT BEFORE YOU;READ IT THOROUGHLY. EDIT IT TO; SUIT YOUR SPECIFIC NEEDS" $red
cecho "Have you read through the script you're about to run and " $red
cecho "understood that it will make changes to your computer? (y/n)" $red
read -rp "⫸  " response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    continue
else
    cecho "Program Canceled" $red
    exit
fi



# Ask for the administrator password upfront
echo "Enter Sudo Password to Begin Setup:"
sudo -v
# Keep-alive: update existing `sudo` time stamp until the program has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Xcode command line tools
xcode-select --install

# Check if Homebrew is installed
if test ! $(which brew); then
    cecho "Installing homebrew..." $green
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update homebrew
brew update

PACKAGES=(
    coreutils
    gnu-tar
    gnu-indent
    gnu-which
    findutils
    bash
    git
    imagemagick
    wp-cli
    node
    npm
    python3
    wget
    emacs
)

cecho "Installing packages..." $green
for i in "${PACKAGES[@]}"; do brew install "$i"; done

cecho "Cleaning up..." $green
brew cleanup

CASKS=(
    google-chrome
    google-backup-and-sync
    visual-studio-code
    postman
    malwarebytes
    spotify
    slack
    spectacle
    macmediakeyforwarder
    xquartz
)

cecho "Installing cask apps..." $green
for i in "${CASKS[@]}"; do brew install --cask "$i"; done

cecho "Installing Python packages..." $green
brew postinstall python3
sudo -H pip3 install --upgrade pip
sudo -H pip3 install --upgrade setuptools

PYTHON_PACKAGES=(
    spotipy
    certifi
    ipython
    scipy
    numpy
    virtualenv
)
for i in "${PYTHON_PACKAGES[@]}"; do sudo -H pip3 install "$i"; done

cecho "Installing Node packages..." $green

NODE_PACKAGES=(
    express
    @material-ui/core
)
for i in "${NODE_PACKAGES[@]}"; do sudo npm install --save "$i"; done

sudo npm install -g create-react-app

cecho "Installing cocoapods" $green
sudo gem install cocoapods

cecho "Configuring git..." $green
# Set up git
git config --global user.name Michael
git config --global user.email 33352572+Mikeint0sh@users.noreply.github.com
git config --global credential.helper osxkeychain  #Caches credentials so you don't have to enter your username and password every time you push
echo '# Folder view configuration files\n.DS_Store\nDesktop.ini\n.AppleDouble\n.LSOverride\n' > ~/.gitignore  #Create a global gitignore
echo '# Thumbnail cache files\n._*\nThumbs.db\n' >> ~/.gitignore
echo '# Files that might appear on external disks\n.Spotlight-V100\n.Trashes\n.DocumentRevisions-V100\n.fseventsd\n.TemporaryItems\n.VolumeIcon.icns\n.com.apple.timemachine.donotpresent\n' >> ~/.gitignore
echo '# Directories potentially created on remote AFP share\n.AppleDB\n.AppleDesktop\nNetwork Trash Folder\nTemporary Items\n.apdisk\n' >> ~/.gitignore
echo '# Compiled Python files\n*.pyc\n' >> ~/.gitignore
echo '# Compiled C++ files\n*.out' >> ~/.gitignore
git config --global core.excludesfile ~/.gitignore



############################################
#   Settings found in System Preferences   #
############################################

cecho "Configuring OSX..." $green  #See https://github.com/mathiasbynens/dotfiles/blob/master/.macos for more

# Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# System Preferences > Sharing > Set computer name
sudo scutil --set ComputerName "Mikeintosh"
sudo scutil --set HostName "Mikeintosh"
sudo scutil --set LocalHostName "Mikeintosh"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "Mikeintosh"

# System Preferences > General > Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

# System Preferences > General > Click in the scrollbar to: Jump to the spot that's clicked
defaults write -globalDomain AppleScrollerPagingBehavior -bool true

# System Preferences > General > Sidebar icon size: Medium
defaults write -globalDomain NSTableViewDefaultSizeMode -int 2

# System Preferences > Desktop & Screen Saver > Start after: Never
defaults -currentHost write com.apple.screensaver idleTime -int 0

# System Preferences > Dock > Size:
defaults write com.apple.dock tilesize -int 80

# System Preferences > Dock > Magnification:
defaults write com.apple.dock magnification -bool true

# System Preferences > Dock > Size (magnified):
defaults write com.apple.dock largesize -int 100

# System Preferences > Dock > Automatically hide and show the Dock:
defaults write com.apple.dock autohide -bool true

# System Preferences > Dock > Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# System Preferences > Mission Controll > Automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# System Preferences > Trackpad > Tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# System Preferences > Trackpad > Enable "natural" scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# System Preferences > Energy Saver > Sleep the display after 10 minutes and system to sleep after 15 minutes
sudo pmset -a displaysleep 10 sleep 15

# System Preferences > Energy Saver > Set display to sleep after 5 minutes on battery
sudo pmset -b displaysleep 5

# System Preferences > Security & Privacy > Require password as soon as screensaver or sleep mode starts
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# System Preferences > Bluetooth and Sound
defaults write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
"/System/Library/CoreServices/Menu Extras/Volume.menu" \
"/System/Library/CoreServices/Menu Extras/TimeMachine.menu";

# System Preferences > Spotlight > Change indexing order and disable some search results
defaults write com.apple.spotlight orderedItems -array \
	'{"enabled" = 1;"name" = "MENU_DEFINITION";}' \
    '{"enabled" = 1;"name" = "APPLICATIONS";}' \
	'{"enabled" = 1;"name" = "DIRECTORIES";}' \
    '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
	'{"enabled" = 1;"name" = "CONTACT";}' \
	'{"enabled" = 1;"name" = "PDF";}' \
    '{"enabled" = 1;"name" = "DOCUMENTS";}' \
    '{"enabled" = 1;"name" = "IMAGES";}' \
	'{"enabled" = 1;"name" = "PRESENTATIONS";}' \
	'{"enabled" = 1;"name" = "SPREADSHEETS";}' \
	'{"enabled" = 1;"name" = "EVENT_TODO";}' \
	'{"enabled" = 1;"name" = "MENU_WEBSEARCH";}' \
	'{"enabled" = 1;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}' \
    '{"enabled" = 0;"name" = "FONTS";}' \
    '{"enabled" = 0;"name" = "MESSAGES";}' \
	'{"enabled" = 0;"name" = "BOOKMARKS";}' \
	'{"enabled" = 0;"name" = "MUSIC";}' \
	'{"enabled" = 0;"name" = "MOVIES";}' \
	'{"enabled" = 0;"name" = "SOURCE";}' \
	'{"enabled" = 0;"name" = "MENU_OTHER";}' \
	'{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
	'{"enabled" = 0;"name" = "MENU_EXPRESSION";}'
# Load new settings before rebuilding the index
killall mds > /dev/null 2>&1
# Make sure indexing is enabled for the main volume
sudo mdutil -i on / > /dev/null
# Rebuild the index from scratch
sudo mdutil -E / > /dev/null


############################################
#   Settings found in Finder Preferences   #
############################################

# Finder > Preferences > General > Show icons for external disks, removable media and connected servers on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder > Preferences > General > Set User's home directory as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Finder > Preferences > Advanced > Show wraning before removing from iCloud Drive
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false

# Finder > Preferences > Advanced > When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"


################################################
#   Settings not found in System Preferences   #
################################################

# Show battery percentage
# defaults write com.apple.menuextra.battery ShowPercent YES

# Wipe all app icons from the Dock (fast way to clear all the preplaced apps on the dock at once)
defaults write com.apple.dock persistent-apps -array

# Add apps in the order you want to the Dock
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Spotify.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Airmail.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Affinity Designer.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Affinity Photo.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Xcode.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Visual Studio Code.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0


###############################################################
#   TextEdit, AppStore, Messages, Google Chrome Preferences   #
###############################################################

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

# Disable automatic emoji substitution (i.e. use plain text smileys)
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

# Use the system-native print preview dialog
# defaults write com.google.Chrome DisablePrintPreview -bool true

# Expand the print dialog by default
# defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true


##########################################
#   Restore Files and Apps from Backup   #
##########################################

cecho "Restoring Files (this may take a few minutes)..." $green
cp ~/Desktop/MacOS\ Setup/Backup\ and\ Restore/.zsh_history ~/.zsh_history
cp ~/Desktop/MacOS\ Setup/Backup\ and\ Restore/.zshrc ~/.zshrc
touch ~/.hushlogin
# cp /Applications/Utilities/Terminal.app/Contents/Resources/Fonts/*.otf ~/Library/Fonts/  # Add SFMono to Fonts

# Add files not to be indexed by Spotlight
sh ~/Desktop/MacOS\ Setup/Backup\ and\ Restore/FilesAdded.sh

# Restart the apps modified for changes to take effect
cecho "\nSome apps need to be restarted, would you like to restart them now? y/n" $cyan
read -rp "⫸  " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    cecho "Restarting apps that were modified..." $green
    for app in "Activity Monitor" \
	    "Dock" \
	    "SystemUIServer" \
        "Finder" \
	    "Google Chrome" \
	    "Messages"; do
	    killall "$app" &> /dev/null
    done
fi

# Restart the computer for all changes to take effect
cecho "\nMacOS Setup Complete\nSome changes require the computer to restart, would you like to restart now? y/n" $cyan
read -rp "⫸  " response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    cecho "Restarting..." $green
    sudo shutdown -r now
else
    cecho "Program Complete" $green
    exit
fi
