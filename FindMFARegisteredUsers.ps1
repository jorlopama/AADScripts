#Connect to Azure AD environment
Import-module MSOnline
Import-Module ActiveDirectory
Connect-MsolService -Credential $Credential

#Create new object with requested information of the users.
$Array = New-Object PSObject
$Array | Add-Member -MemberType NoteProperty –name UserPrincipalName –value NotSet
$Array | Add-Member -MemberType NoteProperty –name sAMAccountName –value NotSet
$Array | Add-Member -MemberType NoteProperty –name Enforced –value NotSet
$Array | Add-Member -MemberType NoteProperty –name Default –value NotSet
$Array | Add-Member -MemberType NoteProperty –name AlternativePhoneNumber –value NotSet
$Array | Add-Member -MemberType NoteProperty –name Email –value NotSet
$Array | Add-Member -MemberType NoteProperty –name PhoneNumber –value NotSet


#Get Users Enrolled in MFA
$MFAUSERS = Get-MsolUser -all| Where{$_.StrongAuthenticationMethods -ne $null} | select UserPrincipalName,StrongAuthenticationMethods,StrongAuthenticationPhoneAppDetails,StrongAuthenticationRequirements,StrongAuthenticationUserDetails



#Loop to create Array of Users and Query Local AD for additional Attributes Mapping
$Array = ForEach($User in $MFAUSERS){
    
    
    $UserData = New-Object PS$Object
    $UserData | Add-Member -MemberType NoteProperty –name UserPrincipalName –value NotSet
    $UserData | Add-Member -MemberType NoteProperty –name sAMAccountName –value NotSet
    $UserData | Add-Member -MemberType NoteProperty –name Enforced –value NotSet
    $UserData | Add-Member -MemberType NoteProperty –name Default –value NotSet
    $UserData | Add-Member -MemberType NoteProperty –name AlternativePhoneNumber –value NotSet
    $UserData | Add-Member -MemberType NoteProperty –name Email –value NotSet
    $UserData | Add-Member -MemberType NoteProperty –name PhoneNumber –value NotSet
  
  
    #Fill all values
	$UserData.UserPrincipalName = $User.UserPrincipalName

    $TempUser = $User.UserPrincipalName
    $Temp = Get-ADUser -Filter { UserPrincipalName -Eq $TempUser }
    $UserData.sAMAccountName = $Temp.SamaccountName


   	$Temp = $User.StrongAuthenticationRequirements 
 	$UserData.Enforced = $Temp.State
	
    $Temp = $User.StrongAuthenticationMethods
    $Temp = $Temp | Where{$_.IsDefault -eq "True"} | Select MethodType
	$UserData.Default = $Temp.MethodType
	

	$Temp = $User.StrongAuthenticationUserDetails
	
    
	$UserData.AlternativePhoneNumber = $Temp.AlternativePhoneNumber
	$UserData.Email = $Temp.Email
	$UserData.PhoneNumber = $Temp.PhoneNumber
	
	$UserData 
}


$OutputUsers | Out-File -FilePath ".\FindMFARegisteredUsers.log"
$Array | export-csv -Path ".\MFARegisteredUserstest.csv" -NoTypeInformation
