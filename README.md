# Power BI Deployment Pipelines with Azure DevOps
Sample code and demo material from our presentation Power BI CI/CD with Azure DevOps

## Sections

This repository contains three sections/folders:
* PowerShell Scripts
* Templates
* Slide Deck

### PowerShell Scripts

In the PowerShell Scripts folder you can find some examples of how you can use PowerShell to create Power BI Workspaces and dowload pbix file from a Workspace in Power BI Service

* **Create_PowerBI_SP_Generic.ps1**: generic script that can be used to create a Service Principal in Azure
* **PowerBI-DownloadFileFromWorkspace.ps1**: simple script that can be used to download a pbix file from Power BI Service given the Report Name, Workspace Name and a Target Location
* **PowerBI-CreateWorkspaceAndAddADGroups.ps1**: power shell script that can be used in the pipeline PowerShell task to create workspaces with role based security

### Templates

In the templates folder you can find the csv template that can be used as an input for the PowerBI-CreateWorkspace pipeline.

### Slide Deck

In the Slide Deck folder you can find the presentation file in a pdf format.

## Built With

* [Microsoft Visual Studio Enterprise 2019 ](https://visualstudio.microsoft.com/vs/enterprise/)
* [Windows PowerShell ISE(https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/ise/exploring-the-windows-powershell-ise?view=powershell-7)
* [Azure DevOps](https://azure.microsoft.com/en-ca/services/devops/)
* [Azure](https://azure.microsoft.com/en-ca/)
* [Power BI Desktop](https://powerbi.microsoft.com/en-us/desktop/)
* [Power BI Gateway](https://powerbi.microsoft.com/en-us/gateway/)
* [Power BI Actions](https://marketplace.visualstudio.com/items?itemName=maikvandergaag.maikvandergaag-power-bi-actions)


## Authors

* **Luca Gualtieri** - [LinkedIn](https://www.linkedin.com/in/lucagualtieri/)
* **PBI Lab Inc.** - [PBI Lab](https://www.pbilab.com)

## License

This repository is licensed under the GNU GPL v3.0 License - see the [LICENSE.md](LICENSE.md) file for details.
