USE master
GO

IF DB_ID('Lab7') IS NOT NULL
  DROP DATABASE Lab7;

CREATE DATABASE Lab7;
GO

USE Lab7;
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

IF OBJECT_ID(N'UserView') IS NOT NULL
  DROP View [UserView]
GO

CREATE VIEW UserView 
WITH SCHEMABINDING
AS
  SELECT Email, UserName, RegistrationDate
    FROM dbo.[User]
GO


SELECT * FROM UserView;
GO


------------


IF OBJECT_ID(N'Review') IS NOT NULL
  DROP TABLE Review;
GO


CREATE TABLE Review(
  UNID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
  PostDate datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Rating real NULL,
  Comment text NULL,
  UserId int FOREIGN KEY REFERENCES [User](UserId)
);
GO


INSERT INTO Review (Rating, Comment, UserId)
    VALUES
  (8.9, N'This is without a doubt my all-time favorite western.', 1),
  (10.0, N'The best film that I''d ever seen!', 2),
  (9.5, N'Westerns don''t get any better than this.', 3);
GO


IF OBJECT_ID(N'UserReviewView') IS NOT NULL
  DROP View [UserReviewView]
GO


CREATE VIEW UserReviewView 
AS
  SELECT 
      u.Email AS Email, 
      u.UserName AS UserName, 
      r.Comment AS Comment, 
      r.Rating AS Rating
    FROM dbo.[User] u
    LEFT JOIN dbo.Review r ON r.UserId = u.UserId
    
GO


SELECT * FROM UserReviewView;


------------


IF OBJECT_ID(N'UserIdx') IS NOT NULL
  DROP INDEX UserIdx ON [User];
GO


CREATE INDEX UserIdx ON [User] (Email, UserName);
GO


------------


IF OBJECT_ID(N'UserViewClIdx') IS NOT NULL
  DROP INDEX UserViewClIdx ON [UserView];
GO



CREATE UNIQUE CLUSTERED INDEX UserViewClIdx   
    ON UserView(Email, UserName, RegistrationDate);
GO


SELECT * FROM UserView;
GO