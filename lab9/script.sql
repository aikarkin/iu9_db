USE master
GO

IF DB_ID('Lab9') IS NOT NULL
  DROP DATABASE Lab9;

CREATE DATABASE Lab9;
GO

USE Lab9;
GO


-- tables creation:
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

IF OBJECT_ID('Film') IS NOT NULL
  DROP TABLE Film;


CREATE TABLE Film(
  id int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
  FilmName nvarchar(120) UNIQUE NOT NULL,
  ProductionCo nvarchar(120) NOT NULL,
  Country nvarchar(120) NULL,
  Rating real NOT NULL DEFAULT 0,
);
GO


IF OBJECT_ID(N'Review') IS NOT NULL
  DROP TABLE Review;
GO


CREATE TABLE Review(
  UNID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
  PostDate datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Rating real DEFAULT 0 CHECK (Rating >= 0 AND Rating <= 10),
  Comment text NULL,
  UserId int FOREIGN KEY REFERENCES [User](UserId),
  FilmId int FOREIGN KEY REFERENCES [Film](id)
);
GO

-- functions' definitions:
IF OBJECT_ID(N'GetFilmIdByName') IS NOT NULL
	DROP FUNCTION dbo.GetFilmIdByName;
GO


CREATE FUNCTION dbo.GetFilmIdByName
  (@filmName AS nvarchar(120))
  RETURNS int
AS
BEGIN
  DECLARE @filmId int;
  SELECT @filmId=id FROM [Film] WHERE FilmName=@filmName;
  RETURN @filmId;
END;
GO

IF OBJECT_ID(N'GetUserIdByEmail') IS NOT NULL
	DROP FUNCTION dbo.GetUserIdByEmail;
GO


CREATE FUNCTION dbo.GetUserIdByEmail
  (@email AS nvarchar(120))
  RETURNS int
AS
BEGIN
  DECLARE @usrId int;
  SELECT @usrId=UserId FROM [User] WHERE Email=@email;
  RETURN @usrId;
END;
GO

IF OBJECT_ID(N'GetFilmRating') IS NOT NULL
	DROP FUNCTION dbo.GetFilmRating;
GO


CREATE FUNCTION dbo.GetFilmRating
  (@filmId AS int)
  RETURNS real
AS
BEGIN
  DECLARE @rating real;
  SET @rating = 0;
  IF EXISTS(SELECT * FROM [Review] WHERE FilmId = @filmId)
    SELECT @rating = AVG(Rating) FROM [Review]
      WHERE FilmId = @filmId;
  RETURN @rating;
END;
GO



-- Task 1. Create triggers for table --

CREATE TRIGGER ReviewInsertTrig
ON Review
AFTER INSERT
AS
  UPDATE dbo.[Film]
    SET Rating = dbo.GetFilmRating(id)
    WHERE id in
    (SELECT FilmId FROM inserted);
  GO
GO


CREATE TRIGGER ReviewUpdateTrig
ON Review
AFTER UPDATE
AS
BEGIN
  IF UPDATE(Rating)
    UPDATE dbo.[Film]
      SET Rating = dbo.GetFilmRating(id)
      WHERE id in
      (SELECT FilmId FROM inserted);

END;
GO

CREATE TRIGGER ReviewDeleteTrig
ON Review
AFTER DELETE
AS
  UPDATE dbo.[Film]
    SET Rating = dbo.GetFilmRating(id)
    WHERE id IN (SELECT FilmId FROM deleted);
GO

-- Test table triggers

-- 1) insert:
INSERT INTO [User](Email, UserName)
    VALUES
  (N'anonymous@example.com', N'anonymous'),
  (N'person1@example.com', N'person1');
GO


INSERT INTO Film(FilmName, ProductionCo, Country) VALUES
  (N'The Shawshank Redemption', N'Castle Rock Entertainment', N'USA'),
  (N'The Godfather', N'Paramount Pictures', N'USA'),
  (N'Il buono, il brutto, il cattivo', N' New Line Cinema', N'Italy'),
  (N'The Lord of the Rings: The Return of the King', N' New Line Cinema', N'New Zeland'),
  (N'Schindler''s List', N'Universal Pictures', N'USA');
GO


INSERT INTO Review(PostDate, Rating, Comment, UserId, FilmId)
VALUES
  (DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 7.5, N'I have never seen such an amazing film since I saw The Shawshank Redemption. Shawshank encompasses friendships, hardships, hopes, and dreams.', 1, 1),
  (DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 8.9, N'The reason I became a member of this database is because I finally found a movie ranking that recognized the true greatness of this movie.', 1, 1),
  (DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 9.9, N'I believe that this film is the best story ever told on film, and I''m about to tell you why.', 1, 1),
  (DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 8.9, N'This is without a doubt my all-time favorite western.', 1, 2),
  (DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 9.5, N'Westerns don''t get any better than this.', 1, 2),
  (DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 8.8, N'..but oh was I thankful for it!!! All through the movie I kept on having this big large smile sculpted into my face.', 1, 4),
  (DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 7.5, N'I think it is important to remember that Peter Jackson took up this film not in order just to make a film of ''The Lord of the Rings'' but because he wanted to make a ''fantasy just like the ''The Lord of the Rings'' as he himself put it.', 1, 4),
  (DATEADD(day, (ABS(CHECKSUM(NEWID())) % 65530), 0), 4.5, 'i just watched this movie and i found it boring 3 hours for nothing this movie is just to make people feel sorry about the Jewish i want to say we must feel sorry about any human ..', 1, 5);
GO

SELECT * FROM [Review]
SELECT * FROM [Film];
GO

-- 2) update

UPDATE [Review]
  SET Rating = 9.5
  WHERE FilmId = 5;

SELECT * FROM [Review]
SELECT * FROM [Film];
GO


-- 3) delete

DELETE FROM [Review]
  WHERE FilmId = 5;


SELECT * FROM [Review]
SELECT * FROM [Film];
GO

---------------



IF OBJECT_ID(N'UsersReview') IS NOT NULL
  DROP VIEW UsersReview;
GO

CREATE VIEW UsersReview
AS
  SELECT
      u.Email AS UserEmail,
      r.PostDate AS PostDate,
      r.Comment AS UserComment,
      r.Rating AS UserRating,
      f.FilmName AS FilmName
    FROM [User] u
    INNER JOIN [Review] r ON r.UserId = u.UserId
    INNER JOIN [Film] f ON f.id = r.FilmId
  ;
GO




------------

-- Task 2. Create triggers for view --

CREATE TRIGGER UsrReviewIns
ON [UsersReview]
INSTEAD OF INSERT
AS
  IF EXISTS(
      SELECT * FROM inserted WHERE UserEmail NOT IN
        (SELECT Email From [User])
      )
    RAISERROR(N'Insert operation failed. Users with such emails are not exist.', 11, 2);
  IF EXISTS(
      SELECT * FROM inserted WHERE FilmName NOT IN
        (SELECT FilmName From [User])
      )
    RAISERROR(N'Insert operation failed. Films with such name are not exist.', 11, 2);
  ELSE
    INSERT INTO [Review]
      SELECT
        UNID=NEWID(),
        PostDate=CURRENT_TIMESTAMP,
        UserRating AS Rating,
        UserComment AS Comment,
        dbo.GetUserIdByEmail(UserEmail) AS UserId,
        dbo.GetFilmIdByName(FilmName) AS FilmId
      FROM inserted;
GO


CREATE TRIGGER UsrReviewDel
ON [UsersReview]
INSTEAD OF DELETE
AS
  WITH ReviewWithDeleted (UNID)
    AS (
      SELECT UNID
      FROM deleted d
        INNER JOIN [Review] r
        ON
          r.FilmId = dbo.GetFilmIdByName(d.FilmName)
        AND 
          r.UserId = dbo.GetUserIdByEmail(d.UserEmail)
        AND
          r.PostDate = d.PostDate
  ) DELETE FROM [Review]
      WHERE UNID IN
      (SELECT UNID FROM ReviewWithDeleted);
GO


CREATE TRIGGER UsrReviewUpd
ON [UsersReview]
INSTEAD OF UPDATE
AS
  IF UPDATE(UserEmail) OR UPDATE(FilmName)
    RAISERROR(N'You cannot delete foreign key. Operation is not permited', 11, 3);

  WITH ReviewWithInserted (UNID, UserComment, UserRating, PostDate)
  AS (
    SELECT
      r.UNID AS UNID,
      i.UserComment AS UserComment,
      i.UserRating As UserRating,
      i.PostDate AS PostDate
    FROM inserted i
      INNER JOIN [Review] r
      ON (
        r.FilmId = dbo.GetFilmIdByName(i.FilmName)
      AND
        r.UserId = dbo.GetUserIdByEmail(i.UserEmail)
      AND
        r.PostDate = i.PostDate)
  )
  UPDATE [Review]
    SET
      [Review].Comment = ReviewWithInserted.UserComment,
      [Review].PostDate = ReviewWithInserted.PostDate,
      [Review].Rating = ReviewWithInserted.UserRating
    FROM
      ReviewWithInserted 
    WHERE 
      Review.UNID = ReviewWithInserted.UNID;
GO


SELECT * FROM [UsersReview]
SELECT * FROM [Review];
SELECT * FROM [Film];
GO

-- Test insert trigger

INSERT INTO [UsersReview]
  (UserEmail, UserComment, UserRating, FilmName)
VALUES
  (N'person1@example.com', N'Spielberg is now the Numero Uno director of schmaltzy cinema. I thought Saving Private Ryan was the ultimate good guys save the poor soul...', 3.8, N'Schindler''s List'),
  (N'person1@example.com', N'This is honestly one of the most overrated films of all time. ', 5.8, N'Schindler''s List');
GO


SELECT * FROM [Film];
SELECT * FROM [Review];
SELECT * FROM [UsersReview];
GO


-- Test update trigger
UPDATE [UsersReview]
SET UserRating = UserRating - 1;
GO



SELECT * FROM [Review];
SELECT * FROM [UsersReview];
GO


-- Test delete trigger

DELETE FROM [UsersReview]
  WHERE UserRating < 7;
GO

SELECT * FROM [Film];
SELECT * FROM [UsersReview];
SELECT * FROM [Review];
GO
