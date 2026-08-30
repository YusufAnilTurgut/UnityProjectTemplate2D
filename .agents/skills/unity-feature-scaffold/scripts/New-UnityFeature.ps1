[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Name,

    [string]$ProjectPath = "",
    [switch]$IncludeData,
    [switch]$IncludeUI,
    [switch]$IncludeEditModeTests,
    [switch]$IncludePlayModeTests
)

$ErrorActionPreference = "Stop"

if (-not [System.Text.RegularExpressions.Regex]::IsMatch($Name, "^[A-Z][A-Za-z0-9]*$"))
{
    throw "Feature name must be a PascalCase identifier such as 'Inventory' or 'SaveSystem'."
}

if ([string]::IsNullOrWhiteSpace($ProjectPath))
{
    $ProjectPath = Join-Path $PSScriptRoot "..\..\..\.."
}

$projectRoot = (Resolve-Path -LiteralPath $ProjectPath).Path
$versionFile = Join-Path $projectRoot "ProjectSettings\ProjectVersion.txt"

if (-not (Test-Path -LiteralPath $versionFile))
{
    throw "'$projectRoot' is not a Unity project root."
}

$relativeFolders = @(
    "Assets\_Project\Scripts\Features\$Name\Runtime"
)

if ($IncludeData)
{
    $relativeFolders += "Assets\_Project\Scripts\Features\$Name\Data"
}

if ($IncludeUI)
{
    $relativeFolders += "Assets\_Project\Scripts\Features\$Name\UI"
}

if ($IncludeEditModeTests)
{
    $relativeFolders += "Assets\_Project\Tests\EditMode\$Name"
}

if ($IncludePlayModeTests)
{
    $relativeFolders += "Assets\_Project\Tests\PlayMode\$Name"
}

foreach ($relativeFolder in $relativeFolders)
{
    $folder = [System.IO.Path]::GetFullPath((Join-Path $projectRoot $relativeFolder))
    $projectPrefix = $projectRoot + [System.IO.Path]::DirectorySeparatorChar

    if (-not $folder.StartsWith($projectPrefix, [System.StringComparison]::OrdinalIgnoreCase))
    {
        throw "Scaffold path escapes the Unity project: '$folder'."
    }

    if ($PSCmdlet.ShouldProcess($folder, "Create feature folder"))
    {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        $marker = Join-Path $folder ".gitkeep"

        if (-not (Test-Path -LiteralPath $marker))
        {
            [System.IO.File]::WriteAllText($marker, [string]::Empty)
        }

        Write-Output "Ready: $relativeFolder"
    }
}

Write-Output "Run Tools\Validate-UnityProject.ps1 or let Unity import the folders before committing."
