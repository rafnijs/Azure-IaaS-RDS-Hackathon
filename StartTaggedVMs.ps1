﻿#Update TagName and TagValue for your environment
$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint   $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
} 


$rgName = '<ResourceGroup>'
$subscriptionId = '<SubIDGUID>'
Select-AzureRmSubscription -SubscriptionId $subscriptionId

#Update TagName and TagValue for your environment
$TagResults = (Find-AzureRmResource -TagName App -TagValue RDS) | ? {$_.ResourceType -eq 'Microsoft.Compute/virtualMachines'}

foreach ($Result in $TagResults){
    $VM = Get-AzureRmVM -Name $Result.Name -ResourceGroupName $rgName
    $VMStatus = (Get-AzureRmVM -Name $Result.Name -ResourceGroupName $rgName -Status).Statuses
    Write-Host Hostname $VM.Name Status $VMStatus.DisplayStatus

    if($VMStatus[1].DisplayStatus -eq 'VM deallocated'){
        Write-Host VM is not started
        Start-AzureRmVM -ResourceGroupName $rgName -Name $VM.Name
    }

} 