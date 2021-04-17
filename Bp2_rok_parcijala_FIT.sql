﻿create database bp2_rok

use bp2_rok
/*  1 
Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea. U postupku kreiranja u obzir uzeti
samo DEFAULT postavke.
Potrebno je kreirati bazu podataka u kojoj će se pohraniti podaci za potrebe analize prodaje proizvoda na
području Evrope. Unutar baze podataka kreirati tabele sa sljedećom strukturom:
a) Proizvodi
i. ProizvodID, automatski generator vrijednosti i primarni ključ
ii. Sifra, polje za unos 25 UNICODE karaktera (jedinstvena vrijednost i obavezan unos)
iii. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
iv. Kategorija, polje za unos 50 UNICODE karaktera (nije obavezan unos)
v. Podkategorija, polje za unos 50 UNICODE karaktera (nije obavezan unos)
vi. Boja, polje za unos 15 UNICODE karaktera (nije obavezan unos)
vii. Cijena, polje za unos decimalnog broja (obavezan unos)
viii. StanjeZaliha, polja za unos cijelog broja (obavezan unos)
b) Prodaja
i. ProdajaID, automatski generator vrijednosti i primarni ključ
ii. ProizvodID, referenca na tabelu Proizvodi (obavezan unos)
iii. Godina, polje za unos cijelog broja (obavezan unos)
iv. Mjesec, polje za unos cijelog broja (obavezan unos)
v. UkupnoProdano, polje za unos cijelog broja (obavezan unos)
vi. UkupnoPopust, polje za unos decimalnog broja (obavezan unos)
vii. UkupnoIznos, polje za unos decimalnog broja (obavezan iznos)
*/ 
create table Proizvodi(
ProizvodID int primary key identity,
Sifra nvarchar(25) unique not null, 
Naziv nvarchar(50) not null, 
Kategorija nvarchar(50), 
Podkategora nvarchar(50), 
Boja nvarchar(15), 
Cijena decimal(10,2) not null, 
StanjeZaliha int not null)


create table Prodaja(
ProdajaID int primary key identity, 
ProizvodID int not null, 
Godina int not null, 
Mjesec int  not null,
UkupnoProdano int not null,
UkupnoPopust decimal(10,2) not null,
UkupnoIznos decimal(10,2) not null )


/*  2 */ 

/* 2. Popunjavanje tabela i manipulacija sa podacima.
a) U tabelu Proizvodi dodati jedan zapis proizvoljno, a zatim za dodani proizvod dodati tri vezana zapisa u
tabelu Prodaja (proizvoljni podaci). 5 bodova
b) Iz baze podataka AdventureWorks2014 u tabelu Proizvodi importovati sve proizvode koji su prodavani na
području Evrope (bez duplikata). Pri tome je potrebno zadržati identifikator proizvoda, te voditi računa da
se prebace svi proizvodi bez obzira da li pripadaju određenoj podkategoriji. Kolone koje su potrebne nalaze
se u više tabela, a to su:
i. Šifra, Naziv, Boja i Cijena se nalaze u tabeli Product (ProductNumber, Name, Color, ListPrice)
ii. Kategorija i Podkategorija se nalaze u tabelama ProductCategory i ProductSubcategory (Name)
iii. Stanje zaliha je potrebno podupitom izračunati iz tabele ProductInventory (Quantity), sve lokacije
 15 bodova
c) Iz baze podataka AdventureWorks2014 u tabelu Prodaja importovati podatke o prodaji prethodno
importovanih proizvoda. Pri tome je potrebno voditi računa da se podaci importuju grupisano i sortirano po
identifikatoru proizvoda, godini i mjesecu. Također, kolone UkupnoPopust i UkupnoIznos zaokružiti na dvije
decimale. 15 bodova
d) Svim proizvodima u tabeli Proizvodi postaviti stanje zaliha na trenutno stanje iz baze podataka
AdventureWorks2014. 5 bodova
e) Iz tabele Prodaja obrisati sve zapise o prodaji proizvoda koji pripadaju podkategoriji „Pedals“.
 5 bodova
select
	(select ProizvodID from Proizvodi where  Sifra collate database_default in (select pp.ProductNumber from AdventureWorks2014.Production.Product) ),
	year(soh.OrderDate),
	MONTH(soh.OrderDate),
	sum(sod.OrderQty),
	(select sum(UnitPriceDiscount) from AdventureWorks2014.Sales.SalesOrderDetail where SalesOrderID=soh.SalesOrderID)/(select count(*) from AdventureWorks2014.Sales.SalesOrderDetail where SalesOrderID=sod.SalesOrderID),
	round((select sum(UnitPrice*OrderQty-(UnitPrice*OrderQty*UnitPriceDiscount)) from AdventureWorks2014.Sales.SalesOrderDetail where SalesOrderID=soh.SalesOrderID),2)
from
	AdventureWorks2014.Production.Product pp
	inner join AdventureWorks2014.Sales.SalesOrderDetail sod
		on sod.ProductID=pp.ProductID
	inner join AdventureWorks2014.Sales.SalesOrderHeader soh
		on soh.SalesOrderID=sod.SalesOrderID
		inner join AdventureWorks2014.Sales.SalesTerritory as ST
where pp.ProductNumber collate database_default in (select Sifra from Proizvodi) and  ST.[Group] like 'Europe'
group by pp.ProductID,
	pp.ProductNumber,
	sod.SalesOrderID,
	soh.SalesOrderID,
	year(soh.OrderDate),
	MONTH(soh.OrderDate)