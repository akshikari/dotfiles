# Run from PowerShell (no admin required for Scoop)
# Usage: Set-ExecutionPolicy Bypass -Scope Process; .\bootstrap-windows.ps1

Write-Host "==> Bootstrapping Windows dev environment..."

# Allow scripts to run (required for PowerShell profiles to load)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Install Scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing Scoop..."
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Install everything from scoopfile
Write-Host "==> Adding Scoop buckets..."
Write-Host "==> Installing Scoop packages..."
scoop import "$HOME\dotfiles\scoopfile.json"

# Disable aria2 warning
scoop config aria2-warning-enabled false

# Install Node.js LTS via nvm
Write-Host "==> Installing Node.js LTS via nvm..."
$env:NVM_HOME = "$HOME\scoop\apps\nvm\current"
$env:NVM_SYMLINK = "$HOME\scoop\apps\nvm\current\nodejs\nodejs"
nvm install lts
nvm use lts

# Neovim config — symlink to dotfiles
Write-Host "==> Setting up Neovim config..."
$nvimConfig = "$env:LOCALAPPDATA\nvim"
$nvimSource = "$HOME\dotfiles\config\nvim"
if (-not (Test-Path $nvimConfig)) {
    New-Item -ItemType Junction -Path $nvimConfig -Target $nvimSource | Out-Null
    Write-Host "  linked: $nvimConfig"
} else {
    Write-Host "  skipped: $nvimConfig already exists"
}

# WezTerm config — hard link to dotfiles (hard link avoids admin requirement for symlinks)
Write-Host "==> Setting up WezTerm config..."
$weztermConfig = "$HOME\.config\wezterm\wezterm.lua"
$weztermSource = "$HOME\dotfiles\wezterm.lua"
$weztermDir = Split-Path $weztermConfig
if (-not (Test-Path $weztermDir)) {
    New-Item -ItemType Directory -Path $weztermDir -Force | Out-Null
}
if (-not (Test-Path $weztermConfig)) {
    New-Item -ItemType HardLink -Path $weztermConfig -Target $weztermSource | Out-Null
    Write-Host "  linked: $weztermConfig"
} else {
    Write-Host "  skipped: $weztermConfig already exists"
}

# GlazeWM config — hard link to dotfiles
Write-Host "==> Setting up GlazeWM config..."
$glazeConfig = "$HOME\.glzr\glazewm\config.yaml"
$glazeSource = "$HOME\dotfiles\config\glazewm\config.yaml"
$glazeDir = Split-Path $glazeConfig
if (-not (Test-Path $glazeDir)) {
    New-Item -ItemType Directory -Path $glazeDir -Force | Out-Null
}
if (-not (Test-Path $glazeConfig)) {
    New-Item -ItemType HardLink -Path $glazeConfig -Target $glazeSource | Out-Null
    Write-Host "  linked: $glazeConfig"
} else {
    Write-Host "  skipped: $glazeConfig already exists"
}

# YASB config — hard link to dotfiles
Write-Host "==> Setting up YASB config..."
$yasbDir = "$HOME\.config\yasb"
if (-not (Test-Path $yasbDir)) {
    New-Item -ItemType Directory -Path $yasbDir -Force | Out-Null
}
foreach ($file in @("config.yaml", "styles.css")) {
    $target = "$yasbDir\$file"
    $source = "$HOME\dotfiles\config\yasb\$file"
    if (-not (Test-Path $target)) {
        New-Item -ItemType HardLink -Path $target -Target $source | Out-Null
        Write-Host "  linked: $target"
    } else {
        Write-Host "  skipped: $target already exists"
    }
}

# PowerShell profile — add vim alias to both PS 5.1 and PS 7 profiles
Write-Host "==> Setting up PowerShell profile..."
$profiles = @(
    "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
)
foreach ($prof in $profiles) {
    $dir = Split-Path $prof
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if (-not (Test-Path $prof)) {
        New-Item -ItemType File -Path $prof -Force | Out-Null
    }
    if (-not (Select-String -Path $prof -Pattern "Set-Alias vim nvim" -Quiet)) {
        Add-Content -Path $prof -Value "`nSet-Alias vim nvim"
        Write-Host "  added vim alias to: $prof"
    } else {
        Write-Host "  skipped: vim alias already in $prof"
    }
}

# Install WSL2 if not already present
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing WSL2..."
    wsl --install
    Write-Host "==> WSL installed. Reboot, then run bootstrap-linux.sh inside WSL."
}

Write-Host ""
Write-Host "==> Windows host setup done!"
Write-Host "==> Next: open WSL and run: bash ~/dotfiles/bootstrap-linux.sh"
