#!/bin/bash
set -e

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if we have sudo access at the beginning
if ! sudo -n true 2>/dev/null; then
    echo -e "${RED}This script requires sudo access to run properly.${NC}"
    echo -e "${YELLOW}Please run 'sudo -v' first to authenticate, then run this script again.${NC}"
    exit 1
fi

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}       Setting up your MacBook...          ${NC}"
echo -e "${BLUE}============================================${NC}"

# TODO
# [ ] Change shell to bash

echo -e "${GREEN}Updating Homebrew...${NC}"
brew update
echo -e "${GREEN}Homebrew update complete!${NC}"
echo -e "${GREEN}Running brew doctor...${NC}"
brew doctor

if ! pgrep -x "Google Drive" > /dev/null; then
    echo -e "${YELLOW}Google Drive is not running.${NC}"
    echo -e "${YELLOW}Please run bootstrap.sh and try again.${NC}"
    exit 1
fi

# Check if SSH keys already exist
if [ -f ~/.ssh/id_ed25519 ]; then
    echo -e "${YELLOW}SSH keys already exist.${NC}"
    read -p "$(echo -e ${CYAN}Copy from google drive anyway? [y/N]: ${NC})" copy_from_google_drive
    copy_from_google_drive=${copy_from_google_drive:-N}
    if [[ ! $copy_from_google_drive =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Keeping existing SSH keys.${NC}"
        break
    fi

    # Copy SSH keys from Google Drive
    echo -e "${GREEN}Copying SSH keys from Google Drive...${NC}"
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    for id in id_ed25519 id_ed25519.pub id_rsa id_rsa.pub; do
        if [ -f ~/Google\ Drive/My\ Drive/dotfiles/ssh/$id ]; then
            cp ~/Google\ Drive/My\ Drive/dotfiles/ssh/$id ~/.ssh/$id
        fi
    done
    echo -e "${GREEN}SSH keys copied from Google Drive.${NC}"
fi

# Start the ssh-agent
eval "$(ssh-agent -s)"
ssh-add

update_macos_preferences() {
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    killall Finder SystemUIServer
}
# up
install_fonts() {
    echo -e "${GREEN}Installing developer fonts...${NC}"
    brew tap homebrew/cask-fonts
    fonts=(
        "font-fira-code"
        "font-jetbrains-mono"
        "font-cascadia-code"
        "font-hack-nerd-font"
        "font-source-code-pro"
    )

    for font in "${fonts[@]}"; do
        if ! brew list --cask "$font" &>/dev/null 2>&1; then
            echo -e "${YELLOW}Installing $font...${NC}"
            brew install --cask "$font"
        else
            echo -e "${GREEN}$font is already installed.${NC}"
        fi
    done

    echo -e "${GREEN}Fonts installation complete!${NC}"
}

if brew list --cask bitwarden &>/dev/null 2>&1; then
    echo -e "${GREEN}Bitwarden already installed.${NC}"
else
    echo -e "${YELLOW}Installing Bitwarden...${NC}"
    brew install --cask bitwarden
fi

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}              Setup complete!              ${NC}"
echo -e "${BLUE}============================================${NC}"
