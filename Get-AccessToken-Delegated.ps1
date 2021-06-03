# Variables that include the resources, clientid and secret created when registering the app in AAD 
$resource = "https://graph.microsoft.com"
$clientid = "f39ed636-9a2f-4f3e-b6aa-b1c2266bf7c1"
$clientSecret = "m17slsPnA4u54P.nc~1VNinQ7~D1K6I__3"
$redirectUri = "https://localhost:8080"
$scope = "https://graph.microsoft.com/.default"
$tenant = "pfecube.onmicrosoft.com"
$tenantid = "916e52d1-6049-45d7-ba59-46876131ab95"
$state = get-random
Add-Type -AssemblyName System.Windows.Forms


# We will use the System.web for URL Encoding
Add-Type -AssemblyName System.Web
$clientIDEncoded = [System.Web.HttpUtility]::UrlEncode($clientid)
$clientSecretEncoded = [System.Web.HttpUtility]::UrlEncode($clientSecret)
$redirectUriEncoded =  [System.Web.HttpUtility]::UrlEncode($redirectUri)
$resourceEncoded = [System.Web.HttpUtility]::UrlEncode($resource)
$scopeEncoded = [System.Web.HttpUtility]::UrlEncode($scope)
$tenantEncoded = [System.Web.HttpUtility]::UrlEncode($tenant)

# We first need to take an authorization request for the user (Remember - this only supports delegated access for now)

$AuthZ_uri = "https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&redirect_uri=$redirectUriEncoded&client_id=$clientid&resource=$resourceencoded&prompt=admin_consent&scope=$scopeEncoded"
             #"https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&redirect_uri=$redirectUriEncoded&client_id=$clientid&resource=$resourceencoded&prompt=admin_consent&state=$state&scope=$scopeEncoded" 
             #"https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&redirect_uri=$redirectUriEncoded&client_id=$clientID&resource=$resourceEncoded&prompt=admin_consent&scope=$scopeEncoded"

#Let's create a windows for the user to sign in 

 # Function to popup Auth Dialog Windows Form.
 function Get-AuthCode {
    Add-Type -AssemblyName System.Windows.Forms
    $Form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width = 440; Height = 640 }
    $Web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width = 420; Height = 600; Url = ($AuthZ_uri  -f ($Scope -join "%20")) }
    $DocComp = {
        $Global:uri = $Web.Url.AbsoluteUri        
        if ($Global:uri -match "error=[^&]*|code=[^&]*") { $Form.Close() }
    }

    $Web.ScriptErrorsSuppressed = $true
    $Web.Add_DocumentCompleted($DocComp)
    $Form.Controls.Add($Web)
    $Form.Add_Shown( { $Form.Activate() })
    $Form.ShowDialog() | Out-Null
    $QueryOutput = [System.Web.HttpUtility]::ParseQueryString($Web.Url.Query)
    $Output = @{ }

    foreach ($Key in $QueryOutput.Keys) {
        $Output["$Key"] = $QueryOutput[$Key]
    }

    #$Output
}

Get-AuthCode
# Extract Access token from the returned URI
$regex = '(?<=code=)(.*)(?=&)'
$AuthZ_code  = ($uri | Select-string -pattern $regex).Matches[0].Value

# we will now start constructing the body and the array for the POST command to retrieve the Access Token using the AuthCode
$Access_token_Body ="grant_type=authorization_code&redirect_uri=$redirectUri&client_id=$clientId&client_secret=$clientSecretEncoded&code=$AuthZ_code&resource=$resource"
   
#We will now make the POST request to aquire a token
$tokenResponse = Invoke-RestMethod https://login.microsoftonline.com/common/oauth2/token `
    -Method Post -ContentType "application/x-www-form-urlencoded" `
    -Body $Access_token_body `
    -ErrorAction STOP

$tokenResponse.access_token