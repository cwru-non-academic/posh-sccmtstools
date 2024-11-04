function Copy-Windows11StartLayout {
    <#
        .SYNOPSIS
            Copies a Windows 11 Start Menu layout file to the default profile on the target OS.
        .DESCRIPTION
            Copies a Windows 11 Start Menu layout file to the default profile on the target OS.

            Aliases: Copy-W11StartLayout, Copy-Win11StartLayout

            This must be called after the "Apply Operating System" image step.

        .OUTPUTS
            bool

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]

    param(
        # The path to the BIN file holding the Start Menu layout. On an installation of W11, this can be found at:
        #   %LocalAppData%\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [string]$Path
    )

    Copy-File -Path $Path -Destination 'Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin'
}

New-Alias -Name 'Copy-W11StartLayout' -Value 'Copy-Windows11StartLayout'
New-Alias -Name 'Copy-Win11StartLayout' -Value 'Copy-Windows11StartLayout'
