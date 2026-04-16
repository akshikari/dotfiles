#!/bin/bash
set -e

echo "==> Bootstrapping Linux dev environment..."

# Detect environment — used to skip desktop/GUI installs in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=true
else
  IS_WSL=false
fi

# System prerequisites
sudo apt-get update
sudo apt-get install -y curl git build-essential procps file

# Install Homebrew (Linuxbrew)
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is in PATH (handles fresh installs and re-runs before shell profile is sourced)
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -f "$HOME/.linuxbrew/bin/brew" ]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi

# Install CLI tools
echo "==> Installing Homebrew packages..."
brew bundle --file="$HOME/dotfiles/Brewfile"

# Install Rust
if ! command -v cargo &>/dev/null; then
  echo "==> Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
source "$HOME/.cargo/env" 2>/dev/null || true

# Desktop environment — skip entirely on WSL
if [ "$IS_WSL" = false ]; then
  # Hyprland and Wayland desktop components
  if ! command -v hyprland &>/dev/null; then
    echo "==> Adding Hyprland PPA (community-maintained, tracks latest releases)..."
    sudo add-apt-repository -y ppa:cppiber/hyprland
    sudo apt-get update
    echo "==> Installing Hyprland and desktop components..."
    sudo apt-get install -y \
      hyprland \
      waybar \
      wofi \
      dunst \
      network-manager-gnome \
      blueman \
      xdg-desktop-portal-hyprland \
      xdg-desktop-portal-gtk \
      policykit-1-gnome \
      grim \
      slurp \
      wl-clipboard \
      pavucontrol \
      hyprlock \
      hypridle \
      hyprpaper \
      playerctl \
      cliphist
  fi

  # Ghostty terminal (PPA — officially endorsed by Ghostty project)
  if ! command -v ghostty &>/dev/null; then
    echo "==> Installing Ghostty..."
    sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
    sudo apt-get update
    sudo apt-get install -y ghostty
  fi
fi


# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install zsh-autosuggestions (oh-my-zsh plugin)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "==> Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Install nvm
if [ ! -d "$HOME/.nvm" ]; then
  echo "==> Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
fi

# Install fzf-git.sh
if [ ! -d "$HOME/fzf-git.sh" ]; then
  echo "==> Installing fzf-git.sh..."
  git clone https://github.com/junegunn/fzf-git.sh.git "$HOME/fzf-git.sh"
fi

# Install Google Cloud SDK
if ! command -v gcloud &>/dev/null && [ ! -d "$HOME/google-cloud-sdk" ]; then
  echo "==> Installing Google Cloud SDK..."
  curl -fsSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz | tar -xz -C "$HOME"
  "$HOME/google-cloud-sdk/install.sh" --quiet
fi

# Oracle Instant Client — WSL only (required for cx_Oracle)
if [ "$IS_WSL" = true ]; then
  INSTANTCLIENT_DIR="$HOME/oracle/instantclient_21_15"
  if [ ! -d "$INSTANTCLIENT_DIR" ]; then
    echo "==> Installing Oracle Instant Client 21.15..."
    # libaio is a runtime dependency of Instant Client
    # Ubuntu 22.04+ renamed the package to libaio1t64
    if apt-cache show libaio1 &>/dev/null; then
      sudo apt-get install -y libaio1
    else
      sudo apt-get install -y libaio1t64
    fi
    sudo apt-get install -y unzip
    mkdir -p "$HOME/oracle"
    ZIPFILE="instantclient-basic-linux.x64-21.15.0.0.0dbru.zip"
    curl -fsSL "https://download.oracle.com/otn_software/linux/instantclient/2115000/${ZIPFILE}" \
      -o "/tmp/${ZIPFILE}"
    unzip -q "/tmp/${ZIPFILE}" -d "$HOME/oracle"
    rm "/tmp/${ZIPFILE}"
    echo "==> Oracle Instant Client installed to ${INSTANTCLIENT_DIR}"
  else
    echo "==> Oracle Instant Client already installed, skipping"
  fi
fi

# Set up symlinks
echo "==> Setting up dotfile symlinks..."
bash "$HOME/dotfiles/setup.sh"

# Make zsh the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "==> Setting zsh as default shell (requires password)..."
  ZSH_PATH="$(which zsh)"
  if ! grep -qF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  sudo usermod -s "$ZSH_PATH" "$USER"
fi

echo ""
echo "==> Done! Restart your terminal to apply all changes."
