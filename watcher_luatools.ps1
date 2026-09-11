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
# overrides para que manifests.ps1 no pida input y no bloquee
function global:Read-Host { param($Prompt) return "2" }
function global:Clear-Host {}
function global:Write-Host {
    param([object]$Object,[switch]$NoNewline,[object]$Separator=' ',[Parameter(ValueFromRemainingArguments=$true)][object[]]$Rest)
    $text = if($null -ne $Object){[string]$Object}else{""}
    if($Rest.Count -gt 0){
      $extra=@($Rest | Where-Object { $_ -is [string] -or $_ -is [int] -or $_ -is [double] })
      if($extra.Count -gt 0){ $text=(@($text)+($extra|ForEach-Object{[string]$_}))-join "$Separator" }
    }
    $clean=$text -replace "\x1B\]8;;[^\x1B]*\x1B\\","" -replace "\x1B\[[0-9;]*[A-Za-z]","" -replace "`r",""
    if($clean.Trim().Length -gt 0){ Log $clean }
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
    try{ Microsoft.PowerShell.Utility\Write-Host @p }catch{ Microsoft.PowerShell.Utility\Write-Host $text }
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
    $done[$appid]=$true
    Log "Detectado descarga AppID $appid -> ejecutando: irm https://luatools.vercel.app/manifests.ps1 | iex (github mirror)"
    try{
     Remove-Variable -Name AppId,ApiKey,MorrenusApiKey -ErrorAction SilentlyContinue
     Remove-Variable -Name AppId -Scope Global -ErrorAction SilentlyContinue
     $env:APP_ID=$appid
     $env:MANIFEST_MODE="github"
     $scriptText = Invoke-RestMethod -Uri "https://luatools.vercel.app/manifests.ps1" -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
     $scriptText = $scriptText -replace '\$null = \$Host\.UI\.RawUI\.ReadKey\([^)]*\)',''
     Invoke-Expression $scriptText
     Log "Auto Luatools OK para $appid"
    }catch{ Log "Auto Luatools FAIL $appid $($_.Exception.Message)" }
   }
  }
 }catch{ Log "Watcher error $($_.Exception.Message)" }
 Start-Sleep -Seconds 1
}
