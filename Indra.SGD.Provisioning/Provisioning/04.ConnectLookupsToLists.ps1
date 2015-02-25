param(
    [parameter(position=0)]
    [bool]$pauseIt = $true
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

# this frees up all assignments if you end it at end of script 
Start-SPAssignment –Global

#get variables from config xml
$configPath = (Get-Location -PSProvider FileSystem).ProviderPath + "\00.Configurations.xml"
[xml]$config = Get-Content $configPath -Encoding UTF8
$varsSC = $config.indraconfiguration.webappvariables

try
{
    $colsPath = (Get-Location -PSProvider FileSystem).ProviderPath + "\04.ConnectLookupsToLists.xml"
    [xml]$colsXml = Get-Content $colsPath -Encoding UTF8
    $varsCols = $colsXml.indraconfiguration.columnstolists

    if($config.indraconfiguration.enable -eq 1)
    {
        $site = Get-SPSite $varsSC.URL.value
        $web = $site.RootWeb

        foreach($col in $varsCols.column) 
        {
			if($col.Enable -eq "1")
			{
				try {

					$list = $web.Lists[$col.LookupList];
					if($list)
					{
						$field=$web.Fields.GetFieldByInternalName($col.title)
						if($field)
						{
							$field.LookupList = $list.Id
							if($col.AllowMultipleValues -and $col.AllowMultipleValues -eq "TRUE") {
								$field.AllowMultipleValues = $true
							} else {
								$field.AllowMultipleValues = $false
							}
							if($col.LookupField) {
								$field.LookupField = $col.LookupField
							}
							if($col.ShowField) {
								$field.ShowField = $col.ShowField
							}
							$field.Update($true)

							write-host $col.title connected to list $col.LookupList
						} else {
						    Write-Host -foregroundcolor red field $col.title not found!
					    }
					} else {
						Write-Host -foregroundcolor red list $col.LookupList not found!
					}
				 }
				catch [Exception]
				{
					$errorMessage = $_.Exception.Message
					Write-Host  -foregroundcolor red $errorMessage
				}
			}
        }
    }
}
catch [Exception]
{
	$errorMessage = $_.Exception.Message
	Write-Host -foregroundcolor red $errorMessage
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
 

