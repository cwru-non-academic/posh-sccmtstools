function Copy-LoginScreenWallpapers {
    <#
        .SYNOPSIS
            Copies login screen wallpapers to the target OS.
        .DESCRIPTION
            Copies login screen wallpapers to the target OS. These are the wallpapers used by the login screen,
            NOT the per-user lock screen.

            This must be called after the "Apply Operating System" image step.

            Aliases: Copy-LSWallpapers

        .OUTPUTS
            bool

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # The path to the directory containing the wallpapers.
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Container' })]
        [string]$Path
    )

    Copy-File -Path (Join-Path -Path $Path -ChildPath '*') -Destination 'WINDOWS\System32\oobe\info\backgrounds'
}

New-Alias -Name 'Copy-LSWallpapers' -Value 'Copy-LoginScreenWallpapers'
