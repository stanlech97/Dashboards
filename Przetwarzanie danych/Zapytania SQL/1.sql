declare @StartDate date = '2020-05-01', @EndDate date= '2020-05-31';
with ListDates(AllDates) as
(    select @StartDate as date
    union all
    select dateadd(day,1,AllDates)
    from ListDates 
    where AllDates < @EndDate
)

select ListDates.AllDates, count(IdWizyty)  as ilosc_wizyt, coalesce(SUM(Oplata),0) as suma_oplat, COUNT(distinct IdLekarza) as ilosc_lekarzy from Wizyty right outer join ListDates on Wizyty.DataWizyty = ListDates.AllDates
group by ListDates.AllDates