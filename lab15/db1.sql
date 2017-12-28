USE master;
GO
 
IF DB_ID (N'Lab15_1') IS NOT NULL
    DROP DATABASE Lab15_1;
GO
 
CREATE DATABASE Lab15_1
    ON ( NAME = Lab15_dat1, FILENAME = '/home/alex/dev/iu9/db/data/lab15_dat1.mdf',
            SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% ) 
    LOG ON ( NAME = Lab15_log1, FILENAME = '/home/alex/dev/iu9/db/data/lab15_log1.ldf',
            SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

Use Lab15_1;

IF OBJECT_ID(N'Review') IS NOT NULL
  DROP TABLE Review;
GO

CREATE TABLE Review(
  UNID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
  PostDate datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Rating real DEFAULT 0 CHECK (Rating >= 0 AND Rating <= 10),
  Comment text NULL,
  UserId int NOT NULL
);
GO

IF OBJECT_ID(N'UserView') IS NOT NULL
  DROP VIEW UserView;
GO

CREATE VIEW [UserView] 
AS
  SELECT * FROM Lab15_2.dbo.[User];
GO


IF OBJECT_ID(N'ReviewView') IS NOT NULL
  DROP VIEW ReviewView;
GO

CREATE VIEW [ReviewView] 
AS
  SELECT * FROM Lab15_1.dbo.Review;
GO


IF OBJECT_ID (N'UsrViewDel') IS NOT NULL
    DROP TRIGGER UsrViewDel;
GO

CREATE TRIGGER UsrViewDel ON UserView
INSTEAD OF DELETE
AS
  IF EXISTS(
    SELECT UserId FROM deleted 
    WHERE UserId IN (
      SELECT UserId FROM Lab15_1.dbo.Review
      )
    ) 
    RAISERROR(N'ERROR: Cannot delete user which has review', 11, 1);
  ELSE
    DELETE Lab15_2.dbo.[User] WHERE UserId IN (
      SELECT UserId FROM deleted
    );
     
    DECLARE @maxID int;

    SELECT @maxID = MAX(UserId)
    FROM Lab15_2.dbo.[User];

    IF @maxID IS NULL
      SET @maxID = 0;

    DBCC CHECKIDENT ('Lab15_2.dbo.[User]', RESEED, @maxID);
GO

IF OBJECT_ID (N'RvwViewIns') IS NOT NULL
    DROP TRIGGER RvwViewIns;
GO

CREATE TRIGGER RvwViewIns ON ReviewView
INSTEAD OF INSERT
AS
  IF EXISTS(SELECT * FROM inserted 
      WHERE UserId NOT IN (
        SELECT UserId FROM Lab15_2.dbo.[User]
      )
    )
    RAISERROR(N'Error: User with current id is not exists', 11, 2);
  ELSE
    INSERT INTO Lab15_1.dbo.Review
    SELECT * FROM inserted;
GO


IF OBJECT_ID (N'RvwViewUpd') IS NOT NULL
    DROP TRIGGER RvwViewUpd;
GO

CREATE TRIGGER RvwViewUpd ON ReviewView
INSTEAD OF UPDATE
AS
  IF UPDATE(UserId)
    RAISERROR(N'Error: Cannot update foreign key', 11, 3);
  ELSE
    DELETE Lab15_1.dbo.Review 
      WHERE UNID IN (SELECT UNID FROM deleted);

    INSERT INTO Lab15_1.dbo.Review
      SELECT * FROM inserted;
GO
