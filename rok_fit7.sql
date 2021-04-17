--1
/*
a) Kreirati bazu podataka pod vlastitim brojem indeksa.*/ 

create database "h12"
use "h12"
/* 
--Prilikom kreiranja tabela voditi racuna o medjusobnom odnosu izmedju tabela.
b) Kreirati tabelu radnik koja ce imati sljedecu strukturu:
	-radnikID, cjelobrojna varijabla, primarni kljuc
	-drzavaID, 15 unicode karaktera
	-loginID, 256 unicode karaktera
	-god_rod, cjelobrojna varijabla
	-spol, 1 unicode karakter
	*/ 
	create table radnik 
	( 
	radnikID int primary key, 
	drzavaID nvarchar(15), 
	loginID nvarchar(256), 
	god_rod int, 
	spol nvarchar(1) 
	) 

	/*
c) Kreirati tabelu nabavka koja ce imati sljedecu strukturu:
	-nabavkaID, cjelobrojna varijabla, primarni kljuc
	-status, cjelobrojna varijabla
	-radnikID, cjelobrojna varijabla
	-br_racuna, 15 unicode karaktera
	-naziv_dobavljaca, 50 unicode karaktera
	-kred_rejting, cjelobrojna varijabla
	*/
	create table nabavka 
	( 
		nabavkaID int primary key, 
		status int , 
		radnikID int, 
		br_racuna nvarchar(15), 
		naziv_dobavljaca nvarchar(50), 
		kred_rejting int,
		constraint FK_nabavka_radnik foreign key (radnikID) references radnik(radnikID)
	) 

	

	/* 
c) Kreirati tabelu prodaja koja ce imati sljedecu strukturu:
	-prodajaID, cjelobrojna varijabla, primarni kljuc, inkrementalno punjenje sa pocetnom vrijednoscu 1, samo neparni brojevi
	-prodavacID, cjelobrojna varijabla
	-dtm_isporuke, datumsko-vremenska varijabla
	-vrij_poreza, novcana varijabla
	-ukup_vrij, novcana varijabla
	-online_narudzba, bit varijabla sa ogranicenjem kojim se mogu unijeti samo cifre 0 i 1
	*/
	create table prodaja 
	( 
	prodajaID int primary key identity(1,2), 
	prodavacID int, 
	dtm_isporuke datetime, 
	vrij_poreza money , 
	ukup_vrij money, 
	online_narudzba bit, 
	constraint FK_prodaja_radnik foreign key (prodavacID)  references radnik(radnikID)
	 ) 
	 

	/* 
--2
Import podataka
a) Iz tabele Employee iz šeme HumanResources baze AdventureWorks2017 u tabelu radnik importovati podatke po sljedecem pravilu:
	-BusinessEntityID -> radnikID
	-NationalIDNumber -> drzavaID
	-LoginID -> loginID
	-godina iz kolone BirthDate -> god_rod
	-Gender -> spol

	*/ 
	insert into radnik (radnikID, drzavaID, loginID, god_rod, spol) 
	select BusinessEntityID, NationalIDNumber, LoginID, year(BirthDate), Gender from 
	AdventureWorks2014.HumanResources.Employee
	/*
b) Iz tabela PurchaseOrderHeader i Vendor šeme Purchasing baze AdventureWorks2017 u tabelu nabavka importovati podatke po sljedecem pravilu:
	-PurchaseOrderID -> dobavljanjeID
	-Status -> status
	-EmployeeID -> radnikID
	-AccountNumber -> br_racuna
	-Name -> naziv_dobavljaca
	-CreditRating -> kred_rejting

	*/

	select * from AdventureWorks2014.Purchasing.PurchaseOrderHeader
	select * from AdventureWorks2014.Purchasing.Vendor
	insert into nabavka (nabavkaID, status, radnikID, br_racuna, naziv_dobavljaca, kred_rejting) 
	select POH.PurchaseOrderID, POH.Status, POH.EmployeeID, V.AccountNumber, V.Name, V.CreditRating from AdventureWorks2014.Purchasing.PurchaseOrderHeader as POH
	inner join AdventureWorks2014.Purchasing.Vendor as V
	on POH.VendorID=V.BusinessEntityID
	
	/*
c) Iz tabele SalesOrderHeader šeme Sales baze AdventureWorks2017 u tabelu prodaja importovati podatke po sljedecem pravilu:
	-SalesPersonID -> prodavacID
	-ShipDate -> dtm_isporuke
	-TaxAmt -> vrij_poreza
	-TotalDue -> ukup_vrij
	-OnlineOrderFlag -> online_narudzba
	*/ 
	insert into prodaja (prodavacID, dtm_isporuke, vrij_poreza, ukup_vrij, online_narudzba)
	select SalesPersonID, ShipDate, TaxAmt, TotalDue, OnlineOrderFlag from AdventureWorks2014.Sales.SalesOrderHeader
	/* 
--3
a) U tabelu radnik dodati kolonu st_kat (starosna kategorija), tipa 3 karaktera.
*/ 
alter table radnik
add st_kat nvarchar(3) 
/*
b) Prethodno kreiranu kolonu popuniti po principu:
	starosna kategorija			uslov
	I							osobe do 30 godina starosti (ukljucuje se i 30)
	II							osobe od 31 do 49 godina starosti
	III							osobe preko 50 godina starosti
*/ 
select datediff(year, '1950', getdate()  )
update radnik
set st_kat='1' 
where year(getdate())-god_rod<=30

update radnik set 
st_kat='2'
where year(getdate())-god_rod between 30 and 49 

update radnik set
st_kat='3' 
where year(getdate())-god_rod >50



/* 
c) Neka osoba sa navrsenih 65 godina odlazi u penziju.
Prebrojati koliko radnika ima 10 ili manje godina do penzije.
Rezultat upita iskljucivo treba biti poruka:
'Broj radnika koji imaju 10 ili manje godina do penzije je' nakon cega slijedi prebrojani broj.
Nece se priznati rjesenje koje kao rezultat upita vraca vise kolona.
*/ 
select 'Broj radnika koji imaju 10 ili manji broj godina do penzije je ' +convert(nvarchar, t.br_radnika)
from (select count(*) as br_radnika from radnik where year(getdate())-god_rod between 55 and 64 ) as t

SELECT 'Broj radnika koji imaju 10 ili manje godina do penzije je ' + CONVERT(NVARCHAR, COUNT(*))
FROM radnik
WHERE 65 - (YEAR(CURRENT_TIMESTAMP) - god_rod) BETWEEN 1 AND 10;

/*
--4
a) U tabeli prodaja kreirati kolonu stopa_poreza (10 unicode karaktera)
b) Prethodno kreiranu kolonu popuniti kao kolicnik vrij_poreza i ukup_vrij.
Stopu poreza izraziti kao cijeli broj s oznakom %, pri cemu je potrebno da izmedju brojcane vrijednosti i znaka % bude prazno mjesto.
(Npr: 14.00 %)
*/
alter table prodaja
add stopa_poreza nvarchar(10) 
select convert(decimal(10,2),convert(int, ukup_vrij/vrij_poreza)) from prodaja
update prodaja
set stopa_poreza =convert(nvarchar,convert(decimal(10,2),convert(int, vrij_poreza/ukup_vrij *100))) + ' ' + '%'



UPDATE prodaja
SET stopa_poreza = CONVERT(NVARCHAR, vrij_poreza / ukup_vrij * 100) + ' %';
select * from prodaja
/*
--5
a) Koristeci tabelu nabavka kreirati pogled view_slova sljedece strukture:
	-slova
	-prebrojano, prebrojani broj pojavljivanja slovnih dijelova podatka u koloni br_racuna.
b) Koristeci pogled view_slova odrediti razliku vrijednosti izmedju prebrojanih i srednje vrijednosti kolone.
Rezultat treba da sadrzi kolone slova, prebrojano i razliku.
Sortirati u rastucem redoslijedu prema razlici.
*/
select * from nabavka
select  substring(br_racuna, 0, 3) from nabavka
create view view_slova 
as
select  substring(br_racuna, 0, len(br_racuna)-3) as slova, count(*) as prebrojano  from nabavka 
group by  substring(br_racuna, 0, len(br_racuna)-3)

select slova , prebrojano,(select avg(prebrojano)  from view_slova) - prebrojano as razlika
from view_slova


/*
--6
a) Koristeci tabelu prodaja kreirati pogled view_stopa sljedece strukture:
	-prodajaID
	-stopa_poreza
	-stopa_num, u kojoj ce biti numericka vrijednost stope poreza
b) Koristeci pogled view_stopa, a na osnovu razlike izmedju vrijednosti u koloni stopa_num i srednje vrijednosti stopa poreza
za svaki proizvodID navesti poruku 'manji', odnosno, 'veci'.

*/ 
select * from prodaja 
create view view_stopa 
as
select prodajaID, stopa_poreza, convert(decimal(10,2) , substring(stopa_poreza, 0, charindex(' ' , stopa_poreza))) as stopa_num
from prodaja

drop view view_stopa

select *, 'veci' from view_stopa
where stopa_num >  (select avg(stopa_num) from view_stopa) 
union all
select *, 'manji' from view_stopa
where stopa_num < (select avg(stopa_num) from view_stopa) 


SELECT *,
	CASE
		WHEN stopa_num > (SELECT AVG(stopa_num) FROM view_stopa) THEN 'veci'
		WHEN stopa_num < (SELECT AVG(stopa_num) FROM view_stopa) THEN 'manji'
	END
FROM view_stopa
/* 
--7 
Koristeci pogled view_stopa_poreza kreirati proceduru proc_stopa_poreza tako da je prilikom izvrsavanja moguce unijeti bilo koji broj
parametara (mozemo ostaviti bilo koji parametar bez unijete vrijednosti), pri cemu ce se prebrojati broj zapisa po stopi poreza uz 
uslov da se dohvate samo oni zapisi u kojima je stopa poreza veca od 10%.
Proceduru pokrenuti za sljedece vrijednosti:
	-stopa poreza = 12, 15 i 21
*/
CREATE PROCEDURE proc_stopa_poreza
(
	@prodajaID INT = NULL,
	@stopa_poreza NVARCHAR(10) = NULL,
	@stopa_num FLOAT = NULL
)
AS
BEGIN
	SELECT COUNT(*)
	FROM view_stopa
	WHERE 
		prodajaID = @prodajaID OR
		stopa_poreza = @stopa_poreza OR
		stopa_num = @stopa_num AND stopa_num > 10
END
EXEC proc_stopa_poreza 12
EXEC proc_stopa_poreza 15
EXEC proc_stopa_poreza 21

/*
--8
Kreirati proceduru proc_prodaja kojom ce se izvrsiti promjena vrijednosti u koloni online_narudzba tabele prodaja.
Promjena ce se vrsiti tako sto ce se 0 zamijeniti sa NO, a 1 sa YES.
Pokrenuti proceduru kako bi se izvrsile promjene, a nakon toga onemoguciti da se u koloni unosi bilo kakva druga vrijednost osim NO ili
YES.
*/ 
drop procedure proc_prodaja
create procedure proc_prodaja
as
begin 
alter table prodaja
alter column online_narudzba nvarchar(3)

update prodaja
set online_narudzba='YES'
where online_narudzba<>'NO'


alter table prodaja
add constraint CH_online_narudzba check(online_narudzba='YES' or online_narudzba='NO')
END
exec proc_prodaja
select * from prodaja
/*
--9
a) Nad kolonom god_rod tabele radnik kreirati ogranicenje kojim ce se onemoguciti unos bilo koje godine iz buducnosti kao godina rodjenja.
Testirati funkcionalnost kreiranog ogranicenja navodjenjem koda za insert podataka kojim ce se kao godina rodjenja pokusati unijeti
bilo koja godina iz buducnosti.
b) Nad kolonom drzavaID tabele radnik kreirati ogranicenje kojim ce se ograniciti duzina podatka na 7 znakova.
Ako je prethodno potrebno, izvrsiti prilagodbu kolone, pri cemu nije dozvoljeno prilagodjavati podatke cija duzina iznosi 7 ili manje znakova.
Testirati funkcionalnost kreiranog ogranicenja navodjenjem koda za insert podataka kojim ce se u drzavaID pokusati unijeti podatak duzi 
od 7 znakova bilo koja godina iz buducnosti.
*/
alter table radnik
add constraint CH_god_rod check(god_rod <=year(getdate())) 

insert into radnik (radnikID, drzavaID, loginID, god_rod, spol, st_kat) 
values (151111, 15, 5, 2021, 'M', '2')

select * from radnik 
update radnik 
set drzavaID=left(drzavaID, 7) 
where len(drzavaID)>7
alter table radnik
add constraint CK_drzava_len check (len(drzavaID) <8) 

insert into radnik (radnikID, drzavaID, loginID, god_rod, spol, st_kat) 
values (151111, 15555565, 5, 2021, 'M', '2')
/*
--10
Kreirati backup baze na default lokaciju, obrisati bazu a zatim izvrsiti restore baze. 
Uslov prihvatanja koda je da se moze izvrsiti.


*/ 

backup database "h12" 
to disk='h12.bak'


use master

alter database "h12"
set offline

drop database "h12"

restore database "h12"
from disk='h12.bak'
with replace

drop database _12