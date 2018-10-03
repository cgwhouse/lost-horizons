# Lost Horizons
# Cristian Widenhouse
#

#region Globals

$welcomeBanner = [IO.File]::ReadAllText("$PSScriptRoot\banner.txt")
$mainPrompt = "`nMain Menu`n`nAvailable Commands:`n-------------------`n1 - View Songs`n2 - View Team Members`n"
$membersPrompt = "`n`nAvailable Commands:`n-------------------`n1 - Add a Member`n2 - Remove a Member`n"
$submissionsPrompt = "`n`nAvailable Commands:`n-------------------`n1 - Play a Song`n2 - Add a Song`n"
$removeMemberQuery = "DELETE FROM Submissions WHERE submitter_ID = (SELECT member_ID FROM Members WHERE name = @name);DELETE FROM Members WHERE name = @name;"
$viewSubmissionsQuery = "SELECT submission_ID AS 'Submission #', Submissions.name AS 'Submission Name', url AS 'URL', members.name AS 'Submitted By' FROM Submissions INNER JOIN Members ON Submissions.submitter_ID = Members.member_ID;"
$submissionInsertQuery = "INSERT INTO Submissions (name, url, submitter_ID) VALUES (@name, @url, @submitter_ID);"
$retrieveUrlQuery = "SELECT url FROM Submissions WHERE submission_ID = @n;"
$retrieveMemberIDQuery = "SELECT member_ID FROM Members WHERE name = @name;"
$dsPath = "$PSScriptRoot/data.SQLite"
$commands = 1, 2

#endregion Globals

#region View Data

function ViewData {
    $query = $args[0]; $introPrompt = $args[1]; $firstAction = $args[2]; $secondAction = $args[3]
    while ($true) {
        $lst = Invoke-SqliteQuery -DataSource $dsPath -Query $query | Out-String
        $lst.TrimEnd()
        Write-Host $introPrompt
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
            1 {
                if ($firstAction -eq "PlaySubmission") {
                    PlaySubmission
                }
                else { AddMember } 
            }
            2 {
                if ($secondAction -eq "AddSubmission") {
                    AddSubmission
                }
                else { RemoveMember }
            }
        }
    }
}

function ViewSubmissions {
    ViewData $viewSubmissionsQuery $submissionsPrompt "PlaySubmission" "AddSubmission"
}

function ViewMembers {
    ViewData "SELECT name AS 'Member List' FROM Members;" $membersPrompt "AddMember" "RemoveMember"
}

#endregion View Data

#region Commands

function PlaySubmission {
    $submissionNumber = Read-Host 'Pick the song to play by entering a submission # (press enter to abort)'
    if (-not ($submissionNumber)) { return }
    try {
        $submissionNumber = [int]$submissionNumber
        $url = Invoke-SqliteQuery -DataSource $dsPath -Query $retrieveUrlQuery -SqlParameters @{ n = $submissionNumber } | Out-DataTable
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
    while ($true) {
        $submissionName = Read-Host 'Enter a name for the submission so you can recognize it in the list (Press enter to abort)'
        if (-not ($submissionName)) { return } else { break }
    }
    while ($true) {
        $submissionUrl = Read-Host 'Copy the url to your clipboard and paste it here (Press enter to abort)'
        if (-not ($submissionUrl)) { return } else { break }
    }
    while ($true) {
        $submitterName = Read-Host 'Which team member gave us this link? (Press enter to abort)'
        if (-not ($submitterName)) { return }
        $submitterID = Invoke-SqliteQuery -DataSource $dsPath -Query $retrieveMemberIDQuery -SqlParameters @{ name = $submitterName} | Out-DataTable
        $submitterID = $submitterID.Rows[0].member_ID
        if (-not ($submitterID)) { Write-Host "`nThat name was not found in the list of members." } else { break }
    }
    try {
        Invoke-SqliteQuery -ErrorAction Stop -DataSource $dsPath -Query $submissionInsertQuery -SqlParameters @{
            name         = $submissionName
            url          = $submissionUrl
            submitter_ID = $submitterID
        }
    }
    catch { Write-Host "`nThat didn't work...the name and url for the submission must each be unique" }
}

function AddOrRemoveMember {
    $prompt = $args[0]
    $query = $args[1]
    $name = Read-Host $prompt
    if (-not ($name)) { return }
    Invoke-SqliteQuery -DataSource $dsPath -Query $query -SqlParameters @{name = $name}
}

function RemoveMember {
    AddOrRemoveMember 'Enter name of member to remove, all submissions will be deleted (press enter to cancel)' $removeMemberQuery
}

function AddMember {
    AddOrRemoveMember 'Enter name of member to add (press enter to cancel)' "INSERT INTO Members (name) VALUES (@name);"
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
