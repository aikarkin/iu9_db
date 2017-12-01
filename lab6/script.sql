USE master
GO

IF DB_ID('Lab6') IS NOT NULL
  DROP DATABASE Lab6;

CREATE DATABASE Lab6;
GO

USE Lab6;
GO

IF OBJECT_ID('Film') IS NOT NULL
  DROP TABLE Film;


CREATE TABLE Film(
  id int NOT NULL IDENTITY(2, 5),
  FilmName nvarchar(120) NOT NULL,
  ProductionCo nvarchar(120) NOT NULL,
  Country nvarchar(120) NULL,
);
GO

IF OBJECT_ID(N'InsertFilm') IS NOT NULL
  DROP PROC InsertFilm;
GO

/*
scope -  stored procedure, function, package
> ident_current: any session, any scope;
> scope_identity: same scope, same session;
> @@identity: same session, any scope;
*/

CREATE PROCEDURE InsertFilm
  @name nvarchar(120), 
  @productionCo nvarchar(120),
  @country nvarchar(120)
AS
  INSERT INTO Film(FilmName, ProductionCo, Country)
    VALUES (@name, @productionCo, @country);
  GO
  SELECT IDENT_CURRENT('Film') AS 'IDENT_CURRENT', 
    SCOPE_IDENTITY() AS 'SCOPE_IDENTITY',
    @@IDENTITY AS '@@IDENTITY';
  GO
GO  


INSERT INTO Film(FilmName, ProductionCo, Country) VALUES
  (N'The Shawshank Redemption', N'Castle Rock Entertainment', N'USA'),
  (N'The Godfather', N'Paramount Pictures', N'USA'),
  (N'Schindler''s List', N'Universal Pictures', N'USA');
GO


EXEC InsertFilm N'12 Angry Men', N'Orion-Nova Productions', N'USA'

-- error: by default IDENTITY_INSERT = OFF
-- INSERT INTO Film(id, FilmName, ProductionCo, Country) VALUES
--   (1, N'Pulp Fiction', N'Miramax', N'USA', N'English');
-- GO


SELECT id, FilmName, Country FROM Film;
GO


SELECT IDENT_CURRENT('Film') AS 'IDENT_CURRENT', 
  SCOPE_IDENTITY() AS 'SCOPE_IDENTITY',
  @@IDENTITY AS '@@IDENTITY';
GO


---------------


ALTER TABLE Film ADD
  Lang nvarchar(80) DEFAULT N'English',
  Rating real CHECK (Rating >= 0 AND Rating <= 10) NULL DEFAULT RAND() * 10;
GO


-- cause error
-- UPDATE Film SET Rating = 12.0;

UPDATE Film SET Lang=N'English';

INSERT INTO Film(FilmName, ProductionCo, Country) VALUES
  (N'The Lord of the Rings: The Return of the King', N' New Line Cinema', N'New Zeland');

INSERT INTO Film(FilmName, ProductionCo, Country, Lang) VALUES  
  (N'Il buono, il brutto, il cattivo', N' New Line Cinema', N'Italy', 'Italian');
GO

SELECT * FROM Film;
GO


---------------

IF OBJECT_ID(N'Review') IS NOT NULL
  DROP TABLE Review;
GO

CREATE TABLE Review(
  UNID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
  PostDate datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Rating real NULL,
  Comment text NULL,
  UserEmail nvarchar(120) DEFAULT N'User with this email deleted'
);
GO

INSERT INTO Review(Rating, Comment, UserEmail)
    VALUES
  (8.9, N'This is without a doubt my all-time favorite western.', N'user1@example.com'),
  (9.5, N'Westerns don''t get any better than this.', N'user1@example.com')
GO

SELECT * FROM Review
GO;


---------------


IF OBJECT_ID(N'UserIdSeq') IS NOT NULL
  DROP SEQUENCE UserIdSeq
GO


CREATE SEQUENCE UserIdSeq
  START WITH 10
  INCREMENT BY 1
GO


IF OBJECT_ID(N'User') IS NOT NULL
  DROP TABLE [User]
GO


CREATE TABLE [User](
  UserId int PRIMARY KEY NOT NULL DEFAULT(NEXT VALUE FOR UserIdSeq),
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

SELECT * FROM [User]
GO


------------------


IF OBJECT_ID(N'User') IS NOT NULL
  DROP TABLE [User]
GO


CREATE TABLE [User](
  Email nvarchar(120) PRIMARY KEY,
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


ALTER TABLE Review
  ADD CONSTRAINT UserFK
  FOREIGN KEY (UserEmail) REFERENCES [User](Email)
  ON UPDATE CASCADE
GO

UPDATE [User] 
  SET Email = 'user1@example.ru'
  WHERE Email='user1@example.com'
GO

SELECT * FROM [User]
SELECT * FROM [Review]
GO


ALTER TABLE Review
  DROP CONSTRAINT UserFK
GO

ALTER TABLE Review
  ADD CONSTRAINT UserFK
  FOREIGN KEY (UserEmail) REFERENCES [User](Email)
  ON UPDATE NO ACTION
GO


-- --ERROR: 
-- UPDATE [User] 
--   SET Email = 'user@example.ru'
--   WHERE Email='user1@example.ru'
-- GO

-- SELECT * FROM [User]
-- SELECT * FROM [Review]
-- GO


ALTER TABLE Review
  DROP CONSTRAINT UserFK
GO

ALTER TABLE Review
  ADD CONSTRAINT UserFK
  FOREIGN KEY (UserEmail) REFERENCES [User](Email)
  ON DELETE SET NULL
GO

DELETE FROM [User]
  WHERE Email='user1@example.ru';
GO

SELECT * FROM [User];
SELECT * FROM [Review];
GO