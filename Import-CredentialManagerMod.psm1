<#
    .NOTES
    ===========================================================================
		Modified on:   	02/24/2020 16:39
		Created by:   	Daryl Bowman
		E-Mail:			
		GitHub:			https://github.com/beardedmogul
		Filename:     	Import-CredentialManagerMod.psm1
		Version: 		1.0
		===========================================================================
#>

#Requires -RunAsAdministrator

# Used to import 'CredentialManager' module
using module ".\Import-ModuleMod.psm1"

$credentialAdmName = 'Pwsh_Adm'
$credentialLAdmName = 'Pwsh_LAdm'

# Domain Administrator credential
function Get-CredentialAdm {
    [CmdletBinding()]
    param
    (
        ## Ask to save credential if none exists
        [Parameter(Mandatory=$False)]
        [bool]
        $AskToSave = $True
    )

    ## Import the 'CredentialManager' module
    [void](Import-ModuleMod -Name 'CredentialManager')
    
    ## Get stored credential or $null
    $credentialAdm = Get-StoredCredential -Target $credentialAdmName

    ## If credential is missing and $AskToSave is $True, ask to save
    if ($null -eq $credentialAdm -and $AskToSave) {
        Write-Host "Domain Administrator credentials are NOT stored for this user.  Would you like to store one?"
        Write-Host '[Y) Yes   [N) NO]'
        $optionPrompt = Read-Host -Prompt "Option"

        if ($optionPrompt -eq 'y') {

            $credAdm = Get-Credential -Message "Enter a Domain Administrator credential"
            $null = New-StoredCredential -Target $credentialAdmName -Username $credAdm.UserName -SecurePassword $credAdm.Password -Type Generic -Persist LocalMachine
            $credentialAdm = Get-StoredCredential -Target $credentialAdmName
        }
    }

    return $credentialAdm
}

# Local machine Administrator credential
function Get-CredentialLAdm {
    [CmdletBinding()]
    [OutputType([PSCredential])]
    param
    (
        # Ask to save credential if none exists
        [Parameter(Mandatory=$False)]
        [bool]
        $AskToSave = $True
    )
    
    ## Import the 'CredentialManager' module
    [void](Import-ModuleMod -Name 'CredentialManager')

    ## Get stored credential or $null
    $credentialLAdm = Get-StoredCredential -Target $credentialLAdmName

    ## If credential is missing and $AskToSave is $True, ask to save
    if ($null -eq $credentialLAdm -and $AskToSave) {
        Write-Host "Local machine Administrator credentials are NOT stored for this user.  Would you like to store one?"
        Write-Host '[Y) Yes   [N) NO]'
        $optionPrompt = Read-Host -Prompt "Option"

        if ($optionPrompt -eq 'y') {

            $credLAdm = Get-Credential -Message "Enter a local machine Administrator credential"
            $null = New-StoredCredential -Target $credentialLAdmName -Username $credLAdm.UserName -SecurePassword $credLAdm.Password -Type Generic -Persist LocalMachine
            $credentialLAdm = Get-StoredCredential -Target $credentialLAdmName
        }
    }

    return $credentialLAdm
}