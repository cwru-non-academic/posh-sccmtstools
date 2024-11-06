function Set-SerialPortPowerManagementState {
    <#
        .SYNOPSIS
            Sets the state of the power management on all USB devices.
        .DESCRIPTION
            Sets the state of the power management on all USB devices.

            This must be called after the "Setup Windows and ConfigMgr" step.

            Messages about if various operations were successful are wrirten to the log.

        .OUTPUTS
            bool

        .NOTES
            Author    : Dan Thompson
            Copyright : 2024 Case Western Reserve University
    #>

    [CmdletBinding()]
    [OutputType([bool])]

    param(
        # The desired power management state. $True for on, $False for off.
        [Parameter(Mandatory = $True)]
        [bool]$State
    )

    $StateString = ''
    if ($State) {
        $StateString = 'on'
    } else {
        $StateString = 'off'
    }

    Write-CMTraceLog -Message "Attempting to turn $StateString power management on all USB devices that support it ..."
    $PowerManagementSet = $True

    # Get the instance IDs of all USB devices.
    $USBDeviceInstanceIDs = (Get-PnpDevice | Where-Object {$_.Class -eq 'USB'}).InstanceID.ToUpper()

    # Iterate though all devices that support power management.
    Get-CimInstance -ClassName 'MSPower_DeviceEnable' -Namespace 'root\WMI' | ForEach-Object {
        $PowerManagedDevice = $_
        $PowerManagedDeviceInstanceName = $_.InstanceName.ToUpper()

        Write-CMTraceLog -Message "Determining if the device with the instance name ""$PowerManagedDeviceInstanceName"" is a USB device ..."

        # Is this one a USB device?

        $IsUSBDevice = $False
        foreach ($USBDeviceInstanceID in $USBDeviceInstanceIDs) {
            if ($PowerManagedDeviceInstanceName -like "$USBDeviceInstanceID*") {
                $IsUSBDevice = $True
            }
        }

        if ($IsUSBDevice) {
            # It is. Set the power management state.

            Write-CMTraceLog -Message "It is. Attempting to turn $StateString power management ..."

            $PowerManagedDevice.Enable = $State
            if (Set-CimInstance -InputObject $PowerManagedDevice -PassThru) {
                Write-CMTraceLog -Message "Succesfully turned $StateString power management."
            } else {
                Write-CMTraceLog -Message "Failed to turn $StateString power management." -Type 'Error'
                $PowerManagementSet = $False
            }
        } else {
            # It isn't.
            Write-CMTraceLog -Message 'It is not.'
        }
    }

    # Output if we succeeded.
    $PowerManagementSet
}
