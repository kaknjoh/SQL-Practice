----------------------------
--1.
----------------------------
/*
Kreirati bazu pod vlastitim brojem indeksa
*/


create database vjezba_ispit

use vjezba_ispit
----------------------------------------------------------------------

--Prilikom kreiranja tabela voditi računa o njihovom međusobnom odnosu 
----------------------------------------------------------------------

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
	dobavljac_br_rac nvarchar(55), 
	naziv_dobavljaca nvarchar(55),
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
create table narudzba
(
narudzba_detalj_id int primary key, 
narudzba_id int, 
dobavljac_id int, 
dtm_narudzbe date , 
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

create table dobavljac_proizvod_1
(
	proizvod_id int, 
	dobavljac_id int, 
	proiz_naziv nvarchar(50), 
	serij_oznaka_proiz nvarchar(50), 
	razlika_min_max int , 
	razlika_max_narudzbe int , 
	modified_date datetime default getdate(), 
	constraint PK_dobavljac_proizvod_1 primary key (proizvod_id, dobavljac_id), 
	constraint FK_dobavljac_proizvod_dobavljac_1 foreign key (dobavljac_id) references  dobavljac(dobavljac_id) 

)


create trigger track_last_update
on dobavljac_proizvod after update 
as 
begin 
set nocount on
update dobavljac_proizvod 
set modified_date=getdate()
from dobavljac_proizvod as dp
inner join inserted i 
on i.dobavljac_id=dp.dobavljac_id and i.proizvod_id=dp.proizvod_id
end

--10 bodova
----------------------------
--2. Insert podataka
----------------------------
/*
a)
U tabelu dobavljac izvršiti insert podataka iz tabele
Purchasing.Vendor prema sljedećoj strukturi:
BusinessEntityID -> dobavljac_id
AccountNumber -> dobavljac_br_rac 
Name -> naziv_dobavljaca
CreditRating -> kred_rejting
*/
insert into dobavljac ( dobavljac_id, dobavljac_br_rac, naziv_dobavljaca, kred_rejting)
select BusinessEntityID, AccountNumber, Name, CreditRating
from AdventureWorks2014.Purchasing.Vendor
/*
b)
U tabelu narudzba izvršiti insert podataka iz tabela
Purchasing.PurchaseOrderHeader i Purchasing.PurchaseOrderDetail prema
sljedećoj strukturi:
PurchaseOrderID -> narudzba_id
PurchaseOrderDetailID -> narudzba_detalj_id
VendorID -> dobavljac_id
OrderDate -> dtm_narudzbe
OrderQty -> naruc_kolicina
UnitPrice -> cijena_proizvoda
*/
insert into narudzba (narudzba_id, narudzba_detalj_id , dobavljac_id, dtm_narudzbe, naruc_kolicina, cijena_proizvoda)
select POD.PurchaseOrderID, POD.PurchaseOrderDetailID, POH.VendorID, POH.OrderDate, POD.OrderQty, POD.UnitPrice
from AdventureWorks2014.Purchasing.PurchaseOrderDetail as POD
inner join AdventureWorks2014.Purchasing.PurchaseOrderHeader as POH 
on POD.PurchaseOrderID=POH.PurchaseOrderID
 
select * from AdventureWorks2014.Purchasing.PurchaseOrderDetail
select * from AdventureWorks2014.Purchasing.PurchaseOrderHeader
/*
c)
U tabelu dobavljac_proizvod izvršiti insert podataka iz tabela
Purchasing.ProductVendor i Production.Product prema sljedećoj
strukturi:
ProductID -> proizvod_id
BusinessEntityID -> dobavljac_id
Name -> proiz_naziv
ProductNumber -> serij_oznaka_proiz
MaxOrderQty - MinOrderQty -> razlika_min_max
MaxOrderQty - OnOrderQty -> razlika_max_narudzba
uz uslov da se dohvate samo oni zapisi u kojima se podatak u koloni
rowguid tabele Production.Product završava cifrom.
*/

insert into dobavljac_proizvod_1 ( proizvod_id, dobavljac_id, proiz_naziv, serij_oznaka_proiz, razlika_min_max, razlika_max_narudzbe)
select PP.ProductID, PV.BusinessEntityID, PP.Name, PP.ProductNumber, PV.MaxOrderQty - PV.MinOrderQty, PV.MaxOrderQty-PV.OnOrderQty from  AdventureWorks2014.Purchasing.ProductVendor as PV 
inner join  AdventureWorks2014.Production.Product as PP
on PP.ProductID=PV.ProductID
where PP.rowguid like '%[0-9]'



select * from  AdventureWorks2014.Purchasing.ProductVendor
select * from AdventureWorks2014.Production.Product

--10 bodova
----------------------------
--3.
----------------------------
/*
Koristeći sve tri tabele iz vlastite baze kreirati pogled
view_dob_proiz sljedeće strukture:
- dobavljac_id
- proizvod_id
- naruc_kolicina
- cijena_proizvoda
- razlika, kao razlika kolona razlika_min_max i
razlika_max_narudzba
Uslov je da se dohvate samo oni zapisi u kojima je razlika pozitivan
broj ili da kreditni rejting 1.
*/

create view view_dob_proiz
as
select d.dobavljac_id , dp.proizvod_id, n.naruc_kolicina, n.cijena_proizvoda, razlika_min_max-razlika_max_narudzbe as razlika 
from dobavljac d
inner join dobavljac_proizvod as  dp 
on d.dobavljac_id=dp.dobavljac_id
inner join narudzba as n 
on dp.dobavljac_id =n.dobavljac_id 
where razlika_min_max-razlika_max_narudzbe >0 or kred_rejting=1
--10 bodova
----------------------------
--4.
----------------------------
/*
Koristeći pogled view_dob_proiz kreirati proceduru proc_dob_proiz koja
će sadržavati parametar razlika i imati sljedeću strukturu:
- dobavljac_id
- suma_razlika, sumirana vrijednost kolone razlika po
dobavljac_id i proizvod_id
Uslov je da se dohvataju samo oni zapisi u kojima je razlika
jednocifren ili dvocifren broj.
Nakon kreiranja pokrenuti proceduru za vrijednost razlike 2.
*/
create procedure proc_dob_proiz
(
@razlika int )
as begin 
select dobavljac_id,sum(razlika) as suma_razlika
from view_dob_proiz
where razlika<100 and razlika=@razlika
group by dobavljac_id, proizvod_id
end

exec proc_dob_proiz @razlika=2
--10 bodova
----------------------------
--5.
----------------------------
/*
a)
Pogled view_dob_proiz kopirati u tabelu tabela_dob_proiz uz uslov da
se ne dohvataju zapisi u kojima je razlika NULL vrijednost
--11051
*/ 
select * 
into tabela_dob_proiz 
from view_dob_proiz
where razlika is not null 

/*
b)
U tabeli tabela_dob_proiz kreirati izračunatu kolonu ukupno kao
proizvod naručene količine i cijene proizvoda.
*/
alter table tabela_dob_proiz 
add  ukupno as (naruc_kolicina*cijena_proizvoda) 
/*
c)
U tabeli tabela_dob_god kreirati novu kolonu razlika_ukupno. Kolonu
popuniti razlikom vrijednosti kolone ukupno i srednje vrijednosti ove
kolone. Negativne vrijednosti u koloni razlika_ukupno zamijeniti 0.
*/
alter table tabela_dob_proiz 
add razlika_ukupno  decimal(10,2)


update tabela_dob_proiz 
set razlika_ukupno= ukupno - (select avg(ukupno) from tabela_dob_proiz)


select * from tabela_dob_proiz
update tabela_dob_proiz
set razlika_ukupno ='0' 
where razlika_ukupno<0
--15 bodova
----------------------------
--6.
----------------------------
/*
Prebrojati koliko u tabeli dobavljac_proizvod ima različitih serijskih
oznaka proizvoda kojima se poslije prve srednje crte nalazi bilo koje
slovo engleskog alfabeta, a koliko ima onih kojima se poslije prve
srednje crte nalazi cifra. Upit treba da vrati dvije poruke (tekst i
podaci se ne prikazuju u zasebnim kolonama):
'Različitih serijskih oznaka proizvoda koje završavaju slovom
engleskog alfabeta ima: ' iza čega slijedi podatak o ukupno
prebrojanom broju zapisa
i
'Različitih serijskih oznaka proizvoda kojima se poslije prve
srednje crte nalazi cifra ima:' iza čega slijedi podatak o ukupno
prebrojanom broju zapisa
*/
select distinct 'Razlicitih serijskih oznaka proizvoda kojima se poslije srednje crte nalazi cifra ima ' + CONVERT(nvarchar, ukupno)
from (select  count(*) as ukupno 
from dobavljac_proizvod as dp 
where isnumeric(substring(serij_oznaka_proiz, 4 , 1))=1 ) 
--10


select count(dp.razlicitih) 
from (
select distinct serij_oznaka_proiz as razlicitih 
from dobavljac_proizvod
where  isnumeric(substring(serij_oznaka_proiz, 4 , 1))=1
) as dp
union 
select count(dp.razlicitih) 
from (
select distinct serij_oznaka_proiz as razlicitih 
from dobavljac_proizvod
where  isnumeric(substring(serij_oznaka_proiz, 4 , 1))=0
) as dp





----------------------------
--7.
----------------------------
/*
a)
Koristeći tabelu dobavljac kreirati pogled view_duzina koji će
sadržavati slovni dio podataka u koloni dobavljac_br_rac, te broj
znakova slovnog dijela podatka.
*/
select * from dobavljac
create view view_duzina
as
select substring(dobavljac_br_rac,1, len(dobavljac_br_rac)-len(right(dobavljac_br_rac,4))) as slovni_dio , len( substring(dobavljac_br_rac,1, len(dobavljac_br_rac)-len(right(dobavljac_br_rac,4))) ) as duzina_sl_dijela
from dobavljac
/*
b)
Koristeći pogled view_duzina odrediti u koliko zapisa broj prebrojanih
znakova je veći ili jednak, a koliko manji od srednje vrijednosti
prebrojanih brojeva znakova. Rezultat upita trebaju biti dva reda sa
odgovarajućim porukama.
*/
select * from view_duzina


select 'Broj znakovac vecih od srednje vrijednosti je ' + convert(nvarchar,count(*)) 
from view_duzina
where duzina_sl_dijela> (select avg(duzina_sl_dijela) from view_duzina)
union 
select 'Broj znakovac manjih od srednje vrijednosti je ' + convert(nvarchar,count(*))
from view_duzina
where duzina_sl_dijela< (select avg(duzina_sl_dijela) from view_duzina)

--10 bodova
----------------------------
--8.
----------------------------
/*
Prebrojati kod kolikog broja dobavljača je broj računa kreiran
korištenjem više od jedne riječi iz naziva dobavljača. Jednom riječi
se podrazumijeva skup slova koji nije prekinut blank (space) znakom.
*/
select * from dobavljac
select count(*) 
from dobavljac
where len(substring(naziv_dobavljaca, 1,charindex(' ' , naziv_dobavljaca)))< len( substring(dobavljac_br_rac,1, len(dobavljac_br_rac)-len(right(dobavljac_br_rac,4))))
--10 bodova
----------------------------
--9.
----------------------------
/*
a) U tabeli dobavljac_proizvod id proizvoda promijeniti tako što će se
sve trocifrene vrijednosti svesti na vrijednost stotina (npr. 524 =>
500). Nakon toga izvršiti izmjenu vrijednosti u koloni proizvod_id po
sljedećem pravilu:
- Prije postojeće vrijednosti dodati "pr-",
- Nakon postojeće vrijednosti dodati srednju crtu i četverocifreni
brojčani dio iz kolone serij_oznaka_proiz koji slijedi nakon prve
srednje crte, pri čemu se u slučaju da četverocifreni dio počinje 0 ta
0 odbacuje.
U slučaju da nakon prve srednje crte ne slijedi četverocifreni broj ne
vrši se nikakvo dodavanje (ni prije, ni poslije postojeće vrijednosti)
*/
select * from dobavljac_proizvod_1

alter table dobavljac_proizvod_1
drop constraint PK_dobavljac_proizvod_1

update dobavljac_proizvod_1
set proizvod_id=left(proizvod_id,1)*100
where proizvod_id>99 and proizvod_id<1000


select * from dobavljac_proizvod_1
alter table dobavljac_proizvod_1
alter column proizvod_id nvarchar(55)
update dobavljac_proizvod_1
set proizvod_id= 'pr-'+convert(nvarchar,proizvod_id)+'-'+convert(nvarchar, convert(int,substring(serij_oznaka_proiz,convert(int,charindex('-', serij_oznaka_proiz))+1,4)))
where proizvod_id in (select proizvod_id from dobavljac_proizvod_1 where proizvod_id in (100,200,300,400,500,600,700,800,900)) and isnumeric(substring(serij_oznaka_proiz,convert(int,charindex('-', serij_oznaka_proiz))+1,4))=1


drop table dobavljac_proizvod_1
/*
Primjer nekoliko konačnih podatka:
proizvod_id serij_oznaka_proit
pr-300-1200 FW-1200
pr-300-820 GT-0820 (odstranjena 0)
700 HL-U509-R (nije izvršeno nikakvo
dodavanje)
*/
--13 bodova
----------------------------
--10.
----------------------------
/*
a) Kreirati backup baze na default lokaciju.
*/ 
backup database vjezba_ispit
/*
b) Napisati kod kojim će biti moguće obrisati bazu.
*/
use master
alter database vjezba_ispit
set offline

restore database vjezba_ispit

drop database vjezba_ispit
/*
c) Izvršiti restore baze.
*/
restore database vjezba_ispit
with replace 
/*
Uslov prihvatanja kodova je da se mogu pokrenuti.

*/
--2 boda