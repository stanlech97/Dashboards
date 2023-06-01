--USE ATS_System;

-- Powiadomienia
--A.	Alert o nowym kandydacie w rekrutacji do osoby odpowiedzialnej za rekrutacje.
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
 
-- enable Database Mail XPs
EXEC sp_configure 'Database Mail XPs', 1
GO
RECONFIGURE
GO
 
-- check if it has been changed
EXEC sp_configure 'Database Mail XPs'
GO
 
-- hide advanced options
EXEC sp_configure 'show advanced options', 0
GO
RECONFIGURE
GO

create TRIGGER NewCandidate
ON Candidates 
AFTER INSERT
AS  
	Declare @fname varchar(255), @body varchar(255)
	SELECT @fname =  FirstName from inserted
	SELECT @body = cast ((select  Firstname + ' zaaplikowa³ na og³oszenie. SprawdŸ co i jak :)' from inserted ) as nvarchar(max))
   EXEC msdb.dbo.sp_send_dbmail  
		@profile_name = 'ATS_System',  
        @recipients = 's8316mb@ms.wwsi.edu.pl',  
        @body = @body,
        @subject = 'New Candidate';   
GO

INSERT INTO Candidates (FirstName, LastName, Phone)
VALUES ('xxx', 'Testowa','133456789123')


-- B.	Wysy³ka maila do kandydata z potwierdzeniem aplikacji na stanowisko pracy.
create TRIGGER NewApplication
ON Application 
AFTER INSERT
AS  
	Declare @body varchar(255)
	SELECT @body = cast ((select 'Hej ' + FirstName + ' ' + LastName + '! Dziêkujemy za aplikacjê. Sprawdzimy Twoje CV i skontaktujemy siê z Tob¹ w przypadku zainteresowania. To bêdzie dobry dzieñ :).' from inserted join Candidates on inserted.CandidateId = Candidates.ID ) as nvarchar(max))
   EXEC msdb.dbo.sp_send_dbmail  
		@profile_name = 'ATS_System',  
        @recipients = 's8316mb@ms.wwsi.edu.pl',  
        @body = @body,  
        @subject = 'Podziêkowanie za aplikacjê';   
GO

INSERT INTO Application ( RecruitmentId, CandidateId, ApplicationDate)
values (3,1,'2022-11-29')

----------------------------- WIDOKI ---------------------------------
-- A.	Widok dla „jobboardów”, które bêd¹ pobieraæ og³oszenia o pracê. Widok powinien zawieraæ wszystkie infomracje o rekrutacji
-- kliencie, zarobkach.


create VIEW Public_Advert AS 
with cte (json) as 
(
select (
	SELECT r.ID, r.Name as Nazwa_Rekrutacji, c.Name as Nazwa_Klienta, pt.Name as Typ_Stanowiska, r.QuantityOfVacancy as Ilosc_Wakatow,
	r.Salary as Wynagrodzenie, r.Responsibilities as Zadania, c.About as O_Firmie, c.Benefits as Benefity, c.City as Miejscowosc
	FOR JSON PATH, INCLUDE_NULL_VALUES, without_array_wrapper
)	FROM Recruitments r
	join Clients c on r.ClientId = c.ID
	join PositionTypes pt on r.PositionTypesId = pt.ID
	--where r.status is null or r.status = 1
)
select * from cte

--B.	Widok dla klientów ze statystykami wyników rekrutacji ( ile kandydatów zaaplikowa³o, ile  
--na jakim etapie jest kandydatów, jakie s¹ osi¹sagne œrednie czasy na etapach przez kandydata na danym etapie w procesie rekrutacyjny,).

CREATE VIEW Client_Stats AS 
WITH CTE_1 (maxdate,ApplicationId)
AS 
(
	select max(ActivityDate)as maxdate, ApplicationId
	from Recruitments_Candidates
	group by ApplicationId
), cte2 (Ilosc_Kandydatow_W_Rekrutacji, worfklowstateid, Etap, recruitmentid)
as 
(
	SELECT count(*) as Ilosc_Kandydatow_W_Rekrutacji ,rc.WorkflowStateId, ws.Name as Etap, rc.RecruitmentId
	FROM Recruitments_Candidates  rc
	join CTE_1 on  ( rc.ApplicationId = CTE_1.ApplicationId and CTE_1.maxdate = rc.ActivityDate)
	join WorkflowStates ws on rc.WorkflowStateId = ws.ID
	GROUP BY WorkflowStateId, ws.Name, rc.RecruitmentId
), cte3 as 
(
	SELECT count(*) as Ilosc_kandydatow_Na_Etapie, c.Name as Klient, r.ID 
	FROM Application a 
	JOIN Recruitments R ON A.RecruitmentId = R.ID
	JOIN Clients C on r.ClientId = c.ID
	group by c.Name,r.ID
) select cte2.recruitmentid as ID_Rekrutacji, Etap, Ilosc_kandydatow_Na_Etapie, Klient 
from cte2
join cte3 on cte2.recruitmentid = cte3.ID


--1.4.2.	Triggery
--A.	Aplikacja kandydata, który ju¿ jest w bazie powoduje scalenie go do jednego profilu kandydata.
create TRIGGER DoubleCandidate
ON Candidates 
AFTER INSERT
AS  
	Declare @fname varchar(255), @lname varchar(255), @phone varchar(12), @counter int
	select @fname = inserted.FirstName, @lname = inserted.LastName, @phone = inserted.Phone, @counter = count(*) 
	from inserted join Candidates c on
	(
		inserted.FirstName = c.FirstName 
		and inserted.LastName = c.LastName
		and inserted.Phone = c.Phone
	)
	group by inserted.FirstName, inserted.LastName, inserted.Phone
	IF @counter >0 
	BEGIN 
		ROLLBACK
		RAISERROR('Kandydat juz istnieje w bazie',1,2)
	END
GO

insert into Candidates (FirstName, LastName, Phone)
values ('Test', 'TEST','123456789012')

--B.	Po osi¹gniêciu oczekiwanej liczby wakatów, rekrutacja jest automatycznie zamykana


create TRIGGER RecruitmentsClosing
ON Recruitments_Candidates 
AFTER INSERT
AS  
	declare @recid int, @positions int, @status int
	Select @status = count(*), @positions = r.QuantityOfVacancy from inserted
	join Recruitments r on inserted.RecruitmentId = r.id 
	where inserted.WorkflowStateId in ( 8, 17)
	group by r.QuantityOfVacancy
	if @status >= @positions
		UPDATE Recruitments set Status = 0
GO


select * from Recruitments where id = 1
select * from Application where CandidateId = 1
insert into Recruitments_Candidates ( RecruitmentId, CandidateId, WorkflowStateId, ActivityDate, ApplicationId)
values ( 1,1,8,'2023-04-01', 582)
select * from Recruitments where id = 1


--1.4.3.	Joby
--A.	Zadanie które bêdzie usuwa³o kandydatów, którzy zostali oznaczeni flag¹ „Do anonimizacji”.
CREATE procedure [dbo].[sp_add_job_quick] 
@job nvarchar(128),
@mycommand nvarchar(max), 
@servername nvarchar(28),
@startdate nvarchar(8),
@starttime nvarchar(8)
as
--Add a job
EXEC dbo.sp_add_job
    @job_name = @job ;
--Add a job step named process step. This step runs the stored procedure
EXEC sp_add_jobstep
    @job_name = @job,
    @step_name = N'process step',
    @subsystem = N'TSQL',
    @command = @mycommand
--Schedule the job at a specified date and time
exec sp_add_jobschedule @job_name = @job,
@name = 'MySchedule',
@freq_type=1,
@active_start_date = @startdate,
@active_start_time = @starttime
-- Add the job to the SQL Server 
EXEC dbo.sp_add_jobserver
    @job_name =  @job,
    @server_name = @servername


exec dbo.sp_add_job_quick 
@job = 'Anonymize',
@mycommand = 'sp_who', -- The T-SQL command to run in the step
@servername = 'serverName', -- SQL Server name. If running locally, you can use @servername=@@Servername
@startdate = '20130829', -- The date August 29th, 2013
@starttime = '160000' -- The time, 16:00:00

--B.	Dla zamkniêtych rekrutacji system bêdzie odrzuca³ kandydatów po 2 tygodniach od ostatniej aktywnoœci na rekrutacji.





------------- PLAN ZAPYTAÑ
SELECT qt.TEXT as SQL_Query, usecounts, size_in_bytes ,
	cacheobjtype, objtype
FROM sys.dm_exec_cached_plans p 
	CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) qt
