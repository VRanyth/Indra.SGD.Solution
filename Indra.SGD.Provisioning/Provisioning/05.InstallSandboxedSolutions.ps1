param([bool] $pauseIt =$true)
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
[xml]$config = Get-Content $configPath
$varsWA = $config.indraconfiguration.webappvariables
$varsSBS = $config.indraconfiguration.sandboxedsolutions

if( $config.indraconfiguration.enable -eq 1)
{
	#Dar acesso a user quando corre por remoting
	if ( (Get-SPWeb -Site $varsWA.Url.value -Limit ALL -ErrorAction SilentlyContinue) -eq $null ) {
		$w = Get-SPWebApplication $varsWA.Url.value
		$w.GrantAccessToProcessIdentity([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
	}

	foreach($obj in $varsSBS.ChildNodes)
	{
		#Deactivate & Remove
		if ( (Get-SPUserSolution -Site $varsWA.URL.value -Identity $obj.title -ErrorAction SilentlyContinue) -ne $null )
		{
			Write-Host -foregroundcolor yellow "Deactivates the sandboxed solution in the site collection.: " $obj.title
			Uninstall-SPUserSolution -Site $varsWA.URL.value -Identity $obj.title -Confirm:$false
			write-host -foregroundcolor green "Ok"

			Write-Host -foregroundcolor yellow "Removes the sandboxed solution from the solution gallery: " $obj.title
			Remove-SPUserSolution -Site $varsWA.URL.value -Identity $obj.title -Confirm:$false
			write-host -foregroundcolor green "Ok"
		}

		#Add & Activate
		if ( (Get-SPUserSolution -Site $varsWA.URL.value -Identity $obj.title -ErrorAction SilentlyContinue) -eq $null )
		{
			Write-Host -foregroundcolor yellow "Uploads the sandboxed solution to the solution gallery: " $obj.title
			Add-SPUserSolution –LiteralPath $obj.value –Site $varsWA.URL.value
			write-host -foregroundcolor green "Ok"

			Write-Host -foregroundcolor yellow "Activates the sandboxed solution in the site collection: " $obj.title
			Install-SPUserSolution –Identity $obj.title –Site $varsWA.URL.value
			write-host -foregroundcolor green "Ok"
		}
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