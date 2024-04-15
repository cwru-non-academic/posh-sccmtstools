function Set-TaskbarSearchIconState {
    <#
        .SYNOPSIS
            Sets the state of the search icon on the taskbar on new profiles on the target OS.
        .DESCRIPTION
            Sets the state of the search icon on the taskbar on new profiles on the target OS.

            Must be called after the "Setup Windows and ConfigMgr" step.

            Aliases: Set-TBSearchIconState

        .OUTPUTS
            bool

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # The state of the icon. Must be one of:
        #   Hidden
        #   IconOnly
        #   Box
        #   IconAndLabel
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Hidden', 'IconOnly', 'Box', 'IconAndLabel')]
        [string]$State
    )

    # Attempt to mount the default user hive.
    $DUKeyPath = 'HKEY_USERS\DefaultUser'
    $DUHiveFilePath = "$(Get-TSVariable -Name 'OSDTargetSystemDrive')\Users\Default\ntuser.dat"
    $DUKeyMounted = Mount-RegistryKey -KeyPath $DUKeyPath -HiveFilePath $DUHiveFilePath

    # Try to set the icon state.

    $IconKeyCreated = $False
    $IconStateSet = $False
    $DUKeyDismounted = -not $DUKeyMounted

    if ($DUKeyMounted) {
        # Create the parent key, as it doesn't seem to exist, even after the "Setup Windows and ConfigMgr" step.

        $IconKeyPath = "$DUKeyPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
        $IconValueName = 'SearchboxTaskbarMode'

        try {
            $IconKeyCreated = $Null -ne (New-Item -Path "Registry::$IconKeyPath" -ItemType 'Container')
        } catch {
            $IconKeyCreated = $False
        }

        if ($IconKeyCreated) {
            Write-CMTraceLog -Message "Created registry key at: ""$IconKeyPath"""

            # Map states to registry values.
            $StateMap = @{
                Hidden = 0
                IconOnly = 1
                Box = 2
                IconAndLabel = 3
            }

            # Try to set the registry value.

            try {
                $IconStateSet = $Null -ne (Set-ItemProperty -Path "Registry::$IconKeyPath" -Name $IconValueName -Value $StateMap.$State -Type 'DWord' -PassThru)
            } catch {
                $IconStateSet = $False
            }

            if ($IconStateSet) {
                Write-CMTraceLog -Message "Set registry value ""$IconKeyPath\$IconValueName"" to ""$($StateMap.State)""."
            } else {
                Write-CMTraceLog -Message "Failed to set registry value ""$IconKeyPath\$IconValueName"" to ""$($StateMap.State)""." -Type 'Error'
            }
        } else {
            Write-CMTraceLog -Message "Failed to create registry key at: ""$IconKeyPath""" -Type 'Error'
        }

        $DUKeyDismounted = Dismount-RegistryKey -KeyPath $DUKeyPath
    }

    $DUKeyMounted -and $IconKeyCreated -and $IconStateSet -and $DUKeyDismounted
}

New-Alias -Name 'Set-TBSearchIconState' -Value 'Set-TaskbarSearchIconState'
