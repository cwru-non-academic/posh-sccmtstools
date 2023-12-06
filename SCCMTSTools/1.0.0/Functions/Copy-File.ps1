function Copy-File {
    <#
        .SYNOPSIS
            Copies file(s) into the destination sub-directory on the target OS.
        .DESCRIPTION
            Copies file(s) into the destination sub-directory on the target OS.
            If the sub-directory or any of its ancestor directories don't already exist, they will
            automatically be created.

            See the examples on Copy-Item that deal with the Path, Destination, and Recurse arguments
            for examples.

            This must be called after the "Apply Operating System Image" step.

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
        # The source. This takes the same syntax as the Path parameter to Copy-Item.
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ })]
        [string]$Path,

        # The destination. This takes the same syntax as the Desitnation parameter to Copy-Item.
        # This exists under the destination OS root drive, the path to which is prepended to this.
        # If this is a directory, and it or any of its parent directories are missing, they will
        # all get created.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -IsValid })]
        [string]$Destination,

        # Indicates that this cmdlet does a recursive copy.
        [Parameter()]
        [switch]$Recurse
    )

    # Calculate the real destination.
    if ($PSBoundParameters.ContainsKey('Destination')) {
        $Destination = Join-Path -Path (Get-TSVariable -Name 'OSDTargetSystemDrive') -ChildPath $Destination
    } else {
        $Destination = Join-Path -Path (Get-TSVariable -Name 'OSDTargetSystemDrive') -ChildPath ''
    }

    # Create any required directories that don't already exist.

    $DirectoryToTestPath = ''
    if ((Split-Path -Path $Destination -Leaf) -like '*.*') {
        Write-CMTraceLog -Message """$Destination"" is a file."
        $DirectoryToTestPath = Split-Path -Path $Destination -Parent
    } else {
        Write-CMTraceLog -Message """$Destination"" is a directory."
        $DirectoryToTestPath = $Destination
    }

    $DirectoryToTestCreated = Test-Path -Path $DirectoryToTestPath -PathType 'Container'
    if ($DirectoryToTestCreated) {
        Write-CMTraceLog -Message """$DirectoryToTestPath"" already exists, so not creating it."
    } else {
        Write-CMTraceLog -Message """$DirectoryToTestPath"" doesn't exist. Attempting to create it ..."

        try {
            $DirectoryToTestCreated = $Null -ne (New-Item -Path $DirectoryToTestPath -ItemType 'Directory')
        } catch {
            $DirectoryToTestCreated = $False
        }

        if ($DirectoryToTestCreated) {
            Write-CMTraceLog -Message "Successfully created: ""$DirectoryToTestPath"""
        } else {
            Write-CMTraceLog -Message "Failed to create: ""$DirectoryToTestPath""" -Type 'Error'
        }
    }

    # Attempt to copy the files.

    $FilesCopied = $False

    if ($DirectoryToTestCreated) {
        try {
            $FilesCopied = $Null -ne (Copy-Item -Path $Path -Destination $Destination -Recurse:($Recurse.IsPresent) -PassThru)
        } catch {
            $FilesCopied = $False
        }

        if ($FilesCopied) {
            Write-CMTraceLog -Message "Successfully copied files from ""$Path"" to ""$Destination""."
        } else {
            Write-CMTraceLog -Message "Failed to copy files from ""$Path"" to ""$Destination""." -Type 'Error'
        }
    }

    # Output the result.
    $DirectoryToTestCreated -and $FilesCopied
}

New-Alias -Name 'Copy-Files' -Value 'Copy-File'
