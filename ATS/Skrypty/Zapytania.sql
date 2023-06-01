USE ATS_System;

--Zapytanie A.	Wska� kandydat�w, kt�rzy zaaplikowali na rodzaj stanowiska �specjalista� w ci�gu zadanego okresu.

SELECT distinct C.ID, C.FirstName, C.LastName 
FROM Application A 
JOIN Candidates C on A.CandidateId = C.ID
where A.RecruitmentId in ( SELECT ID FROM Recruitments where PositionTypesId = 3 )

--B.	Wyka� ile os�b aplikowa�o na stanowiska wg rodzaju stanowisk

SELECT pt.Name, count(*) as ile FROM Application a 
join Recruitments r on a.RecruitmentId = r.id 
join PositionTypes pt on r.PositionTypesId = pt.id
group by pt.Name

--C.	Wska� jaki jest �redni czas postoju kandydata na etapie �nowy� dla ka�dego klienta.

SELECT  avg(DATEDIFF(dd, rc.ActivityDate,rc2.ActivityDate)), c.Name
FROM Recruitments_Candidates RC
JOIN Recruitments_Candidates RC2 ON ( RC.ApplicationId = RC2.ApplicationId AND RC2.WorkflowStateId = 2)
JOIN Recruitments r on rc.RecruitmentId = r.ID
join Clients c on r.ClientId = c.ID
WHERE RC.WorkflowStateId = 1 
group by c.Name
--AND  RC.ApplicationId = 197


--E.	Ile sumarycznie kandydat�w zaaplikowa�o na oferty pracy wg ka�dego klienta.
SELECT count(*), c.Name  FROM Application a
join Recruitments r on a.RecruitmentId = r.id 
join Clients c on r.ClientId = c.ID
group by c.Name

--F.	Wskaz kandydat�w, kt�rzy aplikowali na wi�cej ni� 3 oferty pracy.
select CandidateId, c.firstname, c.lastname
from Application a 
join Candidates c on a.CandidateId = c.id
group by CandidateId, c.firstname, c.lastname
having count(*) > 3


--G.	Wska� klienta, w kt�rym dosz�o do najwi�cej zatrudnieni.
select count(*) as ile, c.Name
from Recruitments_Candidates rc 
join Recruitments r on rc.RecruitmentId = r.ID
join Clients c on r.ClientId = c.ID
where rc.WorkflowStateId in (8,17)
group by c.name 
order by ile desc

--H.	Wskaz kandydat�w kt�rego czas pomi�dzy etapem nowy a zatrudniony jest najwi�kszy oraz najmniejszy 
SELECT  DATEDIFF(dd, rc.ActivityDate,rc2.ActivityDate) as czas_rekrutacji, rc.CandidateId
FROM Recruitments_Candidates RC
JOIN Recruitments_Candidates RC2 ON ( RC.ApplicationId = RC2.ApplicationId AND RC2.WorkflowStateId = 8)
WHERE RC.WorkflowStateId = 1

--I.	Ile procent kandydat�w z ca�ej ilo�ci bazy kandydat�w znalaz�o zatrudnienie.
with cte as 
(
	SELECT COUNT(*) as allc, 1 as a FROM Candidates
), cte2 as 
(
	select count(distinct CandidateId) as hired, 1 as b from Recruitments_Candidates where WorkflowStateId in (18,8)
)
select (cast(hired as float) / cast(allc as float) ) * 100 as procent from cte join cte2 on cte.a = cte2.b



--J.	Wska� top 10 miast, z kt�rych aplikuj� kandydaci

select top 10 with ties count(distinct candidateid) as ile , c.city
from Application a 
join Candidates c on a.CandidateId = c.id
group by c.city
order by ile desc


--K.	Poka� procentowo jak rozk�ada si� udzia� domen pocztowych w adresach mailowych kandydat�w.
select count( distinct Id) as ile, (cast(count( distinct Id) as float) / cast(1000 as float) ) * 100 as procent
, SUBSTRING (Email, CHARINDEX( '@', Email) + 1, LEN(Email)) AS Domena
from Candidates
group by SUBSTRING (Email, CHARINDEX( '@', Email) + 1, LEN(Email))
order by ile desc



------------------------------


-- sprawdzenie informacji o istniej�cych planach w cache
SELECT qt.TEXT as SQL_Query, usecounts, size_in_bytes ,
	cacheobjtype, objtype
FROM sys.dm_exec_cached_plans p 
	CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) qt
WHERE qt.TEXT not like '%dm_exec%'


