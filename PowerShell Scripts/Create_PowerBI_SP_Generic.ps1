#############################################################################################
#   PowerShell Modules Required
### Microsoft.PowerShell.Management 
### Microsoft.PowerShell.Utility
### Microsoft.PowerShell.Security
### pkiclient
### AzureAD
### MicrosoftPowerBIMgmt.Profile
#############################################################################################

#############################################################################################
#   Open PowerShell with an Administrator account
### Login to Azure AD PowerShell With Admin Account
#############################################################################################

Connect-AzureAD

#############################################################################################
#   Create the self signed cert
#############################################################################################

$currentDate = Get-Date
$endDate  = $currentDate.AddYears(1)
$notAfter  = $endDate.AddYears(1)
##replace with your password
$pwd  = "YOUR_PASSWORD"
##This example creates a self-signed SSL server certificate in the computer MY store with the subject alternative name set to YOUR_DNS_NAME
$CertificateThumbnail = (New-SelfSignedCertificate -CertStoreLocation Cert:\localmachine\my -DnsName YOUR_DNS_NAME -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter).Thumbprint
$pwd = ConvertTo-SecureString -String $pwd -Force -AsPlainText
##This step exports the certificate to a Personal Information Exchange (PFX) file
Export-PfxCertificate -Password $pwd -Cert (Get-Item -Path Cert:\LocalMachine\My\$CertificateThumbnail) -FilePath YOUR_CERTIFICATE_NAME.pfx -Verbose

#############################################################################################
#   Load the certificate
### Load using absolute path
#############################################################################################

$cert  = New-Object System.Security.Cryptography.X509Certificates.X509Certificate("YOUR PATH\YOUR_CERTIFICATE_NAME.pfx", $pwd)
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

#############################################################################################
#   Create the Azure Active Directory Application
#############################################################################################

$application = New-AzureADApplication -DisplayName "YOUR_APPLICATION_NAME" -IdentifierUris "https://YOUR_IDENTIFIER_URI"
New-AzureADApplicationKeyCredential -ObjectId $application.ObjectId -CustomKeyIdentifier "YOUR_CUSTOM_KEY_IDENTIFIER" -StartDate $currentDate -EndDate $endDate -Type AsymmetricX509Cert -Usage Verify -Value $keyValue

#############################################################################################
#   Create the Service Principal and connect it to the Application
#############################################################################################

$sp = New-AzureADServicePrincipal -AppId $application.AppId

#############################################################################################
#   Give the Service Principal Reader access to the current tenant 
#   (Get-AzureADDirectoryRole - Application Administrator)
#############################################################################################

$objectId = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq 'Application Administrator'}
Add-AzureADDirectoryRoleMember -ObjectId $objectId.ObjectId -RefObjectId $sp.ObjectId

#############################################################################################
#   Get Tenant Detail
#############################################################################################

$tenant = Get-AzureADTenantDetail
$TenantObjectID = $tenant.ObjectId

#############################################################################################
#   Get Service Principal Application ID
#############################################################################################

$application = Get-AzureADApplication -Filter "DisplayName eq 'YOUR_APPLICATION_NAME'"
$ServicePrincipalApplicationID = $application.AppId

#############################################################################################
#   Get the Certificate Thumbnail
#############################################################################################

$CertificateThumbnail = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -match "CN=YOUR_DSN_NAME"} | Select-Object -ExpandProperty Thumbprint

#############################################################################################
#   Go to portal.azure.com, App Registrations and delegate permissions for this application
#   API Permissions:
#   Azure Active Directory Graph - Directory.Real.All
#   Power BI Service - Tenant.Read.All / Tenant.ReadWriteAll
#############################################################################################

#############################################################################################
#   Now you can login to Azure PowerShell and Power BI with your Service Principal and Certificate
#############################################################################################

Connect-AzureAD -TenantId $TenantObjectID -ApplicationId $ServicePrincipalApplicationID -CertificateThumbprint $CertificateThumbnail
Connect-PowerBIServiceAccount -ServicePrincipal -CertificateThumbprint $CertificateThumbnail -ApplicationId $ServicePrincipalApplicationID -Tenant $TenantObjectID

#############################################################################################
#   Remember to disconnect
#############################################################################################

Disconnect-PowerBIServiceAccount
Disconnect-AzureAD 

#############################################################################################
# Support Commands:
# 
# Get-ChildItem -path cert:\LocalMachine\My 
# Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -match "CN=YOUR_DNS_NAME"} | Select-Object -ExpandProperty Thumbprint
#############################################################################################