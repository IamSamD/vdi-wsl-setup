$ErrorActionPreference = 'Stop'

Write-Host @"
                                        ───▄██▄─────────────▄▄
                                        ──█████▄▄▄▄───────▄▀
                                        ────▀██▀▀████▄───▄▀
                                        ───▄█▀▄██▄████▄─▄█
                                        ▄▄█▀▄▄█─▀████▀██▀

 __          _______ _         _____        __ _                             _____      _               
 \ \        / / ____| |       / ____|      / _| |                           / ____|    | |              
  \ \  /\  / / (___ | |      | (___   ___ | |_| |___      ____ _ _ __ ___  | (___   ___| |_ _   _ _ __  
   \ \/  \/ / \___ \| |       \___ \ / _ \|  _| __\ \ /\ / / _` | '__/ _ \  \___ \ / _ \ __| | | | '_ \ 
    \  /\  /  ____) | |____   ____) | (_) | | | |_ \ V  V / (_| | | |  __/  ____) |  __/ |_| |_| | |_) |
     \/  \/  |_____/|______| |_____/ \___/|_|  \__| \_/\_/ \__,_|_|  \___| |_____/ \___|\__|\__,_| .__/ 
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

$Users = Get-Content -Path .\user.yaml | ConvertFrom-Yaml

Write-Host "Config loaded`n" -ForegroundColor Green

$Distros = @($Users.distros)

foreach ($Distro in $Distros) {
    Write-Host "Running software setup for distro: $($Distro.name)..." -ForegroundColor Cyan
    $Output = wsl -d $Distro.name -u $Distro.name -- pwsh -c "/mnt/c/vdi-wsl-setup/util-scripts/SoftwareSetup.ps1"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error running software setup script: $Output"
        $LASTEXITCODE = 0
        exit 1
    }
}

Write-Host "Software set up successfully for all distros`n" -ForegroundColor Green