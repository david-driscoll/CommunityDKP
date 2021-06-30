[CmdletBinding()]
param (
    [Parameter()]
    $path
)

if ((Test-Path "$path\RaidPointsSystemV2\") -and (-not (Get-Item "$path\RaidPointsSystemV2\").LinkType)) {
    Remove-Item "$path\RaidPointsSystemV2\" -Recurse -Force
}
New-Item -ItemType Junction -Path "$path\RaidPointsSystemV2\" -Target ($PWD.Path)