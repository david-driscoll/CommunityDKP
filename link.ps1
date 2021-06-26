[CmdletBinding()]
param (
    [Parameter()]
    $path
)
New-Item -ItemType Junction -Path "$path\RaidPointsSystemV2\" -Target ($PWD.Path)