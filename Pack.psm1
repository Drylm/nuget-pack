function Push-Package
{
    Param(
        [parameter(Mandatory=$true, Position=0)]
        [string]
        $NuSpecFile,
        [parameter(Mandatory=$true, Position=1)]
        [string]
        $TargetRepository
        )

        $nugetVersion = gitversion /showvariable NuGetVersion
        $commitsSinceVersionSourcePadded = gitversion /showvariable CommitsSinceVersionSourcePadded
        $branchName = gitversion /showvariable BranchName

        $versionToApply =  $nuGetVersion
        if ($branchName -ne "master" -and $branchName -ne "develop" -and $commitsSinceVersionSource -ne 0)
        {
            $majorMinorPatch = gitversion /showvariable MajorMinorPatch
            $nuGetPreReleaseTag = gitversion /showvariable NuGetPreReleaseTag

            $subNugetVersion = $nuGetPreReleaseTag.Substring(0, $nuGetPreReleaseTag.Length - 4)
            $subNugetVersion = $subNugetVersion.Replace("-", "")
            $versionToApply = "$majorMinorPatch-$subNugetVersion$commitsSinceVersionSourcePadded"
        }

        nuget pack $NuSpecFile -Version $versionToApply

        $baseFileName = [System.IO.Path]::GetFileNameWithoutExtension($NuSpecFile)
        Start-Process -Wait -NoNewWindow -FilePath "nuget.exe" -ArgumentList push, "$baseFileName.$versionToApply.nupkg", -source, "$TargetRepository"
}