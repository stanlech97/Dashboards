-- Wersja I
with cte as
(
select w.idwykladowcy , dataoceny, count(ocena) as suma_ocen
from wykladowcy as w join oceny as o
on o.idwykladowcy=w.idwykladowcy
group by w.idwykladowcy, dataoceny
having count(ocena)>=5
),cte2 as
(
select *,
iif(DataOceny = dateadd(day,1,lag(DataOceny,1)over(partition by IdWykladowcy order by dataoceny))
and DataOceny = dateadd(day,2,lag(DataOceny,2)over(partition by IdWykladowcy order by dataoceny))
,'tak','nie') as ciaglosc
from cte
)
select distinct w.Nazwisko,w.Imie,w.Nip from cte2 join Wykladowcy as w
on w.IdWykladowcy=cte2.IdWykladowcy
where ciaglosc='tak'

--Wersja II

with cte as
(
select w.idwykladowcy , dataoceny, count(ocena) as suma_ocen
from wykladowcy as w join oceny as o
on o.idwykladowcy=w.idwykladowcy
group by w.idwykladowcy, dataoceny
),cte2 as
(
select *,suma_ocen+lag(suma_ocen,1)over(partition by IdWykladowcy order by dataoceny)+lag(suma_ocen,2)over(partition by IdWykladowcy order by dataoceny) as suma_ocena_z3,
iif(DataOceny = dateadd(day,1,lag(DataOceny,1)over(partition by IdWykladowcy order by dataoceny))
and DataOceny = dateadd(day,2,lag(DataOceny,2)over(partition by IdWykladowcy order by dataoceny))
,'tak','nie') as ciaglosc
from cte
)
select distinct Wykladowcy.Nazwisko, Wykladowcy.Imie, Wykladowcy.Nip from cte2 join Wykladowcy
on cte2.IdWykladowcy=Wykladowcy.IdWykladowcy
where ciaglosc='tak' and suma_ocena_z3>=5