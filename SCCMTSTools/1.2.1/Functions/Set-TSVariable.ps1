function Set-TSVariable {
    <#
        .SYNOPSIS
            Sets a TS variable.
        .DESCRIPTION
            Sets a TS variable.

            Aliases: Set-TSVar

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]

    param(
        # The name of the variable.
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # The value to set the variable to.
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Value
    )

    # We need access to the TSEnvironment.
    $TSEnv = New-TSEnvironment

    # Set the variable.
    $TSEnv.Value($Name) = $Value

    # Release access to the TSEnvironment.
    Remove-TSEnvironment -Object $TSEnv
}

New-Alias -Name 'Set-TSVar' -Value 'Set-TSVariable'
