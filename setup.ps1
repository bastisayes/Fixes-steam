# SETUP - Instalador de BastissSteam Activator
# Usage: ejecutar este script o compilarlo a setup.exe con: Invoke-ps2exe -inputFile setup.ps1 -outputFile setup.exe -noConsole:$true
# El setup descarga el activator.exe y lo coloca en el escritorio

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:appDir = Join-Path $env:LOCALAPPDATA "BastissSteam"
$script:activatorExe = Join-Path $script:appDir "activator.exe"
$script:watcherScript = Join-Path $script:appDir "download_watcher.ps1"
$script:desktopShortcut = Join-Path ([Environment]::GetFolderPath('Desktop')) "BastissSteam.lnk"
$script:startMenuShortcut = Join-Path ([Environment]::GetFolderPath('StartMenu')) "Programs\BastissSteam.lnk"

$script:BG=[System.Drawing.Color]::FromArgb(11,15,25)
$script:Cyan=[System.Drawing.Color]::FromArgb(0,180,230)
$script:White=[System.Drawing.Color]::White
$script:Gray=[System.Drawing.Color]::FromArgb(130,142,162)
$script:CardBG=[System.Drawing.Color]::FromArgb(18,24,38)
$script:CardBorder=[System.Drawing.Color]::FromArgb(32,48,68)
$script:GreenBtn=[System.Drawing.Color]::FromArgb(45,200,100)
$script:GreenBtnH=[System.Drawing.Color]::FromArgb(35,175,85)

$form=New-Object System.Windows.Forms.Form
$form.Text="Setup BastissSteam Activator"
$form.ClientSize=New-Object System.Drawing.Size(520,360)
$form.StartPosition="CenterScreen"
$form.BackColor=$script:BG
$form.FormBorderStyle="FixedDialog"
$form.MaximizeBox=$false
$form.MinimizeBox=$false

$hp=New-Object System.Windows.Forms.Panel
$hp.Location=New-Object System.Drawing.Point(0,0)
$hp.Size=New-Object System.Drawing.Size(520,120)
$hp.BackColor=$script:BG
$hp.Add_Paint({
    param($s,$e)
    $g=$e.Graphics
    $g.SmoothingMode='AntiAlias'
    $g.TextRenderingHint='ClearTypeGridFit'
    $f1=New-Object System.Drawing.Font("Bahnschrift SemiBold",22,[System.Drawing.FontStyle]::Bold)
    $f2=New-Object System.Drawing.Font("Bahnschrift Light",9)
    $cyBr=New-Object System.Drawing.SolidBrush($script:Cyan)
    $whBr=New-Object System.Drawing.SolidBrush($script:White)
    $g.DrawString("Bastiss", $f1, $cyBr, 100, 32)
    $bastissSz = $g.MeasureString("Bastiss", $f1)
    $g.DrawString("Steam", $f1, $whBr, (100 + $bastissSz.Width - 12), 32)
    $cyBr.Dispose()
    $whBr.Dispose()
    $gyBr=New-Object System.Drawing.SolidBrush($script:Gray)
    $tagSz = $g.MeasureString("setup v1.0", $f2)
    $g.DrawString("setup v1.0", $f2, $gyBr, (100 + ($bastissSz.Width - 12)/2 - $tagSz.Width/2 + 30), 64)
    $gyBr.Dispose()
    $f1.Dispose()
    $f2.Dispose()
})
$form.Controls.Add($hp)

$statusLabel=New-Object System.Windows.Forms.Label
$statusLabel.Location=New-Object System.Drawing.Point(40,140)
$statusLabel.Size=New-Object System.Drawing.Size(440,28)
$statusLabel.Font=New-Object System.Drawing.Font("Segoe UI",9)
$statusLabel.ForeColor=$script:Cyan
$statusLabel.BackColor=$script:BG
$statusLabel.Text="Listo para instalar"
$form.Controls.Add($statusLabel)

$progressBar=New-Object System.Windows.Forms.ProgressBar
$progressBar.Location=New-Object System.Drawing.Point(40,180)
$progressBar.Size=New-Object System.Drawing.Size(440,18)
$progressBar.Style="Continuous"
$progressBar.Minimum=0
$progressBar.Maximum=100
$progressBar.Value=0
$form.Controls.Add($progressBar)

$logBox=New-Object System.Windows.Forms.TextBox
$logBox.Location=New-Object System.Drawing.Point(40,208)
$logBox.Size=New-Object System.Drawing.Size(440,80)
$logBox.Multiline=$true
$logBox.ReadOnly=$true
$logBox.ScrollBars="Vertical"
$logBox.BackColor=[System.Drawing.Color]::FromArgb(14,18,30)
$logBox.ForeColor=$script:White
$logBox.Font=New-Object System.Drawing.Font("Consolas",8)
$logBox.BorderStyle="FixedSingle"
$form.Controls.Add($logBox)

function Write-Log {
    param([string]$msg)
    $logBox.AppendText($msg + "`r`n")
    [System.Windows.Forms.Application]::DoEvents()
}

$btnPanel=New-Object System.Windows.Forms.Panel
$btnPanel.Location=New-Object System.Drawing.Point(0,300)
$btnPanel.Size=New-Object System.Drawing.Size(520,60)
$btnPanel.BackColor=$script:BG
$form.Controls.Add($btnPanel)

$installBtn=New-Object System.Windows.Forms.Button
$installBtn.Location=New-Object System.Drawing.Point(100,8)
$installBtn.Size=New-Object System.Drawing.Size(150,40)
$installBtn.Font=New-Object System.Drawing.Font("Bahnschrift SemiBold",10)
$installBtn.Text="Instalar"
$installBtn.FlatStyle="Flat"
$installBtn.ForeColor=[System.Drawing.Color]::Black
$installBtn.BackColor=$script:GreenBtn
$installBtn.Cursor=[System.Windows.Forms.Cursors]::Hand
$installBtn.FlatAppearance.BorderColor=$script:White
$installBtn.Add_Click({
    $installBtn.Enabled=$false
    try {
        if (-not (Test-Path $script:appDir)) { New-Item -ItemType Directory -Path $script:appDir -Force | Out-Null }
        Write-Log "Directorio: $script:appDir"
        $installBtn.Update()

        # Descargar activator desde GitHub releases
        Write-Log "Descargando activator..."
        $progressBar.Value=10
        [System.Windows.Forms.Application]::DoEvents()
        $githubUrl="https://raw.githubusercontent.com/bastisayes/steamsito/main/BastissSteamActivator2_v10.ps1"
        $tmpActivator=Join-Path $env:TEMP "bsmap_activator_$(Get-Random).ps1"
        try {
            Invoke-RestMethod -Uri $githubUrl -OutFile $tmpActivator -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
            Write-Log "Activator descargado: $((Get-Item $tmpActivator).Length) bytes"
            $progressBar.Value=50
            [System.Windows.Forms.Application]::DoEvents()
        } catch {
            Write-Log "ERROR: No se pudo descargar activator: $($_.Exception.Message)"
            $installBtn.Enabled=$true
            return
        }

        # Copiar como script PowerShell al app dir
        Copy-Item -LiteralPath $tmpActivator -Destination (Join-Path $script:appDir "activator.ps1") -Force
        Write-Log "Activator colocado en: $script:appDir\activator.ps1"
        $progressBar.Value=80
        [System.Windows.Forms.Application]::DoEvents()

        # Crear atajo en el escritorio
        try {
            $shell=New-Object -ComObject WScript.Shell
            $shortcut=$shell.CreateShortcut($script:desktopShortcut)
            $shortcut.TargetPath="powershell.exe"
            $shortcut.Arguments="-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script:appDir\activator.ps1`""
            $shortcut.WorkingDirectory=$script:appDir
            $shortcut.IconLocation="shell32.dll,221"
            $shortcut.Description="BastissSteam Activator"
            $shortcut.Save()
            Write-Log "Atajo de escritorio creado"
        } catch { Write-Log "WARN: No se pudo crear atajo: $($_.Exception.Message)" }
        $progressBar.Value=90
        [System.Windows.Forms.Application]::DoEvents()

        # Crear atajo en menu inicio
        try {
            $startMenuPath=Split-Path $script:startMenuShortcut -Parent
            if (-not (Test-Path $startMenuPath)) { New-Item -ItemType Directory -Path $startMenuPath -Force | Out-Null }
            $shortcut2=$shell.CreateShortcut($script:startMenuShortcut)
            $shortcut2.TargetPath="powershell.exe"
            $shortcut2.Arguments="-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script:appDir\activator.ps1`""
            $shortcut2.WorkingDirectory=$script:appDir
            $shortcut2.IconLocation="shell32.dll,221"
            $shortcut2.Description="BastissSteam Activator"
            $shortcut2.Save()
            Write-Log "Atajo en Menu Inicio creado"
        } catch {}
        $progressBar.Value=100
        [System.Windows.Forms.Application]::DoEvents()

        try { Remove-Item $tmpActivator -Force -ErrorAction SilentlyContinue } catch {}

        $statusLabel.Text="Instalacion completa!"
        $statusLabel.ForeColor=$script:GreenBtn
        Write-Log "DONE - Instalacion completada"
        [System.Windows.Forms.MessageBox]::Show("Instalacion completa!`n`nSe ha creado un atajo en el escritorio.`n Carpetas: $script:appDir`nActivalo con doble click.","Setup OK","OK","Information") | Out-Null
        $form.Close()
    } catch {
        $statusLabel.Text="Error: $($_.Exception.Message)"
        $statusLabel.ForeColor=[System.Drawing.Color]::FromArgb(255,70,70)
        Write-Log "ERROR DETALLADO: $_"
        $installBtn.Enabled=$true
    }
})
$btnPanel.Controls.Add($installBtn)

$exitBtn=New-Object System.Windows.Forms.Button
$exitBtn.Location=New-Object System.Drawing.Point(270,8)
$exitBtn.Size=New-Object System.Drawing.Size(150,40)
$exitBtn.Font=New-Object System.Drawing.Font("Bahnschrift SemiBold",10)
$exitBtn.Text="Salir"
$exitBtn.FlatStyle="Flat"
$exitBtn.ForeColor=$script:White
$exitBtn.BackColor=$script:CardBG
$exitBtn.Cursor=[System.Windows.Forms.Cursors]::Hand
$exitBtn.FlatAppearance.BorderColor=$script:CardBorder
$exitBtn.Add_Click({ $form.Close() })
$btnPanel.Controls.Add($exitBtn)

$form.ShowDialog() | Out-Null
$form.Dispose()
