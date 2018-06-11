/*This script doesnt create the database in MSSQL it only creates the table objects.
Create a Database first before tryin to run this script.*/
USE SoneController;
GO

SET XACT_ABORT ON

--Drop ErrorHandling
IF OBJECT_ID('dbo.CatchErrors', 'U')		IS NOT NULL DROP TABLE dbo.CatchErrors
IF OBJECT_ID('dbo.ErrorHandling', 'P')		IS NOT NULL DROP PROCEDURE dbo.ErrorHandling

--Drop Procedures.
IF OBJECT_ID('Assets.AddSwitch', 'P')		IS NOT NULL DROP PROCEDURE Assets.AddSwitch
IF OBJECT_ID('Assets.GetModels', 'P')		IS NOT NULL DROP PROCEDURE Assets.GetModels
IF OBJECT_ID('Assets.UpdateModel', 'P')		IS NOT NULL DROP PROCEDURE Assets.UpdateModel
IF OBJECT_ID('Assets.RemoveModel', 'P')		IS NOT NULL DROP PROCEDURE Assets.RemoveModel
IF OBJECT_ID('Assets.AddModel', 'P')		IS NOT NULL DROP PROCEDURE Assets.AddModel

--Drops Tables.
IF OBJECT_ID('OrderDetails.Orders', 'U')	IS NOT NULL DROP TABLE OrderDetails.Orders
IF OBJECT_ID('OrderDetails.Course', 'U')	IS NOT NULL DROP TABLE OrderDetails.Course
IF OBJECT_ID('Config.Room', 'U')			IS NOT NULL DROP TABLE Config.Room
IF OBJECT_ID('Config.PortConfig', 'U')		IS NOT NULL DROP TABLE Config.PortConfig
IF OBJECT_ID('Config.VLANs', 'U')			IS NOT NULL DROP TABLE Config.VLANs
IF OBJECT_ID('Config.Sones', 'U')			IS NOT NULL DROP TABLE Config.Sones
IF OBJECT_ID('Assets.Switches', 'U')		IS NOT NULL DROP TABLE Assets.Switches
IF OBJECT_ID('Assets.Models', 'U')			IS NOT NULL DROP TABLE Assets.Models

--Drop Sequence
IF OBJECT_ID('dbo.IDCounter', 'SO')			IS NOT NULL DROP SEQUENCE dbo.IDCounter;

--Drop Schema if it exist.
IF SCHEMA_ID('Assets')						IS NOT NULL DROP SCHEMA Assets;
IF SCHEMA_ID('Config')						IS NOT NULL DROP SCHEMA Config;
IF SCHEMA_ID('OrderDetails')				IS NOT NULL DROP SCHEMA OrderDetails;
GO

--Create all schemas
CREATE SCHEMA Assets;
GO
CREATE SCHEMA Config;
GO
CREATE SCHEMA OrderDetails;
GO

--Sequence for counting IDs
CREATE SEQUENCE dbo.IDCounter
AS INT
START WITH 0
INCREMENT BY 1;
GO

--Create all tables
--The order the tables are important because the FK reference table needs to exist before adding a FK.
CREATE TABLE Assets.Models
(
	ModelID		INT	IDENTITY(1,1)	NOT NULL,
	SwitchModel	NVARCHAR(20)		NOT NULL,
	CONSTRAINT	PK_ModelID
	PRIMARY KEY	(ModelID)
);
GO

CREATE TABLE Assets.Switches
(
    SwitchID	INT	IDENTITY(1,1)	NOT NULL,
    SwitchName	NVARCHAR(12)		NOT NULL,
	ModelID		INT					NOT NULL,
	PortSpeed	INT					NOT NULL,
	CONSTRAINT	PK_SwitchID
	PRIMARY KEY	(SwitchID),
	CONSTRAINT	FK_Models_ModelID_Switches
	FOREIGN KEY	(ModelID)
	REFERENCES	Assets.Models,
	CONSTRAINT	UQ_SwitchName
	UNIQUE		(SwitchName)
);
GO

CREATE TABLE Config.Sones
(
	SoneID		INT	IDENTITY(1,1)	NOT NULL,
	SoneName	NVARCHAR(9)			NOT NULL,
	CONSTRAINT	PK_SoneID
	PRIMARY KEY	(SoneID)
);
GO

CREATE TABLE Config.VLANs
(
	VLANID		INT	NOT NULL,
	SwitchID	INT	NOT NULL,
	SoneID		INT	NOT NULL,
	CONSTRAINT	PK_VLANs
	PRIMARY KEY	(VLANID, SwitchID, SoneID),
	CONSTRAINT	FK_Switches_SwitchID_VLANs
	FOREIGN KEY	(SwitchID)
	REFERENCES	Assets.Switches,
	CONSTRAINT	FK_Sones_SoneID_VLANs
	FOREIGN KEY	(SoneID)
	REFERENCES	Config.Sones
);
GO

CREATE TABLE Config.PortConfig
(
    SwitchID	INT	IDENTITY(1,1)	NOT NULL,
    SoneID		INT					NOT NULL,
	Config		NVARCHAR(200)		NOT NULL,
	CONSTRAINT	PK_SwitchID_SoneID
	PRIMARY KEY	(SwitchID, SoneID),
	CONSTRAINT	FK_Switches_SwitchID_PortConfig
	FOREIGN KEY	(SwitchID)
	REFERENCES	Assets.Switches,
	CONSTRAINT	FK_Sone_SoneiD_PortConfig
	FOREIGN KEY	(SoneID)
	REFERENCES	Config.Sones
);
GO

CREATE TABLE Config.Room
(
    RoomID		INT	IDENTITY(1,1)	NOT NULL,
    SwitchID	INT					NOT NULL,
	RoomName	NVARCHAR(50)		NOT NULL UNIQUE,
	PortRange	INT					NULL,
	SoneID		INT					NULL,
	VLAN		INT					NULL,
	CONSTRAINT	PK_RoomID
	PRIMARY KEY	(RoomID),
	CONSTRAINT	FK_Switches_SwitchID_Room
	FOREIGN KEY	(SwitchID)
	REFERENCES	Assets.Switches,
	CONSTRAINT	FK_Sone_SoneiD_Room
	FOREIGN KEY	(SoneID)
	REFERENCES	Config.Sones
);
GO

CREATE TABLE OrderDetails.Course
(
	CourseID			INT IDENTITY(1,1)	NOT NULL,
	RoomID				INT					NOT NULL,
	SoneID				INT					NULL,
	CourseTitle			NVARCHAR(30)		NOT NULL,
	CourseDescription	NVARCHAR(250)		NULL,
	StartDate			DATETIME			NOT NULL,
	EndDate				DATETIME			NOT NULL,
	Organizer			NVARCHAR(30)		NULL,
	CourseTrainer		NVARCHAR(30)		NULL,
	CONSTRAINT			PK_CourseID
	PRIMARY KEY			(CourseID),
	CONSTRAINT			FK_Room_RoomID_Course
	FOREIGN KEY			(RoomID)
	REFERENCES			Config.Room,
	CONSTRAINT			FK_Sone_SoneiD_Course
	FOREIGN KEY			(SoneID)
	REFERENCES			Config.Sones,
	CONSTRAINT			CK_Start_lt_End
	CHECK				(StartDate < EndDate) --Check for StartDate is less than EndDate
);
GO

CREATE TABLE OrderDetails.Orders
(
	OrderID		INT	IDENTITY(1,1)	NOT NULL,
	OrderBy		NVARCHAR(30)		NULL,
	CourseID	INT					NOT NULL,
	OrderDate	DATETIME			NOT NULL,
	CONSTRAINT	PK_OrderID
	PRIMARY KEY	(OrderID),
	CONSTRAINT	FK_Course_CourseID_Orders
	FOREIGN KEY	(CourseID)
	REFERENCES	OrderDetails.Course
);
GO

--Create Error handling for stored procedures:
CREATE TABLE dbo.CatchErrors
(
	OccurrenceID	INT	IDENTITY(1,1)	NOT NULL,
	ErrorDate		DATETIME			NULL,
	ErrorNumber		INT					NULL,
	ErrorMsg		NVARCHAR(4000)		NULL,
	ErrorSeverity	INT					NULL,
	ErrorState		INT					NULL,
	ErrorLine		INT					NULL,
	ErrorProcedure	NVARCHAR(128)		NULL,
	CONSTRAINT		PK_AuditErrors
	PRIMARY KEY		(OccurrenceID)
);
GO

CREATE PROCEDURE dbo.ErrorHandling
AS
	INSERT INTO dbo.CatchErrors
	VALUES		(
					GETDATE(),
					ERROR_NUMBER(),
					ERROR_MESSAGE(),
					ERROR_SEVERITY(),
					ERROR_STATE(),
					ERROR_LINE(),
					ERROR_PROCEDURE()
				);
	PRINT 'Error was logged with ID: ' + @@IDENTITY
GO

--Create stored procedures for CRUD handling.
--Assets.Models stored procs:
CREATE PROCEDURE Assets.AddModel(
	@ModelName	NVARCHAR(20)
)
AS
BEGIN TRY
	BEGIN TRANSACTION
		IF NOT EXISTS (SELECT SwitchModel FROM Assets.Models WHERE SwitchModel LIKE '%'+@ModelName+'%')
			BEGIN
				INSERT INTO Assets.Models(SwitchModel)
				VALUES		(@ModelName)
				COMMIT TRANSACTION;
			END
		ELSE
			BEGIN
				PRINT 'Model('+@ModelName+') already exists.'
				ROLLBACK TRANSACTION;
			END
	IF @@TRANCOUNT <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
END TRY
BEGIN CATCH
	EXEC dbo.ErrorHandling
END CATCH;
GO

CREATE PROCEDURE Assets.RemoveModel(
	@ModelID	INT,
	@ModelName	NVARCHAR(20) OUTPUT
)
AS
BEGIN TRY
	BEGIN TRANSACTION
		IF @ModelID IS NULL
			BEGIN
				ROLLBACK TRANSACTION;
				PRINT 'MODEL ID IS ZERO'
			END
		ELSE
			BEGIN
				DELETE FROM Assets.Models
				OUTPUT		deleted.SwitchModel
				WHERE		ModelID = @ModelID
				COMMIT TRANSACTION;
			END
	IF @@TRANCOUNT <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
END TRY
BEGIN CATCH
	EXEC dbo.ErrorHandling
END CATCH;
GO

CREATE PROCEDURE Assets.UpdateModel(
	@ModelID	INT,
	@ModelName	NVARCHAR(20)
)
AS
BEGIN TRY
	BEGIN TRANSACTION
		IF @ModelID IS NULL
			BEGIN
				ROLLBACK TRANSACTION;
				PRINT 'MODEL ID IS ZERO'
			END
		ELSE
			BEGIN
				UPDATE	Assets.Models
				SET		SwitchModel = @ModelName
				WHERE	ModelID = @ModelID
				COMMIT TRANSACTION;
			END
	IF @@TRANCOUNT <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
END TRY
BEGIN CATCH
	EXEC dbo.ErrorHandling;
END CATCH;
GO

CREATE PROCEDURE Assets.GetModels(
	@ModelName	INT = NULL
)
AS
BEGIN TRY
	IF @ModelName IS NULL
		BEGIN
			SELECT	SwitchModel
			FROM	Assets.Models
		END
	ELSE
		BEGIN
			SELECT	SwitchModel
			FROM	Assets.Models
			WHERE	SwitchModel LIKE '%'+@ModelName+'%' --Might have to change this depending on what we want to filter, this will scan the table.
		END
END TRY
BEGIN CATCH
	EXEC dbo.ErrorHandling;
END CATCH;
GO

CREATE PROCEDURE Assets.AddSwitch(
	@SwitchName NVARCHAR(12) = N'',
	@ModelID	INT,
	@Speed		INT
)
AS
BEGIN TRY
	BEGIN TRANSACTION
		IF NOT EXISTS (SELECT SwitchName FROM Assets.Switches WHERE SwitchName LIKE '%'+@SwitchName+'%')
			BEGIN
				INSERT INTO Assets.Switches(SwitchName, ModelID, PortSpeed)
				VALUES		(@SwitchName, @ModelID, @Speed)
				COMMIT TRANSACTION;
			END
		ELSE
			BEGIN
				PRINT 'Switch('+@SwitchName+') already exists.'
				ROLLBACK TRANSACTION;
			END
	IF @@TRANCOUNT <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
END TRY
BEGIN CATCH
	EXEC dbo.ErrorHandling
END CATCH;
GO

SET XACT_ABORT OFF;
GO