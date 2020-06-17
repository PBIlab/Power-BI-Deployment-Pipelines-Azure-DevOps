#############################################################################################
#   PowerShell Modules Required
### Microsoft.PowerShell.Utility
### Microsoft.PowerShell.Management
### MicrosoftPowerBIMgmt.Profile
### MicrosoftPowerBIMgmt.Workspaces
### MicrosoftPowerBIMgmt.Reports
#############################################################################################

##This Script is used to download the pbix from the Power BI Service given the Report Name, Workspace Name and that a Target Location is available

#connect to the service
Connect-PowerBIServiceAccount

#prompt to enter name of workspace
$WorkspaceName = Read-Host "Enter Workspace Name"

#prompt if tenant admin
$RoleAdmin = (Read-Host "Are you tenant Admin? (Y/N)").ToUpper()

if($RoleAdmin -eq "Y") {

#search for active instances of the workspace (as tenant admin, you'll have visibility to deleted workspaces as well) and retrieve details for it
$WorkspaceItems = Get-PowerBIWorkspace -Scope Organization -Filter "state eq 'Active' and name eq '$WorkspaceName'"

} else {

#search for the workspace (as non-tenant admin, you'll have visibility only to active workspaces) and retrieve details for it
$WorkspaceItems = Get-PowerBIWorkspace -Scope Individual -Name $WorkspaceName
} 

#Using the workspace name, lookup the workspace id
$WorkspaceID = $WorkspaceItems.Id

#prompt to enter name of the power bi report (WITHOUT .PBIX)
$ReportName = Read-Host "Enter Report Name here"

#using report name search for the report in the identified workspace and retrieve details for it
$ReportItems = Get-PowerBIReport -Name $ReportName -WorkspaceId $WorkspaceID

#Using the report name, lookup the report id
$ReportID = $ReportItems.Id

#prompt to enter location/file name to save the pbix to/as
##this should be the folder for the corresponding BU-Site
$Outfile = Read-Host "Enter Fully Qualified Export File Path"

#check if the file you want to download already exists in your path
$fileToCheck = $Outfile

if (Test-Path $fileToCheck -PathType leaf)
{
    $fileDelete = (Read-Host "File already exists. Do you want to delete it and export again? (Y/N)").ToUpper()
    
##if the file exists and we want to remove the file and download a new version
    if($fileDelete -eq "Y") {

        Remove-Item $fileToCheck

        #Export pbix file with corresponding report id from corresponding workspace id to the defined output location
        Export-PowerBIReport -Id $ReportId -OutFile $Outfile -WorkspaceId $WorkspaceId

    }  

##if the file exists and we don't want to download the new version; we just write a message and don't download it from the service   
    else {

        write-host("Exiting without downloading. Check the file $Outfile to ensure is the required version")

    } 
    
}
#the file doesn't exist; we download it form the Service
else
{

    #Export pbix file with corresponding report id from corresponding workspace id to the defined output location
    Export-PowerBIReport -Id $ReportId -OutFile $Outfile -WorkspaceId $WorkspaceId

}

Disconnect-PowerBIServiceAccount