function Remove-TSEnvironment {
    <#
        .SYNOPSIS
            Releases a Microsoft.SMS.TSEnvironment COM Object.
        .DESCRIPTION
            Releases a Microsoft.SMS.TSEnvironment COM Object. Called after New-TSEnvironment.

            You usually don't want to call this directly. It is a utility function used by
            other functions in this module.

            Aliases: Remove-TSEnv

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]

    # The Microsoft.SMS.TSEnvironment COM Object to remove.
    param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNull()]
        [System.__ComObject]$Object
    )

    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Object) | Out-Null
}

New-Alias -Name 'Remove-TSEnv' -Value 'Remove-TSEnvironment'
