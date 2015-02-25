param(
    [parameter(position=0)]
    [bool]$pauseIt = $true,

    [parameter(position=1)]
    [bool]$create = $true,

	[parameter(position=4)]
    [bool]$noDelete = $false
)

#add SharePoint cmdlets (if not already loaded)
if ( (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null )
{
    Add-PsSnapin Microsoft.SharePoint.PowerShell
    [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
	[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Publishing")
}

#custom pause function
Function Pause($M="Press any key to continue . . . "){If($psISE){$S=New-Object -ComObject "WScript.Shell";$B=$S.Popup("Click OK to continue.",0,"Script Paused",0);Return};Write-Host -NoNewline $M;$I=16,17,18,20,91,92,93,144,145,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183;While($K.VirtualKeyCode -Eq $Null -Or $I -Contains $K.VirtualKeyCode){$K=$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")};Write-Host}

#set elapsed time variable
$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()

#get variables from config xml
$configPath = (Get-Location -PSProvider FileSystem).ProviderPath + "\00.Configurations.xml"
[xml]$config = Get-Content $configPath -Encoding UTF8
$varsWA = $config.indraconfiguration.webappvariables


#get variables from config xml
$configPathXml = (Get-Location -PSProvider FileSystem).ProviderPath + "\06.CreateEnterpriseFolderHierarchy.xml"
[xml]$xml = Get-Content $configPathXml -Encoding UTF8

$folderCollection = $xml.Structure

Function addFolder($myCustomList , $parentFolderServerRelativeUrl, $folder)
{
        $folder2create = $myCustomList.AddItem($parentFolderServerRelativeUrl, [Microsoft.SharePoint.SPFileSystemObjectType]::Folder, $Folder.name)
        $folder2create.Update();
        $folder2create.BreakRoleInheritance($true)
        
        for ($i = 0; $i -lt $folder2create.RoleAssignments.Groups.Count; $i++)
        {
            $folder2create.RoleAssignments.Groups[$i].ID
            $folder2create.RoleAssignments.Groups.Remove($folder2create.RoleAssignments.Groups[$i].ID)
        }
        
        $folder2create.Update();
    
    foreach($childFolder in $folder.ChildNodes.Folder){ 
        
        addFolder $myCustomList $folder2create.Folder.ServerRelativeUrl $childFolder        
    }
}


$web = Get-SPWeb -Identity $varsWA.URL.value
$myCustomList = $web.Lists["Documentos"]

foreach($node in $folderCollection.Folders.Folder)
{
    addFolder $myCustomList $myCustomList.RootFolder.ServerRelativeUrl $node
}


try
{

    if($config.indraconfiguration.enable -eq 1)
    {
        #use Start-SPAssignment to ensure that all objects are disposed of correctly.
        Start-SPAssignment –Global

        $site =  New-Object Microsoft.SharePoint.SPSite($varsWA.URL.value);
        $web = $site.RootWeb

        #Delete
		if(!$noDelete) {
	        Write-Host "Deleting..."
				
		}

		#Create
		if($create) {
			   

        }
	}
}
catch [Exception]
{
	$errorMessage = $_.Exception.Message
	Write-Host $errorMessage
}
finally
{
	if($web){ $web.Dispose() }
	if($site){ $site.Dispose() }
}

write-host -foregroundcolor green "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"

switch ($pauseIt)
{
    $true
    {
        Pause; break
    }
    default { "Done."; break }
}