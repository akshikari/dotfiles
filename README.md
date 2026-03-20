# dotfiles

Personal dev environment configuration for macOS, Linux, and Windows (WSL).

## What's included

| File/Dir               | Target                              |
| ---------------------- | ----------------------------------- |
| `zshrc`                | `~/.zshrc`                          |
| `zshenv`               | `~/.zshenv`                         |
| `zprofile`             | `~/.zprofile`                       |
| `tmux.conf`            | `~/.tmux.conf`                      |
| `wezterm.lua`          | `~/.wezterm.lua`                    |
| `gitconfig`            | `~/.gitconfig`                      |
| `config/nvim/`         | `~/.config/nvim/`                   |
| `config/starship.toml` | `~/.config/starship.toml`           |
| `config/aerospace/`    | `~/.config/aerospace/` (macOS only) |
| `config/lazygit/`      | `~/.config/lazygit/`                |
| `config/bat/`          | `~/.config/bat/`                    |

All configs are managed as symlinks back to this repo via `setup.sh`. Edit files here — changes are immediately live.

---

## macOS

### Prerequisites

- Xcode Command Line Tools: `xcode-select --install`

### Setup

```bash
git clone https://github.com/akshikari/dotfiles ~/dotfiles
bash ~/dotfiles/bootstrap-mac.sh
```

This will:

1. Install Homebrew
2. Install all CLI tools via `Brewfile`
3. Install macOS apps via `Brewfile.mac` (WezTerm, Aerospace)
4. Install oh-my-zsh and zsh plugins
5. Install nvm, fzf-git.sh, and Google Cloud SDK
6. Create all symlinks via `setup.sh`

### Window management

Aerospace is installed via `Brewfile.mac`. Config is at `~/.config/aerospace/aerospace.toml`.

---

## Linux / WSL (Ubuntu/Debian)

### Setup

```bash
git clone https://github.com/akshikari/dotfiles ~/dotfiles
bash ~/dotfiles/bootstrap-linux.sh
```

This will:

1. Install system prerequisites via `apt`
2. Install Homebrew (Linuxbrew)
3. Install all CLI tools via `Brewfile` + WezTerm
4. Install oh-my-zsh and zsh plugins
5. Install nvm, fzf-git.sh, and Google Cloud SDK
6. Create all symlinks via `setup.sh`
7. Set zsh as the default shell (`chsh`)

> **WSL note:** The bootstrap script handles the case where WSL doesn't start as a login shell. `.zprofile` is force-sourced from `.zshrc` when running in WSL.

### Window management

Uncomment your preferred WM in `bootstrap-linux.sh` before running:

- **i3** — X11 environments
- **Hyprland** — Wayland environments (recommended for new Ubuntu setups)

---

## Windows (host)

The Windows bootstrap sets up the host environment (WezTerm, GlazeWM, yasb). The actual dev environment runs inside WSL — run `bootstrap-linux.sh` there after.

### Prerequisites

- PowerShell 5.1+
- WSL2 (the bootstrap will install it if missing)

### Setup

```powershell
git clone https://github.com/akshikari/dotfiles $HOME\dotfiles
Set-ExecutionPolicy Bypass -Scope Process
.\dotfiles\bootstrap-windows.ps1
```

This will:

1. Install Scoop
2. Install all tools via `scoopfile.json` (WezTerm, GlazeWM, yasb, dev CLI tools)
3. Install WSL2 if not already present

After rebooting (if WSL was just installed):

```bash
# Inside WSL
bash ~/dotfiles/bootstrap-linux.sh
```

### Window management

GlazeWM and yasb are installed via Scoop. Configs live in:

- `~/dotfiles/windows/glazewm/`
- `~/dotfiles/windows/yasb/`

---

## Post-bootstrap manual steps

These are intentionally not automated as they vary per machine.

### Git identity

The `gitconfig` uses `includeIf` to load identity based on project directory. Create whichever files apply to the machine:

```bash
# Personal machine
cat > ~/.gitconfig-personal << 'EOF'
[user]
	name = Abhi Kumar
	email = user@personal.com
EOF

# Work machine
cat > ~/.gitconfig-work << 'EOF'
[user]
	name = Abhi Kumar
	email = abhinav@company.com
EOF
```

Then make sure your repos live in the corresponding directories (`~/personal/` and/or `~/work/`). Adjust the paths in `gitconfig` if your structure is different.

> These files are not tracked in this repo — never commit credentials.

---

## Re-running setup

The symlink script is idempotent — safe to re-run any time:

```bash
bash ~/dotfiles/setup.sh
```

## Adding a new config

1. Copy the file/dir into `~/dotfiles/` (or `~/dotfiles/config/`)
2. Add a `link` line to `setup.sh`
3. Run `bash ~/dotfiles/setup.sh`
4. Commit and push
