function Test-TSVariableSet {
    <#
        .SYNOPSIS
            Tests to see if a task seqeunce variable is set.
        .DESCRIPTION
            Tests to see if a task seqeunce variable is set. It is considered to be set if it is not null, empty, or
            just whitespace.

            Aliases: Test-TSVarSet

        .OUTPUTS
            bool

        .NOTES
            Author    : Dan Thompson
            Copyright : 2023 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # The name of the variable.
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    -not [string]::IsNullOrWhiteSpace((Get-TSVariable -Name $Name))
}

New-Alias -Name 'Test-TSVarSet' -Value 'Test-TSVariableSet'
