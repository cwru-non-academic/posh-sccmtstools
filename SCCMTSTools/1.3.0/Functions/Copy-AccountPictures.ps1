function Copy-AccountPictures {
    <#
        .SYNOPSIS
            Copies user account pictures to the target OS.
        .DESCRIPTION
            Copies user account pictures to the target OS.

            This must be called after the "Apply Operating System" image step.

        .OUTPUTS
            bool

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # The path to the directory containing the account pictures.
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Container' })]
        [string]$Path
    )

    Copy-File -Path (Join-Path -Path $Path -ChildPath '*') -Destination 'ProgramData\Microsoft\User Account Pictures'
}
