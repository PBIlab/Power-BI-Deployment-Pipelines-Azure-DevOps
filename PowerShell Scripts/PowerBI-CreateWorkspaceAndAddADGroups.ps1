#############################################################################################
#   PowerShell Modules Required
### Microsoft.PowerShell.Utility *
### Microsoft.PowerShell.Management *
### Microsoft.PowerShell.Security *
### pkiclient *
### PowerShellGet *
### MicrosoftPowerBIMgmt.Profile *
### MicrosoftPowerBIMgmt.Workspaces *
### MicrosoftPowerBIMgmt.Reports
### AzureAD *
#############################################################################################

##################################
# Section 1
## Connect to Power BI Instance
##################################

#Locate and get the Certificate stored in the Azure DevOps Repo in order to authenticate access for the service principal
## The certificate path is stored in the pipeline as a variable
$Certificate = Get-Item -Path $(Build.SourcesDirectory)$env:CERTIFICATE

#Convert the certificate password to a secure string
##The password is stored as a "secret" variable in the pipeline
$pwd = ConvertTo-SecureString -String $env:CERTIFICATEPASSWORD -Force -AsPlainText

#Import the certificate into this PowerShell instance using the file and the password
Import-PfxCertificate -FilePath $Certificate -CertStoreLocation Cert:\LocalMachine\My -Password $pwd

#Install the PowerBI Module to this powershell instance
Install-Module -Name MicrosoftPowerBIMgmt -Force -Verbose -Scope CurrentUser

#Connect to the Power BI instance as a Service Principal
##Certificate Thumbprint, Service Principal App ID and Tenant Object ID are all stored as secret variables within the pipeline
Connect-PowerBIServiceAccount -ServicePrincipal -CertificateThumbprint $env:CERTIFICATETHUMBPRINT -ApplicationId $env:SERVICEPRINCIPALAPPID -Tenant $env:TENANTOBJECTID

#############################################################################
# Section 2
## Get content from the template filed stored in Azure git
### File Should be stored in the correct location and name 
#### including file extension- is entered as a variable within the pipeline
#############################################################################

$Files = Get-Content -Path $(Build.SourcesDirectory)$env:WORKSPACEDETAILSFILE

#Loop through different rows in file
Foreach ($File in $Files)
{
    #Split each row and define variable values for WorkspaceName, ADGroup and Role
    $WorkspaceName,$ADGroup,$Role = $file.split(',')

    #Check to see if the workspace already exists; if not, create the workspace

    #Using the Workspace Name as an input, if the workspace exists pull the details for it
    ##NOTE the Service Principal will only have visibility to workspaces that it is an admin of
    $WorkspaceDetails = Get-PowerBIWorkspace -Filter "name eq '$WorkspaceName'"

    if($WorkspaceDetails.Id -like "*-*"   ){
    #If active workspace exists, provide text response and continue 
        write-host("$WorkspaceName Already Exists")
    }

    #If active workspace does not exist, create new workspace
    else {
        New-PowerBIWorkspace -Name $WorkspaceName
    }

    #checking for the workspace and get details again
    ##this step has to be repeated as if it is a new workspace, it would have brought up null values previously
    $WorkspaceDetails = Get-PowerBIWorkspace -Filter "name eq '$WorkspaceName'"

    #derive workspace id from the workspace details
    $WorkspaceID = $WorkspaceDetails.Id

    #############################################################################
    # Section 3
    ##Security configuration: add AD Groups and roles
    #############################################################################

    #Set principal type to group as we are adding an AD group and not a user
    $PrincipalType = "Group"  

    #Install the Azure AD module to this instance of PowerShell
    #This had to be run within the loop as the module was conflicting with the power bi module in this instance
    Install-Module AzureAD -Force  -Scope CurrentUser

    #connect to Azure AD
    Connect-AzureAD -TenantId $env:TENANTOBJECTID -ApplicationId  $env:SERVICEPRINCIPALAPPID -CertificateThumbprint $env:CERTIFICATETHUMBPRINT

    #get AD group details for the specified AD Group Name
    $AdGroupDetails = Get-AzureADGroup -Filter "DisplayName eq '$ADGroup'"

    #derive AD Group Object id from the AD Group details
    $AdGroupID = $AdGroupDetails.ObjectId

    #create body to be used and invoke rest api call
    #This api call will add the respective AD group and roles to the corresponding workspaces
    $body = '{"identifier": "' + $AdGroupID + '","groupUserAccessRight": "' + $Role + '","principalType": "' + $PrincipalType + '"}'
    Invoke-PowerBIRestMethod -Url ('groups/' + $WorkspaceID + ' /users') -Method POST -Body $body
}

#disconnect from Azure AD and from the PBI service
Disconnect-PowerBIServiceAccount
Disconnect-AzureAD 