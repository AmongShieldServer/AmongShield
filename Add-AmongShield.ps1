# Adds the "AmongShield" server to Among Us (PC). Close Among Us first, then right-click -> Run with PowerShell.
# It only edits Among Us's region list (regionInfo.json); a backup is saved next to it.
$ErrorActionPreference = 'Stop'
$file = Join-Path $env:USERPROFILE 'AppData\LocalLow\Innersloth\Among Us\regionInfo.json'
if (-not (Test-Path $file)) { Write-Host 'Start Among Us once (to the main menu), close it, then run this again.'; Read-Host 'Press Enter'; exit 1 }
if (Get-Process 'Among Us' -ErrorAction SilentlyContinue) { Write-Host 'Close Among Us first, then run this again.'; Read-Host 'Press Enter'; exit 1 }

Copy-Item $file "$file.backup" -Force
$json = Get-Content $file -Raw | ConvertFrom-Json
$json.Regions = @($json.Regions | Where-Object { $_.Name -ne 'AmongShield' })
$region = [pscustomobject]@{
    '$type'        = 'StaticHttpRegionInfo, Assembly-CSharp'
    Name           = 'AmongShield'
    PingServer     = 'amongshield.duckdns.org'
    Servers        = @([pscustomobject]@{ Name = 'http-1'; Ip = 'https://amongshield.duckdns.org'; Port = 443; UseDtls = $false; Players = 0; ConnectionFailures = 0 })
    TargetServer   = $null
    TranslateName  = 1003
}
$json.Regions += $region
$json.CurrentRegionIdx = $json.Regions.Count - 1
($json | ConvertTo-Json -Depth 10 -Compress) | Set-Content $file -Encoding UTF8
Write-Host 'Done! Start Among Us; the region "AmongShield" is selected. To play on normal servers again, pick North America/Europe/Asia in the region menu.'
Read-Host 'Press Enter'
