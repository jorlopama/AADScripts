# Variables that include the resources, clientid and tenant id, importing msal.ps module 
Import-module MSAL.PS
$clientid = "e6d71b10-d674-4879-89b3-065069e10c3a"
$tenantid = "916e52d1-6049-45d7-ba59-46876131ab95"

#GEt Access Token using MSAL.ps using interactive switch for delegated access 

#$MSALtoken = Get-MsalToken -Interactive -ClientId $clientID -TenantId $tenantID


 #Let's now Import Users info from a CSV File 
 #NOTE: This is where you can get creative and use other API's or integrations to your own source of data.

 $users = import-csv -Path "C:\Users\jorlop\OneDrive - Microsoft\Scripts\AZure\jorge.csv"  
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
    #  $apiUrl = "https://graph.microsoft.com/beta/users/$objid/authentication/phoneMethods/3179e48a-750b-4051-897c-87b9720928f7"

    #$Authmethods = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/users/$($userprinname)/authentication/phonemethods/" -Method Post -Headers $headers -Body $AuthPhonebody
              
            #build body for the POST command to update auth methods
            $updatephoneparams = @{
            Uri = $apiUrl
            headers  = @{Authorization = "Bearer $($MSALtoken.accesstoken)" }
            method = 'POST'
            Body = $AuthPhonebody
            Contenttype = "application/json" 
       
            }  
           $Authmethods = Invoke-RestMethod @updatephoneparams 
#>
    
      }