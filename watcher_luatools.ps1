$ErrorActionPreference='SilentlyContinue'
$logPath=Join-Path $env:TEMP "bsmap_luatools.log"
$watchLog=Join-Path $env:TEMP "luatools_watcher.log"
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
function Get-GameName($appid){
  try{
    $r=Invoke-RestMethod -Uri "https://store.steampowered.com/api/appdetails?appids=$appid&cc=us&l=spanish" -UseBasicParsing -TimeoutSec 8 -ErrorAction SilentlyContinue
    $n=$r.$appid.data.name
    if($n){ return $n }
  }catch{}
  try{
    $lu=Get-ChildItem "$steamRoot\config\stplug-in\$appid.lua" -ErrorAction SilentlyContinue | Select-Object -First 1
    if($lu){ return [IO.Path]::GetFileNameWithoutExtension($lu.Name) }
  }catch{}
  return "AppID $appid"
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
    $appid=$sub.Name
    if($appid -notmatch '^\d+$'){ continue }
    if($done.ContainsKey($appid)){ continue }
    if($sub.CreationTime -lt (Get-Date).AddDays(-1)){ continue }
    # verificar que tenga lua activado, si no, saltar
    $lua1=Join-Path $steamRoot "config\stplug-in\$appid.lua"
    $lua2=Join-Path $steamRoot "config\lua\$appid.lua"
    if(-not (Test-Path $lua1) -and -not (Test-Path $lua2)){
      Log "Saltando $appid : sin lua (no esta activado)"
      $done[$appid]=$true
      continue
    }
    $gname=Get-GameName $appid
    $done[$appid]=$true
    Log "Arreglando descarga: $gname ($appid)"
    try{
     Remove-Variable -Name AppId,ApiKey,MorrenusApiKey -ErrorAction SilentlyContinue
     Remove-Variable -Name AppId -Scope Global -ErrorAction SilentlyContinue
     $env:APP_ID=$appid
     $env:MANIFEST_MODE="github"
     $scriptText = Invoke-RestMethod -Uri "https://luatools.vercel.app/manifests.ps1" -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
     $scriptText = $scriptText -replace '\$null = \$Host\.UI\.RawUI\.ReadKey\([^)]*\)',''
     Invoke-Expression $scriptText | Out-Null
     Log "Listo: $gname ($appid) reparado"
    }catch{ Log "Fallo $gname ($appid): $($_.Exception.Message)" }
   }
  }
 }catch{ Log "Watcher error $($_.Exception.Message)" }
 Start-Sleep -Seconds 1
}
