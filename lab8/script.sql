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
  (N'user3@example.com', N'user3'),
  (N'student1@bmstu.ru', N'student1'),
  (N'student2@bmstu.ru', N'student2'),
  (N'student3@bmstu.ru', N'student3'),
  (N'student4@bmstu.ru', N'student4');
GO


IF OBJECT_ID(N'GetEmailCursor') IS NOT NULL
  DROP PROC GetEmailCursor;
GO  


CREATE PROCEDURE GetEmailCursor
  @emailCursor CURSOR VARYING OUTPUT
AS
  SET @emailCursor = CURSOR
    FORWARD_ONLY FOR
      SELECT Email FROM [User];
  OPEN @emailCursor;
GO


DECLARE @cur CURSOR;
EXEC dbo.GetEmailCursor @emailCursor = @cur OUTPUT;

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

GO


------------ Point 2


IF OBJECT_ID(N'GetDate') IS NOT NULL
	DROP FUNCTION dbo.GetDate;
GO


CREATE FUNCTION GetDate (@DTime datetime)
  RETURNS date
AS
BEGIN
  RETURN CAST(@DTime AS DATE)
END;
GO


IF OBJECT_ID(N'GetUserRegDateCursor') IS NOT NULL
	DROP PROC dbo.GetUserRegDateCursor;
GO


CREATE PROCEDURE GetUserRegDateCursor
  @clCur CURSOR VARYING OUTPUT
AS
  SET @clCur = CURSOR
    FORWARD_ONLY FOR
      SELECT 
        UserName, 
        dbo.GetDate(RegistrationDate) AS RegistrationDate 
      FROM [User];
  OPEN @clCur;
GO


DECLARE @cur CURSOR;
EXEC dbo.GetUserRegDateCursor @clCur = @cur OUTPUT;

DECLARE 
  @usrName nvarchar(120),
  @usrReg date;
FETCH NEXT FROM @cur INTO @usrName, @usrReg;

WHILE (@@FETCH_STATUS = 0)
BEGIN
  PRINT @usrName + N' : ' + CONVERT(varchar, @usrReg);
  FETCH NEXT FROM @cur INTO @usrName, @usrReg;
END;

CLOSE @cur;
DEALLOCATE @cur;
GO


------------ Point 3


IF OBJECT_ID(N'IsBmstuUser') IS NOT NULL
  DROP FUNCTION IsBmstuUser;
GO


CREATE FUNCTION Func1
  (@userEmail AS nvarchar(120))
  RETURNS bit
AS
  RETURN 1;
GO

CREATE FUNCTION IsBmstuUser
  (@userEmail AS nvarchar(120))
  RETURNS bit
AS
BEGIN
  DECLARE @isBmstu bit;
  SET @isBmstu = 0;
  IF @userEmail LIKE N'%@bmstu.ru'
    SET @isBmstu = 1;

  RETURN @isBmstu;
END;
GO



IF OBJECT_ID(N'PrintBmstuEmails') IS NOT NULL
  DROP PROC PrintBmstuEmails;
GO 


CREATE PROCEDURE PrintBmstuEmails
AS
BEGIN
  DECLARE @cur CURSOR;
  EXEC dbo.GetEmailCursor @emailCursor = @cur OUTPUT;
  DECLARE @mail nvarchar(120);

  FETCH NEXT FROM @cur INTO @mail;

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    IF dbo.IsBmstuUser(@mail) = 1
      PRINT N'Email: ' + @mail;

    FETCH NEXT FROM @cur INTO @mail;
  END;

  CLOSE @cur;
  DEALLOCATE @cur;
END;
GO

EXEC PrintBmstuEmails;
GO

------------ Point 4


IF OBJECT_ID(N'GetUsersWithRegDate') IS NOT NULL
	DROP FUNCTION dbo.GetUsersWithRegDate;
GO


CREATE FUNCTION GetUsersWithRegDate()
RETURNS table
AS
  RETURN (
    SELECT 
      UserName, 
      CAST(RegistrationDate AS DATE) AS RegDate
    FROM [User]
  );
GO


CREATE FUNCTION GetUsersWithRegDate2()
RETURNS table
AS
  RETURN (
    SELECT 
      UserName, 
      CAST(RegistrationDate AS DATE) AS RegDate
    FROM [User]
  );
GO


IF OBJECT_ID(N'GetUserRegDateCursor') IS NOT NULL
	DROP PROC dbo.GetUserRegDateCursor;
GO


CREATE PROCEDURE GetUserRegDateCursor
  @clCur CURSOR VARYING OUTPUT
AS
  SET @clCur = CURSOR
    FORWARD_ONLY FOR
      SELECT 
        UserName, 
        RegDate 
      FROM dbo.GetUsersWithRegDate();
  OPEN @clCur;
GO


DECLARE @cur CURSOR;
EXEC dbo.GetUserRegDateCursor @clCur = @cur OUTPUT;

DECLARE 
  @usrName nvarchar(120),
  @usrReg date;
FETCH NEXT FROM @cur INTO @usrName, @usrReg;

WHILE (@@FETCH_STATUS = 0)
BEGIN
  PRINT @usrName + N' : ' + CONVERT(varchar, @usrReg);
  FETCH NEXT FROM @cur INTO @usrName, @usrReg;
END;

CLOSE @cur;
DEALLOCATE @cur;
GO