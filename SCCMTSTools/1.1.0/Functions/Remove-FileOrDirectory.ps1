function Remove-FileOrDirectory {
    <#
        .SYNOPSIS
            Removes a file or directory from the target OS.
        .DESCRIPTION
            Removes a file or directory from the target OS.

            This must be called after the "Apply Operating System Image" step.

            Messages about if various operations were successful are wrirten to the log.

        .INPUTS
            string

            The file or directory to be removed.
        .OUTPUTS
            bool

            If the operation succeeded.

        .NOTES
            Author    : Dan Thompson
            Copyright : 2024 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    
    param(
        # The path to the file or directory to delete. This exists under the destination OS root drive, the path to which is
        # prepended to this. Directories will only get deleted if they are empty, unless the $Recurse switch is set. In that case,
        # the directory and all items under it will get deleted.
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        # Determines if deletion should delete the parent directory and everything under it. Has no effect if $Path is a file.
        [Parameter()]
        [switch]$Recurse
    )

    begin {
        $ItemsRemoved = $True
    }

    process {
        # Interate over the path(s) we were given. We use a foreach here in case they were passed in as a single array.
        foreach ($ItemSubPath in $Path) {
            # Make sure it is a valid path.
            if (Test-Path -Path $ItemSubPath -IsValid) {
                # Calculate the actual path.
                $Path = Join-Path -Path (Get-TSVariable -Name 'OSDTargetSystemDrive') -ChildPath $ItemSubPath

                # Remove things.

                try {
                    Remove-Item -Path $Path -Recurse:($Recurse.IsPresent)
                } catch {
                    $ItemsRemoved = $False
                }

                $ItemsRemoved = (-not (Test-Path -Path $Path)) -and $ItemsRemoved
                
                if ($ItemsRemoved) {
                    Write-CMTraceLog -Message "Successfully removed: ""Path"""
                } else {
                    Write-CMTraceLog -Message "Failed to remove: ""Path""" -Type 'Error'
                }
            } else {
                Write-CMTraceLog -Message """$ItemSubPath"" is a malformed path under the target OS! Not deleting." -Type 'Error'
            }
        }
    }

    end {
        $ItemsRemoved
    }
}
