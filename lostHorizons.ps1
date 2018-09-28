# Lost Horizons
# Cristian Widenhouse
#

$welcomeBanner = [IO.File]::ReadAllText("./banner.txt")
Write-Host "`n`n$welcomeBanner`n`n`n"

try {
  Import-Module PSSQLite -ErrorAction Stop
  }
  catch {
    Write-Host 'Something needs to be installed, just a second'
    Install-Module PSSQLite -Force
    Write-Host '...SQLite module was installed!'
    Import-Module PSSQLite
  }

Write-Host 'Everything is fine'
