$_REP_INSTALL = 'your_unc_path'
$_CERT_NAME = 'cert.cer'
$_NEWCERT = $_REP_INSTALL + $_CERT_NAME
$_SERVICE = 'FusionInventory-Agent'
$_CERT_PATH = 'C:\Windows\FusionInventory-Agent\'
$_CERT = $_CERT_PATH + $_CERT_NAME
$_REGISTRYPATH = 'HKLM:\SOFTWARE\FusionInventory-Agent\'
$LogFilePath = "C:\Temp\UpdateFusionInventoryConfLog.txt"
Function CreateLogDir(){
    if (Test-Path -Path "C:\Temp") {
        Write-Host "Le répertoire C:\Temp existe déjà."
    } else {
        New-Item -ItemType Directory -Path "C:\Temp"
    }
}
Function LogMessage(){
    param
       (
       [Parameter(Mandatory=$true)] [string] $Message,
       [Parameter(Mandatory=$true)] [string] $LogFilePath
       )
       Try {

           Add-content -Path  $LogFilePath -Value $Message
       }
       Catch {
           Write-host -f Red "Error:" $_.Exception.Message
       }
}
Function StopFusion(){
    If((Get-Service|Select-Object Name|Where-Object Name -eq $_SERVICE).Name) {
        Stop-Service -Name $_SERVICE
        Write-Host "Service FusionInventory-Agent stopped." -ForegroundColor Green
    }
    Else {
        Write-Host "Service FusionInventory-Agent already stopped." -ForegroundColor Green
    }
}
Function StartFusion(){
    Start-Service -Name $_SERVICE
}

LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Info: Script started" -LogFilePath $LogFilePath
Write-Host "--------------------------------------------------------" -ForegroundColor Cyan -BackgroundColor DarkBlue
Write-Host "                                                        " -ForegroundColor Cyan -BackgroundColor DarkBlue
Write-Host "      Update FusionInventory Certs & registry keys      " -ForegroundColor Cyan -BackgroundColor DarkBlue
Write-Host "                                                        " -ForegroundColor Cyan -BackgroundColor DarkBlue
Write-Host "--------------------------------------------------------" -ForegroundColor Cyan -BackgroundColor DarkBlue
Start-Sleep 1
CreateLogDir
try {
	Write-Host "Stopping FusionInventory-Agent service..." -ForegroundColor Yellow
    try{
	    StopFusion
        LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Info: FusionInventory-Agent stopped." -LogFilePath $LogFilePath
    }
    catch {
        Write-Host "Error while stopping service." -ForegroundColor Red
        LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Error: " $_.Exception.Message -LogFilePath $LogFilePath
    }
    Write-Host "Downloading new cert..." -ForegroundColor Yellow
    try {
        Copy-Item -Path $_NEWCERT -Destination $_CERT
        Write-Host "New cert has been successfully copied." -ForegroundColor Green
        LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Info: New cert copied." -LogFilePath $LogFilePath
    }
    catch {
        Write-Host "Error while downloading new cert." -ForegroundColor Red
        LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Error: " $_.Exception.Message -LogFilePath $LogFilePath
    }
    Write-Host "Modifying registry keys..." -ForegroundColor Yellow
    try {
        Set-ItemProperty -Path $_REGISTRYPATH -Name 'ca-cert-file' -Value $_CERT -Type 'String' -Force
        Write-Host 'Value of field "ca-cert-file" successfully changed".' -ForegroundColor Green
        LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Info: ca-cert-file value successfully changed." -LogFilePath $LogFilePath
        Set-ItemProperty -Path $_REGISTRYPATH -Name 'httpd-trust' -Value '127.0.0.1/32,192.168.100.0/24' -Type 'String' -Force
        Write-Host 'Value of field "httpd-trust" successfully changed".' -ForegroundColor Green
        LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Info: httpd-trust value successfully changed." -LogFilePath $LogFilePath
    }
    catch {
        Write-Host "Error while modifying registry keys." -ForegroundColor Red
        LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Error: " $_.Exception.Message -LogFilePath $LogFilePath
    }
    Write-Host "Relaunching FusionInventory-Agent service..." -ForegroundColor Yellow
    try {

        Write-Host 'FusionInventory successfully restarted with new configuration.' -ForegroundColor Green
        Start-Sleep 1
        Write-Host "Exiting..." -ForegroundColor Green
        LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Info: FusionInventory-Agent successfully restarted. Script is quitting." -LogFilePath $LogFilePath
    }
    catch {
        Write-Host "Error while launching FusionInventory-Agent." -ForegroundColor Red
        LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Error: " $_.Exception.Message -LogFilePath $LogFilePath
    }
}
catch {
	Write-Host "Error while executing the script." -ForegroundColor Red
    LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Error: " $_.Exception.Message -LogFilePath $LogFilePath
}
