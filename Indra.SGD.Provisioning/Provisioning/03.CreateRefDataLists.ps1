param(
    [parameter(position=0)]
    [bool]$pauseIt = $true,

    [parameter(position=1)]
    [bool]$create = $true,

	[parameter(position=2)]
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
$configPathXml = (Get-Location -PSProvider FileSystem).ProviderPath + "\03.CreateRefDataLists.xml"
[xml]$xml = Get-Content $configPathXml -Encoding UTF8


function Delete-List([string]$listName)
{
    $list = $web.Lists[$listName]

    if ($list) {
        
        try {
			$list.AllowDeletion = $true
			$list.Update()
			$list.Delete()
            
			Write-host -foregroundcolor green "Deleted $listName";
            $web.Update();
        }
        catch [Exception]
        {
	        $errorMessage = $_.Exception.Message
	        Write-Host -foregroundcolor red $errorMessage
        }

    }
}

# this frees up all assignments if you end it at end of script 
Start-SPAssignment –Global

try
{
    
    if($config.indraconfiguration.enable -eq 1)
    {
		# Delete-Lists

		if(!$noDelete) {
			ForEach($row in $xml.Templates.Template) {
				
				Delete-List $row.Title
				
			}
		}

        #Create
		if($create) {
			
			Write-Host -foregroundcolor green "Creating Lists"

			ForEach($row in $xml.Templates.Template) {
 
				$listName = $row.Title
				$spTemplate = $web.ListTemplates["Custom List"] 
				$spListCollection = $web.Lists 
				$spListCollection.Add($listName, $listName, $spTemplate) 
				$path = $web.url.trim() 
				$spList = $web.GetList("$path/Lists/$listName")
				
				foreach ($node in $row.Fields.Field) {
				
					$spList.Fields.AddFieldAsXml($node.OuterXml, $true,[Microsoft.SharePoint.SPAddFieldOptions]::AddFieldToDefaultView)
				}
				$spList.Update()
			}
			
			ForEach($row in $xml.Templates.Template) {
 
				$listName = $row.Title
				$spList = $web.GetList("$path/Lists/$listName")

                $dataRows = $row.DataRows	
                $dataRow = $dataRows.DataRow
                $dataFields = $dataRow.Fields
                			

				foreach ($nodeRow in $dataRow.Fields) { 
				   
                   $spItem = $spList.AddItem() 

                   foreach ($itemField in $dataFields.Field) { 			   				      
				       $spItem[$itemField.key] = $itemField.value.ToString() 				   				   
                   }
				   $spItem.Update() 
				}
			}	
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
	if($web)
	{
		$web.Dispose()
	}
	if($site)
	{
		$site.Dispose()
	}
}

# very important to end the assignment of anything from within this script between Start/Stop assignment: 
Stop-SPAssignment –Global

write-host -foregroundcolor green "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"

switch ($pauseIt)
{
    $true
    {
        Pause; break
    }
    default { "Done."; break }
}
