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
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Install CLI tools
echo "==> Installing Homebrew packages..."
brew bundle --file="$HOME/dotfiles/Brewfile"

# Install WezTerm (skip on WSL — it runs on the Windows host there)
if ! grep -qi microsoft /proc/version 2>/dev/null; then
  if ! command -v wezterm &>/dev/null; then
    echo "==> Installing WezTerm..."
    brew tap wezterm/wezterm-linuxbrew
    brew install wezterm
  fi
fi

# Window manager
# sudo apt-get install -y i3
# sudo apt-get install -y hyprland

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
  chsh -s "$ZSH_PATH"
fi

echo ""
echo "==> Done! Restart your terminal to apply all changes."
