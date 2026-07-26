# ---- Ocultar ventana de PowerShell ----
$script:version = "1.3"
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
Add-Type -Name W -Namespace C -MemberDefinition '
[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
' -ErrorAction SilentlyContinue | Out-Null
[C.W]::ShowWindow([C.W]::GetConsoleWindow(), 0) | Out-Null

# ---- Webhook Discord ----
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

# ---- Client ID (compatible con code_server.ps1) ----
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
# ---- fin Client ID ----

function Get-SteamAppName {
    param([string]$appid)
    try {
        $r = Invoke-RestMethod -Uri "https://store.steampowered.com/api/appdetails?appids=$appid" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($r.$appid.success -eq $true -and $r.$appid.data.name) { return $r.$appid.data.name }
    } catch {}
    return $null
}

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
    # fallback: return first existing path even without steam.exe
    foreach ($p in $paths) {
        if ($p -and (Test-Path $p)) { return $p }
    }
    throw "No se encontro Steam en el registro ni en rutas tipicas."
}

function Get-SafeFont {
    param([string]$Family = "Segoe UI", [float]$Size = 10, $Style = [System.Drawing.FontStyle]::Regular)
    $fallbacks = @($Family, "Arial", "Microsoft Sans Serif", "Tahoma", "Segoe UI")
    foreach ($f in $fallbacks) {
        try { return New-Object System.Drawing.Font($f, $Size, $Style) } catch {}
    }
    return New-Object System.Drawing.Font("Arial", $Size, $Style)
}

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
    } catch {
        return $false
    }
}

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
        $sr.Close()
        $pageResp.Close()
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
        if ($progressBar) {
            $pct = $progressStart + [math]::Min($progressEnd, [math]::Round(($progressEnd - $progressStart) * $completed / $totalChunks))
            $progressBar.Value = $pct; [System.Windows.Forms.Application]::DoEvents()
        }
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
                try {
                    $c = [System.IO.File]::ReadAllText($_.FullName)
                    [System.IO.File]::WriteAllText($_.FullName, $header + $c)
                } catch {}
            }
        }
        Get-ChildItem -Path $tempDir -Recurse -Filter *.lua | ForEach-Object { Copy-Item -Path $_.FullName -Destination $luaDir -Force; Copy-Item -Path $_.FullName -Destination $luaDir2 -Force; $result.lua += $_.Name }
        Get-ChildItem -Path $tempDir -Recurse -Filter *.manifest | ForEach-Object { Copy-Item -Path $_.FullName -Destination $manifestDir -Force; $result.manifest += $_.Name }
    } finally {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    return $result
}

function Get-ActivationFolder {
    return $env:TEMP
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
            $del = $prev[$j] + 1
            $ins = $curr[$j-1] + 1
            $sub = $prev[$j-1] + $cost
            $min = $del
            if ($ins -lt $min) { $min = $ins }
            if ($sub -lt $min) { $min = $sub }
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
    $bestMatch = $null
    $bestScore = 0
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
        # Fuzzy match via Levenshtein
        if ($maxLen -gt 3) {
            $dist = Get-LevenshteinDistance $fn $gfn
            $threshold = [Math]::Max(1, [Math]::Floor($maxLen * 0.2))
            if ($dist -le $threshold) {
                $score = $maxLen - $dist
                if ($score -gt $bestScore) { $bestScore = $score; $bestMatch = $g }
            }
        }
    }
    if ($bestMatch) { return $games[$bestMatch], $bestMatch }
    return $null, $null
}

function Show-RepairProgress {
    param([string]$gamePath, [string]$fixName, [string]$fixUrl)
    $dlg = New-Object System.Windows.Forms.Form
    $dlg.Text = "Reparar Juego - $fixName"
    $dlg.Size = New-Object System.Drawing.Size(500, 230)
    $dlg.StartPosition = "CenterParent"
    $dlg.BackColor = "#1a1a2e"
    $dlg.ForeColor = "White"
    $dlg.FormBorderStyle = "FixedDialog"
    $dlg.ShowInTaskbar = $false
    $dlg.ControlBox = $false
    $lblInfo = New-Object System.Windows.Forms.Label
    $lblInfo.Text = "Juego: $fixName`nCarpeta: $gamePath`n`nReparar juego aqui?"
    $lblInfo.ForeColor = "#a0a0a0"
    $lblInfo.Size = New-Object System.Drawing.Size(460, 70)
    $lblInfo.Location = New-Object System.Drawing.Point(20, 15)
    $lblInfo.TextAlign = "MiddleCenter"
    $dlg.Controls.Add($lblInfo)
    $pb = New-Object System.Windows.Forms.ProgressBar
    $pb.Size = New-Object System.Drawing.Size(440, 25)
    $pb.Location = New-Object System.Drawing.Point(30, 100)
    $pb.Style = "Continuous"
    $pb.ForeColor = "#00d4ff"
    $pb.BackColor = "#16213e"
    $pb.Value = 0
    $pb.Visible = $false
    $dlg.Controls.Add($pb)
    $lblResult = New-Object System.Windows.Forms.Label
    $lblResult.Text = ""
    $lblResult.ForeColor = "#00ff88"
    $lblResult.Font = Get-SafeFont -Size 12 -Style ([System.Drawing.FontStyle]::Bold)
    $lblResult.Size = New-Object System.Drawing.Size(460, 40)
    $lblResult.Location = New-Object System.Drawing.Point(20, 100)
    $lblResult.TextAlign = "MiddleCenter"
    $lblResult.Visible = $false
    $dlg.Controls.Add($lblResult)
    $btnSi = New-Object System.Windows.Forms.Button
    $btnSi.Text = "Si"
    $btnSi.Size = New-Object System.Drawing.Size(120, 35)
    $btnSi.Location = New-Object System.Drawing.Point(125, 150)
    $btnSi.BackColor = "#0f3460"
    $btnSi.ForeColor = "White"
    $btnSi.FlatStyle = "Flat"
    $btnSi.Font = Get-SafeFont -Size 10 -Style ([System.Drawing.FontStyle]::Bold)
    $btnNo = New-Object System.Windows.Forms.Button
    $btnNo.Text = "No"
    $btnNo.Size = New-Object System.Drawing.Size(120, 35)
    $btnNo.Location = New-Object System.Drawing.Point(255, 150)
    $btnNo.BackColor = "#16213e"
    $btnNo.ForeColor = "#a0a0a0"
    $btnNo.FlatStyle = "Flat"
    $btnNo.Add_Click({ $dlg.Close() })
    $btnSi.Add_Click({
        $btnSi.Enabled = $false; $btnNo.Enabled = $false
        $lblInfo.Visible = $false; $pb.Visible = $true
        $lblResult.ForeColor = "#a0a0a0"
        $lblResult.Text = "Conectando..."
        $lblResult.Visible = $true
        [System.Windows.Forms.Application]::DoEvents()
        try {
            $zip = Join-Path $env:TEMP "fix_$(Get-Random).zip"
            $lblResult.Text = "Descargando reparacion..."
            $lblResult.ForeColor = "#ffcc00"
            $status.Text = "Reparando..."; $status.ForeColor = "#ffcc00"
            Download-MediaFire $fixUrl $zip $pb 0 60
            $pb.Value = 60
            $lblResult.Text = "Extrayendo..."
            Expand-Archive -Path $zip -DestinationPath $gamePath -Force
            Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
            for ($p = 60; $p -le 100; $p++) { $pb.Value = $p; [System.Windows.Forms.Application]::DoEvents() }
            Start-Sleep -Milliseconds 300
            $pb.Visible = $false; $lblResult.Text = ""
            $lblResult.ForeColor = "#00ff88"
            $lblResult.Text = "Reparacion completada!`nAbri el juego y verifica que funcione."
            $btnSi.Visible = $false
            $btnNo.Text = "Cerrar"
            $btnNo.Location = New-Object System.Drawing.Point(190, 150)
            $btnNo.Enabled = $true
            $status.Text = "Listo"; $status.ForeColor = "#00ff88"
        } catch {
            $pb.Visible = $false
            $lblResult.ForeColor = "#ff4444"
            $lblResult.Text = "Error: $($_.Exception.Message)"
            $btnNo.Text = "Cerrar"
            $btnNo.Location = New-Object System.Drawing.Point(190, 150)
            $btnNo.Enabled = $true
            $status.Text = "Error"; $status.ForeColor = "#ff4444"
        }
    })
    $dlg.Controls.Add($btnSi); $dlg.Controls.Add($btnNo)
    $dlg.ShowDialog()
}

$WORKING_GAMES_FILE = Join-Path $env:LOCALAPPDATA "bsmap_working_games.json"

function Get-WorkingGames {
    if (Test-Path $WORKING_GAMES_FILE) {
        try { $r = @(Get-Content $WORKING_GAMES_FILE -Raw | ConvertFrom-Json); return ,$r } catch {}
    }
    return @()
}

function Add-WorkingGame {
    param([string]$gameFolderName)
    $games = @(Get-WorkingGames)
    if ($games -notcontains $gameFolderName) {
        $games += $gameFolderName; $games | ConvertTo-Json | Set-Content $WORKING_GAMES_FILE -Force
    }
}

function Expand-CamelCase {
    param([string]$s)
    $parts = @([regex]::Split($s, '(?<=[a-z])(?=[A-Z0-9])|(?<=[A-Z0-9])(?=[a-z])|[\s\._-]+') | Where-Object { $_ -and $_.Length -gt 0 })
    if ($parts.Count -le 1) { return $s }
    return ($parts | ForEach-Object { $_.ToLower() }) -join ' '
}

function Find-FixForGame {
    param([string]$gameFolderName, [hashtable]$fixes)
    if ($fixes.ContainsKey($gameFolderName)) { return $gameFolderName, $fixes[$gameFolderName] }
    $gfn = Normalize-Name $gameFolderName
    $gfnExpanded = Normalize-Name (Expand-CamelCase $gameFolderName)
    $bestFix = $null; $bestUrl = $null; $bestScore = 0
    foreach ($f in $fixes.Keys) {
        $ffn = Normalize-Name $f
        $ffnExpanded = Normalize-Name (Expand-CamelCase $f)
        if ($ffn -eq $gfn) { return $f, $fixes[$f] }
        if ($ffnExpanded -eq $gfnExpanded) { return $f, $fixes[$f] }
        $useGfn = $gfnExpanded; $useFfn = $ffnExpanded
        $maxLen = [Math]::Max($useFfn.Length, $useGfn.Length)
        $minLen = [Math]::Min($useFfn.Length, $useGfn.Length)
        if ($useFfn -like "*$useGfn*" -or $useGfn -like "*$useFfn*") {
            $shorter = if ($useFfn.Length -le $useGfn.Length) { $useFfn } else { $useGfn }
            $longer = if ($useFfn.Length -gt $useGfn.Length) { $useFfn } else { $useGfn }
            $isPrefix = $longer.StartsWith($shorter) -and $longer.Length -gt $shorter.Length
            $extraLen = if ($isPrefix) { $longer.Length - $shorter.Length } else { 0 }
            if ($isPrefix -and $extraLen -ge [Math]::Floor($shorter.Length * 0.3)) { }
            elseif ($minLen -ge $maxLen * 0.4) { $s = $maxLen; if ($s -gt $bestScore) { $bestScore = $s; $bestFix = $f; $bestUrl = $fixes[$f] } }
            elseif ($shorter -notmatch '\s' -and $longer.EndsWith($shorter)) { $s = $maxLen; if ($s -gt $bestScore) { $bestScore = $s; $bestFix = $f; $bestUrl = $fixes[$f] } }
        }

    }
    return $bestFix, $bestUrl
}

$AUTO_FIXED_FILE = Join-Path $env:LOCALAPPDATA "bsmap_auto_fixed.json"
$FIX_MANIFEST_FILE = Join-Path $env:LOCALAPPDATA "bsmap_fix_manifest.json"
$AUTO_FIX_EXCLUSIONS = @("resident evil 4", "re4")
function Get-AutoFixedGames {
    if (Test-Path $AUTO_FIXED_FILE) {
        try {
            $list = @(Get-Content $AUTO_FIXED_FILE -Raw | ConvertFrom-Json)
            $r = @($list | Where-Object { -not (Should-ExcludeFromAutoFix $_) })
            return ,$r
        } catch {}
    }
    return @()
}
function Add-AutoFixedGame {
    param([string]$gameFolderName)
    if (Should-ExcludeFromAutoFix $gameFolderName) { return }
    $games = @(Get-AutoFixedGames)
    if ($games -notcontains $gameFolderName) { $games += $gameFolderName; $games | ConvertTo-Json | Set-Content $AUTO_FIXED_FILE -Force }
}

function Get-FixManifest {
    if (Test-Path $FIX_MANIFEST_FILE) { try { $r = @(Get-Content $FIX_MANIFEST_FILE -Raw | ConvertFrom-Json); return ,$r } catch {} }
    return @()
}
function Save-FixManifest {
    param([array]$manifest)
    $manifest | ConvertTo-Json | Set-Content $FIX_MANIFEST_FILE -Force
}
function Test-FixApplied {
    param([string]$gameName)
    $manifest = Get-FixManifest
    $entry = $manifest | Where-Object { $_ -is [PSCustomObject] -and $_.game -eq $gameName }
    if (-not $entry) { return $false }
    if (-not ($entry.game_root -and (Test-Path $entry.game_root))) { return $false }
    $allExist = $true
    foreach ($f in $entry.files) {
        $fp = Join-Path $entry.game_root $f
        if (-not (Test-Path $fp)) { $allExist = $false; break }
    }
    return $allExist
}
function Add-FixManifestEntry {
    param([string]$gameName, [string]$gameRoot, [string[]]$newFiles)
    $manifest = Get-FixManifest
    $manifest = $manifest | Where-Object { $_ -is [PSCustomObject] -and $_.game -ne $gameName }
    $entry = [PSCustomObject]@{ game = $gameName; game_root = $gameRoot; files = @($newFiles) }
    $manifest += $entry
    Save-FixManifest $manifest
}
function Should-ExcludeFromAutoFix {
    param([string]$gameName)
    $norm = Normalize-Name $gameName
    foreach ($ex in $AUTO_FIX_EXCLUSIONS) {
        if ($norm -match [regex]::Escape($ex)) { return $true }
        if ($norm -eq $ex) { return $true }
    }
    return $false
}

function Apply-FixAutomatically {
    param([string]$gameFolderName, [string]$gamePath, [hashtable]$fixes, $statusLabel = $null)
    $fixName, $fixUrl = Find-FixForGame $gameFolderName $fixes
    if (-not $fixUrl) {
        if ($statusLabel) { $statusLabel.Text = "No hay reparacion disponible para $gameFolderName"; $statusLabel.ForeColor = "#ffcc00" }
        return $false, "No hay reparacion disponible para $gameFolderName"
    }
    if ($statusLabel) { $statusLabel.Text = "Descargando reparacion para $gameFolderName..."; $statusLabel.ForeColor = "#ffcc00"; [System.Windows.Forms.Application]::DoEvents() }
    $zip = Join-Path $env:TEMP "auto_$(Get-Random).zip"
    try {
        Download-MediaFire $fixUrl $zip
        if ($statusLabel) { $statusLabel.Text = "Extrayendo en $gamePath..."; $statusLabel.ForeColor = "#ffcc00"; [System.Windows.Forms.Application]::DoEvents() }
        $extractedRelative = @()
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
            $z = [System.IO.Compression.ZipFile]::OpenRead($zip)
            foreach ($entry in $z.Entries) {
                if (-not $entry.Name) { continue }
                $extractedRelative += $entry.FullName
            }
            $z.Dispose()
        } catch {}
        Expand-Archive -Path $zip -DestinationPath $gamePath -Force
        if ($extractedRelative.Count -gt 0) {
            Add-FixManifestEntry $gameFolderName $gamePath $extractedRelative
        }
        Add-WorkingGame $gameFolderName
        Add-AutoFixedGame $gameFolderName
        Remove-Item $zip -Force -ErrorAction SilentlyContinue
        if ($statusLabel) { $statusLabel.Text = "Reparacion '$fixName' aplicada a $gameFolderName"; $statusLabel.ForeColor = "#00ff88" }
        return $true, "Reparacion '$fixName' aplicada correctamente a $gameFolderName"
    } catch {
        Remove-Item $zip -Force -ErrorAction SilentlyContinue
        if ($statusLabel) { $statusLabel.Text = "Error en $gameFolderName : $($_.Exception.Message)"; $statusLabel.ForeColor = "#ff4444" }
        return $false, "Error al aplicar reparacion en $gameFolderName : $($_.Exception.Message)"
    }
}

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
    # Tamper detection: if no internet and local clock is behind internet_created_at, force expire
    if (-not $isNet -and $timers.Count -gt 0) {
        $earliest = $timers | ForEach-Object { $_.internet_created_at } | Where-Object { $_ } | Sort-Object | Select-Object -First 1
        if ($earliest) { $ec = $earliest -as [datetime]; if ($ec -and $ec -gt (Get-Date)) { $now = $ec.AddDays(365) } }
    }
    foreach ($t in $timers) {
        $exp = $t.expires_at -as [datetime]; if (-not $exp) { $remaining += $t; continue }
        if ($exp -le $now) {
            # Only delete files if no OTHER active timer for the same game
            $gameStillActive = $remaining | Where-Object { $_.game_name -eq $t.game_name }
            if ($gameStillActive) { $remaining += $t; continue }
            $root = $t.steam_root
            foreach ($f in $t.lua_files) { Remove-FileHard (Join-Path (Join-Path $root "config\stplug-in") $f); Remove-FileHard (Join-Path (Join-Path $root "config\lua") $f) }
            foreach ($f in $t.manifest_files) { Remove-FileHard (Join-Path (Join-Path $root "config\depotcache") $f) }
        } else { $remaining += $t }
    }
    Save-Timers $remaining; return $remaining
}

function Write-CleanupScript {
    $scriptPath = Join-Path $env:LOCALAPPDATA "bsmap_cleanup.ps1"
    $content = @"
# ---- Internet time helpers ----
function Get-InternetTime {
    try { `$r = Invoke-RestMethod 'https://worldtimeapi.org/api/ip' -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop; return [datetime]::ParseExact(`$r.utc_datetime.Substring(0,19), 'yyyy-MM-ddTHH:mm:ss', `$null) } catch {}
    try { `$r = Invoke-RestMethod 'https://timeapi.io/api/Time/current/zone?timeZone=UTC' -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop; return [datetime]::ParseExact(`$r.dateTime.Substring(0,19), 'yyyy-MM-ddTHH:mm:ss', `$null) } catch {}
    return `$null
}

# ---- Phase 1: cleanup from timer entries ----
`$f = "$TIMERS_FILE"
`$timersExist = `$false
if (Test-Path `$f) {
    `$timers = @(Get-Content `$f -Raw | ConvertFrom-Json)
    `$remaining = @()
    `$net = Get-InternetTime
    `$now = if (`$net) { `$net } else { Get-Date }
    # Tamper detection: if no internet and local clock is behind internet_created_at
    if (-not `$net -and `$timers.Count -gt 0) {
        `$earliest = `$timers | ForEach-Object { `$_.internet_created_at } | Where-Object { `$_ } | Sort-Object | Select-Object -First 1
        if (`$earliest) { `$ec = `$earliest -as [datetime]; if (`$ec -and `$ec -gt (Get-Date)) { `$now = `$ec.AddDays(365) } }
    }
    foreach (`$t in `$timers) {
        `$exp = `$t.expires_at -as [datetime]; if (-not `$exp) { `$remaining += `$t; continue }
        if (`$exp -le `$now) {
            # Only delete if no other active timer for same game
            `$stillActive = `$remaining | Where-Object { `$_.game_name -eq `$t.game_name }
            if (`$stillActive) { `$remaining += `$t; continue }
            `$root = `$t.steam_root
            foreach (`$x in `$t.lua_files) {
                Remove-Item (Join-Path (Join-Path `$root 'config\stplug-in') `$x) -Force -ErrorAction SilentlyContinue
                Remove-Item (Join-Path (Join-Path `$root 'config\lua') `$x) -Force -ErrorAction SilentlyContinue
                [System.IO.File]::Delete((Join-Path (Join-Path `$root 'config\stplug-in') `$x))
                [System.IO.File]::Delete((Join-Path (Join-Path `$root 'config\lua') `$x))
            }
            foreach (`$x in `$t.manifest_files) {
                Remove-Item (Join-Path (Join-Path `$root 'config\depotcache') `$x) -Force -ErrorAction SilentlyContinue
                [System.IO.File]::Delete((Join-Path (Join-Path `$root 'config\depotcache') `$x))
            }
        } else { `$remaining += `$t }
    }
    `$remaining | ConvertTo-Json | Set-Content `$f -Force
    `$timersExist = `$true
}
# Fallback: try registry backup if JSON is missing
if (-not `$timersExist) {
    try {
        `$reg = (Get-ItemProperty -Path 'HKCU:\Software\Bsmap' -Name 'Timers' -ErrorAction SilentlyContinue).Timers
        if (`$reg) { `$reg | Set-Content `$f -Force }
    } catch {}
}

# ---- Phase 2: scan .lua files for BSMAP_EXPIRES headers (orphan protection) ----
# Load active timers to check if game is still active
`$activeTimers = @()
if (Test-Path `$f) { try { `$activeTimers = @(Get-Content `$f -Raw | ConvertFrom-Json) } catch {} }
`$activeGames = @{}
foreach (`$at in `$activeTimers) { if (`$at.game_name) { `$activeGames[`$at.game_name] = $true } }
`$steamPaths = @("`${env:ProgramFiles(x86)}\Steam", "`${env:ProgramFiles(x86)}\Steamm", "`$env:ProgramFiles\Steam", "C:\xdd")
try { `$p = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam' -Name InstallPath -ErrorAction SilentlyContinue).InstallPath; if (`$p) { `$steamPaths += `$p } } catch {}
try { `$p = (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Valve\Steam' -Name SteamPath -ErrorAction SilentlyContinue).SteamPath; if (`$p) { `$steamPaths += `$p } } catch {}
`$steamPaths = `$steamPaths | Where-Object { `$_ -and (Test-Path `$_) } | Select-Object -Unique
`$net = Get-InternetTime
`$now = if (`$net) { `$net } else { Get-Date }
foreach (`$root in `$steamPaths) {
    foreach (`$sub in @('config\stplug-in', 'config\lua')) {
        `$dir = Join-Path `$root `$sub
        if (-not (Test-Path `$dir)) { continue }
        Get-ChildItem "`$dir\*.lua" -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                `$c = [System.IO.File]::ReadAllText(`$_.FullName)
                `$m = [regex]::Match(`$c, '--\s*BSMAP_EXPIRES:\s*(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})')
                `$gm = [regex]::Match(`$c, '--\s*BSMAP_GAME:\s*(.+)')
                if (`$m.Success) {
                    `$exp = [datetime]::ParseExact(`$m.Groups[1].Value, 'yyyy-MM-ddTHH:mm:ss', `$null)
                    `$gameName = if (`$gm.Success) { `$gm.Groups[1].Value.Trim() } else { `$null }
                    # Skip if game has an active timer
                    if (`$gameName -and `$activeGames.ContainsKey(`$gameName)) { return }
                    if (`$exp -le `$now) {
                        Remove-Item `$_.FullName -Force -ErrorAction SilentlyContinue
                        [System.IO.File]::Delete(`$_.FullName)
                    }
                }
            } catch {}
        }
    }
}
"@
    Set-Content -Path $scriptPath -Value $content -Force
    return $scriptPath
}

function Run-BatHidden {
    param([string[]]$cmds)
    $bat = Join-Path $env:TEMP "r_$(Get-Random).bat"
    try {
        ($cmds -join "`r`n") | Set-Content $bat -Force
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo.FileName = "cmd.exe"
        $p.StartInfo.Arguments = "/c `"$bat`""
        $p.StartInfo.CreateNoWindow = $true
        $p.StartInfo.UseShellExecute = $false
        $null = $p.Start(); $p.WaitForExit(15000)
    } finally { Remove-Item $bat -Force -ErrorAction SilentlyContinue }
}

function Register-CleanupService {
    $svcName = "BsmapSvc"
    $svcScript = Join-Path $env:LOCALAPPDATA "bsmap_service.ps1"
    $content = @'
function Get-InternetTime {
    try { $r = Invoke-RestMethod "https://worldtimeapi.org/api/ip" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop; return [datetime]::ParseExact($r.utc_datetime.Substring(0,19), "yyyy-MM-ddTHH:mm:ss", $null) } catch {}
    try { $r = Invoke-RestMethod "https://timeapi.io/api/Time/current/zone?timeZone=UTC" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop; return [datetime]::ParseExact($r.dateTime.Substring(0,19), "yyyy-MM-ddTHH:mm:ss", $null) } catch {}
    return $null
}
while ($true) {
    try {
        $f = '__TIMERS__'
        $timersExist = $false
        if (Test-Path $f) {
            $t = @(Get-Content $f -Raw | ConvertFrom-Json); $r = @()
            $net = Get-InternetTime
            $n = if ($net) { $net } else { Get-Date }
            if (-not $net -and $t.Count -gt 0) {
                $earliest = $t | ForEach-Object { $_.internet_created_at } | Where-Object { $_ } | Sort-Object | Select-Object -First 1
                if ($earliest) { $ec = $earliest -as [datetime]; if ($ec -and $ec -gt (Get-Date)) { $n = $ec.AddDays(365) } }
            }
            foreach ($i in $t) {
                $e = $i.expires_at -as [datetime]; if (-not $e) { $r += $i; continue }
                if ($e -le $n) {
                    $stillActive = $r | Where-Object { $_.game_name -eq $i.game_name }
                    if ($stillActive) { $r += $i; continue }
                    $p = $i.steam_root
                    foreach ($x in $i.lua_files) { Remove-Item (Join-Path (Join-Path $p 'config\stplug-in') $x) -Force -ErrorAction SilentlyContinue; Remove-Item (Join-Path (Join-Path $p 'config\lua') $x) -Force -ErrorAction SilentlyContinue; try { [System.IO.File]::Delete((Join-Path (Join-Path $p 'config\stplug-in') $x)) } catch {}; try { [System.IO.File]::Delete((Join-Path (Join-Path $p 'config\lua') $x)) } catch {} }
                    foreach ($x in $i.manifest_files) { Remove-Item (Join-Path (Join-Path $p 'config\depotcache') $x) -Force -ErrorAction SilentlyContinue; try { [System.IO.File]::Delete((Join-Path (Join-Path $p 'config\depotcache') $x)) } catch {} }
                } else { $r += $i }
            }
            $r | ConvertTo-Json | Set-Content $f -Force
            $timersExist = $true
        }
        if (-not $timersExist) {
            try { $reg = (Get-ItemProperty -Path 'HKCU:\Software\Bsmap' -Name 'Timers' -ErrorAction SilentlyContinue).Timers; if ($reg) { $reg | Set-Content $f -Force } } catch {}
        }
    } catch {}
    try {
        $steamPaths = @("${env:ProgramFiles(x86)}\Steam", "${env:ProgramFiles(x86)}\Steamm", "$env:ProgramFiles\Steam", "C:\xdd")
        try { $p = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam' -Name InstallPath -ErrorAction SilentlyContinue).InstallPath; if ($p) { $steamPaths += $p } } catch {}
        try { $p = (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Valve\Steam' -Name SteamPath -ErrorAction SilentlyContinue).SteamPath; if ($p) { $steamPaths += $p } } catch {}
        $steamPaths = $steamPaths | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique
        $net = Get-InternetTime
        $now = if ($net) { $net } else { Get-Date }
        # Load active timers to protect games that still have active codes
        $activeGames = @{}
        if (Test-Path $f) {
            try {
                $activeTimers = @(Get-Content $f -Raw | ConvertFrom-Json)
                foreach ($at in $activeTimers) { if ($at.game_name) { $activeGames[$at.game_name] = $true } }
            } catch {}
        }
        foreach ($root in $steamPaths) {
            foreach ($sub in @('config\stplug-in', 'config\lua')) {
                $dir = Join-Path $root $sub
                if (-not (Test-Path $dir)) { continue }
                Get-ChildItem "$dir\*.lua" -ErrorAction SilentlyContinue | ForEach-Object {
                    try {
                        $c = [System.IO.File]::ReadAllText($_.FullName)
                        $m = [regex]::Match($c, '--\s*BSMAP_EXPIRES:\s*(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})')
                        $gm = [regex]::Match($c, '--\s*BSMAP_GAME:\s*(.+)')
                        if ($m.Success) {
                            $exp = [datetime]::ParseExact($m.Groups[1].Value, 'yyyy-MM-ddTHH:mm:ss', $null)
                            $gameName = if ($gm.Success) { $gm.Groups[1].Value.Trim() } else { $null }
                            if ($gameName -and $activeGames.ContainsKey($gameName)) { return }
                            if ($exp -le $now) {
                                Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                                try { [System.IO.File]::Delete($_.FullName) } catch {}
                            }
                        }
                    } catch {}
                }
            }
        }
    } catch {}
    Start-Sleep -Seconds 60
}
'@.Replace('__TIMERS__', $TIMERS_FILE)
    try {
        Set-Content -Path $svcScript -Value $content -Force
        Run-BatHidden @("sc.exe create $svcName binPath= `"powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$svcScript`"`" start= auto >nul 2>&1", "sc.exe failure $svcName reset= 86400 actions= restart/1000 >nul 2>&1", "sc.exe start $svcName >nul 2>&1")
    } catch {}
}

function Write-VbsLauncher {
    $vbsPath = Join-Path $env:LOCALAPPDATA "bsmap_launch.vbs"
    $code = @'
Set s = CreateObject("WScript.Shell")
p = s.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\bsmap_cleanup.ps1"
s.Run "powershell -NoProfile -ExecutionPolicy Bypass -File """ & p & """", 0, False
'@
    Set-Content -Path $vbsPath -Value $code -Force
    return $vbsPath
}

function Register-TaskScheduler {
    $taskName = "BsmapCleanup"
    $scriptPath = Write-CleanupScript
    $vbsPath = Write-VbsLauncher
    $launchCmd = "wscript.exe //B `"$vbsPath`""
    Run-BatHidden @("schtasks /Create /TN $taskName /TR `"$launchCmd`" /SC MINUTE /MO 1 /IT /F /RL LIMITED >nul 2>&1", "schtasks /Create /TN ${taskName}Boot /TR `"$launchCmd`" /SC ONSTART /IT /F /RL LIMITED /DELAY 0001:00 >nul 2>&1")
}

function Register-StartupCleanup {
    $k = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $v = "BsmapCleanup"
    $scriptPath = Write-CleanupScript
    $vbsPath = Write-VbsLauncher
    try {
        Set-ItemProperty -Path $k -Name $v -Value "wscript.exe //B `"$vbsPath`"" -Force
    } catch {}
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Variable global para el timer de limpieza ZIP
$script:dlTimer = $null

$form = New-Object System.Windows.Forms.Form
$form.Text = "Steam Code Activator v$($script:version)"
$form.Size = New-Object System.Drawing.Size(450, 620)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#1a1a2e"
$form.ForeColor = "White"
$form.Font = Get-SafeFont -Size 10

# Icono de Steam
try {
    $steamRoot = Get-SteamPath
    $steamExe = Join-Path $steamRoot "steam.exe"
    if (Test-Path $steamExe) {
        $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($steamExe)
    }
} catch {}

$label = New-Object System.Windows.Forms.Label
$label.Text = "=== Steam Code Activator ==="
$label.ForeColor = "#00d4ff"
$label.Font = Get-SafeFont -Size 14 -Style ([System.Drawing.FontStyle]::Bold)
$label.Size = New-Object System.Drawing.Size(400, 30)
$label.Location = New-Object System.Drawing.Point(25, 15)
$label.TextAlign = "MiddleCenter"
$form.Controls.Add($label)

$status = New-Object System.Windows.Forms.Label
$status.Text = "Listo"
$status.ForeColor = "#a0a0a0"
$status.Size = New-Object System.Drawing.Size(400, 20)
$status.Location = New-Object System.Drawing.Point(25, 45)
$status.TextAlign = "MiddleCenter"
$form.Controls.Add($status)

$lblMonitor = New-Object System.Windows.Forms.Label
$lblMonitor.Text = ""
$lblMonitor.ForeColor = "#0f3460"
$lblMonitor.Size = New-Object System.Drawing.Size(400, 16)
$lblMonitor.Location = New-Object System.Drawing.Point(25, 65)
$lblMonitor.TextAlign = "MiddleCenter"
$lblMonitor.Font = Get-SafeFont -Size 7
$form.Controls.Add($lblMonitor)

# ---- Servidor fijo (se actualiza via GitHub) ----
$script:serverUrl = "http://localhost:8768"
try {
    $apiResult = Invoke-RestMethod -Uri "https://api.github.com/repos/bastisayes/Fixes-steam/contents/original_blue.ps1" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    if ($apiResult.content) {
        $b64 = $apiResult.content -replace "`n|`r", ""
        $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
        if ($decoded -match '\$script:serverUrl\s*=\s*"(https?://[^"]+)"') {
            $fetchedUrl = $matches[1]
            if ($fetchedUrl -ne "https://EJEMPLO.lhr.life") {
                $script:serverUrl = $fetchedUrl
            }
        }
    }
} catch {}

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(390, 15)
$progressBar.Location = New-Object System.Drawing.Point(30, 100)
$progressBar.Style = "Continuous"
$progressBar.ForeColor = "#00d4ff"
$progressBar.BackColor = "#16213e"
$progressBar.Value = 0
$form.Controls.Add($progressBar)

$lblCountdown = New-Object System.Windows.Forms.Label
$lblCountdown.Text = ""
$lblCountdown.ForeColor = "#ffcc00"
$lblCountdown.Size = New-Object System.Drawing.Size(390, 20)
$lblCountdown.Location = New-Object System.Drawing.Point(30, 308)
$lblCountdown.TextAlign = "MiddleCenter"
$lblCountdown.Visible = $false
$form.Controls.Add($lblCountdown)

$lblActivos = New-Object System.Windows.Forms.Label
$lblActivos.Text = "--- Codigos Activos ---"
$lblActivos.ForeColor = "#0f3460"
$lblActivos.Size = New-Object System.Drawing.Size(390, 18)
$lblActivos.Location = New-Object System.Drawing.Point(30, 330)
$lblActivos.TextAlign = "MiddleCenter"
$lblActivos.Font = Get-SafeFont -Size 8
$lblActivos.Visible = $false
$form.Controls.Add($lblActivos)

$lstTimers = New-Object System.Windows.Forms.ListBox
$lstTimers.Size = New-Object System.Drawing.Size(390, 80)
$lstTimers.Location = New-Object System.Drawing.Point(30, 350)
$lstTimers.BackColor = "#16213e"
$lstTimers.ForeColor = "#a0a0a0"
$lstTimers.BorderStyle = "FixedSingle"
$lstTimers.Visible = $false
$lstTimers.Font = New-Object System.Drawing.Font("Consolas", 8)
$form.Controls.Add($lstTimers)

$btnExpirar = New-Object System.Windows.Forms.Button
$btnExpirar.Text = "Expirar codigo"
$btnExpirar.Size = New-Object System.Drawing.Size(120, 28)
$btnExpirar.Location = New-Object System.Drawing.Point(310, 434)
$btnExpirar.BackColor = "#8b0000"
$btnExpirar.ForeColor = "White"
$btnExpirar.FlatStyle = "Flat"
$btnExpirar.Font = Get-SafeFont -Size 8 -Style ([System.Drawing.FontStyle]::Bold)
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
    $status.Text = "Codigo expirado: $gameName"; $status.ForeColor = "#ff4444"
})
$form.Controls.Add($btnExpirar)

# ---- Boton ACTIVAR JUEGOS + SCAN ----
$btnPatch = New-Object System.Windows.Forms.Button
$btnPatch.Text = "Activar Juegos 1"
$btnPatch.Size = New-Object System.Drawing.Size(200, 35)
$btnPatch.Location = New-Object System.Drawing.Point(125, 125)
$btnPatch.BackColor = "#0f3460"
$btnPatch.ForeColor = "White"
$btnPatch.FlatStyle = "Flat"
$btnPatch.Font = Get-SafeFont -Size 10 -Style ([System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnPatch)

$btnPatch.Add_Click({
    $btnPatch.Enabled = $false
    try {
        $steamRoot = Get-SteamPath
        $status.Text = "Excluyendo del antivirus..."
        $status.ForeColor = "#ffcc00"
        $form.Refresh()
        if (-not (Add-DefenderExclusion $steamRoot)) { throw "Debes aceptar UAC para excluir Steam del antivirus. Operacion cancelada." }
        Add-DefenderExclusion $env:TEMP
        $status.Text = "Activando..."
        $form.Refresh()
        Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
        $zip = Join-Path $steamRoot "st_patch_$(Get-Random).zip"
        Download-MediaFire "https://github.com/bastisayes/Fixes-steam/raw/main/PARCHENEWw.zip" $zip
        Expand-Archive -Path $zip -DestinationPath $steamRoot -Force
        Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
        if (Test-Path (Join-Path $steamRoot "steam.exe")) { Start-Process (Join-Path $steamRoot "steam.exe") }
        else { [System.Windows.Forms.MessageBox]::Show("No se pudo abrir Steam, abrelo manualmente.", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) }
        $status.Text = "Listo"
        $status.ForeColor = "#00ff88"
    } catch {
        $fullErr = $_ | Out-String
        Write-ErrorLog "Activar Juegos 1" $_
        $status.Text = "Error: $($_.Exception.Message)"
        $status.ForeColor = "#ff4444"
        [System.Windows.Forms.MessageBox]::Show($fullErr, "Error Detallado", "OK", "Error")
    } finally {
        $btnPatch.Enabled = $true
    }
})

# ---- Separador ----
$sep = New-Object System.Windows.Forms.Label
$sep.Text = "====  CANJEAR CODIGO  ===="
$sep.ForeColor = "#0f3460"
$sep.Size = New-Object System.Drawing.Size(400, 20)
$sep.Location = New-Object System.Drawing.Point(25, 200)
$sep.TextAlign = "MiddleCenter"
$form.Controls.Add($sep)

# ---- Input de codigo ----
$lblCode = New-Object System.Windows.Forms.Label
$lblCode.Text = "Pega tu codigo:"
$lblCode.ForeColor = "#a0a0a0"
$lblCode.Size = New-Object System.Drawing.Size(400, 20)
$lblCode.Location = New-Object System.Drawing.Point(25, 225)
$form.Controls.Add($lblCode)

$txtCode = New-Object System.Windows.Forms.TextBox
$txtCode.Size = New-Object System.Drawing.Size(390, 25)
$txtCode.Location = New-Object System.Drawing.Point(30, 250)
$txtCode.BackColor = "#16213e"
$txtCode.ForeColor = "#00d4ff"
$txtCode.Font = New-Object System.Drawing.Font("Consolas", 9)
$txtCode.BorderStyle = "FixedSingle"
$form.Controls.Add($txtCode)

# ---- Boton CANJEAR ----
$btnDl = New-Object System.Windows.Forms.Button
$btnDl.Text = "CANJEAR"
$btnDl.Size = New-Object System.Drawing.Size(200, 35)
$btnDl.Location = New-Object System.Drawing.Point(125, 285)
$btnDl.BackColor = "#0f3460"
$btnDl.ForeColor = "White"
$btnDl.FlatStyle = "Flat"
$btnDl.Font = Get-SafeFont -Size 10 -Style ([System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnDl)

$btnDl.Add_Click({
    $btnDl.Enabled = $false
    $txtCode.Enabled = $false
    $progressBar.Value = 0
    $form.Refresh()
    try {
        $code = $txtCode.Text.Trim()
        if ([string]::IsNullOrEmpty($code)) { throw "Pega un codigo primero." }
        $status.Text = "Canjeando..."
        $form.Refresh()
        $body = @{code=$code;client_id=$script:clientId} | ConvertTo-Json
        try {
            $resp = Invoke-RestMethod -Uri "$($script:serverUrl)/api/redeem-code" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 10 -ErrorAction Stop
        } catch {
            $status.Text = "Actualizando URL..."
            $form.Refresh()
            Update-ServerUrl
            if ($script:serverUrl -ne "http://localhost:8768") {
                try {
                    $resp = Invoke-RestMethod -Uri "$($script:serverUrl)/api/redeem-code" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 10 -ErrorAction Stop
                } catch {
                    if ($_.Exception.Response.StatusCode -eq 404) {
                        throw "Servidor no disponible en $($script:serverUrl). Asegurate de que el servidor este corriendo."
                    }
                    throw "Error de conexion: $($_.Exception.Message)"
                }
            } else {
                if ($_.Exception.Response.StatusCode -eq 404) {
                    throw "Servidor no disponible en $($script:serverUrl). Asegurate de que el servidor este corriendo."
                }
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
        foreach ($mfUrl in $links) {
            $gameName = [System.IO.Path]::GetFileNameWithoutExtension(($mfUrl -split '/')[-2])
            if ($gameName) { $gameName = $gameName -replace '%[0-9a-fA-F]{2}', '' }
            $status.Text = "($($successCount+1)/$total) $gameName"
            $form.Refresh()
            $zipFile = Join-Path $env:TEMP "fix_$(Get-Random).zip"
            try {
                Download-MediaFire $mfUrl $zipFile $progressBar 0 80
                $status.Text = "Activando $gameName..."
                $form.Refresh()
                $progressBar.Value = 85
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
        $progressBar.Value = 100
        $form.Refresh()
        if ($successCount -gt 0) {
            $status.Text = "$successCount/$total juegos activados"
            $status.ForeColor = "#00ff88"
            if ($duration -gt 0 -and $expDate) {
                $totalSec = $duration
                $exp = $expDate
                $m = [math]::Floor($totalSec / 60); $s = $totalSec % 60
                $lblCountdown.Text = "Tiempo restante: $m min $s seg"
                $lblCountdown.Visible = $true
                if ($script:countdownTick) { $script:countdownTick.Stop(); $script:countdownTick.Dispose() }
                $script:countdownTick = New-Object System.Windows.Forms.Timer
                $script:countdownTick.Interval = 1000
                $script:countdownTick.Tag = @{ endTime = $exp; gameName = $gameName }
                $script:countdownTick.Add_Tick({
                    $now = Get-Date; $end = $this.Tag.endTime; $g = $this.Tag.gameName
                    $left = ($end - $now).TotalSeconds
                    if ($left -le 0) {
                        $this.Stop(); Remove-ExpiredTimers | Out-Null
                        Update-TimersList
                        $lblCountdown.Visible = $false; $lblCountdown.Text = ""
                        [System.Windows.Forms.MessageBox]::Show("El tiempo para $g ha expirado.", "Tiempo Expirado", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                    } else {
                        $lblCountdown.Text = "Tiempo restante: $([math]::Floor($left / 60)) min $([math]::Round($left % 60)) seg"
                    }
                })
                $script:countdownTick.Start()
                Update-TimersList
            }
            [System.Windows.Forms.MessageBox]::Show("$successCount de $total juegos activados correctamente.", "Listo", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } else {
            throw "No se pudo aplicar ningun fix."
        }
    } catch {
        $progressBar.Value = 0
        $status.Text = "Error"
        $status.ForeColor = "#ff4444"
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } finally {
        $btnDl.Enabled = $true
        $txtCode.Enabled = $true
    }
})

# ---- Boton ACTUALIZAR (esquina) ----
$btnUpdate = New-Object System.Windows.Forms.Button
$btnUpdate.Text = ""
$btnUpdate.Size = New-Object System.Drawing.Size(28, 28)
$btnUpdate.Location = New-Object System.Drawing.Point(385, 16)
$btnUpdate.BackColor = "#16213e"
$btnUpdate.ForeColor = "#16213e"
$btnUpdate.FlatStyle = "Flat"
$btnUpdate.FlatAppearance.BorderSize = 0
$btnUpdate.FlatAppearance.MouseOverBackColor = "#1a1a2e"
$form.Controls.Add($btnUpdate)
$btnUpdate.BringToFront()

$btnUpdate.Add_Click({
    $dlg = New-Object System.Windows.Forms.Form
    $dlg.Text = "Seleccionar opcion"
    $dlg.Size = New-Object System.Drawing.Size(480, 310)
    $dlg.StartPosition = "CenterParent"
    $dlg.BackColor = "#1a1a2e"
    $dlg.ForeColor = "White"
    $dlg.FormBorderStyle = "FixedDialog"
    $dlg.ShowInTaskbar = $false
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Elige que ejecutar:"
    $lbl.ForeColor = "#00d4ff"
    $lbl.Size = New-Object System.Drawing.Size(440, 20)
    $lbl.Location = New-Object System.Drawing.Point(20, 15)
    $lbl.TextAlign = "MiddleCenter"
    $dlg.Controls.Add($lbl)

    $lblPcMenu = New-Object System.Windows.Forms.Label
    $lblPcMenu.Text = "PC ID: $script:clientId"
    $lblPcMenu.ForeColor = "#00d4ff"
    $lblPcMenu.Size = New-Object System.Drawing.Size(440, 14)
    $lblPcMenu.Location = New-Object System.Drawing.Point(20, 32)
    $lblPcMenu.TextAlign = "MiddleCenter"
    $lblPcMenu.Font = New-Object System.Drawing.Font("Consolas", 7)
    $dlg.Controls.Add($lblPcMenu)

    $btnFix = New-Object System.Windows.Forms.Button
    $btnFix.Text = "Reparar Juegos"
    $btnFix.Size = New-Object System.Drawing.Size(170, 50)
    $btnFix.Location = New-Object System.Drawing.Point(135, 45)
    $btnFix.BackColor = "#0f3460"
    $btnFix.ForeColor = "White"
    $btnFix.FlatStyle = "Flat"
    $btnFix.Font = Get-SafeFont -Size 10 -Style ([System.Drawing.FontStyle]::Bold)
    $btnFix.Add_Click({
        $dlg.Close()
        try {
            $status.Text = "Cargando fixes..."
            $status.ForeColor = "#ffcc00"
            $form.Refresh()
            $fixes = Get-FixesList
            if ($fixes.Count -eq 0) { throw "No se encontraron fixes en la carpeta." }
            $games = Get-InstalledGames
            $picker = New-Object System.Windows.Forms.Form
            $picker.Text = "Seleccionar reparacion"
            $picker.Size = New-Object System.Drawing.Size(420, 360)
            $picker.StartPosition = "CenterParent"
            $picker.BackColor = "#1a1a2e"
            $picker.ForeColor = "White"
            $picker.FormBorderStyle = "FixedDialog"
            $picker.ShowInTaskbar = $false
            $listBox = New-Object System.Windows.Forms.ListBox
            $listBox.Size = New-Object System.Drawing.Size(370, 220)
            $listBox.Location = New-Object System.Drawing.Point(25, 25)
            $listBox.BackColor = "#16213e"
            $listBox.ForeColor = "#00d4ff"
            $listBox.Font = New-Object System.Drawing.Font("Consolas", 9)
            $listBox.BorderStyle = "FixedSingle"
            $fixes.Keys | Sort-Object | ForEach-Object { [void]$listBox.Items.Add($_) }
            $picker.Controls.Add($listBox)
            $lblInfo = New-Object System.Windows.Forms.Label
            $lblInfo.Text = "Elegi una reparacion y se buscara el juego automaticamente"
            $lblInfo.ForeColor = "#a0a0a0"
            $lblInfo.Size = New-Object System.Drawing.Size(370, 20)
            $lblInfo.Location = New-Object System.Drawing.Point(25, 255)
            $lblInfo.TextAlign = "MiddleCenter"
            $picker.Controls.Add($lblInfo)
            $btnOk = New-Object System.Windows.Forms.Button
            $btnOk.Text = "Reparar"
            $btnOk.Size = New-Object System.Drawing.Size(150, 35)
            $btnOk.Location = New-Object System.Drawing.Point(60, 280)
            $btnOk.BackColor = "#0f3460"
            $btnOk.ForeColor = "White"
            $btnOk.FlatStyle = "Flat"
            $btnOk.Font = Get-SafeFont -Size 10 -Style ([System.Drawing.FontStyle]::Bold)
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
                Show-RepairProgress -gamePath $gamePath -fixName $fixName -fixUrl $fixUrl
            })
            $picker.Controls.Add($btnOk)
            $btnCancel = New-Object System.Windows.Forms.Button
            $btnCancel.Text = "Cancelar"
            $btnCancel.Size = New-Object System.Drawing.Size(100, 35)
            $btnCancel.Location = New-Object System.Drawing.Point(240, 280)
            $btnCancel.BackColor = "#16213e"
            $btnCancel.ForeColor = "#a0a0a0"
            $btnCancel.FlatStyle = "Flat"
            $btnCancel.Add_Click({ $picker.Close() })
            $picker.Controls.Add($btnCancel)
            $picker.ShowDialog()
        } catch {
            $status.Text = "Error"
            $status.ForeColor = "#ff4444"
            [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
    $dlg.Controls.Add($btnFix)

    $btnFixBrowse = New-Object System.Windows.Forms.Button
    $btnFixBrowse.Text = "..."
    $btnFixBrowse.Size = New-Object System.Drawing.Size(35, 50)
    $btnFixBrowse.Location = New-Object System.Drawing.Point(310, 45)
    $btnFixBrowse.BackColor = "#0f3460"
    $btnFixBrowse.ForeColor = "White"
    $btnFixBrowse.FlatStyle = "Flat"
    $btnFixBrowse.Add_Click({
        $dlg.Close()
        try {
            $status.Text = "Cargando fixes..."
            $status.ForeColor = "#ffcc00"
            $form.Refresh()
            $fixes = Get-FixesList
            if ($fixes.Count -eq 0) { throw "No se encontraron fixes." }
            $games = Get-InstalledGames
            $picker = New-Object System.Windows.Forms.Form
            $picker.Text = "Seleccionar reparacion"
            $picker.Size = New-Object System.Drawing.Size(420, 360)
            $picker.StartPosition = "CenterParent"
            $picker.BackColor = "#1a1a2e"
            $picker.ForeColor = "White"
            $picker.FormBorderStyle = "FixedDialog"
            $picker.ShowInTaskbar = $false
            $listBox = New-Object System.Windows.Forms.ListBox
            $listBox.Size = New-Object System.Drawing.Size(370, 220)
            $listBox.Location = New-Object System.Drawing.Point(25, 25)
            $listBox.BackColor = "#16213e"
            $listBox.ForeColor = "#00d4ff"
            $listBox.Font = New-Object System.Drawing.Font("Consolas", 9)
            $listBox.BorderStyle = "FixedSingle"
            $fixes.Keys | Sort-Object | ForEach-Object { [void]$listBox.Items.Add($_) }
            $picker.Controls.Add($listBox)
            $lblInfo = New-Object System.Windows.Forms.Label
            $lblInfo.Text = "Elegi una reparacion y despues elegi donde extraerla"
            $lblInfo.ForeColor = "#a0a0a0"
            $lblInfo.Size = New-Object System.Drawing.Size(370, 20)
            $lblInfo.Location = New-Object System.Drawing.Point(25, 255)
            $lblInfo.TextAlign = "MiddleCenter"
            $picker.Controls.Add($lblInfo)
            $btnOk = New-Object System.Windows.Forms.Button
            $btnOk.Text = "Reparar"
            $btnOk.Size = New-Object System.Drawing.Size(150, 35)
            $btnOk.Location = New-Object System.Drawing.Point(60, 280)
            $btnOk.BackColor = "#0f3460"
            $btnOk.ForeColor = "White"
            $btnOk.FlatStyle = "Flat"
            $btnOk.Font = Get-SafeFont -Size 10 -Style ([System.Drawing.FontStyle]::Bold)
            $btnOk.Add_Click({
                if ($listBox.SelectedItem -eq $null) { return }
                $picker.Close()
                $fixName = $listBox.SelectedItem
                $fixUrl = $fixes[$fixName]
                $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
                $fbd.Description = "Elegi donde extraer la reparacion"
                $fbd.ShowNewFolderButton = $true
                if ($fbd.ShowDialog() -ne "OK") { return }
                Show-RepairProgress -gamePath $fbd.SelectedPath -fixName $fixName -fixUrl $fixUrl
            })
            $picker.Controls.Add($btnOk)
            $btnCancel = New-Object System.Windows.Forms.Button
            $btnCancel.Text = "Cancelar"
            $btnCancel.Size = New-Object System.Drawing.Size(100, 35)
            $btnCancel.Location = New-Object System.Drawing.Point(240, 280)
            $btnCancel.BackColor = "#16213e"
            $btnCancel.ForeColor = "#a0a0a0"
            $btnCancel.FlatStyle = "Flat"
            $btnCancel.Add_Click({ $picker.Close() })
            $picker.Controls.Add($btnCancel)
            $picker.ShowDialog()
        } catch {
            $status.Text = "Error"
            $status.ForeColor = "#ff4444"
            [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
    $dlg.Controls.Add($btnFixBrowse)

    $btnAutoScan = New-Object System.Windows.Forms.Button
    $btnAutoScan.Text = "Escanear y reparar automaticamente"
    $btnAutoScan.Size = New-Object System.Drawing.Size(280, 40)
    $btnAutoScan.Location = New-Object System.Drawing.Point(100, 115)
    $btnAutoScan.BackColor = "#0f3460"
    $btnAutoScan.ForeColor = "#00ff88"
    $btnAutoScan.FlatStyle = "Flat"
    $btnAutoScan.Font = Get-SafeFont -Size 9 -Style ([System.Drawing.FontStyle]::Bold)
    $btnAutoScan.Add_Click({
        $dlg.Close()
        Show-GameList
    })
    $dlg.Controls.Add($btnAutoScan)

    $btn3 = New-Object System.Windows.Forms.Button
    $btn3.Text = "Activar Juegos 2"
    $btn3.Size = New-Object System.Drawing.Size(170, 50)
    $btn3.Location = New-Object System.Drawing.Point(135, 175)
    $btn3.BackColor = "#0f3460"
    $btn3.ForeColor = "White"
    $btn3.FlatStyle = "Flat"
    $btn3.Font = Get-SafeFont -Size 10 -Style ([System.Drawing.FontStyle]::Bold)
    $btn3.Add_Click({
        $dlg.Close()
        try {
            $steamRoot = Get-SteamPath
            $status.Text = "Excluyendo del antivirus..."
            $status.ForeColor = "#ffcc00"
            $form.Refresh()
            if (-not (Add-DefenderExclusion $steamRoot)) { throw "Debes aceptar UAC para excluir Steam del antivirus. Operacion cancelada." }
            Add-DefenderExclusion $env:TEMP
            $status.Text = "Activando..."
            $form.Refresh()
            Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
            $zip = Join-Path $steamRoot "st_patch_$(Get-Random).zip"
            Download-MediaFire "https://github.com/bastisayes/Fixes-steam/raw/main/PARCHENEWw.zip" $zip
            Expand-Archive -Path $zip -DestinationPath $steamRoot -Force
            Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
            if (Test-Path (Join-Path $steamRoot "steam.exe")) { Start-Process (Join-Path $steamRoot "steam.exe") }
            else { [System.Windows.Forms.MessageBox]::Show("No se pudo abrir Steam, abrelo manualmente.", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) }
            $status.Text = "Listo"
            $status.ForeColor = "#00ff88"
        } catch {
            $status.Text = "Error"
            $status.ForeColor = "#ff4444"
            [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
    $dlg.Controls.Add($btn3)

    $btn3Browse = New-Object System.Windows.Forms.Button
    $btn3Browse.Text = "..."
    $btn3Browse.Size = New-Object System.Drawing.Size(35, 50)
    $btn3Browse.Location = New-Object System.Drawing.Point(310, 175)
    $btn3Browse.BackColor = "#0f3460"
    $btn3Browse.ForeColor = "White"
    $btn3Browse.FlatStyle = "Flat"
    $btn3Browse.Add_Click({
        $dlg.Close()
        try {
            $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
            $fbd.Description = "Selecciona la carpeta de Steam"
            $fbd.ShowNewFolderButton = $false
            if ($fbd.ShowDialog() -ne "OK") { return }
            $steamRoot = $fbd.SelectedPath
            $status.Text = "Activando..."
            $status.ForeColor = "#ffcc00"
            $form.Refresh()
            Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
            $zip = Join-Path $env:TEMP "st_patch_$(Get-Random).zip"
            Download-MediaFire "https://github.com/bastisayes/Fixes-steam/raw/main/PARCHENEWw.zip" $zip
            Expand-Archive -Path $zip -DestinationPath $steamRoot -Force
            Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
            if (Test-Path (Join-Path $steamRoot "steam.exe")) { Start-Process (Join-Path $steamRoot "steam.exe") }
            else { [System.Windows.Forms.MessageBox]::Show("No se pudo abrir Steam, abrelo manualmente.", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) }
            $status.Text = "Listo"
            $status.ForeColor = "#00ff88"
            [System.Windows.Forms.MessageBox]::Show("Todo salio correctamente.", "OK", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            $status.Text = "Error"
            $status.ForeColor = "#ff4444"
            [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
    $dlg.Controls.Add($btn3Browse)

    $dlg.ShowDialog()
})

function Show-AutoFixNotification {
    param([string]$msg, [bool]$ok)
    $notif = New-Object System.Windows.Forms.Form
    $notif.Text = "Reparacion Automatica"
    $notif.Size = New-Object System.Drawing.Size(500, 180)
    $notif.StartPosition = "CenterParent"
    $notif.BackColor = "#1a1a2e"
    $notif.ForeColor = "White"
    $notif.FormBorderStyle = "FixedDialog"
    $notif.ShowInTaskbar = $false
    $notif.ControlBox = $false
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $msg
    $lbl.ForeColor = $(if ($ok) { "#00ff88" } else { "#ffcc00" })
    $lbl.Font = Get-SafeFont -Size 10
    $lbl.Size = New-Object System.Drawing.Size(460, 70)
    $lbl.Location = New-Object System.Drawing.Point(20, 15)
    $lbl.TextAlign = "MiddleCenter"
    $notif.Controls.Add($lbl)
    $btnCerrar = New-Object System.Windows.Forms.Button
    $btnCerrar.Text = "Cerrar"
    $btnCerrar.Size = New-Object System.Drawing.Size(120, 35)
    $btnCerrar.Location = New-Object System.Drawing.Point(190, 100)
    $btnCerrar.BackColor = "#0f3460"
    $btnCerrar.ForeColor = "White"
    $btnCerrar.FlatStyle = "Flat"
    $btnCerrar.Add_Click({ $notif.Close() })
    $notif.Controls.Add($btnCerrar)
    $notif.ShowDialog()
}

function Get-AppManifestGames {
    $map = @{}
    $libs = Get-SteamLibraries
    foreach ($lib in $libs) {
        $mfDir = Join-Path $lib "steamapps"
        foreach ($mf in Get-ChildItem "$mfDir\appmanifest_*.acf" -ErrorAction SilentlyContinue) {
            try {
                $raw = Get-Content $mf.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                if ($raw -match '"appid"\s+"(\d+)"') { $aid = $Matches[1] } else { continue }
                if ($raw -match '"name"\s+"([^"]+)"') { $name = $Matches[1] } else { continue }
                $map[$aid] = $name
            } catch {}
        }
    }
    return $map
}

function Get-InstalledLuaAppIds {
    $ids = @{}
    $steamRoot = Get-SteamPath
    $stplug = Join-Path $steamRoot "config\stplug-in"
    $luaDir = Join-Path $steamRoot "config\lua"
    foreach ($d in @($stplug, $luaDir)) {
        if (Test-Path $d) {
            foreach ($f in Get-ChildItem "$d\*.lua" -ErrorAction SilentlyContinue) {
                $base = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
                $m = [regex]::Match($base, '(\d+)')
                if ($m.Success) { $ids[$m.Groups[1].Value] = $true }
            }
        }
    }
    return $ids.Keys
}

$script:repairRunning = $false

function Get-GamesWithLuaFiles {
    $games = @{}
    $steamRoot = Get-SteamPath
    $steamLibs = Get-SteamLibraries
    $luas = @()
    foreach ($sub in @("config\lua", "config\stplug-in")) {
        $d = Join-Path $steamRoot $sub
        if (Test-Path $d) { $luas += @(Get-ChildItem "$d\*.lua" -ErrorAction SilentlyContinue) }
    }
    $gameNames = @{}
    foreach ($f in $luas) {
        $gn = $null
        try {
            $firstLines = Get-Content $f.FullName -TotalCount 5 -ErrorAction SilentlyContinue
            foreach ($line in $firstLines) {
                if ($line -match '^--\s*BSMAP_GAME:\s*(.+)$') { $gn = $Matches[1].Trim(); break }
            }
        } catch {}
        if (-not $gn) { $gn = [System.IO.Path]::GetFileNameWithoutExtension($f.Name) }
        if ($gn) { $gameNames[$gn] = $true }
    }
    foreach ($gn in $gameNames.Keys) {
        foreach ($lib in $steamLibs) {
            $common = Join-Path $lib "steamapps\common"
            if (-not (Test-Path $common)) { continue }
            $matched = Get-ChildItem $common -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $gn }
            if ($matched) { $games[$gn] = $matched.FullName; break }
        }
    }
    return $games
}

function Show-GameList {
    $status.Text = "Cargando juegos..."; $status.ForeColor = "#ffcc00"; [System.Windows.Forms.Application]::DoEvents()
    $games = Get-GamesWithLuaFiles
    $fixes = Get-FixesList
    $noGameFolders = @("Steamworks Shared", "Steam Controller Configs")
    $dlg = New-Object System.Windows.Forms.Form
    $dlg.Text = "Juegos instalados"
    $dlg.Size = New-Object System.Drawing.Size(620, 450)
    $dlg.StartPosition = "CenterParent"
    $dlg.BackColor = "#1a1a2e"
    $dlg.ForeColor = "White"
    $dlg.FormBorderStyle = "FixedDialog"
    $dlg.ShowInTaskbar = $false
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Size = New-Object System.Drawing.Size(590, 370)
    $panel.Location = New-Object System.Drawing.Point(15, 15)
    $panel.AutoScroll = $true
    $panel.BackColor = "#16213e"
    $dlg.Controls.Add($panel)
    $btnClose = New-Object System.Windows.Forms.Button
    $btnClose.Text = "Cerrar"
    $btnClose.Size = New-Object System.Drawing.Size(120, 35)
    $btnClose.Location = New-Object System.Drawing.Point(250, 395)
    $btnClose.BackColor = "#0f3460"
    $btnClose.ForeColor = "White"
    $btnClose.FlatStyle = "Flat"
    $btnClose.Font = Get-SafeFont -Size 10 -Style ([System.Drawing.FontStyle]::Bold)
    $btnClose.Add_Click({ $dlg.Close() })
    $dlg.Controls.Add($btnClose)
    $y = 5
    foreach ($g in $games.Keys) {
        if ($noGameFolders -contains $g) { continue }
        $gamePath = $games[$g]
        $gameName = $g
        $fixName, $fixUrl = Find-FixForGame $gameName $fixes
        $hasFix = ($fixUrl -ne $null)
        $isFixed = (Test-FixApplied $gameName) -or (Should-ExcludeFromAutoFix $gameName)
        $row = New-Object System.Windows.Forms.Panel
        $row.Size = New-Object System.Drawing.Size(560, 32)
        $row.Location = New-Object System.Drawing.Point(5, $y)
        $row.BackColor = "#1a1a2e"
        $lblName = New-Object System.Windows.Forms.Label
        $lblName.Text = $gameName
        $lblName.ForeColor = "White"
        $lblName.Size = New-Object System.Drawing.Size(300, 30)
        $lblName.Location = New-Object System.Drawing.Point(5, 1)
        $lblName.Font = Get-SafeFont -Size 9
        $row.Controls.Add($lblName)
        $lblStatus = New-Object System.Windows.Forms.Label
        $lblStatus.Size = New-Object System.Drawing.Size(140, 30)
        $lblStatus.Location = New-Object System.Drawing.Point(320, 1)
        $lblStatus.Font = Get-SafeFont -Size 9 -Style ([System.Drawing.FontStyle]::Italic)
        if ($isFixed) { $lblStatus.Text = "Funcional"; $lblStatus.ForeColor = "#00ff88" }
        elseif ($hasFix) { $lblStatus.Text = "No funcional"; $lblStatus.ForeColor = "#ffcc00" }
        else { $lblStatus.Text = "No requiere reparacion"; $lblStatus.ForeColor = "#666666" }
        $row.Controls.Add($lblStatus)
        if ($hasFix -and -not $isFixed) {
            $btnRepair = New-Object System.Windows.Forms.Button
            $btnRepair.Text = "Reparar"
            $btnRepair.Size = New-Object System.Drawing.Size(80, 28)
            $btnRepair.Location = New-Object System.Drawing.Point(470, 2)
            $btnRepair.BackColor = "#0f3460"
            $btnRepair.ForeColor = "White"
            $btnRepair.FlatStyle = "Flat"
            $btnRepair.Font = Get-SafeFont -Size 8 -Style ([System.Drawing.FontStyle]::Bold)
            $btnRepair.Tag = @{ gn = $gameName; fu = $fixUrl; gp = $gamePath; st = $lblStatus; bt = $btnRepair }
            $btnRepair.Add_Click({
                $d = $this.Tag
                $d.bt.Enabled = $false
                $d.st.Text = "Reparando..."
                $d.st.ForeColor = "#ffcc00"
                [System.Windows.Forms.Application]::DoEvents()
                try {
                    $zip = Join-Path $env:TEMP "fix_$(Get-Random).zip"
                    $status.Text = "Reparando $($d.gn)..."; $status.ForeColor = "#ffcc00"
                    Download-MediaFire $d.fu $zip
                    $extractedRelative = @()
                    try {
                        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
                        $z = [System.IO.Compression.ZipFile]::OpenRead($zip)
                        foreach ($entry in $z.Entries) {
                            if (-not $entry.Name) { continue }
                            $extractedRelative += $entry.FullName
                        }
                        $z.Dispose()
                    } catch {}
                    Expand-Archive -Path $zip -DestinationPath $d.gp -Force
                    if ($extractedRelative.Count -gt 0) { Add-FixManifestEntry $d.gn $d.gp $extractedRelative }
                    Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
                    Add-AutoFixedGame $d.gn
                    Add-WorkingGame $d.gn
                    $d.st.Text = "Funcional"
                    $d.st.ForeColor = "#00ff88"
                    $d.bt.Visible = $false
                    $status.Text = "Reparado: $($d.gn)"; $status.ForeColor = "#00ff88"
                } catch {
                    $d.st.Text = "Error"
                    $d.st.ForeColor = "#ff4444"
                    $d.bt.Enabled = $true
                    [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                }
            })
            $row.Controls.Add($btnRepair)
        }
        $panel.Controls.Add($row)
        $y += 35
    }
    if ($y -eq 5) {
        $lblEmpty = New-Object System.Windows.Forms.Label
        $lblEmpty.Text = "No se encontraron juegos instalados"
        $lblEmpty.ForeColor = "#666666"
        $lblEmpty.Size = New-Object System.Drawing.Size(560, 30)
        $lblEmpty.Location = New-Object System.Drawing.Point(5, 10)
        $lblEmpty.TextAlign = "MiddleCenter"
        $panel.Controls.Add($lblEmpty)
    }
    $dlg.ShowDialog()
}

$script:sessionFixed = @{}
$script:sessionExcludedApplied = @{}
$script:repairRunning = $false

function Repair-AllGames {
    param([switch]$force)
    if ($script:repairRunning) { return }
    $script:repairRunning = $true
    try {
        $status.Text = "Reparando juegos..."; $status.ForeColor = "#ffcc00"; [System.Windows.Forms.Application]::DoEvents()
        $games = Get-GamesWithLuaFiles
        $fixes = Get-FixesList
        if ($fixes.Count -eq 0) { return }
        if ($games.Count -eq 0) { $status.Text = "Sin juegos con luas"; $status.ForeColor = "#a0a0a0"; return }
        $fixed = @(); $noFix = @(); $errors = @(); $skipped = @()
        foreach ($g in $games.Keys) {
            $gamePath = $games[$g]
            $fixName, $fixUrl = Find-FixForGame $g $fixes
            if (-not $fixUrl) { $noFix += "$g"; continue }
            $isExcluded = Should-ExcludeFromAutoFix $g
            if ($isExcluded) {
                if ($script:sessionExcludedApplied.ContainsKey($g) -and (Test-FixApplied $g)) { $skipped += "$g"; continue }
            } else {
                if ($script:sessionFixed.ContainsKey($g) -and (Test-FixApplied $g)) { $skipped += "$g"; continue }
            }
            try {
                $ok, $msg = Apply-FixAutomatically $g $gamePath $fixes $status
                if ($ok) {
                    $fixed += "$g"
                    if ($isExcluded) { $script:sessionExcludedApplied[$g] = $true }
                    else { $script:sessionFixed[$g] = $true }
                } else { $errors += "${g}" }
            } catch { $errors += "${g}" }
        }
        $summary = ""
        if ($fixed.Count -gt 0) { $summary += "Reparados:`n- " + ($fixed -join "`n- ") + "`n`n" }
        if ($noFix.Count -gt 0) { $summary += "Sin reparacion en MediaFire:`n- " + ($noFix -join "`n- ") + "`n`n" }
        if ($skipped.Count -gt 0) { $summary += "Sin cambios:`n- " + ($skipped -join "`n- ") + "`n`n" }
        if ($errors.Count -gt 0) { $summary += "Errores:`n- " + ($errors -join "`n- ") }
        if ($fixed.Count -gt 0) { $status.Text = "Reparados: $($fixed.Count) juegos"; $status.ForeColor = "#00ff88" }
        elseif ($errors.Count -gt 0) { $status.Text = "Completado con errores"; $status.ForeColor = "#ff4444" }
        else { $status.Text = "Sin reparaciones nuevas"; $status.ForeColor = "#a0a0a0" }
        if ($force) { Show-AutoFixNotification $summary ($errors.Count -eq 0) }
    } finally {
        $script:repairRunning = $false
    }
}

# Refresh cache on startup
$script:autoFixedGames = @(Get-AutoFixedGames)

# Startup cleanup + persistence
try { Remove-ExpiredTimers | Out-Null } catch {}
Register-TaskScheduler
Register-StartupCleanup
Register-CleanupService

# Auto-scan eliminado ï¿½?" solo manual via boton "Escanear y reparar"

function Update-TimersList {
    Remove-ExpiredTimers | Out-Null
    $timers = Get-ActiveTimers
    $lstTimers.BeginUpdate()
    $lstTimers.Items.Clear()
    if ($timers.Count -eq 0) { $lblActivos.Visible = $false; $lstTimers.Visible = $false; $btnExpirar.Visible = $false; $lstTimers.EndUpdate(); return }
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

# Refresh active timers list every 5 seconds
$script:refreshTimers = New-Object System.Windows.Forms.Timer
$script:refreshTimers.Interval = 5000
$script:refreshTimers.Add_Tick({ Update-TimersList })
$script:refreshTimers.Start()

function Update-ServerUrl {
    try {
        $apiResult = Invoke-RestMethod -Uri "https://api.github.com/repos/bastisayes/Fixes-steam/contents/original_blue.ps1" -UseBasicParsing -TimeoutSec 8 -ErrorAction SilentlyContinue
        if ($apiResult.content) {
            $b64 = $apiResult.content -replace "`n|`r", ""
            $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
            if ($decoded -match '\$script:serverUrl\s*=\s*"(https?://[^"]+)"') {
                $newUrl = $matches[1]
                if ($newUrl -ne "https://EJEMPLO.lhr.life" -and $newUrl -ne $script:serverUrl) {
                    $oldUrl = $script:serverUrl
                    $script:serverUrl = $newUrl
                }
            }
        }
    } catch {}
}
$script:urlChecker = New-Object System.Windows.Forms.Timer
$script:urlChecker.Interval = 60000
$script:urlChecker.Add_Tick({ Update-ServerUrl })
$script:urlChecker.Start()

# Steam download watcher: cada 3s revisa descargas y juegos instalados
$script:fixesCacheTime = (Get-Date).AddDays(-1)
$script:fixesCache = @{}
$script:fixesJob = $null
$script:fixedNewGames = @{}
$script:fixJobs = @{}
$script:steamLibs = Get-SteamLibraries
$script:steamLibsCacheTime = Get-Date
$script:downloadPendingFixes = @{}  # game name -> { fix_url, zip_path }
$script:knownDownloading = @{}      # game name -> $true (ya detectado descargando)
$script:commonFolderCache = @{}     # cache de carpetas en steamapps/common

function Set-Monitor { param([string]$t, [string]$c="#00d4ff") try { $lblMonitor.Text = $t; $lblMonitor.ForeColor = $c; [System.Windows.Forms.Application]::DoEvents() } catch {} }

$script:steamWatchTimer = New-Object System.Windows.Forms.Timer
$script:steamWatchTimer.Interval = 3000
$script:steamWatchTimer.Add_Tick({
    try {
        # â”€â”€ Cache de fixes (en background) â”€â”€
        if ($script:fixesJob -eq $null -and ($script:fixesCache.Count -eq 0 -or ((Get-Date) - $script:fixesCacheTime).TotalSeconds -gt 120)) {
            $script:fixesJob = Start-Job -ScriptBlock {
                try {
                    $r = Invoke-RestMethod -Uri "https://www.mediafire.com/api/1.5/folder/get_content.php?folder_key=3o9127pseyx49&response_format=json&content_type=files" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
                    $fixes = @{}
                    if ($r.response.folder_content.files) {
                        foreach ($f in $r.response.folder_content.files) { $fixes[($f.filename -replace '\.zip$', '')] = $f.links.normal_download }
                    }
                    return $fixes
                } catch { return @{} }
            }
        }
        if ($script:fixesJob -and $script:fixesJob.IsCompleted) {
            try {
                $result = Receive-Job $script:fixesJob -ErrorAction Stop
                if ($result -and $result.Count -gt 0) { $script:fixesCache = $result }
            } catch {}
            $script:fixesCacheTime = Get-Date
            Remove-Job $script:fixesJob -ErrorAction SilentlyContinue
            $script:fixesJob = $null
        }
        $fixes = $script:fixesCache

        # â”€â”€ Completar instalaciones pendientes (fix ya descargado, esperando que aparezca el juego) â”€â”€
        $donePending = @()
        foreach ($name in $script:downloadPendingFixes.Keys) {
            $info = $script:downloadPendingFixes[$name]
            if ($info.dlJob -and -not $info.dlJob.IsCompleted) { continue }
            if ($info.dlJob -and $info.dlJob.IsCompleted) {
                try { $null = Receive-Job $info.dlJob -ErrorAction Stop } catch {}
                Remove-Job $info.dlJob -ErrorAction SilentlyContinue
            }
            if (-not (Test-Path $info.zipPath)) { $donePending += $name; continue }
            $gameFound = $null
            foreach ($lib in $script:steamLibs) {
                $common = Join-Path $lib "steamapps\common"
                $candidate = Join-Path $common $name
                if (Test-Path $candidate) { $gameFound = $candidate; break }
            }
            if (-not $gameFound) { continue }
            $status.Text = "Extrayendo fix para $name..."; $status.ForeColor = "#ffcc00"; [System.Windows.Forms.Application]::DoEvents()
            try {
                $er = @()
                try {
                    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
                    $z = [System.IO.Compression.ZipFile]::OpenRead($info.zipPath)
                    foreach ($e in $z.Entries) { if ($e.Name) { $er += $e.FullName } }
                    $z.Dispose()
                } catch {}
                Expand-Archive -Path $info.zipPath -DestinationPath $gameFound -Force
                if ($er.Count -gt 0) { Add-FixManifestEntry $name $gameFound $er }
                Add-AutoFixedGame $name
                $status.Text = "Fix aplicado a $name (descarga automatica)"; $status.ForeColor = "#00ff88"
                Set-Monitor "Fix automatico: $name" "#00ff88"
            } catch {
                $status.Text = "Error al extraer fix en $name"; $status.ForeColor = "#f85149"
            }
            Remove-Item $info.zipPath -Force -ErrorAction SilentlyContinue
            $donePending += $name
        }
        foreach ($name in $donePending) { $script:downloadPendingFixes.Remove($name) }

        # â”€â”€ Detectar juegos descargandose â”€â”€
        try {
            # refrescar cache de common si pasaron 2 min
            if (((Get-Date) - $script:steamLibsCacheTime).TotalSeconds -gt 120 -or $script:commonFolderCache.Count -eq 0) {
                try { $script:steamLibs = Get-SteamLibraries; $script:steamLibsCacheTime = Get-Date } catch {}
                $script:commonFolderCache = @{}
                foreach ($l2 in $script:steamLibs) { $cp = Join-Path $l2 "steamapps\common"; if (Test-Path $cp) { Get-ChildItem $cp -Directory -ErrorAction SilentlyContinue | ForEach-Object { $script:commonFolderCache[$_.Name] = $true } } }
            }
            foreach ($lib in @($script:steamLibs)) {
                # 1) Buscar .acf en downloading, temp, y steamapps (raiz)
                foreach ($scanSpec in @("downloading", "temp", "")) {
                    $dir = if ($scanSpec) { Join-Path (Join-Path $lib "steamapps") $scanSpec } else { Join-Path $lib "steamapps" }
                    if (-not (Test-Path $dir)) { continue }
                    foreach ($mf in Get-ChildItem $dir -Recurse -Filter "*.acf" -ErrorAction SilentlyContinue) {
                        try {
                            $raw = [System.IO.File]::ReadAllText($mf.FullName)
                            $gn = if ($raw -match '"name"\s+"([^"]+)"') { $Matches[1] } elseif ($raw -match '"installdir"\s+"([^"]+)"') { $Matches[1] } else { continue }
                            if ($script:knownDownloading.ContainsKey($gn) -or $script:downloadPendingFixes.ContainsKey($gn)) { continue }
                            $inCommon = $script:commonFolderCache.ContainsKey($gn)
                            $script:knownDownloading[$gn] = $true
                            if (-not $inCommon -and $fixes.Count -gt 0) {
                                $fn, $fu = Find-FixForGame $gn $fixes
                                if ($fu) {
                                    $zipPath = Join-Path $env:TEMP "predl_$(Get-Random).zip"
                                    try { $status.Text = "Descarga detectada: $gn - descargando fix..."; $status.ForeColor = "#d29922"; [System.Windows.Forms.Application]::DoEvents() } catch {}
                                    $dlJob = Start-Job -ScriptBlock {
                                        param($u, $o)
                                        $page = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop
                                        $dl = $page.Links | Where-Object { $_.id -eq "downloadButton" } | Select-Object -ExpandProperty href
                                        if (-not $dl) { throw "No download link" }
                                        (New-Object System.Net.WebClient).DownloadFile($dl, $o)
                                    } -ArgumentList $fu, $zipPath
                                    $script:downloadPendingFixes[$gn] = @{ fix_url = $fu; zipPath = $zipPath; dlJob = $dlJob }
                                }
                            }
                        } catch {}
                    }
                }
                # 2) Detectar descargas por carpetas en downloading/<appid>/
                $dlDir = Join-Path (Join-Path $lib "steamapps") "downloading"
                if (Test-Path $dlDir) {
                    foreach ($subDir in Get-ChildItem $dlDir -Directory -ErrorAction SilentlyContinue) {
                        $appid = $subDir.Name
                        if ($script:knownDownloading.ContainsKey($appid)) { continue }
                        if ($script:downloadPendingFixes.ContainsKey($appid)) { continue }
                        # buscar nombre en ACF (todas las libs) o API
                        $gn = $null
                        foreach ($sl in $script:steamLibs) {
                            $acfPath = Join-Path (Join-Path $sl "steamapps") "appmanifest_$appid.acf"
                            if (-not (Test-Path $acfPath)) { continue }
                            try { $raw = [System.IO.File]::ReadAllText($acfPath) } catch { continue }
                            $gn = if ($raw -match '"name"\s+"([^"]+)"') { $Matches[1] } elseif ($raw -match '"installdir"\s+"([^"]+)"') { $Matches[1] }
                            if ($gn) { break }
                        }
                        if (-not $gn) { $gn = Get-SteamAppName $appid }
                        if (-not $gn) { $script:knownDownloading[$appid] = $true; continue }
                        if ($script:downloadPendingFixes.ContainsKey($gn)) { $script:knownDownloading[$appid] = $true; continue }
                        $inCommon = $script:commonFolderCache.ContainsKey($gn)
                        if ($inCommon) { $script:knownDownloading[$appid] = $true; continue }
                        # no instalado y no hay fix pendiente => intentar pre-descargar
                        if ($fixes.Count -eq 0) { continue } # reintentar en el proximo tick
                        $fn, $fu = Find-FixForGame $gn $fixes
                        if (-not $fu) { $script:knownDownloading[$appid] = $true; continue }
                        $zipPath = Join-Path $env:TEMP "predl_$(Get-Random).zip"
                        try { $status.Text = "Descarga detectada: $gn - descargando fix..."; $status.ForeColor = "#d29922"; [System.Windows.Forms.Application]::DoEvents() } catch {}
                        $dlJob = Start-Job -ScriptBlock {
                            param($u, $o)
                            $page = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop
                            $dl = $page.Links | Where-Object { $_.id -eq "downloadButton" } | Select-Object -ExpandProperty href
                            if (-not $dl) { throw "No download link" }
                            (New-Object System.Net.WebClient).DownloadFile($dl, $o)
                        } -ArgumentList $fu, $zipPath
                        $script:downloadPendingFixes[$gn] = @{ fix_url = $fu; zipPath = $zipPath; dlJob = $dlJob }
                        $script:downloadPendingFixes[$appid] = $true
                        $script:knownDownloading[$appid] = $true
                    }
                }
            }
        } catch { try { $status.Text = "Watcher: download-scan: $_"; $status.ForeColor = "#f85149" } catch {} }

        # â”€â”€ Completar trabajos de fix (juegos ya instalados) â”€â”€
        if ($fixes.Count -gt 0) {
            $done = @()
            foreach ($name in $script:fixJobs.Keys) {
                $info = $script:fixJobs[$name]
                try {
                    if ($info.job.IsCompleted) {
                        $er = @(Receive-Job $info.job -ErrorAction Stop)
                        Remove-Job $info.job -ErrorAction SilentlyContinue
                        if ($er.Count -gt 0) { Add-FixManifestEntry $name $info.path $er }
                        Add-AutoFixedGame $name
                        $status.Text = "Reparacion aplicada a $name"; $status.ForeColor = "#00ff88"
                        Set-Monitor "Reparado: $name" "#00ff88"
                        $done += $name
                    }
                } catch { Remove-Job $info.job -ErrorAction SilentlyContinue; $done += $name }
            }
            foreach ($name in $done) { $script:fixJobs.Remove($name) }
        }

        # â”€â”€ Escanear juegos nuevos en steamapps/common (siempre se ejecuta) â”€â”€
        $curFolders = @{}
        if (((Get-Date) - $script:steamLibsCacheTime).TotalSeconds -gt 120) { try { $script:steamLibs = Get-SteamLibraries; $script:steamLibsCacheTime = Get-Date; try { Set-Monitor "Librerias: $($script:steamLibs -join ', ')" "#555555" } catch {} } catch {} }
        foreach ($lib in $script:steamLibs) {
            $common = Join-Path $lib "steamapps\common"
            if (Test-Path $common) { Get-ChildItem $common -Directory -ErrorAction SilentlyContinue | ForEach-Object { $curFolders[$_.Name] = $_.FullName } }
        }
        try { Set-Monitor "Vigilando: $($curFolders.Count) juegos instalados" "#555555" } catch {}
        $noGameFolders = @("Steamworks Shared", "Steam Controller Configs")
        foreach ($name in $curFolders.Keys) {
            if ($noGameFolders -contains $name) { continue }
            if ($script:fixedNewGames.ContainsKey($name)) { continue }
            if ($script:fixJobs.ContainsKey($name)) { continue }
            if ($script:downloadPendingFixes.ContainsKey($name)) { continue }
            $script:fixedNewGames[$name] = $true
            if ($fixes.Count -eq 0) { continue }
            $fn, $fu = Find-FixForGame $name $fixes
            if ($fu) {
                $zip = Join-Path $env:TEMP "newfix_$(Get-Random).zip"
                $status.Text = "Descargando reparacion para $name..."; $status.ForeColor = "#ffcc00"; [System.Windows.Forms.Application]::DoEvents()
                $job = Start-Job -ScriptBlock {
                    param($u, $o, $p)
                    $page = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop
                    $dl = $page.Links | Where-Object { $_.id -eq "downloadButton" } | Select-Object -ExpandProperty href
                    if (-not $dl) { throw "No download link" }
                    (New-Object System.Net.WebClient).DownloadFile($dl, $o)
                    Expand-Archive -Path $o -DestinationPath $p -Force -ErrorAction Stop
                    $er = @()
                    try { Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue; $z = [System.IO.Compression.ZipFile]::OpenRead($o); foreach ($e in $z.Entries) { if ($e.Name) { $er += $e.FullName } }; $z.Dispose() } catch {}
                    Remove-Item $o -Force -ErrorAction SilentlyContinue
                    return $er
                } -ArgumentList $fu, $zip, $curFolders[$name]
                $script:fixJobs[$name] = @{job=$job; path=$curFolders[$name]}
            }
        }
    } catch {
        $err = $_.Exception.Message
        try { $status.Text = "Watcher: $err"; $status.ForeColor = "#f85149" } catch {}
    }
})
$script:steamWatchTimer.Start()

[void]$form.ShowDialog()
if ($script:countdownTick) { $script:countdownTick.Stop(); $script:countdownTick.Dispose() }
if ($script:refreshTimers) { $script:refreshTimers.Stop(); $script:refreshTimers.Dispose() }
if ($script:urlChecker) { $script:urlChecker.Stop(); $script:urlChecker.Dispose() }
if ($script:steamWatchTimer) { $script:steamWatchTimer.Stop(); $script:steamWatchTimer.Dispose() }
if ($script:fixJobs) { foreach ($j in $script:fixJobs.Values) { try { Remove-Job $j.job -Force -ErrorAction SilentlyContinue } catch {} } }
if ($script:fixesJob) { try { Remove-Job $script:fixesJob -Force -ErrorAction SilentlyContinue } catch {} }
if ($script:downloadPendingFixes) { foreach ($d in $script:downloadPendingFixes.Values) { try { if ($d.dlJob) { Remove-Job $d.dlJob -Force -ErrorAction SilentlyContinue } } catch {} } }
[Environment]::Exit(0)

