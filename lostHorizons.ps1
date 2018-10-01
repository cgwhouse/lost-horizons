# Lost Horizons
# Cristian Widenhouse
#

#region Globals

$welcomeBanner = [IO.File]::ReadAllText("$PSScriptRoot\banner.txt")
$mainPrompt = "`nMain Menu`n`nAvailable Commands:`n-------------------`n1 - View Songs`n2 - View Team Members`n"
$membersPrompt = "`n`nAvailable Commands:`n-------------------`n1 - Add a Member`n2 - Remove a Member`n"
$submissionsPrompt = "`n`nAvailable Commands:`n-------------------`n1 - Play a Song`n2 - Add a Song`n"
$removeMemberQuery = "DELETE FROM Members WHERE name = @name;DELETE FROM Submissions WHERE submitter_ID = (SELECT member_ID FROM Members WHERE name = @name);"
$viewSubmissionsQuery = "SELECT submission_ID AS 'Submission #', Submissions.name AS 'Submission Name', url AS 'URL', members.name AS 'Submitted By' FROM Submissions INNER JOIN Members ON Submissions.submitter_ID = Members.member_ID;"
$dsPath = "$PSScriptRoot/data.SQLite"
$commands = 1, 2

#endregion Globals

#region Commands

function PlaySubmission {
    $submissionNumber = Read-Host 'Pick the song to play by entering a submission #'
    try {
        $submissionNumber = [int]$submissionNumber
        $query = "SELECT url FROM Submissions WHERE submission_ID = @n;"
        $url = Invoke-SqliteQuery -DataSource $dsPath -Query $query -SqlParameters @{ n = $submissionNumber } | Out-DataTable
        $url = $url.Rows[0].url
        if (-not ($url)) { throw }
        else {
            Write-Host "Launching Chrome...`n"
            Start-Process -FilePath 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' -ArgumentList $url
        }
    }
    catch { Write-Host "`nNo Submissions with that Submission # are in the table" }
}

function AddSubmission {
    #TODO
    Write-Host "adding a song"
}

function ViewSubmissions {
    while ($true) {
        $submissionList = Invoke-SqliteQuery -DataSource $dsPath -Query $viewSubmissionsQuery | Out-String
        $submissionList.TrimEnd()
        Write-Host $submissionsPrompt
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
            1 { PlaySubmission }
            2 { AddSubmission }
        }
    }
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

#endregion Commands

function HandleSqlModule {
    try { Import-Module PSSQLite -ErrorAction Stop }
    catch {
        Write-Host 'Something needs to be installed, just a second...'
        Install-Module PSSQLite -Force -Scope CurrentUser
        Write-Host "...SQLite module was installed!`n"
        Import-Module PSSQLite
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
            1 {
                ViewSubmissions
            }
            2 { ViewMembers }
        }
    }
}

Main
