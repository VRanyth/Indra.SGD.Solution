param(
    [parameter(position=0)]
    [bool]$pauseIt = $true,

    [parameter(position=1)]
    [bool]$create = $true
)

#add SharePoint cmdlets (if not already loaded)
if ( (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null )
{
    Add-PsSnapin Microsoft.SharePoint.PowerShell
}

#custom pause function
Function Pause($M="Press any key to continue . . . "){If($psISE){$S=New-Object -ComObject "WScript.Shell";$B=$S.Popup("Click OK to continue.",0,"Script Paused",0);Return};Write-Host -NoNewline $M;$I=16,17,18,20,91,92,93,144,145,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183;While($K.VirtualKeyCode -Eq $Null -Or $I -Contains $K.VirtualKeyCode){$K=$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")};Write-Host}

#set elapsed time variable
$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()

#get variables from config xml
$configPath = (Get-Location -PSProvider FileSystem).ProviderPath + "\00.Configurations.xml"
[xml]$config = Get-Content $configPath -Encoding UTF8
$varsWA = $config.indraconfiguration.webappvariables
$varsSA = $config.indraconfiguration.serviceapplications

try
{
    [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
	[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Publishing")

    $colsPath = (Get-Location -PSProvider FileSystem).ProviderPath + "\08.ConnectColsToLocalTermSets.xml"
    [xml]$colsXml = Get-Content $colsPath -Encoding UTF8
    $varsCols = $colsXml.indraconfiguration.columnstotermsets

    if($config.indraconfiguration.enable -eq 1)
    {
        $taxonomySite = Get-SPSite $varsWA.URL.value
        $site = Get-SPSite -Identity $taxonomySite
        $web = $site.RootWeb

	    #vai buscar a Term Store.
	    $taxonomySession = Get-SPTaxonomySession -site $taxonomySite
	    $termStore=$taxonomySession.TermStores[$varsSA.ManagedMetadata.value]

	    if ($termStore -ne $null)                
	    {
		    #Vai buscar o grupo caso exista
		    $group = $termStore.Groups[$varsWA.TermStoreGroup.value]

		    if ($group -ne $null)                
		    {
                foreach($col in $varsCols.column) 
                {
                    try {
                        $termset = $group.TermSets[$col.termset];

                        if($termset -ne $null) {
                            $field=$web.Fields.GetFieldByInternalName($col.title)

                            $field.SspId=$termset.TermStore.Id
                            $field.TermSetId=$termset.Id

                            if($col.guid -ne $null)
							{
								$field.AnchorId = $col.guid;
							}							
							elseif($col.anchor -ne $null) {
                                $field.AnchorId=$termset.Terms[$col.anchor].Id
                            }
							else
							{
								write-host -foregroundcolor yellow $col.title do not have anchor connected to root.
							}

                            if($col.IsPathRendered -ne $null) {
                                $field.IsPathRendered = $col.IsPathRendered
                            }
                            $field.Update($true)
                            write-host $col.title connected to $col.termset $col.anchor
                        } else {
                            write-host -foregroundcolor red Termset $col.termset not found.
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

write-host -foregroundcolor green "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"

switch ($pauseIt)
{
    $true
    {
        Pause; break
    }
    default { "Done."; break }
}