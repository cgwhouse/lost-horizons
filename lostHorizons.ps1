# Lost Horizons
# Cristian Widenhouse
#

$welcomeBanner = [IO.File]::ReadAllText("./banner.txt")
Write-Host "`n`n$welcomeBanner`n`n`n"

try {
  Import-Module PSSQLite -ErrorAction Stop
  }
  catch {
    Write-Host 'Something needs to be installed, just a second...'
    Install-Module PSSQLite -Force
    Write-Host '...SQLite module was installed!'
    Import-Module PSSQLite
  }

$db = "$PSScriptRoot/data.SQLite"
if(-not (Test-Path $db)) {
  Write-Host 'no database detected, we will make one'
  $query = [IO.File]::ReadAllText("./createTables.sql")
  Write-Host $query
  Invoke-SQLiteQuery -DataSource $db -Query $query
} else {
  Write-Host 'database detected'
}
