﻿----------------------------
--1.
----------------------------
/*
Kreirati bazu pod vlastitim brojem indeksa
*/

create database indeks12	

use indeks12
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
create table dobavljac(
dobavljac_id int primary key, 
dobavljac_br_rac nvarchar(50),
naziv_dobavljaca nvarchar(50), 
kred_rejting int) 
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
create table narudzba (
narudzba_detalj_id int primary key ,
narudzba_id int, 
dobavljac_id int, 
dtm_narudzbe date, 
naruc_kolicina int ,
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
dobavljac_id int , 
proiz_naziv nvarchar(50), 
serij_oznaka_proiz nvarchar(50), 
razlika_min_max int , 
razlika_max_narudzba int, 
constraint PK_dobavljac_proizvod primary key(proizvod_id , dobavljac_id), 
constraint FK_dobavljac_proizvod_dobavljac foreign key (dobavljac_id) references dobavljac(dobavljac_id))


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
select PV.BusinessEntityID, 
PV.AccountNumber, 
PV.Name, 
PV.CreditRating
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
select pod.PurchaseOrderDetailID, poh.PurchaseOrderID, poh.VendorID, poh.OrderDate, pod.OrderQty, pod.UnitPrice
from AdventureWorks2014.Purchasing.PurchaseOrderDetail as pod 
inner join AdventureWorks2014.Purchasing.PurchaseOrderHeader as poh
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
select PP.ProductID, V.BusinessEntityID, PP.Name, PP.ProductNumber, V.MaxOrderQty - V.MinOrderQty as razlika_min_max, V.MaxOrderQty-V.OnOrderQty as razlika_max_narudzba
from AdventureWorks2014.Purchasing.ProductVendor as V
inner join AdventureWorks2014.Production.Product as PP
on V.ProductID=PP.ProductID
where right(PP.rowguid,1) like '[0-9]'
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
as 
(
select d.dobavljac_id, dp.proizvod_id, 
n.naruc_kolicina, n.cijena_proizvoda, dp.razlika_min_max- dp.razlika_max_narudzba as razlika
from dobavljac as d
inner join narudzba as n
on d.dobavljac_id=n.dobavljac_id
inner join dobavljac_proizvod as dp
on d.dobavljac_id=dp.dobavljac_id
where dp.razlika_min_max- dp.razlika_max_narudzba>0 or d.kred_rejting=1
)

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
create procedure proc_dob_proiz
(
@razlika int=null
)
as 
begin 
select dobavljac_id, sum(razlika) as suma_razlika
from view_dob_proiz 
where razlika=@razlika and( len(razlika)=2 or len(razlika)=1)
group by dobavljac_id,proizvod_id
end
drop procedure proc_dob_proiz
exec proc_dob_proiz @razlika=2
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
U tabeli tabela_dob_god kreirati novu kolonu razlika_ukupno. Kolonu popuniti razlikom vrijednosti kolone ukupno i srednje vrijednosti ove kolone. 
Negativne vrijednosti u koloni razlika_ukupno zamijeniti 0.
*/
--15 bodova

/* a */ 
select * 
into tabela_dob_proiz
from view_dob_proiz
where razlika is not null

/* b */ 
alter table tabela_dob_proiz 
add ukupno as (naruc_kolicina*cijena_proizvoda)

/* c */ 
alter table tabela_dob_proiz 
add razlika_ukupno decimal(10,2)

update tabela_dob_proiz 
set razlika_ukupno=ukupno- (select avg(ukupno) from tabela_dob_proiz)
where ukupno- (select avg(ukupno) from tabela_dob_proiz)>=0

update tabela_dob_proiz 
set razlika_ukupno=0
where ukupno- (select avg(ukupno) from tabela_dob_proiz)<0



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
--10
create view view_oznaka
as
(

select distinct serij_oznaka_proiz from dobavljac_proizvod
) 
select    'Različitih serijskih oznaka proizvoda koje završavaju slovom engleskog alfabeta ima: '+ convert(nvarchar, count(*))
from view_oznaka
where substring(serij_oznaka_proiz, CHARINDEX('-', serij_oznaka_proiz)+1, 1) like '[0-9]'
union 
select   'Različitih serijskih oznaka proizvoda kojima se poslije prve srednje crte nalazi cifra ima:'+  convert(nvarchar, count(*)) 
from view_oznaka
where substring(serij_oznaka_proiz, CHARINDEX('-', serij_oznaka_proiz)+1, 1) like '[A-Z]'
----------------------------
--7.
----------------------------
/*
a)
Koristeći tabelu dobavljac kreirati pogled view_duzina koji će sadržavati slovni dio podataka u koloni dobavljac_br_rac, te broj znakova slovnog dijela podatka.
b)
Koristeći pogled view_duzina odrediti u koliko zapisa broj prebrojanih znakova je veći ili jednak, a koliko manji od srednje vrijednosti prebrojanih brojeva znakova. 
Rezultat upita trebaju biti dva reda sa odgovarajućim porukama.
*/
--10 bodova
select * from dobavljac
create view view_duzina 
as (
select distinct left(dobavljac_br_rac, len(dobavljac_br_rac)-4) as slovni_dio, len(left(dobavljac_br_rac, len(dobavljac_br_rac)-4)) as duzina
from dobavljac)


select 'Broj zapisa veci od avg ' + convert(nvarchar, count(*))
from view_duzina
where duzina >= (select avg(duzina) from view_duzina)
union 
select 'Broj zapisa manji od avg ' + convert(nvarchar, count(*))
from view_duzina
where duzina < (select avg(duzina) from view_duzina)


----------------------------
--8.
----------------------------
/*
Prebrojati kod kolikog broja dobavljača je broj računa kreiran korištenjem više od jedne riječi iz naziva dobavljača.
 Jednom riječi se podrazumijeva skup slova koji nije prekinut blank (space) znakom. 
*/
--10 bodova
select count(*) 
from dobavljac 
where len(left(dobavljac_br_rac, len(dobavljac_br_rac)-4)) > len(substring(naziv_dobavljaca,1, charindex(' ' , naziv_dobavljaca))) and  len(substring(naziv_dobavljaca,1,  charindex(' ' , naziv_dobavljaca))) >0
----------------------------
--9.
----------------------------
/*
a) U tabeli dobavljac_proizvod id proizvoda promijeniti tako što će se sve trocifrene vrijednosti svesti na vrijednost stotina (npr. 524 => 500). Nakon toga izvršiti izmjenu vrijednosti u koloni proizvod_id po sljedećem pravilu:
- Prije postojeće vrijednosti dodati "pr-", 
- Nakon postojeće vrijednosti dodati srednju crtu i četverocifreni brojčani dio iz kolone serij_oznaka_proiz koji slijedi nakon prve srednje crte, pri čemu se u slučaju da četverocifreni dio počinje 0 ta 0 odbacuje. 
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

alter table dobavljac_proizvod 
drop constraint PK_dobavljac_proizvod


update dobavljac_proizvod 
set proizvod_id=left(proizvod_id,1)*100
where proizvod_id between 99 and 1000

alter table dobavljac_proizvod
alter column  proizvod_id nvarchar(10) 
create procedure proc_update
as 
begin 
update dobavljac_proizvod 
set proizvod_id= 'pr-'+convert(nvarchar,proizvod_id)+substring(serij_oznaka_proiz, CHARINDEX('-', serij_oznaka_proiz)+1,4)
where  ISNUMERIC(substring(serij_oznaka_proiz, CHARINDEX('-', serij_oznaka_proiz)+1,4))=1 and substring(serij_oznaka_proiz, CHARINDEX('-', serij_oznaka_proiz)+1,1) <>'0'
update dobavljac_proizvod 
set proizvod_id= 'pr-'+convert(nvarchar,proizvod_id)+convert(nvarchar,convert(int,substring(serij_oznaka_proiz, CHARINDEX('-', serij_oznaka_proiz)+1,4)))
where  ISNUMERIC(substring(serij_oznaka_proiz, CHARINDEX('-', serij_oznaka_proiz)+1,4))=1 and substring(serij_oznaka_proiz, CHARINDEX('-', serij_oznaka_proiz)+1,1) ='0'
end
drop procedure proc_update
exec proc_update


select * from dobavljac_proizvod


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