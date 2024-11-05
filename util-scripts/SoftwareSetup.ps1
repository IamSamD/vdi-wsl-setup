$ErrorActionPreference = 'Stop'

# Install tfenv
if (-not(Test-Path "~/.tfenv")) {
    Write-Host "Installing tfenv..." -ForegroundColor Cyan
    $output = git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error cloning tfenv: $Output"
        $LASTEXITCODE = 0
        exit 1
    }
    Write-Host "tfenv cloned successfully`n" -ForegroundColor Green

    Write-Host "Adding tfenv to path..." -ForegroundColor Cyan
    $Output = echo 'export PATH=$PATH:$HOME/.tfenv/bin' >> ~/.bashrc
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error writing to .bashrc: $Output"
        $LASTEXITCODE = 0
        exit 1
    }
    Write-Host "tfenv installed and configured successfully`n" -ForegroundColor Green
}


# Install nvm
if (-not(Test-Path "~/.nvm")) {
    Write-Host "Installing NVM..." -ForegroundColor Cyan
    $Output = curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error failed to install NVM: $Output"
        $LASTEXITCODE = 0
        exit 1
    }
    Write-Host "NVM installed successfully`n" -ForegroundColor Green
}


# Setup chezmoi
if (-not(Test-Path "~/.local/share/chezmoi")) {
    Write-Host "Installing chezmoi..." -ForegroundColor Cyan
    $Output = bash -c /mnt/c/vdi-wsl-setup/util-scripts/setup-chezmoi.sh
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error installing chezmoi: $Output"
        $LASTEXITCODE = 0
        exit 1
    }
    Write-Host "chezmoi installed successfully`n"
}
