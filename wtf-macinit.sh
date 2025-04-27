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
echo -e "${BLUE}       Setting up your MacBook...          ${NC}"
echo -e "${BLUE}============================================${NC}"

# Create a directory for the installation logs
mkdir -p ~/.setup_logs
LOGFILE=~/.setup_logs/setup_$(date +%Y%m%d-%H%M%S).log
exec > >(tee -a "$LOGFILE") 2>&1
echo -e "${GREEN}Logging setup to $LOGFILE${NC}"

# ==== SHELL SETUP ====
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

# ==== TOUCHID SETUP ====
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

# ==== HOMEBREW SETUP ====
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew is not installed.${NC}"
    read -p "$(echo -e ${CYAN}Would you like to install it? [Y/n]: ${NC})" install_brew
    install_brew=${install_brew:-Y}  # Default to Y if no input
    if [[ $install_brew =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Set PATH based on Apple silicon vs Intel Mac
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        echo -e "${GREEN}Homebrew installation complete!${NC}"
    else
        echo -e "${YELLOW}Skipping Homebrew installation.${NC}"
    fi
else
    echo -e "${GREEN}Homebrew is already installed.${NC}"
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

# ==== INSTALL ESSENTIAL TOOLS ====
read -p "$(echo -e ${CYAN}Would you like to install essential development tools? [Y/n]: ${NC})" install_essentials
install_essentials=${install_essentials:-Y}
if [[ $install_essentials =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Installing essential command line tools...${NC}"
    
    # Create a list of essential tools
    essential_tools=(
        "git"
        "vim"
        "tmux"
        "htop"
        "tree"
        "wget"
        "jq"
        "ripgrep"
        "fd"
        "fzf"
        "bat"
        "exa"
        "gh"         # GitHub CLI
    )
    
    # Install essential tools
    for tool in "${essential_tools[@]}"; do
        if ! brew list "$tool" &>/dev/null; then
            echo -e "${YELLOW}Installing $tool...${NC}"
            brew install "$tool"
        else
            echo -e "${GREEN}$tool is already installed.${NC}"
        fi
    done
fi

# ==== INSTALL DEVELOPMENT APPS ====
read -p "$(echo -e ${CYAN}Would you like to install development applications? [Y/n]: ${NC})" install_dev_apps
install_dev_apps=${install_dev_apps:-Y}
if [[ $install_dev_apps =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Installing development applications...${NC}"
    
    # Create a list of development apps
    dev_apps=(
        "visual-studio-code"
        "iterm2"
        "docker"
        "postman"
        "github"
    )
    
    # Install development apps
    for app in "${dev_apps[@]}"; do
        if ! brew list --cask "$app" &>/dev/null 2>&1; then
            echo -e "${YELLOW}Installing $app...${NC}"
            brew install --cask "$app"
        else
            echo -e "${GREEN}$app is already installed.${NC}"
        fi
    done
fi

# ==== INSTALL PRODUCTIVITY APPS ====
read -p "$(echo -e ${CYAN}Would you like to install productivity applications? [Y/n]: ${NC})" install_prod_apps
install_prod_apps=${install_prod_apps:-Y}
if [[ $install_prod_apps =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Installing productivity applications...${NC}"
    
    # Create a list of productivity apps
    prod_apps=(
        "rectangle"     # Window management
        "alfred"        # Spotlight replacement
        "1password"     # Password manager
        "notion"        # Notes and documents
        "slack"         # Team communication
    )
    
    # Install productivity apps
    for app in "${prod_apps[@]}"; do
        if ! brew list --cask "$app" &>/dev/null 2>&1; then
            echo -e "${YELLOW}Installing $app...${NC}"
            brew install --cask "$app"
        else
            echo -e "${GREEN}$app is already installed.${NC}"
        fi
    done
fi

# ==== INSTALL LANGUAGES AND FRAMEWORKS ====
read -p "$(echo -e ${CYAN}Would you like to install programming languages and frameworks? [Y/n]: ${NC})" install_langs
install_langs=${install_langs:-Y}
if [[ $install_langs =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Which languages would you like to install?${NC}"
    echo -e "1) Node.js"
    echo -e "2) Python"
    echo -e "3) Go"
    echo -e "4) Rust"
    echo -e "5) Ruby"
    echo -e "6) All of them"
    echo -e "0) None"
    
    read -p "$(echo -e ${CYAN}Enter your choices (comma-separated, e.g., 1,3,4): ${NC})" lang_choices
    
    # Parse choices
    if [[ $lang_choices == "6" ]]; then
        lang_choices="1,2,3,4,5"
    fi
    
    # Install Node.js
    if [[ $lang_choices == *"1"* ]] && [[ $lang_choices != "0" ]]; then
        echo -e "${YELLOW}Installing Node.js...${NC}"
        if ! brew list "node" &>/dev/null; then
            brew install node
            
            # Install some global npm packages
            npm install -g npm@latest
            npm install -g yarn
            npm install -g typescript
            npm install -g @angular/cli
            npm install -g create-react-app
            
            echo -e "${GREEN}Node.js and common packages installed!${NC}"
        else
            echo -e "${GREEN}Node.js is already installed.${NC}"
        fi
    fi
    
    # Install Python
    if [[ $lang_choices == *"2"* ]] && [[ $lang_choices != "0" ]]; then
        echo -e "${YELLOW}Installing Python...${NC}"
        if ! brew list "python" &>/dev/null; then
            brew install python
            
            # Install pip packages
            pip3 install --upgrade pip
            pip3 install pipenv
            pip3 install virtualenv
            pip3 install jupyter
            
            echo -e "${GREEN}Python and common packages installed!${NC}"
        else
            echo -e "${GREEN}Python is already installed.${NC}"
        fi
    fi
    
    # Install Go
    if [[ $lang_choices == *"3"* ]] && [[ $lang_choices != "0" ]]; then
        echo -e "${YELLOW}Installing Go...${NC}"
        if ! brew list "go" &>/dev/null; then
            brew install go
            echo -e "${GREEN}Go installed!${NC}"
        else
            echo -e "${GREEN}Go is already installed.${NC}"
        fi
    fi
    
    # Install Rust
    if [[ $lang_choices == *"4"* ]] && [[ $lang_choices != "0" ]]; then
        echo -e "${YELLOW}Installing Rust...${NC}"
        if ! command -v rustc &>/dev/null; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
            source "$HOME/.cargo/env"
            echo -e "${GREEN}Rust installed!${NC}"
        else
            echo -e "${GREEN}Rust is already installed.${NC}"
        fi
    fi
    
    # Install Ruby
    if [[ $lang_choices == *"5"* ]] && [[ $lang_choices != "0" ]]; then
        echo -e "${YELLOW}Installing Ruby...${NC}"
        if ! brew list "ruby" &>/dev/null; then
            brew install ruby
            
            # Add Ruby to PATH
            echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.bash_profile
            
            # Install common gems
            gem install bundler
            gem install rails
            
            echo -e "${GREEN}Ruby and common gems installed!${NC}"
        else
            echo -e "${GREEN}Ruby is already installed.${NC}"
        fi
    fi
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

# ==== INSTALL DOTFILES ====
read -p "$(echo -e ${CYAN}Would you like to set up dotfiles from your GitHub repo? [Y/n]: ${NC})" setup_dotfiles
setup_dotfiles=${setup_dotfiles:-Y}
if [[ $setup_dotfiles =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Setting up dotfiles from GitHub...${NC}"
    
    # Create a backup directory for existing dotfiles
    mkdir -p ~/.dotfiles_backup
    
    # Backup existing dotfiles
    for file in .bash_profile .bashrc .vimrc .gitconfig .tmux.conf; do
        if [ -f ~/$file ]; then
            echo -e "${YELLOW}Backing up existing $file to ~/.dotfiles_backup/${NC}"
            cp ~/$file ~/.dotfiles_backup/
        fi
    done
    
    # Clone dotfiles repo (using your repo URL)
    if [ ! -d ~/dotfiles ]; then
        git clone https://github.com/vhata/dotfiles.git ~/dotfiles
    else
        echo -e "${YELLOW}Dotfiles directory already exists. Pulling latest changes...${NC}"
        cd ~/dotfiles && git pull
    fi
    
    # Create symlinks for dotfiles
    for file in ~/dotfiles/.bash_profile ~/dotfiles/.bashrc ~/dotfiles/.vimrc ~/dotfiles/.gitconfig ~/dotfiles/.tmux.conf; do
        if [ -f $file ]; then
            filename=$(basename $file)
            echo -e "${YELLOW}Creating symlink for $filename${NC}"
            ln -sf $file ~/$filename
        fi
    done
    
    echo -e "${GREEN}Dotfiles setup complete!${NC}"
fi

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

# ==== INSTALL SSH KEYS ====
read -p "$(echo -e ${CYAN}Would you like to generate new SSH keys? [Y/n]: ${NC})" gen_ssh
gen_ssh=${gen_ssh:-Y}
if [[ $gen_ssh =~ ^[Yy]$ ]]; then
    # Check if SSH keys already exist
    if [ -f ~/.ssh/id_ed25519 ]; then
        echo -e "${YELLOW}SSH keys already exist.${NC}"
        read -p "$(echo -e ${CYAN}Generate new keys anyway? This will overwrite existing keys. [y/N]: ${NC})" overwrite_keys
        overwrite_keys=${overwrite_keys:-N}
        if [[ ! $overwrite_keys =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}Keeping existing SSH keys.${NC}"
            gen_ssh="n"
        fi
    fi
    
    if [[ $gen_ssh =~ ^[Yy]$ ]]; then
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
    fi
fi

# ==== RUN BREW DOCTOR ====
read -p "$(echo -e ${CYAN}Would you like to run brew doctor to check for issues? [Y/n]: ${NC})" run_doctor
run_doctor=${run_doctor:-Y}  # Default to Y if no input
if [[ $run_doctor =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Running brew doctor...${NC}"
    brew doctor
fi

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
echo -e "${GREEN}Log file: $LOGFILE${NC}"
echo -e "${YELLOW}You may need to restart your terminal or computer for all changes to take effect.${NC}"