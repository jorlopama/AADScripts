<#
.SYNOPSIS
Get List of Users who haven't singed-in in more than 180 
.DESCRIPTION
Use App registration to connect to Graph API and get the LastLoginDate value
.NOTES
Written by Jorge Lopez (MSFT) 
Instructions: Change the ClientID / Tenant ID / Secret in the next session . Optional you can change the number of days to consider stale. 

#>
 
# VARIABLES - Populate with the values of the App registration created in Azure AD / Change the LastSignInDate value. 
$clientID = "01f29cbb-fdd7-4c48-ac1d-c45f675bd8c6"
$ClientSecret = ".t37kt~V4ql7Gm4yZ7Jtk1-Qa.Hyp-VW88"
$Tenant = "pfecube.onmicrosoft.com"
$resource = "https://graph.microsoft.com"
$LastSignIndate = '2020-06-01T00:00:00Z'
$Output = (Get-Date -Format yyyy-MM-dd) + "_AADStaleAccounts.csv"
 
$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $clientID
    Client_Secret = $clientSecret
} 
 
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
 
# Construct URI to query Graph to find users where lastSignInDateTime less or equal than $Date

$uri = 'https://graph.microsoft.com/beta/users?filter=signInActivity/lastSignInDateTime le '+ $LastSignIndate

#$uri = 'https://graph.microsoft.com/beta/users?$select=displayName,userPrincipalName,signInActivity'
 
# If the result is more than 999, we need to read the @odata.nextLink to show more than one side of users



$GraphQuery = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $uri -Method Get

# Set the result into an variable
$StaleUsers = ($GraphQuery | select-object Value).Value


$Data = $StaleUsers | select DisplayName,UserPrincipalName,@{n="LastLoginDate";e={$_.signInActivity.lastSignInDateTime}}

$Data | Export-Csv -NoTypeInformation -Path $Output
 




<#

[datetime]::Parse('2020-04-07T16:55:35Z')
 
# Export data and pipe to Out-GridView for copy to Excel
$Export | select DisplayName,UserPrincipalName,@{Name='LastLoginDate';Expression={[datetime]::Parse($_.LastLoginDate)}} | Out-GridView
 
# Export and filter result based on domain name (Update the domainname)
$Export | Where-Object {$_.userPrincipalName -match "alden365.se"} | select DisplayName,UserPrincipalName,@{Name='LastLoginDate';Expression={[datetime]::Parse($_.LastLoginDate)}}

#>