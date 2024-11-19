# 1.0.0
* First release.

# 1.1.0
* Added `Remove-FileOrDirectory` to delete files or directories from the target OS drive.

# 1.2.0
* Added support for error handling (issue #3):
    * Added `Copy-Logs` function.
    * Added `Show-ImagingErrorBox` function.

# 1.2.1
This was bug fixes and minor enhancements to items added in 1.2.0:
* Fixed bugs with `Copy-Logs`.
* Adjusted formating on `Show-ImagingErrorBox`.

# 1.2.2
* Fixed a bug where `Copy-Logs` wasn't outputting a `bool`.

# 1.2.3
* Added clarification on when to call `Show-ImagingErrorBox`.

# 1.3.0
* Added function `Set-USBPowerManagementState` to control the power management state of USB devices that support it. Useful when you have USB devices that do not take kindly to being put into sleep mode.

# 1.3.1
* Fixed a bug. The file `Set-USBPowerManagementState.ps1` had the wrong function name in the function definition.
