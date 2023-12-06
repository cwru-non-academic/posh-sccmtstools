function Show-InputBox {
    <#
        .SYNOPSIS
            Shows an input box used to get input from a user.
        .DESCRIPTION
            Shows an input box used to get input from a user.

            This must be called from an interactive PowerShell session. ServiceUI can do this.

        .OUTPUTS
            string

            What the user typed in. This will be an empty string if the user clicks [Cancel].

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([string])]

    param(
        # The body of the message to display.
        #
        # Aliases: Message
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [Alias('Message')]
        [string]$Body,

        # The title of the dialog box. Defaults to "Question".
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Title = 'Question',

        # What to put into the response text field by default. If not set, nothing is displayed.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultResponse,

        # Set this to NOT close the SCCM task sequence progress dialog. You usually only want to do
        # this if you have already closed it.
        [Parameter()]
        [switch]$NoCloseTSProgressDialog
    )

    # Close the TS progress dialog unless we have been told not to.
    if (-not $NoCloseTSProgressDialog) {
        Close-TSProgressDialog
    }

    # Show the input box.
    
    Add-Type -AssemblyName 'Microsoft.VisualBasic'

    [Microsoft.VisualBasic.Interaction]::InputBox(
        $Body,
        $Title,
        $DefaultResponse
    )
}
