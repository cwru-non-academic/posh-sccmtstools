function New-TSEnvironment {
    <#
        .SYNOPSIS
            Creates a new Microsoft.SMS.TSEnvironment COM object variable.
        .DESCRIPTION
            Creates a new Microsoft.SMS.TSEnvironment COM object variable. Call Remove-TSEnvironment after
            you are done with the object.

            You usually don't want to call this directly. It is a utility function used by
            other functions in this module.

            Aliases: New-TSEnv

        .OUTPUTS
            __ComObject

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([__ComObject])]

    param()

    New-Object -ComObject 'Microsoft.SMS.TSEnvironment'
}

New-Alias -Name 'New-TSEnv' -Value 'New-TSEnvironment'
