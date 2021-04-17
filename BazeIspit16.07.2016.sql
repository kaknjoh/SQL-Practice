create database kaknjo_h_12
use kaknjo_h_12
create table Proizvodi 
(
 ProizvodID int identity primary key , 
 Sifra nvarchar(10) not null unique ,
 Naziv nvarchar(50) not null, 
 Cijena decimal(10,2) not null
)

create table Skladista (
SkladisteID int identity primary key, 
Naziv nvarchar(50) not null , 
Oznaka nvarchar(10) not null unique, 
Lokacija nvarchar(50) not null
)


create table SkladisteProizvodi
(
ProizvodID int, 
SkladisteID int, 
Stanje decimal(10,2), 
constraint PK_SkladistePrizvodi primary key(ProizvodID, SkladisteID),
constraint FK_SkladisteProizvodi_Proizvodi foreign key (ProizvodID) references Proizvodi(ProizvodID), 
constraint FK_SkladisteProizvodi_Skladista foreign key (SkladisteID) references Skladista(SkladisteID)
)



/* 2 */ 
insert into Skladista values
(
'BingoSkladiste', '123456789a', 'Lukovo Polje'), 
('HassSkladiste', '987654321b', 'Radakovo'), 
('TrgoTenSkladiste', '123456789c','Nova Zenica')


insert into Proizvodi 
create view view_pro_1
as (
select top 10 P.ProductNumber,PS.Name as SubCategory ,P.ListPrice,sum(SOD.OrderQty) as kolicina  from 
AdventureWorks2014.Production.ProductCategory as PC
inner join AdventureWorks2014.Production.ProductSubcategory as PS
on PC.ProductCategoryID=PS.ProductCategoryID
inner join AdventureWorks2014.Production.Product as P
on P.ProductSubCategoryID=PS.ProductSubcategoryID
inner join AdventureWorks2014.Sales.SalesOrderDetail as SOD
on SOD.ProductID=P.ProductID
where PC.Name='Bikes'
group by  P.ProductNumber,PS.Name,P.ListPrice,PC.Name
order by sum(SOD.OrderQty) desc
)

select * from view_pro_1
insert into Proizvodi 
select ProductNumber, SubCategory, ListPrice 
from view_pro_1
/*
inner join AdventureWorks2014.Sales.SalesOrderDetail as POD
on POD.ProductID=P.ProductID 

select * from AdventureWorks2014.Sales.SalesOrderDetail

*/ 


insert into SkladisteProizvodi
select P.ProizvodID ,S.SkladisteID,  100.00 from Skladista as S, Proizvodi as P
where SkladisteID=1

insert into SkladisteProizvodi
select P.ProizvodID ,S.SkladisteID,  100.00 from Skladista as S, Proizvodi as P
where SkladisteID=2

insert into SkladisteProizvodi
select P.ProizvodID ,S.SkladisteID,  100.00 from Skladista as S, Proizvodi as P
where SkladisteID=3

select * from SkladisteProizvodi

/* 3 */ 

create procedure proc_povecaj_stanje (
@SkladisteID int=null, 
@Stanje decimal(10,2) =null,
@ProizvodID int =null )
as 
begin 
update SkladisteProizvodi
set Stanje= Stanje+@Stanje
where SkladisteID=@SkladisteID and ProizvodID=@ProizvodID
end

exec proc_povecaj_stanje @SkladisteID=1, @Stanje=5, @ProizvodID=3

select  * from SkladisteProizvodi



/* 4 */ 
/* 4. Kreiranje indeksa u bazi podataka nad tabelama
a) Non-clustered indeks nad tabelom Proizvodi. Potrebno je indeksirati Sifru i Naziv. Također,
potrebno je uključiti kolonu Cijena
b) Napisati proizvoljni upit nad tabelom Proizvodi koji u potpunosti iskorištava indeks iz
prethodnog koraka
c) Uradite disable indeksa iz koraka a)
*/ 
create nonclustered index IX_Cijena_Naziv on Proizvodi(Sifra,Naziv)
include(Cijena)

select * from Proizvodi

select Sifra,Naziv,Cijena from Proizvodi
where Sifra='BK-M68B-38' 


alter index IX_Cijena_Naziv on Proizvodi
disable


alter index IX_Cijena_Naziv on Proizvodi
rebuild



/* 5 */ 

create view view_pro_skl
as
(
select P.Sifra, P.Naziv as NazivProizvoda,P.Cijena,S.Oznaka, S.Naziv as NazivSkladista, S.Lokacija,SP.Stanje
from Skladista as S
inner join 
SkladisteProizvodi as SP
on S.SkladisteID=SP.SkladisteID
inner join Proizvodi as P
on P.ProizvodID=SP.ProizvodID
)

select * from view_pro_skl

/* 6 */ 

create procedure proc_proiz_stanje_1
(
@Sifra nvarchar(10) = null 
)
as
begin 
select Sifra,NazivProizvoda,Cijena,Sum(Stanje)
from view_pro_skl
where Sifra like @Sifra
group by Sifra,NazivProizvoda,Cijena
end



select * from Proizvodi
exec proc_proiz_stanje_1 @Sifra='BK-M68S-38'


/* 7 */ 

create procedure proc_unos_pr (
@Sifra nvarchar(10)= null, 
@Naziv nvarchar(50) =null, 
@Cijena decimal(10,2)=null
) 
as 
begin 
insert into Proizvodi values
(@Sifra,@Naziv,@Cijena)
insert into SkladisteProizvodi values (
(select ProizvodID from Proizvodi where Sifra=@Sifra),1,0),
((select ProizvodID from Proizvodi where Sifra=@Sifra),2,0),
((select ProizvodID from Proizvodi where Sifra=@Sifra),3,0)
end 

exec proc_unos_pr @Sifra='123-456-89', @Naziv='Mountain Bike', @Cijena=150.00



/*  8  */ 

create procedure proc_delete_proizvod
(
@Sifra nvarchar(10)=null)
as 
begin 
delete SkladisteProizvodi
where ProizvodID = (select ProizvodID from Proizvodi where Sifra like @Sifra)
delete Proizvodi 
where ProizvodID=(select ProizvodID from Proizvodi where Sifra like @Sifra)
end


exec proc_delete_proizvod @Sifra='123-456-89'

/*  9  */ 
select * from view_pro_skl


create procedure proc_view_5_4 (
@Sifra nvarchar(10)=null ,
@Oznaka nvarchar(10)=null, 
@Lokacija nvarchar(50)=null ) 
as
begin 
select * from 
view_pro_skl
where  (Sifra like @Sifra and @Lokacija is null  and @Oznaka is null ) or (Sifra like @Sifra and Oznaka like @Oznaka and @Lokacija is null) or (@Oznaka is null and @Lokacija is null and @Sifra is null )
 
end
drop procedure proc_view_5_4
exec proc_view_5_4 @Sifra='BK-M68B-38'

select Sifra from 
view_pro_skl 
where Sifra not like 'A%'


create proc USP_PretragaSkladista
(
	@Sifra nvarchar(10)='',
	@Oznaka nvarchar(10)='',
	@Lokacija nvarchar(50)=''
) as
begin
	select *
	from
		view_pro_skl
	where Sifra like '%'+@Sifra+'%' and Oznaka like '%'+@Oznaka+'%' and 
	Lokacija like '%'+@Lokacija+'%'
end
go




/* 10. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera:
C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup*/


backup database  kaknjo_h_12
to disk='C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\kaknjo_h_12.bak'

use master

alter database kaknjo_h_12
set offline

drop database kaknjo_h_12



backup database  kaknjo_h_12
to disk='C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\kaknjo_h_12.dif'
with differential 



restore database kaknjo_h_12 
from disk= 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\kaknjo_h_12.bak'
with replace




backup database kaknjo_h_12
to disk='C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\kaknjo_h_12.bak'


backup database kaknjo_h_12
to disk='C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\kaknjo_h_12.dif'
with differential

use master
alter database kaknjo_h_12
set offline


replace database kaknjo_h_12
from disk =backup database kaknjo_h_12
to disk='C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\kaknjo_h_12.bak'
with replace


