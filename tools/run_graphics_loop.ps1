<#
.SYNOPSIS
  One run of the overnight graphics loop: starts Claude Code non-interactively in this repo with tools/graphics_loop_prompt.md.

.DESCRIPTION
  Called hourly by the "Graphics Loop" scheduled task (docs/art/graphics_loop.md has the stop/disable commands).
  - Exits immediately when another run is active (lock file _logs/graphics_loop.lock holds the runner PID; a stale lock is cleared).
  - Logs to _logs/graphics_loop_<timestamp>.log (stdout, stream-json) and ..._err.log (stderr).
  - Always removes the lock when done, even on failure or Ctrl+C.
  - Usage-limit and network failures are logged and the script exits normally; the next hourly run tries again.
  Manual use:  powershell -NoProfile -ExecutionPolicy Bypass -File tools\run_graphics_loop.ps1 [-MaxMinutes 10]
#>
param(
	# Wall-clock cap for one run (a fresh run, with a fresh context, starts at the next trigger).
	[int]$MaxMinutes = 480
)

$ErrorActionPreference = 'Continue'
$Repo = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path $Repo '_logs'
$LockFile = Join-Path $LogDir 'graphics_loop.lock'
$PromptFile = Join-Path $Repo 'tools\graphics_loop_prompt.md'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Write-Log([string]$Message) {
	$line = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
	Add-Content -Path $script:RunLog -Value $line -Encoding utf8
	Write-Host $line
}

# ---- lock: refuse to run twice, clear stale locks ---------------------------------------------------
if (Test-Path $LockFile) {
	$lockedPid = 0
	$raw = (Get-Content $LockFile -ErrorAction SilentlyContinue | Select-Object -First 1)
	if ($raw -and [int]::TryParse($raw.Trim(), [ref]$lockedPid) -and $lockedPid -gt 0) {
		$alive = Get-Process -Id $lockedPid -ErrorAction SilentlyContinue
		if ($alive -and $alive.ProcessName -match 'powershell|pwsh') {
			Write-Host "Graphics loop already running (PID $lockedPid); exiting."
			exit 0
		}
	}
	Write-Host 'Clearing stale lock.'
	Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
}

$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$RunLog = Join-Path $LogDir "graphics_loop_$Stamp.log"
$ErrLog = Join-Path $LogDir "graphics_loop_${Stamp}_err.log"
Set-Content -Path $LockFile -Value $PID -Encoding ascii
$child = $null

try {
	Write-Log "Graphics loop run starting (runner PID $PID, repo $Repo, cap $MaxMinutes min)."
	if (-not (Test-Path $PromptFile)) { Write-Log "Prompt file missing: $PromptFile"; return }

	# One Godot at a time: clear leftovers from a previous run (this PC is low on memory).
	Get-Process -Name 'Godot*' -ErrorAction SilentlyContinue | ForEach-Object {
		Write-Log "Killing leftover Godot process $($_.Id)"
		Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
	}

	$claude = (Get-Command claude -ErrorAction SilentlyContinue).Source
	if (-not $claude) { $claude = Join-Path $env:USERPROFILE '.local\bin\claude.exe' }
	if (-not (Test-Path $claude)) { Write-Log "claude executable not found ($claude)"; return }

	# Non-interactive (print) mode, no permission prompts, streamed JSON lines so the log shows progress live.
	# The prompt file is piped to stdin so its length never hits the command-line limit.
	$arguments = @('-p', '--permission-mode', 'bypassPermissions', '--output-format', 'stream-json', '--verbose', '--add-dir', $Repo)
	Write-Log ("Starting: {0} {1}" -f $claude, ($arguments -join ' '))
	$child = Start-Process -FilePath $claude -ArgumentList $arguments -WorkingDirectory $Repo `
		-RedirectStandardInput $PromptFile -RedirectStandardOutput $RunLog.Replace('.log', '_stream.log') -RedirectStandardError $ErrLog `
		-NoNewWindow -PassThru
	Add-Content -Path $LockFile -Value $child.Id -Encoding ascii   # line 2: the child PID, for the stop command

	if (-not $child.WaitForExit($MaxMinutes * 60 * 1000)) {
		Write-Log "Reached the $MaxMinutes minute cap; stopping this run (the next trigger starts a fresh one)."
		& taskkill.exe /PID $child.Id /T /F | Out-Null
	} else {
		Write-Log "Claude exited with code $($child.ExitCode)."
	}

	# Classify the ending for the log: usage limit / network trouble are normal and handled by simply exiting.
	$tail = @()
	$stream = $RunLog.Replace('.log', '_stream.log')
	if (Test-Path $stream) { $tail += Get-Content $stream -Tail 40 -ErrorAction SilentlyContinue }
	if (Test-Path $ErrLog) { $tail += Get-Content $ErrLog -Tail 40 -ErrorAction SilentlyContinue }
	$text = ($tail -join "`n")
	if ($text -match '(?i)usage limit|limit reached|rate.?limit|credit balance|quota|resets? at|429') {
		Write-Log 'Usage limit reached; exiting. The next scheduled run will resume the loop.'
	} elseif ($text -match '(?i)ECONNRESET|ENOTFOUND|ETIMEDOUT|EAI_AGAIN|network|offline|could not resolve|socket hang up|fetch failed|overloaded|529|503') {
		Write-Log 'Network or service trouble; exiting. The next scheduled run will try again.'
	}
} catch {
	Write-Log "Runner error: $($_.Exception.Message)"
} finally {
	if ($child -and -not $child.HasExited) {
		& taskkill.exe /PID $child.Id /T /F 2>$null | Out-Null
	}
	Get-Process -Name 'Godot*' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
	Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
	Write-Log 'Lock removed; run finished.'
}
exit 0
