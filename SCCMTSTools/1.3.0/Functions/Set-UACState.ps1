function Set-UACState {
    <#
        .SYNOPSIS
            Sets the state of the User Account Control (UAC) on the target OS.
        .DESCRIPTION
            Sets the state of the User Account Control (UAC) on the target OS. This can be set in Group
            Policy, but seems to require an extra reboot after booting into Windows for it to take
            effect. This function avoids the need for that.

            Must be called after the "Setup Windows and ConfigMgr" step.

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
        # The state of UAC. $True for on, $False for off.
        [Parameter(Mandatory = $True)]
        [bool]$State
    )

    $ParentRegKeyPath = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $RegName = 'EnableLUA'
    [int]$RegValue = $State

    $Success = $False
    try {
        $Success = $Null -ne (Set-ItemProperty -Path "Registry::$ParentRegKeyPath" -Name $RegName -Value $RegValue -PassThru)
    } catch {
        $Success = $False
    }

    if ($Success) {
        Write-CMTraceLog -Message "Set registry value ""$ParentRegKeyPath\$RegName"" to ""$RegValue""."
    } else {
        Write-CMTraceLog -Message "Failed to set registry value ""$ParentRegKeyPath\$RegName"" to ""$RegValue""." -Type 'Error'
    }

    $Success
}
