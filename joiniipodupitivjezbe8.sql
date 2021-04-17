﻿--NORTHWND
/*
Koristeći tabele Orders i Order Details kreirati upit koji će dati sumu količina po Order ID, pri čemu je uslov:
a) da je vrijednost Freighta veća od bilo koje vrijednosti Freighta narudžbi realiziranih u 12. mjesecu 1997. godine
b) da je vrijednost Freighta veća od svih vrijednosti Freighta narudžbi realiziranih u 12. mjesecu 1997. godine
*/

use NORTHWND

select * from Orders
select * from [Order Details]

select O.OrderID, (select SUM(OD.Quantity) from [Order Details] as OD 
					where O.OrderID=OD.OrderID)
		from Orders as O 
		where Freight > ANY(select Freight from Orders where month(ShippedDate)=12 and year(ShippedDate)=1997)
		order by 2 


/* Pod b */ 

select O.OrderID, (select SUM(OD.Quantity) from [Order Details] as OD 
					where O.OrderID=OD.OrderID)
		from Orders as O 
		where Freight > all(select Freight from Orders where month(ShippedDate)=12 and year(ShippedDate)=1997)
		order by 2 



--AdventureWorks2014
/*
Koristeći tabele Production.Product i Production.WorkOrder kreirati upit sa podupitom koji će dati sumu OrderQty po nazivu proizvoda. 
pri čemu se izostavljaju zapisi u kojima je suma NULL vrijednost. 
Upit treba da sadrži naziv proizvoda i sumu po nazivu.
*/


use AdventureWorks2014

select * from Production.Product
select * from Production.WorkOrder

select PP.Name, (select SUM(PW.OrderQty) from Production.WorkOrder as PW where PP.ProductID=PW.ProductID 
having SUM(PW.OrderQty) is not null )
from Production.Product as PP
where (select SUM(PW.OrderQty) from Production.WorkOrder  as PW where PP.ProductID=PW.ProductID 
)is not null


/*
Koristeći tabele Sales.SalesOrderHeader i Sales.SalesOrderDetail kreirati upit sa podupitom koji će prebrojati CarrierTrackingNumber po SalesOrderID,
 pri čemu se izostavljaju zapisi čiji AccountNumber ne spada u klasu 10-4030. Upit treba da sadrži SalesOrderID i prebrojani broj.
*/

select * from Sales.SalesOrderHeader
select * from Sales.SalesOrderDetail

select SO.SalesOrderID, (select Count(SOD.CarrierTrackingNumber) from Sales.SalesOrderDetail as SOD 
where SO.SalesOrderID=SOD.SalesOrderID)
from Sales.SalesOrderHeader as SO
where  LEFT(SO.AccountNumber,7) <>'10-4030'



/*
Koristeći tabele Sales.SpecialOfferProduct i Sales.SpecialOffer kreirati upit sa podupitom koji će prebrojati broj proizvoda po kategorijama koji su u 2014. 
godini bili na specijalnoj ponudi pri čemu se izostavljaju one kategorije kod kojih ne postoji ni jedan proizvod koji nije bio na specijalnoj ponudi.
*/

select * from Sales.SpecialOfferProduct 
select * from Sales.SpecialOffer

select SO.Category, (select COUNT(SOP.ProductID) FROM Sales.SpecialOfferProduct as SOP 
where SO.Category=SO.Category and SO.SpecialOfferID=SOP.SpecialOfferID and year(SOP.ModifiedDate)=2014)
from Sales.SpecialOffer as SO 
where  (select COUNT(SOP.ProductID) FROM Sales.SpecialOfferProduct as SOP 
where SO.Category=SO.Category and SO.SpecialOfferID=SOP.SpecialOfferID and year(SOP.ModifiedDate)=2014) <> 0 


select	Sales.SpecialOffer.Category,
		(select COUNT (*) from Sales.SpecialOfferProduct
		where Sales.SpecialOffer.SpecialOfferID = Sales.SpecialOfferProduct.SpecialOfferID and
		YEAR (Sales.SpecialOfferProduct.ModifiedDate) = 2014)
from Sales.SpecialOffer
where	(select COUNT (*) from Sales.SpecialOfferProduct
		where Sales.SpecialOffer.SpecialOfferID = Sales.SpecialOfferProduct.SpecialOfferID and
		YEAR (Sales.SpecialOfferProduct.ModifiedDate) = 2014) <> 0

order by 1



/*
Koristeći tabele SpecialOfferProduct i SpecialOffer prebrojati broj narudžbi po kategorijama popusta od 0 do 15%, pri čemu treba uvesti novu kolona kategorija u koju će biti 
unijeta vrijednost popusta, npr. 0, 1, 2... Rezultat sortirati prema koloni kategorija u rastućem redoslijedu.
 Upit treba da vrati kolone: SpecialOfferID, prebrojani broj i kategorija.
*/


--JOIN
--AdventureWorks2014
/*
Koristeći tabele Person.Address, Sales.SalesOrderDetail i Sales.SalesOrderHeader kreirati upit koji će dati sumu naručenih količina po gradu i godini 
isporuke koje su izvršene poslije 2012. godine.
*/

select * from Person.Address
select  * from Sales.SalesOrderDetail
select * from Sales.SalesOrderHeader


select SUM(SOD.OrderQty),  PA.City 
from Sales.SalesOrderDetail as SOD inner join 
Sales.SalesOrderHeader as SOH on SOD.SalesOrderID=SOH.SalesOrderID 
inner join Person.Address as PA
on Pa.AddressID=SOH.ShipToAddressID
where year(SOH.ShipDate)>2012
group by PA.City ,year(SOH.ShipDate)
order by 1 


/*
Koristeći tabele Sales.Store, Sales.SalesPerson i SalesPersonQuotaHistory kreirati upit koji će dati sumu prodajnih kvota po nazivima prodavnica i ID teritorija,
 ali samo onih čija je suma veća od 2000000. Sortirati po ID teritorije i sumi.
*/

select * from Sales.Store
select * from Sales.SalesPerson
select * from Sales.SalesPersonQuotaHistory

select S.Name, SP.TerritoryID,SUM(SPQH.SalesQuota) from 
Sales.Store as S 
inner join Sales.SalesPerson as SP
on S.SalesPersonID=SP.BusinessEntityID
inner join Sales.SalesPersonQuotaHistory as SPQH on
SP.BusinessEntityID=SPQH.BusinessEntityID
group by  S.Name, SP.TerritoryID
having SUM(SPQH.SalesQuota)>200000

/*
Koristeći tabele Person.Person, Person.PersonPhone, Person.PhoneNumberType i Person.Password kreirati upit kojim će se dati informacija da li PasswordHash sadrži bar jedan +.
 Ako sadrži u koloni status_hash dati poruku "da", inače ostaviti prazn0. Upit treba da sadrži kolone Person.Person.PersonType, Person.PersonPhone.PhoneNumber, 
 Person.PhoneNumberType.Name, Person.Password.PasswordHash.
*/


select * from  Person.Person
select * from Person.PersonPhone
select * from  Person.PhoneNumberType 
select * from Person.Password



select Person.Person.PersonType, Person.PersonPhone.PhoneNumber, 
 Person.PhoneNumberType.Name, Person.Password.PasswordHash, 'da' status_hash
FROM            Person.Password INNER JOIN
                         Person.Person ON Person.Password.BusinessEntityID = Person.Person.BusinessEntityID INNER JOIN
                         Person.PersonPhone ON Person.Person.BusinessEntityID = Person.PersonPhone.BusinessEntityID INNER JOIN
                         Person.PhoneNumberType ON Person.PersonPhone.PhoneNumberTypeID = Person.PhoneNumberType.PhoneNumberTypeID 
						 WHERE CHARINDEX('+',Person.Password.PasswordHash)=0
						 union 

select Person.Person.PersonType, Person.PersonPhone.PhoneNumber, 
 Person.PhoneNumberType.Name, Person.Password.PasswordHash, 'ne' status_hash
FROM            Person.Password INNER JOIN
                         Person.Person ON Person.Password.BusinessEntityID = Person.Person.BusinessEntityID INNER JOIN
                         Person.PersonPhone ON Person.Person.BusinessEntityID = Person.PersonPhone.BusinessEntityID INNER JOIN
                         Person.PhoneNumberType ON Person.PersonPhone.PhoneNumberTypeID = Person.PhoneNumberType.PhoneNumberTypeID 
						 WHERE CHARINDEX('+',Person.Password.PasswordHash)>0


/*
Koristeći tabele HumanResources.Employee i HumanResources.EmployeeDepartmentHistory kreirati upit koji će dati pregled ukupno ostaverenih bolovanja po departmentu, 
pri čemu će se uzeti u obzir samo one osobe čiji nacionalni broj počinje ciframa 10, 20, 80 ili 90.
*/


select * from HumanResources.Employee 
select * from HumanResources.EmployeeDepartmentHistory

select EDH.DepartmentID, sum(E.SickLeaveHours) from 
HumanResources.Employee as E inner join
HumanResources.EmployeeDepartmentHistory as EDH
on E.BusinessEntityID=EDH.BusinessEntityID
where left(E.NationalIDNumber,2) IN ('10','20','80','90')
group by EDH.DepartmentID




/*
Koristeći tabele Purchasing.PurchaseOrderHeader, Purchasing.Vendor, Purchasing.PurchaseOrderDetail i Purchasing.ShipMethod kreirati upit koji će sadržavati kolone VendorID, 
Name vendora, EmployeeID, ShipDate, ShipBase i UnitPrice, uz uslov da je UnitPrice veća od ShipBase.
*/

select * from Purchasing.PurchaseOrderHeader
select * from Purchasing.Vendor
select * from Purchasing.PurchaseOrderDetail
select * from Purchasing.ShipMethod

select  V.Name, POH.EmployeeID, POH.ShipDate, POD.UnitPrice
from Purchasing.PurchaseOrderHeader as POH inner join 
Purchasing.Vendor as V
on POH.VendorID=V.BusinessEntityID 
inner join Purchasing.PurchaseOrderDetail as POD on
POD.PurchaseOrderID=POH.PurchaseOrderID
inner join 
Purchasing.ShipMethod as SM on
SM.ShipMethodID=POH.ShipMethodID

where POD.UnitPrice > SM.ShipBase



/*
Koristeći tabele Person.Person, Sales.PersonCreditCard i Person.Password kreirati upit koji će da vrati polja BusinessEntityID, PersonType, CreditCardID i PasswordSalt.
*/
select * from Person.Person
select * from Sales.PersonCreditCard
select * from Person.Password

select PP.BusinessEntityID, PP.PersonType, PCC.CreditCardID, PA.PasswordSalt 
from Person.Person as PP 
inner join 
Sales.PersonCreditCard as PCC 
on
PP.BusinessEntityID=PCC.BusinessEntityID 
join 
Person.Password as PA 
on PA.BusinessEntityID=PP.BusinessEntityID



/*
Koristeći tabele  Production.ProductModelProductDescriptionCulture, Production.ProductModel i Production.Product kreirati upit koji će vratiti polja CultureID, 
Name iz tabele Production.ProductModel, Name iz tabele Production.Product i Color, te prebrojani broj po koloni Color. Uslov je da se ne prikazuju upiti u kojima nije unijeta 
vrijednost za CatalogDescription iz tabele Production.ProductModel.
*/


