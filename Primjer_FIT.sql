create database ROK_1_2
(
	NAME=ROK_1_2
	FILENAME='D:\DBMS\Data\ROK_1_2.mdf', 
	SIZE=5MB, 
	MAXSIZE=10MB, 
	FILEGROWTH=5%
), 
(
	NAME=ROK_1_2
	FILENAME='D:\DBMS\Data\ROK_1_2.ndf', 
	SIZE=5MB, 
	MAXSIZE=10MB, 
	FILEGROWTH=5%
)

(
	NAME=ROK_1_2_LOG
	FILENAME='D:\DBMS\Log\ROK_1_2.ldf', 
	SIZE=5MB, 
	MAXSIZE=10MB, 
	FILEGROWTH=5%
)

USE ROK_1_2

/*
1. Kreirati bazu podataka koju ćete imenovati Vašim brojem dosijea. Fajlove baze smjestiti na sljedeće lokacije:
 Data fajl -> D:\DBMS\Data
 Log fajl -> D:\DBMS\Log
2. U bazi podataka kreirati sljedeće tabele:
a. Kandidati
 Ime, polje za unos 30 karaktera (obavezan unos),
 Prezime, polje za unos 30 karaktera (obavezan unos),
 JMBG, polje za unos 13 karaktera (obavezan unos i jedinstvena vrijednost),
 DatumRodjenja, polje za unos datuma (obavezan unos),
 MjestoRodjenja, polje za unos 30 karaktera,
 Telefon, polje za unos 20 karaktera,
 Email, polje za unos 50 karaktera (jedinstvena vrijednost).
*/
create table Kandidati(
ID_Kandidata int identity(1,1) primary key , 
Ime nvarchar(30) not null, 
Prezime nvarchar(30) not null, 
JMBG nvarchar(13) not null unique, 
DatumRodjenja date not null, 
MjestoRodjenja nvarchar(30), 
Telefon nvarchar(20), 
Email nvarchar(50) unique
)


/*
b. Testovi
 Datum, polje za unos datuma i vremena (obavezan unos),
 Naziv, polje za unos 50 karaktera (obavezan unos),
 Oznaka, polje za unos 10 karaktera (obavezan unos i jedinstvena vrijednost),
 Oblast, polje za unos 50 karaktera (obavezan unos),
 MaxBrojBodova, polje za unos cijelog broja (obavezan unos),
 Opis, polje za unos 250 karaktera.

*/
create table Testovi
(
ID_Testa int  identity(1,1) primary key,
Datum datetime not null, 
Naziv nvarchar(50) not null,
Oznaka nvarchar(10) not null unique, 
Oblast nvarchar(50) not null, 
MaxBrojBodova int not null, 
Opis nvarchar(250)
)

/*
c. RezultatiTesta
 Polozio, polje za unos ishoda testiranja – DA/NE (obavezan unos)
 OsvojeniBodovi, polje za unos decimalnog broja (obavezan unos),
 Napomena, polje za unos dužeg niza karaktera.
*/
 create table RezultatiTesta
 (
	ID_Testa int , 
	ID_Kandidata int,
	Polozio bit not null, 
	OsvojeniBodovi decimal(10,2) not null, 
	Napomena text,
	constraint FK_RezultatiTesta_Testovi foreign key (ID_Testa) references Testovi(ID_Testa), 
	constraint FK_RezultatiTesta_Kandidati foreign key (ID_Kandidata) references Kandidati (ID_Kandidata), 
	constraint PK_RezultatiTesta primary key (ID_Testa, ID_Kandidata)

 
 )

/*
Napomena: Kandidat može da polaže više testova i za svaki test ostvari određene rezultate, pri čemu kandidat ne
može dva puta polagati isti test. Također, isti test može polagati više kandidata.
3. Koristeći AdventureWorks2014 bazu podataka, importovati 10 kupaca u tabelu Kandidati i to sljedeće
kolone:
a. FirstName (Person) -> Ime,
b. LastName (Person) -> Prezime,
c. Zadnjih 13 karaktera kolone rowguid iz tabele Customer (Crticu zamijeniti brojem 0) -> JMBG,
d. ModifiedDate (Customer) -> DatumRodjenja,
e. City (Address) -> MjestoRodjenja,
f. PhoneNumber (PersonPhone) -> Telefon,
g. EmailAddress (EmailAddress) -> Email.
Također, u tabelu Testovi unijeti minimalno tri testa sa proizvoljnim podacima.
*/
insert into Kandidati 
(
	Ime, Prezime, JMBG, DatumRodjenja, MjestoRodjenja, Telefon , Email
)
select top 10 PP.FirstName, PP.LastName, replace(right(SC.rowguid, 13),'-',0), SC.ModifiedDate, A.City, PH.PhoneNumber, EA.EmailAddress  from AdventureWorks2014.Person.Person as PP
inner join AdventureWorks2014.Person.PersonPhone as PH
on PP.BusinessEntityID=PH.BusinessEntityID
inner join AdventureWorks2014.Person.EmailAddress as EA 
on PP.BusinessEntityID=EA.BusinessEntityID
inner join AdventureWorks2014.Sales.Customer as SC
on PP.BusinessEntityID=SC.PersonID
inner join AdventureWorks2014.Person.BusinessEntity as BE
on PP.BusinessEntityID=BE.BusinessEntityID
inner join AdventureWorks2014.Person.BusinessEntityAddress as BEA
on BE.BusinessEntityID=BEA.BusinessEntityID
inner join AdventureWorks2014.Person.Address as A
on A.AddressID=BEA.AddressID

insert into Testovi values(getdate(), 'Test fizika', 'ENZOT', 'Atomska fizika', 100,'Zavrsni test iz fizike'), 
(getdate(), 'Test matematika', 'Parcijalni ', 'Aritmetika', 50, 'Parcijalni test iz matematike'), 
(getdate(), 'Kontrolni engleski', 'Kolokvij', 'Vremena',40, 'Prvi kontrolni iz engleskog jezika')
/*
DBMS praktični ispit – Integralni (13.06.2015)
Broj dosijea
4. Kreirati stored proceduru koja će na osnovu proslijeđenih parametara služiti za unos podataka u tabelu
RezultatiTesta. Proceduru pohraniti pod nazivom usp_RezultatiTesta_Insert. Obavezno testirati ispravnost
kreirane procedure (unijeti proizvoljno minimalno 10 rezultata za različite testove).
*/ 
 create procedure usp_RezultatiTesta_Insert
(@ID_Testa int null, 
@ID_Kandidata int null, 
@Polozio bit =1,
@OsvojeniBodovi decimal(10,2)  null,
@Napomena text
)
as begin
insert into RezultatiTesta (ID_Testa, ID_Kandidata, Polozio, OsvojeniBodovi, Napomena) values
(@ID_Testa, @ID_Kandidata, @Polozio, @OsvojeniBodovi, @Napomena)
end
select * from Testovi
exec usp_RezultatiTesta_Insert @ID_Testa=3, @ID_Kandidata=18518, @Polozio=1, @OsvojeniBodovi=19, @Napomena='Kandidat polozio ocjena 6 '
/* 
5. Kreirati view (pogled) nad podacima koji će sadržavati sljedeća polja: ime i prezime, jmbg, telefon i email
kandidata, zatim datum, naziv, oznaku, oblast i max. broj bodova na testu, te polje položio, osvojene bodove i
procentualni rezultat testa. View pohranite pod nazivom view_Rezultati_Testiranja.
*/ 
create view rezultati_testiranja as
select K.Ime+ ' ' + K.Prezime as [Ime i prezime], K.JMBG, K.Telefon, K.Email, T.Datum, T.Naziv,T.Oznaka, T.Oblast, T.MaxBrojBodova as [Max broj bodova], RT.Polozio , RT.OsvojeniBodovi, convert(nvarchar, (RT.OsvojeniBodovi*T.MaxBrojBodova)/100) as [Postotak osvojenih bodova]  from 
Kandidati as K
inner join RezultatiTesta as RT
on K.ID_Kandidata=RT.ID_Kandidata
inner join Testovi as T
on RT.ID_Testa=T.ID_Testa
/* 
6. Kreirati stored proceduru koja će na osnovu proslijeđenih parametara @OznakaTesta i @Polozio prikazivati
rezultate testiranja. Kao izvor podataka koristiti prethodno kreirani view. Proceduru pohraniti pod nazivom
usp_RezultatiTesta_SelectByOznaka. Obavezno testirati ispravnost kreirane procedure.
*/
drop view rezultati_testiranja
create procedure usp_RezultatiTesta_SelectByOznaka
( @OznakaTesta int null, 
	@Polozio bit )
	as
	begin
	select * from rezultati_testiranja
	where Oznaka=@OznakaTesta and Polozio=@Polozio
	end

/*
7. Kreirati proceduru koja će služiti za izmjenu rezultata testiranja. Proceduru pohraniti pod nazivom
usp_RezultatiTesta_Update. Obavezno testirati ispravnost kreirane procedure.
*/
 create procedure usp_RezultatiTesta_Update (
 @ID_Testa int, 
 @ID_Kandidata int , 
 @Polozio bit, 
 @OsvojeniBodovi decimal(10,2), 
 @Napomena text) 
 as 
 begin 
 update RezultatiTesta
 set Polozio=@Polozio, OsvojeniBodovi=@OsvojeniBodovi, Napomena=@Napomena
 where ID_Testa=@ID_Testa and ID_Kandidata=@ID_Kandidata
 end
exec usp_RezultatiTesta_Update @ID_Testa=3, @ID_Kandidata=18518, @Polozio=1, @OsvojeniBodovi=25, @Napomena='Pogresan broj bodova ocjena 8'
select * from RezultatiTesta
/*

8. Kreirati stored proceduru koja će služiti za brisanje testova zajedno sa svim rezultatima testiranja. Proceduru
pohranite pod nazivom usp_Testovi_Delete. Obavezno testirati ispravnost kreirane procedure.
*/ 
create procedure usp_Testovi_Delete
(@ID_Testa int)
as begin 
delete RezultatiTestawhere ID_Testa=@ID_Testadelete Testoviwhere ID_Testa=@ID_Testaend

/*
9. Kreirati trigger koji će spriječiti brisanje rezultata testiranja. Obavezno testirati ispravnost kreiranog triggera.
*/ 
create trigger block_delete_rezultata
on RezultatiTesta instead of delete 
as
begin 
RAISERROR('Nije moguce obrisati rezultate testiranja', 1,1)
rollback transaction 
end

delete RezultatiTesta
where ID_Testa=3
/* 

10. Uraditi full backup Vaše baze podataka na lokaciju D:\DBMS\Backup

*/

backup database to disk='D:\DBMS\Backup'
with format