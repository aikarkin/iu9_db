use master;

IF DB_ID(N'Lab8') IS NOT NULL
  DROP DATABASE Lab8;

CREATE DATABASE Lab8;
GO


USE Lab8;
GO

IF OBJECT_ID(N'User') IS NOT NULL
  DROP TABLE [User]
GO

CREATE TABLE [User](
  UserId int PRIMARY KEY IDENTITY(1, 1),
  Email nvarchar(120) UNIQUE NOT NULL,
  UserName nvarchar(120) UNIQUE NOT NULL,
  RegistrationDate datetime DEFAULT CURRENT_TIMESTAMP,
  About text NULL
)
GO

INSERT INTO [User](Email, UserName)
    VALUES
  (N'user1@example.com', N'user1'),
  (N'user2@example.com', N'user2'),
  (N'user3@example.com', N'user3');
GO


IF OBJECT_ID(N'getEmailCursor') IS NOT NULL
  DROP PROC getEmailCursor;
GO  


CREATE PROCEDURE getEmailCursor
  @emailCursor CURSOR VARYING OUTPUT
AS
  SET @emailCursor = CURSOR
    FORWARD_ONLY FOR
      SELECT Email FROM [User];
  OPEN @emailCursor;
GO


DECLARE @cur CURSOR;
EXEC dbo.getEmailCursor @emailCursor = @cur OUTPUT;

DECLARE @mail nvarchar(120);
FETCH NEXT FROM @cur INTO @mail;

WHILE (@@FETCH_STATUS = 0)
BEGIN
  PRINT N'Email: ' + @mail;
  FETCH NEXT FROM @cur INTO @mail;
END;

CLOSE @cur;
DEALLOCATE @cur;
GO
