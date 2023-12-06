function Set-DesktopIconState {
    <#
        .SYNOPSIS
            Sets the state of the specified desktop icon(s) for new user profiles on the target OS.
        .DESCRIPTION
            Sets the state of the specified desktop icon(s) for new user profiles on the target OS.

            This must be called after the "Setup Windows and ConfigMgr" step.

            Messages about if various operations were successful are wrirten to the log.

        .INPUTS
            string
        .OUTPUTS
            bool

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # The name of the icon. Must be one of:
        #   Computer
        #   ControlPanel
        #   UserFiles
        #   RecycleBin
        #   Network
        # Multiple icons can be specified via the pipeline.
        #
        # Aliases: Names
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Computer', 'ControlPanel', 'UserFiles', 'RecycleBin', 'Network')]
        [Alias('Names')]
        [string]$Name,

        # The state of the icon. $True (the default) means shown, $False means hidden.
        [Parameter(Mandatory = $True)]
        [bool]$State
    )

    begin {
        # Mount the default user hive.

        $DUKeyPath = 'HKEY_USERS\DefaultUser'
        $DUHiveFilePath = "$(Get-TSVariable -Name 'OSDTargetSystemDrive')\Users\Default\ntuser.dat"
        $DUKeyMounted = Mount-RegistryKey -KeyPath $DUKeyPath -HiveFilePath $DUHiveFilePath

        # Map icon names to IDs.
        $IconIDs = @{
            Computer = '{20D04FE0-3AEA-1069-A2D8-08002B30309D}'
            ControlPanel = '{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}'
            UserFiles = '{59031A47-3F72-44A7-89C5-5595FE6B30EE}'
            RecycleBin = '{645FF040-5081-101B-9F08-00AA002F954E}'
            Network = '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}'
        }

        # Convert $State into an appropriate DWORD registry value. Needs to be the opposite of $State as
        # the registry value sets if the desktop icon is hidden, whereas $State determines if it is shown.
        [int]$RegVal = -not $State

        # Set the paths to the HideDesktopIcons and NewStartPanel keys.
        $HideDesktopIconsKeyPath = "$DUKeyPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons"
        $NewStartPanelKeyPath = "$HideDesktopIconsKeyPath\NewStartPanel"

        # These keys don't exist, even after the "Setup Windows and ConfigMgr" step.

        # Store if we were successful creating the HideDesktopIcons key.
        $HideDesktopIconsKeyCreated = $True

        # Store if we were successful creating the NewStartPanel key.
        $NewStartPanelKeyCreated = $True

        # Try to create the keys.

        try {
            $HideDesktopIconsKeyCreated = $Null -ne (New-Item -Path "Registry::$HideDesktopIconsKeyPath" -ItemType 'Container')
        } catch {
            $HideDesktopIconsKeyCreated = $False
        }

        if ($HideDesktopIconsKeyCreated) {
            Write-CMTraceLog -Message "Successfully created registry key at: ""$HideDesktopIconsKeyPath"""

            try {
                $NewStartPanelKeyCreated = $Null -ne (New-Item -Path "Registry::$NewStartPanelKeyPath" -ItemType 'Container')
            } catch {
                $NewStartPanelKeyCreated = $False
            }

            if ($NewStartPanelKeyCreated) {
                Write-CMTraceLog -Message "Successfully created registry key at: ""$NewStartPanelKeyPath"""
            } else {
                Write-CMTraceLog -Message "Failed to create registry key at: ""$NewStartPanelKeyPath""" -Type 'Error'
            }
        } else {
            Write-CMTraceLog -Message "Failed to create registry key at: ""$HideDesktopIconsKeyPath""" -Type 'Error'
        }

        # Store if we were successful on setting each of the desktop icon states.
        $IconStateSet = $True
    }

    process {
        if ($DUKeyMounted -and $HideDesktopIconsKeyCreated -and $NewStartPanelKeyCreated) {
            # Try to set the state of the specified icon.

            try {
                $IconStateSet = $IconStateSet -and ($Null -ne (Set-ItemProperty -Path "Registry::$NewStartPanelKeyPath" -Name $IconIDs.$Name -Value $RegVal -Type 'DWord' -PassThru))
            } catch {
                $IconStateSet = $False
            }

            if ($IconStateSet) {
                Write-CMTraceLog -Message "Set registry value ""$NewStartPanelKeyPath\$($IconIDs.$Name)"" to ""$RegVal""."
            } else {
                Write-CMTraceLog -Message "Failed to set registry value ""$NewStartPanelKeyPath\$($IconIDs.$Name)"" to ""$RegVal""." -Type 'Error'
            }
        }
    }

    end {
        # Dismount the default user hive if it was mounted.
        $DUKeyDismountSucceeded = $True
        if ($DUKeyMounted) {
            $DUKeyDismountSucceeded = Dismount-RegistryKey -KeyPath $DUKeyPath
        }

        # Return if we were successful.
        $DUKeyMounted -and $IconStateSet -and $DUKeyDismountSucceeded
    }
}
