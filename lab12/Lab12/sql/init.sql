use lab12;

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
