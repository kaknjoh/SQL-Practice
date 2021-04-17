CREATE DATABASE ROK_2_15
(
NAME=ROK_2_15,
FILENAME='D:\DBMS\Data\ROK_2_15.mdf',
SIZE=5MB,
MAXSIZE=10 MB, 
FILEGROWTH=10%),
( 
NAME=ROK_2_15,
FILENAME='D:\DBMS\Data\ROK_2_15.ndf',
SIZE=5 MB,
MAXSIZE=10MB, 
FILEGROWTH=10%)
(
NAME=ROK_2_15_LOG,
FILENAME='D:\DBMS\Data\ROK_2_15.ldf',
SIZE=5 MB,
MAXSIZE=10MB, 
FILEGROWTH=10%)



USE ROK_2_15
/* 
1. Kreirati bazu podataka koju ćete imenovati Vašim brojem dosijea. Fajlove baze smjestiti na sljedeće lokacije:
 Data fajl -> D:\DBMS\Data
 Log fajl -> D:\DBMS\Log
2. U bazi podataka kreirati sljedeće tabele:
a. Klijenti
 JMBG, polje za unos 13 karaktera (obavezan unos i jedinstvena vrijednost),
 Ime, polje za unos 30 karaktera (obavezan unos),
 Prezime, polje za unos 30 karaktera (obavezan unos),
 Adresa, polje za unos 100 karaktera (obavezan unos),
 Telefon, polje za unos 20 karaktera (obavezan unos),
 Email, polje za unos 50 karaktera (jedinstvena vrijednost),
 Kompanija, polje za unos 50 karaktera.

*/ 
CREATE TABLE Klijenti
(	
	ID_Klijenta int identity primary key,
	JMBG nvarchar(13) unique not null, 
	Ime nvarchar(30) not null, 
	Prezime nvarchar(30) not null,
	Adresa nvarchar(100) not null, 
	Telefon nvarchar(20) not null, 
	Email nvarchar(50) unique, 
	Kompanija nvarchar(30)
)
/* 


b. Krediti
 Datum, polje za unos datuma (obavezan unos),
 Namjena, polje za unos 50 karaktera (obavezan unos),
 Iznos, polje za decimalnog broja (obavezan unos),
 BrojRata, polje za unos cijelog broja (obavezan unos),
 Osiguran, polje za unos bit vrijednosti (obavezan unos),
 Opis, polje za unos dužeg niza karaktera.
*/ 
 create table Krediti 
 (
	ID_Kredita int identity primary key,
	Datum date not null, 
	Namjena nvarchar(50) not null, 
	Iznos decimal(10,2) not null, 
	BrojRata int not null, 
	Osiguran bit not null, 
	ID_Klijenta int , 
	Opis text, 
	constraint FK_krediti_klijent foreign key (ID_Klijenta) references Klijenti(ID_Klijenta)
 )
 select * from Klijenti


/* 

c. Otplate
 Datum, polje za unos datuma (obavezan unos)
 Iznos, polje za unos decimalnog broja (obavezan unos),
 Rata, polje za unos cijelog broja (obavezan unos),
 Opis, polje za unos dužeg niza karaktera.
*/ 
create table Otplate 
(
ID_Otplate int identity not null , 
ID_Kredita int,
Datum date not null, 
Iznos decimal(10,2) not null, 
Rata int not null, 
Opis text, 
constraint FK_Otplate_Krediti foreign key (ID_Kredita) references Krediti(ID_Kredita)
)
select * from Krediti

/*
Napomena: Klijent može uzeti više kredita, dok se kredit veže isključivo za jednog klijenta. Svaki kredit može imati
više otplata (otplata rata).
3. Koristeći AdventureWorks2014 bazu podataka, importovati 10 kupaca u tabelu Klijenti i to sljedeće kolone:
a. Zadnjih 13 karaktera kolone rowguid (Crticu '-' zamijeniti brojem 1)-> JMBG,
b. FirstName (Person) -> Ime,
c. LastName (Person) -> Prezime,
d. AddressLine1 (Address) -> Adresa,
e. PhoneNumber (PersonPhone) -> Telefon,
f. EmailAddress (EmailAddress) -> Email,
g. 'FIT' -> Kompanija
Također, u tabelu Krediti unijeti minimalno tri zapisa sa proizvoljnim podacima.

*/ 

alter table klijenti
alter column JMBG nvarchar(13)
select rowguid from AdventureWorks2014.Person.Person
select '1'+convert(nvarchar,right(PP.rowguid,12)) from AdventureWorks2014.Person.Person as PP


insert into Klijenti (JMBG, Ime, Prezime, Adresa , Telefon , Email, Kompanija) 
select top 10   '1'+convert(nvarchar,right(PP.rowguid,12)), PP.FirstName, PP.LastName, PA.AddressLine1, PH.PhoneNumber,EA.EmailAddress, 'FIT'  from AdventureWorks2014.Person.Person as PP
inner join AdventureWorks2014.Person.BusinessEntity as BE 
on PP.BusinessEntityID=BE.BusinessEntityID
inner join AdventureWorks2014.Person.BusinessEntityAddress as BEA
on BEA.BusinessEntityID=BE.BusinessEntityID
inner join AdventureWorks2014.Person.Address as PA
on PA.AddressID=BEA.AddressID
inner join AdventureWorks2014.Person.PersonPhone  as PH
on PH.BusinessEntityID=PP.BusinessEntityID
inner join AdventureWorks2014.Person.EmailAddress as EA
on PP.BusinessEntityID=EA.BusinessEntityID



 insert into Krediti(Datum , Namjena, Iznos, BrojRata, Osiguran, ID_Klijenta, Opis)
 values 
 (getdate(),'Nenamjenski kredit', 15.000, 12, 1, 37598,'Hocu da se uvalim u kredit' ),
 (getdate(),'Namjenski kredit za kupovinu stana', 40.000, 24, 1, 37599,'Hocu da se uvalim u kredit treba mi stan' ), 
 (getdate(),'Kredit za obnovu kuce', 10.000, 6, 1, 37598,'Kuca porusena u vremenskim nepogodama' ),
 (getdate(),'Kredit za kupovinu automobila', 20.000, 12, 1, 37600,'Treba mi novi auto' )
/* 
DBMS praktični ispit – Integralni (04.07.2015)
Broj dosijea
4. Kreirati stored proceduru koja će na osnovu proslijeđenih parametara služiti za unos podataka u tabelu
Otplate. Proceduru pohraniti pod nazivom usp_Otplate_Insert. Obavezno testirati ispravnost kreirane
procedure (unijeti minimalno 5 zapisa sa proizvoljnim podacima).

*/
create procedure usp_Otplate_Insert 
(
	@ID_Kredita int null , 
	@Datum date null, 
	@Iznos decimal(10,2)  null, 
	@Rata int  null,
	@Opis text null
)
as 
begin 
insert into Otplate(ID_Kredita, Datum, Iznos, Rata, Opis)
values(@ID_Kredita, @Datum, @Iznos, @Rata, @Opis)
end

select * from Krediti
exec usp_Otplate_Insert @ID_Kredita=3 ,@Datum='2015-04-15', @Iznos=400, @Rata=1, @Opis='Dosla plata stigla rata'
/*

5. Kreirati view (pogled) nad podacima koji će prikazivati sljedeća polja: jmbg, ime i prezime, adresa, telefon i
email klijenta, zatim datum, namjenu i iznos kredita, te ukupan broj otplaćenih rata i ukupan otplaćeni iznos.
View pohranite pod nazivom view_Krediti_Otplate.
*/
	create view view_Krediti_Otplate
	as
	select k.JMBG,k.Ime+ ' ' +k.Prezime as [Ime i prezime], k.Adresa, k.Telefon, k.Email, kr.Datum, kr.Namjena, kr.Iznos, 'Ukupan broj otplacenih rata ' + convert(nvarchar, count(*)) as [Broj otplacenih rata],
	 'Ukupan otplaceni iznos' + convert(nvarchar,sum(o.Iznos)) as [Ukupan otplaceni iznos]
	from 
	Klijenti as k inner join Krediti as kr on k.ID_Klijenta=kr.ID_Klijenta
	inner join Otplate as o on o.ID_Kredita=kr.ID_Kredita
	group by  k.JMBG,k.Ime+ ' ' +k.Prezime, k.Adresa, k.Telefon, k.Email, kr.Datum, kr.Namjena, kr.Iznos
/*
6. Kreirati stored proceduru koja će na osnovu proslijeđenog parametra @JMBG prikazivati podatke o otplati
kredita. Kao izvor podataka koristiti prethodno kreirani view. Proceduru pohraniti pod nazivom
usp_Krediti_Otplate_SelectByJMBG. Obavezno testirati ispravnost kreirane procedure.
*/
	create procedure usp_Krediti_Otplate_SelectByJMBG 
	( @JMBG nvarchar(13) )
	as 
	begin 
	select * from view_Krediti_Otplate
	where JMBG=@JMBG
	end
	
	
	exec usp_Krediti_Otplate_SelectByJMBG @JMBG='1BD35B36CDBD0'
/*
7. Kreirati proceduru koja će služiti za izmjenu podataka o otplati kredita. Proceduru pohraniti pod nazivom
usp_Otplate_Update. Obavezno testirati ispravnost kreirane procedure.

*/
create procedure usp_Otplate_Update
( 
	@ID_Otplate int null, 
	@ID_Kredita int null , 
	@Datum date null, 
	@Iznos decimal(10,2)  null, 
	@Rata int  null,
	@Opis text null
)
as begin
update Otplate
set ID_Kredita=@ID_Kredita,
Datum=@Datum, Iznos=@Iznos, Rata=@Rata, Opis=@Opis
where ID_Otplate=@ID_Otplate
end 

/* 
8. Kreirati stored proceduru koja će služiti za brisanje kredita zajedno sa svim otplatama. Proceduru pohranite
pod nazivom usp_Krediti_Delete. Obavezno testirati ispravnost kreirane procedure.
*/
create procedure usp_Krediti_Delete 
(@ID_Kredita int null) 
as begin 
delete Otplate
where ID_Kredita=@ID_Kredita

delete Krediti
where ID_Kredita=@ID_Kredita
end 
exec usp_Krediti_Delete @ID_Kredita=4
select * from Krediti
select * from Otplate
/*
9. Kreirati trigger koji će spriječiti brisanje zapisa u tabeli Otplate. Trigger pohranite pod nazivom
tr_Otplate_IO_Delete. Obavezno testirati ispravnost kreiranog triggera.
*/

create trigger tr_Otplate_IO_Delete
on Otplate instead of delete 
as
begin 
RAISERROR('Error occurred in  block.', 1, 1);
end

select * from Otplate
delete Otplate
where ID_Otplate=3
/* 



10. Uraditi full backup Vaše baze podataka na lokaciju D:\DBMS\Backup


*/
backup database  ROK_2_15 to disk='D:\DBMS\Backup'
with format




