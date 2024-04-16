function Get-MessageBoxButtons {
    <#
        .SYNOPSIS
            Gets the System.Windows.MessageBoxButton enum names.
        .DESCRIPTION
            Gets the System.Windows.MessageBoxButton enum names.

            You usually don't want to call this directly. It is a utility function used by
            other functions in this module.

        .OUTPUTS
            string[]

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([string[]])]

    param()

    Add-Type -AssemblyName 'PresentationCore','PresentationFramework'

    [enum]::getNames([System.Windows.MessageBoxButton])
}
