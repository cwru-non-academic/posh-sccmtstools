function Remove-TSProgressUI {
    <#
        .SYNOPSIS
            Releases a Microsoft.SMS.TSProgressUI COM Object.
        .DESCRIPTION
            Releases a Microsoft.SMS.TSProgressUI COM Object. Called after New-TSProgressUI.

            You usually don't want to call this directly. It is a utility function used by
            other functions in this module.

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]

    # The Microsoft.SMS.TSProgressUI COM Object to remove.
    param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNull()]
        [System.__ComObject]$Object
    )

    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Object) | Out-Null
}
