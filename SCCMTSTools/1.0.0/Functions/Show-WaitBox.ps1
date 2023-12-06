function Show-WaitBox {
    <#
        .SYNOPSIS
            Shows a dialog box used to puase the task sequence, usually for debugging.
        .DESCRIPTION
            Shows a dialog box used to puase the task sequence, usually for debugging.
            
            This must be called from an interactive PowerShell session. ServiceUI can do this.

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]

    param()

    # Show the dialog box.

    $Body = "The task seqeunce is paused.`n"
    $Body += "Press [F8] to open a command prompt.`n"
    $Body += 'Click [OK] to continue.'

    Show-MessageBox -Body $Body -Title 'TS Paused'
}
