function Remove-TSVariable {
    <#
        .SYNOPSIS
            Removes a SCCM task seqeunce variable.
        .DESCRIPTION
            Removes a SCCM task seqeunce variable.

            WARNING: This does no checking to see if you are removing a built-in variable.

            Aliases: Remove-TSVar

        .INPUTS
            string

            The name of the variable.

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

    # Per MS docs, we unset a TS variable by setting it to an empty string.
    $TSEnv.Value($Name) = ''

    # Release access to the TSEnvironment.
    Remove-TSEnvironment -Object $TSEnv
}

New-Alias -Name 'Remove-TSVar' -Value 'Remove-TSVariable'
