function Show-MessageBox {
    <#
        .SYNOPSIS
            Shows a message box.
        .DESCRIPTION
            Shows a message box.
            
            This must be called from an interactive PowerShell session. ServiceUI can do this.

        .OUTPUTS
            string

            One of the MessageBoxResult enum names
            (https://learn.microsoft.com/en-us/dotnet/api/system.windows.messageboxresult).

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([int])]

    param(
        # The body of the message to display.
        #
        # Aliases: Message
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [Alias('Message')]
        [string]$Body,

        # The title of the dialog box. Defaults to "Message".
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Title = 'Message',

        # Which button(s) to display. Must be one of the MessageBoxButton enum names. See
        # https://learn.microsoft.com/en-us/dotnet/api/system.windows.messageboxbutton. Defaults to
        # showing a single OK button.
        [Parameter()]
        [ValidateScript({ (Get-MessageBoxButtons).Contains($_) })]
        [string]$Buttons = 'OK',

        # Which image to show. Must be one of the MessageBoxImage enum names. See
        # https://learn.microsoft.com/en-us/dotnet/api/system.windows.messageboximage. Defaults to
        # showing the "information" image.
        [Parameter()]
        [ValidateScript({ (Get-MessageBoxImages).Contains($_) })]
        [string]$Image = 'Information',

        # Set this to NOT close the SCCM task sequence progress dialog. You usually only want to do
        # this if you have already closed it.
        [Parameter()]
        [switch]$NoCloseTSProgressDialog
    )

    # Close the TS progress dialog unless we have been told not to.
    if (-not $NoCloseTSProgressDialog) {
        Close-TSProgressDialog
    }

    # Show the message.

    Add-Type -AssemblyName 'PresentationCore','PresentationFramework'

    [System.Windows.MessageBox]::Show($Body, $Title, $Buttons, $Image)
}
