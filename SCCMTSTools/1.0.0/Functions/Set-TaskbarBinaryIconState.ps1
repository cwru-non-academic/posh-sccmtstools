function Set-TaskbarBinaryIconState {
    <#
        .SYNOPSIS
            Sets the states of icons on the taskbar in the default profile on the target OS.
        .DESCRIPTION
            Sets the states of icons on the taskbar in the default profile on the target OS. This function is
            used to set the state of icons that can be either hidden or shown.

            Must be called after the "Setup Windows and ConfigMgr" step.

            Messages about if various operations were successful are wrirten to the log.

            Aliases: Set-TBBinaryIconState

        .OUTPUTS
            bool
        .INPUTS
            string

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # The name(s) of the icon(s) to set the state of. Must be one of:
        #   TaskView
        #   Widgets
        #   Chat
        #
        # Aliases: Names
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Search', 'TaskView', 'Widgets', 'Chat')]
        [Alias('Names')]
        [string]$Name,

        # The state to set the icon to. $True for shown, $False for hidden.
        [Parameter(Mandatory = $True)]
        [bool]$State
    )

    begin {
        # Attempt to mount the default user hive.
        $DUKeyPath = 'HKEY_USERS\DefaultUser'
        $DUHiveFilePath = "$(Get-TSVariable -Name 'OSDTargetSystemDrive')\Users\Default\ntuser.dat"
        $DUKeyMounted = Mount-RegistryKey -KeyPath $DUKeyPath -HiveFilePath $DUHiveFilePath

        # Set the path to the parent key.
        $IconKeyPath = "$DUKeyPath\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

        # Map icon names to registry names.
        $IconRegNames = @{
            TaskView = 'ShowTaskViewButton'
            Widgets = 'TaskbarDa'
            Chat = 'TaskbarMn'
        }

        # Store if we successfully set the registry value.
        $IconStateSet = $True

        # Convert $State into an appropriate DWORD registry value.
        [int]$RegVal = $State
    }

    process {
        if ($DUKeyMounted) {
            # Try and set the icon state.

            Write-CMTraceLog -Message "Attempting to set the state of the ""$Name"" icon on the taskbar ..."

            try {
                $IconStateSet = $IconStateSet -and ($Null -ne (Set-ItemProperty -Path "Registry::$IconKeyPath" -Name $IconRegNames.$Name -Value $RegVal -Type 'DWord' -PassThru))
            } catch {
                $IconStateSet = $False
            }

            if ($IconStateSet) {
                Write-CMTraceLog -Message "Set registry value ""$IconKeyPath\$($IconRegNames.$Name)"" to ""$RegVal""."
            } else {
                Write-CMTraceLog -Message "Failed to set registry value ""$IconKeyPath\$($IconRegNames.$Name)"" to ""$RegVal""." -Type 'Error'
            }
        }
    }

    end {
        # Attempt to dismount the default user hive if we mounted it.
        $DUKeyDismounted = $True
        if ($DUKeyMounted) {
            $DUKeyDismounted = Dismount-RegistryKey -KeyPath $DUKeyPath
        }

        # Output the results.
        $DUKeyMounted -and $IconStateSet -and $DUKeyDismounted
    }
}

New-Alias -Name 'Set-TBBinaryIconState' -Value 'Set-TaskbarBinaryIconState'
