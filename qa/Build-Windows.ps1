param(
    [Parameter(Mandatory=$true)][string]$RuntimePath,
    [Parameter(Mandatory=$true)][string]$UserFolder,
    [ValidateSet('Default','Developer')][string]$Configuration = 'Default',
    [string]$OutputDirectory = ''
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
if (!$OutputDirectory) { $OutputDirectory = Join-Path $projectRoot 'build' }
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
$igorCandidates = @((Join-Path $RuntimePath 'bin\igor\windows\x64\Igor.exe'), (Join-Path $RuntimePath 'bin\Igor.exe'))
$igor = $igorCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (!$igor) { throw 'This runtime installation has no Igor compiler. Repair/install a complete runtime in GameMaker.' }
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$argsForIgor = @(
    "/uf=$UserFolder", "/rp=$RuntimePath", "/project=$projectRoot\Samurai Slasher.yyp",
    "/cache=$OutputDirectory\cache", "/temp=$OutputDirectory\temp", "/config=$Configuration",
    "/of=$OutputDirectory\SamuraiRunner.zip", "/tf=$OutputDirectory\SamuraiRunner.win",
    '--', 'Windows', 'PackageZip'
)
& $igor @argsForIgor
if ($LASTEXITCODE -ne 0) { throw "GameMaker build failed with exit code $LASTEXITCODE" }
