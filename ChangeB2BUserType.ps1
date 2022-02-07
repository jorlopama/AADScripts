<#
.SYNOPSIS 
    This Azure Automation runbook finds all members of an Azure AD Security Group and changes the usertype to guest for those who are set as Member.
	We're using PowerShell for Microsoft Graph 
    AUTHOR: Jorge Lopez
    LASTEDIT: January 2022  
#>

#Obtain AccessToken for Microsoft Graph via the managed identity/Define Other Variables
$resourceURI = "https://graph.microsoft.com/"
$tokenAuthURI = $env:IDENTITY_ENDPOINT + "?resource=$resourceURI&api-version=2019-08-01"
$tokenResponse = Invoke-RestMethod -Method GET -Headers @{"X-IDENTITY-HEADER"="$env:IDENTITY_HEADER"} -Uri $tokenAuthURI
$accessToken = $tokenResponse.access_token
$UTmemberscount = 0
$Userschanged = 0

#Define the desired graph endpoint
Select-MgProfile -Name 'beta'

#Connect to the Microsoft Graph using the aquired AccessToken
Connect-Graph -AccessToken $accessToken

#Get group name and Group Members
$groupName = (Get-MGGroup -groupid '52b04e8f-0f11-4866-a25e-bcdd9f7993e7').displayName
$Group_Members = Get-MgGroupMember -groupid '52b04e8f-0f11-4866-a25e-bcdd9f7993e7' | ForEach-Object { Get-MgUser -UserId $_.Id }
$Group_Members_count = $Group_Members.count

Write-Output ("Checking members of group $groupName")

foreach ($user in $Group_Members)
{ 

if ($user.UserType -eq 'Member') { 
   Update-MgUser -UserId $user.UserPrincipalName -UserType "Guest" 
   $userUPN = $user.UserPrincipalName
   Write-Output ("Converted "+ $userUPN + " to Guest User") 
   $Userschanged++
 }
 else {
  $UTmemberscount++
 }

}

Write-Output ("Users changed to Guest: $Userschanged")
Write-Output ("Users not Changed: $UTmemberscount")
Write-Output ("Total Users Checked: $Group_Members_count")