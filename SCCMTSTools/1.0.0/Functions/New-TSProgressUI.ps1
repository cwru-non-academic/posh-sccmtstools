function New-TSProgressUI {
    <#
        .SYNOPSIS
            Creates a new Microsoft.SMS.TSProgressUI COM object variable.
        .DESCRIPTION
            Creates a new Microsoft.SMS.TSProgressUI COM object variable. Call Remove-TSProgressUI after
            you are done with the object.

            You usually don't want to call this directly. It is a utility function used by
            other functions in this module.

        .OUTPUTS
            __ComObject

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([__ComObject])]

    param()

    New-Object -ComObject 'Microsoft.SMS.TSProgressUI'
}
