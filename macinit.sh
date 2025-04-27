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

# Change default shell to bash if it's not already
current_shell=$(echo $SHELL)
if [[ "$current_shell" != *"/bash"* ]]; then
    echo -e "${YELLOW}Current shell: ${current_shell}${NC}"
    read -p "$(echo -e ${CYAN}Would you like to change it to bash? [Y/n]: ${NC})" change_shell
    change_shell=${change_shell:-Y}  # Default to Y if no input
    if [[ $change_shell =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Changing default shell to bash...${NC}"
        
        # Check if bash is in the list of allowed shells
        if ! grep -q "/bin/bash" /etc/shells; then
            echo -e "${YELLOW}Adding bash to allowed shells...${NC}"
            echo "/bin/bash" | sudo tee -a /etc/shells
        fi
        
        # Change the default shell to bash
        chsh -s /bin/bash
        
        echo -e "${GREEN}Default shell changed to bash. You'll need to restart your terminal for changes to take effect.${NC}"
    else
        echo -e "${YELLOW}Keeping current shell (${current_shell}).${NC}"
    fi
else
    echo -e "${GREEN}Bash is already your default shell.${NC}"
fi

# Check if Homebrew is already installed
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew is not installed.${NC}"
    read -p "$(echo -e ${CYAN}Would you like to install it? [Y/n]: ${NC})" install_brew
    install_brew=${install_brew:-Y}  # Default to Y if no input
    if [[ $install_brew =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH (assumes Apple Silicon)
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

# Optional: Run brew doctor
read -p "$(echo -e ${CYAN}Would you like to run brew doctor to check for issues? [Y/n]: ${NC})" run_doctor
run_doctor=${run_doctor:-Y}  # Default to Y if no input
if [[ $run_doctor =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Running brew doctor...${NC}"
    brew doctor
fi

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}              Setup complete!              ${NC}"
echo -e "${BLUE}============================================${NC}"