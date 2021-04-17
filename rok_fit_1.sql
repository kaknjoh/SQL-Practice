----------------------------------------------------------------1.
/*
Koristeći isključivo SQL kod, kreirati bazu pod vlastitim brojem indeksa sa defaultnim postavkama.
*/
create database "1"
use "1"

/*
Unutar svoje baze podataka kreirati tabele sa sljedećom struktorom:
--NARUDZBA
a) Narudzba
NarudzbaID, primarni ključ
Kupac, 40 UNICODE karaktera
PunaAdresa, 80 UNICODE karaktera
DatumNarudzbe, datumska varijabla, definirati kao datum
Prevoz, novčana varijabla
Uposlenik, 40 UNICODE karaktera
GradUposlenika, 30 UNICODE karaktera
DatumZaposlenja, datumska varijabla, definirati kao datum
BrGodStaza, cjelobrojna varijabla
*/

create table Narudzba
(
NarudzbaID int primary key, 
Kupac nvarchar(40) , 
PunaAdresa nvarchar(80), 
DatumNarudzbe date default getdate(), 
Prevoz money, 
Uposlenik nvarchar(40), 
GradUposlenika nvarchar(30),
DatumZaposlenja date default getdate(), 
BrGodStaza int ) 

--PROIZVOD
/*
b) Proizvod
ProizvodID, cjelobrojna varijabla, primarni ključ
NazivProizvoda, 40 UNICODE karaktera
NazivDobavljaca, 40 UNICODE karaktera
StanjeNaSklad, cjelobrojna varijabla
NarucenaKol, cjelobrojna varijabla
*/
create table Proizvod
(
ProizvodID int primary key, 
NazivProizvoda nvarchar(40), 
NazivDobavljaca nvarchar(40), 
StanjeNaSklad int, 
NarucenaKol int) 



--DETALJINARUDZBE
/*
c) DetaljiNarudzbe
NarudzbaID, cjelobrojna varijabla, obavezan unos
ProizvodID, cjelobrojna varijabla, obavezan unos
CijenaProizvoda, novčana varijabla
Kolicina, cjelobrojna varijabla, obavezan unos
Popust, varijabla za realne vrijednosti
Napomena: Na jednoj narudžbi se nalazi jedan ili više proizvoda.
*/


create table DetaljiNarudzbe ( 
NarudzbaID int  not null, 
ProizvodID int not null, 
CijenaProizvoda money, 
Kolicina int not null, 
Popust float , 
constraint PK_DetaljiNarudzbe primary key (NarudzbaID, ProizvodID), 
constraint FK_DetaljiNarudzbe_Proizvod foreign key (ProizvodID) references Proizvod(ProizvodID)
)
alter table DetaljiNarudzbe 
add constraint FK_Detalji_Narudzbe_Narudzba foreign key(NarudzbaID) references Narudzba(NarudzbaID)
----------------------------------------------------------------2.
--2a) narudzbe
/*
Koristeći bazu Northwind iz tabela Orders, Customers i Employees importovati podatke po sljedećem pravilu:
OrderID -> ProizvodID
ComapnyName -> Kupac
PunaAdresa - spojeno adresa, poštanski broj i grad, pri čemu će se između riječi staviti srednja crta sa razmakom prije i poslije nje
OrderDate -> DatumNarudzbe
Freight -> Prevoz
Uposlenik - spojeno prezime i ime sa razmakom između njih
City -> Grad iz kojeg je uposlenik
HireDate -> DatumZaposlenja
BrGodStaza - broj godina od datum zaposlenja
*/

insert into Narudzba (NarudzbaID , Kupac, PunaAdresa, DatumNarudzbe , Prevoz , Uposlenik , GradUposlenika, DatumZaposlenja, BrGodStaza) 
select O.OrderID, C.CompanyName, C.Address+' - '+C.PostalCode+' - ' +C.City, O.OrderDate, O.Freight, E.FirstName + ' ' + E.LastName,E.City, E.HireDate, datediff(year, E.HireDate, getdate()) 
from NORTHWND.dbo.Orders AS O 
inner join NORTHWND.dbo.Customers as C
on O.CustomerID=C.CustomerID
inner join NORTHWND.dbo.Employees as E
on E.EmployeeID=O.EmployeeID
select * from NORTHWND.dbo.Orders
select * from NORTHWND.dbo.Customers
select  * from NORTHWND.dbo.Employees


--proizvod
/*
Koristeći bazu Northwind iz tabela Products i Suppliers putem podupita importovati podatke po sljedećem pravilu:
ProductID -> ProizvodID
ProductName -> NazivProizvoda 
CompanyName -> NazivDobavljaca 
UnitsInStock -> StanjeNaSklad 
UnitsOnOrder -> NarucenaKol 
*/
insert into Proizvod (ProizvodID,NazivProizvoda, NazivDobavljaca, StanjeNaSklad, NarucenaKol)

SELECT 
	P.ProductID, 
	P.ProductName, 
	( 
	  SELECT S.CompanyName 
	  FROM NORTHWND.dbo.Suppliers AS S 
	  WHERE S.SupplierID = P.SupplierID 
	),
	P.UnitsInStock, 
	P.UnitsOnOrder
FROM NORTHWND.dbo.Products AS P 
WHERE P.SupplierID IN (SELECT S.SupplierID FROM NORTHWND.dbo.Suppliers AS S)


select * from NORTHWND.dbo.Products
select * from NORTHWND.dbo.Suppliers
--RJ: 78

--detaljinarudzbe
/*
Koristeći bazu Northwind iz tabele Order Details importovati podatke po sljedećem pravilu:
OrderID -> NarudzbaID
ProductID -> ProizvodID
CijenaProizvoda - manja zaokružena vrijednost kolone UnitPrice, npr. UnitPrice = 3,60 CijenaProizvoda = 3,00
*/


insert into DetaljiNarudzbe 
select OrderID, ProductID,UnitPrice, FLOOR(UnitPrice), Quantity, Discount
from NORTHWND.dbo.[Order Details]
----------------------------------------------------------------3.
--3a
/*
U tabelu Narudzba dodati kolonu SifraUposlenika kao 20 UNICODE karaktera. Postaviti uslov da podatak mora biti dužine tačno 15 karaktera.
*/

alter table Narudzba 
add SifraUposlenika nvarchar(20) 

alter table Narudzba
add constraint CK_Len_Sifra check (len(SifraUposlenika)=15) 

--3b
/*
Kolonu SifraUposlenika popuniti na način da se obrne string koji se dobije spajanjem grada uposlenika i prvih 10 karaktera datuma zaposlenja pri 
čemu se između grada i 10 karaktera nalazi jedno prazno mjesto. Provjeriti da li je izvršena izmjena.
*/
update Narudzba
set SifraUposlenika=left(reverse(GradUposlenika+' ' +left(DatumZaposlenja,10)),15 )


--3c
/*
U tabeli Narudzba u koloni SifraUposlenika izvršiti zamjenu svih zapisa kojima grad uposlenika završava slovom "d" tako da se umjesto toga ubaci 
slučajno generisani string dužine 20 karaktera. Provjeriti da li je izvršena zamjena.
*/
alter table Narudzba 
drop constraint CK_Len_Sifra
select * from Narudzba
update Narudzba 
set SifraUposlenika=left(newid(),20)
where GradUposlenika like '%d'

----------------------------------------------------------------4.
/*
Koristeći svoju bazu iz tabela Narudzba i DetaljiNarudzbe kreirati pogled koji će imati sljedeću strukturu: Uposlenik, SifraUposlenika, 
ukupan broj proizvoda izveden iz NazivProizvoda, uz uslove da je dužina sifre uposlenika 20 karaktera, te da je ukupan broj proizvoda veći od 2. 
Provjeriti sadržaj pogleda, pri čemu se treba izvršiti sortiranje po ukupnom broju proizvoda u opadajućem redoslijedu.*/
select * from Narudzba
select * from Proizvod
select * from DetaljiNarudzbe
create view view_upo_nar
as
select N.Uposlenik , N.SifraUposlenika,count(P.NazivProizvoda)
as [BrojProdanih]
from DetaljiNarudzbe as D
inner join Proizvod as P
on D.ProizvodID=P.ProizvodID
inner join Narudzba as N
on N.NarudzbaID=D.NarudzbaID
where len(N.SifraUposlenika)=20 

group by  N.Uposlenik , N.SifraUposlenika
having count(P.NazivProizvoda)>2
order by 3 desc


drop view view_upo_nar

----------------------------------------------------------------5. 
/*
Koristeći vlastitu bazu kreirati proceduru nad tabelom Narudzbe kojom će se dužina podatka u koloni SifraUposlenika 
smanjiti sa 20 na 4 slučajno generisana karaktera. Pokrenuti proceduru. */

create procedure proc_izmjeni 
as 
begin 
update Narudzba
set SifraUposlenika=left(newid(),4)
end

exec proc_izmjeni

----------------------------------------------------------------6.
/*
Koristeći vlastitu bazu podataka kreirati pogled koji će imati sljedeću strukturu: NazivProizvoda, 
Ukupno - ukupnu sumu prodaje proizvoda uz uzimanje u obzir i popusta. 
Suma mora biti zakružena na dvije decimale. U pogled uvrstiti one proizvode koji su naručeni, uz uslov da je suma veća od 10000. 
Provjeriti sadržaj pogleda pri čemu ispis treba sortirati u opadajućem redoslijedu po vrijednosti sume.
*/

select * from DetaljiNarudzbe
create view  proizvodi 
as
select p.NazivProizvoda,round(sum(DN.CijenaProizvoda*DN.Kolicina),2) - round((sum(DN.CijenaProizvoda*DN.Popust*DN.Kolicina)),2) as [ukupno]
from Proizvod as P
inner join DetaljiNarudzbe as DN
on DN.ProizvodID=P.ProizvodID
where P.NarucenaKol>0
group by p.NazivProizvoda
having round(sum(DN.CijenaProizvoda*DN.Kolicina),2) - round((sum(DN.CijenaProizvoda*DN.Popust*DN.Kolicina)),2)>10000


select * from proizvodi 
order by 2 desc


select p.NazivProizvoda,round(sum(DN.CijenaProizvoda*DN.Kolicina*(1-DN.Popust)),2) as [ukupno]
from Proizvod as P
inner join DetaljiNarudzbe as DN
on DN.ProizvodID=P.ProizvodID
where P.NarucenaKol>0
group by p.NazivProizvoda
having round(sum(DN.CijenaProizvoda*DN.Kolicina*(1-DN.Popust)),2)>10000
order by 2 desc
----------------------------------------------------------------7.
--7a
/*
Koristeći vlastitu bazu podataka kreirati pogled koji će imati sljedeću strukturu: Kupac, NazivProizvoda, 
suma po cijeni proizvoda pri čemu će se u pogled smjestiti samo oni zapisi kod kojih je cijena proizvoda veća od srednje vrijednosti 
cijene proizvoda. Provjeriti sadržaj pogleda pri čemu izlaz treba sortirati u rastućem redoslijedu izračunatoj sumi.
*/

select * from Narudzba
select * from Proizvod
select * from DetaljiNarudzbe
select * from Narudzba
create view  kupac_pro 
as 
select N.Kupac,p.NazivProizvoda, sum(DN.CijenaProizvoda) as [Suma po proizvodu]
from Proizvod as p
inner join DetaljiNarudzbe as DN
on 
p.ProizvodID=DN.ProizvodID
inner join Narudzba as N
on DN.NarudzbaID=N.NarudzbaID
where DN.CijenaProizvoda> (select avg(CijenaProizvoda) from DetaljiNarudzbe) 
group by N.Kupac,p.NazivProizvoda

select * from kupac_pro
where [Suma po proizvodu]=123
/*
Koristeći vlastitu bazu podataka kreirati proceduru kojom će se, koristeći prethodno kreirani pogled, definirati parametri: kupac,
NazivProizvoda i SumaPoCijeni. Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara
(možemo ostaviti bilo koji parametar bez unijete vrijednosti), uz uslov da vrijednost sume bude veća od srednje vrijednosti suma koje
su smještene u pogled. Sortirati po sumi cijene. Procedura se treba izvršiti ako se unese vrijednost za bilo koji parametar.
Nakon kreiranja pokrenuti proceduru za sljedeće vrijednosti parametara:
1. SumaPoCijeni = 123
2. Kupac = Hanari Carnes
3. NazivProizvoda = Côte de Blaye
*/

SELECT DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
     TABLE_NAME = 'kupac_pro' AND 
     COLUMN_NAME = '[Suma po cijeni]'
select  


create procedure proc_kupac_pro
(@Kupac nvarchar(55)=null , 
@NazivProizvoda nvarchar(55)=null , 
@SumaPoCijeni MONEY=null ) 
as 
begin
select * from 
kupac_pro 
where Kupac=@Kupac or NazivProizvoda=@NazivProizvoda or [Suma po proizvodu]=@SumaPoCijeni and @SumaPoCijeni >(select avg([Suma po proizvodu]) from kupac_pro)
order by 3
end 
exec proc_kupac_pro @Kupac='Hanari Carnes'

exec proc_kupac_pro @NazivProizvoda = 'Côte de Blaye'

----------------------------------------------------------------8.
/*
a) Kreirati indeks nad tabelom Proizvod. Potrebno je indeksirati NazivDobavljaca. Uključiti i kolone StanjeNaSklad i NarucenaKol. 
Napisati proizvoljni upit nad tabelom Proizvod koji u potpunosti koristi prednosti kreiranog indeksa.*/

create index IX_NonClustered_Proizvod 
on Proizvod(NazivDobavljaca) 
include (StanjeNaSklad, NarucenaKol) 
set statistics time on 
select * from Proizvod
where NazivProizvoda='Konbu' and StanjeNaSklad<100 and NarucenaKol<100
select NazivDobavljaca, StanjeNaSklad, NarucenaKol from Proizvod


/*b) Uraditi disable indeksa iz prethodnog koraka.*/

alter index IX_NonClustered_Proizvod on Proizvod
disable
----------------------------------------------------------------9.
/*Napraviti backup baze podataka na default lokaciju servera.*/

backup database "1" 
to disk='1.bak'

----------------------------------------------------------------10.
/*Kreirati proceduru kojom će se u jednom pokretanju izvršiti brisanje svih pogleda i procedura koji su kreirani u Vašoj bazi.*/

create procedure brisi 
as
begin 
drop procedure proc_izmjeni
drop procedure proc_kupac_pro
drop view kupac_pro
drop view proizvodi
drop view view_upo_nar
end 