[CmdletBinding()]
param(
    [string]$ProjectPath = "",
    [string]$UnityEditorPath = $env:UNITY_EDITOR_PATH
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectPath))
{
    $ProjectPath = Split-Path -Parent $PSScriptRoot
}

$projectRoot = (Resolve-Path -LiteralPath $ProjectPath).Path
$versionFile = Join-Path $projectRoot "ProjectSettings\ProjectVersion.txt"

if (-not (Test-Path -LiteralPath $versionFile))
{
    throw "ProjectVersion.txt was not found under '$projectRoot'."
}

$versionLine = Get-Content -LiteralPath $versionFile |
    Where-Object { $_ -like "m_EditorVersion:*" } |
    Select-Object -First 1

if (-not $versionLine)
{
    throw "Unity Editor version could not be read from '$versionFile'."
}

$editorVersion = ($versionLine -split ":", 2)[1].Trim()

if ([string]::IsNullOrWhiteSpace($UnityEditorPath))
{
    $programFiles = [Environment]::GetFolderPath("ProgramFiles")
    $UnityEditorPath = Join-Path $programFiles "Unity\Hub\Editor\$editorVersion\Editor\Unity.exe"
}

if (-not (Test-Path -LiteralPath $UnityEditorPath))
{
    throw "Unity $editorVersion was not found at '$UnityEditorPath'. Set UNITY_EDITOR_PATH or pass -UnityEditorPath."
}

$lockFile = Join-Path $projectRoot "Temp\UnityLockfile"
if (Test-Path -LiteralPath $lockFile)
{
    throw "The project is open in Unity. Close the Editor before batch validation."
}

$logDirectory = Join-Path $projectRoot "Logs"
New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
$logFile = Join-Path $logDirectory "ProjectValidation.log"

$arguments = @(
    "-batchmode",
    "-nographics",
    "-quit",
    "-projectPath",
    "`"$projectRoot`"",
    "-logFile",
    "`"$logFile`""
)

Write-Output "Validating with Unity $editorVersion..."
$process = Start-Process -FilePath $UnityEditorPath -ArgumentList $arguments -PassThru -Wait -WindowStyle Hidden

$errorPattern = "error CS\d+|Scripts have compiler errors|Compilation failed|Unhandled Exception"
$compilerErrors = Select-String -LiteralPath $logFile -Pattern $errorPattern -CaseSensitive:$false

if ($process.ExitCode -ne 0 -or $compilerErrors)
{
    Get-Content -LiteralPath $logFile -Tail 80
    throw "Unity validation failed. See '$logFile'."
}

Write-Output "Unity import and compilation succeeded."
Write-Output "Log: $logFile"
