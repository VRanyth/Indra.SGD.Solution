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
$varsFS = $config.indraconfiguration.farmsolutions

function WaitForJobToFinish([string]$Identity)
{   
    $job = Get-SPTimerJob | ?{ $_.Name -like "*solution-deployment*$Identity*" }
    $maxwait = 30
    $currentwait = 0

    if (!$job)
    {
        Write-Host -f Red '[ERROR] Timer job not found'
    }
    else
    {
        $jobName = $job.Name
        Write-Host -NoNewLine "[WAIT] Waiting to finish job $jobName"        
        while (($currentwait -lt $maxwait))
        {
            Write-Host -f Green -NoNewLine .
            $currentwait = $currentwait + 1
            Start-Sleep -Seconds 2
            if (!(Get-SPTimerJob $jobName)){
                break;
            }
        }

        #force execution
        if ((Get-SPTimerJob $jobName)){
            net stop SPAdminV4
            Start-SPAdminJob -Verbose
            net start SPAdminV4
        }

        Write-Host  -f Green "...Done!"
    }
}

function RetractSolution([string]$Identity)
{
    Write-Host "[RETRACT] Uninstalling $Identity"    
    Write-Host -NoNewLine "[RETRACT] Does $Identity contain any web application-specific resources to deploy?"
    $solution = Get-SPSolution | where { $_.Name -match $Identity }
    if($solution.ContainsWebApplicationResource)
    {
        Write-Host  -f Yellow "...Yes!"        
        Write-Host -NoNewLine "[RETRACT] Uninstalling $Identity from all web applications"            
        Uninstall-SPSolution -identity $Identity -allwebapplications -Confirm:$false
        Write-Host -f Green "...Done!"
    }
    else
    {
        Write-Host  -f Yellow  "...No!"        
        Uninstall-SPSolution -identity $Identity -Confirm:$false    
        Write-Host -f Green "...Done!"
    }

    WaitForJobToFinish

    Write-Host -NoNewLine  '[UNINSTALL] Removing solution:' $SolutionName
    Remove-SPSolution -Identity $Identity -Confirm:$false
    Write-Host -f Green "...Done!"
}

function DeploySolution([string]$Path, [string]$Identity)
{
    Write-Host -NoNewLine "[DEPLOY] Adding solution:" $Identity
    Add-SPSolution $Path
    Write-Host -f Green "...Done!"

    Write-Host -NoNewLine "[DEPLOY] Does $Identity contain any web application-specific resources to deploy?"
    $solution = Get-SPSolution | where { $_.Name -match $Identity }

    if($solution.ContainsWebApplicationResource)
    {
        Write-Host -f Yellow "...Yes!"        
        Write-Host -NoNewLine "[DEPLOY] Installing $Identity in " $varsFS.url.value
        Install-SPSolution -Identity $Identity –WebApplication $varsFS.url.value -GACDeployment -Force
    }
    else
    {
        Write-Host -f Yellow "...No!"        
        Write-Host -NoNewLine "[DEPLOY] Globally deploying $Identity"    
        Install-SPSolution -Identity $Identity -GACDeployment -Force
    }
    Write-Host -f Green "...Done!"

    WaitForJobToFinish
}


#Automatically Retract, Remove, Add and Deploy SharePoint 2010 WSP Solution Files with PowerShell
#source: http://jmkristiansen.wordpress.com/2012/02/17/automatically-retract-remove-add-and-deploy-sharepoint-2010-wsp-solution-files-with-powershell/



foreach($obj in $varsFS.ChildNodes)
{
	if( $obj.enable -eq 1)
	{
		$identity = $obj.title
		$path = $obj.value

		Write-Host "[INFO] ----------------------------------------"
		Write-Host "[INFO] Installing $Identity"
		Write-Host -NoNewLine "[INFO] Determining if $Identity is already installed"

		$isInstalled = Get-SPSolution | where { $_.Name -eq $identity }
		if ($isInstalled)
		{
			Write-Host -ForegroundColor Yellow "...Yes!"
			(RetractSolution $identity)
			(DeploySolution $path $identity)
		}
		else
		{
			Write-Host -ForegroundColor Yellow "...No!"
			(DeploySolution $path $identity)
		}

		Write-Host -NoNewline "[INFO] Installation and deployment of $Identity"
		Write-Host -ForegroundColor Green "...Done!"
	}
	
}

Stop-SPAssignment -Global

write-host -foregroundcolor green "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"

switch ($pauseIt)
{
    $true
    {
        Pause; break
    }
    default { "Done."; break }
}