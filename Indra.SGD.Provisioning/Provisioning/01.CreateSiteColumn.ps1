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
$configPathXml = (Get-Location -PSProvider FileSystem).ProviderPath + "\01.CreateSiteColumn.xml"
[xml]$xml = Get-Content $configPathXml -Encoding UTF8


  function Delete-Column {
    param( [parameter(mandatory=$true)][string]$fieldName)
    try {
        $f = $web.Fields.GetField($fieldName)
        if($f.ReadOnlyField -eq $true) {
            $f.ReadOnlyField = $false
            $f.Update()
        }
        $web.Fields.delete($fieldName)
        $web.Update()
    } catch [Exception] { }
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
	        Write-Host "Deleting Columns"
			foreach($field in $xml.Elements.Field) 
			{
				try
				{
					$web.Fields.delete($field.StaticName)
					$web.Update()
				}
				catch [Exception]
				{
					$errorMessage = $_.Exception.Message
					if(-not $errorMessage -eq "Value does not fall within the expected range.") {
						Write-Host -foregroundcolor yellow $errorMessage
					}
				}
			}
			#remove duplicated fields
			#Delete-Column "hb3da0620f9e44afac2f7a5012e9f32d"
			#$web.Update()			
		}

		#Create
		if($create) {
			   
                Write-Host "Creating Columns"
                
                ForEach($row in $xml.Elements.Field) {
 
                # Assign fieldXML variable with XML string for Site Column
                $fieldXML = $row.OuterXml
 
                # Output XML to console
                write-host $fieldXML
 
                # Create Site Column from XML string
                $web.Fields.AddFieldAsXml($fieldXML)
 
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