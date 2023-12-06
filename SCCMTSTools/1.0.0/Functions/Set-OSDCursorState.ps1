function Set-OSDCursorState {
    <#
        .SYNOPSIS
            Sets the state of the mouse cursor on the OSD after booting into the target OS.
        .DESCRIPTION
            Sets the state of the mouse cursor on the OSD after booting into the target OS. See 
            https://learn.microsoft.com/en-us/troubleshoot/mem/configmgr/os-deployment/no-mouse-cursor-during-osd-task-sequence
            for details about this.

            This must be called after the "Apply Operating System" step, but before booting into the target OS
            (which the "Setup Windows and ConfigMgr Step" does).

            Messages about if various operations were successful are wrirten to the log.

        .OUTPUTS
            bool

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # If you want to enable the cursor. $True (the default) means yes, $False means no. By default, Windows
        # hides the cursor.
        [Parameter()]
        [bool]$State = $True
    )

    # Set some paths.
    $HKLMSoftwareKeyPath = 'HKEY_LOCAL_MACHINE\Temp'
    $HKLMSoftwareHiveFilePath = "$(Get-TSVariable -Name 'OSDTargetSystemDrive')\Windows\System32\Config\SOFTWARE"

    # Try to set the registry value.

    $HKLMSoftwareKeyMounted = Mount-RegistryKey -KeyPath $HKLMSoftwareKeyPath -HiveFilePath $HKLMSoftwareHiveFilePath
    $HKLMSoftwareKeyDismounted = $True

    if ($HKLMSoftwareKeyMounted) {
        # The actual registry value we set has to be an int, and the opposite of $State.
        [int]$RegVal = -not $State

        # Store if we were able to set the registry value.
        $RegValSet = $True

        try {
            $RegValSet = $Null -ne (Set-ItemProperty -Path "Registry::$HKLMSoftwareKeyPath\Microsoft\Windows\CurrentVersion\Policies\System" -Name 'EnableCursorSuppression' -Value $RegVal -Type 'DWord' -PassThru)
        } catch {
            $RegValSet = $False
        }

        if ($RegValSet) {
            Write-CMTraceLog -Message "Successfully set suppression of the display of the cursor after booting into the target OS to: ""$RegVal"""
        } else {
            Write-CMTraceLog -Message "Failed to set suppression of the display of the cursor after booting into the target OS to: ""$RegVal""" -Type 'Error'
        }

        if ($HKLMSoftwareKeyMounted) {
            $HKLMSoftwareKeyDismounted = Dismount-RegistryKey -KeyPath $HKLMSoftwareKeyPath
        }
    }

    $HKLMSoftwareKeyMounted -and $RegValSet -and $HKLMSoftwareKeyDismounted
}
