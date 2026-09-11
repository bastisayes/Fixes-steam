$ErrorActionPreference='SilentlyContinue'
$logPath=Join-Path $env:TEMP "bsmap_dropsv2.log"
$logPath2=Join-Path $env:TEMP "bsmap_luatools.log"
function Log($m){
  $line="[$(Get-Date -Format 'HH:mm:ss')] $m"
  try { Add-Content -Path $logPath -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue } catch {}
  try { Add-Content -Path $logPath2 -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue } catch {}
}
function Get-SteamPath{
 $paths=@((Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name InstallPath -ErrorAction SilentlyContinue).InstallPath,(Get-ItemProperty -Path "HKLM:\SOFTWARE\Valve\Steam" -Name InstallPath -ErrorAction SilentlyContinue).InstallPath,"${env:ProgramFiles(x86)}\Steam","${env:ProgramFiles(x86)}\Steamm")
 foreach($p in $paths){ if($p -and (Test-Path (Join-Path $p "steam.exe"))){ return $p } }
 return $null
}
function Get-GameName($gid){
  try{
    $r=Invoke-RestMethod -Uri "https://store.steampowered.com/api/appdetails?appids=$gid&cc=us&l=spanish" -UseBasicParsing -TimeoutSec 6 -ErrorAction SilentlyContinue
    $n=$r.$gid.data.name
    if($n){ return $n }
  }catch{}
  return "AppID $gid"
}
function Get-DepotIds($lua){
  $deps=@()
  if(-not (Test-Path $lua)){ return $deps }
  $content=Get-Content $lua -ErrorAction SilentlyContinue
  foreach($line in $content){
    if($line -match 'addappid\s*\(\s*(\d+)\s*,\s*\d+\s*,\s*"[a-fA-F0-9]+"'){
      $deps+=$matches[1]
    }
  }
  return $deps | Select-Object -Unique
}
$steamRoot=Get-SteamPath
if(-not $steamRoot){ Log "No Steam encontrado"; exit }
$dlDir=Join-Path $steamRoot "steamapps\downloading"
$done=@{}
Log "Reparador 2 (Drops V2) iniciado, monitoreando $dlDir cada 1s"
while($true){
 try{
  if(Test-Path $dlDir){
   foreach($sub in Get-ChildItem $dlDir -Directory -ErrorAction SilentlyContinue){
    $curId=$sub.Name
    if($curId -notmatch '^\d+$'){ continue }
    if($done.ContainsKey($curId)){ continue }
    if($sub.CreationTime -lt (Get-Date).AddDays(-1)){ continue }
    $lua1=Join-Path $steamRoot "config\stplug-in\$curId.lua"
    $lua2=Join-Path $steamRoot "config\lua\$curId.lua"
    $luaPath=$null
    if(Test-Path $lua1){ $luaPath=$lua1 } elseif(Test-Path $lua2){ $luaPath=$lua2 }
    if(-not $luaPath){
      Log "Saltando $curId : sin lua"
      $done[$curId]=$true
      continue
    }
    $gname=Get-GameName $curId
    $done[$curId]=$true
    Log "Arreglando descarga ($gname) [$curId] via Drops V2"
    try{
      $deps=Get-DepotIds $luaPath
      if($deps.Count -eq 0){
        Log "Fallo ($gname): sin depots en lua"
        continue
      }
      $resp=Invoke-RestMethod -Uri "https://api.steamcmd.net/v1/info/$curId" -TimeoutSec 15 -ErrorAction Stop
      if($resp.status -ne "success"){
        Log "Fallo ($gname): steamcmd API sin datos"
        continue
      }
      $depotsData=$resp.data.$curId.depots
      $queue=@()
      foreach($d in $deps){
        if($depotsData.PSObject.Properties.Name -contains $d -and $depotsData.$d.manifests -and $depotsData.$d.manifests.public -and $depotsData.$d.manifests.public.gid){
          $gid=$depotsData.$d.manifests.public.gid
          $queue+=@{depot=$d; manifest=$gid}
        }
      }
      if($queue.Count -eq 0){
        Log "Fallo ($gname): sin manifests publicos"
        continue
      }
      $outDir=Join-Path $steamRoot "depotcache"
      if(-not (Test-Path $outDir)){ New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
      $ok=0; $sk=0
      foreach($it in $queue){
        $dep=$it.depot; $man=$it.manifest
        $fn="${dep}_${man}.manifest"
        $outFile=Join-Path $outDir $fn
        if((Test-Path $outFile) -and (Get-Item $outFile).Length -gt 0){
          $sk++
          continue
        }
        $url="https://raw.githubusercontent.com/qwe213312/k25FCdfEOoEJ42S6/main/$fn"
        try{
          $r=Invoke-WebRequest -Uri $url -TimeoutSec 30 -UseBasicParsing -ErrorAction Stop
          if($r.StatusCode -eq 200){
            [IO.File]::WriteAllBytes($outFile, $r.Content)
            $ok++
          }
        }catch{}
      }
      Log "Listo ($gname) reparado: $ok descargados, $sk ya existian"
    }catch{ Log "Fallo ($gname): $($_.Exception.Message)" }
   }
  }
 }catch{ Log "Watcher error $($_.Exception.Message)" }
 Start-Sleep -Seconds 1
}
