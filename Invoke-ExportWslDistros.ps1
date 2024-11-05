$ErrorActionPreference = 'Stop'

Write-Host @"
                            ────────────▄  ▄ ▀█▄  
                            ──▄████████▄██▄██▄██  
                            ──█████████████▄████▌ 
                            ──▌████████████▀▀▀▀▀  
                            ─▀ ▐█▄▐█▄▐█▄▐█▄       

 __          _______ _        ______                       _            
 \ \        / / ____| |      |  ____|                     | |           
  \ \  /\  / / (___ | |      | |__  __  ___ __   ___  _ __| |_ ___ _ __ 
   \ \/  \/ / \___ \| |      |  __| \ \/ / '_ \ / _ \| '__| __/ _ \ '__|
    \  /\  /  ____) | |____  | |____ >  <| |_) | (_) | |  | ||  __/ |   
     \/  \/  |_____/|______| |______/_/\_\ .__/ \___/|_|   \__\___|_|   
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
$SeedDistro = $Config.export.seeddistro
$ExportPath = $Config.export.exportpath

foreach ($Distro in $Distros) {
    Write-Host "Exporting distro $Distro" -ForegroundColor Cyan
    $Output = wsl --export $SeedDistro "$($ExportPath)/$($Distro).tar"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to export distro: $Distro - $Output"
        $LASTEXITCODE = 0
        exit 1
    }

    Write-Host "`nSuccessful`n" -ForegroundColor Green 
}

Write-Host "Successfully exported all distros to $ExportPath" -ForegroundColor Green