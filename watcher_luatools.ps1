$ErrorActionPreference='SilentlyContinue'
$logPath=Join-Path $env:TEMP "bsmap_luatools.log"
$watchLog=Join-Path $env:TEMP "luatools_watcher.log"
try{ Add-Content -Path $logPath -Value "[$(Get-Date -Format 'HH:mm:ss')] Watcher boot" -Encoding UTF8 -ErrorAction SilentlyContinue }catch{}
function Log($m){
  $line="[$(Get-Date -Format 'HH:mm:ss')] $m"
  try { Add-Content -Path $logPath -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue } catch {}
  try { Add-Content -Path $watchLog -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue } catch {}
}
function Get-SteamPath{
 $paths=@((Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name InstallPath -ErrorAction SilentlyContinue).InstallPath,(Get-ItemProperty -Path "HKLM:\SOFTWARE\Valve\Steam" -Name InstallPath -ErrorAction SilentlyContinue).InstallPath,"${env:ProgramFiles(x86)}\Steam","${env:ProgramFiles(x86)}\Steamm")
 foreach($p in $paths){ if($p -and (Test-Path (Join-Path $p "steam.exe"))){ return $p } }
 return $null
}
function Get-GameName($gid){
  try{
    $r=Invoke-RestMethod -Uri "https://store.steampowered.com/api/appdetails?appids=$gid&cc=us&l=spanish" -UseBasicParsing -TimeoutSec 8 -ErrorAction SilentlyContinue
    $n=$r.$gid.data.name
    if($n){ return $n }
  }catch{}
  try{
    $lu=Get-ChildItem "$steamRoot\config\stplug-in\$gid.lua" -ErrorAction SilentlyContinue | Select-Object -First 1
    if($lu){ return [IO.Path]::GetFileNameWithoutExtension($lu.Name) }
  }catch{}
  return "AppID $gid"
}
# overrides para que manifests.ps1 no pida input
function global:Read-Host { param($Prompt) return "2" }
function global:Clear-Host {}
# Write-Host silencioso: no loguea verboso, solo muestra
function global:Write-Host {
    param([object]$Object,[switch]$NoNewline,[object]$Separator=' ',[Parameter(ValueFromRemainingArguments=$true)][object[]]$Rest)
    $p=@{}
    if($PSBoundParameters.ContainsKey('Object')){$p.Object=$Object}
    if($NoNewline){$p.NoNewline=$true}
    if($PSBoundParameters.ContainsKey('Separator')){$p.Separator=$Separator}
    for($i=0;$i -lt $Rest.Count;$i++){
      if($Rest[$i] -is [string] -and $Rest[$i] -like "-*"){
        $k=$Rest[$i].TrimStart('-')
        if($i+1 -lt $Rest.Count){$p[$k]=$Rest[$i+1];$i++}
      }
    }
    try{ Microsoft.PowerShell.Utility\Write-Host @p }catch{ Microsoft.PowerShell.Utility\Write-Host "$Object" }
}
$steamRoot=Get-SteamPath
if(-not $steamRoot){ Log "No Steam encontrado"; exit }
$dlDir=Join-Path $steamRoot "steamapps\downloading"
$done=@{}
Log "Auto LuaTools iniciado, monitoreando $dlDir cada 1s (github mirror=1)"
while($true){
 try{
  if(Test-Path $dlDir){
   foreach($sub in Get-ChildItem $dlDir -Directory -ErrorAction SilentlyContinue){
    $curId=$sub.Name
    if($curId -notmatch '^\d+$'){ continue }
    if($done.ContainsKey($curId)){ continue }
    if($sub.CreationTime -lt (Get-Date).AddDays(-1)){ continue }
    # verificar que tenga lua activado, si no, saltar
    $lua1=Join-Path $steamRoot "config\stplug-in\$curId.lua"
    $lua2=Join-Path $steamRoot "config\lua\$curId.lua"
    if(-not (Test-Path $lua1) -and -not (Test-Path $lua2)){
      Log "Saltando $curId : sin lua (no esta activado)"
      $done[$curId]=$true
      continue
    }
    $gname=Get-GameName $curId
    $done[$curId]=$true
    Log "Arreglando descarga ($gname)"
    try{
     $AppId=$null; $ApiKey=$null; $MorrenusApiKey=$null
     Remove-Variable -Name AppId,ApiKey,MorrenusApiKey -ErrorAction SilentlyContinue
     Remove-Variable -Name AppId -Scope Global -ErrorAction SilentlyContinue
     $global:AppId=$curId
     $env:APP_ID=$curId
     $env:MANIFEST_MODE="github"
     $scriptText = Invoke-RestMethod -Uri "https://luatools.vercel.app/manifests.ps1" -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
     $scriptText = $scriptText -replace '\$null = \$Host\.UI\.RawUI\.ReadKey\([^)]*\)',''
     $scriptText = $scriptText -replace '(?m)^\s*exit\s+\d.*$','return'
     $scriptText = $scriptText -replace '\bexit\s+0\b','return'
     $scriptText = $scriptText -replace '\bexit\s+1\b','return'
     Invoke-Expression $scriptText | Out-Null
     Log "Listo ($gname) reparado"
    }catch{ Log "Fallo ($gname): $($_.Exception.Message)" }
   }
  }
 }catch{ Log "Watcher error $($_.Exception.Message)" }
 Start-Sleep -Seconds 1
}
