function Show-ImagingErrorBox {
    <#
        .SYNOPSIS
            Shows a dialog box used to let the user know that imaging the computer failed.
        .DESCRIPTION
            Shows a dialog box used to let the user know that imaging the computer failed.

            This includes:
                * A message indicating the task sequence failed.
                * The name of the last step the task sequence ran.
                * The exit code of the last step the task sequence ran.

            Be sure to call this from the first step in your error handling group. If you don't,
            the step name and exit code displayed will not be for the step that caused the error.
            
            This must be called from an interactive PowerShell session. ServiceUI can do this.

        .NOTES
            Author    : Dan Thompson
            Copyright : 2024 Case Western Reserve University
    #>

    [CmdletBinding()]

    param(
        # An additional message to display, such as asking the technician doing to image to check your
        # knowledgebase. This is optional.
        [Parameter()]
        [string]$ExtraMessage
    )

    # Show the dialog box.

    $Body = "The imaging process failed.`n"
    $Body += "`tLAST STEP NAME: $(Get-TSVariable -Name '_SMSTSLastActionName')`n"
    $Body += "`tLAST STEP EXIT CODE: $(Get-TSVariable -Name '_SMSTSLastActionRetCode')"

    if ($PSBoundParameters.ContainsKey('ExtraMessage')) {
        $Body += "`n`n$ExtraMessage"
    }

    Show-MessageBox -Body $Body -Title 'Imaging Error' -Image 'Error'
}
