SET XACT_ABORT ON
IF NOT EXISTS	(
					SELECT database_id
					FROM [master].[sys].[databases] WHERE [name] = 'ZoneController'
				)
	CREATE DATABASE ZoneController;
GO

USE ZoneController;
GO

-------------------------------------------------------------------------
--Drop ErrorLogging
-------------------------------------------------------------------------
IF OBJECT_ID('Auditing.CatchErrors', 'U')	IS NOT NULL DROP TABLE Auditing.CatchErrors;
IF OBJECT_ID('Auditing.ErrorLogging', 'P')	IS NOT NULL DROP PROCEDURE Auditing.ErrorLogging;
IF OBJECT_ID('Auditing.ErrorHandling', 'P')	IS NOT NULL DROP PROCEDURE Auditing.ErrorHandling;
-------------------------------------------------------------------------
--Drop Procedures.
-------------------------------------------------------------------------
IF OBJECT_ID('OrderDetails.GetCourses', 'P')IS NOT NULL DROP PROCEDURE OrderDetails.GetCourses;
IF OBJECT_ID('Person.GetUsers', 'P')		IS NOT NULL DROP PROCEDURE Person.GetUsers;
IF OBJECT_ID('Person.UpdateUser', 'P')		IS NOT NULL DROP PROCEDURE Person.UpdateUser;
IF OBJECT_ID('Person.RemoveUser', 'P')		IS NOT NULL DROP PROCEDURE Person.RemoveUser;
IF OBJECT_ID('Person.AddUser', 'P')			IS NOT NULL DROP PROCEDURE Person.AddUser;
IF OBJECT_ID('Config.GetRooms', 'P')		IS NOT NULL DROP PROCEDURE Config.GetRooms;
IF OBJECT_ID('Config.UpdateRoom', 'P')		IS NOT NULL DROP PROCEDURE Config.UpdateRoom;
IF OBJECT_ID('Config.RemoveRoom', 'P')		IS NOT NULL DROP PROCEDURE Config.RemoveRoom;
IF OBJECT_ID('Config.AddRoom', 'P')			IS NOT NULL DROP PROCEDURE Config.AddRoom;
IF OBJECT_ID('Config.GetVLANs', 'P')		IS NOT NULL DROP PROCEDURE Config.GetVLANs;
IF OBJECT_ID('Config.UpdateVLAN', 'P')		IS NOT NULL DROP PROCEDURE Config.UpdateVLAN;
IF OBJECT_ID('Config.RemoveVLAN', 'P')		IS NOT NULL DROP PROCEDURE Config.RemoveVLAN;
IF OBJECT_ID('Config.AddVLAN', 'P')			IS NOT NULL DROP PROCEDURE Config.AddVLAN;
IF OBJECT_ID('Config.GetZones', 'P')		IS NOT NULL DROP PROCEDURE Config.GetZones;
IF OBJECT_ID('Config.UpdateZone', 'P')		IS NOT NULL DROP PROCEDURE Config.UpdateZone;
IF OBJECT_ID('Config.RemoveZone', 'P')		IS NOT NULL DROP PROCEDURE Config.RemoveZone;
IF OBJECT_ID('Config.AddZone', 'P')			IS NOT NULL DROP PROCEDURE Config.AddZone;
IF OBJECT_ID('Assets.GetSwitches', 'P')		IS NOT NULL DROP PROCEDURE Assets.GetSwitches;
IF OBJECT_ID('Assets.UpdateSwitch', 'P')	IS NOT NULL DROP PROCEDURE Assets.UpdateSwitch;
IF OBJECT_ID('Assets.RemoveSwitch', 'P')	IS NOT NULL DROP PROCEDURE Assets.RemoveSwitch;
IF OBJECT_ID('Assets.AddSwitch', 'P')		IS NOT NULL DROP PROCEDURE Assets.AddSwitch;
IF OBJECT_ID('Assets.GetModels', 'P')		IS NOT NULL DROP PROCEDURE Assets.GetModels;
IF OBJECT_ID('Assets.UpdateModel', 'P')		IS NOT NULL DROP PROCEDURE Assets.UpdateModel;
IF OBJECT_ID('Assets.RemoveModel', 'P')		IS NOT NULL DROP PROCEDURE Assets.RemoveModel;
IF OBJECT_ID('Assets.AddModel', 'P')		IS NOT NULL DROP PROCEDURE Assets.AddModel;
-------------------------------------------------------------------------
--Drops Tables.
-------------------------------------------------------------------------
IF OBJECT_ID('Offices.Locations', 'U')		IS NOT NULL DROP TABLE Offices.Locations;
IF OBJECT_ID('Offices.Addresses', 'U')		IS NOT NULL DROP TABLE Offices.Addresses;
IF OBJECT_ID('OrderDetails.Orders', 'U')	IS NOT NULL DROP TABLE OrderDetails.Orders;
IF OBJECT_ID('OrderDetails.Courses', 'U')	IS NOT NULL DROP TABLE OrderDetails.Courses;
IF OBJECT_ID('Person.Users', 'U')			IS NOT NULL DROP TABLE Person.Users;
IF OBJECT_ID('Config.Rooms', 'U')			IS NOT NULL DROP TABLE Config.Rooms;
IF OBJECT_ID('Config.VLANs', 'U')			IS NOT NULL DROP TABLE Config.VLANs;
IF OBJECT_ID('Config.Zones', 'U')			IS NOT NULL DROP TABLE Config.Zones;
IF OBJECT_ID('Assets.Switches', 'U')		IS NOT NULL DROP TABLE Assets.Switches;
IF OBJECT_ID('Assets.Models', 'U')			IS NOT NULL DROP TABLE Assets.Models;
-------------------------------------------------------------------------
--Drop Schema if it exist.
-------------------------------------------------------------------------
IF SCHEMA_ID('Assets')						IS NOT NULL DROP SCHEMA Assets;
IF SCHEMA_ID('Config')						IS NOT NULL DROP SCHEMA Config;
IF SCHEMA_ID('OrderDetails')				IS NOT NULL DROP SCHEMA OrderDetails;
IF SCHEMA_ID('Person')						IS NOT NULL DROP SCHEMA Person;
IF SCHEMA_ID('Offices')						IS NOT NULL DROP SCHEMA Offices;
IF SCHEMA_ID('Auditing')					IS NOT NULL DROP SCHEMA Auditing;
-------------------------------------------------------------------------
GO

--Create all schemas
CREATE SCHEMA Assets;
GO
CREATE SCHEMA Config;
GO
CREATE SCHEMA OrderDetails;
GO
CREATE SCHEMA Person;
GO
CREATE SCHEMA Offices;
GO
CREATE SCHEMA Auditing;
GO

--Create all tables
--The order of the tables are important because the FK reference table needs to exist before adding a FK.
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
	SwitchName	NVARCHAR(30)		NOT NULL,
	ModelID		INT					NOT NULL,
	PortRange	NVARCHAR(50)		NOT NULL,
	CONSTRAINT	PK_SwitchID
	PRIMARY KEY	(SwitchID),
	CONSTRAINT	FK_Models_ModelID_Switches
	FOREIGN KEY	(ModelID)
	REFERENCES	Assets.Models,
	CONSTRAINT	UQ_SwitchName
	UNIQUE		(SwitchName)
);
GO

CREATE TABLE Config.Zones
(
	ZoneID		INT	IDENTITY(1,1)	NOT NULL,
	ZoneName	NVARCHAR(20)		NOT NULL,
	CONSTRAINT	PK_ZoneID
	PRIMARY KEY	(ZoneID)
);
GO

CREATE TABLE Config.VLANs
(
	VLANID		INT	NOT NULL,
	SwitchID	INT	NOT NULL,
	ZoneID		INT	NOT NULL,
	CONSTRAINT	PK_VLANID_SwitchID_ZoneID
	PRIMARY KEY	(VLANID, SwitchID, ZoneID),
	CONSTRAINT	FK_Switches_SwitchID_VLANs
	FOREIGN KEY	(SwitchID)
	REFERENCES	Assets.Switches,
	CONSTRAINT	FK_Zones_ZoneID_VLANs
	FOREIGN KEY	(ZoneID)
	REFERENCES	Config.Zones
);
GO

CREATE TABLE Config.Rooms
(
	RoomID		INT	IDENTITY(1,1)	NOT NULL,
	SwitchID	INT					NOT NULL,
	RoomName	NVARCHAR(50)		NOT NULL,
	VLAN		INT					NULL,
	CONSTRAINT	PK_RoomID
	PRIMARY KEY	(RoomID),
	CONSTRAINT	FK_Switches_SwitchID_Rooms
	FOREIGN KEY	(SwitchID)
	REFERENCES	Assets.Switches,
	CONSTRAINT	UQ_RoomName
	UNIQUE		(RoomName)
);
GO

CREATE TABLE Person.Users
(
	UserID		INT	IDENTITY(1,1)	NOT NULL,
	FirstName	NVARCHAR(50)		NULL,
	LastName	NVARCHAR(50)		NULL,
	LogonName	NVARCHAR(20)		NULL,
	EMail		NVARCHAR(100)		NULL,
	OBJGUID		UNIQUEIDENTIFIER	NOT NULL	CONSTRAINT	DF_OBJGUID	DEFAULT	NEWID(), -- Use this for AD objguid?
	CONSTRAINT	PK_UserID
	PRIMARY KEY	(UserID)
);
GO

CREATE TABLE OrderDetails.Courses
(
	CourseID			INT IDENTITY(1,1)	NOT NULL,
	RoomID				INT					NOT NULL,
	ZoneID				INT					NULL,
	CourseTitle			NVARCHAR(30)		NOT NULL,
	CourseDescription	NVARCHAR(250)		NULL,
	StartDate			DATETIME			NOT NULL,
	EndDate				DATETIME			NOT NULL,
	OrganizerID			INT					NULL,
	CourseTrainer		NVARCHAR(150)		NULL,
	CONSTRAINT			PK_CourseID
	PRIMARY KEY			(CourseID),
	CONSTRAINT			FK_Rooms_RoomID_Courses
	FOREIGN KEY			(RoomID)
	REFERENCES			Config.Rooms,
	CONSTRAINT			FK_Zone_ZoneiD_Courses
	FOREIGN KEY			(ZoneID)
	REFERENCES			Config.Zones,
	CONSTRAINT			FK_Users_OrganizerID_Courses
	FOREIGN KEY			(OrganizerID)
	REFERENCES			Person.Users,
	CONSTRAINT			CK_Start_lt_End
	CHECK				(StartDate < EndDate) --Check for StartDate is less than EndDate
);
GO

CREATE TABLE OrderDetails.Orders
(
	OrderID		INT	IDENTITY(1,1)	NOT NULL,
	OrderBy		INT					NULL,
	CourseID	INT					NOT NULL,
	OrderDate	DATETIME			NOT NULL,
	CONSTRAINT	PK_OrderID
	PRIMARY KEY	(OrderID),
	CONSTRAINT	FK_Users_OrderBy_Orders
	FOREIGN KEY	(OrderBy)
	REFERENCES	Person.Users,
	CONSTRAINT	FK_Courses_CourseID_Orders
	FOREIGN KEY	(CourseID)
	REFERENCES	OrderDetails.Courses
);
GO

CREATE TABLE Offices.Addresses
(
	AddressID		INT	IDENTITY(1,1)	NOT NULL,
	AddressLine		NVARCHAR(50)		NULL,
	City			NVARCHAR(25)		NULL,
	StateOrProvince	NVARCHAR(50)		NULL,
	PostalCode		INT					NULL,
	CONSTRAINT		PK_AddressID
	PRIMARY KEY		(AddressID)
	--AddressTypeID	INT					NOT NULL,
	/*
	If we are using other types of addresses, such as one for locations and one for users.
	The mindset will be as following:
	Create another table(AddressType) and add the following types.
	Users
	Locations
	*/
);
GO

CREATE TABLE Offices.Locations
(
	LocationID		INT	IDENTITY(1,1)	NOT NULL,
	LocationName	NVARCHAR(50)		NULL,
	AddressID		INT					NULL,
	ContactID		INT					NULL,  -- This would be the userid from the user table.
	Code			NVARCHAR(20)		NULL,
	CONSTRAINT		PK_LocationID
	PRIMARY KEY		(LocationID),
	CONSTRAINT		FK_Addresses_AddressID_Locations
	FOREIGN KEY		(AddressID)
	REFERENCES		Offices.Addresses,
	CONSTRAINT		FK_Users_ContactID_Locations
	FOREIGN KEY		(ContactID)
	REFERENCES		Person.Users
);
GO

--Create Error handling for stored procedures:
CREATE TABLE Auditing.CatchErrors
(
	OccurrenceID	INT	IDENTITY(1,1)	NOT NULL,
	ErrorDate		DATETIME			NULL,
	ErrorNumber		INT					NULL,
	ErrorMsg		NVARCHAR(4000)		NULL,
	ErrorSeverity	INT					NULL,
	ErrorState		INT					NULL,
	ErrorLine		INT					NULL,
	ErrorProcedure	NVARCHAR(128)		NULL,
	ErrorXACTSTATE	SMALLINT			NULL,
	CONSTRAINT		PK_AuditErrors
	PRIMARY KEY		(OccurrenceID)
);
GO

CREATE PROCEDURE Auditing.ErrorLogging
AS
	INSERT INTO Auditing.CatchErrors(ErrorDate, ErrorNumber, ErrorMsg, ErrorSeverity, ErrorState, ErrorLine, ErrorProcedure, ErrorXACTSTATE)
	VALUES		(
					GETDATE(),
					ERROR_NUMBER(),
					ERROR_MESSAGE(),
					ERROR_SEVERITY(),
					ERROR_STATE(),
					ERROR_LINE(),
					ERROR_PROCEDURE(),
					XACT_STATE()
				);
GO

CREATE PROCEDURE Auditing.ErrorHandling
AS
	EXEC Auditing.ErrorLogging;		--Execute ErrorLogging, so we can log the error that triggered the catch block.
	IF @@TRANCOUNT <> 0				--Check transaction count, if there is a uncommited transaction do a ROLLBACK.
		BEGIN
			ROLLBACK TRANSACTION;
		END
	IF	XACT_STATE() = -1			--Check XACT_STATE in the case of uncommitable transactions -1 means the transaction is uncommitable.
		BEGIN
			ROLLBACK TRANSACTION;
		END
	IF	XACT_STATE() = 1			--Check XACT_STATE in the case of uncommitable transactions 1 means the transaction is commitable.
		BEGIN
			COMMIT TRANSACTION;
		END
GO

--Create stored procedures for CRUD handling.
--Assets.Models stored procs:
CREATE PROCEDURE Assets.AddModel(
	@ModelName	NVARCHAR(20)		--Modelname that should be added.
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF NOT EXISTS (SELECT ModelID FROM Assets.Models WHERE SwitchModel LIKE '%'+@ModelName+'%')
			BEGIN
				INSERT INTO Assets.Models(SwitchModel)
				VALUES		(@ModelName)
				COMMIT TRANSACTION;
				RETURN 1;
			END
		ELSE
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 60000, 'ModelName already exists', 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Assets.RemoveModel(
	@ModelID	INT
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF (@ModelID IS NULL)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61000, 'ModelID cannot be NULL', 1;
			END
		IF NOT EXISTS (SELECT TOP 1 ModelID FROM Assets.Models WHERE ModelID = @ModelID)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61001, 'ModelID does not exist', 1;
			END
		ELSE
			BEGIN
				DELETE FROM Assets.Models
				WHERE		ModelID = @ModelID
				COMMIT TRANSACTION;
				RETURN 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Assets.UpdateModel(
	@ModelID	INT,			-- ModelID from application, get the select modelid first.
	@ModelName	NVARCHAR(20)	-- What the modelname should be changed to.
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF (@ModelID IS NULL)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61000, 'ModelID cannot be NULL', 1;
			END
		IF NOT EXISTS (SELECT TOP 1 ModelID FROM Assets.Models WHERE ModelID = @ModelID)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61001, 'ModelID does not exist', 1;
			END
		ELSE
			BEGIN
				UPDATE	Assets.Models
				SET		SwitchModel = @ModelName
				WHERE	ModelID = @ModelID
				COMMIT TRANSACTION;
				RETURN 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Assets.GetModels(
	@ModelName	NVARCHAR(20) = NULL
)
AS
BEGIN TRY
	SET NOCOUNT ON;
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
	SET NOCOUNT OFF;
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorLogging
	RETURN 0;
END CATCH;
GO

CREATE PROCEDURE Assets.AddSwitch(
	@SwitchName NVARCHAR(12) = N'',
	@ModelID	INT,
	@PortRange	NVARCHAR(50)
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF NOT EXISTS (SELECT SwitchID FROM Assets.Switches WHERE SwitchName LIKE '%'+@SwitchName+'%')
			BEGIN
				INSERT INTO Assets.Switches(SwitchName, ModelID, PortRange)
				VALUES		(@SwitchName, @ModelID, @PortRange)
				COMMIT TRANSACTION;
				RETURN 1;
			END
		ELSE
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 60000, 'SwitchName already exists', 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Assets.RemoveSwitch(
	@SwitchID	INT
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF @SwitchID IS NULL
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61000, 'SwitchID cannot be NULL', 1;
			END
		ELSE
			BEGIN
				DELETE FROM Assets.Switches
				WHERE		SwitchID = @SwitchID
				COMMIT TRANSACTION;
				RETURN 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Assets.UpdateSwitch(
	@SwitchID	INT = NULL,
	@SwitchName	NVARCHAR(20),
	@ModelID	INT,
	@PortRange	NVARCHAR(50)
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF (@SwitchID IS NULL)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61000, 'SwitchID cannot be NULL', 1;
			END
		IF NOT EXISTS (SELECT TOP 1 SwitchID FROM Assets.Switches WHERE SwitchID = @SwitchID)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61001, 'SwitchID does not exist', 1;
			END
		ELSE
			BEGIN
				UPDATE	Assets.Switches
				SET		SwitchName = @SwitchName,
						ModelID = @ModelID,
						PortRange = @PortRange
				WHERE	SwitchID = @SwitchID
				COMMIT TRANSACTION;
				RETURN 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO


CREATE PROCEDURE Assets.GetSwitches(
	@SwitchName	NVARCHAR(30) = NULL
)
AS
BEGIN TRY
	SET NOCOUNT ON;
	IF @SwitchName IS NULL
		BEGIN
			SELECT	SW.SwitchID,
					SW.SwitchName,
					MO.SwitchModel,
					SW.PortRange
			FROM	Assets.Switches AS SW
			JOIN	Assets.Models AS MO
					ON SW.ModelID = MO.ModelID
		END
	ELSE
		BEGIN
			SELECT	SW.SwitchID,
					SW.SwitchName,
					MO.SwitchModel,
					SW.PortRange
			FROM	Assets.Switches AS SW
			JOIN	Assets.Models AS MO
					ON SW.ModelID = MO.ModelID
			WHERE	SW.SwitchName LIKE '%' + @SwitchName + '%'
		END
	SET NOCOUNT OFF;
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorLogging
	RETURN 0;
END CATCH;
GO

CREATE PROCEDURE Config.AddZone(
	@ZoneName	NVARCHAR(20)
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF NOT EXISTS (SELECT ZoneID FROM Config.Zones WHERE ZoneName LIKE '%'+@ZoneName+'%')
			BEGIN
				INSERT INTO	Config.Zones(ZoneName)
				VALUES		(@ZoneName)
				RETURN 1;
			END
		ELSE
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 60000, 'ZoneName already exists', 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Config.RemoveZone(
	@ZoneID	INT
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF (@ZoneID IS NULL)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61000, 'ZoneID cannot be NULL', 1;
			END
		IF NOT EXISTS (SELECT TOP 1 ZoneID FROM Config.Zones WHERE ZoneID = @ZoneID)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61001, 'ZoneID does not exist', 1;
			END
		ELSE
			BEGIN
				DELETE FROM Config.Zones
				WHERE		ZoneID = @ZoneID
				COMMIT TRANSACTION;
				RETURN 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Config.UpdateZone(
	@ZoneID		INT,
	@ZoneName	NVARCHAR(20) = NULL
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF (@ZoneID IS NULL)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61000, 'ZoneID cannot be NULL', 1;
			END
		IF NOT EXISTS (SELECT TOP 1 ZoneID FROM Config.Zones WHERE ZoneID = @ZoneID)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61001, 'ZoneID does not exist', 1;
			END
		ELSE
			BEGIN
				UPDATE	Config.Zones
				SET		ZoneName = @ZoneName
				WHERE	ZoneID = @ZoneID
				COMMIT TRANSACTION;
				RETURN 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Config.GetZones(
	@ZoneName	NVARCHAR(20)
)
AS
BEGIN TRY
	SET NOCOUNT ON;
	IF @ZoneName IS NULL
		BEGIN
			SELECT	ZoneName
			FROM	Config.Zones
		END
	ELSE
		BEGIN
			SELECT	ZoneName
			FROM	Config.Zones
			WHERE	ZoneName LIKE '%'+@ZoneName+'%' --Might have to change this depending on what we want to filter, this will scan the table.
		END
	SET NOCOUNT OFF;
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorLogging
	RETURN 0;
END CATCH;
GO

CREATE PROCEDURE Config.AddVLAN(
	@VLAN		INT,
	@SwitchID	INT,
	@ZoneID		INT
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF NOT EXISTS (SELECT VLANID FROM Config.VLANs WHERE VLANID = @VLAN)
			BEGIN
				INSERT INTO	Config.VLANs(VLANID, SwitchID, ZoneID)
				VALUES		(@VLAN, @SwitchID, @ZoneID)
				RETURN 1;
			END
		ELSE
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 60000, 'VLANID already exists', 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Config.RemoveVLAN(
	@VLANID	INT
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF (@VLANID IS NULL)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61000, 'VLANID cannot be NULL', 1;
			END
		IF NOT EXISTS (SELECT TOP 1 VLANID FROM Config.VLANs WHERE VLANID = @VLANID)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61001, 'VLANID does not exist', 1;
			END
		ELSE
			BEGIN
				DELETE FROM Config.VLANs
				WHERE		VLANID = @VLANID
				COMMIT TRANSACTION;
				RETURN 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Config.UpdateVLAN(
	@VLANID		INT,
	@SwitchID	INT,
	@ZoneID		INT
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF (@VLANID IS NULL)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61000, 'VLANID cannot be NULL', 1;
			END
		IF NOT EXISTS (SELECT TOP 1 VLANID FROM Config.VLANs WHERE VLANID = @VLANID)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61001, 'VLANID does not exist', 1;
			END
		ELSE
			BEGIN
				UPDATE	Config.VLANs
				SET		SwitchID = @SwitchID,
						ZoneID = @ZoneID
				WHERE	VLANID = @VLANID
				COMMIT TRANSACTION;
				RETURN 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Config.GetVLANs(
	@VLANID	INT
)
AS
BEGIN TRY
	SET NOCOUNT ON;
	IF @VLANID IS NULL
		BEGIN
			SELECT	VLANID,
					SwitchID,
					ZoneID
			FROM	Config.VLANs
		END
	ELSE
		BEGIN
			SELECT	VLANID,
					SwitchID,
					ZoneID
			FROM	Config.VLANs
			WHERE	VLANID = @VLANID --Might have to change this depending on what we want to filter.
		END
	SET NOCOUNT OFF;
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorLogging
	RETURN 0;
END CATCH;
GO

CREATE PROCEDURE Config.AddRoom(
	@SwitchID	INT,
	@RoomName	NVARCHAR(50),
	@VLAN		INT
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF NOT EXISTS (SELECT RoomID FROM Config.Rooms WHERE RoomName = @RoomName)
			BEGIN
				INSERT INTO	Config.Rooms(SwitchID, RoomName, VLAN)
				VALUES		(@SwitchID, @RoomName, @VLAN)
				RETURN 1;
			END
		ELSE
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 60000, 'RoomName already exists', 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Config.RemoveRoom(
	@RoomID	INT
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF (@RoomID IS NULL)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61000, 'RoomID cannot be NULL', 1;
			END
		IF NOT EXISTS (SELECT TOP 1 RoomID FROM Config.Rooms WHERE RoomID = @RoomID)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61001, 'RoomID does not exist', 1;
			END
		ELSE
			BEGIN
				DELETE FROM Config.Rooms
				WHERE		RoomID = @RoomID
				COMMIT TRANSACTION;
				RETURN 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Config.UpdateRoom(
	@RoomID		INT,
	@SwitchID	INT,
	@RoomName	NVARCHAR(50),
	@VLAN		INT
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF (@RoomID IS NULL)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61000, 'RoomID cannot be NULL', 1;
			END
		IF NOT EXISTS (SELECT TOP 1 RoomID FROM Config.Rooms WHERE RoomID = @RoomID)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61001, 'RoomID does not exist', 1;
			END
		ELSE
			BEGIN
				UPDATE	Config.Rooms
				SET		SwitchID = @SwitchID,
						RoomName = @RoomName,
						VLAN = @VLAN
				WHERE	RoomID = @RoomID
				COMMIT TRANSACTION;
				RETURN 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Config.GetRooms(
	@RoomID	INT
)
AS
BEGIN TRY
	SET NOCOUNT ON;
	IF @RoomID IS NULL
		BEGIN
			SELECT	RoomID,
					SwitchID,
					RoomName,
					VLAN
			FROM	Config.Rooms
		END
	ELSE
		BEGIN
			SELECT	RoomID,
					SwitchID,
					RoomName,
					VLAN
			FROM	Config.Rooms
			WHERE	RoomID = @RoomID --Might have to change this depending on what we want to filter.
		END
	SET NOCOUNT OFF;
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorLogging
	RETURN 0;
END CATCH;
GO

CREATE PROCEDURE Person.AddUser(
	@FirstName	NVARCHAR(50),
	@LastName	NVARCHAR(50),
	@LogonName	NVARCHAR(20),
	@EMail		NVARCHAR(100)
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF NOT EXISTS (SELECT UserID FROM Person.Users WHERE LogonName = @LogonName)
			BEGIN
				INSERT INTO	Person.Users(FirstName, LastName, LogonName, EMail)
				VALUES		(@FirstName, @LastName, @LogonName, @EMail)
				RETURN 1;
			END
		ELSE
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 60000, 'A user with that username already exists', 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Person.RemoveUser(
	@UserID	INT
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF (@UserID IS NULL)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61000, 'UserID cannot be NULL', 1;
			END
		IF NOT EXISTS (SELECT TOP 1 UserID FROM Person.Users WHERE UserID = @UserID)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61001, 'UserID does not exist', 1;
			END
		ELSE
			BEGIN
				DELETE FROM Person.Users
				WHERE		UserID = @UserID
				COMMIT TRANSACTION;
				RETURN 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Person.UpdateUser(
	@UserID		INT,
	@FirstName	NVARCHAR(50),
	@LastName	NVARCHAR(50),
	@LogonName	NVARCHAR(20),
	@EMail		NVARCHAR(100)
)
AS
BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		IF (@UserID IS NULL)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61000, 'UserID cannot be NULL', 1;
			END
		IF NOT EXISTS (SELECT TOP 1 UserID FROM Person.Users WHERE UserID = @UserID)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 61001, 'UserID does not exist', 1;
			END
		ELSE
			BEGIN
				UPDATE	Person.Users
				SET		FirstName = @FirstName,
						LastName = @LastName,
						LogonName = @LogonName,
						EMail = @EMail
				WHERE	UserID = @UserID
				COMMIT TRANSACTION;
				RETURN 1;
			END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;					--Return False to the application, so we can report the error to the user.
END CATCH;
GO

CREATE PROCEDURE Person.GetUsers(
	@UserID	INT
)
AS
BEGIN TRY
	SET NOCOUNT ON;
	IF @UserID IS NULL
		BEGIN
			SELECT	UserID,
					FirstName,
					LastName,
					LogonName,
					EMail
			FROM	Person.Users
		END
	ELSE
		BEGIN
			SELECT	UserID,
					FirstName,
					LastName,
					LogonName,
					EMail
			FROM	Person.Users
			WHERE	UserID = @UserID --Might have to change this depending on what we want to filter.
		END
	SET NOCOUNT OFF;
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorLogging
	RETURN 0;
END CATCH;
GO

--CREATE PROCEDURE OrderDetails.AddCourse(
--	@RoomID				INT,
--	@ZoneID				INT,
--	@CourseTitle		NVARCHAR(30),
--	@CourseDescription	NVARCHAR(250),
--	@StartDate			DATETIME,
--	@EndDate			DATETIME,
--	@OrganizerID		INT,
--	@CourseTrainer		NVARCHAR(150)
--)
--AS
--BEGIN TRY
--	SET XACT_ABORT ON;
--	SET NOCOUNT ON;
--	BEGIN TRANSACTION
--		IF NOT EXISTS (SELECT CourseID FROM Person.Users WHERE LogonName = @LogonName)
--			BEGIN
--				INSERT INTO	Person.Users()
--				VALUES		()
--				RETURN 1;
--			END
--		ELSE
--			BEGIN
--				ROLLBACK TRANSACTION;
--				THROW 60000, 'A user with that username already exists', 1;
--			END
--END TRY
--BEGIN CATCH
--	EXEC Auditing.ErrorHandling;
--	RETURN 0;					--Return False to the application, so we can report the error to the user.
--END CATCH;
--GO



--CREATE PROCEDURE OrderDetails.GetCourses(
--	@CourseID	INT
--)
--AS
--BEGIN TRY
--	SET NOCOUNT ON;
--		SELECT	COR.CourseID,
--				ROO.RoomName,
--				ZON.ZoneName,
--				COR.CourseTitle,
--				COR.CourseDescription,
--				COR.StartDate,
--				COR.EndDate,
--				USR.UserID,
--				COR.CourseTrainer
--		FROM	OrderDetails.Courses AS COR
--		JOIN	Config.Rooms AS ROO
--				ON COR.RoomID = ROO.RoomID
--		JOIN	Config.Zones AS ZON
--				ON COR.ZoneID = ZON.ZoneID
--		JOIN	Person.Users AS USR
--				ON COR.OrganizerID = USR.UserID
--	SET NOCOUNT OFF;
--END TRY
--BEGIN CATCH
--	EXEC Auditing.ErrorLogging
--	RETURN 0;
--END CATCH;
--GO

--End the script.
SET XACT_ABORT OFF;
GO
--EOF