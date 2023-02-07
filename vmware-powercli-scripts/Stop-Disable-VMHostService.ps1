$ViSession = Connect-VIServer "vcenter"

$vmhosts = Get-VMHost -Server $ViSession

$ServiceName = "slpd"

foreach ($vmhost in $vmhosts) {

    $VmhostService = Get-VMHostService -VMHost $vmhost -Server $ViSession | Where-Object { $_.Key -eq $ServiceName }

    # Creating the HostService Object
    $VmHostServiceObj = New-Object VMware.Vim.HostService
    $VmHostServiceObj.Key = $VmhostService.Key
    $VmHostServiceObj.Label = $VmhostService.Label
    $VmHostServiceObj.Policy = "off"
    $VmHostServiceObj.Required = $false
    $VmHostServiceObj.Running = $false

    if ($VmhostService.Running -eq $false) {
        Write-Output "$($vmhost.Name) - $($VmhostService.Key) service is already stopped"
    }
    if ($VmhostService.Running -eq $true) {
        Write-Output "$($vmhost.Name) - $($VmhostService.Key) service is running. Stopping it...."    
        Stop-VMHostService -HostService $VmHostService -Confirm:$false
    }

}

Disconnect-VIServer -Server $ViSession -Force -Confirm:$false
