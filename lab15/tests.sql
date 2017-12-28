USE Lab15_1;

DELETE ReviewView
GO

DELETE UserView
GO

INSERT INTO UserView
  (Email, UserName, About)
VALUES
  (N'student1@bmstu.ru', N'student1', N'student'),
  (N'student2@bmstu.ru', N'student2', N'student');
GO

UPDATE [UserView]
SET About = N'updated through view';
GO

SELECT * FROM UserView;


INSERT INTO ReviewView(UNID, PostDate, Rating, Comment, UserId)
  VALUES
    -- (NEWID(), CURRENT_TIMESTAMP, 5.7, 'comment 4', 4),
    -- (NEWID(), CURRENT_TIMESTAMP, 3.8, 'comment 3', 3),
    (NEWID(), CURRENT_TIMESTAMP, 8.9, 'comment 2', 2),
    (NEWID(), CURRENT_TIMESTAMP, 7.6, 'comment 1', 1);
GO

SELECT * FROM ReviewView;
GO

UPDATE ReviewView SET Rating = Rating + 1
GO

SELECT * FROM ReviewView;
GO


-- Lab15_2

USE Lab15_2;

INSERT INTO UserView
  (Email, UserName, About)
VALUES
  (N'student3@bmstu.ru', N'student3', N'student'),
  (N'student4@bmstu.ru', N'student4', N'student'),
  (N'person1@bmstu.ru', N'person1', N'person'),
  (N'person2@bmstu.ru', N'person2', N'person');
GO

SELECT * FROM UserView;

UPDATE UserView
  SET About = 'student'
  WHERE About LIKE 'updated%';

SELECT * FROM UserView;

DELETE UserView WHERE UserName LIKE 'person%';

SELECT * FROM UserView;



INSERT INTO ReviewView(UNID, PostDate, Rating, Comment, UserId)
  VALUES
    -- (NEWID(), CURRENT_TIMESTAMP, 5.7, 'comment 4', 10),
    -- (NEWID(), CURRENT_TIMESTAMP, 3.8, 'comment 3', 15),
    (NEWID(), CURRENT_TIMESTAMP, 5.9, 'comment', 3),
    (NEWID(), CURRENT_TIMESTAMP, 3.6, 'comment', 4);
GO

SELECT * FROM ReviewView;
GO

UPDATE ReviewView SET Rating = Rating + 1
WHERE UserId > 2
GO

SELECT * FROM ReviewView;
GO

DELETE ReviewView WHERE UserId < 3;

SELECT * FROM ReviewView;
GO