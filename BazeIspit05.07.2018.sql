create database kaknjo_12
use kaknjo_12

create table Klijenti(
KlijentID int identity primary key , 
Ime nvarchar(30) not null, 
Prezime nvarchar(30) not null,
Telefon nvarchar(20) not null, 
Mail nvarchar(50) not null unique, 
BrojRacuna nvarchar(20) not null, 
KorisnickoIme nvarchar(20) not null, 
Lozinka nvarchar(20) not null
) 

create table Transakcije 
( 
TransakcijaID int identity primary key, 
Datum datetime not null, 
TipTransakcije nvarchar(30) not null, 
PosiljacID int not null ,
PrimalacID int not null, 
Svrha nvarchar(50) not null, 
Iznos decimal(10,2)
constraint FK_Transakcije_Klijenti_Posiljalac foreign key (PosiljacID) references Klijenti(KlijentID), 
constraint FK_Transkacije_Klijenti_Primalac foreign key(PrimalacID) references Klijenti(KlijentID)
)


select * from AdventureWorks2014.Purchasing.Vendor

insert into Klijenti 
select p.FirstName, p.LastName, PP.PhoneNumber, EM.EmailAddress, (select V.AccountNumber from AdventureWorks2014.Person.BusinessEntity as BE inner join AdventureWorks2014.Purchasing.Vendor as V on BE.BusinessEntityID=V.BusinessEntityID) .FirstName+'.'+p.LastName,  right(Pass.PasswordHash,8)
from  AdventureWorks2014.Person.Person as p

inner join 
 AdventureWorks2014.Person.EmailAddress as EM on
 p.BusinessEntityID=EM.BusinessEntityID
 inner join  AdventureWorks2014.Person.PersonPhone as PP
 on p.BusinessEntityID=PP.BusinessEntityID
 inner join  AdventureWorks2014.Person.Password as Pass
 on P.BusinessEntityID=Pass.BusinessEntityID
 inner join  AdventureWorks2014.Person.BusinessEntity as BE
 on BE.BusinessEntityID=p.BusinessEntityID
 inner join  AdventureWorks2014.Purchasing.Vendor as V
 on BE.BusinessEntityID=V.BusinessEntityID


 select t.acc
from (select V.AccountNumber as acc,Be.BusinessEntityID as Bt from 

AdventureWorks2014.Purchasing.Vendor as V
inner join 
 AdventureWorks2014.Person.BusinessEntity  as Be
 on Be.BusinessEntityID=V.BusinessEntityID) as t
inner join  AdventureWorks2014.Person.Person as p
on p.BusinessEntityID=t.Bt



select * from AdventureWorks2014.Person.BusinessEntity



CREATE TABLE Zaposlenici( 
ZaposlenikID int identity primary key,
Ime nvarchar(30) not null,
Prezime nvarchar(30) not null, 
Spol nvarchar(10) not null ,
JMBG  nvarchar(13) not null, 
DatumRodjenja date default getdate(),
Adresa nvarchar(100) not null, 
Email nvarchar(100) not null unique , 
KorisnickoIme nvarchar(60) not null, 
Lozinka nvarchar(30) not null
)


create table Artikli(
 ArtikalID int identity  primary key, 
 Naziv nvarchar(50), 
 Cijena decimal(10,2) not null,
 StanjeNaSkladistu int not null) 

 create table Prodaja(
 ZaposlenikID int,
 ArtikalID int ,
 Datum date not null default getdate(), 
 Kolicina decimal(10,2) not null,
 constraint PK_Prodaja primary key (ArtikalID,ZaposlenikID,Datum),
 constraint FK_Prodaja_Artikal foreign key(ArtikalID) references Artikli(ArtikalID), 
 constraint FK_Prodaja_Zaposlenici foreign key (ZaposlenikID) references Zaposlenici(ZaposlenikID)
 )
 

 /* 2-a */ 
 use NORTHWND 
 SELECT * FROM NORTHWND.dbo.Orders
 
select * from Zaposlenici

delete from Zaposlenici 
where ZaposlenikID=8

 insert into Zaposlenici 
 select E.EmployeeID, E.FirstName, E.LastName, IIF(E.TitleOfCourtesy in('Mr.','Dr.'), 'Musko' , 'Zensko') , convert(nvarchar,year(E.BirthDate))+
 convert(nvarchar,month(E.BirthDate))+convert(nvarchar,day(E.BirthDate)), E.BirthDate, E.Country+','+E.City+','+E.Address, lower(E.FirstName)+
 right(year(E.BirthDate),2)+'@poslovna.ba',
 E.FirstName+'.'+E.LastName, reverse(substring(E.Notes, 15,6)+left(E.Extension,2)+'#' +convert(nvarchar,day(BirthDate)-day(HireDate)))
 from NORTHWND.dbo.Employees as E
 where Year(getDate())-year(E.BirthDate) >60 
 select * from Zaposlenici

 insert into Artikli 
 select P.ProductID, P.ProductName, P.UnitPrice, P.UnitsInStock
 from NORTHWND.dbo.Products as P
 inner join NORTHWND.dbo.[Order Details] as OD
 on OD.ProductID=P.ProductID
 inner join 
 NORTHWND.dbo.Orders as O
 on O.OrderID=OD.OrderID
 where year(O.OrderDate)=1997 and (month(O.OrderDate)=8 or month(O.OrderDate)=9)
 group by P.ProductID,  P.ProductName, P.UnitPrice, P.UnitsInStock


 select * from NORTHWND.dbo.[Order Details]

 insert into Prodaja 
 select Z.ZaposlenikID, A.ArtikalID, O.OrderDate, OD.Quantity 
 from NORTHWND.dbo.[Order Details] as OD
 inner join Artikli as A
 on A.ArtikalID=OD.ProductID
 inner join 
 NORTHWND.dbo.Orders as O
 on OD.OrderID=O.OrderID
 inner join Zaposlenici as Z
 on O.EmployeeID=Z.ZaposlenikID
 where year(O.OrderDate)=1997 and (month(O.OrderDate)=8 or month(O.OrderDate)=9)



 /* 3 */ 

 alter table Zaposlenici 
 alter column Adresa nvarchar(100)

 alter table Artikli
 add Kategorija nvarchar(50) 
 select * from Zaposlenici
 update Zaposlenici 
 set DatumRodjenja=convert(date,(convert(nvarchar,convert(int, year(DatumRodjenja))+2)+'-'+convert(nvarchar,substring(convert(nvarchar,DatumRodjenja),5,5))))
 where Spol='Zensko'




 select convert(nvarchar,convert(int, year(DatumRodjenja))+2)+convert(nvarchar,substring(convert(nvarchar,DatumRodjenja),5,5)) from Zaposlenici where Spol='Zensko'


 /* 4*/ 
 
update Zaposlenici 
set KorisnickoIme=substring(convert(nvarchar,year(DatumRodjenja)),2,2) 

/* 5 */ 

create view view_zalihe
as
(
select A.Naziv , A.StanjeNaSkladistu, convert(nvarchar,sum(P.Kolicina))+'kom' as broj_narucenih,ABS( count(P.Kolicina)-A.StanjeNaSkladistu )as [Potrebno naruciti]
from Artikli as A
inner join Prodaja as P
on A.ArtikalID=P.ArtikalID
 
group by A.Naziv , A.StanjeNaSkladistu
having sum(P.Kolicina)>A.StanjeNaSkladistu
) 

select * from view_zalihe

SELECT v.Naziv ,v.StanjeNaSkladistu , v.broj_narucenih, v.[Potrebno naruciti]
from view_zalihe  as v
where v.broj_narucenih>v.StanjeNaSkladistu 


/* 6 */ 

select * from Prodaja
create view view_prod
as
(
select Z.Ime + Z.Prezime  as ImePrezime, A.Naziv, ISNULL(A.Kategorija,'n/a')as Kategorija, P.Kolicina ,cast(round(A.Cijena*P.Kolicina,2)as DECIMAL(10,2)) as Zarada
from Artikli as A
inner join Prodaja as P
on A.ArtikalID=P.ArtikalID
inner join Zaposlenici as Z
on Z.ZaposlenikID=P.ZaposlenikID
where Z.Adresa like 'USA%'
)

select ImePrezime, Naziv,Kategorija,SUM(Kolicina) as Kolicina,SUM(Zarada)
from view_prod
group by ImePrezime,Naziv,Kategorija


select P.ZaposlenikID, count(P.ZaposlenikID)
from Prodaja as P 
where P.ZaposlenikID=5
group by P.ZaposlenikID





select Z.Ime, Z.Prezime 
from Zaposlenici as Z
inner join Prodaja as P
on P.ZaposlenikID=Z.ZaposlenikID
where P.Datum='1997-09-22' or P.Datum='1997-08-22'

select * from Zaposlenici


/* 7 */ 


create view view_prod_1
as
(
select Z.Ime + Z.Prezime  as ImePrezime,Z.Spol as Spol, P.Datum,  A.Naziv, ISNULL(A.Kategorija,'n/a')as Kategorija, P.Kolicina ,cast(round(A.Cijena*P.Kolicina,2)as DECIMAL(10,2)) as Zarada
from Artikli as A
inner join Prodaja as P
on A.ArtikalID=P.ArtikalID
inner join Zaposlenici as Z
on Z.ZaposlenikID=P.ZaposlenikID
where Z.Spol='Zensko' and A.Kategorija is null
)

select ImePrezime, Spol, Naziv, Datum
from view_prod_1 
where Datum in ('1997-08-22','1997-09-22') and Naziv like '[CG]%'


/* 8 */ 
select month(P.Datum) from Prodaja as P


create view lista_zaposlenika
as
(
select Z.ZaposlenikID, Z.Ime + Z.Prezime  as ImePrezime,Z.Spol as Spol, P.Datum,Z.DatumRodjenja
from Artikli as A
inner join Prodaja as P
on A.ArtikalID=P.ArtikalID
inner join Zaposlenici as Z
on Z.ZaposlenikID=P.ZaposlenikID
where month(P.Datum)=8 and year(P.Datum)=1997

)

select ImePrezime,Spol, convert(nvarchar,day(DatumRodjenja))+'.'+convert(nvarchar,month(DatumRodjenja))+'.'+convert(nvarchar, year(DatumRodjenja)) as DatumRodjenja,count(ZaposlenikID) as br_prodaja
from lista_zaposlenika
group by ImePrezime,Spol,convert(nvarchar,day(DatumRodjenja))+'.'+convert(nvarchar,month(DatumRodjenja))+'.'+convert(nvarchar, year(DatumRodjenja))


/* 9 */ 
create procedure proc_delete_lon
as
begin 
delete from Prodaja 
where ZaposlenikID =(select Z.ZaposlenikID
from Zaposlenici as Z
inner join Prodaja as P
on Z.ZaposlenikID=P.ZaposlenikID
where substring(Adresa, charindex(',',Adresa)+1,6) like 'London'
group by Z.ZaposlenikID
)
delete from Zaposlenici 
where  substring(Adresa, charindex(',',Adresa)+1,6) like 'London'
end 

select * from Zaposlenici



select convert(nvarchar,year(E.BirthDate))+'-'
 +right('00' + convert(nvarchar,month(E.BirthDate)),2)+'-'+right('00'+ convert(nvarchar,day(E.BirthDate)),2) from NORTHWND.dbo.Employees as E

 select E.BirthDate from NORTHWND.dbo.Employees as E



