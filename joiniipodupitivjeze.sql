﻿--PODUPITI
/*
Iz tabele Order Details baze Northwind dati prikaz ID narudžbe, ID proizvoda, jedinične cijene i srednje vrijednosti, te razliku cijene proizvoda u odnosu na srednju vrijednost cijene za sve proizvode u tabeli. Rezultat sortirati prema vrijednosti razlike u rastućem redoslijedu.*/
use NORTHWND

select 
OrderID,
ProductID,
UnitPrice,
(SELECT AVG(UnitPrice) from [Order Details]),
(SELECT AVG(UnitPrice) from [Order Details]) -UnitPrice as 'Razlika srednje cijene i cijene proizvoda'
from [Order Details]

/*
Iz tabele Products baze Northwind za sve proizvoda kojih ima na stanju dati prikaz ID proizvoda, naziv proizvoda, stanje zaliha i srednju vrijednost, te razliku stanja zaliha proizvoda u odnosu na srednju vrijednost stanja za sve proizvode u tabeli. Rezultat sortirati prema vrijednosti razlike u opadajućem redoslijedu.*/
select
ProductID, ProductName,UnitsInStock,
(SELECT avg(UnitsInStock) from Products) as 'Srednja vrijednost',
(SELECT avg(UnitsInStock) from Products)-UnitsInStock as 'Razlika srednje vrijednosti i pojedinacne'

from [Products]
/*
Upotrebom tabela Orders i Order Details baze Northwind prikazati ID narudžbe i kupca koji je kupio više od 10 komada proizvoda čiji je ID 15.*/
SELECT
O.OrderID,
O.EmployeeID
FROM Orders AS O
WHERE (SELECT Quantity FROM [Order Details] AS OD WHERE O.OrderID=OD.OrderID AND ProductID=15)>10


/*
Upotrebom tabela sales i stores baze pubs prikazati ID i naziv prodavnice u kojoj je naručeno više od 1 komada publikacije čiji je ID 6871.
*/
use pubs
SELECT 
ST.stor_id,
ST.stor_name
FROM Stores as ST
WHERE (select S.qty from Sales as S where ST.stor_id=S.stor_id AND S.ord_num= 6871)>1


--JOIN
/*
INNER JOIN
Rezultat upita su samo oni zapisi u kojima se podudaraju vrijednosti spojnog polja iz obje tabele.

LEFT OUTER JOIN
Lijevi spoj je inner join kojim su pridodati i oni zapisi koji postoje u "lijevoj" tabeli, ali ne i u "desnoj".
Kod lijevog spoja, na mjestu "povezne" kolone iz desne tabele bit će vraćena vrijednost NULL

RIGHT OUTER JOIN
Desni spoj je inner join kojim su pridodati i oni zapisi koji postoje u "desnoj" tabeli, ali ne i u "lijevoj".
Kod desnog spoja, na mjestu "povezne" kolone iz lijeve tabele bit će vraćena vrijednost NULL

FULL OUTER JOIN
Kod punog spoja obje tabele imaju ulogu „glavne“. 
U rezultatu će se naći svi zapisi iz obje tabele koji zadovoljavaju uslov, pri čemu će se u zapisima koji nisu upareni, na mjestu "poveznih" kolona iz obje tabele vratiti NULL vrijednost.
*/

/*
Iz tabela discount i stores baze pubs prikazati naziv popusta, ID i naziv prodavnice
*/
use pubs 

select 
D.discounttype,
s.stor_name
from discounts as D 
inner join stores as s 
on
D.stor_id=s.stor_id
/*
Iz tabela employee i jobs baze pubs prikazati ID i ime uposlenika, ID posla i naziv posla koji obavlja*/
select 
E.emp_id,
E.fname + ' ' + E.lname as 'Ime i prezime uposlenika',
J.job_id,
J.job_desc as 'Naziv posla'
from employee as E 
inner join jobs as J
on E.job_id=J.job_id

/*
U svim upitima treba vratiti sljedeće kolone: OsobaID iz obje tabele, RedovniPrihodiID, Neto, VanredniPrihodiID, IznosVanrednogPrihoda
U bazi Prihodi upotrebom:
a) left outer joina iz tabela Redovni i Vanredni prihodi prikazati id osobe iz obje tabele, neto i iznos vanrednog prihoda, pri čemu će se isključiti zapisi u kojima je ID osobe iz tabele redovni prihodi NULL vrijednost, a rezultat sortirati u rastućem redoslijedu prema ID osobe iz tabele redovni prihodi
b) right outer joina iz  tabela Redovni i Vanredni prihodi prikazati id osobe iz obje tabele, neto i iznos vanrednog prihoda, pri čemu će se isključiti zapisi u kojima je ID osobe iz tabele redovni prihodi NULL vrijednost, a rezultat sortirati u rastućem redoslijedu prema ID osobe iz tabele vanredni prihodi
c) full outer joina prikazati i redovne i vanredne prihode osobe, a rezultat sortirati u rastućem redoslijedu prema ID osobe iz tabela redovni i vanredni prihodi
*/
use prihodi

select 
RP.OsobaID, RP.RedovniPrihodiID,RP.Neto,
VP.OsobaID,
from RedovniPrihodi as RP
left outer join Osoba as O
on RP.OsobaID=O.OsobaID
left outer join
VanredniPrihodi as VP
on O.OsobaID=VP.OsobaID
where RP.OsobaID is not null


/*
Iz tabela Employees, EmployeeTerritories, Territories i Region baze Northwind prikazati prezime i ime uposlenika kao polje ime i prezime, teritoriju i regiju koju pokrivaju i stariji su od 30 godina.*/
use NORTHWND
select 
E.FirstName + ' '+ E.LastName as 'Ime i Prezime',
T.TerritoryDescription,
R.RegionDescription
from Employees as E
inner join EmployeeTerritories as ET
on E.EmployeeID=ET.EmployeeID
inner join Territories as T 
on ET.TerritoryID=T.TerritoryID
inner join Region as R
on T.RegionID=R.RegionID
where DATEDIFF(YEAR,E.BirthDate,GETDATE())>30


/*
Iz tabela Employee, Order Details i Orders baze Northwind prikazati ime i prezime uposlenika kao polje ime i prezime, jediničnu cijenu, količinu i ukupnu vrijednost pojedinačne narudžbe kao polje ukupno za sve narudžbe u 1997. godini, pri čemu će se rezultati sortirati prema novokreiranom polju ukupno.*/
select 
E.FirstName + ' '+ E.LastName as 'Ime i Prezime',
OD.UnitPrice,
OD.Quantity,
 OD.Quantity*OD.UnitPrice-OD.UnitPrice*OD.Discount as 'Ukupno'
from Employees as E 
inner join [Orders] as O
on E.EmployeeID=O.EmployeeID
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
where YEAR(O.OrderDate)=1997
order by 4

/*
Iz tabela Employee, Order Details i Orders baze Northwind prikazati ime uposlenika i ukupnu vrijednost svih narudžbi koje je taj uposlenik napravio u 1996. godini ako je ukupna vrijednost veća od 50000, pri čemu će se rezultati sortirati uzlaznim redoslijedom prema polju ime. Vrijednost sume zaokružiti na dvije decimale.*/
select 
E.FirstName,
 ROUND(SUM(OD.Quantity*OD.UnitPrice-OD.UnitPrice*OD.Discount),2) as 'Ukupno'
from Employees as E 
inner join [Orders] as O
on E.EmployeeID=O.EmployeeID
inner join [Order Details] as OD
on O.OrderID=OD.OrderID
where YEAR(O.OrderDate)=1996
group by E.FirstName
having ROUND(SUM(OD.Quantity*OD.UnitPrice-OD.UnitPrice*OD.Discount),2)>50000
order by 2 desc

/*
Iz tabela Categories, Products i Suppliers baze Northwind prikazati naziv isporučitelja (dobavljača), mjesto i državu isporučitelja (dobavljača) i 
naziv(e) proizvoda iz kategorije napitaka (pića) kojih na stanju ima više od 30 jedinica. Rezultat upita sortirati po državi.*/
use NORTHWND
select 
S.CompanyName,
S.Address,
S.Country,
P.ProductName,
P.QuantityPerUnit
from Suppliers as S
inner join Products as P
on S.SupplierID=P.SupplierID
inner join Categories as C
on P.CategoryID=C.CategoryID
where C.CategoryID=1 and P.UnitsInStock>30






/*
U tabeli Customers baze Northwind ID kupca je primarni ključ. U tabeli Orders baze Northwind ID kupca je vanjski ključ.
Dati izvještaj:
a) koliko je ukupno kupaca evidentirano u obje tabele (lista bez ponavljanja iz obje tabele)
a.1) koliko je ukupno kupaca evidentirano u obje tabele
b) da li su svi kupci obavili narudžbu
c) koji kupci nisu napravili narudžbu*/


/*
a) Provjeriti u koliko zapisa (slogova) tabele Orders nije unijeta vrijednost u polje regija kupovine.
b) Upotrebom tabela Customers i Orders baze Northwind prikazati ID kupca pri čemu u polje regija kupovine nije unijeta vrijednost, uz uslov da je kupac obavio narudžbu (kupac iz tabele Customers postoji u tabeli Orders). Rezultat sortirati u rastućem redoslijedu.
c) Upotrebom tabela Customers i Orders baze Northwind prikazati ID kupca pri čemu u polje regija kupovine nije unijeta vrijednost i kupac nije obavio ni jednu narudžbu (kupac iz tabele Customers ne postoji u tabeli Orders).
Rezultat sortirati u rastućem redoslijedu.*/


/*
Iz tabele HumanResources.Employee baze AdventureWorks2014 prikazati po 5 najstarijih zaposlenika muškog, odnosno, ženskog pola uz navođenje sljedećih podataka:
 radno mjesto na kojem se nalazi, datum rođenja, korisnicko ime i godine starosti. Korisničko ime je dio podatka u LoginID. 
 Rezultate sortirati prema polu uzlaznim, a zatim prema godinama starosti silaznim redoslijedom.*/

 use AdventureWorks2014
 select * from (select top 5  E.JobTitle,
 E.BirthDate,
 P.FirstName,
 E.Gender ,
 DATEDIFF(YEAR, E.BirthDate,GETDATE()) as 'Starost'
 from HumanResources.Employee as E
 inner join Person.Person as P
 on E.BusinessEntityID=P.BusinessEntityID
 where E.Gender='M'
 order by 5 desc) as q1
 
 union 
 select* from(select  top 5  E.JobTitle,
 E.BirthDate,
 P.FirstName,
 E.Gender as 'Spol',
 DATEDIFF(YEAR, E.BirthDate,GETDATE()) as 'Starost'
 from HumanResources.Employee as E
 inner join Person.Person as P
 on E.BusinessEntityID=P.BusinessEntityID
 where E.Gender='F'
 order by 5 desc) as q2
 order by q1.Gender asc ,q1.Starost desc

 select * from HumanResources.Employee
/*
Iz tabele HumanResources.Employee baze AdventureWorks2014 prikazati po 2 zaposlenika sa najdužim stažom bez obzira da li su u braku ili ne i 
obavljaju poslove inžinjera uz navođenje sljedećih podataka: radno mjesto na kojem se nalazi, datum zaposlenja i bračni status. 
Ako osoba nije u braku plaća dodatni porez, inače ne plaća. Rezultate sortirati prema bračnom statusu uzlaznim, a zatim prema stažu silaznim redoslijedom.*/
use AdventureWorks2014
select * from (select  top 2 substring(E.LoginID, CHARINDEX('\', E.LoginID)+1,len(E.LoginID)) as 'User' , 
DATEDIFF(YEAR, E.HireDate,GETDATE()) AS 'Staz', 
E.JobTitle,
E.HireDate,
E.MaritalStatus,
'Ne placa porez' as 'Porez'

from HumanResources.Employee as E
where E.JobTitle LIKE '%Enginee%'and E.MaritalStatus='M'
order by 2 desc, 5 asc) as q1
union 
select * from (select  top 2 substring(E.LoginID, CHARINDEX('\', E.LoginID)+1,len(E.LoginID)) as 'User' , 
DATEDIFF(YEAR, E.HireDate,GETDATE()) AS 'Staz', 
E.JobTitle,
E.HireDate,
E.MaritalStatus,
'Placa porez' as 'Porez'

from HumanResources.Employee as E
where E.JobTitle LIKE '%Enginee%'and E.MaritalStatus='S'
order by 2 desc, 5 asc) as q2
order by q1.MaritalStatus asc, q1.HireDate desc 


/*
Iz tabela HumanResources.Employee i Person.Person prikazati po 5 osoba koje se nalaze na 1, odnosno, 4.  organizacionom nivou,
 uposlenici su i žele primati email ponude od AdventureWorksa uz navođenje sljedećih polja: 
 ime i prezime osobe kao jedinstveno polje, organizacijski nivo na kojem se nalazi i da li prima email promocije.
  Pored ovih uvesti i polje koje će sadržavati poruke: Ne prima, Prima selektirane i Prima. 
  Sadržaj novog polja ovisi o vrijednosti polja EmailPromotion. Rezultat sortirati prema organizacijskom nivou i dodatno uvedenom polju.*/

 select * from(select top 5 P.FirstName + ' ' + P.LastName as 'Ime i Prezime',
 E.OrganizationLevel,
 Iif(P.EmailPromotion=0,'Ne prima',Iif(P.EmailPromotion=1,'Prima selektirane','Prima')) as 'Email'
 from Person.Person as P
 inner join HumanResources.Employee as E
 on E.BusinessEntityID=P.BusinessEntityID
 where E.OrganizationLevel=1) as q1
 union 
 select * from(select top 5 P.FirstName + ' ' + P.LastName as 'Ime i Prezime',
 E.OrganizationLevel,
 Iif(P.EmailPromotion=0,'Ne prima',Iif(P.EmailPromotion=1,'Prima selektirane','Prima')) as 'Email'
 from Person.Person as P
 inner join HumanResources.Employee as E
 on E.BusinessEntityID=P.BusinessEntityID
 where E.OrganizationLevel=4) as q2
 order by q1.OrganizationLevel, 3 



 use AdventureWorks2014
 
 select * from Person.Person
 /* 

Iz tabela Sales.SalesOrderDetail i Production.
Product prikazati 10 najskupljih stavki prodaje uz navođenje polja: naziv proizvoda, količina, cijena i iznos. 
Cijenu i iznos zaokružiti na dvije decimale. Iz naziva proizvoda odstraniti posljednji dio koji sadržava cifre i zarez.
U rezultatu u polju količina na broj dodati 'kom.', a u polju cijena i iznos na broj dodati 'KM'.*/
select * from Production.Product

select distinct top 10
SUBSTRING(P.Name,1,len(P.Name)-4) 'Product Name',
	SOD.OrderQty,
	ROUND(SOD.UnitPrice,2) 'UnitPrice',
	round(SOD.OrderQty*SOD.UnitPrice,2) 'Total'

from 
Sales.SalesOrderDetail as SOD
inner join Production.Product as P
on SOD.ProductID=P.ProductID
order by 4 desc








select 
	q1.[Product Name],
	convert(nvarchar(5),q1.OrderQty)+' .kom' 'Kolicina',
	convert(nvarchar(15),q1.UnitPrice)+ ' KM' 'UnitPrice',
	convert(nvarchar(15),q1.Total)+ ' KM' 'Total'
from(
select top 10
	SUBSTRING(P.Name,1,len(P.Name)-4) 'Product Name',
	SOD.OrderQty,
	ROUND(SOD.UnitPrice,2) 'UnitPrice',
	round(SOD.OrderQty*SOD.UnitPrice,2) 'Total'
from
	Sales.SalesOrderDetail as SOD inner join Production.Product as P
		ON P.ProductID=SOD.ProductID
order by Total desc) as q1

