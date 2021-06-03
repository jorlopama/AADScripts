#Connect to Azure AD environment
Import-module MSOnline
$Credential = Get-Credential
Connect-MsolService -Credential $Credential

# Save current StrongAuthenticationMethods
# REPLACE USERNAME@DOMAIN.COM with the username you want to perform this against to 
$Methods = (Get-MsolUser -UserPrincipalName USERNAME@DOMAIN.COM).StrongAuthenticationMethods


# Disable MFA by setting the StrongAuthenticationRequirements to an empty array
# This will also remove the StrongAuthenticationMethods
# REPLACE USERNAME@DOMAIN.COM with the username you want to perform this against to 
Set-MsolUser -UserPrincipalName USERNAME@DOMAIN.COM -StrongAuthenticationRequirements @()

# Restore the StrongAuthenticationMethods value that was saved
# REPLACE USERNAME@DOMAIN.COM with the username you want to perform this against to 
Set-MsolUser -UserPrincipalName USERNAME@DOMAIN.COM -StrongAuthenticationMethods $Methods

#$Methods = @()