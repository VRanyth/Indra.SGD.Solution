param([bool] $pauseIt =$true)

Function ProcessTerm($termSet, $parentTerm, $termConfig)
{
    Write-Host -foregroundcolor yellow "Processing Term: $($termConfig.name) ..."
    Try
    {
        $term = $termSet.GetTerm($termConfig.guid);
        if($term -eq $null)
        {
            $term = $parentTerm.CreateTerm($termConfig.name, $termConfig.lcid, $termConfig.guid);
            $term.SetDescription($termConfig.description, $termConfig.lcid);
            $termConfig.LocalCustomProperties.ChildNodes | foreach { # terms LocalCustomProperties
	            if([System.Convert]::ToBoolean($_.enable))
	            {
                    Write-Host -foregroundcolor yellow "Setting LocalCustomProperty: $($_.name) : $($_.value) ..."
                    $term.SetLocalCustomProperty($_.name, $_.value);
                }
            }
        }
                
        $customSortOrder = @();
        $termConfig.Terms.ChildNodes | foreach { # child terms
	        if([System.Convert]::ToBoolean($_.enable))
	        {
                $childTerm = ProcessTerm $termSet $term  $_
                $customSortOrder += $childTerm.ID.ToString();
            }
        }
        $term.CustomSortOrder = $customSortOrder -join ":";
        return $term;
    }
    Catch [system.exception]
    {
        #Write-Host -foregroundcolor red $_.Exception.ToString();
        throw $_.Exception;
    }    
}


# set elapsed time variable
$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()

#get variables from config xml
$configPath = (Get-Location -PSProvider FileSystem).ProviderPath + "\00.Configurations.xml"
[xml]$config = Get-Content $configPath -Encoding UTF8
$varsWA = $config.indraconfiguration.webappvariables

#get variables from config xml
$configPathXml = (Get-Location -PSProvider FileSystem).ProviderPath + "\07.SuporteTaxonomyStructure.xml"
[xml]$xml = Get-Content $configPathXml -Encoding UTF8
$taxonomy = $xml.Taxonomy


#[Microsoft.SharePoint.SPSecurity]::RunWithElevatedPrivileges(
#{

$taxonomySite = get-SPSite $varsWA.URL.value
$taxonomySession = Get-SPTaxonomySession -site $taxonomySite

Write-Host -foregroundcolor yellow "Processing Taxonomy Structure ..."
$taxonomy.ChildNodes | foreach { #termStores
	if([System.Convert]::ToBoolean($_.enable))
	{
        $termStore=$taxonomySession.TermStores[$_.name];
		Write-Host -foregroundcolor yellow "Processing TermStore: $($termStore.Name) ..."
        Try
        {
            $_.ChildNodes | foreach { # groups
	            if([System.Convert]::ToBoolean($_.enable))
	            {
                    $group = $termStore.Groups[$_.name];
                    if($group -eq $null)
                    {
                        Write-Host -foregroundcolor yellow "Group: $($_.name) doesn't exist! Creating!..."
                        $group = $termStore.CreateGroup($_.name);
                    }
                    Write-Host -foregroundcolor yellow "Processing Group: $($group.Name) ..."

                    $_.ChildNodes | foreach { # termSets
	                    if([System.Convert]::ToBoolean($_.enable))
	                    {
                            $termSet = $group.TermSets[$_.name];
                            if($termSet -eq $null)
                            {
                                Write-Host -foregroundcolor yellow "TermSet: $($_.name) doesn't exist! Creating!..."
                                $termSet = $group.CreateTermSet($_.name, $_.guid, $_.lcid);
                            }
                            Write-Host -foregroundcolor yellow "Processing TermSet: $($termSet.Name) ..."
                            
                            $customSortOrder = @();
                            $_.ChildNodes | foreach { # terms
	                            if([System.Convert]::ToBoolean($_.enable))
	                            {
                                    $childTerm = ProcessTerm $termSet $termSet  $_
                                    $customSortOrder += $childTerm.ID.ToString();
                                }
                            }
                            $termSet.CustomSortOrder = $customSortOrder -join ":";
                        }
                    }
                }
            }
            $termStore.CommitAll();
        }
        Catch [system.exception]
        {
            Write-Host -foregroundcolor red $_.Exception.ToString();
            $termStore.RollbackAll();
        }
        Finally
        {
          $termStore.ResyncHiddenList($taxonomySite);
        }
    }
}
#})

write-host -foregroundcolor green "Total Elapsed Time: $($ElapsedTime.Elapsed.ToString())"

switch ($pauseIt)
{
    $true
    {
        Pause; break
    }
    default { "Done."; break }
}