function Set-QuickAccessState {
    <#
        .SYNOPSIS
            Sets if File Explorer should open to "Quick Access" by default on new profiles
            on the target OS.
        .DESCRIPTION
            Sets if File Explorer should open to "Quick Access" by default on new profiles
            on the target OS. This is the default behavior in Windows 10 and 11. If you
            turn this off, File Explorer opens to the list of drives instead.

            This must be called after the "Setup Windows and ConfigMgr" step.

            Messages about if various operations were successful are wrirten to the log.

            Aliases: Set-QAState

        .OUTPUTS
            bool

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # Set to $True to turn on Quick Access, $False to turn it off.
        [Parameter(Mandatory = $True)]
        [bool]$State
    )

    # Set the path to the default user hive and where we want to mount it.
    $DUKeyPath = 'HKEY_USERS\DefaultUser'
    $DUHiveFilePath = "$(Get-TSVariable -Name 'OSDTargetSystemDrive')\Users\Default\ntuser.dat"

    # Set the state value as we need to write to to the registry.
    [int]$QAState = -not $State

    # Store some success states.
    $DUKeyMounted = Mount-RegistryKey -KeyPath $DUKeyPath -HiveFilePath $DUHiveFilePath
    $QAStateSet = $True

    # Attempt to set the state of Quick Access.
    if ($DUKeyMounted) {
        $DUExplorerSettingsKeyPath = "$DUKeyPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

        try {
            $QAStateSet = $Null -ne (Set-ItemProperty -Path "Registry::$DUExplorerSettingsKeyPath" -Name 'LaunchTo' -Value $QAState -Type 'DWord' -PassThru)
        } catch {
            $QAStateSet = $False
        }

        if ($QAStateSet) {
            Write-CMTraceLog -Message "Set registry value ""$DUExplorerSettingsKeyPath\LaunchTo"" to ""$QAState""."
        } else {
            Write-CMTraceLog -Message "Failed to set registry value ""$DUExplorerSettingsKeyPath\LaunchTo"" to ""$QAState""." -Type 'Error'
        }

        # Dismount the registry key.
        $DUKeyDismountSucceeded = Dismount-RegistryKey -KeyPath $DUKeyPath
    }

    # Output if we succeeded.
    $DUKeyMounted -and $QAStateSet -and $DUKeyDismountSucceeded
}

New-Alias -Name 'Set-QAState' -Value 'Set-QuickAccessState'
