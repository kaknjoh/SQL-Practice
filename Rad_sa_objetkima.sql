﻿/*
a) U okviru baze AdventureWorks kopirati tabele Sale.Store, Sales.Customer, Sales.SalesTerritoryHistory i Sales.SalesPerson\
 u tabele istih naziva a koje će biti u šemi vjezba. Nakon kopiranja u novim tabelama definirati iste PK i FK kojima su definirani odnosi među tabelama.
*/

use AdventureWorks2014
go 
select * from Sale.Store
create schema vjezba
select * into 
vjezba.Store
from Sales.Store

select * into 
vjezba.Customer 
from Sales.Customer

select * into vjezba.SalesTerritoryHistory
from Sales.SalesTerritoryHistory

select * into vjezba.SalesPerson
from Sales.SalesPerson



-- PK 

alter table vjezba.Customer
add constraint PK_customer primary key (CustomerID)

alter table vjezba.Store
add constraint PK_store primary key (BusinessEntityID)

alter table vjezba.SalesPerson
add constraint PK_SalesPerson primary key(BusinessEntityID)

alter table vjezba.SalesTerritoryHistory
add constraint PK_SalesTerritoryHistory primary key (BusinessEntityID, TerritoryID, StartDate)


--FK 

alter table vjezba.Customer 
add constraint FK_cust_store foreign key (StoreID) references vjezba.Store(BusinessEntityID)


alter table vjezba.SalesTerritoryHistory
add constraint FK_salterrhist_saleperson foreign key (BusinessEntityID) references vjezba.SalesPerson(BusinessEntityID)


alter table vjezba.Store
add constraint FK_store_salesperson foreign key (SalesPersonID) references vjezba.SalesPerson(BusinessEntityID)

/*
b) Definirati sljedeća ograničenja (prva dva samo za tabele Customer i SalesPerson): 
	1. ModifiedDate kolone -					defaultna vrijednost je aktivni datum
	2. rowguid -								slučajno generisani niz znakova
	3. SalesQuota u tabeli SalesPerson -		defaultna vrijednost 0.00
												zabrana unosa vrijednost manje od 0.00
	4. EndDate u tabeli SalesTerritoryHistory - zabrana unosa starijeg datuma od StartDate
--constraint
ModifiedDate, rowguid
*/

alter table vjezba.Customer
add constraint DF_ModifiedDate_c default (getdate()) for ModifiedDate

alter table vjezba.Customer 
add constraint R_rowguid default (newid()) for rowguid

--sales

alter table vjezba.SalesPerson
add constraint DF_modifieddate_s default (getdate()) for ModifiedDate


alter table vjezba.SalesPerson
add constraint R_rowguid_s default (newid()) for rowguid

-- Sales PErson 

select * from vjezba.SalesPerson

alter table vjezba.SalesPerson 
add constraint DF_SalesQuota default (0.00) for SalesQuota

alter table vjezba.SalesPerson 
add constraint CH_SalesQuota check(SalesQuota >0)

-- SalesTerritoryHistory EndDate

alter table vjezba.SalesTerritoryHistory 
add constraint CH_EndDate check(EndDate>=StartDate)

/*
c) Dodati tabele u dijagram
*/

/*
U tabeli Customer:
a) dodati stalno pohranjenu kolonu godina koja će preuzimati godinu iz kolone ModifiedDate
b) ograničiti dužinu kolone rowguid na 10 znakova, a zatim postaviti defaultnu vrijednost na 10 slučajno generisanih znakova
c) obrisati PK tabele, a zatim definirati kolonu istog naziva koja će biti identity sa početnom vrijednošću 1 i inkrementom 2
d) izvršiti insert podataka iz tabele Sales.Customer
e) kreirati upit za prikaz zapisa u kojima je StoreID veći od 500, a zatim pokrenuti upit sa uključenim vremenom i planom izvršavanja
f) nad kolonom StoreID kreirati nonclustered indeks, a zatim pokrenuti upit sa uključenim vremenom i planom izvršavanja
g) kreirati upit za prikaz zapisa u kojima je TerritoryID veći od 1, a zatim pokrenuti upit sa uključenim vremenom i planom izvršavanja
h) nad kolonom TerritoryID kreirati nonclustered indeks, a zatim pokrenuti upit sa uključenim vremenom i planom izvršavanja
*/


alter table vjezba.Customer 
add godina as year(ModifiedDate)

select godina from vjezba.Customer

alter table vjezba.Customer
drop constraint R_rowguid


select rowguid from vjezba.Customer
-- b

alter table vjezba.Customer
alter column rowguid nvarchar(40)

update vjezba.Customer
set rowguid=LEFT(rowguid,10)

alter table vjezba.Customer
add constraint CH_rowguid check(len(rowguid)=10)

alter table vjezba.Customer 
add constraint DF_rowguid default (LEFT(newid(),10)) for rowguid


--c 

alter table vjezba.Customer 
drop constraint PK_Customer

alter table vjezba.Customer
drop column CustomerID


alter table vjezba.Customer
add CustomerID int  identity (1,2)

alter table vjezba.Customer
drop column CustomerID
alter table vjezba.Customer
add CustomerID int constraint PK_Customer primary key identity(1,2)


DBCC CHECKIDENT ('vjezba.Customer', RESEED, 1)  


select CustomerID, PersonID, StoreID, TerritoryID, AccountNumber, rowguid, ModifiedDate, godina
from vjezba.Customer

--d 
insert into vjezba.Customer
select PersonID, StoreID, TerritoryID, AccountNumber, left(rowguid,10), ModifiedDate
from Sales.Customer


--e 
set statistics time on
select CustomerID, PersonID, StoreID, TerritoryID, AccountNumber, rowguid, ModifiedDate, godina
from vjezba.Customer
where StoreID > 500 
order by StoreID
set statistics time off
--f 

create nonclustered index IX_storeID
on vjezba.Customer(StoreID)


set statistics time on
select CustomerID, PersonID, StoreID, TerritoryID, AccountNumber, rowguid, ModifiedDate, godina
from vjezba.Customer
where StoreID > 500 
order by StoreID
set statistics time off

drop index IX_storeID on vjezba.Customer

--g 
set statistics time on 
select CustomerID, PersonID, StoreID, TerritoryID, AccountNumber, rowguid, ModifiedDate, godina
from vjezba.Customer 
where TerritoryID>1 
order by StoreID

set statistics time off 


create nonclustered index IX_TerritoryID
on vjezba.Customer(TerritoryID)

drop index IX_TerritoryID on vjezba.Customer


/*
northwind
Koristeći tabele Order Details i Products kreirati upit kojim će se dati prikaz naziva proizvoda, 
jedinične cijene i količine uz uslov da se prikažu samo oni proizvodi koji počinju slovima A ili C. Uključiti prikaz vremena i plana izvršavanja.
*/


use NORTHWND
select * from [Order Details]
select * from [Products]

set statistics time on
select Products.ProductName, [Order Details].UnitPrice, [Order Details].Quantity
from [Order Details]
inner join Products 
on 
Products.ProductID=[Order Details].ProductID
where Products.ProductName like '[AC]%'
set statistics time off


/*
northwind
Koristeći tabele Order i Customers kreirati upit kojim će se dati prikaz naziva kompanije, poštanskog broja, datuma narudžbe i datuma 
isporuke uz uslov da se prikažu samo oni proizvodi za koje je razlika OrderDate i ShippedDate pozitivna. Uključiti prikaz vremena i plana izvršavanja.
*/


select * from Orders
select * from Customers

set statistics time on 

select Customers.CompanyName, Customers.PostalCode, Orders.OrderDate, Orders.ShippedDate 
from Customers 
inner join 
Orders
on
Customers.CustomerID=Orders.CustomerID
where day(Orders.OrderDate)-day(Orders.ShippedDate)>0 

set statistics time off 