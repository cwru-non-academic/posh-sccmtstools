function Dismount-RegistryKey {
    <#
        .SYNOPSIS
            Dismounts a registry key.
        .DESCRIPTION
            Dismounts a registry key. Should be called after calling Mount-RegistryKey.

            Messages about if this succeeded or failed are written to the log.

            Aliases: Dismount-RegKey

        .OUTPUTS
            bool

            If the dismount succeeded.

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # The path to the key. This uses the path form that a call to "reg load" uses,
        # not the one that other PowerShell Cmdlets use. See
        # https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-load for details.
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path "Registry::$_" -PathType 'Container' })]
        [string]$KeyPath
    )

    [gc]::Collect()
    [gc]::WaitForPendingFinalizers()
    reg unload $KeyPath *>$Null

    $Success = (0 -eq $LastExitCode)
    if ($Success) {
        Write-CMTraceLog -Message "Successfully dismounted the registry key at: ""$Keypath"""
    } else {
        Write-CMTraceLog -Message "Failed to dismount the registry key at: ""KeyPath""" -Type 'Error'
    }

    $Success
}

New-Alias -Name 'Dismount-RegKey' -Value 'Dismount-RegistryKey'
