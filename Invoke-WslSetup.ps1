$ErrorActionPreference = 'Stop'

Write-Host @"
`n
                                ───▄▀▀▀▀▀───▄█▀▀▀█▄
                                ──▐▄▄▄▄▄▄▄▄██▌▀▄▀▐██
                                ──▐▒▒▒▒▒▒▒▒███▌▀▐███
                                ───▌▒▓▒▒▒▒▓▒██▌▀▐██
                                ───▌▓▐▀▀▀▀▌▓─▀▀▀▀▀

 __          _______ _        _    _                  _____      _               
 \ \        / / ____| |      | |  | |                / ____|    | |              
  \ \  /\  / / (___ | |      | |  | |___  ___ _ __  | (___   ___| |_ _   _ _ __  
   \ \/  \/ / \___ \| |      | |  | / __|/ _ \ '__|  \___ \ / _ \ __| | | | '_ \ 
    \  /\  /  ____) | |____  | |__| \__ \  __/ |     ____) |  __/ |_| |_| | |_) |
     \/  \/  |_____/|______|  \____/|___/\___|_|    |_____/ \___|\__|\__,_| .__/ 
                                                                          | |    
                                                                          |_|    
"@

Write-Host "Getting required modules..." -ForegroundColor Cyan
Save-Module -Name powershell-yaml -RequiredVersion 0.4.7 -Path ".\modules"
Import-Module -Name ".\modules\powershell-yaml\0.4.7\powershell-yaml.psm1"
Write-Host "Required modules installed`n" -ForegroundColor Green

Write-Host "Loading config..." -ForegroundColor Cyan
$Config = Get-Content -Path .\config.yaml | ConvertFrom-Yaml
Write-Host "Config loaded`n" -ForegroundColor Green

$Distros = @($Config.distros)
$SudoUsers = @($Config.sudousers)

if ($SudoUsers.Length -gt $Distros.Length) {
    Write-Error "You have more sudo users than distros"
    exit 1
}

# Hash table of temp passwords
$TempPasswords = @{}

$characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'


foreach ($i in $Distros) {
    $Password = -join ((1..6) | ForEach-Object { $characters[(Get-Random -Maximum $characters.Length)] })

    if ($SudoUsers -contains $i) {
        $Output = wsl -d $i -u root -- bash -c "adduser --disabled-password --gecos '' $($i) && echo '$($i):$($password)' | chpasswd && usermod -aG sudo $($i)"
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Error creating WSL user: $i - $Output"
            $LASTEXITCODE = 0
            exit 1
        }

        $TempPasswords[$i] = $Password

        Write-Host "User and password created for $i" -ForegroundColor Cyan
        Write-Host "User $i added to sudo group`n" -ForegroundColor Yellow
    } else {

        $Output = wsl -d $i -u root -- bash -c "adduser --disabled-password --gecos '' $($i) && echo '$($i):$($password)' | chpasswd"
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Error creating WSL user: $i - $Output"
            $LASTEXITCODE = 0
            exit 1
        }
    
        $TempPasswords[$i] = $Password

        Write-Host "User and password created for $i`n" -ForegroundColor Cyan
    }
}

Write-Host "Users set up successfully`n" -ForegroundColor Green

Write-Host "Temp Passwords for all users.."

$TempPasswords