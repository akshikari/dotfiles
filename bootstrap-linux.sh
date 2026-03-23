#!/bin/bash
set -e

echo "==> Bootstrapping Linux dev environment..."

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

# Install WezTerm (skip on WSL — it runs on the Windows host there)
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  if ! command -v wezterm &>/dev/null; then
    echo "==> Installing WezTerm..."
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo apt-get update
    sudo apt-get install -y wezterm
  fi
fi

# Install Hyprland and companion tools (skip on WSL)
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  echo "==> Installing Hyprland stack..."

  # Add cppiber PPA for up-to-date Hyprland packages
  sudo add-apt-repository -y ppa:cppiber/hyprland
  sudo apt-get update

  # Hyprland core
  sudo apt-get install -y \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    hypridle \
    hyprlock \
    hyprsunset

  # Companion tools
  sudo apt-get install -y \
    waybar \
    sway-notification-center \
    wl-clipboard \
    cliphist \
    grim \
    slurp \
    swappy \
    playerctl \
    pavucontrol \
    polkit-kde-agent-1 \
    rofi \
    network-manager-gnome \
    blueman \
    gnome-keyring \
    thunar \
    btop

  # Install swww (wallpaper daemon) from GitHub releases
  if ! command -v swww &>/dev/null; then
    echo "==> Installing swww..."
    SWWW_VER=$(curl -s https://api.github.com/repos/LGFae/swww/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    curl -sSL "https://github.com/LGFae/swww/releases/download/${SWWW_VER}/swww-x86_64-unknown-linux-musl.tar.gz" \
      | tar -xz -C /tmp swww swww-daemon
    sudo mv /tmp/swww /tmp/swww-daemon /usr/local/bin/
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
