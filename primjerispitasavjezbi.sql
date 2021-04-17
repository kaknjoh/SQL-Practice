﻿	--1
/*
a) Kreirati bazu podataka pod vlastitim brojem indeksa.
*/


create database test


use test
/*
Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
b) Kreirati tabelu radnik koja će imati sljedeću strukturu:
	radnikID, cjelobrojna varijabla, primarni ključ
	drzavaID, 15 unicode karaktera
	loginID, 30 unicode karaktera
	sati_god_odmora, cjelobrojna varijabla
	sati_bolovanja, cjelobrojna varijabla
*/

create table radnik  (
radnikID int primary key, 
drzavaID nvarchar(15),
loginID nvarchar(30),
sati_god_odmora int,
sati_bolovanja int
)

create procedure proc_radnik_unos (
@radnikID int =null ,
@drzavaID nvarchar(25)=null, 
@loginID nvarchar(25)=null, 
@sati_god_odmora int =null,
@sati_bolovanja int=null)
as
begin 

insert into radnik values (
@radnikID, @drzavaID, @loginID, @sati_god_odmora,@sati_bolovanja)

end 

exec proc_radnik_unos @radnikID=1 , @drzavaID='Kanada', @loginID='17a10', @sati_god_odmora=12,@sati_bolovanja=10
select * from radnik

/*
c) Kreirati tabelu kupovina koja će imati sljedeću strukturu:
	kupovinaID, cjelobrojna varijabla, primarni ključ
	status, cjelobrojna varijabla
	radnikID, cjelobrojna varijabla
	br_racuna, 15 unicode karaktera
	naziv_dobavljaca, 50 unicode karaktera
	kred_rejting, cjelobrojna varijabla
*/


create table kupovina (
kupovinaID int primary key, 
status int , 
radnikID int ,
br_racuna int ,
naziv_dobavljaca nvarchar(50), 
kred_rejting int, 
constraint FK_kupovina_radnik foreign key (radnikID) references radnik(radnikID)
)


alter table kupovina 
alter column br_racuna nvarchar(15)


/*
d) Kreirati tabelu prodaja koja će imati sljedeću strukturu:
	prodavacID, cjelobrojna varijabla, primarni ključ
	prod_kvota, novčana varijabla
	bonus, novčana varijabla
	proslogod_prodaja, novčana varijabla
	naziv_terit, 50 unicode karaktera
*/

create table prodaja 
(
prodavacID int primary key , 
prod_kvota money ,
bonus money ,
proslogod_prodaja money, 
naziv_terit nvarchar(50) 
constraint FK_prodaja_radnik foreign key (prodavacID) references radnik(radnikID)
)





/*
a) Iz tabela humanresources.employee baze AdventureWorks2014 u tabelu radnik importovati podatke po sljedećem pravilu:
	BusinessEntityID -> radnikID
	NationalIDNumber -> drzavaID
	LoginID -> loginID
	VacationHours -> sati_god_odmora
	SickLeaveHours -> sati_bolovanja
*/
insert into radnik 
select BusinessEntityID, NationalIDNumber, LoginID,VacationHours,SickLeaveHours 
from AdventureWorks2014.HumanResources.Employee




/*
b) Iz tabela purchasing.purchaseorderheader i purchasing.vendor baze AdventureWorks2014 u tabelu kupovina importovati podatke po sljedećem pravilu:
	PurchaseOrderID -> kupovinaID
	Status -> status
	EmployeeID -> radnikID
	AccountNumber -> br_racuna
	Name -> naziv_dobavljaca
	CreditRating -> kred_rejting
*/
insert into kupovina
select	poh.PurchaseOrderID, poh.Status, poh.EmployeeID,
		v.AccountNumber, v.Name, v.CreditRating
from	AdventureWorks2014.Purchasing.PurchaseOrderHeader poh 
		join AdventureWorks2014.Purchasing.Vendor v
on		v.BusinessEntityID = poh.VendorID





/*
c) Iz tabela sales.salesperson i sales.salesterritory baze AdventureWorks2014 u tabelu prodaja importovati podatke po sljedećem pravilu:
	BusinessEntityID -> prodavacID
	SalesQuota -> prod_kvota
	Bonus -> bonus
	SalesLastYear -> proslogod_prodaja
	Name -> naziv_terit
*/
insert into prodaja 
select SP.BusinessEntityID, SP.SalesQuota, SP.Bonus, ST.SalesLastYear, ST.Name
from AdventureWorks2014.Sales.SalesPerson as SP 
inner join AdventureWorks2014.Sales.SalesTerritory as ST
on ST.TerritoryID=SP.TerritoryID



select * from  AdventureWorks2014.Sales.SalesTerritory
select * from AdventureWorks2014.Sales.SalesPerson




--3.
/*
Iz tabela radnik i kupovina kreirati pogled view_drzavaID koji će imati sljedeću strukturu: 
	- naziv dobavljača,
	- drzavaID
Uslov je da u pogledu budu samo oni zapisi čiji ID države počinje ciframa u rasponu od 40 do 49, te da se kombinacije dobavljača i drzaveID ne ponavljaju.
*/

create view rad_kup  as 
( 
select distinct naziv_dobavljaca , drzavaID 
from radnik r join kupovina k 
on r.radnikID=k.radnikID
where left(r.drzavaID, 2) between 40 and 49 
) 



--4.
/*
Koristeći tabele radnik i prodaja kreirati pogled view_klase_prihoda koji će sadržavati ID radnika, ID države, količnik prošlogodišnje prodaje i prodajne kvote, 
te oznaku klase koje će biti formirane prema pravilu: 
	- <10			- klasa 1 
	- >=10 i <20	- klasa 2 
	- >=20 i <30	- klasa 3
*/
create view view_klase_prihoda as ( 
select r.radnikID, r.drzavaID, 'klasa 1' as klasa 
from radnik r 
inner join 
prodaja p 
on r.radnikID=p.prodavacID
where p.proslogod_prodaja/p.prod_kvota <10
union 

select r.radnikID, r.drzavaID, 'klasa 2' as klasa 
from radnik r 
inner join 
prodaja p 
on r.radnikID=p.prodavacID
where p.proslogod_prodaja/p.prod_kvota >=10 and p.proslogod_prodaja/p.prod_kvota <20
union 

select r.radnikID, r.drzavaID, 'klasa 3' as klasa 
from radnik r 
inner join 
prodaja p 
on r.radnikID=p.prodavacID
where p.proslogod_prodaja/p.prod_kvota >=20 and p.proslogod_prodaja/p.prod_kvota<30
)



--5.
/*
Koristeći pogled view_klase_prihoda kreirati proceduru proc_klase_prihoda koja će prebrojati broj klasa. 
Procedura treba da sadrži naziv klase i ukupan broj pojavljivanja u pogledu view_klase_prihoda. Sortirati prema broju pojavljivanja u opadajućem redoslijedu.
*/
create procedure proc_klase_prihoda 
as 
begin 
( 
select klasa, count(klasa)
from view_klase_prihoda
group by klasa 
) end 


--6.
/*
Koristeći tabele radnik i kupovina kreirati pogled view_kred_rejting koji će sadržavati kolone drzavaID, kreditni rejting i prebrojani broj pojavljivanja kreditnog rejtinga po ID države.
*/

create view view_kred_rejting 
as 
(
select r.drzavaID, k.kred_rejting, count(*) as prebrojano 
from radnik r 
inner join kupovina k
on r.radnikID=k.radnikID
group by r.drzavaID, k.kred_rejting
) 

--7.
/*
Koristeći pogled view_kred_rejting kreirati proceduru proc_kred_rejting koja će davati informaciju o najvećem prebrojanom broju pojavljivanja kreditnog rejtinga. 
Procedura treba da sadrži oznaku kreditnog rejtinga i najveći broj pojavljivanja za taj kreditni rejting. Proceduru pokrenuti za sve kreditne rejtinge (1, 2, 3, 4, 5). 
*/
create procedure proc_kred_rejting 
 (
			@broj_pojavljivanja int =null) 
as
begin 

select kred_rejting , max(prebrojano) 
from view_kred_rejting 
WHERE kred_rejting=@broj_pojavljivanja 
group by kred_rejting

end

--8.
/*
Kreirati tabelu radnik_nova i u nju prebaciti sve zapise iz tabele radnik. Nakon toga, svim radnicima u tabeli radnik_nova čije se ime u koloni loginID sastoji od 3 i manje slova,
 loginID promijeniti u slučajno generisani niz znakova.
*/


select * 
into radnik_nova
from radnik 
select  len(loginID)-1  - charindex('\',loginID)  from radnik
where 

update radnik_nova
set loginID=left(newid(),30)
where len(loginID)-1  - charindex('\',loginID) <=3




--9.
/*
a) Kreirati pogled view_sume koji će sadržavati sumu sati godišnjeg odmora i sumu sati bolovanja za radnike iz tabele radnik_nova kojima je loginID promijenjen u slučajno generisani niz znakova 
b) Izračunati odnos (količnik) sume bolovanja i sume godišnjeg odmora. Ako je odnos veći od 0.5 dati poruku 'Suma bolovanja je prevelika. Odnos iznosi: ______'. U suprotnom dati poruku 'Odnos je prihvaljiv i iznosi: _____'
*/

create view view_sume 
as
(
select radnikID, SUM(sati_god_odmora) as god_odmor, sum(sati_bolovanja) as bolovanje
from radnik_nova
where len(loginID)=30
group by radnikID
) 

create view view_odnos 
as (
select 'Suma bolovanja je prevelika. Odnos iznosi: '+ cast (convert(real,bolovanje)/god_odmor as nvarchar )
from view_sume
where  convert(real,bolovanje)/god_odmor >0.5
) 


--10.
/*
a) Kreirati backup baze na default lokaciju.
b) Obrisati bazu.
c) Napraviti restore baze.
*/
use h_12

backup database h_12
to disk='h_12.bak'

use master

alter database h_12 
set offline
drop database h_12


restore database h_12
from disk='h_12'
with replace 



/*
Kreirati bazu podataka BrojIndeksa sa sljedećim parametrima:
a) primarni i sekundarni data fajl:
- veličina: 		5 MB
- maksimalna veličina: 	neograničena
- postotak rasta:	10%
b) log fajl
- veličina: 		2 MB
- maksimalna veličina: 	neograničena
- postotak rasta:	5%
Svi fajlovi trebaju biti smješteni u folder c:\BP2\data\ koji je potrebno prethodno kreirati.
*/


create database br_indeksa ON PRIMARY (
NAME='br_indeksa', 
FILENAME='c:\BP2\data\br_indeksa.mdf', 
SIZE=5 MB, 
MAXSIZE=UNLIMITED, 
FILEGROWTH=10%
) ,
(
NAME='br_indeksa_sek', 
FILENAME='c:\BP2\data\br_indeksa_sek.ndf', 
SIZE=5 MB, 
MAXSIZE=UNLIMITED, 
FILEGROWTH=10%
)
LOG ON ( 
NAME='br_indeksa_log', 
FILENAME='c:\BP2\log\br_indeksa_log.ldf', 
SIZE=2 MB, 
MAXSIZE=UNLIMITED, 
FILEGROWTH=5%

) 




create database harun on primary (
NAME='harun',
FILENAME='c:\BP2\data\harun.mdf',
SIZE=5 MB,
MAXSIZE= UNLIMITED, 
GROWTH= 10%), 
(
NAME='harun_sek',
FILENAME='c:\BP2\data\harun_sek.ndf',
SIZE=5 MB,
MAXSIZE= UNLIMITED, 
GROWTH= 10%)

LOG ON ( 
NAME='harun_log',
FILENAME='c:\BP2\log\harun_log.ldf',
SIZE=5 MB,
MAXSIZE= UNLIMITED, 
GROWTH= 5%)



















use radna 

alter table Product 
add constraint PR_check_LP check (ListPrice>=0) 


alter table WorkOrder
add constraint WO_check check(EndDate >=StartDate) 


/*
Kreirati proceduru koja će izmijeniti podatke u koloni LocationID tabele WorkOrderRouting po sljedećem principu:
	10 -> A
	20 -> B
	30 -> C
	40 -> D
	45 -> E
	50 -> F
	60 -> G
*/

select * from WorkOrderRouting

create procedure proc_chage_loc
begin as
( 
update WorkOrderRouting
set LocationID='A'
where LocationID=10

) end