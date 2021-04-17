﻿----------------------------
--1.
----------------------------
/*
Kreirati bazu pod vlastitim brojem indeksa
*/

create database _12 

use _12


-----------------------------------------------------------------------
--Prilikom kreiranja tabela voditi računa o njihovom međusobnom odnosu.
-----------------------------------------------------------------------
/*
a) 
Kreirati tabelu dobavljac sljedeće strukture:
	- dobavljac_id - cjelobrojna vrijednost, primarni ključ
	- dobavljac_br_rac - 50 unicode karaktera
	- naziv_dobavljaca - 50 unicode karaktera
	- kred_rejting - cjelobrojna vrijednost
*/
create table dobavljac
(
dobavljac_id int primary key, 
dobavljac_br_rac nvarchar(50), 
naziv_dobavljaca nvarchar(50), 
kred_rejting int

)


/*
b)
Kreirati tabelu narudzba sljedeće strukture:
	- narudzba_detalj_id - cjelobrojna vrijednost, primarni ključ
	- narudzba_id - cjelobrojna vrijednost
	- dobavljac_id - cjelobrojna vrijednost
	- dtm_narudzbe - datumska vrijednost
	- naruc_kolicina - cjelobrojna vrijednost
	- cijena_proizvoda - novčana vrijednost
*/
create table narudzba(
 narudzba_detalj_id int primary key, 
 narudzba_id int , 
 dobavljac_id int, 
 dtm_narudzbe date, 
 naruc_kolicina int, 
 cijena_proizvoda money, 
 constraint FK_narudzba_dobavljac foreign key (dobavljac_id) references dobavljac(dobavljac_id)
 )
/*
c)
Kreirati tabelu dobavljac_proizvod sljedeće strukture:
	- proizvod_id cjelobrojna vrijednost, primarni ključ
	- dobavljac_id cjelobrojna vrijednost, primarni ključ
	- proiz_naziv 50 unicode karaktera
	- serij_oznaka_proiz 50 unicode karaktera
	- razlika_min_max cjelobrojna vrijednost
	- razlika_max_narudzba cjelobrojna vrijednost
*/
--10 bodova
create table dobavljac_proizvod(
proizvod_id int , 
dobavljac_id int, 
proiz_naziv nvarchar(50), 
serij_oznaka_proiz nvarchar(50), 
razlika_min_max int, 
razlika_max_narudzba int
constraint PK_dobavljac_proizvod primary key (proizvod_id, dobavljac_id),
constraint FK_dobavljac_proizvod foreign key (dobavljac_id) references dobavljac(dobavljac_id)
)

----------------------------
--2. Insert podataka
----------------------------
/*
a) 
U tabelu dobavljac izvršiti insert podataka iz tabele Purchasing.Vendor prema sljedećoj strukturi:
	BusinessEntityID -> dobavljac_id 
	AccountNumber -> dobavljac_br_rac 
	Name -> naziv_dobavljaca
	CreditRating -> kred_rejting
*/
insert into dobavljac 
select PV.BusinessEntityID, PV.AccountNumber, PV.Name, PV.CreditRating 
from AdventureWorks2014.Purchasing.Vendor as PV
/*
b) 
U tabelu narudzba izvršiti insert podataka iz tabela Purchasing.PurchaseOrderHeader i Purchasing.PurchaseOrderDetail prema sljedećoj strukturi:
	PurchaseOrderID -> narudzba_id
	PurchaseOrderDetailID -> narudzba_detalj_id
	VendorID -> dobavljac_id 
	OrderDate -> dtm_narudzbe 
	OrderQty -> naruc_kolicina 
	UnitPrice -> cijena_proizvoda
*/
select * from AdventureWorks2014.Purchasing.PurchaseOrderHeader
select * from AdventureWorks2014.Purchasing.PurchaseOrderDetail
insert into narudzba
select pod.PurchaseOrderDetailID, poh.PurchaseOrderID, poh.VendorID, poh.OrderDate, pod.OrderQty , pod.UnitPrice
from AdventureWorks2014.Purchasing.PurchaseOrderHeader as poh 
inner join AdventureWorks2014.Purchasing.PurchaseOrderDetail as pod 
on poh.PurchaseOrderID=pod.PurchaseOrderID


/*
c) 
U tabelu dobavljac_proizvod izvršiti insert podataka iz tabela Purchasing.ProductVendor i Production.Product prema sljedećoj strukturi:
	ProductID -> proizvod_id 
	BusinessEntityID -> dobavljac_id 
	Name -> proiz_naziv 
	ProductNumber -> serij_oznaka_proiz
	MaxOrderQty - MinOrderQty -> razlika_min_max 
	MaxOrderQty - OnOrderQty -> razlika_max_narudzba
uz uslov da se dohvate samo oni zapisi u kojima se podatak u koloni rowguid tabele Production.Product završava cifrom.
*/
--10 bodova
select * from AdventureWorks2014.Purchasing.ProductVendor 
select * from AdventureWorks2014.Production.Product
insert into dobavljac_proizvod 
select PP.ProductID,  PV.BusinessEntityID, PP.Name, PP.ProductNumber, PV.MaxOrderQty- PV.MinOrderQty as razlika_min_max, PV.MaxOrderQty-PV.OnOrderQty as razlika_max_narudzba
from AdventureWorks2014.Purchasing.ProductVendor as PV
inner join AdventureWorks2014.Production.Product as PP
on PP.ProductID=PV.ProductID
where right(PP.rowguid, 1) like '[0-9]'

----------------------------
--3.
----------------------------
/*
Koristeći sve tri tabele iz vlastite baze kreirati pogled view_dob_proiz sljedeće strukture:
	- dobavljac_id
	- proizvod_id
	- naruc_kolicina
	- cijena_proizvoda
	- razlika, kao razlika kolona razlika_min_max i razlika_max_narudzba 
Uslov je da se dohvate samo oni zapisi u kojima je razlika pozitivan broj ili da kreditni rejting 1.
*/
--10 bodova
create view view_dob_proiz 
as (
select d.dobavljac_id, dp.proizvod_id, n.naruc_kolicina, n.cijena_proizvoda, dp.razlika_min_max - dp.razlika_max_narudzba as razlika
from narudzba as n 
inner join dobavljac as d
on n.dobavljac_id=d.dobavljac_id
inner join dobavljac_proizvod as dp
on dp.dobavljac_id=n.dobavljac_id
where  dp.razlika_min_max - dp.razlika_max_narudzba >0 or d.kred_rejting=1
) 

select * from view_dob_proiz

----------------------------
--4.
----------------------------
/*
Koristeći pogled view_dob_proiz kreirati proceduru proc_dob_proiz koja će sadržavati parametar razlika i imati sljedeću strukturu:
	- dobavljac_id
	- suma_razlika, sumirana vrijednost kolone razlika po dobavljac_id i proizvod_id
Uslov je da se dohvataju samo oni zapisi u kojima je razlika jednocifren ili dvocifren broj.
Nakon kreiranja pokrenuti proceduru za vrijednost razlike 2.
*/
--10 bodova


----------------------------
--5.
----------------------------
/*
a)
Pogled view_dob_proiz kopirati u tabelu tabela_dob_proiz uz uslov da se ne dohvataju zapisi u kojima je razlika NULL vrijednost
--11051
b) 
U tabeli tabela_dob_proiz kreirati izračunatu kolonu ukupno kao proizvod naručene količine i cijene proizvoda.
c)
U tabeli tabela_dob_god kreirati novu kolonu razlika_ukupno. Kolonu popuniti razlikom vrijednosti kolone ukupno i srednje vrijednosti ove kolone. Negativne vrijednosti u koloni razlika_ukupno zamijeniti 0.
*/
--15 bodova
select * 
into tabela_dob_proiz
from view_dob_proiz
where razlika is not null 


alter table tabela_dob_proiz 
add ukupno int 

update tabela_dob_proiz
set razlika_ukupno=naruc_kolicina*cijena_proizvoda


alter table tabela_dob_proiz 
add razlika_ukupno int 

update tabela_dob_proiz
set razlika_ukupno=ukupno-(select avg(ukupno) from tabela_dob_proiz)

select * from tabela_dob_proiz
update tabela_dob_proiz 
set razlika_ukupno= 0
where razlika_ukupno<0

----------------------------
--6.
----------------------------
/*
Prebrojati koliko u tabeli dobavljac_proizvod ima različitih serijskih oznaka proizvoda kojima se poslije prve srednje crte nalazi bilo koje slovo engleskog alfabeta,
 a koliko ima onih kojima se poslije prve srednje crte nalazi cifra. Upit treba da vrati dvije poruke (tekst i podaci se ne prikazuju u zasebnim kolonama):
	'Različitih serijskih oznaka proizvoda koje završavaju slovom engleskog alfabeta ima: ' iza čega slijedi podatak o ukupno prebrojanom  broju zapisa 
	i
	'Različitih serijskih oznaka proizvoda kojima se poslije prve srednje crte nalazi cifra ima:' iza čega slijedi podatak o ukupno prebrojanom  broju zapisa 
*/
select * from dobavljac_proizvod
--10

select substring(serij_oznaka_proiz, charindex('-',serij_oznaka_proiz)+1, 1)
from dobavljac_proizvod 
where substring(serij_oznaka_proiz, charindex('-',serij_oznaka_proiz)+1, 1) not like '[A-Z]%'


select 'Različitih serijskih oznaka proizvoda koje završavaju slovom engleskog alfabeta ima: '+ convert(nvarchar, count(*)) 
from dobavljac_proizvod 
where substring(serij_oznaka_proiz, charindex('-',serij_oznaka_proiz)+1, 1) like '[A-Z]%'
union 
select 'Različitih serijskih oznaka proizvoda kojima se poslije prve srednje crte nalazi cifra ima:' + convert(nvarchar, count(*)) 
from dobavljac_proizvod 
where substring(serij_oznaka_proiz, charindex('-',serij_oznaka_proiz)+1, 1) not like '[A-Z]%'

----------------------------
--7.
----------------------------
/*
a)
Koristeći tabelu dobavljac kreirati pogled view_duzina koji će sadržavati slovni dio podataka u koloni dobavljac_br_rac, te broj znakova slovnog dijela podatka.
b)
Koristeći pogled view_duzina odrediti u koliko zapisa broj prebrojanih znakova je veći ili jednak,
 a koliko manji od srednje vrijednosti prebrojanih brojeva znakova. Rezultat upita trebaju biti dva reda sa odgovarajućim porukama.
*/
--10 bodova
create view view_duzina 
as
select left(dobavljac_br_rac, len(dobavljac_br_rac)-4) as znakovni_dio, len(dobavljac_br_rac)-4 as broj_znakova
from dobavljac

select 'Broj zapisa u kojima je broj znakova veci od avg:' + convert(nvarchar, count(*))
from view_duzina
where broj_znakova>= (select avg(broj_znakova) from view_duzina) 
union 
select 'Broj zapisa u kojima je broj znakova manji od avg:' + convert(nvarchar, count(*))
from view_duzina
where broj_znakova< (select avg(broj_znakova) from view_duzina) 


----------------------------
--8.
----------------------------
/*
Prebrojati kod kolikog broja dobavljača je broj računa kreiran korištenjem više od jedne riječi iz naziva dobavljača. 
Jednom riječi se podrazumijeva skup slova koji nije prekinut blank (space) znakom. 
*/
--10 bodova
select left(naziv_dobavljaca,charindex(' ' , naziv_dobavljaca))
from dobavljac

select count(*) 
from dobavljac
where len(upper(SUBSTRING(naziv_dobavljaca, 1, charindex(' ' , naziv_dobavljaca)))) <len (left(dobavljac_br_rac, len(dobavljac_br_rac)-4)) and len(upper(SUBSTRING(naziv_dobavljaca, 1, charindex(' ' , naziv_dobavljaca))))>0

----------------------------
--9.
----------------------------
/*
a) U tabeli dobavljac_proizvod id proizvoda promijeniti tako što će se sve trocifrene vrijednosti svesti na vrijednost stotina (npr. 524 => 500). 
Nakon toga izvršiti izmjenu vrijednosti u koloni proizvod_id po sljedećem pravilu:
- Prije postojeće vrijednosti dodati "pr-", 
- Nakon postojeće vrijednosti dodati srednju crtu i četverocifreni brojčani dio iz kolone serij_oznaka_proiz koji slijedi nakon prve srednje crte,
 pri čemu se u slučaju da četverocifreni dio počinje 0 ta 0 odbacuje. 
U slučaju da nakon prve srednje crte ne slijedi četverocifreni broj ne vrši se nikakvo dodavanje (ni prije, ni poslije postojeće vrijednosti)
*/
/*
Primjer nekoliko konačnih podatka:

proizvod_id		serij_oznaka_proit

pr-300-1200		FW-1200
pr-300-820 		GT-0820 (odstranjena 0)
700				HL-U509-R (nije izvršeno nikakvo dodavanje)
*/
--13 bodova
select left(proizvod_id,1)*100 from dobavljac_proizvod
where proizvod_id>99

alter table dobavljac_proizvod 
drop constraint PK_dobavljac_proizvod

update dobavljac_proizvod 
set proizvod_id=left(proizvod_id,1)*100
where proizvod_id>99


alter table dobavljac_proizvod 
alter column proizvod_id nvarchar(15)


create procedure proc_up_dp
as 
begin 
update dobavljac_proizvod
set proizvod_id='pr-'+convert(nvarchar,proizvod_id)+'-'+right(serij_oznaka_proiz,4)
where serij_oznaka_proiz in (select serij_oznaka_proiz from dobavljac_proizvod where 
substring(serij_oznaka_proiz, CHARINDEX('-',serij_oznaka_proiz)+1, 4) not like '%[A-Z]%' and substring(serij_oznaka_proiz, CHARINDEX('-',serij_oznaka_proiz)+1,1)<>'0')
update dobavljac_proizvod
set proizvod_id='pr-'+convert(nvarchar,proizvod_id)+'-'+right(serij_oznaka_proiz,3)
where serij_oznaka_proiz in (select serij_oznaka_proiz from dobavljac_proizvod where 
substring(serij_oznaka_proiz, CHARINDEX('-',serij_oznaka_proiz)+1, 4) not like '%[A-Z]%' and substring(serij_oznaka_proiz, CHARINDEX('-',serij_oznaka_proiz)+1,1)='0')
end


exec proc_up_dp

----------------------------
--10.
----------------------------
/*
a) Kreirati backup baze na default lokaciju.
b) Napisati kod kojim će biti moguće obrisati bazu.
c) Izvršiti restore baze.
Uslov prihvatanja kodova je da se mogu pokrenuti.
*/
--2 boda

backup database _12
to disk='_12.bak'

use master
alter database _12
set offline

drop database _12 


restore database _12 
from disk='_12.bak'