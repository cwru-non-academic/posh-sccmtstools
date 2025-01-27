@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'SCCMTSTools.psm1'

    # Version number of this module.
    ModuleVersion = '1.3.1'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop')

    # ID used to uniquely identify this module
    GUID = '6f423047-ef26-4782-a351-6480a84b70fd'

    # Author of this module
    Author = 'Dan Thompson'

    # Company or vendor of this module
    CompanyName = 'Case Western Reserve University'

    # Copyright statement for this module
    Copyright = '(C)2023 Case Western Reserve University. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Provides PowerShell functions for use with SCCM task sequences.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Close-TSProgressDialog',
        'Copy-File',
        'Copy-AccountPictures',
        'Copy-LoginScreenWallpapers',
        'Copy-Logs',
        'Copy-Windows11StartLayout',
        'Dismount-RegistryKey',
        'Get-MessageBoxButtons',
        'Get-MessageBoxImages',
        'Get-MesssageBoxResults',
        'Get-TSVariable',
        'Install-Theme',
        'Mount-RegistryKey',
        'New-TSEnvironment',
        'New-TSProgressUI',
        'Remove-Apps',
        'Remove-FileOrDirectory',
        'Remove-TSEnvironment',
        'Remove-TSProgressUI',
        'Remove-TSVariable',
        'Set-DesktopIconState',
        'Set-OSDCursorState',
        'Set-QuickAccessState',
        'Set-TaskbarBinaryIconState',
        'Set-TaskbarSearchIconState',
        'Set-TSVariable',
        'Set-UACState',
        'Set-USBPowerManagementState',
        'Show-ImagingErrorBox'
        'Show-InputBox',
        'Show-MessageBox',
        'Show-WaitBox',
        'Test-TSVariableSet',
        'Write-CMTraceLog'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @(
        'Copy-Files',
        'Copy-LSWallpapers',
        'Copy-Win11StartLayout',
        'Copy-W11StartLayout',
        'Dismount-RegKey',
        'Get-TSVar',
        'Mount-RegKey',
        'New-TSEnv',
        'Remove-TSEnv',
        'Remove-TSVar',
        'Set-TBBinaryIconState',
        'Set-TBSearchIconState',
        'Set-TSVar',
        'Set-QAState',
        'Test-TSVarSet'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData
    # hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('sccm', 'task sequence')

            # A URL to the license for this module.
            LicenseUri = 'https://www.gnu.org/licenses/gpl-3.0.en.html'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/cwru-non-academic/posh-sccmtstools'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/cwru-non-academic/posh-sccmtstools/blob/master/CHANGELOG.md'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}

