create database bp2_rok

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
 5 bodova */  insert into Proizvodi values ( '12AB-34CD','Upaljac', 'Pirotehnika', 'Pirotehnicka sredstva', 'Crna', '1.50', 20) insert into Prodaja values ( 1,2020,6,9,0.20,1.30),  ( 1,2020,6,2,0.10,1.40), ( 1,2019,8,1,0.05,1.45)select * from AdventureWorks2014.Sales.SalesOrderHeaderdrop table Proizvodialter table Proizvodi alter column ProizvodID int   insert into Proizvodi  select distinct P.ProductNumber, P.Name,PC.Name,PSC.Name, P.Color, P.ListPrice, (select sum(I.Quantity) from AdventureWorks2014.Production.ProductInventory as I where P.ProductID=I.ProductID having sum(I.Quantity) is not null) from AdventureWorks2014.Production.Product as P  inner join  AdventureWorks2014.Production.ProductSubcategory as PSC on P.ProductSubcategoryID=PSC.ProductSubcategoryIDinner join AdventureWorks2014.Production.ProductCategory as PConPC.ProductCategoryID=PSC.ProductCategoryIDinner join AdventureWorks2014.Sales.SpecialOfferProduct as SOP on P.ProductID=SOP.ProductIDinner join AdventureWorks2014.Sales.SalesOrderDetail as SODon SOD.ProductID=SOP.ProductIDinner join AdventureWorks2014.Sales.SalesOrderHeader as SOH on SOD.SalesOrderID=SOH.SalesOrderIDinner join AdventureWorks2014.Sales.SalesTerritory as STon ST.TerritoryID = SOH.TerritoryIDwhere ST.[Group] like 'Europe' and (select sum(I.Quantity) from AdventureWorks2014.Production.ProductInventory as I where P.ProductID=I.ProductID ) is not null/*  Radna verzija */select   (select ProizvodID from Proizvodi  as PR where ProizvodID),year(SOH.OrderDate), MONTH(SOH.OrderDate),SOD.UnitPrice,SOD.UnitPriceDiscount  from AdventureWorks2014.Production.Product as P  inner join AdventureWorks2014.Sales.SpecialOfferProduct as SOP on P.ProductID=SOP.ProductIDinner join AdventureWorks2014.Sales.SalesOrderDetail as SODon SOD.ProductID=SOP.ProductIDinner join AdventureWorks2014.Sales.SalesOrderHeader as SOH on SOD.SalesOrderID=SOH.SalesOrderIDinner join AdventureWorks2014.Sales.SalesTerritory as STon ST.TerritoryID = SOH.TerritoryIDwhere ST.[Group] like 'Europe' and (select sum(I.Quantity) from AdventureWorks2014.Production.ProductInventory as I where P.ProductID=I.ProductID ) is not nullgroup by P.ProductID,year(SOH.OrderDate), MONTH(SOH.OrderDate),SOD.UnitPrice,SOD.UnitPriceDiscount select * from AdventureWorks2014.Sales.SalesOrderDetailselect SOD.ProductID from AdventureWorks2014.Production.Product as PPinner join AdventureWorks2014.Sales.SpecialOfferProduct as SOP on PP.ProductID=SOP.ProductIDinner join AdventureWorks2014.Sales.SalesOrderDetail as SODon SOD.ProductID=SOP.ProductIDinner join AdventureWorks2014.Sales.SalesOrderHeader as SOH on SOD.SalesOrderID=SOH.SalesOrderIDinner join AdventureWorks2014.Sales.SalesTerritory as STon ST.TerritoryID = SOH.TerritoryIDwhere ST.[Group] like 'Europe'alter table Proizvodiadd col1 int  select * from Proizvodiupdate Proizvodiset col1=ProizvodIDalter table Proizvodi drop column ProizvodID/* Durmicevo rjesenje */ insert into Prodaja
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
		inner join AdventureWorks2014.Sales.SalesTerritory as STon ST.TerritoryID = soh.TerritoryID
where pp.ProductNumber collate database_default in (select Sifra from Proizvodi) and  ST.[Group] like 'Europe'
group by pp.ProductID,
	pp.ProductNumber,
	sod.SalesOrderID,
	soh.SalesOrderID,
	year(soh.OrderDate),
	MONTH(soh.OrderDate)