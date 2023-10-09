# Get a list of all Azure subscriptions in your tenant
$subscriptions = Get-AzSubscription

# Create an empty array to store results
$results = @()

# Loop through each subscription
foreach ($subscription in $subscriptions) {
    # Set the current subscription context
    Set-AzContext -Subscription $subscription.Id

    # Get subscription details
    $subscriptionDetails = Get-AzSubscription -SubscriptionName $subscription.Name

    # Get resources with private IP addresses in the current subscription
    $resourcesWithPrivateIPs = Get-AzNetworkInterface | Where-Object { $_.IpConfigurations.PrivateIpAddress -ne $null }

    # Loop through the resources and add them to the results array
    foreach ($resource in $resourcesWithPrivateIPs) {
        $resourceDetails = Get-AzResource -ResourceId $resource.Id

        $results += [PSCustomObject]@{
            SubscriptionName  = $subscriptionDetails.Name
            ResourceGroup     = $resourceDetails.ResourceGroupName
            ResourceName      = $resource.Name
            ResourceType      = $resource.Type
            PrivateIPAddress  = $resource.IpConfigurations.PrivateIpAddress
            SubscriptionId    = $subscriptionDetails.Id
        }
    }
}

# Define the path to the Excel file where you want to save the results
$excelFilePath = "Azure_resource_private_ip_final_list.xlsx"

# Export the results to an Excel file
$results | Export-Excel -Path $excelFilePath -WorksheetName "PrivateIPResources" -AutoSize -Append

# Sign out (optional)
# Disconnect-AzAccount

Write-Host "Results exported to $excelFilePath"
