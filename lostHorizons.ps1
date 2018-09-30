# Lost Horizons
# Cristian Widenhouse
#

$welcomeBanner = [IO.File]::ReadAllText("$PSScriptRoot\banner.txt")
$mainPrompt = "Available Commands:`n-------------------`n1 - View Songs`n2 - View Team Members"
$dsPath = "$PSScriptRoot/data.SQLite"
$commands = 1, 2

# Make the database if it doesn't exist for some reason, this may go in a recovery script or not exist
# if (-not (Test-Path $dsPath)) {
#     Write-Host 'No database detected, creating one and adding members'
#     $createTablesQuery = [IO.File]::ReadAllText("$PSScriptRoot\createTables.sql")
#     Invoke-SQLiteQuery -DataSource $dsPath -Query $createTablesQuery
#     $insertMemberQuery = "INSERT INTO Members (name) VALUES (@name);"
#     foreach ($line in (Get-Content "$PSScriptRoot\members.txt")) {
#         Invoke-SQLiteQuery -DataSource $dsPath -Query $insertMemberQuery -SqlParameters @{name = $line}
#     }
# }

function HandleSqlModule {
    try { Import-Module PSSQLite -ErrorAction Stop }
    catch {
        Write-Host 'Something needs to be installed, just a second...'
        Install-Module PSSQLite -Force -Scope CurrentUser
        Write-Host "...SQLite module was installed!`n"
        Import-Module PSSQLite
    }
}

function ViewSongs {
    #TODO
    Write-Host "this is the view songs command"
}

function ViewMembers {
    #TODO
    Write-Host "this is the view members command"
}

function Main {
    Write-Host "`n`n$welcomeBanner`n`n`n" -ForegroundColor Cyan
    HandleSqlModule
    while ($true) {
        Write-Host $mainPrompt
        $cmd = Read-Host 'Select a command (press enter to exit)'
        if (-not $cmd) { exit }
        try {
            $cmd = [int]$cmd
            if (-not ($commands.Contains($cmd))) { throw }
        }
        catch { Write-Host "`nInvalid command, use the numbers on the left`n" }
        switch ($cmd) {
            1 { ViewSongs }
            2 { ViewMembers }
        }
    }
}

Main
