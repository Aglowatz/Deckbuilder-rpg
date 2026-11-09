# Fable Nov 9, Part 2.2: drives the EXPORTED TheWaywardPath.exe (not the editor, not a pack run) with real key presses, mouse clicks and
# screen captures, following a tiny script: one command per line - `wait <s>`, `key <SendKeys text>` (e.g. {ENTER}, {ESC}, e, w),
# `press ESC|ENTER|<char>` (a key with its real scan code: Escape and the arrows need it), `hold <char> <s>` (a held movement key),
# `click <x> <y>` (window coordinates of the capture), `shot <name>`, `log <text>`, `quit`.
# It never touches the player's files: to test a fresh install, move %APPDATA%\Deckbuilder-RPG aside by hand (mv) before and back after.
#   powershell -ExecutionPolicy Bypass -File tools/exe_drive.ps1 -Exe builds/_export/TheWaywardPath.exe -Script docs/review/play_scripts/exe_a.txt -Out _screenshots/exe/a
param(
	[string]$Exe = "builds\_export\TheWaywardPath.exe",
	[string]$Script = "",
	[string]$Out = "_screenshots\exe"
)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System; using System.Runtime.InteropServices;
public static class Win32 {
	[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
	[DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
	[DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
	[DllImport("user32.dll")] public static extern void mouse_event(uint f, uint dx, uint dy, uint d, UIntPtr e);
	[DllImport("user32.dll")] public static extern short VkKeyScan(char c);
	[DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, UIntPtr extra);
	[DllImport("user32.dll")] public static extern uint MapVirtualKey(uint code, uint type);
	[StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
}
"@
New-Item -ItemType Directory -Force $Out | Out-Null
$log = Join-Path $Out "exe_drive.log"
$t0 = Get-Date
function Log($t) { $line = ("{0,7:N1}  {1}" -f ((Get-Date) - $t0).TotalSeconds, $t); $line | Tee-Object -FilePath $log -Append }
$proc = Start-Process -FilePath (Resolve-Path $Exe) -PassThru
Log "started $Exe pid $($proc.Id)"
Start-Sleep -Seconds 3
function Win() { $proc.Refresh(); return $proc.MainWindowHandle }
function Focus() { $h = Win; if ($h -ne [IntPtr]::Zero) { [Win32]::SetForegroundWindow($h) | Out-Null } }
function Shot($name) {
	Focus; Start-Sleep -Milliseconds 400
	$r = New-Object Win32+RECT; $h = Win
	if ($h -eq [IntPtr]::Zero -or -not [Win32]::GetWindowRect($h, [ref]$r)) { Log "shot ${name}: no window"; return }
	$w = $r.Right - $r.Left; $hh = $r.Bottom - $r.Top
	if ($w -le 0 -or $hh -le 0) { Log "shot ${name}: empty window"; return }
	$bmp = New-Object System.Drawing.Bitmap $w, $hh
	$g = [System.Drawing.Graphics]::FromImage($bmp)
	$g.CopyFromScreen($r.Left, $r.Top, 0, 0, $bmp.Size)
	$path = Join-Path $Out "$name.png"
	$bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
	Log "shot $name ($w x $hh) -> $path"
}
function Key($text) { Focus; [System.Windows.Forms.SendKeys]::SendWait($text); Log "key $text" }
function Hold($ch, $secs) {
	Focus; $vk = [byte]([Win32]::VkKeyScan([char]$ch) -band 0xFF)
	$scan = [byte]([Win32]::MapVirtualKey([uint32]$vk, 0) -band 0xFF)
	[Win32]::keybd_event($vk, $scan, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds ([int]($secs * 1000)); [Win32]::keybd_event($vk, $scan, 2, [UIntPtr]::Zero)
	Log "hold $ch $secs"
}
## `press ESC|ENTER|SPACE|TAB|UP|DOWN|LEFT|RIGHT|F10|<char>`: a key down/up with its real scan code (SendKeys leaves it empty, and Godot's
## input map matches Escape and the arrows by physical key).
function Press($name) {
	Focus
	$vk = switch ($name.ToUpper()) { "ESC" { 0x1B } "ENTER" { 0x0D } "SPACE" { 0x20 } "TAB" { 0x09 } "UP" { 0x26 } "DOWN" { 0x28 } "LEFT" { 0x25 } "RIGHT" { 0x27 } "F10" { 0x79 } "F8" { 0x77 } default { [int]([Win32]::VkKeyScan([char]$name[0]) -band 0xFF) } }
	$scan = [byte]([Win32]::MapVirtualKey([uint32]$vk, 0) -band 0xFF)
	[Win32]::keybd_event([byte]$vk, $scan, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 70; [Win32]::keybd_event([byte]$vk, $scan, 2, [UIntPtr]::Zero)
	Log "press $name"
}
function Click($x, $y) {
	Focus; $r = New-Object Win32+RECT; [Win32]::GetWindowRect((Win), [ref]$r) | Out-Null
	# The first click after the window takes the focus is swallowed as the activation click, so the pointer is moved first (a real
	# motion event), the window gets a moment, then the button goes down and up.
	Start-Sleep -Milliseconds 250
	[Win32]::SetCursorPos($r.Left + $x - 2, $r.Top + $y) | Out-Null; Start-Sleep -Milliseconds 120
	[Win32]::mouse_event(1, 2, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 200
	[Win32]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 90; [Win32]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
	Log "click $x $y"
}
$lines = @()
if ($Script -ne "" -and (Test-Path $Script)) { $lines = Get-Content $Script }
foreach ($raw in $lines) {
	$line = $raw.Trim()
	if ($line -eq "" -or $line.StartsWith("#")) { continue }
	if ($proc.HasExited) { Log "the game exited (code $($proc.ExitCode)) before: $line"; break }
	$parts = $line -split "\s+", 2
	$cmd = $parts[0]; $arg = if ($parts.Length -gt 1) { $parts[1] } else { "" }
	switch ($cmd) {
		"wait" { Start-Sleep -Milliseconds ([int]([double]$arg * 1000)); Log "wait $arg" }
		"key" { Key $arg }
		"press" { Press $arg }
		"hold" { $a = $arg -split "\s+"; Hold $a[0] ([double]$a[1]) }
		"click" { $a = $arg -split "\s+"; Click ([int]$a[0]) ([int]$a[1]) }
		"shot" { Shot $arg }
		"log" { Log "note: $arg" }
		"quit" { if (-not $proc.HasExited) { $proc.CloseMainWindow() | Out-Null; Start-Sleep -Seconds 4 }; Log "quit asked (exited: $($proc.HasExited))" }
		default { Log "unknown command: $line" }
	}
}
if (-not $proc.HasExited) { Start-Sleep -Seconds 1; $proc.CloseMainWindow() | Out-Null; Start-Sleep -Seconds 6; if (-not $proc.HasExited) { Log "still running after close: stopping it"; Stop-Process -Id $proc.Id } else { Log "closed at the end" } }
$proc.Refresh()
Log "exit code: $($proc.ExitCode)"
