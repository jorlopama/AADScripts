 <#Notes 
 SCRIPT TO Delete Phone numbers as authentication method USING GRAPH API
  Author: Jorge Lopez
  1) This is a simple loop reading data from a csv file, you can be as creative as you like using other data sources
  2) This script does NOT validate if a user already has an auth phone defined, if it does it will more likely fail
  3) More logic should be added to validate if a user already has something populated, since a PUT call should be used instead of POST
  4) CSV file needs to have at least 3 headers (userPrincipalName, objectid and authphone) 
      *Userprincipalname = Obvious
      *objectid = of course the objectid from the user
      *authphone = this would be the phone number to populate, needs to have the format : +xx xxx xxx xxxx
      
THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
FITNESS FOR A PARTICULAR PURPOSE.
THIS SAMPLE IS NOT SUPPORTED UNDER ANY MICROSOFT STANDARD SUPPORT PROGRAM OR SERVICE
#>

# Variables that include the resources, clientid and tenant id, importing msal.ps module 
Import-module MSAL.PS
$clientid = "e6d71b10-d674-4879-89b3-065069e10c3a"
$tenantid = "916e52d1-6049-45d7-ba59-46876131ab95"

#Get Access Token using MSAL.ps using interactive switch for delegated access 

$MSALtoken = Get-MsalToken -Interactive -ClientId $clientID -TenantId $tenantID


 #Let's now Import Users info from a CSV File 


 $users = import-csv -Path "path of CSV file"  
 $headers  = @{Authorization = "Bearer $($MSALtoken.accesstoken)" }
 
 #Now that we have a token - Let's POST Authmethods to the users imported from the CSV file  

 #foreach ($user in $users) {
        $objid = $user.objectid 
        #$userprinname = $user.userPrincipalName
        $userprinname = "drew@atlpfe.com"
      
 #PhonemethodID for mobile    
 # mobile :  3179e48a-750b-4051-897c-87b9720928f7 
 

  $apiUrl = "https://graph.microsoft.com/beta/users/$($userprinname)/authentication/phonemethods/3179e48a-750b-4051-897c-87b9720928f7" 
 
             
            #build body for the DELETE command to update auth methods
            $DeleteMobile = @{
            Uri = $apiUrl
            headers  = @{Authorization = "Bearer $($MSALtoken.accesstoken)" }
            method = 'DELETE'
            Contenttype = "application/json" 
       
            }  
           #POST call to Graph 
           $Authmethods = Invoke-RestMethod @DeleteMobile 

#alternate : b6332ec1-7057-4abe-9331-3d72feddfe41

$apiUrl = "https://graph.microsoft.com/beta/users/$($userprinname)/authentication/phonemethods/b6332ec1-7057-4abe-9331-3d72feddfe41" 

$DeleteAlternatemobile = @{
    Uri = $apiUrl
    headers  = @{Authorization = "Bearer $($MSALtoken.accesstoken)" }
    method = 'DELETE'
    Contenttype = "application/json" 

    }  
   #POST call to Graph 
   $Authmethods = Invoke-RestMethod @DeleteAlternatemobile 
    
      #}
