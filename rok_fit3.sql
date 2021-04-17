/*
1.	Kroz SQL kod napraviti bazu podataka koja nosi ime vašeg broja dosijea, 
a zatim u svojoj bazi podataka kreirati tabele sa sljedećom strukturom:
*/ 
create database "5"
use "5"
use master
drop database "5"
/* 
a)	Klijenti
i.	Ime, polje za unos 50 karaktera (obavezan unos)
ii.	Prezime, polje za unos 50 karaktera (obavezan unos)
iii.	Drzava, polje za unos 50 karaktera (obavezan unos)
iv.	Grad, polje za  unos 50 karaktera (obavezan unos)
v.	Email, polje za unos 50 karaktera (obavezan unos)
vi.	Telefon, polje za unos 50 karaktera (obavezan unos)
*/ 
create table Klijenti (
	KlijentID  int identity(1,1) primary key, 
	Ime nvarchar(50) not null, 
	Prezime nvarchar(50) not null ,
	Drzava nvarchar(50) not null ,
	Grad nvarchar(50) not null, 
	Email nvarchar(50) not null, 
	Telefon nvarchar(50) )

/* 
b)	Izleti
i.	Sifra, polje za unos 10 karaktera (obavezan unos)
ii.	Naziv, polje za unos 100 karaktera (obavezan unos)
iii.	DatumPolaska, polje za unos datuma (obavezan unos)
iv.	DatumPovratka, polje za unos datuma (obavezan unos)
v.	Cijena, polje za unos decimalnog broja (obavezan unos)
vi.	Opis, polje za unos dužeg teksta (nije obavezan unos)
*/ 
create table Izleti 
(
	IzletID int identity(1,1)  primary key,
	Sifra nvarchar(10) not null, 
	Naziv nvarchar(100) not null, 
	DatumPolaska date not null,
	DatumPovratka date not null,
	Cijena decimal(10,2) not null, 
	Opis text 
	)

/* 
c)	Prijave
i.	Datum, polje za unos datuma i vremena (obavezan unos)
ii.	BrojOdraslih polje za unos cijelog broja (obavezan unos)
iii.	BrojDjece polje za unos cijelog broja (obavezan unos)
Napomena: Na izlet se može prijaviti više klijenata, dok svaki klijent može prijaviti više izleta. 
Prilikom prijave klijent je obavezan unijeti broj odraslih i broj djece koji putuju u sklopu izleta.
*/
create table Prijave
(
KlijentID int constraint FK_prijave_klijent foreign key references Klijenti(KlijentID), 
IzletID int constraint FK_prijave_izlet foreign key references Izleti(IzletID), 
Datum datetime not null, 
BrojOdraslih int not null, 
BrojDjece int not null, 
constraint PK_Prijave primary key (KlijentID, IzletID)
) 


/*
2.	Iz baze podataka AdventureWorks2014 u svoju bazu podataka prebaciti sljede�e podatke:
a)	U tabelu Klijenti prebaciti sve uposlenike koji su radili u odjelu prodaje (Sales) 
i.	FirstName -> Ime
ii.	LastName -> Prezime
iii.	CountryRegion (Name) -> Drzava
iv.	Addresss (City) -> Grad
v.	EmailAddress (EmailAddress)  -> Email (Izme�u imena i prezime staviti ta�ku)
vi.	PersonPhone (PhoneNumber) -> Telefon
*/ 
select EmailAddress, stuff(EmailAddress,4,1,'.') from AdventureWorks2014.Person.EmailAddress
select * from   AdventureWorks2014.Sales.Customer as C

insert into Klijenti(Ime, Prezime, Drzava, Grad, Email, Telefon)
select PP.FirstName, PP.LastName, CR.Name, PA.City, PP.FirstName + '.' + PP.LAStName + SUBSTRING(EA.EmailAddress, CHARINDEX('@', EA.EmailAddress), 25), PH.PhoneNumber from 
AdventureWorks2014.Person.Person as PP
inner join AdventureWorks2014.Person.EmailAddress as EA
on PP.BusinessEntityID=EA.BusinessEntityID 
inner join AdventureWorks2014.Person.PersonPhone as PH
on PP.BusinessEntityID=PH.BusinessEntityID
inner join AdventureWorks2014.Person.BusinessEntity as BE
on BE.BusinessEntityID=PP.BusinessEntityID
inner join AdventureWorks2014.Person.BusinessEntityAddress as BEA
on BEA.BusinessEntityID=PP.BusinessEntityID
inner join AdventureWorks2014.Person.Address as PA
on PA.AddressID=BEA.AddressID 
inner join AdventureWorks2014.Person.StateProvince as ST
on ST.StateProvinceID=PA.StateProvinceID
inner join AdventureWorks2014.Person.CountryRegion as CR
on ST.CountryRegionCode=CR.CountryRegionCode
inner join AdventureWorks2014.HumanResources.Employee as HEA
on HEA.BusinessEntityID=PP.BusinessEntityID
where HEA.JobTitle not like '%Sales%'
drop table Klijenti
/* 
b)	U tabelu Izleti dodati 3 izleta (proizvoljno)	
*/
INSERT INTO Izleti (Sifra, Naziv, DatumPolaska, DatumPovratka, Cijena)
VALUES ('AB-100-10','Putovanje u Grad 1','20170925','20171025', 1000),
	   ('AB-100-20','Putovanje u Grad 2','20170925','20171025', 2000),
	   ('AB-100-30','Putovanje u Grad 3','20170925','20171025', 3000)

/*
3.	Kreirati uskladištenu proceduru za unos nove prijave. Proceduri nije potrebno proslijediti parametar Datum.
Datum se uvijek postavlja na trenutni. Koristeći kreiranu proceduru u tabelu Prijave dodati 10 prijava.
*/
alter table Prijave
create procedure  proc_Prijave_insert
(@KlijentID int=null,
@IzletID int=null, 
@BrojOdraslih int=null,
@BrojDjece int=null)
as
begin 

insert into Prijave(KlijentID, IzletID, Datum, BrojOdraslih, BrojDjece)
values (@KlijentID, @IzletID,getdate(),  @BrojOdraslih, @BrojDjece)
end

select * from Klijenti
select * from Izleti
EXEC proc_Prijave_insert 1,1,2,2 
EXEC proc_Prijave_insert 2,1,2,2 
EXEC proc_Prijave_insert 4,1,2,3 
EXEC proc_Prijave_insert 5,2,2,3
EXEC proc_Prijave_insert 1,2,2,2
EXEC proc_Prijave_insert 8,2,2,1
EXEC proc_Prijave_insert 9,2,2,3
EXEC proc_Prijave_insert 3,3,2,2
EXEC proc_Prijave_insert 5,3,2,3
EXEC proc_Prijave_insert 4,3,2,2

/*
4.	Kreirati index koji će spriječiti dupliciranje polja Email u tabeli Klijenti. Obavezno testirati ispravnost kreiranog indexa.
*/
create unique nonclustered index IX_unique_email
on Klijenti(Email)

drop index  IX_unique_email on Klijenti
create unique nonclustered index IX_unique_email 
on Klijenti(Email)


INSERT INTO Klijenti
VALUES ('Test', 'Test', 'Test', 'Test', 'test@test.com','Test')

/*
5.	Svim izletima koji imaju više od 3 prijave cijenu umanjiti za 10%.
*/
select * from Izleti
update Izleti
set Cijena=1800
where IzletID in (select IzletID from Prijave group by IzletID having(count(IzletID)) >3)
/*
6.	Kreirati view (pogled) koji prikazuje podatke o izletu: šifra, naziv, datum polaska, datum povratka i cijena, 
te ukupan broj prijava na izletu, 
ukupan broj putnika, ukupan broj odraslih i ukupan broj djece. Obavezno prilagoditi format datuma (dd.mm.yyyy).
*/
create view view_izleta
as
select I.sifra, I.Naziv, convert(nvarchar,I.DatumPolaska) as DatumPolaska, convert(nvarchar,I.DatumPovratka) as DatumPovratka, I.Cijena, count(*)as [Ukupan broj prijava], sum(P.BrojOdraslih+P.BrojDjece) as [Ukupan broj putnika], 
sum(P.BrojOdraslih) as BrojOdraslih, sum(P.BrojDjece) as UkupnoDjece
from Izleti as I
inner join Prijave as P 
on I.IzletID=P.IzletID
group by I.sifra, I.Naziv, I.DatumPolaska, I.DatumPovratka, I.Cijena
/*
7.	Kreirati uskladištenu proceduru koja će na osnovu unesene šifre izleta prikazivati zaradu od izleta i 
to sljedeće kolone: naziv izleta, zarada od odraslih, zarada od djece, ukupna zarada. 
Popust za djecu se obračunava 50% na ukupnu cijenu za djecu. Obavezno testirati ispravnost kreirane procedure.
*/

create procedure zarada_po_izletu(
@Sifra nvarchar(15) =null
)
as
begin 
select I.Naziv,sum(P.BrojOdraslih)*I.Cijena as ZaradaOdODraslih, sum(P.BrojDjece)*I.Cijena*0.5 as ZaradaOdDjece, sum(P.BrojOdraslih)*I.Cijena +Sum(P.BrojDjece)*I.Cijena*0.5 as UkupnaZarada
from Izleti as I
inner join Prijave as P
on I.IzletID=P.IzletID
where I.Sifra=@Sifra
group by I.Naziv,I.Cijena
end 
select * from Izleti
exec zarada_po_izletu 'AB-100-10'
/*
8.	a) Kreirati tabelu IzletiHistorijaCijena u koju je potrebno pohraniti identifikator izleta kojem je cijena izmijenjena, 
datum izmjene cijene, staru i novu cijenu. Voditi računa o tome da se jednom izletu može više puta mijenjati
cijena te svaku izmjenu treba zapisati u ovu tabelu.
b) Kreirati trigger koji će pratiti izmjenu cijene u tabeli Izleti te za svaku izmjenu u prethodno
kreiranu tabelu pohraniti podatke izmijeni.
c) Za određeni izlet (proizvoljno) ispisati sljdedeće podatke: naziv izleta, datum polaska, datum povratka, 
trenutnu cijenu te kompletnu historiju izmjene cijena tj. datum izmjene, staru i novu cijenu.
*/

create table IzletiHistorijaCijena
(
IzmjenaID int identity primary key, 
IzletID int constraint FK_IZH_Izlet foreign key references Izleti(IzletID), 
DatumIzmjene datetime default getdate(), 
StaraCijena money, NovaCijena money
)
drop table IzletiHistorijaCijena

create trigger prati_cijene_izleta
on Izleti after update 
as
begin 
insert into IzletiHistorijaCijena
values ( (select Iz.IzletID from Izleti as Iz inner join inserted as i on i.IzletID=Iz.IzletID), getdate(), (select d.Cijena from deleted as d inner join Izleti as i on i.IzletID=d.IzletID), (select i.Cijena from inserted as i inner join Izleti as Iz on Iz.IzletID=i.IzletID ))
end 


UPDATE Izleti
SET Cijena = Cijena+ 22
WHERE IzletID = 2

select * from IzletiHistorijaCijena

/*9. Obrisati sve klijente koji nisu imali niti jednu prijavu na izlet. */

delete Klijenti
where KlijentID not in (select KlijentID from Prijave )

SELECT K.KlijentID
	FROM Klijenti AS K 
        LEFT JOIN Prijave AS P ON K.KlijentID = P.KlijentID
	GROUP BY K.KlijentID
	HAVING COUNT(P.KlijentID) = 0



	select P.Ime , K.KlijentID
	from Prijave as K 
	left join Klijenti as P
	on P.KlijentID=K.KlijentID
	select K.KlijentID
	from Klijenti as K
	left join Prijave as P
	on K.KlijentID=P.KlijentID 
	group by K.KlijentID
	having count(P.KlijentID)=0

/*10. Kreirati full i diferencijalni backup baze podataka na lokaciju servera D:\BP2\Backup*/

backup database "5" 
to disk='5.bak'


backup database "5" 
to disk='5.bak'
with differential

