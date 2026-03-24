# dotfiles

Personal dev environment configuration for macOS, Linux, and Windows (WSL).

## What's included

| File/Dir               | Target                                        | Platform        |
| ---------------------- | --------------------------------------------- | --------------- |
| `zshrc`                | `~/.zshrc`                                    | all             |
| `zshenv`               | `~/.zshenv`                                   | all             |
| `zprofile`             | `~/.zprofile`                                 | all             |
| `tmux.conf`            | `~/.tmux.conf`                                | all             |
| `wezterm.lua`          | `~/.wezterm.lua`                              | all             |
| `gitconfig`            | `~/.gitconfig`                                | all             |
| `config/nvim/`         | `~/.config/nvim/`                             | all             |
| `config/starship.toml` | `~/.config/starship.toml`                     | all             |
| `config/lazygit/`      | `~/.config/lazygit/`                          | all             |
| `config/bat/`          | `~/.config/bat/`                              | all             |
| `config/ghostty/`      | `~/.config/ghostty/`                          | macOS + Linux   |
| `config/aerospace/`    | `~/.config/aerospace/`                        | macOS only      |
| `config/hypr/`         | `~/.config/hypr/`                             | Linux only      |
| `config/waybar/`       | `~/.config/waybar/`                           | Linux only      |
| `config/wofi/`         | `~/.config/wofi/`                             | Linux only      |

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
3. Install all CLI tools via `Brewfile`
4. Install Hyprland + Wayland components and Ghostty (skipped on WSL)
5. Install oh-my-zsh and zsh plugins
6. Install nvm, fzf-git.sh, and Google Cloud SDK
7. Create all symlinks via `setup.sh`
8. Set zsh as the default shell (`chsh`)

> **WSL:** Desktop installs (Hyprland, Ghostty, Wayland tooling) are automatically skipped. `.zprofile` is force-sourced from `.zshrc` when running in WSL.

### Window management

[Hyprland](https://hyprland.org) is installed automatically on non-WSL Ubuntu. Config lives in `~/.config/hypr/` (symlinked from `config/hypr/`).

Workspace layout mirrors the macOS AeroSpace config — same letter/number scheme, same keybindings (`alt+<key>` to switch, `alt+shift+<key>` to move windows).

#### NVIDIA suspend fix (post-bootstrap, NVIDIA GPUs only)

Hyprland loses its GPU connection if the compositor is still running when the NVIDIA driver suspends. Fix with two systemd units that freeze/thaw Hyprland around suspend:

```bash
sudo tee /etc/systemd/system/hyprland-suspend.service << 'EOF'
[Unit]
Description=Freeze Hyprland before NVIDIA suspend
Before=sleep.target
Before=nvidia-suspend.service

[Service]
Type=oneshot
ExecStart=/home/$USER/.config/hypr/scripts/nvidia-suspend.sh suspend

[Install]
WantedBy=sleep.target
EOF

sudo tee /etc/systemd/system/hyprland-resume.service << 'EOF'
[Unit]
Description=Unfreeze Hyprland after NVIDIA resume
After=nvidia-resume.service

[Service]
Type=oneshot
ExecStart=/home/$USER/.config/hypr/scripts/nvidia-suspend.sh resume

[Install]
WantedBy=sleep.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable hyprland-suspend.service hyprland-resume.service
```

> Do **not** use `--now` — these services must only run on suspend/resume events, not on demand.

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
