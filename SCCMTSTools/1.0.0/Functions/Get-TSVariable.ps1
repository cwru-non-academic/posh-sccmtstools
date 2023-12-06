function Get-TSVariable {
    <#
        .SYNOPSIS
            Gets the value of a SCCM task sequence variable.
        .DESCRIPTION
            Gets the value of a SCCM task sequence variable.

            Aliases: Get-TSVar

        .OUTPUTS
            string

            The value of the variable if it was found, or $Null if it wasn't.

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    
    param (
        # The name of the variable.
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    # We need access to the TSEnvironment.
    $TSEnv = New-TSEnvironment

    $TSEnv.Value($Name)

    # Release access to the TSEnvironment.
    Remove-TSEnvironment -Object $TSEnv
}

New-Alias -Name 'Get-TSVar' -Value 'Get-TSVariable'
