USE Lab10;
GO

DELETE FROM [User];
GO

INSERT INTO [User](Email, UserName)
    VALUES
  (N'anonymous@example.com', N'anonymous'),
  (N'person1@example.com', N'person1');
GO