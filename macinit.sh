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

current_shell=$(echo $SHELL)
if [[ "$current_shell" != *"/bash"* ]]; then
    echo -e "${YELLOW}Current shell: ${current_shell}${NC}"
    read -p "$(echo -e ${CYAN}Would you like to change it to bash? [Y/n]: ${NC})" change_shell
    change_shell=${change_shell:-Y}
    if [[ $change_shell =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Changing default shell to bash...${NC}"
        
        # Check if bash is in the list of allowed shells
        if ! grep -q "/bin/bash" /etc/shells; then
            echo -e "${YELLOW}Adding bash to allowed shells...${NC}"
            echo "/bin/bash" | sudo tee -a /etc/shells
        fi
        chsh -s /bin/bash
        echo -e "${GREEN}Default shell changed to bash. You'll need to restart your terminal for changes to take effect.${NC}"
    else
        echo -e "${YELLOW}Keeping current shell (${current_shell}).${NC}"
    fi
else
    echo -e "${GREEN}Bash is already your default shell.${NC}"
fi

# Enable Touch ID for sudo
echo -e "${YELLOW}Checking if Touch ID is enabled for sudo...${NC}"
if ! grep -q "pam_tid.so" /etc/pam.d/sudo; then
    read -p "$(echo -e ${CYAN}Would you like to enable Touch ID for sudo authentication? [Y/n]: ${NC})" enable_touchid
    enable_touchid=${enable_touchid:-Y}  # Default to Y if no input
    if [[ $enable_touchid =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Enabling Touch ID for sudo...${NC}"
        sudo sed -i '' '2i\
auth       sufficient     pam_tid.so
' /etc/pam.d/sudo
        echo -e "${GREEN}Touch ID enabled for sudo authentication!${NC}"
    else
        echo -e "${YELLOW}Skipping Touch ID configuration for sudo.${NC}"
    fi
else
    echo -e "${GREEN}Touch ID is already enabled for sudo authentication.${NC}"
fi

if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew is not installed.${NC}"
    read -p "$(echo -e ${CYAN}Would you like to install it? [Y/n]: ${NC})" install_brew
    install_brew=${install_brew:-Y}  # Default to Y if no input
    if [[ $install_brew =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
        eval "$(/opt/homebrew/bin/brew shellenv)"
        
        echo -e "${GREEN}Homebrew installation complete!${NC}"
    else
        echo -e "${YELLOW}Skipping Homebrew installation.${NC}"
    fi
else
    echo -e "${YELLOW}Homebrew is already installed.${NC}"
    read -p "$(echo -e ${CYAN}Would you like to update it? [Y/n]: ${NC})" update_brew
    update_brew=${update_brew:-Y}  # Default to Y if no input
    if [[ $update_brew =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Updating Homebrew...${NC}"
        brew update
        echo -e "${GREEN}Homebrew update complete!${NC}"
    else
        echo -e "${YELLOW}Skipping Homebrew update.${NC}"
    fi
fi

read -p "$(echo -e ${CYAN}Would you like to run brew doctor to check for issues? [Y/n]: ${NC})" run_doctor
run_doctor=${run_doctor:-Y}  # Default to Y if no input
if [[ $run_doctor =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Running brew doctor...${NC}"
    brew doctor
fi

# ==== MACOS SYSTEM PREFERENCES ====
read -p "$(echo -e ${CYAN}Would you like to set recommended macOS system preferences? [Y/n]: ${NC})" set_prefs
set_prefs=${set_prefs:-Y}
if [[ $set_prefs =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Setting recommended macOS system preferences...${NC}"

    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Show path bar in Finder
    defaults write com.apple.finder ShowPathbar -bool true

    # Show status bar in Finder
    defaults write com.apple.finder ShowStatusBar -bool true

    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # Disable the "Are you sure you want to open this application?" dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # Enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

    # Enable three finger drag
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

    # Set a faster keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Save screenshots to the desktop
    defaults write com.apple.screencapture location -string "$HOME/Desktop"

    # Save screenshots in PNG format
    defaults write com.apple.screencapture type -string "png"

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    # Restart affected applications
    for app in "Finder" "SystemUIServer"; do
        killall "${app}" &> /dev/null
    done

    echo -e "${GREEN}macOS preferences have been updated!${NC}"
fi

echo INSERT DOTFILES INTEGRATION HERE
echo INSERT DOTFILES INTEGRATION HERE
echo INSERT DOTFILES INTEGRATION HERE
echo INSERT DOTFILES INTEGRATION HERE


# ==== INSTALL FONTS ====
read -p "$(echo -e ${CYAN}Would you like to install developer fonts? [Y/n]: ${NC})" install_fonts
install_fonts=${install_fonts:-Y}
if [[ $install_fonts =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Installing developer fonts...${NC}"

    # Tap font caskroom
    brew tap homebrew/cask-fonts

    # Install fonts
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
fi

 Check if Bitwarden is installed and operational
if brew list --cask bitwarden &>/dev/null 2>&1; then
    echo -e "${GREEN}Bitwarden is installed and can be used to securely store/retrieve SSH keys.${NC}"
    echo -e "${YELLOW}You can:${NC}"
    echo -e "1. Store existing SSH keys in Bitwarden as secure attachments"
    echo -e "2. Retrieve SSH keys from Bitwarden when setting up a new machine"
    echo -e "3. Generate new SSH keys and then back them up to Bitwarden"
    echo -e ""
else
    echo -e "${YELLOW}Note: Bitwarden was selected for installation earlier and can be used to store SSH keys securely.${NC}"
    echo -e "${YELLOW}Make sure to finish the installation process and set up your Bitwarden account.${NC}"
    echo -e ""
fi

read -p "$(echo -e ${CYAN}Would you like to [G]enerate new SSH keys, [R]estore from Bitwarden, or [S]kip this step? [G/r/s]: ${NC})" ssh_option
ssh_option=${ssh_option:-G}

case "${ssh_option}" in
  [Gg]* )
    # Check if SSH keys already exist
    if [ -f ~/.ssh/id_ed25519 ]; then
        echo -e "${YELLOW}SSH keys already exist.${NC}"
        read -p "$(echo -e ${CYAN}Generate new keys anyway? This will overwrite existing keys. [y/N]: ${NC})" overwrite_keys
        overwrite_keys=${overwrite_keys:-N}
        if [[ ! $overwrite_keys =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}Keeping existing SSH keys.${NC}"
            break
        fi
    fi

    echo -e "${GREEN}Generating new SSH keys...${NC}"
    read -p "$(echo -e ${CYAN}Enter your email for the SSH key: ${NC})" ssh_email

    # Create .ssh directory if it doesn't exist
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    # Generate SSH key with Ed25519 algorithm
    ssh-keygen -t ed25519 -C "$ssh_email" -f ~/.ssh/id_ed25519

    # Start the ssh-agent
    eval "$(ssh-agent -s)"

    # Add SSH key to ssh-agent
    ssh-add ~/.ssh/id_ed25519

    # Copy the public key to clipboard
    pbcopy < ~/.ssh/id_ed25519.pub

    echo -e "${GREEN}SSH key generated and copied to clipboard!${NC}"
    echo -e "${YELLOW}Add this key to your GitHub account: https://github.com/settings/keys${NC}"

    # Remind to backup to Bitwarden
    echo -e "${YELLOW}IMPORTANT: Remember to backup your new SSH keys to Bitwarden:${NC}"
    echo -e "1. Open Bitwarden"
    echo -e "2. Create a new secure note"
    echo -e "3. Attach your private key (~/.ssh/id_ed25519) as a secure attachment"
    echo -e "4. Store your public key text in the note"
    ;;

  [Rr]* )
    echo -e "${YELLOW}To restore SSH keys from Bitwarden:${NC}"
    echo -e "1. Open your Bitwarden vault"
    echo -e "2. Find your SSH key secure note"
    echo -e "3. Download the private key attachment"
    echo -e "4. Copy the public key text"

    echo -e "${GREEN}Once you have your keys from Bitwarden:${NC}"

    # Create .ssh directory with correct permissions
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    read -p "$(echo -e ${CYAN}Enter the path to your downloaded private key: ${NC})" private_key_path
    if [ -f "$private_key_path" ]; then
        cp "$private_key_path" ~/.ssh/id_ed25519
        chmod 600 ~/.ssh/id_ed25519

        read -p "$(echo -e ${CYAN}Would you like to paste your public key now? [Y/n]: ${NC})" paste_public_key
        paste_public_key=${paste_public_key:-Y}
        if [[ $paste_public_key =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Paste your public key, then press Enter and Ctrl+D:${NC}"
            cat > ~/.ssh/id_ed25519.pub
            chmod 644 ~/.ssh/id_ed25519.pub
        fi

        # Start the ssh-agent
        eval "$(ssh-agent -s)"

        # Add SSH key to ssh-agent
        ssh-add ~/.ssh/id_ed25519

        echo -e "${GREEN}SSH keys restored and added to ssh-agent!${NC}"
    else
        echo -e "${RED}Private key file not found at specified path!${NC}"
        echo -e "${YELLOW}Please retrieve your SSH keys from Bitwarden and try again later.${NC}"
    fi
    ;;

  [Ss]* )
    echo -e "${YELLOW}Skipping SSH key setup.${NC}"
    ;;
esac


# ==== CLEANUP ====
read -p "$(echo -e ${CYAN}Would you like to clean up Homebrew packages? [Y/n]: ${NC})" cleanup
cleanup=${cleanup:-Y}
if [[ $cleanup =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Cleaning up...${NC}"
    brew cleanup
fi


echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}              Setup complete!              ${NC}"
echo -e "${BLUE}============================================${NC}"
