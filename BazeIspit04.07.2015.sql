

/* . Kreirati bazu podataka koju ćete imenovati Vašim brojem dosijea. Fajlove baze smjestiti na sljedeće lokacije:
 Data fajl -> D:\DBMS\Data
 Log fajl -> D:\DBMS\Log*/ 

create database ispit_07_15 on primary(
NAME='ispit_07_15', 
FILENAME='c:\BP2\data\ispit_07_15.mdf'
),
(
NAME='ispit_07_15_sek', 
FILENAME='c:\BP2\data\ispit_07_15_sek.mdf'
)
LOG ON 
(
NAME='ispit_07_15_log', 
FILENAME='c:\BP2\log\ispit_07_15_log.ldf'
)
use ispit_07_15

/* 2 */ 

/*  U bazi podataka kreirati sljedeće tabele:
a. Klijenti
 JMBG, polje za unos 13 karaktera (obavezan unos i jedinstvena vrijednost),
 Ime, polje za unos 30 karaktera (obavezan unos),
 Prezime, polje za unos 30 karaktera (obavezan unos),
 Adresa, polje za unos 100 karaktera (obavezan unos),
 Telefon, polje za unos 20 karaktera (obavezan unos),
 Email, polje za unos 50 karaktera (jedinstvena vrijednost),
 Kompanija, polje za unos 50 karaktera.
b. Krediti
 Datum, polje za unos datuma (obavezan unos),
 Namjena, polje za unos 50 karaktera (obavezan unos),
 Iznos, polje za decimalnog broja (obavezan unos),
 BrojRata, polje za unos cijelog broja (obavezan unos),
 Osiguran, polje za unos bit vrijednosti (obavezan unos),
 Opis, polje za unos dužeg niza karaktera.
c. Otplate
 Datum, polje za unos datuma (obavezan unos)
 Iznos, polje za unos decimalnog broja (obavezan unos),
 Rata, polje za unos cijelog broja (obavezan unos),
 Opis, polje za unos dužeg niza karaktera.
Napomena: Klijent može uzeti više kredita, dok se kredit veže isključivo za jednog klijenta. Svaki kredit može imati
više otplata (otplata rata).*/ 

create table Klijenti
(
	KlijentID int identity primary key,
	JMBG nvarchar(13) not null unique,
	Ime nvarchar(30) not null,
	Prezime nvarchar(30) not null,
	Adresa nvarchar(100) not null,
	Telefon nvarchar(20) not null, 
	Email nvarchar(50) unique,
	Kompanija nvarchar(50)
)

create table Krediti 
(
	KreditID int identity primary key,
	KlijentID int,
	Datum date, 
	Namjena nvarchar(50) not null,
	Iznos decimal(10,2) not null, 
	BrojRata int not null,
	Osiguran BIT not null, 
	Opis nvarchar(100),
	constraint FK_Krediti_Klijent foreign key (KlijentID) references Klijenti(KlijentID)
)
drop table Otplate
create table Otplate(
	OtplataID int identity ,
	KreditID int,
	Datum date not null, 
	Iznos decimal(10,2) not null,
	Rata int not null, 
	Opis nvarchar(100),
	constraint FK_Otplate_Krediti foreign key(KreditID) references Krediti(KreditID),
	constraint PK_Otplate primary key (OtplataID,KreditID)
	)


	/* 3 */ 

	/* 3. Koristeći AdventureWorks2014 bazu podataka, importovati 10 kupaca u tabelu Klijenti i to sljedeće kolone:
a. Zadnjih 13 karaktera kolone rowguid (Crticu '-' zamijeniti brojem 1)-> JMBG,
b. FirstName (Person) -> Ime,
c. LastName (Person) -> Prezime,
d. AddressLine1 (Address) -> Adresa,
e. PhoneNumber (PersonPhone) -> Telefon,
f. EmailAddress (EmailAddress) -> Email,
g. 'FIT' -> Kompanija
Također, u tabelu Krediti unijeti minimalno tri zapisa sa proizvoljnim podacima.
*/ 


select * from AdventureWorks2014.Person.Address

INSERT into Klijenti
select top 10 '1'+right(A.rowguid,12),P.FirstName, P.LastName, A.AddressLine1, PH.PhoneNumber, E.EmailAddress, 'PTF'
FROM AdventureWorks2014.Person.Person as P
inner join AdventureWorks2014.Person.PersonPhone as PH
on P.BusinessEntityID=PH.BusinessEntityID
inner join AdventureWorks2014.Person.BusinessEntity as BE
on P.BusinessEntityID=BE.BusinessEntityID 
inner join AdventureWorks2014.Person.BusinessEntityAddress as BEA
on BE.BusinessEntityID=BEA.BusinessEntityID
inner join AdventureWorks2014.Person.Address as A
on BEA.AddressID=A.AddressID
inner join AdventureWorks2014.Person.EmailAddress as E
on E.BusinessEntityID=P.BusinessEntityID

insert into Krediti values 
(1,getdate(), 'Kupovina automobila', 1000, 12,0,'Kredit za kupovinu automobila')
(2,dateadd(year,-5,getdate()) ,'Kredit za izgradnju tunela prenj', 154000, 36,1,'Kredit tunel prenj'),
(4,dateadd(month,-3,getdate()), 'Kredit za sredstva za kucu', 154000, 24,1,'Kupovina kuce'),
(1,getdate(), 'Kupovina stana', 15000, 12,0,'Kredit za kupovinu stana')


/* 4 */ 
/* Kreirati stored proceduru koja će na osnovu proslijeđenih parametara služiti za unos podataka u tabelu
Otplate. Proceduru pohraniti pod nazivom usp_Otplate_Insert. Obavezno testirati ispravnost kreirane
procedure (unijeti minimalno 5 zapisa sa proizvoljnim podacima). */ 

create procedure usp_Otplate_Insert 
(
	@KreditID int=null,
	@Datum date=null,
	@Iznos decimal(10,2) =null,
	@Rata int=null,
	@Opis nvarchar(100)=null
)
as 
begin
insert into Otplate values
(@KreditID,@Datum,@Iznos,@Rata,@Opis)
end

exec usp_Otplate_Insert @KreditID=2,@Datum='2015-01-21', @Iznos=1500, @Rata=2, @Opis='Druga rata'
exec usp_Otplate_Insert @KreditID=2,@Datum='2012-01-21', @Iznos=1500, @Rata=4, @Opis='Dug za ratu'
exec usp_Otplate_Insert @KreditID=1,@Datum='2020-08-21', @Iznos=1400, @Rata=2, @Opis='Dug za otplatu kredita'

exec usp_Otplate_Insert @KreditID=3,@Datum='2014-08-05', @Iznos=400, @Rata=1, @Opis='Rata za kredit'

exec usp_Otplate_Insert @KreditID=4,@Datum='2014-08-05', @Iznos=400, @Rata=1, @Opis='Prva rata'
exec usp_Otplate_Insert @KreditID=4,@Datum='2014-09-05', @Iznos=100, @Rata=2, @Opis='Druga rata'

/* 5 */ 
/* . Kreirati view (pogled) nad podacima koji će prikazivati sljedeća polja: jmbg, ime i prezime, adresa, telefon i
email klijenta, zatim datum, namjenu i iznos kredita, te ukupan broj otplaćenih rata i ukupan otplaćeni iznos.
View pohranite pod nazivom view_Krediti_Otplate.*/ 


create view view_Krediti_Otplate as 
(
	select KL.JMBG, KL.Ime+KL.Prezime as ImePrezime, KL.Adresa, KL.Telefon, KL.Email, k.Datum,k.Namjena,k.Iznos, count(o.Rata) as BrojOtplacenihRata,SUM(o.Iznos) as OtplacenaSuma
	from Klijenti as KL
	inner join Krediti as k
	on KL.KlijentID=k.KlijentID
	inner join Otplate as o
	on k.KreditID=o.KreditID
	group by  KL.JMBG, KL.Ime+KL.Prezime, KL.Adresa, KL.Telefon, KL.Email, k.Datum,k.Namjena,k.Iznos

)



/* 6 */ 
/* Kreirati stored proceduru koja će na osnovu proslijeđenog parametra @JMBG prikazivati podatke o otplati
kredita. Kao izvor podataka koristiti prethodno kreirani view. Proceduru pohraniti pod nazivom
usp_Krediti_Otplate_SelectByJMBG. Obavezno testirati ispravnost kreirane procedure.*/ 

create procedure usp_Krediti_Otplate_SelectByJMBG 
(
@JMBG nvarchar(13) =null
)
as begin
select * from view_Krediti_Otplate
where JMBG=@JMBG
end

select * from Klijenti
	
exec  usp_Krediti_Otplate_SelectByJMBG @JMBG='1585C2D4EC6E9'

 /* 7 */ 
 
 /*7. Kreirati proceduru koja će služiti za izmjenu podataka o otplati kredita. Proceduru pohraniti pod nazivom
usp_Otplate_Update. Obavezno testirati ispravnost kreirane procedure */ 

create procedure usp_Otplate_Update 
(
@OtplataID int=null,
@KreditID int =null, 
@Datum date =null,
@Iznos decimal(10,2) =null,
@Rata int =null ,
@Opis nvarchar(100) =null) as
begin 
update Otplate
set Datum=@Datum,
Iznos=@Iznos,
Rata=@Rata,
Opis=@Opis
where OtplataID=@OtplataID and KreditID=@KreditID
end 


exec usp_Otplate_Update @OtplataID=6,@KreditID=4, @Datum='2020-06-25',@Iznos=150,@Rata=1,@Opis='Kredit rata legla'
go

 /* 8 */ 

 /*8. Kreirati stored proceduru koja će služiti za brisanje kredita zajedno sa svim otplatama. Proceduru pohranite
pod nazivom usp_Krediti_Delete. Obavezno testirati ispravnost kreirane procedure. */

create procedure usp_Krediti_Delete (
@KreditID int=null
)
as begin
delete from Otplate
where KreditID =@KreditID

delete from Krediti
where KreditID=@KreditID
end


exec usp_Krediti_Delete @KreditID=4


/*  9 */

/*Kreirati trigger koji će spriječiti brisanje zapisa u tabeli Otplate. Trigger pohranite pod nazivom
tr_Otplate_IO_Delete. Obavezno testirati ispravnost kreiranog triggera.  */  


create trigger tr_Otplate_IO_Delete 
on Otplate
instead of delete
as
begin 
select * from Krediti
end 



delete from Otplate
where OtplataID=2


	  
/* 10 */ 

/* 
Uraditi full backup Vaše baze podataka na lokaciju D:\DBMS\Backup.*/ 

backup database ispit_07_15
to disk ='c:\BP2\Backup\ispit_07_15.bak'