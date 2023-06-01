--USE [2023_MZ202_ZSBD_8316];
 USE ATS_SYSTEM;

INSERT INTO PositionTypes (Name) VALUES
('dyrektor'),
('asystent'),
('specjalista'),
('pracownik fizyczny'),
('pracownik biurowy'),
('inne');


INSERT INTO Workflows (Name, CreatedDate)
VALUES 
('Standard','01-01-2023'),
('Temp','03-01-2023');


INSERT INTO WorkflowStates (Name, Element, CreatedDate, WorkflowId )
VALUES 
('Nowy','1', '01-03-2023',1),
('Rozmowa telefoniczna ','2', '01-01-2023',1),
('Spotkanie rekrutacyjne','3', '01-01-2023',1),
('Test','4', '01-01-2023',1),
('Akceptacja klienta','5', '01-01-2023',1),
('Akceptacja kandydata','6', '01-01-2023',1),
('Weryfikacja dokumentów + badania lekarskie','7', '01-01-2023',1),
('Zatrudnienie','8', '01-01-2023',1),
('Odrzucenie','9', '01-01-2023',1),
('Poczekalnia','10', '01-01-2023',1),
('Nowy','1', '01-01-2023',2),
('Rozmowa telefoniczna ','2', '03-01-2023',2),
('Spotkanie rekrutacyjne','3', '03-01-2023',2),
('Akceptacja klienta','4', '03-01-2023',2),
('Akceptacja kandydata','5', '03-01-2023',2),
('Weryfikacja dokumentów + badania lekarskie','6', '03-01-2023',2),
('Zatrudnienie','7', '03-01-2023',2),
('Odrzucenie','8', '03-01-2023',2),
('Poczekalnia','9', '03-01-2023',2)
;


BULK INSERT Files
FROM 'D:\magisterka\dane\file.csv'
WITH
(
		FORMAT = 'CSV',
        FIRSTROW=2,
		DATAFILETYPE = 'char',
		FIELDTERMINATOR = ';', 
        ROWTERMINATOR = '\n'
)
GO

BULK INSERT Candidates
FROM 'D:\magisterka\dane\candidate.csv'
WITH
(
		FORMAT = 'CSV',
        FIRSTROW=2,
		DATAFILETYPE = 'char',
		FIELDTERMINATOR = ';', 
        ROWTERMINATOR = '\n',
		CODEPAGE='ACP'
)
GO


BULK INSERT Clients
FROM 'D:\magisterka\dane\clients.csv'
WITH
(
		FORMAT = 'CSV',
        FIRSTROW=2,
		DATAFILETYPE = 'char',
		FIELDTERMINATOR = ';', 
        ROWTERMINATOR = '\n',
		CODEPAGE='ACP'
)
GO


BULK INSERT Files_Candidates
FROM 'D:\magisterka\dane\files_candidates.csv'
WITH
(
		FORMAT = 'CSV',
        FIRSTROW=2,
		DATAFILETYPE = 'char',
		FIELDTERMINATOR = ';', 
        ROWTERMINATOR = '\n',
		CODEPAGE='ACP'
)
GO


BULK INSERT Recruitments
FROM 'D:\magisterka\dane\recruitments.csv'
WITH
(
		FORMAT = 'CSV',
        FIRSTROW=2,
		DATAFILETYPE = 'char',
		FIELDTERMINATOR = ';', 
        ROWTERMINATOR = '\n',
		CODEPAGE='ACP'
)
GO

BULK INSERT Application
FROM 'D:\magisterka\dane\application.csv'
WITH
(
		FORMAT = 'CSV',
        FIRSTROW=2,
		DATAFILETYPE = 'char',
		FIELDTERMINATOR = ';', 
        ROWTERMINATOR = '\n',
		CODEPAGE='ACP'
)
GO

-- WORFKLOW1 
-- state1
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT RecruitmentId,CandidateId,Id,'1' as WorfkflowStateId ,ApplicationDate  FROM Application WHERE RecruitmentId IN (SELECT ID FROM Recruitments WHERE WorkflowId = 1);

--state 2
-- 1005 candidate => 800 next, 100 new, 95 reject, 10 WAITING LIST
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 800 RecruitmentId,CandidateId,ApplicationId, 2 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 1


INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 95 RecruitmentId,CandidateId,ApplicationId, 9 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 1 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId = 2)

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 10  RecruitmentId,CandidateId,ApplicationId, 10 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 1 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId in(2,9))


--state 3
-- 800 candidate => 500 next,  100 reject, 50 WAITING LIST,  150 s2,
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 500 RecruitmentId,CandidateId,ApplicationId, 3 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 2

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 100 RecruitmentId,CandidateId,ApplicationId, 9 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 2 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId =3)

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 50  RecruitmentId,CandidateId,ApplicationId, 10 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 2 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId in(3,9));


--state 4
-- 500 candidate => 460 next,  10 reject,  30 s3,
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 460 RecruitmentId,CandidateId,ApplicationId, 4 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 3

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 10 RecruitmentId,CandidateId,ApplicationId, 9 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 3 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId =4)


--state 5
-- 460 candidate => 300 next,  120 reject, 30 WAITING LIST,  10  s4,
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 300 RecruitmentId,CandidateId,ApplicationId, 5 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 4

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 120 RecruitmentId,CandidateId,ApplicationId, 9 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 4 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId =5)

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 30  RecruitmentId,CandidateId,ApplicationId, 10 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 4 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId in(5,9));


--state 6 AKC KANDYDATA
-- 300 candidate => 150 next,  70 reject, 60 WAITING LIST,  20  s5,
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 150 RecruitmentId,CandidateId,ApplicationId, 6 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 5

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 70 RecruitmentId,CandidateId,ApplicationId, 9 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 5 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId =6)

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 60  RecruitmentId,CandidateId,ApplicationId, 10 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 5 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId in(6,9));


--state 7 WERYFIKACJA KANDYDATA
-- 150 candidate => 135 next,  0 reject, 0 WAITING LIST,  15  s5,
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 135 RecruitmentId,CandidateId,ApplicationId, 7 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 6


--state 8 zatrudnienie
-- 135 candidate => 115 next,  5 reject, 15  s7,
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 115 RecruitmentId,CandidateId,ApplicationId, 8 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 7

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 5 RecruitmentId,CandidateId,ApplicationId, 9 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 7 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId =8)



-- WORFKLOW2
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT RecruitmentId,CandidateId,Id,'11' as WorfkflowStateId ,ApplicationDate  FROM Application WHERE RecruitmentId IN (SELECT ID FROM Recruitments WHERE WorkflowId = 2);

--state 2
-- 995 candidate => 800 next, 95 reject 100 new,
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 800 RecruitmentId,CandidateId,ApplicationId, 12 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 11

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 95 RecruitmentId,CandidateId,ApplicationId, 18 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 11 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId = 12)


--state 3
-- 800 candidate => 600 next, 80 reject , 20 waiting list , 100 s2,
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 600 RecruitmentId,CandidateId,ApplicationId, 13 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 12

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 80 RecruitmentId,CandidateId,ApplicationId, 18 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 12 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId = 13)

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 20  RecruitmentId,CandidateId,ApplicationId, 19 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 12 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId in(13,18,19))

--state 4
-- 600 candidate => 400 next, 150 reject , 20 waiting list , 100 s2,
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 400 RecruitmentId,CandidateId,ApplicationId, 14 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 13

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 150 RecruitmentId,CandidateId,ApplicationId, 18 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 13 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId = 14)

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 20  RecruitmentId,CandidateId,ApplicationId, 19 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 13 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId in(14,18,19))

--state 5
-- 400 candidate => 200 next, 50 reject , 50 waiting list , 100 s5,
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 200 RecruitmentId,CandidateId,ApplicationId, 15 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 14

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 50 RecruitmentId,CandidateId,ApplicationId, 18 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 14 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId = 15)

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 50  RecruitmentId,CandidateId,ApplicationId, 19 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 14 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId in(15,18,19))


--state 6
-- 200 candidate => 160 next, 10 reject , 30 s6,
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 160 RecruitmentId,CandidateId,ApplicationId, 16 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 15

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 10 RecruitmentId,CandidateId,ApplicationId, 18 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 15 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId = 16)



--state 7
-- 160 candidate => 100 next, 10 reject , 50 s6,
INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT TOP 100 RecruitmentId,CandidateId,ApplicationId, 17 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates where WorkflowStateId = 16

INSERT INTO Recruitments_Candidates(RecruitmentId,CandidateId,ApplicationId, WorkflowStateId , ActivityDate)
SELECT top 10 RecruitmentId,CandidateId,ApplicationId, 18 , DATEADD(DAY, ABS(CHECKSUM(NewId())) % 9+1, ActivityDate)
FROM Recruitments_Candidates 
where WorkflowStateId = 16 and ApplicationId not in ( select ApplicationId from Recruitments_Candidates where WorkflowStateId = 17)


WITH CTE_1 (maxdate,ApplicationId)
AS 
(
	select max(ActivityDate)as maxdate, ApplicationId
	from Recruitments_Candidates
	group by ApplicationId
)
SELECT count(*) as ile ,rc.WorkflowStateId
FROM Recruitments_Candidates  rc
join CTE_1 on  ( rc.ApplicationId = CTE_1.ApplicationId and CTE_1.maxdate = rc.ActivityDate)
GROUP BY WorkflowStateId
order by WorkflowStateId

--DROP TABLE Recruitments_Candidates;
--DROP TABLE Files_Candidates;
--DROP TABLE Application;
--DROP TABLE Candidates
--DROP TABLE FILES;
--DROP TABLE Recruitments;
--DROP TABLE WorkflowStates;
--DROP TABLE Workflows;
--DROP TABLE Clients;
--DROP TABLE PositionTypes;
