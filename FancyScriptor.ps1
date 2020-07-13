<#
    .NOTES
    ===========================================================================
		Modified on:   	02/24/2020 16:40
		Created by:   	Daryl Bowman
		E-Mail:			
		GitHub:			https://github.com/beardedmogul
		Filename:     	Scriptor.ps1
		Version: 		1.2
		===========================================================================
#>

#Requires -RunAsAdministrator
#Requires -PSEdition Desktop

# Load these modules
using module "scripts\#modules\Import-CredentialManagerMod.psm1"

# Script variables
$Script:ScriptsDirectory = 'scripts'
$Script:HomeDirectory = "$($PSScriptRoot)\$($Script:ScriptsDirectory)"
$Script:TitleText = @'
███████╗ ██████╗██████╗ ██╗██████╗ ████████╗ ██████╗ ██████╗ 
██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗
███████╗██║     ██████╔╝██║██████╔╝   ██║   ██║   ██║██████╔╝
╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   ██║   ██║██╔══██╗
███████║╚██████╗██║  ██║██║██║        ██║   ╚██████╔╝██║  ██║
╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝    ╚═════╝ ╚═╝  ╚═╝

'@
$Script:MainMenuText = @'
          _____       _         _____                
         |     | ___ |_| ___   |     | ___  ___  _ _ 
         | | | || .'|| ||   |  | | | || -_||   || | |
         |_|_|_||__,||_||_|_|  |_|_|_||___||_|_||___|

                  ■ Please enter an Option ■

'@

<# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments

        $processInfo = New-Object -TypeName System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = "wt.exe"
        $processInfo.UseShellExecute = $true
        $processInfo.Verb = "runas"

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processInfo
        $process.Start()
        Exit
    }
}
#>

# Get the directories and files in a certain directory and return them in a menu format
function Get-Options {
    [CmdletBinding()]
    param
    (
        [System.IO.DirectoryInfo]$Menu = (Get-Item -Path $Script:HomeDirectory)
    )

    [System.Collections.ArrayList]$menuOptions = @()
    
    ## Add the parent menu as an option, unless it's the main menu
    if ($Menu.FullName -eq $Script:HomeDirectory) {
        [void]$menuOptions.Add($Menu)
    }
    else {
        [void]$menuOptions.Add($Menu.Parent)
    }
    
    ## Scan for directories and add as sub-menus
    $subMenus = $Menu.GetDirectories()
    foreach ($subMenu in $subMenus)
    {
        ## Exclude folder names starting with '#'
        if ($subMenu.Name[0] -ne '#') {
            [void]$menuOptions.Add($subMenu)
        }
    }

    ## Scan for files and add as menu options
    $subItems = $Menu.GetFiles()
    foreach ($subItem in $subItems)
    {
        [void]$menuOptions.Add($subItem)
    }

    ## A way to display messages to the user in the menu
    $messageText = ""

    ## Main menu selection : repeat until a valid selection is made
    do
    {
        Clear-Host
        Write-Host $Script:TitleText
        Write-Host $Script:MainMenuText
        Write-Host $messageText -ForegroundColor DarkRed
        Write-Host

        ## Add the menu option text at a fixed width to the right
        foreach ($menuOption in $menuOptions)
        {
            ## Display folders as sub-menus
            switch ($menuOption.GetType()) {

                ([System.IO.DirectoryInfo].AsType()) {
                    ## If this is the parent menu, show it differently
                    if ($menuOption.FullName -eq $Script:SelectedOption.Parent.FullName) {

                        Write-Host "$(($menuOptions.IndexOf($menuOption)).ToString()))".PadRight(3,' ') -ForegroundColor White -NoNewline
                        Write-Host "(parent menu)" -ForegroundColor Blue
                    }
                    ## This is an IMPORTANT placeholder to remove the main menu's entry of itself
                    elseif ($menuOption.FullName -eq $Script:SelectedOption.FullName) { }

                    ## This must be a regular folder; show it as a sub-menu
                    else {
                        Write-Host "$(($menuOptions.IndexOf($menuOption)).ToString()))".PadRight(3,' ') -ForegroundColor White -NoNewline
                        Write-Host "[$($menuOption.Name)]" -ForegroundColor DarkYellow
                    }
                }

                ([System.IO.FileInfo].AsType()) {
                    ## Display files as menu options
                    Write-Host "$(($menuOptions.IndexOf($menuOption)).ToString()))".PadRight(3,' ') -ForegroundColor White -NoNewline
                    Write-Host "$([System.IO.Path]::GetFileNameWithoutExtension($menuOption.Name))" -ForegroundColor White
                }
            }
        }
        Write-Host

        ## Get user's selection
        $optionPrompt = Read-Host -Prompt '[#] '
        
        $selectionIsValid = $true
        $selection = $null

        ## Try converting to a number to catch non-numbers
        try {
            $selection = [Convert]::ToInt32($optionPrompt)
            $messageText = ""
        }
        catch {
            $messageText = [string]::Concat("▌!".PadRight(3,' '),'Only numbers are accepted. Try again.')
            $selectionIsValid = $false
        }

        ## Catch numbers greater than the number of options
        if ($selection -gt $menuOptions.Count) {
            $messageText = [string]::Concat("▌!".PadRight(3,' '),'Good try, but not an option. Try again.')
            $selectionIsValid = $false
        }
    } ## End main menu selection
    while (!$selectionIsValid)
    
    ## Store the selected  option
    $Script:SelectedOption = $menuOptions.Item($selection)
    
    Clear-Host
    Write-Host $Script:TitleText

    switch ($Script:SelectedOption.GetType()) {
        ## If the selection is a 'directory', look for sub-options
        ([System.IO.DirectoryInfo].AsType()) {
            Write-Host "$($Script:SelectedOption.Name)`r`n`r`n"
            Get-Options($Script:SelectedOption)
        }
        ## If the selection is a 'file', execute it
        ([System.IO.FileInfo].AsType()) {
            $Script:SelectedOption.Name
            switch ($Script:SelectedOption.Extension)
            {
                ## For Pwsh modules, import the module and try to run the 'Invoke-Main' function, passing in parameters if possible
                '.psm1' {
                    $null = Import-Module -Name $Script:SelectedOption.FullName -Force
                    $command = Get-Command -Name "Invoke-Main" -ErrorAction SilentlyContinue
                    $commandArgs = ""

                    ## Look for parameters to pass
                    if ($null -ne $command) {
                        $parameters = $command.Parameters.Keys

                        foreach ($parameter in $parameters) {
                            switch ($parameter) {

                                ##################################################
                                #--------------------------------------------------------
                                # Inlude PARAMETERS to pass here ------------------------------------------------------------
                                #----------------------------------------------------------------
                                ##################################################

                                'CredentialAdm' {
                                    $commandArgs += "-$($parameter) " + '$Script:CredentialAdm '
                                }

                                'CredentialLadm' {
                                    $commandArgs += "-$($parameter) " + '$Script:CredentialLadm '
                                }
                                
                                <# Sample new parameter (remove notes between * *)
                                'SampleParameter' *must match the parameter name of the Pwsh Script Module* {
                                    $commandArgs += "-$($parameter) " + '$Script:SampleParameter ' *must match a variable name and value declared in section at line 285 *
                                }
                                #>

                                #####################################################
                                #-------------------------
                                # End PARAMETERS section
                                #-----------------------------------
                                ##############################################################
                            }
                        }
                    }

                    if ([string]::IsNullOrEmpty($commandArgs)) {
                        $null = Invoke-Expression $command.Name
                    }
                    else {
                        $null = Invoke-Expression "$($command.Name) $($commandArgs)"
                    }
                    
                    ## When the module has completed, display a message to the user and wait for '[Enter]'
                    $message = [string]::Concat("▌!".PadRight(3,' '),'End of script. Press [Enter] to return to SCRIPTOR.')
                    Write-Host $message -ForegroundColor DarkRed
                    Read-Host
                }
                ## For Pwsh scripts, run the script
                '.ps1' {
                    & $Script:SelectedOption.FullName

                    ## When the script has completed, display a message to the user and wait for '[Enter]'
                    $message = [string]::Concat("▌!".PadRight(3,' '),'End of script. Press [Enter] to return to SCRIPTOR.')
                    Write-Host $message -ForegroundColor DarkRed
                    Read-Host
                }
                ## For any other extensions, run them with their default app
                default {
                    Write-Host "Starting '$($Script:SelectedOption.BaseName)'..."
                    Write-Host
                    Write-Host
                    Invoke-Item -Path $Script:SelectedOption.FullName
                }      
            }
            
            ## Go back to the main menu
            Show-MainMenu
        }
    }


    if ($Script:SelectedOption.GetType() -eq [System.IO.DirectoryInfo].AsType()) {
        Write-Host "$($Script:SelectedOption.Name)`r`n`r`n"
        Get-Options($Script:SelectedOption)
    }
    ## If the selection is a 'file', execute it in the way specified for its extension
    else {
        
    }
}

# Shows the main menu
function Show-MainMenu {
    $Script:SelectedOption = (Get-Item -Path $Script:HomeDirectory)
    Get-Options
}




############################################################################################################################################################
#------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------
# START OF SCRIPT -----------------------------
# ---------------------------------------------------------

Clear-Host
Write-Host @'

██╗      ██████╗  █████╗ ██████╗ ██╗███╗   ██╗ ██████╗          
██║     ██╔═══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝          
██║     ██║   ██║███████║██║  ██║██║██╔██╗ ██║██║  ███╗         
██║     ██║   ██║██╔══██║██║  ██║██║██║╚██╗██║██║   ██║         
███████╗╚██████╔╝██║  ██║██████╔╝██║██║ ╚████║╚██████╔╝██╗██╗██╗
╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝╚═╝╚═╝
                                                                
'@ -ForegroundColor DarkYellow


#-----------------------------------------------------------------------------
### Declare PARAMETERS to pass here
#-----------------------------------

# Gets a stored credential from Credential Manager
$Script:CredentialAdm = [PSCredential](Get-CredentialAdm)
$Script:CredentialLadm = [PSCredential](Get-CredentialLadm)

#$Script:SampleParameter = $null

#-----------------------------------
#------------------------------------------------------------------------------

# Starts the menu display loop
Show-MainMenu

#--------------------------------------------------------------------------------------------------------------------
# END OF SCRIPT ------------------------------------------------------------------------------------
################################################################################################################################################
