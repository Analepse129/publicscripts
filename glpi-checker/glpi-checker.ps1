Import-Module SimplySql

function Get-GLPIData {
    $Server = "glpi_server"
    $Database = "glpi_database"
    $Username = "glpi_database_username"
    $Password = "glpi_database_user_pswd"
    $Query = "select name from glpi_ipaddresses where mainitemtype = 'computer' and version ='4' and name != '127.0.0.1'"
    $result = New-Object System.Collections.ArrayList
    Open-MySqlConnection -Server $Server -Database $Database -UserName $Username -Password $Password
    $data = $(Invoke-SqlQuery -Query $Query)
    Close-SqlConnection
    foreach ($element in $data){
        [void]$result.Add($element.Item(0))
    }
    return $result
}

function Get-Computerpark {
    param(
        [string]$InjectSQLData
    )
    $computersWithIP = @()
    $computersWithoutIP = @()
    $resp = ""
    $computers = Get-ADComputer -Filter * -Properties IPv4Address
    foreach ($computer in $computers) {
        if ($computer.IPv4Address) {
            $computersWithIP += $computer
        } else {
            $computersWithoutIP += $computer
        }
    }
    # Afficher les ordinateurs avec une adresse IP
    Write-Host "Ordinateurs avec une adresse IP :" -ForegroundColor Yellow
    foreach ($element in $computersWithIP){
        if($element.IPv4Address -in $InjectSQLData.Split(" ")){
           #Write-Host $element.Name " is in GLPI" -ForegroundColor Green
            $element | Add-Member -Force GLPI Present
        }
        else{
            #Write-Host $element.Name " is not in GLPI" -ForegroundColor Red
            $element | Add-Member -Force GLPI Absent
        }
    }
    $computersWithIP | Format-Table -AutoSize Name, IPv4Address, @{
        Label = "GLPI"
        Expression = {
            switch ($_.GLPI){
                'Present' { $color = '92' }
                'Absent' { $color = '91' }
                default { $color = '93' }
            }
            $e=[char]27
            "$e[${color}m$($_.GLPI)${e}[0m" 
        }
    }
    Start-Sleep -Seconds 2
    # Afficher les ordinateurs sans adresse IP
    Write-Host "Ordinateurs sans adresse IP :" -ForegroundColor Yellow
    $computersWithoutIP | Select-Object Name | Format-Table -AutoSize
    Start-Sleep -Seconds 2
    Write-Host 'Terminé' -ForegroundColor Yellow
    Write-Host ""
    While ($resp -notin @("Y", "y", "N", "n")) {
        $resp = Read-Host "Voulez-vous exporter les données en CSV ? [Y/N]"
        if ( $resp -in @('Y', 'y') ) {
            $FilePath = Read-Host "Entrez le chemin du fichier à enregistrer : "
            $computersWithIP | Select-Object -Property Name, IPv4Address, GLPI | Export-CSV -Path $FilePath -NoTypeInformation
        }
        elseif ( $resp -in @('N', 'n') ) {
            Write-Host "Le programme va quitter."
        }
    }
}

Start-Sleep -Seconds 2
$glpiData = Get-GLPIData
Get-Computerpark -InjectSQLData $glpiData 