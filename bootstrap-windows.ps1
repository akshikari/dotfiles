# Run from PowerShell (no admin required for Scoop)
# Usage: Set-ExecutionPolicy Bypass -Scope Process; .\bootstrap-windows.ps1

Write-Host "==> Bootstrapping Windows dev environment..."

# Install Scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing Scoop..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Install everything from scoopfile
Write-Host "==> Adding Scoop buckets..."
Write-Host "==> Installing Scoop packages..."
scoop import "$HOME\dotfiles\scoopfile.json"

# Disable aria2 warning
scoop config aria2-warning-enabled false

# Neovim config — symlink to dotfiles
Write-Host "==> Setting up Neovim config..."
$nvimConfig = "$env:LOCALAPPDATA\nvim"
$nvimSource = "$HOME\dotfiles\config\nvim"
if (-not (Test-Path $nvimConfig)) {
    New-Item -ItemType SymbolicLink -Path $nvimConfig -Target $nvimSource | Out-Null
    Write-Host "  linked: $nvimConfig"
} else {
    Write-Host "  skipped: $nvimConfig already exists"
}

# PowerShell profile — create if needed and add vim alias
Write-Host "==> Setting up PowerShell profile..."
if (-not (Test-Path (Split-Path $PROFILE))) {
    New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force | Out-Null
}
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}
if (-not (Select-String -Path $PROFILE -Pattern "Set-Alias vim nvim" -Quiet)) {
    Add-Content -Path $PROFILE -Value "`nSet-Alias vim nvim"
    Write-Host "  added: vim -> nvim alias"
} else {
    Write-Host "  skipped: vim alias already present"
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
