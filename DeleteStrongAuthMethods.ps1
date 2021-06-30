 <#Notes 
 SCRIPT TO Delete Phone numbers as authentication method USING GRAPH API
  Author: Jorge Lopez
  1) This is a simple loop reading data from a csv file, you can be as creative as you like using other data sources
  2) This script does NOT validate if a user already has an auth phone defined or deleted
    4) CSV file needs to have at least 3 headers (userPrincipalName, objectid and authphone) 
      *Userprincipalname = Obvious
  
      
THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
FITNESS FOR A PARTICULAR PURPOSE.
THIS SAMPLE IS NOT SUPPORTED UNDER ANY MICROSOFT STANDARD SUPPORT PROGRAM OR SERVICE
#>

# Variables that include the resources, clientid and tenant id, importing msal.ps module 
Import-module MSAL.PS
$clientid = "Type your ClientID Here"
$tenantid = "Type your tenantid here "

#Get Access Token using MSAL.ps using interactive switch for delegated access 

$MSALtoken = Get-MsalToken -Interactive -ClientId $clientID -TenantId $tenantID


 #Let's now Import Users info from a CSV File 


 $users = import-csv -Path "path of CSV file"  
 $headers  = @{Authorization = "Bearer $($MSALtoken.accesstoken)" }
 
 #Now that we have a token - Let's POST Authmethods to the users imported from the CSV file  

 foreach ($user in $users) {
        $objid = $user.objectid 
        $userprinname = $user.userPrincipalName
        
      
 #SECTION TO REMOVE ALTERNATE PHONE AS AUTHENTICATION METHOD
 # mobile id: 3179e48a-750b-4051-897c-87b9720928f7 
 

  $apiUrl = "https://graph.microsoft.com/beta/users/$($userprinname)/authentication/phonemethods/3179e48a-750b-4051-897c-87b9720928f7" 
 
             
            #build body for the DELETE command to update auth methods
            $DeleteMobile = @{
            Uri = $apiUrl
            headers  = @{Authorization = "Bearer $($MSALtoken.accesstoken)" }
            method = 'DELETE'
            Contenttype = "application/json" 
       
            }  
           #delete call to Graph 
           $Authmethods = Invoke-RestMethod @DeleteMobile 

# SECTION TO REMOVE ALTERNATE PHONE AS AUTHENTICATION METHOD
#alternate : b6332ec1-7057-4abe-9331-3d72feddfe41

$apiUrl = "https://graph.microsoft.com/beta/users/$($userprinname)/authentication/phonemethods/b6332ec1-7057-4abe-9331-3d72feddfe41" 

$DeleteAlternatemobile = @{
    Uri = $apiUrl
    headers  = @{Authorization = "Bearer $($MSALtoken.accesstoken)" }
    method = 'DELETE'
    Contenttype = "application/json" 

    }  
   #delete call to Graph 
   $Authmethods = Invoke-RestMethod @DeleteAlternatemobile 
    
     }
