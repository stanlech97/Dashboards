--USE [2023_MZ202_ZSBD_8316];
USE ATS_SYSTEM

CREATE TABLE PositionTypes (
    ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
    Name varchar(255) not null
);

CREATE TABLE Files (
    ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
    FileName varchar(255)
);


CREATE TABLE Candidates (
    ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
    FirstName varchar(255) NOT NULL,
    LastName varchar(255) NOT NULL,
	Phone varchar(12) NOT NULL,
    Email varchar(255),
    City varchar(255),
	Anonymize bit
);

CREATE TABLE Files_Candidates (
	ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
    FileId int NOT NULL,
	CandidateId int NOT NULL,
	CONSTRAINT FK_FilesCandidates_File FOREIGN KEY (FileId) REFERENCES Files(ID),
	CONSTRAINT FK_FilesCandidates_Candidates FOREIGN KEY (CandidateId) REFERENCES Candidates(ID)
);


CREATE TABLE Workflows (
    ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
    Name varchar(255) NOT NULL,
	CreatedDate date,
	DisabledDate date,
);

CREATE TABLE WorkflowStates (
    ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
    Name varchar(255) NOT NULL,
	Element int not null,
	CreatedDate date not null,
	DisabledDate date,
	WorkflowId int not null,
	CONSTRAINT WorkflowStates_Workflows FOREIGN KEY (WorkflowId) REFERENCES Workflows(ID)
);

CREATE TABLE Clients (
    ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
    Name varchar(255) NOT NULL,
	NIP varchar(10) NOT NULL,
	City varchar(255),
	Benefits varchar(max),
	About varchar(max)
);


CREATE TABLE Recruitments (
    ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
    Name varchar(255) NOT NULL,
	WorkflowId int NOT NULL,
	ClientId int NOT NULL,
	PositionTypesId int not null,
	QuantityOfVacancy int not null,
	Salary int not null,
	Responsibilities varchar(max),
	Status bit null,
	CONSTRAINT Recruitments_Workflow FOREIGN KEY (WorkflowId) REFERENCES Workflows(ID),
	CONSTRAINT Recruitments_Clients FOREIGN KEY (ClientId) REFERENCES Clients(ID),
	CONSTRAINT Recruitments_PositionTypes FOREIGN KEY (PositionTypesId) REFERENCES PositionTypes(ID)
);

CREATE TABLE Application (
    ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
	RecruitmentId int NOT NULL,
	CandidateId int NOT NULL,
	ApplicationDate date not null,
	Quantity int,
	CONSTRAINT FK_Application_Recruitment FOREIGN KEY (RecruitmentId) REFERENCES Recruitments(ID),
	CONSTRAINT FK_Application_Candidate FOREIGN KEY (CandidateId) REFERENCES Candidates(ID),
);

CREATE TABLE Recruitments_Candidates (
    ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
	RecruitmentId int NOT NULL,
	CandidateId int NOT NULL,
	WorkflowStateId int not null,
	ActivityDate date not null,
	ApplicationId int not null,
	CONSTRAINT FK_RecruitmentsCandidates_Recruitment FOREIGN KEY (RecruitmentId) REFERENCES Recruitments(ID),
	CONSTRAINT FK_RecruitmentsCandidates_Candidate FOREIGN KEY (CandidateId) REFERENCES Candidates(ID),
	CONSTRAINT FK_RecruitmentsCandidates_WokrflowState FOREIGN KEY (WorkflowStateId) REFERENCES WorkflowStates(ID),
	CONSTRAINT FK_RecruitmentsCandidates_Application FOREIGN KEY (ApplicationId) REFERENCES Application(ID),
);





