--NORTHWND
/*
Koristeći tabele Orders i Order Details kreirati upit koji će dati
sumu količina po Order ID, pri čemu je uslov:
a) da je vrijednost Freighta veća od bilo koje vrijednosti Freighta
narudžbi realiziranih u 12. mjesecu 1997. godine
b) da je vrijednost Freighta veća od svih vrijednosti Freighta
narudžbi realiziranih u 12. mjesecu 1997. godine
*/
use NORTHWND
select OrderID,
(select SUM(Quantity) from [Order Details] 
where Orders.OrderID=[Order Details].OrderID) as suma 

from Orders
where Freight >any (
select Freight from Orders where MONTH(OrderDate)=12 and YEAR(OrderDate)=1997)
--AdventureWorks2014
/*
Koristeći tabele Production.Product i Production.WorkOrder kreirati
upit sa podupitom koji će dati sumu OrderQty po nazivu proizvoda. pri
čemu se izostavljaju zapisi u kojima je suma NULL vrijednost. Upit
treba da sadrži naziv proizvoda i sumu po nazivu.
*/
use AdventureWorks2014
select * from Production.Product



select P.Name,SUM(PW.OrderQty) as 'Ukupno'  from Production.Product as P
inner join Production.WorkOrder as PW on 
P.ProductID=PW.ProductID
where 'Ukupno' is not null
group by P.Name



select * from(
select P.Name,SUM(PW.OrderQty) as 'Ukupno' from Production.Product as P
inner join Production.WorkOrder as PW 
on PW.ProductID=P.ProductID
where 


select P.Name, 
(select SUM(OrderQty) from Production.WorkOrder 
where P.ProductID=ProductID)
from Production.Product as P
where(select SUM(OrderQty) from  Production.WorkOrder 
where P.ProductID=ProductID) is not null 
/*
Koristeći tabele Sales.SalesOrderHeader i Sales.SalesOrderDetail
kreirati upit sa podupitom koji će prebrojati CarrierTrackingNumber po
SalesOrderID, pri čemu se izostavljaju zapisi čiji AccountNumber ne
spada u klasu 10-4030. Upit treba da sadrži SalesOrderID i prebrojani
broj.
*/
select SalesOrderID,
(select count(*) from Sales.SalesOrderDetail
where Sales.SalesOrderHeader.SalesOrderID=Sales.SalesOrderDetail.SalesOrderID)
from Sales.SalesOrderHeader
where LEFT(AccountNumber,7)<> '10-4030'
order by 2 desc
/*
Koristeći tabele Sales.SpecialOfferProduct i Sales.SpecialOffer
kreirati upit sa podupitom koji će prebrojati broj proizvoda po
kategorijama koji su u 2014. godini bili na specijalnoj ponudi pri
čemu se izostavljaju one kategorije kod kojih ne postoji ni jedan
proizvod koji nije bio na specijalnoj ponudi.
*/
select (select count(Category), SO.Category from Sales.SpecialOffer as SO
where SOP.Category=SO.Category and (Year(SO.StartDate)=2014 or Year(SO.EndDate)=2014 )
group by SO.Category)
from Sales.SpecialOffer as SOP 



select SOP.Category,SOP.SpecialOfferID
from Sales.SpecialOffer as SOP 
where(select SP.SpecialOfferID from 
Sales.SpecialOfferProduct as SP 
where SOP.SpecialOfferID=SP.SpecialOfferID) and (Year(SOP.StartDate)=2014 or Year(SOP.EndDate)=2014) 

use AdventureWorks2014
select * from Sales.SpecialOfferProduct
select * from Sales.SpecialOffer
--JOIN
--AdventureWorks2014
select SO.Category,
count( SOP.ProductID) 
from Sales.SpecialOffer as SO
inner join Sales.SpecialOfferProduct as SOP 
on SO.SpecialOfferID=SO.SpecialOfferID
where year(SO.StartDate) =2014 or year(SO.EndDate)=2014
group by Category 


select Category,
(select count(*)  from Sales.SpecialOfferProduct where Sales.SpecialOffer.SpecialOfferID=Sales.SpecialOfferProduct.SpecialOfferID
and YEAR(

/*
Koristeći tabele Person.Address, Sales.SalesOrderDetail i
Sales.SalesOrderHeader kreirati upit koji će dati sumu naručenih
količina po gradu i godini isporuke koje su izvršene poslije 2012.
godine.
*/
use AdventureWorks2014
select * from  Person.Address
select * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeader

select year([SOH].[ShipDate]) ,
SUM(SOD.OrderQty), P.City

from Person.Address as P
inner join Sales.SalesOrderHeader as SOH 
on P.AddressID=SOH.ShipToAddressID
inner join 
Sales.SalesOrderDetail as SOD
ON SOH.SalesOrderID=SOD.SalesOrderID
where year(SOH.ShipDate) > 2012
group by year(SOH.ShipDate),P.City
/*
Koristeći tabele Sales.Store, Sales.SalesPerson i
SalesPersonQuotaHistory kreirati upit koji će dati sumu prodajnih
kvota po nazivima prodavnica i ID teritorija, ali samo onih čija je
suma veća od 2000000. Sortirati po ID teritorije i sumi.
*/