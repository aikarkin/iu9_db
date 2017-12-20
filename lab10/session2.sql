USE Lab10;

SELECT @@spid AS Session2Id;
GO

--------------------

-- 1. dirty read

BEGIN TRANSACTION;

UPDATE [User]
SET UserName = N'anonym'
WHERE Email = N'anonymous@example.com';

WAITFOR DELAY '00:00:10';

ROLLBACK;


--------------------

-- 2. non-repeatable read

BEGIN TRAN;

DELETE [User]
WHERE Email = N'anonymous@example.com';

COMMIT TRAN;


--------------------

-- 3. phantom read

BEGIN TRAN;

INSERT INTO [User](Email, UserName)
    VALUES
  (N'person2@example.com', N'person2'),
  (N'person3@example.com', N'person3');

COMMIT TRAN;