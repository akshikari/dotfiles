export ZPROFILE_LOADED=1

# Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Homebrew — handles Apple Silicon, Intel, and Linux
if [[ "$(uname -m)" == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"         # macOS Apple Silicon
elif [[ -f "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"            # macOS Intel
elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"  # Linux
fi


# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv &>/dev/null && eval "$(pyenv init -)"

# pipx
export PATH="$PATH:$HOME/.local/bin"
