/*This script doesnt create the database in MSSQL it only creates the table objects.
Create a Database first before tryin to run this script.*/
USE SoneController;
GO

SET XACT_ABORT ON

--Drops Table if it exist.
IF OBJECT_ID('Events.Orders', 'U')		IS NOT NULL DROP TABLE Events.Orders
IF OBJECT_ID('Events.Course', 'U')		IS NOT NULL DROP TABLE Events.Course
IF OBJECT_ID('Config.Room', 'U')		IS NOT NULL DROP TABLE Config.Room
IF OBJECT_ID('Config.PortConfig', 'U')	IS NOT NULL DROP TABLE Config.PortConfig
IF OBJECT_ID('Config.Sone', 'U')		IS NOT NULL DROP TABLE Config.Sone
IF OBJECT_ID('Assets.Switches', 'U')	IS NOT NULL DROP TABLE Assets.Switches
IF OBJECT_ID('Assets.Models', 'U')		IS NOT NULL DROP TABLE Assets.Models

--Drop Schema if it exist.
IF SCHEMA_ID('Assets')	IS NOT NULL DROP SCHEMA Assets;
IF SCHEMA_ID('Config')	IS NOT NULL DROP SCHEMA Config;
IF SCHEMA_ID('Events')	IS NOT NULL DROP SCHEMA Events;
GO

--Create all schemas
CREATE SCHEMA Assets;
GO
CREATE SCHEMA Config;
GO
CREATE SCHEMA Events;
GO

--Create all tables
--The order the tables are important because the FK reference table needs to exist before adding a FK.
CREATE TABLE Assets.Models
(
	ModelID		INT			NOT NULL,
	SwitchModel	VARCHAR(20)	NOT NULL,
	CONSTRAINT	PK_ModelID
	PRIMARY KEY	(ModelID)
);
GO

CREATE TABLE Assets.Switches
(
    SwitchID	INT			NOT NULL,
    SwitchName	VARCHAR(12)	NOT NULL,
	ModelID		INT			NOT NULL,
	PortSpeed	INT			NOT NULL,
	CONSTRAINT	PK_SwitchID
	PRIMARY KEY	(SwitchID),
	CONSTRAINT	FK_Models_ModelID_Switches
	FOREIGN KEY	(ModelID)
	REFERENCES	Assets.Models
);
GO

CREATE TABLE Config.Sone
(
	SoneID		INT			NOT NULL,
	SoneName	VARCHAR(9)	NOT NULL,
	CONSTRAINT	PK_SoneID
	PRIMARY KEY	(SoneID)
);
GO

CREATE TABLE Config.PortConfig
(
    SwitchID	INT				NOT NULL,
    SoneID		INT				NOT NULL,
	Config		VARCHAR(200)	NOT NULL,
	CONSTRAINT	PK_SwitchID_SoneID
	PRIMARY KEY	(SwitchID, SoneID),
	CONSTRAINT	FK_Switches_SwitchID_PortConfig
	FOREIGN KEY	(SwitchID)
	REFERENCES	Assets.Switches,
	CONSTRAINT	FK_Sone_SoneiD_PortConfig
	FOREIGN KEY	(SoneID)
	REFERENCES	Config.Sone
);
GO

CREATE TABLE Config.Room
(
    RoomID		INT			NOT NULL,
    SwitchID	INT			NOT NULL,
	RoomName	VARCHAR(50)	NOT NULL UNIQUE,
	PortRange	INT			NULL,
	SoneID		INT			NULL,
	VLAN		INT			NULL,
	CONSTRAINT	PK_RoomID
	PRIMARY KEY	(RoomID),
	CONSTRAINT	FK_Switches_SwitchID_Room
	FOREIGN KEY	(SwitchID)
	REFERENCES	Assets.Switches,
	CONSTRAINT	FK_Sone_SoneiD_Room
	FOREIGN KEY	(SoneID)
	REFERENCES	Config.Sone
);
GO

CREATE TABLE Events.Course
(
	CourseID			INT				NOT NULL,
	RoomID				INT				NOT NULL,
	SoneID				INT				NULL,
	CourseTitle			VARCHAR(30)		NOT NULL,
	CourseDescription	VARCHAR(250)	NULL,
	StartDate			DATETIME		NOT NULL,
	EndDate				DATETIME		NOT NULL,
	Organizer			VARCHAR(30)		NULL,
	CourseTrainer		VARCHAR(30)		NULL,
	CONSTRAINT			PK_CourseID
	PRIMARY KEY			(CourseID),
	CONSTRAINT			FK_Room_RoomID_Course
	FOREIGN KEY			(RoomID)
	REFERENCES			Config.Room,
	CONSTRAINT			FK_Sone_SoneiD_Course
	FOREIGN KEY			(SoneID)
	REFERENCES			Config.Sone,
	CONSTRAINT			CK_Start_lt_End
	CHECK				(StartDate < EndDate) --Check for StartDate is less than EndDate
);
GO

CREATE TABLE Events.Orders
(
	OrderID	INT	NOT NULL,
	OrderBy	VARCHAR(30),
	CourseID	INT	NOT NULL,
	OrderDate	DATETIME	NOT NULL,
	CONSTRAINT	PK_OrderID
	PRIMARY KEY	(OrderID),
	CONSTRAINT	FK_Course_CourseID_Orders
	FOREIGN KEY	(CourseID)
	REFERENCES	Events.Course
);
GO

SET XACT_ABORT OFF;
GO