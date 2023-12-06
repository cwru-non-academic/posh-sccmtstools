function Close-TSProgressDialog {
    <#
        .SYNOPSIS
            Closes the task sequence progress dialog.
        .DESCRIPTION
            Closes the task sequence progress dialog.
            
            This must be called from an interactive PowerShell session. ServiceUI can do this.

            You usually don't want to call this directly. It is a utility function used by
            other functions in this module.

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]

    param()

    $TSProgressUI = New-TSProgressUI
    $TSProgressUI.CloseProgressDialog()
    Remove-TSProgressUI -Object $TSProgressUI
}
