[CmdletBinding()]
param (
    [Parameter()]
    $path
)
New-Item -ItemType Junction -Path $path -Target ($PWD.Path)