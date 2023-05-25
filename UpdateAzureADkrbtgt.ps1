Import-Module ActiveDirectory

$domainDn = (get-addomaincontroller).DefaultPartition
Write-Host "+ DomainDN : $($domainDn)"

try {
    $adminSDHolderDn = "{0},{1}" -f "CN=AdminSDHolder,CN=System", $domainDn
    $adminSDHolderAcl = get-ACL "AD:\$adminSDHolderDn" -ErrorAction Stop
}
catch {
    Write-Host -ForegroundColor Red "+ Unable to get AdminSD Holder security descriptor."
    exit -1
}

try {
    $krbAzureADDn = "{0},{1}" -f "CN=krbtgt_AzureAD,CN=Users", $domainDn
    $krbAzureADCurrentAcl = get-ACL "AD:\$krbAzureADDn" -ErrorAction Stop
}
catch {
    Write-Host -ForegroundColor Red "+ Unable to get krbtgt_AzureAD security descriptor."
    exit -1
}

$backupSDDLFilePath = Join-Path $env:UserProfile "Documents\krbtgt_AzureAD_initialSDDL_$([DateTime]::Now.ToString("yyyy-MM-ddThh-mm-ss")).txt"
$krbAzureADCurrentAcl.Sddl | Out-File $backupSDDLFilePath -Encoding ascii 
Write-Host "+ Current SD written to : $($backupSDDLFilePath)"

$krbAzureADNewAcl = new-object "System.DirectoryServices.ActiveDirectorySecurity"
$krbAzureADNewAcl.SetSecurityDescriptorBinaryForm($adminSDHolderAcl.GetSecurityDescriptorBinaryForm(), [System.Security.AccessControl.AccessControlSections]::Access)

Write-Host "+ Writing new SD."
Set-Acl "AD:\$krbAzureADDn" -AclObject $krbAzureADNewAcl