--1. Kreiranje baze i tabela
/*
a) Kreirati bazu pod vlastitim brojem indeksa.
*/


create database "3" 

use "3"
--b) Kreiranje tabela.
/*
Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
I. Kreirati tabelu kreditna sljedeće strukture:
	- kreditnaID - cjelobrojna vrijednost, primarni ključ
	- br_kreditne - 25 unicode karatera, obavezan unos
	- dtm_evid - datumska varijabla za unos datuma
*/
create table kreditna (
kreditnaID int constraint PK_kreditna primary key, 
br_kreditne nvarchar(25) not null, 
dtm_evid date 
)


/*
II. Kreirati tabelu osoba sljedeće strukture:
	osobaID - cjelobrojna vrijednost, primarni ključ
	kreditnaID - cjelobrojna vrijednost, obavezan unos
	mail_lozinka - 128 unicode karaktera
	lozinka - 10 unicode karaktera 
	br_tel - 25 unicode karaktera
*/
create table osoba
(


osobaID int constraint PK_osoba primary key, 
kreditnaID int not null, 
mail_lozinka nvarchar(128) , 
lozinka nvarchar(10), 
br_tel nvarchar(25), 
constraint FK_osoba_kreditna foreign key(kreditnaID) references kreditna(kreditnaID) 
)



/*
III. Kreirati tabelu narudzba sljedeće strukture:
	narudzbaID - cjelobrojna vrijednost, primarni ključ
	kreditnaID - cjelobrojna vrijednost
	br_narudzbe - 25 unicode karaktera
	br_racuna - 15 unicode karaktera
	prodavnicaID - cjelobrojna varijabla
*/
create table narudzba 
(
	narudzbaID int constraint PK_narudzba primary key, 
	kreditnaID int ,
	br_narudzbe nvarchar(25), 
	br_racuna nvarchar(15), 
	prodavnicaID int, 
	constraint FK_narudzba_kreditna foreign key(kreditnaID) references kreditna(kreditnaID)
)

--10 bodova





-----------------------------------------------------------------------------------------------------------------------------
--2. Import podataka
/*
a) Iz tabele CreditCard baze AdventureWorks2017 importovati podatke u tabelu kreditna na sljedeći način:
	- CreditCardID -> kreditnaID
	- CardNUmber -> br_kreditne
	- ModifiedDate -> dtm_evid
*/
insert into kreditna (kreditnaID, br_kreditne, dtm_evid) 
select CC.CreditCardID, CC.CardNumber, CC.ModifiedDate from AdventureWorks2014.Sales.CreditCard as CC

/*
b) Iz tabela Person, Password, PersonCreditCard i PersonPhone baze AdventureWorks2017 koje se nalaze u šemama Sales i Person 
importovati podatke u tabelu osoba na sljedeći način:
	- BussinesEntityID -> osobaID
	- CreditCardID -> kreditnaID
	- PasswordHash -> mail_lozinka
	- PasswordSalt -> lozinka
	- PhoneNumber -> br_tel
*/
insert into osoba (osobaID, kreditnaID,mail_lozinka, lozinka, br_tel)
select PP.BusinessEntityID, PCC.CreditCardID, PW.PasswordHash , PW.PasswordSalt, PH.PhoneNumber
from AdventureWorks2014.Person.Person as PP
inner join AdventureWorks2014.Person.PersonPhone as PH
on PP.BusinessEntityID=PH.BusinessEntityID
inner join AdventureWorks2014.Person.Password as PW
on PW.BusinessEntityID=PP.BusinessEntityID
inner join AdventureWorks2014.Sales.PersonCreditCard as PCC on
PCC.BusinessEntityID=PP.BusinessEntityID

/*
c) Iz tabela Customer i SalesOrderHeader baze AdventureWorks2017 koje se nalaze u šemi Sales importovati podatke u tabelu 
narudzba na sljedeći način:
	- SalesOrderID -> narudzbaID
	- CreditCardID -> kreditnaID
	- PurchaseOrderNumber -> br_narudzbe
	- AccountNumber -> br_racuna
	- StoreID -> prodavnicaID
*/
insert into narudzba (narudzbaID, kreditnaID, br_narudzbe, br_racuna, prodavnicaID)
select SOH.SalesOrderID , SOH.CreditCardID, SOH.PurchaseOrderNumber, C.AccountNumber, C.StoreID
from AdventureWorks2014.Sales.Customer as C
inner join AdventureWorks2014.Sales.SalesOrderHeader as SOH
on C.CustomerID=SOH.CustomerID
--10 bodova





-----------------------------------------------------------------------------------------------------------------------------
/*
3. Kreirati pogled view_kred_mail koji će se sastojati od kolona: 
	- br_kreditne, 
	- mail_lozinka, 
	- br_tel i 
	- br_cif_br_tel, 
	pri čemu će se kolone puniti na sljedeći način:
	- br_kreditne - odbaciti prve 4 cifre 
 	- mail_lozinka - preuzeti sve znakove od 10. znaka (uključiti i njega) uz odbacivanje znaka jednakosti koji se nalazi na kraju lozinke
	- br_tel - prenijeti cijelu kolonu
	- br_cif_br_tel - broj cifara u koloni br_tel
*/
select  o.mail_lozinka,substring(o.mail_lozinka,10,len(o.mail_lozinka)-len(left(o.mail_lozinka,10))) from osoba	as o 
create view view_kred_mail 
as
select substring(k.br_kreditne,5,len(k.br_kreditne)) as br_kreditne, substring(o.mail_lozinka,10,len(o.mail_lozinka)-len(left(o.mail_lozinka,10))-1) as mail_lozinka, o.br_tel,
len(br_tel) as br_cif_br_tel 
from osoba as o 
inner join kreditna as k 
on k.kreditnaID=o.kreditnaID

--10 bodova





-----------------------------------------------------------------------------------------------------------------------------
/*
4. Koristeći tabelu osoba kreirati proceduru proc_kred_mail u kojoj će biti sve kolone iz tabele. 
Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara (možemo ostaviti bilo koji 
parametar bez unijete vrijednosti) uz uslov da se prenesu samo oni zapisi u kojima je unijet predbroj u koloni br_tel. 
Npr. (123) 456 789 je zapis u kojem je unijet predbroj. 
Nakon kreiranja pokrenuti proceduru za sljedeću vrijednost:
br_tel = 1 (11) 500 555-0132
*/

create procedure proc_kred_mail 
(
@osobaID int=null,

@kreditnaID int= null, 
@mail_lozinka nvarchar(128) =null, 
@lozinka nvarchar(10)=null, 
@br_tel nvarchar(25)=null
)
as
begin 
select * from osoba
where (osobaID=@osobaID or kreditnaID=@kreditnaID or mail_lozinka=  @mail_lozinka or lozinka =@lozinka or br_tel=@br_tel) and br_tel like '%(%'
end
exec proc_kred_mail @br_tel = '1 (11) 500 555-0132'

select * from osoba

--10 bodova

-----------------------------------------------------------------------------------------------------------------------------
/*
5. 
a) Kopirati tabelu kreditna u kreditna1, 
b) U tabeli kreditna1 dodati novu kolonu dtm_izmjene čija je default vrijednost aktivni datum sa vremenom. Kolona je sa obaveznim unosom.
*/


select * 
into kreditna1 
from kreditna


alter table kreditna1
add dtm_izmjene datetime not null constraint DF_date default getdate()
-----------------------------------------------------------------------------------------------------------------------------
/*
6.
a) U zapisima tabele kreditna1 kod kojih broj kreditne kartice počinje ciframa 1 ili 3 vrijednost broja kreditne kartice zamijeniti 
slučajno generisanim nizom znakova.
b) Dati ifnormaciju (prebrojati) broj zapisa u tabeli kreditna1 kod kojih se datum evidencije nalazi u intevalu do najviše 6 godina 
u odnosu na datum izmjene.
c) Napisati naredbu za brisanje tabele kreditna1
*/


update kreditna1
set br_kreditne=left(newid(),25) 
where br_kreditne like '1%' or br_kreditne like '3%'

select * from kreditna1
select * from kreditna1
select count(*)
from kreditna1 
where datediff(year , dtm_evid, dtm_izmjene) <=6

drop table kreditna1

-----------------------------------------------------------------------------------------------------------------------------
/*
7.
a) U tabeli narudzba izvršiti izmjenu svih null vrijednosti u koloni br_narudzbe slučajno generisanim nizom znakova.
b) U tabeli narudzba izvršiti izmjenu svih null vrijednosti u koloni prodavnicaID po sljedećem pravilu.
	- ako narudzbaID počinje ciframa 4 ili 5 u kolonu prodavnicaID preuzeti posljednje 3 cifre iz kolone narudzbaID  
	- ako narudzbaID počinje ciframa 6 ili 7 u kolonu prodavnicaID preuzeti posljednje 4 cifre iz kolone narudzbaID  
*/

--12 bodova
update narudzba
set br_narudzbe=left(newid(),25)
where br_narudzbe is null


update narudzba
set prodavnicaID=right(narudzbaID,3)
where narudzbaID like '4%' OR narudzbaID like '5%'

update narudzba 
set prodavnicaID=right(narudzbaID,4) 
where narudzbaID like '6%' or narudzbaID like '7%'

-----------------------------------------------------------------------------------------------------------------------------
/*
8.
Kreirati proceduru kojom će se u tabeli narudzba izvršiti izmjena svih vrijednosti u koloni br_narudzbe u kojima se ne nalazi 
slučajno generirani niz znakova tako da se iz podatka izvrši uklanjanje prva dva znaka. 
*/
select * from narudzba
create procedure  update_nar
as
begin 
update narudzba 
set br_narudzbe=right(br_narudzbe,23) 
where len(br_narudzbe)<25
end

exec update_nar

--8 bodova




-----------------------------------------------------------------------------------------------------------------------------
/*
9.
a) Iz tabele narudzba kreirati pogled koji će imati sljedeću strukturu:
	- duz_br_nar 
	- prebrojano - prebrojati broj zapisa prema dužini podatka u koloni br_narudzbe 
	  (npr. 1000 zapisa kod kojih je dužina podatka u koloni br_narudzbe 10)
Uslov je da se ne prebrojavaju zapisi u kojima je smješten slučajno generirani niz znakova. 
Provjeriti sadržaj pogleda.
b) Prikazati minimalnu i maksimalnu vrijednost kolone prebrojano
c) Dati pregled zapisa u kreiranom pogledu u kojima su vrijednosti u koloni prebrojano veće od srednje vrijednosti kolone prebrojano 
*/

--13 bodova

select * from narudzba 
where br_narudzbe like 'PO%'

SELECT * FROM narudzba 
where len(br_narudzbe)<25
select * from narudzba

create view view_narudzba
as
select 
len(br_narudzbe) as [duz_br_nar], count(*) as prebrojano 
from narudzba
where len(br_narudzbe)<25
group by len(br_narudzbe)


select min(prebrojano), max(prebrojano) from view_narudzba

select * from view_narudzba 
where prebrojano > (select avg(prebrojano) from view_narudzba)
-----------------------------------------------------------------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Obrisati bazu.
*/
backup database "3" to disk ='3.bak'

use master
drop database "3"
--2 boda
