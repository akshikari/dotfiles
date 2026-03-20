# Run from PowerShell (no admin required for Scoop)
# Usage: Set-ExecutionPolicy Bypass -Scope Process; .\bootstrap-windows.ps1

Write-Host "==> Bootstrapping Windows dev environment..."

# Install Scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing Scoop..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Add required buckets
Write-Host "==> Adding Scoop buckets..."
scoop bucket add extras
scoop bucket add main

# Install everything from scoopfile
Write-Host "==> Installing Scoop packages..."
scoop import "$HOME\dotfiles\scoopfile.json"

# Install WSL2 if not already present
if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing WSL2..."
    wsl --install
    Write-Host "==> WSL installed. Reboot, then run bootstrap-linux.sh inside WSL."
}

Write-Host ""
Write-Host "==> Windows host setup done!"
Write-Host "==> Next: open WSL and run: bash ~/dotfiles/bootstrap-linux.sh"
