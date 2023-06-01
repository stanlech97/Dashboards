with best30days as (
select top(30) with ties DataWizyty, sum(Oplata) as suma_oplat from wizyty
where datawizyty between '2021-01-01' and '2021-12-31'
group by DataWizyty
order by suma_oplat desc
)
select top(2) with ties Lekarze.Nazwisko, lekarze.Imie, count(Wizyty.IdWizyty) as liczba_wizyt, sum(Wizyty.Oplata) as suma_oplat from wizyty
join best30days on Wizyty.DataWizyty = best30days.DataWizyty
join lekarze on Wizyty.IdLekarza = Lekarze.IdLekarza
group by Lekarze.Nazwisko, lekarze.Imie
order by suma_oplat desc