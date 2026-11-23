# Adds the "AmongShield" server to Among Us on PC: Steam, Epic, itch.io and Microsoft Store / Xbox app.
# Close Among Us first, then right-click this file -> Run with PowerShell (Windows 11: Show more options first).
# It only edits Among Us's server list and saves a backup copy first. Nothing is downloaded or installed.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
function Finish($text, [bool]$ok) {
    Write-Host ''; Write-Host $text -ForegroundColor $(if ($ok) { 'Green' } else { 'Red' })
    $icon = if ($ok) { 'Information' } else { 'Error' }
    [void][System.Windows.Forms.MessageBox]::Show($text, 'AmongShield', 'OK', $icon)
    exit
}
$help = "`n`nStill stuck? Tell us what this message says at github.com/AmongShieldServer/AmongShield/issues"
try {
    if (Get-Process 'Among Us' -ErrorAction SilentlyContinue) { Finish "Among Us is still open.`n`nClose Among Us completely, then run this file again." $false }
    $shield = [pscustomobject]@{
        '$type'       = 'StaticHttpRegionInfo, Assembly-CSharp'
        Name          = 'AmongShield'
        PingServer    = 'amongshield.duckdns.org'
        Servers       = @([pscustomobject]@{ Name = 'http-1'; Ip = 'https://amongshield.duckdns.org'; Port = 443; UseDtls = $false; Players = 0; ConnectionFailures = 0 })
        TargetServer  = $null
        TranslateName = 1003
    }
    $files = @()
    # Steam, Epic, itch.io
    $normal = Join-Path $env:USERPROFILE 'AppData\LocalLow\Innersloth\Among Us\regionInfo.json'
    if (Test-Path $normal) { $files += $normal }
    # Microsoft Store / Xbox app: the server list is a save file with a random name in the game's package folder
    foreach ($pkg in Get-ChildItem (Join-Path $env:LOCALAPPDATA 'Packages') -Directory -Filter 'Innersloth.AmongUs*' -ErrorAction SilentlyContinue) {
        foreach ($f in Get-ChildItem (Join-Path $pkg.FullName 'SystemAppData\wgs') -Recurse -File -ErrorAction SilentlyContinue) {
            if ($f.Length -lt 200KB -and (Get-Content $f.FullName -Raw -Encoding UTF8) -match '^\W*\{\s*"CurrentRegionIdx"') { $files += $f.FullName }
        }
    }
    if ($files.Count -eq 0) { Finish "Among Us's server list wasn't found on this PC.`n`nStart Among Us once and wait for the main menu, close it, then run this file again.$help" $false }
    $backups = Join-Path $env:LOCALAPPDATA 'AmongShield-backup'
    New-Item -ItemType Directory -Force $backups | Out-Null
    $done = 0; $problems = @(); $n = 0
    foreach ($file in $files) {
        $n++
        try {
            Copy-Item $file (Join-Path $backups "regionInfo-$n.json") -Force
            try { $list = Get-Content $file -Raw -Encoding UTF8 | ConvertFrom-Json } catch { throw 'DAMAGED' }
            if ($null -eq $list.Regions) { throw 'DAMAGED' }
            $list.Regions = @($list.Regions | Where-Object { $_.Name -ne 'AmongShield' }) + $shield
            $list.CurrentRegionIdx = $list.Regions.Count - 1
            [IO.File]::WriteAllText($file, ($list | ConvertTo-Json -Depth 10 -Compress), (New-Object Text.UTF8Encoding $false))
            $done++
        } catch {
            $why = if ("$_" -eq 'DAMAGED') { "the server list file is damaged. Delete it, start Among Us once, close it and run this again: $file" }
                   elseif ($_.Exception -is [UnauthorizedAccessException] -or "$_" -match 'denied|being used') { "Windows didn't allow the change (file in use or protected). Close Among Us and the Xbox app, then try again." }
                   else { $_.Exception.Message }
            $problems += $why
        }
    }
    if ($done -gt 0 -and $problems.Count -eq 0) { Finish "Server successfully added!`n`nPlease start Among Us. AmongShield is already selected in the region menu (the globe button).`n`nTo play on normal servers again, pick North America, Europe or Asia there." $true }
    if ($done -gt 0) { Finish ("AmongShield was added, so you can start Among Us. But one copy of the game couldn't be updated:`n- " + ($problems -join "`n- ") + $help) $true }
    Finish ("AmongShield couldn't be added:`n- " + ($problems -join "`n- ") + $help) $false
} catch {
    Finish ("Something went wrong, so nothing was changed: " + $_.Exception.Message + $help) $false
}
