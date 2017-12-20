USE master
GO

IF DB_ID(N'Lab10') IS NOT NULL
  DROP DATABASE Lab10;

CREATE DATABASE Lab10;
GO

USE Lab10;
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
  (N'anonymous@example.com', N'anonymous'),
  (N'person1@example.com', N'person1');
GO
