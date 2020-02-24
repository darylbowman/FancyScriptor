<#
    .NOTES
    ===========================================================================
		Modified on:   	02/24/2020 16:39
		Created by:   	Daryl Bowman
		E-Mail:			
		GitHub:			https://github.com/beardedmogul
		Filename:     	Import-ModuleMod.psm1
		Version: 		1.0
		===========================================================================
#>
function Import-ModuleMod {
    [CmdletBinding()]
    param
    (
        # Module name to import
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ModuleName
    )

    ## Check if the module is installed
    if (Get-InstalledModule -Name $ModuleName -ErrorAction SilentlyContinue) {
        try {
            ## Import the module
            Import-Module -Name $ModuleName
            return $True
        }
        catch {
            ## Something went wrong
            return $False
        }
    }
    ## Attempt to install the module
    else {
        Write-Host "The '$($ModuleName)' module is not installed.  Would you like to install it now?"
        Write-Host '[1) Yes ]  [2) NO ]'
        $optionPrompt = Read-Host -Prompt '[#] '

        if ($optionPrompt -eq '1') {
            try {
                Install-Module -Name $ModuleName -Force
                if (Get-InstalledModule -Name $ModuleName -ErrorAction SilentlyContinue) {
                    return $True
                }
                else {
                    return $False
                }
            }
            catch {
                Write-Host "The '$($ModuleName)' module encountered an error during installation:"
                Write-Host $Error
                return $False
            }
            
        }
    }
}
