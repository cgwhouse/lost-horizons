# Lost Horizons
# Cristian Widenhouse
#

$welcomeBanner = [IO.File]::ReadAllText("$PSScriptRoot\banner.txt")
$mainPrompt = "`nMain Menu`n`nAvailable Commands:`n-------------------`n1 - View Songs`n2 - View Team Members`n"
$membersPrompt = "`n`nAvailable Commands:`n-------------------`n1 - Add a Member`n2 - Remove a Member`n"
$removeMemberQuery = "DELETE FROM Members WHERE name = @name;DELETE FROM Submissions WHERE submitter_ID = (SELECT member_ID FROM Members WHERE name = @name);"
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

function RemoveMember {
    $name = Read-Host 'Enter name of member to remove, all submissions will be deleted (press enter to cancel)'
    if (-not ($name)) { return }
    Invoke-SqliteQuery -DataSource $dsPath -Query $removeMemberQuery -SqlParameters @{name = $name}
    return
}

function AddMember {
    $name = Read-Host 'Enter name of member to add (press enter to cancel)'
    if (-not ($name)) { return }
    Invoke-SqliteQuery -DataSource $dsPath -Query "INSERT INTO Members (name) VALUES (@name);" -SqlParameters @{name = $name}
    return
}

function ViewMembers {
    while ($true) {
        $memberList = Invoke-SqliteQuery -DataSource $dsPath -Query "SELECT name AS 'Member List' FROM Members;" | Out-String
        $memberList.TrimEnd()    
        Write-Host $membersPrompt
        $cmd = Read-Host 'Select a command (press enter to return to main menu)'
        if (-not $cmd) {
            Write-Host "`nReturning to main menu..."
            return 
        }
        try {
            $cmd = [int]$cmd
            if (-not ($commands.Contains($cmd))) { throw }
        }
        catch { Write-Host "`nInvalid command, use the numbers on the left" }
        switch ($cmd) {
            1 { AddMember }
            2 { RemoveMember }
        }
    }
}

function Main {
    Write-Host "`n`n$welcomeBanner`n`n" -ForegroundColor Cyan
    HandleSqlModule
    while ($true) {
        Write-Host $mainPrompt
        $cmd = Read-Host 'Select a command (press enter to exit program)'
        if (-not $cmd) { exit }
        try {
            $cmd = [int]$cmd
            if (-not ($commands.Contains($cmd))) { throw }
        }
        catch { Write-Host "`nInvalid command, use the numbers on the left" }
        switch ($cmd) {
            1 { ViewSongs }
            2 { ViewMembers }
        }
    }
}

Main
