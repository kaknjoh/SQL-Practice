

/* */ 

create database harun_16

use harun_16

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


select * from AdventureWorks2014.Sales.Customer
select * from AdventureWorks2014.Person.PersonPhone
select * from AdventureWorks2014.Person.EmailAddress
insert into Klijenti
select  top 10 PP.FirstName, PP.LastName, PH.PhoneNumber, EA.EmailAddress,C.AccountNumber, lower(PP.FirstName+'.'+PP.LastName),right(Pa.PasswordHash,8)
from AdventureWorks2014.Person.Person as PP
inner join AdventureWorks2014.Person.PersonPhone as PH
on PP.BusinessEntityID=PH.BusinessEntityID
inner join AdventureWorks2014.Person.EmailAddress as EA
on EA.BusinessEntityID=PH.BusinessEntityID
inner join AdventureWorks2014.Person.Password as Pa
on PP.BusinessEntityID=Pa.BusinessEntityID
inner join AdventureWorks2014.Sales.Customer as C
on C.PersonID=PP.BusinessEntityID


insert into Transakcije values
('2018-04-23 17:15:41.421' , 'Lokalna' , 2, 5 , 'Kupovina rasvjete', 120.00), 
('2010-03-23 15:15:41.421' , 'Opcinska' , 10, 4 , 'Uplata grijanja', 1514.00), 
('2012-08-28 15:51:41.421' , 'Medunarodna' , 6, 9 , 'Taksa za rezije', 105.00), 
('2020-05-13 10:15:41.421' , 'Lokalna' , 7, 1 , 'Uplata za vozacki ispit', 120.00),
('2014-07-23 16:52:41.421' , 'Medunarodna' , 9, 2 , 'Pomoc za humanitarnu akciju', 1500.00), 
('2017-02-23 14:15:41.421' , 'Lokalna' , 5, 8 , 'Kupovina automobila', 10550.00), 
('2014-08-23 15:15:41.421' , 'Lokalna' , 3, 7 , 'Izdavanje potvrde', 14.00)


( 
getdate(), 'Lokalna', 1,2,'Uplata novca za faks' , 500.00),
( 
 '2020-06-22 14:35:33.427', 'Medunarodna', 1,3, 'Kupovina avionske karte' , 1400.00
), 
('2019-08-23 15:15:41.421' , 'Lokalna' , 2, 3 , 'Kupovina saksije', 115.00)




/* 4 */ 

create procedure proc_upis_klijenta (
@Ime nvarchar(30)=null, 
@Prezime nvarchar(30)=null, 
@Telefon nvarchar(20)=null, 
@Mail nvarchar(50)=null, 
@BrojRacuna nvarchar(15)=null, 
@Lozinka nvarchar(20) = null 
) as
begin 
insert into Klijenti values(
@Ime, @Prezime, @Telefon,@Mail,@BrojRacuna, lower(@Ime+'.'+@Prezime), @Lozinka)
end 

exec proc_upis_klijenta @Ime='Harun', @Prezime='Kaknjo', @Telefon='061-084-661', @Mail='harun@size.ba', @BrojRacuna='111511a',@Lozinka='1554ad=a'
select * from Klijenti 

/* 5 */ 
create view view_primalac_posiljalac as  (

select 
 t.Datum,t.TipTransakcije, t.ImePrezimePosiljaoca, t.BrojRacunaPosiljaoca,k.Ime+k.Prezime as ImePrezimePrimaoca, k.BrojRacuna as BrojRacunaPrimaoca,t.Svrha,t.Iznos  from (
 select T.Datum,T.TipTransakcije,K.Ime+K.Prezime as ImePrezimePosiljaoca,K.BrojRacuna as BrojRacunaPosiljaoca,T.Svrha,T.Iznos, T.PrimalacID
 from 
 Transakcije as T
 inner join Klijenti as K 
 on T.PosiljacID=K.KlijentID
 ) as t
inner join Klijenti as k  
on t.PrimalacID=k.KlijentID
) 


select * from view_primalac_posiljalac

/* 6 */ 

create procedure proc_check_transaction(
@BrojRacunaPosiljaoca nvarchar(30)= null ) as 
begin 
select * from view_primalac_posiljalac 
where BrojRacunaPosiljaoca = @BrojRacunaPosiljaoca
end

DROP PROCEDURE proc_check_transaction

exec proc_check_transaction @BrojRacunaPosiljaoca='AW00011000'

/* 7 */ 
select year(Datum) , sum(Iznos)
from Transakcije 
group by   year(Datum)


/* 8 */ 

create procedure proc_delete_tr
(
@KlijentID int =null )
as begin
delete from Transakcije 
where PosiljacID =@KlijentID or PrimalacID=@KlijentID
end 

exec proc_delete_tr @KlijentID=1

 /* 9 */ 

 create procedure proc_search
 (
 @BrojRacunaPosiljaoca nvarchar(20) = '', 
 @Prezime nvarchar(30)=''
 ) as 
 begin 

 select * from 
 view_primalac_posiljalac 
 where BrojRacunaPosiljaoca like '%'+@BrojRacunaPosiljaoca+'%' and ImePrezimePosiljaoca like '%'+@Prezime
 end
 drop procedure proc_search

exec proc_search @BrojRacunaPosiljaoca='AW00011001',@Prezime='Huang'


select * from Transakcije
dbcc checkident('Transakcije', RESEED, 11) 
insert into Transakcije values
('2010-04-23 17:15:41.421' , 'Medunarodna' , 2, 5 , 'Kupovina auta', 1000.00)

