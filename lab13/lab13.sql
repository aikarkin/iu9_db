USE master;
GO
 
IF DB_ID (N'Users1') IS NOT NULL
    DROP DATABASE Users1;
GO
 
CREATE DATABASE Users1
    ON ( NAME = Users_dat1, FILENAME = '/home/alex/dev/iu9/db/data/users_dad1.mdf',
            SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% ) 
    LOG ON ( NAME = Hotels_log1, FILENAME = '/home/alex/dev/iu9/db/data/users_log1.ldf',
            SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

IF DB_ID (N'Users2') IS NOT NULL
    DROP DATABASE Users2;
GO
 

CREATE DATABASE Users2
    ON ( NAME = Users_dat2, FILENAME = '/home/alex/dev/iu9/db/data/users_dad2.mdf',
            SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% ) 
    LOG ON ( NAME = Users_log1, FILENAME = '/home/alex/dev/iu9/db/data/users_log2.ldf',
            SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO 
 
USE Users1;

IF OBJECT_ID(N'User') IS NOT NULL
  DROP TABLE [User]
GO
 
CREATE TABLE [User](
  UserId int PRIMARY KEY CHECK (UserId < 6),
  Email nvarchar(120) UNIQUE NOT NULL,
  UserName nvarchar(120) UNIQUE NOT NULL,
  About text NULL
)
GO

INSERT INTO [User](UserId, Email, UserName)
    VALUES
  (1, N'person1@example.com', N'person1'),
  (2, N'person2@example.com', N'person2'),
  (3, N'person3@example.com', N'person3')
GO
 
USE Users2;
 
IF OBJECT_ID(N'User') IS NOT NULL
  DROP TABLE [User]
GO
 
CREATE TABLE [User](
  UserId int PRIMARY KEY CHECK (UserId >= 6),
  Email nvarchar(120) UNIQUE NOT NULL,
  UserName nvarchar(120) UNIQUE NOT NULL,
  About text NULL
)
GO

INSERT INTO [User](UserId, Email, UserName)
    VALUES
  (6, N'person4@example.com', N'person4'),
  (7, N'person5@example.com', N'person5'),
  (8, N'person6@example.com', N'person6');
GO 
  
 
 
IF OBJECT_ID (N'UserView') IS NOT NULL
    DROP VIEW UserView;
GO
 
CREATE VIEW UserView AS
    SELECT * FROM Users1.dbo.[User]
    UNION ALL
    SELECT * FROM Users2.dbo.[User];
GO

SELECT * FROM UserView;

INSERT INTO dbo.[UserView] (UserId, UserName, Email, About) 
  VALUES
(4, N'alex', N'alex@bmstu.ru', 'student'),
(5, N'john', N'john@bmstu.ru', 'student'),  
(9, N'person7', N'person7@example.com', N'person'),
(10, N'person8', N'person8@example.com', N'person');


SELECT * FROM UserView;