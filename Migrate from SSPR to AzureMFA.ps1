#Connect to Azure AD environment
Import-module MSOnline
$Credential = Get-Credential
Connect-MsolService -Credential $Credential

$upn = "<<UPN>>"

#Save Enabled status to sta array   
$st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$st.RelyingParty = "*"
$st.State = "Enabled"
$sta = @($st)

#Assign voice mobile to SM1 variable 
$sm1 = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
$sm1.IsDefault = $true
$sm1.MethodType = "TwoWayVoiceMobile"
$sm = @($sm1)

#Set methods on User 
Set-MsolUser -UserPrincipalName $upn -StrongAuthenticationRequirements $sta -StrongAuthenticationMethods $sm


#From here , we will save methods, disable the user from mfa per-user, and restore methods while keeping user disabled
# Save current StrongAuthenticationMethods
$Methods = (Get-MsolUser -UserPrincipalName upn@domain.com).StrongAuthenticationMethods


# Disable MFA by setting the StrongAuthenticationRequirements to an empty array
# This will also remove the StrongAuthenticationMethods
Set-MsolUser -UserPrincipalName clouduser1@atlpfe.com -StrongAuthenticationRequirements @()

# Restore the StrongAuthenticationMethods value that was saved
Set-MsolUser -UserPrincipalName clouduser1@atlpfe.com -StrongAuthenticationMethods $Methods 
