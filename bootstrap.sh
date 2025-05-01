#!/bin/bash
set -e

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}       Bootstrapping...                  ${NC}"
echo -e "${BLUE}============================================${NC}"

if ! sudo -n true 2>/dev/null; then
    echo -e "${RED}This script requires sudo access to run properly.${NC}"
    echo -e "${YELLOW}Please run 'sudo -v' first to authenticate, then run this script again.${NC}"
    exit 1
fi

# Enable Touch ID for sudo
if ! grep -q "pam_tid.so" /etc/pam.d/sudo; then
    echo -e "${GREEN}Enabling Touch ID for sudo...${NC}"
    sudo sed -i '' '2i\
auth       sufficient     pam_tid.so
' /etc/pam.d/sudo
    echo -e "${GREEN}Touch ID enabled for sudo authentication!${NC}"
else
    echo -e "${GREEN}Touch ID is already enabled for sudo authentication.${NC}"
fi

if ! xcode-select -p &>/dev/null; then
  echo -e "${YELLOW}Installing XCode Command Line Tools...${NC}"
  xcode-select --install
  echo "After XCode Command Line Tools installation completes, run this script again."
  exit 0
fi

if ! command -v brew &>/dev/null; then
  echo -e "${YELLOW}Installing Homebrew...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo -e "${GREEN}Homebrew installed successfully.${NC}"
fi

echo -e "${YELLOW}Installing Google Drive...${NC}"
brew install google-drive
echo -e "${GREEN}Google Drive installed successfully.${NC}"



