 <#Notes 
 SCRIPT TO PRE-POPULATE AZUREAD AUTHENTICATION METHODS (MFA) USING GRAPH API
  Author: Jorge Lopez
  1) This is a simple loop reading data from a csv file, you can be as creative as you like using other data sources
  2) This script does NOT validate if a user already has an auth phone defined, if it does it will more likely fail
  3) More logic should be added to validate if a user already has something populated, since a PUT call should be used instead of POST
  4) CSV file needs to have at least 3 headers (userPrincipalName, objectid and authphone) 
      *Userprincipalname = Obvious
      *objectid = of course the objectid from the user
      *authphone = this would be the phone number to populate, needs to have the format : +xx xxx xxxx
      
THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
FITNESS FOR A PARTICULAR PURPOSE.
THIS SAMPLE IS NOT SUPPORTED UNDER ANY MICROSOFT STANDARD SUPPORT PROGRAM OR SERVICE
#>

# Variables that include the resources, clientid and tenant id, importing msal.ps module 
Import-module MSAL.PS
$clientid = "Add your clientid here "
$tenantid = "Add your TenantId here"

#Get Access Token using MSAL.ps using interactive switch for delegated access 

$MSALtoken = Get-MsalToken -Interactive -ClientId $clientID -TenantId $tenantID


 #Let's now Import Users info from a CSV File 


 $users = import-csv -Path "path of CSV file"  
 $headers  = @{Authorization = "Bearer $($MSALtoken.accesstoken)" }
 
 #Now that we have a token - Let's POST Authmethods to the users imported from the CSV file  

 foreach ($user in $users) {
        $objid = $user.objectid 
        $userprinname = $user.userPrincipalName
        $authphone = $user.authphone
    
            $AuthPhoneArray = @{
                "phoneType" = "mobile"
                "phonenumber" = $authphone; 
            
            } 
  
            $AuthPhonebody = $AuthPhoneArray | ConvertTo-JSON  
    
  $apiUrl = "https://graph.microsoft.com/beta/users/$($userprinname)/authentication/phonemethods/" 
             
            #build body for the POST command to update auth methods
            $updatephoneparams = @{
            Uri = $apiUrl
            headers  = @{Authorization = "Bearer $($MSALtoken.accesstoken)" }
            method = 'POST'
            Body = $AuthPhonebody
            Contenttype = "application/json" 
       
            }  
           #POST call to Graph 
           $Authmethods = Invoke-RestMethod @updatephoneparams 

    
      }
