
# Main function
function Invoke-Main () {
    [CmdletBinding()]
    param ()
    Write-Host "`r`n`r`nDESCRIPTION: Generates a module template.`r`n`r`n[1) Continue]  [2) CANCEL]`r`n"
    $selection = Read-Host -Prompt "[#]"
    Write-Host
    if ($selection -eq 1) {
'
##############################
## SCRIPTOR Module template ##
##############################
<# Requirements (see https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_requires )
#Requires 
#>

## Main function (the only function SCRIPTOR will execute)
function Invoke-Main () {
    [CmdletBinding()]
    param ()
    
    Write-Host "`r`n`r`nDESCRIPTION: **place description here**.`r`n`r`n[1) Continue]  [2) CANCEL]`r`n"
    $selection = Read-Host -Prompt "[#]"
    Write-Host
    if ($selection -eq 1) {
        ## Place action code here
    }
    else {
        Write-Host "You chose to cancel.`r`n"
    }
}
' | Out-File "$(Split-Path $PSScriptRoot)\scripts\Template.psm1"

        Write-Host "A template has been generate here: '$(Split-Path $PSScriptRoot)\scripts\Template.psm1'`r`n"
    }
    else {
        Write-Host "You chose to cancel.`r`n"
    }
}