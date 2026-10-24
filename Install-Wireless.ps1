param([Parameter(Mandatory=$true)][string]$GamePath,[switch]$CheckOnly)
$ErrorActionPreference='Stop'
$game=(Resolve-Path -LiteralPath $GamePath).Path
$exe=Join-Path $game 'Voyage\Binaries\Win64\VoyageSteam-Win64-Shipping.exe'
$dll=Join-Path $game 'Voyage\Binaries\Win64\ue4ss\UE4SS.dll'
if ((Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash -ne '08228B72D4590F9B00E2171F252D618464C2E04B785237FE728DDDBF27D3B734') {throw 'Spielbuild 25982825 / 0.10.0.653173 erforderlich.'}
if (-not (Test-Path -LiteralPath $dll)) {throw 'Zuerst UE4SS v3.0.1-1125-g527a483b installieren. Download und Anleitung: README.md.'}
if ((Get-FileHash -LiteralPath $dll -Algorithm SHA256).Hash -ne '91D5444F41D19D0BB502F0FBDC15D76421E20359E898CAA39E41E134C8F87958') {throw 'Andere UE4SS-Version: Geprueft ist UE4SS v3.0.1-1125-g527a483b. Download und DLL-Pruefsumme: README.md.'}
$bridge=Join-Path $game 'Voyage\Content\Paks\~mods\AssetBridge'
if (-not (Test-Path -LiteralPath $bridge -PathType Container) -or -not (Get-ChildItem -LiteralPath $bridge -Filter '*.utoc' -File)) {throw 'AssetBridge 0.4.0 ist fuer die neuen Ressourcen-Geraete erforderlich. Installation und Autorenlink: README.md.'}
$files=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Dateien.json') -Raw | ConvertFrom-Json
foreach($row in $files){
 $source=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot $row.path))
 $dest=[IO.Path]::GetFullPath((Join-Path $game $row.path))
 if(-not $source.StartsWith($PSScriptRoot+'\',[StringComparison]::OrdinalIgnoreCase) -or -not $dest.StartsWith($game+'\Voyage\',[StringComparison]::OrdinalIgnoreCase)){throw 'Ungueltiger Paketpfad.'}
 if((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -ne $row.sha256){throw "Pruefsumme falsch: $($row.path)"}
}
if($CheckOnly){Write-Output "OK: $($files.Count) Dateien, Spielbuild, UE4SS und vorhandenes AssetBridge-Paket geprueft. Keine Aenderung.";return}
if(Get-Process Voyage*,Vortex -ErrorAction SilentlyContinue){throw 'Spiel und Vortex vorher schliessen.'}
$backup=Join-Path $game ('CaretakerModBackups\WirelessResources-'+(Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
New-Item -ItemType Directory -Path $backup | Out-Null
$written=@()
try{
 foreach($row in $files){
  $dest=Join-Path $game $row.path
  if(Test-Path -LiteralPath $dest){
   $old=Join-Path $backup $row.path
   New-Item -ItemType Directory -Path (Split-Path -Parent $old) -Force | Out-Null
   Copy-Item -LiteralPath $dest -Destination $old
  }
  New-Item -ItemType Directory -Path (Split-Path -Parent $dest) -Force | Out-Null
  $written+=$row.path
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot $row.path) -Destination $dest
  if((Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash -ne $row.sha256){throw 'Kopierpruefung fehlgeschlagen.'}
 }
}catch{
 foreach($rel in $written){
  $old=Join-Path $backup $rel;$dest=Join-Path $game $rel
  if(Test-Path -LiteralPath $old){Copy-Item -LiteralPath $old -Destination $dest}
  elseif(Test-Path -LiteralPath $dest){Remove-Item -LiteralPath $dest}
 }
 throw
}
[pscustomobject]@{installed=(Get-Date -Format o);backup=$backup;files=$files} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $backup 'installation.json') -Encoding utf8
Write-Output "Wireless Fix 1.0.0 installiert; vorherige Dateien gesichert: $backup"
