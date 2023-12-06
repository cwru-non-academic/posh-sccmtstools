function Write-CMTraceLog {
    <#
        .SYNOPSIS
            Writes messages to a log in the CMTrace format.
        .DESCRIPTION
            Writes messages to a log in the CMTrace format.

            By default, the log file is written to %_SMSTSLogPath%\SCCMTSTools.log. To override the directory path and file name,
            set the task sequence variables SCCMTSTools_Log_DirPath and SCCMTSTools_Log_FileName, respectively.

            DON'T try to set this to log to smsts.log, as that file will be locked by SCCM and it will get very grumpy.

        .INPUTS
            string

            The message to write.

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]

    param(
        # The message to write.
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        # Type type of message to write. Must be one of:
        #   Info
        #   Warning
        #   Error
        # Defaults to "Error".
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )

    begin {
        # Convert the type into an integer.
        switch ($Type) {
            'Info' { [int]$Type = 1 }
            'Warning' { [int]$Type = 2 }
            'Error' { [int]$Type = 3 }
        }

        # Determine the path to the log file.

        $Path = ''

        if (Test-TSVariableSet -Name 'SCCMTSTools_Log_DirPath') {
            $Path = Get-TSVariable -Name 'SCCMTSTools_Log_DirPath'
        } else {
            $Path = Get-TSVariable -Name '_SMSTSLogPath'
        }

        if (Test-TSVariableSet -Name 'SCCMTSTools_Log_FileName') {
            $Path = Join-Path -Path $Path -ChildPath (Get-TSVariable -Name 'SCCMTSTools_Log_FileName')
        } else {
            $Path = Join-Path -Path $Path -ChildPath 'SCCMTSTools.log'
        }
    }

    process {
        # Build the log entry.

        $Content = "<![LOG[$Message]LOG]!>"
        $Content += "<time=""$(Get-Date -Format 'HH:mm:ss.fff')$((Get-TimeZone).BaseUtcOffset.TotalMinutes)"" "
        $Content += "date=""$(Get-Date -Format 'M-d-yyyy')"" "
        $Content += "component=""$((Get-Process -Id $PID).ProcessName)"" "
        $Content += "context=""$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"" "
        $Content += "type=""$Type"" "
        $Content += "thread=""$PID"" "
        $Content += "file=""$((Get-PSCallStack)[1].Location)"">"

        # Write the line to the file.
        Add-Content -Path $Path -Value $Content
    }
}
