function Remove-Apps {
    <#
        .SYNOPSIS
            Removes UWP/Modern apps from the target OS.
        .DESCRIPTION
            Removes UWP/Modern apps from the target OS.
            
            This must be called after the "Setup Windows and ConfigMgr" step.

            Messages about if various operations were successful are wrirten to the log.

        .INPUTS
            string

            The pattern(s) to match the app names against.
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
        # The pattern to match the app's package name against. Multiple paterns can be passed via the pipeline.
        #
        # Can be one of:
        #   * a simple string that the app's package name must contain
        #   * a regular expression that the app's package name must match
        #
        # You can see the apps that will be installed for each new user with the Get-AppxProvisionedPackage CmdLet.
        # The PackageName property is what is being matched here.
        #
        # Aliases: Patterns
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Patterns')]
        [string]$Pattern,

        # Controls which mode this function operates in:
        #   Remove : Removes any apps that match the specified pattern.
        #   Keep   : Keeps only apps that match the specified pattern.
        # Defaults to "Keep".
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Remove','Keep')]
        [string]$Mode = 'Keep',

        # Set this to consider failing to remove an app an error. If this is set, an error will be written to
        # the log, and the output will be $False. Otherwise, only a warning will be logged, and $True will be the
        # output.
        #
        # This is used instead of ErrorAction as there are possible values for ErrorAction that don't really make sense
        # here, such as "Suspend" and "Inquire".
        [Parameter()]
        [switch]$ErrorOnFailureToRemove
    )

    begin {
        # Get the package name of the apps already installed on the target OS.
        $AppsInstalled = (Get-AppxProvisionedPackage -Online).PackageName

        # Did we find any?
        $NumAppsInstalled = ($AppsInstalled | Measure-Object).Count
        Write-CMTraceLog -Message "$NumAppsInstalled apps found on the target OS."

        # We need to store which apps we are going to remove. Start by assuming we are removing everything.
        $AppsToRemove = $AppsInstalled
    }

    process {
        if ($NumAppsInstalled -gt 0) {
            # Whittle down the list of installed apps to just the ones we want to actually remove.
            switch ($Mode) {
                'Remove' {
                    $AppsToRemove = $AppsToRemove | Where-Object {
                        $_ -match $Pattern
                    }
                }

                'Keep' {
                    $AppsToRemove = $AppsToRemove | Where-Object {
                        $_ -notmatch $Pattern
                    }
                }
            }
        }
    }

    end {
        $AppsRemoved = $True

        # Did we find any apps to remove?
        $NumAppsToRemove = ($AppsToRemove | Measure-Object).Count
        if ($NumAppsToRemove -gt 0) {
            Write-CMTraceLog -Message "Found $NumAppsToRemove apps to remove."

            # Set the type of message to write to the log on a failure.
            $FailureLogMessageType = ''
            if ($ErrorOnFailureToRemove.IsPresent) {
                $FailureLogMessageType = 'Error'
            } else {
                $FailureLogMessageType = 'Warning'
            }

            # Attempt to remove each app.

            $AppsToRemove | ForEach-Object {
                $AppToRemove = $_
                Remove-AppProvisionedPackage -PackageName $AppToRemove -Online

                $AppRemoved = 0 -eq ((Get-AppxProvisionedPackage -Online | Where-Object {
                    $_.PackageName -eq $AppToRemove
                }) | Measure-Object).Count

                if ($AppRemoved) {
                    Write-CMTraceLog -Message "Successfully removed ""$AppToRemove."""
                } else {
                    Write-CMTraceLog -Message "Failed to remove ""$AppToRemove""." -Type $FailureLogMessageType
                    $AppsRemoved = -not $ErrorOnFailureToRemove.IsPresent
                }
            }
        } else {
            # No apps found to remove.
            Write-CMTraceLog -Message 'Found no apps to remove! Aborting removing apps.' -Type 'Warning'
        }

        $AppsRemoved
    }
}
