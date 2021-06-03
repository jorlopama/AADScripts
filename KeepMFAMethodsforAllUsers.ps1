#Connect to Azure AD environment
Import-module MSOnline
$Credential = Get-Credential
Connect-MsolService -Credential $Credential

# Disable MFA for all users, keeping their MFA methods intact
#Get-MsolUser -All | Disable-MFA -KeepMethods
 
# Enforce MFA for all users
#Get-MsolUser -All | Set-MfaState -State Enforced 
 
 
# Wrapper to disable MFA with the option to keep the MFA 
# methods (to avoid having to proof-up again later)
function Disable-Mfa {
 
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        $User,
        [switch] $KeepMethods
    )
 
    Process {
 
        Write-Verbose ("Disabling MFA for user '{0}'" -f $User.UserPrincipalName)
        $User | Set-MfaState -State Disabled
 
        if ($KeepMethods) {
            # Restore the MFA methods which got cleared when disabling MFA
            # TODO: Can this be done with the Set-MsolUser called in Set-MfaState?
            Set-MsolUser -ObjectId $User.ObjectId `
                         -StrongAuthenticationMethods $User.StrongAuthenticationMethods
        }
    }
}
 
# Sets the MFA requirement state
function Set-MfaState {
    
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $ObjectId,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $UserPrincipalName,
        [ValidateSet("Disabled","Enabled","Enforced")]
        $State
    )
 
    Process {
        Write-Verbose ("Setting MFA state for user '{0}' to '{1}'." -f $ObjectId, $State)
        $Requirements = @()
        if ($State -ne "Disabled") {
            $Requirement = 
                [Microsoft.Online.Administration.StrongAuthenticationRequirement]::new()
            $Requirement.RelyingParty = "*"
            $Requirement.State = $State
            $Requirements += $Requirement
        }
 
        Set-MsolUser -ObjectId $ObjectId -UserPrincipalName $UserPrincipalName `
                     -StrongAuthenticationRequirements $Requirements
    }
} 

Get-MsolUser -All | Disable-MFA -KeepMethods 
 