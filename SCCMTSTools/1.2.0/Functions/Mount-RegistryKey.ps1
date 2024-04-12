function Mount-RegistryKey {
    <#
        .SYNOPSIS
            Mounts a registry key from a hive file.
        .DESCRIPTION
            Mounts a registry key from a hive file. This is a wrapper around reg load. This should be followed by
            a Dismount-RegistryKey when you are done working with the hive.

            Messages about if this succeeded or failed are written to the log.

            Aliases: Mount-RegKey

        .OUTPUTS
            bool

            If the mount succeeded.

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # The path to the key the file will be mounted to. This uses the path form that a call to "reg load" uses,
        # not the one that other PowerShell Cmdlets use. See
        # https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/reg-load for details.
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyPath,

        # The path to the hive file.
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [string]$HiveFilePath
    )

    reg load $KeyPath $HiveFilePath *>$Null

    $Success = (0 -eq $LastExitCode)
    if ($Success) {
        Write-CMTraceLog -Message "Successfully mounted the registry hive at ""$HiveFilePath"" to the registry key at ""$KeyPath""."
    } else {
        Write-CMTraceLog -Message "Failed to mount the registry hive at ""$HiveFilePath"" to the registry key at ""$KeyPath""." -Type 'Error'
    }

    $Success
}

New-Alias -Name 'Mount-RegKey' -Value 'Mount-RegistryKey'
