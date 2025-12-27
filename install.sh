#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCAL_BIN_DIR="$HOME/.local/bin"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# OS and architecture detection
OS=""
ARCH=""
HOMEBREW_PREFIX=""

# Function to print colored messages
print_info() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Detect OS and architecture
detect_platform() {
    ARCH=$(uname -m)

    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        if [[ "$ARCH" == "arm64" ]]; then
            print_info "Detected macOS (Apple Silicon)"
            HOMEBREW_PREFIX="/opt/homebrew"
        else
            print_info "Detected macOS (Intel)"
            HOMEBREW_PREFIX="/usr/local"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/debian_version ]]; then
            OS="debian"
            print_info "Detected Debian/Ubuntu Linux ($ARCH)"
        else
            print_error "Unsupported Linux distribution. This script supports Debian/Ubuntu."
            exit 1
        fi
    else
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

# Check and install Homebrew (macOS only)
install_homebrew() {
    if [[ "$OS" != "macos" ]]; then
        return
    fi

    if command -v brew &>/dev/null; then
        print_success "Homebrew already installed"
        return
    fi

    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    if [[ -f "${HOMEBREW_PREFIX}/bin/brew" ]]; then
        eval "$("${HOMEBREW_PREFIX}/bin/brew" shellenv)"
        print_success "Homebrew installed successfully"
    else
        print_error "Homebrew installation failed"
        exit 1
    fi
}

# Update apt and install packages (Debian only)
install_debian_packages() {
    if [[ "$OS" != "debian" ]]; then
        return
    fi

    print_info "Updating apt..."
    sudo apt update

    local packages=(
        "fish"
        "tmux"
        "neovim"
        "bat"
        "fd-find"
        "ripgrep"
        "fzf"
        "git-delta"
        "zoxide"
        "golang-go"
        "python3"
        "python3-pip"
        "curl"
        "git"
        "build-essential"
        "luarocks"
    )

    print_info "Installing packages via apt..."
    for package in "${packages[@]}"; do
        if dpkg -l "$package" &>/dev/null; then
            print_warning "$package already installed"
        else
            sudo apt install -y "$package" && print_success "Installed $package"
        fi
    done

    # Install starship
    if command -v starship &>/dev/null; then
        print_warning "starship already installed"
    else
        print_info "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        print_success "Installed starship"
    fi

    # Install eza (modern ls replacement)
    if command -v eza &>/dev/null; then
        print_warning "eza already installed"
    else
        print_info "Installing eza..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza && print_success "Installed eza"
    fi

    # Install lazygit
    if command -v lazygit &>/dev/null; then
        print_warning "lazygit already installed"
    else
        print_info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        # Map architecture names for lazygit releases
        local lazygit_arch="$ARCH"
        if [[ "$ARCH" == "aarch64" ]]; then
            lazygit_arch="arm64"
        fi
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${lazygit_arch}.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
        print_success "Installed lazygit"
    fi

    # Create symlinks for different binary names on Debian
    if [[ ! -L /usr/local/bin/bat ]] && command -v batcat &>/dev/null; then
        sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
        print_success "Created bat symlink"
    fi

    if [[ ! -L /usr/local/bin/fd ]] && command -v fdfind &>/dev/null; then
        sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
        print_success "Created fd symlink"
    fi

    # Install Nerd Font
    print_info "Installing Hack Nerd Font..."
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    if [[ -f "$font_dir/HackNerdFont-Regular.ttf" ]]; then
        print_warning "Hack Nerd Font already installed"
    else
        curl -fLo "$font_dir/Hack.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
        unzip -o "$font_dir/Hack.zip" -d "$font_dir"
        rm "$font_dir/Hack.zip"
        fc-cache -fv
        print_success "Installed Hack Nerd Font"
    fi
}

# Install required packages (macOS via Homebrew)
install_packages() {
    if [[ "$OS" != "macos" ]]; then
        return
    fi

    print_info "Installing required packages..."

    local packages=(
        "fish"
        "tmux"
        "neovim"
        "bat"
        "starship"
        "fd"
        "ripgrep"
        "fzf"
        "git-delta"
        "zoxide"
        "eza"
        "go"
        "lazygit"
        "luarocks"
        "python"
    )

    local casks=(
        "ghostty"
        "orbstack"
    )

    print_info "Installing formulae..."
    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            print_warning "$package already installed"
        else
            brew install "$package" && print_success "Installed $package"
        fi
    done

    print_info "Installing casks..."
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            print_warning "$cask already installed"
        else
            brew install --cask "$cask" && print_success "Installed $cask"
        fi
    done

    # Install Nerd Font
    print_info "Installing Hack Nerd Font..."
    brew tap homebrew/cask-fonts 2>/dev/null || true
    if brew list --cask font-hack-nerd-font &>/dev/null; then
        print_warning "Hack Nerd Font already installed"
    else
        brew install --cask font-hack-nerd-font && print_success "Installed Hack Nerd Font"
    fi
}

# Backup existing configs
backup_existing() {
    print_info "Backing up existing configurations..."

    local configs=(
        "ghostty"
        "fish"
        "nvim"
        "starship"
        "tmux"
        "bat"
        "lazygit"
        "tmux-sessionizer"
        "alacritty"
        "kitty"
    )

    local backed_up=false

    for config in "${configs[@]}"; do
        if [[ -e "$CONFIG_DIR/$config" && ! -L "$CONFIG_DIR/$config" ]]; then
            mkdir -p "$BACKUP_DIR"
            mv "$CONFIG_DIR/$config" "$BACKUP_DIR/"
            print_success "Backed up $config to $BACKUP_DIR"
            backed_up=true
        fi
    done

    # Backup bin scripts
    if [[ -e "$LOCAL_BIN_DIR/tmux-sessionizer" && ! -L "$LOCAL_BIN_DIR/tmux-sessionizer" ]]; then
        mkdir -p "$BACKUP_DIR/bin"
        mv "$LOCAL_BIN_DIR/tmux-sessionizer" "$BACKUP_DIR/bin/"
        print_success "Backed up tmux-sessionizer to $BACKUP_DIR/bin"
        backed_up=true
    fi

    if [[ -e "$LOCAL_BIN_DIR/tmux-windowizer" && ! -L "$LOCAL_BIN_DIR/tmux-windowizer" ]]; then
        mkdir -p "$BACKUP_DIR/bin"
        mv "$LOCAL_BIN_DIR/tmux-windowizer" "$BACKUP_DIR/bin/"
        print_success "Backed up tmux-windowizer to $BACKUP_DIR/bin"
        backed_up=true
    fi

    if [[ "$backed_up" == false ]]; then
        print_info "No existing configurations to backup"
    fi
}

# Create necessary directories
create_directories() {
    print_info "Creating necessary directories..."
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$LOCAL_BIN_DIR"
    mkdir -p "$CONFIG_DIR/tmux-sessionizer"
    print_success "Directories created"
}

# Symlink configuration files
symlink_configs() {
    print_info "Creating symlinks..."

    # Config directories
    local configs=(
        "ghostty"
        "fish"
        "nvim"
        "starship"
        "tmux"
        "bat"
        "lazygit"
        "alacritty"
        "kitty"
    )

    for config in "${configs[@]}"; do
        if [[ -L "$CONFIG_DIR/$config" ]]; then
            print_warning "$config already symlinked"
        else
            ln -sf "$DOTFILES_DIR/$config" "$CONFIG_DIR/$config"
            print_success "Symlinked $config"
        fi
    done

    # Bin scripts
    if [[ -L "$LOCAL_BIN_DIR/tmux-sessionizer" ]]; then
        print_warning "tmux-sessionizer already symlinked"
    else
        ln -sf "$DOTFILES_DIR/bin/tmux-sessionizer" "$LOCAL_BIN_DIR/tmux-sessionizer"
        chmod +x "$DOTFILES_DIR/bin/tmux-sessionizer"
        print_success "Symlinked tmux-sessionizer"
    fi

    if [[ -L "$LOCAL_BIN_DIR/tmux-windowizer" ]]; then
        print_warning "tmux-windowizer already symlinked"
    else
        ln -sf "$DOTFILES_DIR/bin/tmux-windowizer" "$LOCAL_BIN_DIR/tmux-windowizer"
        chmod +x "$DOTFILES_DIR/bin/tmux-windowizer"
        print_success "Symlinked tmux-windowizer"
    fi

    # Create tmux-sessionizer config if it doesn't exist
    if [[ ! -f "$CONFIG_DIR/tmux-sessionizer/config" ]]; then
        cp "$DOTFILES_DIR/tmux-sessionizer/config.example" "$CONFIG_DIR/tmux-sessionizer/config"
        print_success "Created tmux-sessionizer config"
        print_warning "Edit $CONFIG_DIR/tmux-sessionizer/config to customize your project paths"
    fi
}

# Install Fish shell plugins
install_fish_plugins() {
    print_info "Setting up Fish shell..."

    # Set Fish as default shell
    local fish_path
    fish_path=$(command -v fish)

    if ! grep -q "$fish_path" /etc/shells; then
        print_info "Adding Fish to /etc/shells..."
        echo "$fish_path" | sudo tee -a /etc/shells
    fi

    if [[ "$SHELL" != "$fish_path" ]]; then
        print_info "Setting Fish as default shell..."
        chsh -s "$fish_path"
        print_success "Fish set as default shell (restart terminal to take effect)"
    fi

    # Install oh-my-fish
    if [[ ! -d "$HOME/.local/share/omf" ]]; then
        print_info "Installing oh-my-fish..."
        curl -fsSL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
        print_success "oh-my-fish installed"
    else
        print_warning "oh-my-fish already installed"
    fi

    # Install fisher
    print_info "Installing fisher..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" 2>/dev/null || true

    # Install fish plugins
    print_info "Installing fish plugins..."
    fish -c "fisher install jorgebucaran/nvm.fish" 2>/dev/null || true
    print_success "Fish plugins installed"
}

# Install Node.js via nvm
install_node() {
    print_info "Installing Node.js..."

    # Check if nvm.fish is available
    if ! fish -c "type -q nvm" 2>/dev/null; then
        print_warning "nvm.fish not available yet, Node.js installation will be skipped"
        print_info "After restarting your shell, run: nvm install lts"
        return
    fi

    # Install latest LTS version of Node
    print_info "Installing Node.js LTS version..."
    fish -c "nvm install lts" 2>/dev/null || {
        print_warning "Could not install Node.js automatically"
        print_info "After restarting your shell, run: nvm install lts"
        return
    }

    # Set LTS as default
    fish -c "nvm use lts" 2>/dev/null || true

    print_success "Node.js LTS installed"
}

# Install Tmux Plugin Manager
install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        print_warning "TPM already installed"
    else
        print_info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        print_success "TPM installed"
        print_info "Press prefix + I in tmux to install plugins"
    fi
}

# Build bat cache
build_bat_cache() {
    print_info "Building bat theme cache..."
    bat cache --build &>/dev/null
    print_success "Bat cache built"
}

# Main installation
main() {
    echo ""
    echo "╔════════════════════════════════════════════╗"
    echo "║     Dotfiles Installation Script           ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""

    detect_platform
    install_homebrew
    install_packages
    install_debian_packages
    backup_existing
    create_directories
    symlink_configs
    install_fish_plugins
    install_node
    install_tpm
    build_bat_cache

    echo ""
    print_success "Installation complete!"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: exec fish"
    echo "  2. If Node.js wasn't installed automatically, run: nvm install lts"
    echo "  3. Open tmux and press prefix + I to install plugins"
    echo "  4. Edit $CONFIG_DIR/tmux-sessionizer/config to add your project paths"
    echo "  5. Run 'make theme THEME=<name>' to switch themes (catppuccin, rose-pine, gruvbox)"
    echo ""

    if [[ -d "$BACKUP_DIR" ]]; then
        print_warning "Previous configs backed up to: $BACKUP_DIR"
    fi
}

main "$@"
