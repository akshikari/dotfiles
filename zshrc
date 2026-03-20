# WSL doesn't always start as a login shell, so .zprofile may not be sourced.
# Force-source it here if we're in WSL and it hasn't been loaded yet.
if [[ -n "$WSL_DISTRO_NAME" && -z "$ZPROFILE_LOADED" ]]; then
  source "$HOME/.zprofile"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# OhMyZsh plugins
plugins=(
  git
  dotenv
  python
  npm
  docker
  nvm
  pipenv
  poetry
  postgres
  pyenv
  react-native
  zsh-autosuggestions
)

# macOS-specific oh-my-zsh plugins
if [[ "$OSTYPE" == "darwin"* ]]; then
  plugins+=(macos)
fi

# Set default editor
export EDITOR="nvim"

# XDG_CONFIG_HOME for Linux library compatibility
export XDG_CONFIG_HOME="$HOME/.config"

# History settings
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# NVM settings
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Python settings
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

# Golang settings
export PATH=$PATH:$HOME/go/bin

# macOS-specific settings
if [[ "$OSTYPE" == "darwin"* ]]; then
  # x86 homebrew (Rosetta)
  alias axbrew='arch -x86_64 /usr/local/homebrew/bin/brew'
  # CMake app bundle
  export PATH="/Applications/CMake.app/Contents/bin:$PATH"
  # llvm (for clang-tidy)
  export PATH="$(brew --prefix llvm)/bin:$PATH"
  # aerospace config alias
  alias vima="nvim $HOME/.config/aerospace/aerospace.toml"
fi

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
  . "$HOME/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
  . "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# Neovim aliases
export NVIMRC="$HOME/.config/nvim"
alias vim=nvim
alias vimn="nvim $NVIMRC/lua/2026_akumar/init.lua"
alias vimt="nvim $HOME/.tmux.conf"
alias vims="nvim $HOME/.config/starship.toml"
alias vimdot="nvim $HOME/dotfiles"

# Make it easy to edit zshrc
export ZSHRC=$HOME/.zshrc
alias vimz="nvim $ZSHRC"

# Start oh-my-zsh
source $ZSH/oh-my-zsh.sh

# zsh-syntax-highlighting (installed via brew)
if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &>/dev/null; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [ -f "/home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "/home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# pipx binaries
export PATH="$HOME/.local/bin:$PATH"

# pipx completions
fpath=(~/.zsh_completions $fpath)
autoload -U compinit && compinit
eval "$(register-python-argcomplete pipx)"

# ---- FZF -----
eval "$(fzf --zsh)"

# fzf theme (catppuccin-inspired)
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

source "$HOME/fzf-git.sh/fzf-git.sh"

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"                         "$@" ;;
    ssh)          fzf --preview 'dig {}'                                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview"                "$@" ;;
  esac
}

# Eza aliases
alias ls="eza -I='.git|.venv' --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias lst="ls --tree --level=3"
alias lsta="ls -I='' -a --tree --level=3"
alias lsa="ls -a"

# zoxide
eval "$(zoxide init --cmd cd zsh)"

# lazygit
alias lg="lazygit"

# terraform
alias tf="terraform"

# Starship prompt
export STARSHIP_CACHE=~/.starship/cache
eval "$(starship init zsh)"

# Docker CLI completions
if [ -d "$HOME/.docker/completions" ]; then
  fpath=($HOME/.docker/completions $fpath)
  autoload -Uz compinit
  compinit
fi
