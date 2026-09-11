Add-Type -AssemblyName System.Windows.Forms
$logPath=Join-Path $env:TEMP "bsmap_luatools.log"
function Log-Luatools { param([string]$m) try { Add-Content -Path $logPath -Value $m -Encoding UTF8 -ErrorAction SilentlyContinue } catch {} }
try { Set-Content -Path $logPath -Value "[$(Get-Date -Format 'HH:mm:ss')] Reparar juegos listo. Ingresa un AppID." -Encoding UTF8 -ErrorAction SilentlyContinue } catch {}
# intercept Write-Host para loguear + mostrar
function global:Write-Host {
    param(
        [object]$Object,
        [switch]$NoNewline,
        [object]$Separator = ' ',
        [Parameter(ValueFromRemainingArguments=$true)][object[]]$Rest
    )
    $text = if ($null -ne $Object) { [string]$Object } else { "" }
    if ($Rest.Count -gt 0) {
        $extra = @($Rest | Where-Object { $_ -is [string] -or $_ -is [int] -or $_ -is [double] })
        if ($extra.Count -gt 0) { $text = (@($text) + ($extra | ForEach-Object { [string]$_ })) -join "$Separator" }
    }
    $clean = $text -replace "\x1B\]8;;[^\x1B]*\x1B\\", "" -replace "\x1B\[[0-9;]*[A-Za-z]", "" -replace "`r", ""
    if ($clean.Trim().Length -gt 0) { Log-Luatools $clean }
    # forward to original
    $p=@{}
    if ($PSBoundParameters.ContainsKey('Object')) { $p.Object=$Object }
    if ($NoNewline) { $p.NoNewline=$true }
    if ($PSBoundParameters.ContainsKey('Separator')) { $p.Separator=$Separator }
    # forward remaining named args (ForegroundColor etc) via Rest parsing
    for ($i=0; $i -lt $Rest.Count; $i++) {
        if ($Rest[$i] -is [string] -and $Rest[$i] -like "-*") {
            $k=$Rest[$i].TrimStart('-')
            if ($i+1 -lt $Rest.Count) { $p[$k]=$Rest[$i+1]; $i++ }
        }
    }
    try { Microsoft.PowerShell.Utility\Write-Host @p } catch { Microsoft.PowerShell.Utility\Write-Host $text }
}
function global:Read-Host { param($Prompt) return "2" }
function global:Clear-Host {}
$form=New-Object System.Windows.Forms.Form
$form.Text="Reparar juegos - Manifests"
$form.Size=New-Object System.Drawing.Size(420,180)
$form.StartPosition="CenterScreen"
$form.BackColor=[System.Drawing.Color]::FromArgb(12,18,32)
$lbl=New-Object System.Windows.Forms.Label
$lbl.Text="AppID del juego:"
$lbl.ForeColor=[System.Drawing.Color]::White
$lbl.Location=New-Object System.Drawing.Point(16,20)
$lbl.AutoSize=$true
$form.Controls.Add($lbl)
$txt=New-Object System.Windows.Forms.TextBox
$txt.Location=New-Object System.Drawing.Point(16,45)
$txt.Size=New-Object System.Drawing.Size(360,24)
$txt.BackColor=[System.Drawing.Color]::FromArgb(20,26,40)
$txt.ForeColor=[System.Drawing.Color]::White
$form.Controls.Add($txt)
$btn=New-Object System.Windows.Forms.Button
$btn.Text="Reparar"
$btn.Location=New-Object System.Drawing.Point(16,85)
$btn.Size=New-Object System.Drawing.Size(360,32)
$btn.BackColor=[System.Drawing.Color]::FromArgb(0,85,255)
$btn.ForeColor=[System.Drawing.Color]::White
$btn.FlatStyle="Flat"
$btn.Add_Click({
  $appid=$txt.Text.Trim()
  if(-not $appid -or $appid -notmatch '^\d+$'){ [System.Windows.Forms.MessageBox]::Show("Pone un AppID numerico","Error","OK","Warning"); return }
  try { Set-Content -Path $logPath -Value "[$(Get-Date -Format 'HH:mm:ss')] Reparar juegos - AppID $appid (github)" -Encoding UTF8 -ErrorAction SilentlyContinue } catch {}
  Log-Luatools "Buscando manifests para AppID $appid (modo github)..."
  $env:APP_ID=$appid
  $env:MANIFEST_MODE="github"
  try {
    $scriptText = Invoke-RestMethod -Uri "https://luatools.vercel.app/manifests.ps1" -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
    # parchear Exit-WithPrompt para no bloquear con ReadKey
    $scriptText = $scriptText -replace '\$null = \$Host\.UI\.RawUI\.ReadKey\([^)]*\)',''
    Invoke-Expression $scriptText
    Log-Luatools "Reparacion finalizada para AppID $appid"
    [System.Windows.Forms.MessageBox]::Show("Reparacion finalizada para AppID $appid. Revisa Steam y prueba descargar.","Listo","OK","Information") | Out-Null
  } catch {
    Log-Luatools "ERROR: $($_.Exception.Message)"
    [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)","Error","OK","Error") | Out-Null
  }
})
$form.Controls.Add($btn)
$form.ShowDialog() | Out-Null
