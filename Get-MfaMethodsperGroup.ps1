## Script to Get MFa Methods from User Group in AAD using MGGraph  
# AUTHOR:Jorge Lopez (jorlop@microsoft.com) 
#
# THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
# FITNESS FOR A PARTICULAR PURPOSE.
#
# This sample is not supported under any Microsoft standard support program or service. 
# The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
# implied warranties including, without limitation, any implied warranties of merchantability
# or of fitness for a particular purpose. The entire risk arising out of the use or performance
# of the sample and documentation remains with you. In no event shall Microsoft, its authors,
# or anyone else involved in the creation, production, or delivery of the script be liable for 
# any damages whatsoever (including, without limitation, damages for loss of business profits, 
# business interruption, loss of business information, or other pecuniary loss) arising out of 
# the use of or inability to use the sample or documentation, even if Microsoft has been advised 
# of the possibility of such damages.
################################################################################################


$results_List = @()
Select-MgProfile -Name "beta"
Connect-MgGraph -Scopes "UserAuthenticationMethod.Read.All","Group.Read.All"
$GroupID = 'Group_Object_ID'
$Group_Members = Get-MgGroupMember -groupid $groupID | ForEach-Object { Get-MgUser -UserId $_.Id }

 foreach ($User in $Group_Members) {
            try {
                $DeviceList = Get-MgUserAuthenticationMethod -User $User.Id -ErrorAction Stop
                $DeviceOutput = foreach ($Device in $DeviceList) {
 
                    #Converting long method to short-hand human readable method type.
                    switch ($Device.AdditionalProperties["@odata.type"]) {
                        '#microsoft.graph.microsoftAuthenticatorAuthenticationMethod'  {
                            $MethodAuthType     = 'AuthenticatorApp'
                            $AdditionalProperties = $Device.AdditionalProperties["displayName"]
                        }
 
                        '#microsoft.graph.phoneAuthenticationMethod'                   {
                            $MethodAuthType     = 'PhoneAuthentication'
                            $AdditionalProperties = $Device.AdditionalProperties["phoneType", "phoneNumber"] -join ' '
                        }
 
                        '#microsoft.graph.passwordAuthenticationMethod'                {
                            $MethodAuthType     = 'PasswordAuthentication'
                            $AdditionalProperties = $Device.AdditionalProperties["displayName"]
                        }
 
                        '#microsoft.graph.fido2AuthenticationMethod'                   {
                            $MethodAuthType     = 'Fido2'
                            $AdditionalProperties = $Device.AdditionalProperties["model"]
                        }
 
                        '#microsoft.graph.windowsHelloForBusinessAuthenticationMethod' {
                            $MethodAuthType     = 'WindowsHelloForBusiness'
                            $AdditionalProperties = $Device.AdditionalProperties["displayName"]
                        }
 
                        '#microsoft.graph.emailAuthenticationMethod'                   {
                            $MethodAuthType     = 'EmailAuthentication'
                            $AdditionalProperties = $Device.AdditionalProperties["emailAddress"]
                        }
 
                        '#microsoft.graph.temporaryAccessPassAuthenticationMethod'        {
                            $MethodAuthType     = 'TemporaryAccessPass'
                            $AdditionalProperties = 'TapLifetime:' + $Device.AdditionalProperties["lifetimeInMinutes"] + 'm - Status:' + $Device.AdditionalProperties["methodUsabilityReason"]
                        }
 
                        '#microsoft.graph.passwordlessMicrosoftAuthenticatorAuthenticationMethod' {
                            $MethodAuthType     = 'Passwordless'
                            $AdditionalProperties = $Device.AdditionalProperties["displayName"]
                        }
 
                        '#microsoft.graph.softwareOathAuthenticationMethod' {
                            $MethodAuthType     = 'SoftwareOath'
                            $AdditionalProperties = $Device.AdditionalProperties["displayName"]
                        }
                    }
 
                    [PSCustomObject]@{
                        UserPrincipalName      = $User.UserPrincipalName
                        AuthenticationMethodId = $Device.Id
                        MethodType             = $MethodAuthType
                        AdditionalProperties   = $AdditionalProperties
                    }
                }
 
                if ($PSBoundParameters.ContainsKey('MethodType')) {
                    $DeviceOutput | Where-Object {$_.MethodType -in $MethodType}
                  } else {
                    $DeviceOutput
                }
 
            } catch {
                Write-Error $_.Exception.Message
 
            } finally {
                $DeviceList           = $null
                $MethodAuthType       = $null
                $AdditionalProperties = $null
 
            }
        }
$results_List += $results
$results_List  | Export-csv -Path .\UsersStrongAuthMethods.csv
