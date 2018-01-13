USE master;
GO
 
IF DB_ID (N'Users1') IS NOT NULL
    DROP DATABASE Users1;
GO
 
CREATE DATABASE Users1
    ON ( NAME = Users_dat1, FILENAME = '/home/alex/dev/iu9/db/data/lab14_users_dad1.mdf',
            SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% ) 
    LOG ON ( NAME = Users_log1, FILENAME = '/home/alex/dev/iu9/db/data/lab14_users_log1.ldf',
            SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

IF DB_ID (N'Users2') IS NOT NULL
    DROP DATABASE Users2;
GO
 

CREATE DATABASE Users2
    ON ( NAME = Users_dat2, FILENAME = '/home/alex/dev/iu9/db/data/lab14_users_dad2.mdf',
            SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% ) 
    LOG ON ( NAME = Users_log1, FILENAME = '/home/alex/dev/iu9/db/data/lab14_users_log2.ldf',
            SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO 
 
USE Users1;
 
IF OBJECT_ID(N'User') IS NOT NULL
  DROP TABLE [User]
GO
 
CREATE TABLE [User](
  UserId int PRIMARY KEY,
  RegistrationDate datetime DEFAULT CURRENT_TIMESTAMP,
  Activity real DEFAULT 0 CHECK (Activity <= 10 AND Activity >=0),
  About text NULL
)
GO

INSERT INTO [User]
  (UserId, RegistrationDate, Activity, About)
    VALUES
  (1, DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 2.5, 'user'),
  (2, DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 8.7, 'user'),
  (3, DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 8.9, 'user'),
  (4, DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 2.14, 'user');
 



USE Users2;
 
IF OBJECT_ID(N'User') IS NOT NULL
  DROP TABLE [User]
GO
 
CREATE TABLE [User](
  UserId int PRIMARY KEY,
  Email nvarchar(120) UNIQUE NOT NULL,
  UserName nvarchar(120) UNIQUE NOT NULL
)
GO
 
INSERT INTO [User](UserId, Email, UserName)
    VALUES
  (1, 'student1@bmstu.ru', 'Student I'),
  (2, 'student2@bmstu.ru', 'Student II'),
  (3, 'student3@bmstu.ru', 'Student III'),
  (4, 'student4@bmstu.ru', 'Student IV');
GO


IF OBJECT_ID (N'UsrView') IS NOT NULL
    DROP VIEW UsrView;
GO


CREATE VIEW UsrView AS
    SELECT 
      u2.UserId AS UserId, 
      u2.UserName AS UserName,
      u2.Email AS Email,
      u1.RegistrationDate AS RegistrationDate,
      u1.Activity AS Activity,
      u1.About AS About
    FROM Users1.dbo.[User] u1
    JOIN Users2.dbo.[User] u2 ON u1.UserId = u2.UserId;
GO

SELECT * FROM UsrView;
GO


IF OBJECT_ID(N'UsrViewDel') IS NOT NULL
  DROP TRIGGER UsrViewDel;
GO

CREATE TRIGGER UsrViewDel ON dbo.UsrView
INSTEAD OF DELETE
AS
  DELETE FROM [Users1].[dbo].[User] 
    WHERE UserId IN (SELECT UserId FROM deleted);

  DELETE FROM [Users2].[dbo].[User] 
    WHERE UserId IN (SELECT UserId FROM deleted);
GO 


IF OBJECT_ID(N'UsrViewIns') IS NOT NULL
  DROP TRIGGER UsrViewIns;
GO

CREATE TRIGGER UsrViewIns ON dbo.UsrView
INSTEAD OF INSERT
AS
  INSERT INTO [Users1].[dbo].[User]
    SELECT UserId, RegistrationDate, Activity, About 
    FROM inserted;

  INSERT INTO [Users2].[dbo].[User]
    SELECT UserId, Email, UserNAme
    FROM inserted;
GO


IF OBJECT_ID(N'UsrViewUpd') IS NOT NULL
  DROP TRIGGER UsrViewUpd;
GO

CREATE TRIGGER UsrViewUpd ON dbo.UsrView
INSTEAD OF UPDATE
AS
  DELETE FROM [Users1].[dbo].[User] 
    WHERE UserId IN (SELECT UserId FROM deleted);
  DELETE FROM [Users2].[dbo].[User] 
    WHERE UserId IN (SELECT UserId FROM deleted);

  INSERT INTO [Users1].[dbo].[User]
    SELECT UserId, RegistrationDate, Activity, About 
    FROM inserted;
  INSERT INTO [Users2].[dbo].[User]
    SELECT UserId, Email, UserNAme
    FROM inserted;  
GO


INSERT INTO [UsrView] 
  (UserId, Email, UserName, RegistrationDate, Activity, About)
    VALUES
  (5, N'person5@example.com', N'person5', DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 5.0, 'person'),
  (6, N'person6@example.com', N'person6', DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 5.0, 'person'),
  (7, N'person7@example.com', N'person7', DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 5.0, 'person');


SELECT * FROM [UsrView];

UPDATE [UsrView]
SET Activity=Activity + 1;

SELECT * FROM [UsrView];

DELETE FROM [UsrView]
  WHERE Activity <= 6;

SELECT * FROM [UsrView];
Go