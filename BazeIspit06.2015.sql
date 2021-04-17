create database ispit_06_15  on  primary (
NAME='ispit_06_15.mdf',
FILENAME='c:\BP2\data\ispit_06_15.mdf',
SIZE=5 MB,
MAXSIZE=UNLIMITED,
FILEGROWTH=10%) ,

(
NAME='ispit_06_15_sek.ndf',
FILENAME='c:\BP2\data\ispit_06_15_sek.ndf',
SIZE=5 MB,
MAXSIZE=UNLIMITED,
FILEGROWTH=10%)
LOG ON 
(
NAME='ispit_06_15_log.mdf',
FILENAME='c:\BP2\LOG\ispit_06_15_log.ldf',
SIZE=2 MB,
MAXSIZE=UNLIMITED,
FILEGROWTH=5%)
/* 2 */ 

use ispit_06_15 

create table Kandidati(
KandidatID int primary key, 
Ime nvarchar(30) not null, 
Prezime nvarchar(30) not null, 
JMBG nvarchar(13) not null unique, 
DatumRodjenja date not null, 
MjestoRodjenja nvarchar(30), 
Telefon nvarchar(20), 
Email nvarchar(50) unique) 


create table Testovi (
TestID int primary key, 
Datum datetime not null, 
Naziv nvarchar(50) not null, 
Oznaka nvarchar(10) not null unique, 
Oblast nvarchar(50) not null , 
MaxBrojBodova int not null, 
Opis nvarchar(250)
)


create table RezultatiTesta(
KandidatID int, 
TestID int, 
Polozio nvarchar(2) not null,
OsvojeniBodovi decimal(10,2) not null, 
Napomena nvarchar(200),
constraint PK_RezultatiTesta primary key (KandidatID, TestID), 
constraint FK_RezultatiTesta_Kandidat foreign key (KandidatID) references Kandidati(KandidatID), 
constraint FK_RezultatiTesta_Testovi foreign key (TestID) references Testovi(TestID)
) 


/* 3 */ 

select * from AdventureWorks2014.Person.PersonPhone

insert into Kandidati 
select  top 10 P.BusinessEntityID, P.FirstName, P.LastName, '0'+right(C.rowguid,12), C.ModifiedDate, PA.City, PH.PhoneNumber, PE.EmailAddress
from AdventureWorks2014.Person.Person as P
inner join AdventureWorks2014.Person.PersonPhone as PH
on P.BusinessEntityID=PH.BusinessEntityID
inner join AdventureWorks2014.Person.EmailAddress as PE
on PE.BusinessEntityID=P.BusinessEntityID
inner join   AdventureWorks2014.Person.BusinessEntity as BE 
on P.BusinessEntityID=BE.BusinessEntityID 
inner join AdventureWorks2014.Person.BusinessEntityAddress as BEA
on BE.BusinessEntityID=BEA.BusinessEntityID
inner join AdventureWorks2014.Person.Address as PA
on PA.AddressID=BEA.AddressID
inner join AdventureWorks2014.Sales.Customer as C
on P.BusinessEntityID=C.PersonID

select getdate()


insert into Testovi values 
( 1,  getdate(),'Parcijala primjenjena matematika', 'HC-15-AR', 'Primjenjena matematika', 100,'Test iz primjenjene matematike'), 
( 2,  '2020-04-23 02:01:30.730','Integralni elektronika', 'HC-16-ER', 'Elektronika', 120,'Elektronika i robotika test'), 
( 3, '2019-02-17 14:01:30.730', 'Zavrsni ispit racunarstvo ', 'HC-17-BR', 'Racunarstvo', 80,'Osnove racunarstva')



/* 4 */ 

create procedure usp_RezultatiTesta_Insert 
(
@KandidatID int=null,
@TestID int=null, 
@Polozio nvarchar(2)=null,
@OsvojeniBodovi decimal(10,2)=null,
@Napomena nvarchar(50)=null)
as 
begin 
insert into RezultatiTesta values (
@KandidatID, @TestID, @Polozio, @OsvojeniBodovi, @Napomena) 
end 
select * from Kandidati 6229, 13531 ,11901, 6990,6229,20229
exec  usp_RezultatiTesta_Insert @KandidatID=3878, @TestID=1,@Polozio='DA', @OsvojeniBodovi=55,@Napomena='Ocjena 6 '
exec  usp_RezultatiTesta_Insert @KandidatID=5454, @TestID=1,@Polozio='DA', @OsvojeniBodovi=55,@Napomena='Ocjena 7 '
exec  usp_RezultatiTesta_Insert @KandidatID=3878, @TestID=1,@Polozio='DA', @OsvojeniBodovi=55,@Napomena='Ocjena 8 '
exec  usp_RezultatiTesta_Insert @KandidatID=6229, @TestID=2,@Polozio='DA', @OsvojeniBodovi=55,@Napomena='Ocjena 9 '
exec  usp_RezultatiTesta_Insert @KandidatID=13531, @TestID=1,@Polozio='NE', @OsvojeniBodovi=40,@Napomena='Ocjena 5 '
exec  usp_RezultatiTesta_Insert @KandidatID=11901, @TestID=1,@Polozio='DA', @OsvojeniBodovi=98,@Napomena='Ocjena 10 '
exec  usp_RezultatiTesta_Insert @KandidatID=6990, @TestID=3,@Polozio='DA', @OsvojeniBodovi=80,@Napomena='Ocjena 8 '
exec  usp_RezultatiTesta_Insert @KandidatID=3878, @TestID=3,@Polozio='DA', @OsvojeniBodovi=68,@Napomena='Ocjena 7 '
exec  usp_RezultatiTesta_Insert @KandidatID=20229, @TestID=2,@Polozio='DA', @OsvojeniBodovi=56,@Napomena='Ocjena 6 '


/* 5 */ 


/*  Kreirati view (pogled) nad podacima koji će sadržavati sljedeća polja: ime i prezime, jmbg, telefon i email
kandidata, zatim datum, naziv, oznaku, oblast i max. broj bodova na testu, te polje položio, osvojene bodove i
procentualni rezultat testa. View pohranite pod nazivom view_Rezultati_Testiranja.*/ 
create view view_Rezultati_Testiranja 
as 
(select k.Ime + k.Prezime as ImePrezime, k.JMBG, k.Telefon , k.Email, 
T.Datum, T.Naziv,T.Oznaka,T.MaxBrojBodova, RT.Polozio,RT.OsvojeniBodovi, convert(nvarchar,convert(decimal(10,2),round(RT.OsvojeniBodovi/T.MaxBrojBodova * 100,2)))+ '%' as Postotak
from Kandidati as k
inner join RezultatiTesta as RT
on k.KandidatID=RT.KandidatID
inner join Testovi as T
on T.TestID=RT.TestID
)

/* 6 */ 

/* . Kreirati stored proceduru koja će na osnovu proslijeđenih parametara @OznakaTesta i @Polozio prikazivati
rezultate testiranja. Kao izvor podataka koristiti prethodno kreirani view. Proceduru pohraniti pod nazivom
usp_RezultatiTesta_SelectByOznaka. Obavezno testirati ispravnost kreirane procedure */ 



create procedure usp_RezultatiTesta_SelectByOznaka (
@OznakaTesta nvarchar(10)=null,
@Polozio nvarchar(2) = null) 
as begin
select * from view_Rezultati_Testiranja 
where Oznaka= @OznakaTesta and  Polozio =@Polozio
end
 

 drop procedure usp_RezultatiTesta_SelectByOznaka

exec usp_RezultatiTesta_SelectByOznaka @OznakaTesta='HC-15-AR', @Polozio='NE'


/* 7 */ 

/*  . Kreirati proceduru koja će služiti za izmjenu rezultata testiranja. Proceduru pohraniti pod nazivom
usp_RezultatiTesta_Update. Obavezno testirati ispravnost kreirane procedure.  */ 


create procedure proc_update_rezultat(
@KandidatID int=null, 
@TestID int=null,
@Polozio nvarchar(2) =null,
@OsvojeniBodovi decimal(10,2)=null,
@Napomena nvarchar(50) =null)
as begin
update RezultatiTesta
set 
Polozio =@Polozio,
OsvojeniBodovi=@OsvojeniBodovi,
Napomena=@Napomena
where TestID=@TestID and KandidatID=@KandidatID
end 

exec proc_update_rezultat @KandidatID=3878,@TestID=1, @Polozio='NE',@OsvojeniBodovi=25,@Napomena='Ocjena 5'


/* 8 */ 
/*
Kreirati stored proceduru koja će služiti za brisanje testova zajedno sa svim rezultatima testiranja. Proceduru
pohranite pod nazivom usp_Testovi_Delete. Obavezno testirati ispravnost kreirane procedure. */ delete RezultatiTestawhere TestID=1select * from RezultatiTestaselect * from Kandidaticreate procedure usp_Testovi_Delete ( @TestID int=null)as begindelete RezultatiTestawhere TestID=@TestIDdelete Testoviwhere TestID=@TestIDendexec usp_Testovi_Delete @TestID=2/*  9 */ CREATE  TRIGGER prev_del
 ON RezultatiTesta
 INSTEAD OF DELETE
 AS
BEGIN
  select * from Testovi
ENDexec usp_Testovi_Delete @TestID=2