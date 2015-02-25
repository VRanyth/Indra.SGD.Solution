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
[xml]$config = Get-Content $configPath
$varsWA = $config.indraconfiguration.webappvariables

#get variables from config xml
$configPathXml = (Get-Location -PSProvider FileSystem).ProviderPath + "\02.CreateContentType.xml"
$list = new-object system.collections.arraylist

function DeleteContentType([string]$contentTypeName)
{
    $ct = $web.ContentTypes[$contentTypeName]

    if ($ct) {
        <#
        $ctusage = [Microsoft.SharePoint.SPContentTypeUsage]::GetUsages($ct)
        foreach ($ctuse in $ctusage) {
            $list = $web.GetList($ctuse.Url)
            $contentTypeCollection = $list.ContentTypes;
            $contentTypeCollection.Delete($contentTypeCollection[$contentType].Id);
            Write-host "Deleted $contentTypeName content type id [$contentTypeCollection[$contentType].Id] from $ctuse.Url"
        }
        #>
        try {
            $ct.Delete()
            Write-host -foregroundcolor green "Deleted $contentTypeName";
            $web.Update();
        }
        catch [Exception]
        {
	        $errorMessage = $_.Exception.Message
	        Write-Host -foregroundcolor red $errorMessage
        }

    }
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

			Write-Host "Deleting ContentTypes"
			[xml]$xml = Get-Content $configPathXml
			foreach($contentType in $xml.Elements.ContentType) 
			{
				try
				{
					#Write-host "Try to delete $contentType content type"
					$contentTypeName = $contentType.Name;
					$list.Add($contentTypeName) > $null;
				}
				catch [Exception]
				{
					$errorMessage = $_.Exception.Message
					Write-Host -foregroundcolor yellow $errorMessage
				}
			}
        
			$list.Reverse();
			foreach($ctype in $list) 
			{
				#Write-Host -foregroundcolor red "ContentType: " $ctype;
				DeleteContentType($ctype);
			}
		}

        #Create
		if($create) {
			Write-Host "Creating ContentTypes"

			#Create Site Content Types
			$xml = [xml](Get-Content($configPathXml))
			foreach($ctype in $xml.Elements.ContentType) 
			{
				#Create Content Type object inheriting from parent
				$spContentType = New-Object Microsoft.SharePoint.SPContentType ($ctype.ID,$web.ContentTypes,$ctype.Name)
				
				#Set Content Type description and group
				$spContentType.Description = $ctype.Description
				$spContentType.Group = $ctype.Group
				
				foreach($fieldref in $ctype.FieldRefs.FieldRef)
                {
					if(!$spContentType.FieldLinks[$fieldref.Name])
					{
						#Create a field link for the Content Type by getting an existing column
						$spFieldLink = New-Object Microsoft.SharePoint.SPFieldLink ($web.Fields.GetFieldByInternalName($fieldref.Name))
					
						#Check to see if column should be Optional, Required or Hidden
						if ($fieldref.Required -eq "TRUE") {$spFieldLink.Required = $true}
						if ($fieldref.Hidden -eq "TRUE") {$spFieldLink.Hidden = $true}
					
						#Add column to Content Type
						$spContentType.FieldLinks.Add($spFieldLink)
					}
				}
				
				#Create Content Type on the site and update Content Type object
				$ct = $web.ContentTypes.Add($spContentType)
				$spContentType.Update()
				write-host "Content type" $ct.Name "has been created"
			}

		}
    }
}
catch [Exception]
{

	$errorMessage = $spContentType.Exception.Message
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

write-host -foregroundcolor green "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"

switch ($pauseIt)
{
    $true
    {
        Pause; break
    }
    default { "Done."; break }
}