#!/bin/bash
set -e

DOTFILES="$HOME/dotfiles"
CONFIG="$HOME/.config"

# Creates a symlink, backing up any existing non-symlink file.
# Removes existing symlinks first — ln -sf behaves unexpectedly when the
# destination is already a symlink pointing to a directory (places the new
# symlink inside it instead of replacing it).
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    echo "  backing up: $dst → $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  echo "  linked: $dst"
}

echo "==> Setting up dotfile symlinks..."

# Shell
link "$DOTFILES/zshrc"       "$HOME/.zshrc"
link "$DOTFILES/zshenv"      "$HOME/.zshenv"
link "$DOTFILES/zprofile"    "$HOME/.zprofile"

# Terminal
link "$DOTFILES/tmux.conf"   "$HOME/.tmux.conf"
link "$DOTFILES/wezterm.lua" "$HOME/.wezterm.lua"

# Git
link "$DOTFILES/gitconfig"   "$HOME/.gitconfig"

# Config directories
link "$DOTFILES/config/nvim"          "$CONFIG/nvim"
link "$DOTFILES/config/starship.toml" "$CONFIG/starship.toml"
link "$DOTFILES/config/lazygit"       "$CONFIG/lazygit"
link "$DOTFILES/config/bat"           "$CONFIG/bat"

# macOS-only
if [[ "$(uname -s)" == "Darwin" ]]; then
  link "$DOTFILES/config/aerospace" "$CONFIG/aerospace"
fi

# Linux (native only, not WSL)
if [[ "$(uname -s)" == "Linux" ]] && ! grep -qi microsoft /proc/version 2>/dev/null; then
  link "$DOTFILES/config/hypr"    "$CONFIG/hypr"
  link "$DOTFILES/config/waybar"  "$CONFIG/waybar"
  link "$DOTFILES/config/wofi"    "$CONFIG/wofi"
fi


echo "==> Done!"
