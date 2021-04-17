﻿--northwind
/*
Koristeći tabele Employees, EmployeeTerritories, Territories i Region baze Northwind kreirati pogled view_Employee koji će sadržavati prezime i ime uposlenika kao polje ime i prezime,
 teritoriju i regiju koju pokrivaju. Uslov je da su stariji od 30 godina i pokrivaju terirotiju Western.
*/

use NORTHWND

select * from Employees
select * from EmployeeTerritories
select * from Territories
select * from Region

create view view_Employee AS 
select E.FirstName + E.LastName as 'Ime i prezime', 
T.TerritoryDescription , datediff(year,E.BirthDate, getdate()) as 'godine'
from EmployeeTerritories as ET
inner join
Employees as E
on E.EmployeeID=ET.EmployeeID
inner join Territories as T
on T.TerritoryDescription=ET.TerritoryID
inner join Region as R
on R.RegionID=T.RegionID

where datediff(year,E.BirthDate, getdate())>30 and R.RegionDescription='Western'



/*
Koristeći tabele Employee, Order Details i Orders baze Northwind kreirati pogled view_Employee2 koji će sadržavati ime uposlenika i ukupnu vrijednost svih narudžbi koje je taj 
uposlenik napravio u 1996. godini ako je ukupna vrijednost veća od 50000, pri čemu će se rezultati sortirati uzlaznim redoslijedom prema polju ime.
*/

select * from Employees
select * from [Order Details] 
select * from Orders

use NORTHWND
create view view_employee3 as 
select E.FirstName, SUM(Round((OD.UnitPrice-OD.Discount*OD.UnitPrice)*OD.Quantity,2)) as 'suma'
from Employees as E 
inner join Orders as O
on E.EmployeeID=O.EmployeeID
inner join 
[Order Details] as OD
on 
OD.OrderID=O.OrderID
where O.OrderDate BETWEEN '1/1/1997' and '12/31/1997'
group by E.FirstName 
having SUM(OD.UnitPrice*OD.Quantity)>50000 

go

/*
Koristeći tabele Orders i Order Details kreirati pogled koji će sadržavati polja: Orders.EmployeeID, [Order Details].ProductID i suma po UnitPrice.
*/

select * from Orders
select * from [Order Details]

create view view_orders as
select O.EmployeeID, OD.ProductID, SUM(OD.UnitPrice) as 'suma'
	from Orders as O
	inner join [Order Details] as OD on 
	O.OrderID=OD.OrderID

	group by O.EmployeeID, OD.ProductID

	/*
Koristeći prethodno kreirani pogled izvršiti ukupno sumiranje po uposlenicima. Sortirati po ID uposlenika.
*/

select EmployeeID ,SUM(suma)
from view_orders 
group by EmployeeID
order by 1 

select * from view_orders

/*
Koristeći tabele Categories, Products i Suppliers kreirati pogled koji će sadržavati polja: CategoryName, ProductName i CompanyName. 
*/

select * from Categories
select * from Products
select * from Suppliers


create view view_kat_prod_sup as
select C.CategoryName, P.ProductName, S.CompanyName
from Products as P
inner join 
Categories as C
on C.CategoryID=P.CategoryID
inner join 
Suppliers as S
on S.SupplierID=P.SupplierID
go


/*
Koristeći prethodno kreirani pogled prebrojati broj proizvoda po kompanijama. Sortirati po nazivu kompanije.
*/

select CompanyName, Count(*) 
from view_kat_prod_sup
group by CompanyName
order by 1


/*
Koristeći prethodno kreirani pogled prebrojati broj proizvoda po kategorijama. Sortirati po nazivu kompanije.
*/

select CategoryName, Count(*) as br_pr_kat
from view_kat_prod_sup
group by CategoryName
order by 1

select * from view_kat_prod_sup



/*
Koristeći bazu Northwind kreirati pogled view_supp_ship koji će sadržavati polja: Suppliers.CompanyName, Suppliers.City i Shippers.CompanyName. 
*/


create view view_supp_ship as 
select S.CompanyName, S.City , SH.CompanyName AS 'Dostavljac'
from Products as P
inner join Suppliers as S
on P.SupplierID=S.SupplierID 
inner join [Order Details] as OD
on OD.ProductID=P.ProductID
inner join Orders as O
on O.OrderID=OD.OrderID
inner join Shippers as SH
on O.ShipVia=SH.ShipperID


/*
Koristeći pogled view_supp_ship kreirati upit kojim će se prebrojati broj kompanija po prevoznicima.
*/

select Dostavljac, Count(*) 
from view_supp_ship
group by Dostavljac




/*
Koristeći pogled view_supp_ship kreirati upit kojim će se prebrojati broj prevoznika po kompanijama. Uslov je da se prikažu one kompanije koje su imale ili 
ukupan broj prevoza manji od 30 ili veći od 150. Upit treba da sadrži naziv kompanije, prebrojani broj prevoza i napomenu "nizak promet" za kompanije ispod 30 prevoza, 
odnosno, "visok promet" za kompanije preko 150 prevoza. Sortirati prema vrijednosti ukupnog broja prevoza.
*/

select * from view_supp_ship

select CompanyName, count(*), 'nizak promet'
from view_supp_ship
group by CompanyName 
having count(*)<30
union 
select CompanyName, count(*), 'visok promet'
from view_supp_ship
group by CompanyName 
having count(*)>150




/*
Koristeći tabele Products i Order Details kreirati pogled view_prod_price koji će sadržavati naziv proizvoda i sve cijene po kojima se prodavao. 
*/

select * from Products
select * from [Order Details]

create view view_prod_price1 as
SELECT	  distinct Products.ProductName, [Order Details].UnitPrice
FROM	[Order Details] INNER JOIN Products 
ON		[Order Details].ProductID = Products.ProductID


/*
Koristeći pogled view_prod_price dati pregled srednjih vrijednosti cijena proizvoda.
*/

select ProductName, AVG(UnitPrice) 
from view_prod_price1
group by ProductName


/*
Koristeći tabele Orders i Order Details kreirati pogled view_ord_quan koji će sadržavati ID uposlenika i vrijednosti količina bez ponavljanja koje je isporučio pojedini uposlenik.
*/

select * from Orders
select * from [Order Details]

create view view_ord_quan as
select distinct Orders.EmployeeID, [Order Details].Quantity
from Orders inner join [Order Details] on Orders.OrderID=[Order Details].OrderID

/*
Koristeći pogled view_ord_quan dati pregled srednjih vrijednosti količina po uposlenicima proizvoda.
*/

select EmployeeID, AVG(Quantity)
from view_ord_quan 
group by EmployeeID


/*
Koristeći tabele Categories, Products i Suppliers kreirati tabelu kat_prod_komp koja će sadržavati polja: CategoryName, ProductName i CompanyName. 
*/

select Categories.CategoryName, Products.ProductName, Suppliers.CompanyName
into kat_prod_komp 
from 
Categories inner join 
Products on 
Categories.CategoryID=Products.CategoryID
inner join Suppliers
on Suppliers.SupplierID=Products.SupplierID



/*
Koristeći tabele Orders i Customers kreirati pogled view_ord_cust koji će sadržavati ID uposlenika, Customers.CompanyName i Customers.City.
*/

select * from Orders
select * from Customers
create view ord_cus as 
select Orders.EmployeeID, Customers.CompanyName, Customers.City 
from Orders inner join 
Customers on 
Orders.CustomerID=Customers.CustomerID


/*
Koristeći pogled view_ord_cust kreirati upit kojim će se prebrojati sa koliko različitih kupaca je uposlenik ostvario saradnju.
*/

select EmployeeID, count(*)
from ord_cus
group by EmployeeID
order by 1,2