# Lost Horizons
# Cristian Widenhouse
#

$welcomeBanner = [IO.File]::ReadAllText("$PSScriptRoot\banner.txt")
Write-Host "`n`n$welcomeBanner`n`n`n"

try {
    Import-Module PSSQLite -ErrorAction Stop
}
catch [Exception] {
    Write-Host 'Something needs to be installed, just a second...'
    Install-Module PSSQLite -Force
    Write-Host '...SQLite module was installed!'
    Import-Module PSSQLite
}

$ds = "$PSScriptRoot/data.SQLite"
if (-not (Test-Path $ds)) {
    Write-Host 'no database detected, we will make one'
    $query = [IO.File]::ReadAllText("$PSScriptRoot\createTables.sql")
    Write-Host $query
    Invoke-SQLiteQuery -DataSource $ds -Query $query
}
else {
    Write-Host 'database detected'
}
