$ErrorActionPreference = 'Stop'

Write-Host @"
                            ─────▄████▀█▄
                            ───▄█████████████████▄
                            ─▄█████.▼.▼.▼.▼.▼.▼▼▼▼
                            ▄███████▄.▲.▲▲▲▲▲▲▲▲
                            ████████████████████▀▀

 __          _______ _        _____                            _            
 \ \        / / ____| |      |_   _|                          | |           
  \ \  /\  / / (___ | |        | |  _ __ ___  _ __   ___  _ __| |_ ___ _ __ 
   \ \/  \/ / \___ \| |        | | | '_ ` _ \| '_ \ / _ \| '__| __/ _ \ '__|
    \  /\  /  ____) | |____   _| |_| | | | | | |_) | (_) | |  | ||  __/ |   
     \/  \/  |_____/|______| |_____|_| |_| |_| .__/ \___/|_|   \__\___|_|   
                                             | |                            
                                             |_|                            
"@

# Set up modules
Write-Host "Importing required modules..." -ForegroundColor Cyan

if (-not(Test-Path -Path ".\modules\powershell-yaml\0.4.7\powershell-yaml.psm1")) {
    Save-Module -Name powershell-yaml -RequiredVersion 0.4.7 -Path ".\modules"
}
Import-Module -Name ".\modules\powershell-yaml\0.4.7\powershell-yaml.psm1"

Write-Host "Required modules imported`n" -ForegroundColor Green

# Load config
Write-Host "Loading config..." -ForegroundColor Cyan

$Config = Get-Content -Path .\config.yaml | ConvertFrom-Yaml

Write-Host "Config loaded`n" -ForegroundColor Green

$Distros = @($Config.distros)
$ExportLocation = $Config.export.exportpath
$InstallLocation = $Config.import.installlocation

foreach ($Distro in $Distros) {
    Write-Host "Importing distribution $Distro..." -ForegroundColor Cyan
    $Output = wsl --import $Distro "$($InstallLocation)\$($Distro)" "$($ExportLocation)/main-distro.tar"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error importing distribution: $Distro - $Output"
        $LASTEXITCODE = 0
        exit 1
    }

    Write-Host "`nSuccessfully imported distribution: $Distro`n" -ForegroundColor Green
}

Write-Host "All distributions imported successfully" -ForegroundColor Green