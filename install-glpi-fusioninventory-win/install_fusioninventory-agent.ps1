#Modify these variables to adapt to your infrastructure

$_REP_INSTALL = 'rep_fusioninventory_exe'
$_SERVICE = 'FusionInventory-Agent'
$_CERT_PATH = 'C:\Windows\FusionInventory-Agent'
$_CERT_NAME = 'cert.cer'
$_CERT = $_CERT_PATH + '\' + $_CERT_NAME
$_TEST_PATH = "C:\Program Files\FusionInventory-Agent"
$LogFilePath = "C:\Temp\InstallFusionInventoryConfLog.txt"
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

Function CheckService(){
	If((Get-Service|Select Name|Where Name -eq $_SERVICE).Name) {
		Stop-Service -Name $_SERVICE
	}
}

Function CopyCert(){
	New-Item $_CERT_PATH -Type Directory
	Copy-Item -Path "$_REP_INSTALL\$_CERT_NAME" -Destination "$_CERT_PATH\$_CERT_NAME"
}

Function InstallFusion(){
	Set-Location $_REP_INSTALL
	./fusioninventory-agent_windows-x64_2.6.exe /S /acceptlicense /server='"https://your_server/glpi/plugins/fusioninventory/"' /ca-cert-file=$_CERT /installtasks=full /installtype=from-scratch /task-frequency=minute /task-minute-modifier=15 /runnow /conf-reload-interval=300 /execmode=service /add-firewall-exception
}
#Do not modify below UNLESS you know what you're doing ! :p

LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Info: Script started" -LogFilePath $LogFilePath
Write-Host "-----------------------------------------" -ForegroundColor Cyan -BackgroundColor DarkBlue
Write-Host "                                         " -ForegroundColor Cyan -BackgroundColor DarkBlue
Write-Host "      Install FusionInventory Agent      " -ForegroundColor Cyan -BackgroundColor DarkBlue
Write-Host "                                         " -ForegroundColor Cyan -BackgroundColor DarkBlue
Write-Host "-----------------------------------------" -ForegroundColor Cyan -BackgroundColor DarkBlue
Start-Sleep 1

Write-Host "Lancement de la procedure d'installation" -ForegroundColor Yellow
#On verifie si le programme est bien installé (un controle rapide du repertoire d'installation).
Write-Host "Verificaion de la presence du programme sur la machine..." -ForegroundColor Yellow
If(Test-Path $_TEST_PATH){
	Write-Host "L'agent est deja en place !" -ForegroundColor Green
	Exit
}
Else {
	#Au cas ou si jamais le service est la...
	try{
	    CheckService
		Write-Host "Service FusionInventory-Agent stopped." -ForegroundColor Green
        LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Info: FusionInventory-Agent stopped." -LogFilePath $LogFilePath
    }
    catch {
        Write-Host "Error while stopping service." -ForegroundColor Red
        LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Error: " $_.Exception.Message -LogFilePath $LogFilePath
    }
	
	#Installation de l'agent
	Write-Host "Copie du certificat..." -ForegroundColor Yellow
	try {
		CopyCert
		Write-Host "Certificate successfully copied." -ForegroundColor Green
		LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Info: Cert successfully copied." -LogFilePath $LogFilePath	
	}
	catch {
		Write-Host "Error while copying certificate." -ForegroundColor Red	
		LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Error: " $_.Exception.Message -LogFilePath $LogFilePath
	}
	Write-Host "Installation de l'agent..." -ForegroundColor Yellow
	try {
		InstallFusion
		Write-Host "FusionInventory-Agent successfully installed." -ForegroundColor Green
	}
	catch {
		Write-Host "Error while installing FusionInventory-Agent." -ForegroundColor Red	
		LogMessage "$(Get-Date -format 'dd/MM/yyy hh:mm:ss tt') Error: " $_.Exception.Message -LogFilePath $LogFilePath
	}
}