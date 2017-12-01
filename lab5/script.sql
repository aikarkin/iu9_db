USE master


IF DB_ID(N'Lab5') IS NOT NULL 
BEGIN
  IF EXISTS (
      SELECT *  FROM sys.indexes 
        WHERE name='CIX_Departments_id'
    )
    DROP INDEX CIX_Departments_id ON Lab5.Departments
  DROP DATABASE Lab5;
END;

CREATE DATABASE Lab5
    ON ( NAME = Lab5_dat, FILENAME = 
        "/home/alex/dev/iu9/db/data/lab5dat.mdf",
         SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
    LOG ON ( NAME = Lab5_log, FILENAME = 
        "/home/alex/dev/iu9/db/data/lab5log.ldf",
        SIZE = 5MB, MAXSIZE = 50MB, FILEGROWTH = 5MB )
go


USE Lab5;

GO

IF OBJECT_ID(N'Employees') IS NOT NULL
BEGIN
  DROP Table Employees;
END

CREATE TABLE Employees( 
    id int IDENTITY(1, 1),
    fio varchar(120) NOT NULL,
    staffName varchar(120) NULL,
    salary money NOT NULL );
GO

INSERT INTO Employees(fio, staffName, salary) VALUES
  ('Ivanov Niklay Andreevich', 'developer', $120);

SELECT * FROM Employees;


ALTER DATABASE Lab5 ADD 
  FILEGROUP EmployeesFileGroup

GO

ALTER DATABASE Lab5 ADD FILE (
  name="EmplFileMod", FILENAME="/home/alex/dev/iu9/db/data/EmplFileMod"
) TO FILEGROUP EmployeesFileGroup;

GO

SELECT * FROM Employees;

ALTER DATABASE Lab5 
  MODIFY FILEGROUP EmployeesFileGroup DEFAULT;
GO


SELECT * FROM Employees;

CREATE TABLE Departments( 
    id int IDENTITY(1, 1),
    depName nvarchar(400) NOT NULL,
    LocationReal nvarchar(400) NULL);
GO



SELECT o.[name], o.[type], i.[name], i.[index_id], f.[name] FROM sys.indexes i
INNER JOIN sys.filegroups f
ON i.data_space_id = f.data_space_id
INNER JOIN sys.all_objects o
ON i.[object_id] = o.[object_id] WHERE i.data_space_id = f.data_space_id
AND o.type = 'U'
GO

INSERT INTO Departments([depName], LocationReal) VALUES
  (N'Department 1', N'Addr 1');
GO

SELECT * FROM Employees;
SELECT * FROM Departments;
GO

CREATE CLUSTERED INDEX CIX_Departments_id
   ON dbo.Departments (id)
   WITH (DROP_EXISTING = OFF)
   ON [PRIMARY]
GO

ALTER DATABASE Lab5 
  MODIFY FILEGROUP [PRIMARY] DEFAULT;
GO

ALTER DATABASE Lab5
  REMOVE FILE EmplFileMod;

ALTER DATABASE Lab5
  REMOVE FILEGROUP EmployeesFileGroup;




SELECT o.[name], o.[type], i.[name], i.[index_id], f.[name] FROM sys.indexes i
INNER JOIN sys.filegroups f
ON i.data_space_id = f.data_space_id
INNER JOIN sys.all_objects o
ON i.[object_id] = o.[object_id] WHERE i.data_space_id = f.data_space_id
AND o.type = 'U'
GO

INSERT INTO Departments([depName], LocationReal) VALUES
  (N'Department 2', N'Addr 2');
GO

SELECT * FROM Employees;
SELECT * FROM Departments;
GO

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'Empl')
BEGIN
  DROP SCHEMA Empl
END;

EXEC ('CREATE SCHEMA Empl;');
GO


ALTER SCHEMA Empl TRANSFER dbo.Employees;
GO

SELECT * from Empl.Employees
go

ALTER SCHEMA dbo TRANSFER Empl.Employees;
GO

DROP SCHEMA Empl
GO