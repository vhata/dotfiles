#!/bin/bash
set -e

echo "Setting up your MacBook..."

# Change default shell to bash if it's not already
current_shell=$(echo $SHELL)
if [[ "$current_shell" != *"/bash"* ]]; then
    read -p "Your current shell is $current_shell. Would you like to change it to bash? (y/n): " change_shell
    if [[ $change_shell =~ ^[Yy]$ ]]; then
        echo "Changing default shell to bash..."
        
        # Check if bash is in the list of allowed shells
        if ! grep -q "/bin/bash" /etc/shells; then
            echo "Adding bash to allowed shells..."
            echo "/bin/bash" | sudo tee -a /etc/shells
        fi
        
        # Change the default shell to bash
        chsh -s /bin/bash
        
        echo "Default shell changed to bash. You'll need to restart your terminal for changes to take effect."
    else
        echo "Keeping current shell ($current_shell)."
    fi
else
    echo "Bash is already your default shell."
fi

# Check if Homebrew is already installed
if ! command -v brew &> /dev/null; then
    read -p "Homebrew is not installed. Would you like to install it? (y/n): " install_brew
    if [[ $install_brew =~ ^[Yy]$ ]]; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH (assumes Apple Silicon)
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
        eval "$(/opt/homebrew/bin/brew shellenv)"
        
        echo "Homebrew installation complete!"
    else
        echo "Skipping Homebrew installation."
    fi
else
    read -p "Homebrew is already installed. Would you like to update it? (y/n): " update_brew
    if [[ $update_brew =~ ^[Yy]$ ]]; then
        echo "Updating Homebrew..."
        brew update
        echo "Homebrew update complete!"
    else
        echo "Skipping Homebrew update."
    fi
fi

# Optional: Run brew doctor
read -p "Would you like to run brew doctor to check for issues? (y/n): " run_doctor
if [[ $run_doctor =~ ^[Yy]$ ]]; then
    brew doctor
fi

echo "Setup complete!"