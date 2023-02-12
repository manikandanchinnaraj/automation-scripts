$ViSession = Connect-VIServer "vcenter"

function Disable-VMHostService {
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Enter VMHost Service name. Example: slpd',
            Position = 0)]
        [string]$ServiceName,
        [Parameter(Mandatory = $true,
            HelpMessage = 'Enter Firewall Rule name. "CIM SLP"',
            Position = 1)]
        [string]$RuleName
    )

    begin {
        $vmhosts = Get-VMHost -Server $ViSession
    }

    process {
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
    
            $FirewallRule = $vmhost | Get-VMHostFirewallException -Name $RuleName
    
            if ($FirewallRule.Enabled -eq $false -and $FirewallRule.ServiceRunning -eq $false) {
                Write-Output "Both the rule and serice is disabled"
            }
            if ($FirewallRule.Enabled -eq $true) {
                $FirewallRule | Set-VMHostFirewallException -Enabled $false -Confirm:$false
            }
        }
    }
}

Disconnect-VIServer -Server $ViSession -Force -Confirm:$false