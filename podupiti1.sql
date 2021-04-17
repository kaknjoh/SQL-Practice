﻿--NORTHWND
/*
Koristeći tabele Orders i Order Details kreirati upit koji će dati sumu količina po Order ID, pri čemu je uslov:
a) da je vrijednost Freighta veća od bilo koje vrijednosti Freighta narudžbi realiziranih u 12. mjesecu 1997. godine
b) da je vrijednost Freighta veća od svih vrijednosti Freighta narudžbi realiziranih u 12. mjesecu 1997. godine
*/

use NORTHWND

select * from Orders 
select * from [Order Details]
select O.OrderID, (select SUM(OD.UnitPrice*OD.Quantity) from [Order Details] as OD where
O.OrderID=OD.OrderID)
from
Orders as O
where Freight > any (select Freight from Orders where year(ShippedDate)=1997 and month(ShippedDate)=12 )


select O.OrderID, (select SUM(OD.UnitPrice*OD.Quantity) from [Order Details] as OD where
O.OrderID=OD.OrderID)
from
Orders as O
where Freight > all (select Freight from Orders where year(ShippedDate)=1997 and month(ShippedDate)=12 )



--AdventureWorks2014
/*
Koristeći tabele Production.Product i Production.WorkOrder kreirati upit sa podupitom koji će dati sumu OrderQty po nazivu proizvoda.
 pri čemu se izostavljaju zapisi u kojima je suma NULL vrijednost. Upit treba da sadrži naziv proizvoda i sumu po nazivu.
*/
use AdventureWorks2014
select * from Production.Product
select * from Production.WorkOrder

select P.Name , 
(select SUM(OrderQty) from 
Production.WorkOrder as WO 
where P.ProductID=WO.ProductID
having sum(OrderQty) is not null)
from Production.Product as P
where  (select SUM(OrderQty) from 
Production.WorkOrder as WO 
where P.ProductID=WO.ProductID
having sum(OrderQty) is not null) is not null

/*
Koristeći tabele Sales.SalesOrderHeader i Sales.SalesOrderDetail kreirati upit sa podupitom koji će prebrojati CarrierTrackingNumber po SalesOrderID,
 pri čemu se izostavljaju zapisi čiji AccountNumber ne spada u klasu 10-4030. Upit treba da sadrži SalesOrderID i prebrojani broj.
*/
select * from Sales.SalesOrderHeader 
select * from Sales.SalesOrderDetail
select SOH.SalesOrderID, (select count(CarrierTrackingNumber) 
from Sales.SalesOrderDetail as SOD
where SOH.SalesOrderID=SOD.SalesOrderID), AccountNumber
from Sales.SalesOrderHeader as SOH
where  LEFT(AccountNumber,7)<>'10-4030'



select	SalesOrderID,	
		(select COUNT (CarrierTrackingNumber) from Sales.SalesOrderDetail 
		where Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID) as broj
from Sales.SalesOrderHeader
where LEFT (AccountNumber,7) <> '10-4030'
order by 1
/*
Koristeći tabele Sales.SpecialOfferProduct i Sales.SpecialOffer kreirati upit sa podupitom koji će prebrojati broj proizvoda po kategorijama koji su u 2014.
 godini bili na specijalnoj ponudi pri čemu se izostavljaju one kategorije kod kojih ne postoji ni jedan proizvod koji nije bio na specijalnoj ponudi.
*/


select * from Sales.SpecialOfferProduct
select  * from Sales.SpecialOffer

select SO.Category, (select count(ProductID) from Sales.SpecialOfferProduct as SOP
where SO.SpecialOfferID=SOP.SpecialOfferID

having count(ProductID)>0)
from Sales.SpecialOffer as SO
where year(ModifiedDate)=2014



/*
Koristeći kolonu AccountNumber tabele Sales.Customer prebrojati broj zapisa prema broju cifara brojčanog dijela podatka iz ove kolone. 
Rezultat sortirati u rastućem redoslijedu.
 */
 
 select * from Sales.Customer
 
 select len(convert(int,right(AccountNumber,len(AccountNumber)-charindex('W', AccountNumber)))),count(*) from 
 Sales.Customer
 group by len(convert(int,right(AccountNumber,len(AccountNumber)-charindex('W', AccountNumber))))



 select len (cast 
		(substring (AccountNumber, CHARINDEX ('W',AccountNumber) +1, 
		LEN (AccountNumber) - CHARINDEX ('W',AccountNumber)) as int))
		, COUNT (*)
from Sales.Customer
group by len (cast 
		(substring (AccountNumber, CHARINDEX ('W',AccountNumber) +1, 
		LEN (AccountNumber) - CHARINDEX ('W',AccountNumber)) as int))
order by 1