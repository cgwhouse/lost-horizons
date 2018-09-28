CREATE TABLE Submissions
(
    submission_ID INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    url TEXT NOT NULL,
    UNIQUE(name),
    UNIQUE(url),
    FOREIGN KEY (submitter_ID) REFERENCES Members(member_ID)
);

CREATE TABLE Members
(
    member_ID INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    UNIQUE(name)
);
