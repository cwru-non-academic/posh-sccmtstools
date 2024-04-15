function Show-ImagingErrorBox {
    <#
        .SYNOPSIS
            Shows a dialog box used to let the user know that imaging the computer failed.
        .DESCRIPTION
            Shows a dialog box used to let the user know that imaging the computer failed.

            This includes:
                * A message indicating the task sequence failed.
                * The step the task sequence failed on.
                * The error code.
            
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
    $Body += "`tFAILING STEP: $(Get-TSVariable -Name '_SMSTSLastActionName')`n"
    $Body += "`tERROR CODE: $(Get-TSVariable -Name '_SMSTSLastActionRetCode')"

    if ($PSBoundParameters.ContainsKey('ExtraMessage')) {
        $Body += "`n`n$ExtraMessage"
    }

    Show-MessageBox -Body $Body -Title 'Imaging Error' -Image 'Error'
}
