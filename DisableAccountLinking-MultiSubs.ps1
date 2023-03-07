Write-Host "The Account Linking Experience Disablement Process" -ForegroundColor Green

try {
	if (-not (Get-Module -ListAvailable -Name AzureAD)) {
		Install-Module AzureAD -AllowClobber
	}

	if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
		Install-Module Az.Accounts -AllowClobber
	}
}


catch {
	$message = $_
	Write-Warning - Message "Unable to install required module. $message"
	break;
}

Write-Host "If you have multiple subscriptions Please type the subscription ID you want to disable the account linking experience [Enter for Default] " -ForegroundColor Green
$SubID=  Read-Host "Subscription ID"

If ($SubID) {

try {
	$connectedTenant = Connect-AzureAD
	Write-Host $connectedTenant
    $azconnect= Connect-AzAccount
    Write-Host "Setting context to use Subscription ID: $SubID" 
    Set-AzContext -SubscriptionId $SubID


} 
catch {
	Write-Warning "Unable to connect to AzureAD.  Please re-run the script or contact support"
	Write-Error $_
	break;
}
}  Else { 

try {
	$connectedTenant = Connect-AzureAD
	Write-Host $connectedTenant
    $azconnect= Connect-AzAccount
    
   


}
catch {
	Write-Warning "Unable to connect to AzureAD.  Please re-run the script or contact support"
	Write-Error $_
	break;
}
} 

try {
	$tenantInfo=Get-AzureADTenantDetail
	$tenantId=$tenantInfo.objectId
	$tenantDisplayName=$tenantInfo.DisplayName
	$tenantDomain=$tenantInfo.VerifiedDomain
	$token = Get-AzAccessToken
}
catch {
	Write-Warning "Unable to obtain tenant ID. Please re-run the script or contact support"
	Write-Error $_
	break;
}


try {
	$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$headers.Add("Authorization", $token)
	$headers.Add("X-Executor", $connectedTenant.Account)

	$body = "{
	`n  `"TenantName`": `"$tenantDisplayName`",
	`n  `"TenantId`": `"$tenantId`",
	`n  `"Executor`": `"$connectedTenant.Account`",
	`n  `"TenantDomain`": `"$tenantDomain`"
	`n}"

	$response = Invoke-RestMethod 'https://accountlinkingmanagement.azurewebsites.net/api/Disablelinking?code=DjA9zo8eSiXgCjZfz8wBq_A8njKsy0DOEN6C0fC-qqsVAzFufMRIEQ==' -Method 'POST' -Headers $headers -Body $body
	$response | ConvertTo-Json
}
catch {
    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
	Write-Error $_
	Write-Warning "Please re-run the script or contact support"
	break;
}


Write-Host "The Account Linking Experience has been disabled on your tenant" -ForegroundColor Green