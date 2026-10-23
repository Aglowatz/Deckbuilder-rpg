# Runs a command in the foreground and samples its memory until it exits (docs/release/how_to_build.md).
# Every sample sums the working set and private bytes of all processes whose name starts with -Match (the Godot console wrapper
# starts the real Godot exe as a child, so both are counted), notes free RAM and the last line the command printed, so the peak can be
# tied to an export step. Writes the timeline to -Csv, the command's output to -Log, prints a summary and exits with the command's code.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File tools/measure_process.ps1 -Exe <exe> -ArgList "<args>" -Log out.log -Csv mem.csv
param(
	[Parameter(Mandatory = $true)][string]$Exe,
	[string]$ArgList = "",
	[Parameter(Mandatory = $true)][string]$Log,
	[string]$Csv = "",
	[string]$Match = "Godot",
	[int]$IntervalMs = 250,
	[string]$WorkDir = (Get-Location).Path
)
$ErrorActionPreference = "Stop"
$errLog = "$Log.err"
$avail = New-Object System.Diagnostics.PerformanceCounter("Memory", "Available MBytes")
$p = Start-Process -FilePath $Exe -ArgumentList $ArgList -WorkingDirectory $WorkDir -NoNewWindow -PassThru `
	-RedirectStandardOutput $Log -RedirectStandardError $errLog
$null = $p.Handle # keeps the handle so ExitCode is readable after exit
$start = Get-Date
$rows = New-Object System.Collections.Generic.List[string]
$rows.Add("seconds,working_set_mb,private_mb,free_mb,last_line")
$peakWs = 0; $peakPriv = 0; $minFree = [int]::MaxValue; $peakAt = 0; $peakLine = ""; $lastLine = ""
while (-not $p.HasExited) {
	$ws = 0; $priv = 0
	foreach ($q in (Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "$Match*" })) {
		try { $ws += $q.WorkingSet64; $priv += $q.PrivateMemorySize64 } catch {}
	}
	$free = [int]$avail.NextValue()
	try {
		$tail = Get-Content -LiteralPath $Log -Tail 1 -ErrorAction SilentlyContinue
		if ($tail) { $lastLine = ($tail -replace '[",\r\n]', ' ').Trim() }
	} catch {}
	$t = [math]::Round(((Get-Date) - $start).TotalSeconds, 1)
	$wsMb = [int]($ws / 1MB); $privMb = [int]($priv / 1MB)
	if ($wsMb -gt $peakWs) { $peakWs = $wsMb; $peakAt = $t; $peakLine = $lastLine }
	if ($privMb -gt $peakPriv) { $peakPriv = $privMb }
	if ($free -lt $minFree) { $minFree = $free }
	$cut = if ($lastLine.Length -gt 160) { $lastLine.Substring(0, 160) } else { $lastLine }
	$rows.Add("$t,$wsMb,$privMb,$free,`"$cut`"")
	Start-Sleep -Milliseconds $IntervalMs
}
$p.WaitForExit()
$code = $p.ExitCode
if ($null -eq $code) { $code = -1 }
if (Test-Path -LiteralPath $errLog) {
	Get-Content -LiteralPath $errLog | Add-Content -LiteralPath $Log
	Remove-Item -LiteralPath $errLog -Force
}
if ($Csv) { $rows | Set-Content -LiteralPath $Csv -Encoding utf8 }
$secs = [math]::Round(((Get-Date) - $start).TotalSeconds, 0)
Write-Output ("MEASURE: exit=$code seconds=$secs peak_working_set_mb=$peakWs peak_private_mb=$peakPriv min_free_mb=$minFree peak_at_s=$peakAt")
Write-Output ("MEASURE: at peak the last output line was: $peakLine")
exit $code
