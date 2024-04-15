function Copy-Logs {
    <#
        .SYNOPSIS
            Copies SCCM TS log files to a subdirectory under a given destination directory.
        .DESCRIPTION
            Copies SCCM TS log files to a subdirectory under a given destination directory.

            Must be called after the "Format and Partition Disk" step.

        .OUTPUTS
            bool

        .NOTES
            Author    : Dan Thompson
            Copyright : 2024 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # The directory containing the logs. Defaults to _SMSTSLogPath.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Container' })]
        [string]$Path = (Get-TSVariable -Name '_SMSTSLogPath'),

        # Where to copy the logs to. A subdirectory will be created under this named after the
        # computer name and current date and time. So, this should be a directory containing
        # the directories for each machine that encounters an error while imaging. If you want this
        # to be a network location, map that to a network drive in a previous step, and set this
        # to that network drive. Defaults to: "L:"
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -IsValid })]
        [string]$Destination = 'L:',

        # Filters the logs copied. Defaults to "*.log".
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Filter = '*.log',

        # The timestamp format to use on the directory that gets created under $Destination. This uses
        # the standard .NET date and time format strings found here:
        # https://learn.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
        # Defaults to "yyyyMMddHHmm".
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$TimestampFormat = 'yyyyMMddHHmm'
    )

    # Try and fetch the computer name. We need this to construct the name of the directory we will dump the
    # logs to.

    # Fetch from the variable that is set on re-images.
    $ComputerName = Get-TSVariable -Name '_SMSTSMachineName'

    if (-not $ComputerName) {
        # It isn't a re-image. Look at the variable that is set on a new image.
        $ComputerName = Get-TSVariable -Name 'OSDComputerName'
    }

    if (-not $ComputerName) {
        # We can't find the computer name. Use "UNKNOWN" instead of just failing outright.
        $ComputerName = 'UNKNOWN'
    }

    # Copy the logs.

    # Calculate the real destination.
    $Destination = Join-Path -Path $Destination -ChildPath "$ComputerName_$(Get-Date -Format $TimestampFormat)"

    # Try and copy the logs.

    Write-CMTraceLog -Message "Attempting to copy logs from ""$Source"" to ""$Destination"" ..."

    $LogsCopied = $False
    try {
        Copy-Item -Path $Path -Destination $Destination -Filter $Filter -Recurse
        $LogsCopied = $True
    } catch {
        $LogsCopied = $False
    }

    if (-not $LogsCopied) {
        Write-CMTraceLog -Message "Failed to copy logs from ""$Path"" into ""$Destination""." -Type 'Error'
    }
}
