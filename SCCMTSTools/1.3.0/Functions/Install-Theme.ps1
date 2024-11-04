function Install-Theme {
    <#
        .SYNOPSIS
            Copies a theme file and the corresponding wallpaper to the target OS.
        .DESCRIPTION
            Copies a theme file and the corresponding wallpaper to the target OS.
            
            This must be called after the "Setup Windows and ConfigMgr" step.

            Messages about if various operations were successful are wrirten to the log.

        .OUTPUTS
            bool

            If the operation succeeded.

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # The path to the theme file.
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [string]$ThemePath,

        # The path to the sub-directory on the target OS to put the theme file in. Defaults to:
        # Resources\Themes
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ThemeDestination = 'WINDOWS\Resources\Themes',

        # The path to the wallpaper the theme uses, if it uses one.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [string]$WallpaperPath,

        # The path to the sub-directory on the target OS to put the wallpaper file in. Defaults to:
        # Web\Wallpaper
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$WallpaperDestination = 'WINDOWS\Web\Wallpaper',

        # Set this to also make the theme the default theme for new profiles.
        [Parameter()]
        [switch]$MakeDefault
    )

    $Success = $True

    # We need to make sure the target OS Windows directory is created.
    if (Test-TSVariableSet -Name 'OSDTargetSystemRoot') {
        Write-CMTraceLog -Message 'Target OS Windows path exists.'

        # Try to copy the wallpaper file, if there is one.
        if ($PSBoundParameters.ContainsKey('WallpaperPath')) {
            # Try to copy the wallpaper file.

            Write-CMTraceLog -Message 'We were asked to copy wallpaper. Attempting to do so ...'
            $WallpaperCopied = Copy-File -Path $WallpaperPath -Destination $WallpaperDestination

            if (-not $WallpaperCopied) {
                $Success = $False
            }
        } else {
            Write-CMTraceLog -Message 'We were not given a wallpaper to copy.'
        }

        # Try to copy the theme file.

        Write-CMTraceLog -Message 'Attempting to copy the theme file ...'
        $ThemeCopied = Copy-File -Path $ThemePath -Destination $ThemeDestination

        if ($ThemeCopied) {
            # Set the default theme for new profiles if asked to.

            $ThemeFileDestination = "$(Get-TSVariable -Name 'OSDTargetSystemDrive')\$ThemeDestination\$(Split-Path -Path $ThemePath -Leaf)"

            if ($MakeDefault.IsPresent) {
                Write-CMTraceLog -Message "Request made to make ""$ThemePath"" the default for new profiles."

                $DUKeyPath = 'HKEY_USERS\DefaultUser'
                $DUHiveFilePath = "$(Get-TSVariable -Name 'OSDTargetSystemDrive')\Users\Default\ntuser.dat"
                
                if (Mount-RegistryKey -KeyPath $DUKeyPath -HiveFilePath $DUHiveFilePath) {
                    $DUThemeKeyPath = "$DUKeyPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes"


                    $ThemeSet = $False
                    try {
                        $ThemeSet = $Null -ne (Set-ItemProperty -Path "Registry::$DUThemeKeyPath" -Name 'CurrentTheme' -Value $ThemeFileDestination -PassThru)
                    } catch {
                        $ThemeSet = $False
                    }

                    if ($ThemeSet) {
                        Write-CMTraceLog -Message "Set registry value ""$DUThemeKeyPath\CurrentTheme"" to ""$ThemeFileDestination""."
                    } else {
                        Write-CMTraceLog -Message "Failed to set registry value ""$DUThemeKeyPath\CurrentTheme"" to ""$ThemeFileDestination""." -Type 'Error'
                        $Success = $False
                    }

                    if (-not (Dismount-RegistryKey -KeyPath $DUKeyPath)) {
                        $Success = $False
                    }
                } else {
                    $Success = $False
                }
            } else {
                Write-CMTraceLog -Message 'Request to make theme the default for new profiles not made.'
            }
        } else {
            $Success = $False
        }
    } else {
        Write-CMTraceLog -Message 'No target OS Windows path found. Did you try to install theme before the "Apply Windows Operating System" step?' -Type 'Error'
        $Success = $False
    }

    $Success
}
