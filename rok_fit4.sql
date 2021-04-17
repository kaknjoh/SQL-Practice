/*
1.	Kroz SQL kod,naparaviti bazu podataka koja nosi ime vaseg broja dosijea sa default postavkama
*/

create database "4" 
use "4"

/*
2.	Unutar svoje baze kreirati tabele sa sljedecom strukutrom
Autori
-	AutorID 11 UNICODE karaltera i primarni kljuc
-	Prezime 25 UNICODE karaktera (obavezan unos)
-	Ime 25 UNICODE karaktera (obavezan unos)
-	Telefon 20 UNICODE karaktera DEFAULT je NULL
-	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
-	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
*/  
create table Autori
( 
	AutorID nvarchar(11) primary key , 
	Prezime nvarchar(25) not null,
	Ime nvarchar(25) not null, 
	Telefon nvarchar(20) default null, 
	DatumKreiranjaZapisa datetime not null constraint DF_datum1 default getdate(),
	DatumModifikovanjaZapisa datetime constraint DF_datum2 default null
)
 


/* 
Izdavaci 
-	IzdavacID 4 UNICODE karaktera i primarni kljuc
-	Naziv 100 UNICODE karaktera(obavezan unos),jedinstvena vrijednost
-	Biljeske 1000 UNICODE karaktera DEFAULT tekst je Lorem ipsum
-	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
-	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL

*/
create table Izdavaci (
IzdavacID nvarchar(4) constraint PK_izdavaci primary key, 
Naziv nvarchar(100) not null unique ,
Biljeske nvarchar(1000) default 'Lorem ispum' , 
DatumKreiranjaZapisa datetime not null constraint DF_datum3 default getdate(),
DatumModifikovanjaZapisa datetime constraint DF_datum4 default null 
)

/*
Naslovi
-	NaslovID 6 UNICODE karaktera i primarni kljuc
-	IzdavacID ,spoljni kljuc prema tabeli Izdavaci
-	Naslov 100 UNICODE karaktera (obavezan unos)
-	Cijena monetarni tip
-	DatumIzdavanja datumska vraijabla (obavezan unos) DEFAULT datum unosa zapisa
-	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
-	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
*/ 
create table Naslovi 
( 
NaslovID nvarchar(6) constraint PK_naslovi primary key, 
IzdavacID nvarchar(4), 
Naslov nvarchar(100) not null, 
Cijena money, 
DatumIzdavanja datetime not null constraint DF_datum default getdate(), 
DatumKreiranjaZapisa datetime not null constraint DF_datum5 default getdate(), 
DatumModifikovanjaZapisa datetime constraint DF_datum6 default null,
constraint FK_Naslovi_Izdavac foreign key(IzdavacID) references Izdavaci(IzdavacID)
)


/*
NasloviAutori
-	AutorID ,spoljni kljuc prema tabeli Autori
-	NaslovID ,spoljni kljuc prema tabeli Naslovi
-	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
-	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
*/

create table NasloviAutori 
(
AutorID nvarchar(11) constraint FK_NasloviAutori_Autori references Autori(AutorID), 
NaslovID nvarchar(6) constraint FK_NasloviAutori_Naslovi references Naslovi(NaslovID), 
DatumKreiranjaZapisa datetime constraint DF_datum7 default getdate(), 
DatumModifikovanjaZapisa datetime constraint DF_datum8 default null
)



/*
2b. Generisati testne podatke i obavezno testirati da li su podaci u tabeli za svaki korak posebno:
-	Iz baze podataka pubs tabela authors,  putem podupita u tabelu Autori importovati sve slucajno sortirane zapise.
Vodite racuna da mapirate odgovarajuce kolone.

*/

 insert into Autori (AutorID, Prezime, Ime, Telefon)
select au_id, au_lname, au_fname, phone
from pubs.dbo.authors
select * from pubs.dbo.authors
/* 
-	Iz baze podataka pubs i tabela publishers i pub_info , a putem podupita u tabelu Izdavaci importovati
sve slucajno sortirane zapise.Kolonu pr_info mapirati kao biljeske i iste skratiti na 100 karaktera.
Vodte racuna da mapirate odgovarajuce kolone

*/
select * from pubs.dbo.publishers
select * from pubs.dbo.pub_info
/*
-	Iz baze podataka pubs tabela titles ,a putem podupita u tablu Naslovi importovati sve zapise.
Vodite racuna da mapirate odgvarajuce kolone
*/
INSERT INTO Naslovi(NaslovID, IzdavacID, Naslov, Cijena)
SELECT t.title_id, t.pub_id, t.title, t.price
FROM 
(
	SELECT title_id, pub_id,title, price
	FROM pubs.dbo.titles
) AS t
/*
-	Iz baze podataka pubs tabela titleauthor, a putem podupita u tabelu NasloviAutori importovati zapise.
Vodite racuna da mapirate odgovrajuce koloone
*/
INSERT INTO NasloviAutori(AutorID, NaslovID)
SELECT ta.au_id, ta.title_id
FROM 
(
	SELECT au_id,title_id
	FROM pubs.dbo.titleauthor
) AS ta

insert into izdavaci (IzdavacID, Naziv, Biljeske)
select t.pub_id, t.pub_name, t.pr_info
from (select p.pub_id, p.pub_name, substring(pin.pr_info, 0, 100) as pr_info from 
pubs.dbo.publishers as p inner join pubs.dbo.pub_info as pin 
on p.pub_id=pin.pub_id
) as t

/*
2c. Kreiranje nove tabele,importovanje podataka i modifikovanje postojece tabele:
     Gradovi
-	GradID ,automatski generator vrijednosti cija je pocetna vrijednost je 5 i uvrcava se za 5,primarni kljuc
-	Naziv 100 UNICODE karaktera (obavezan unos),jedinstvena vrijednost
-	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
-	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
-	Iz baze podataka pubs tebela authors a putem podupita u tablelu Gradovi imprtovati nazive gradova bez duplikata
-	Modifikovati tabelu Autori i dodati spoljni kljuc prema tabeli Gradovi
*/
create table Gradovi
(
GradID int identity(5,5) primary key, 
Naziv nvarchar(100) not null unique, 
DatumKreiranjaZapisa datetime not null constraint DF_datum10 default getdate(), DatumModifikovanjaZapisa datetime constraint DF_datum9 default null
)
select * from pubs.dbo.authors
set identity_insert Gradovi off
insert into Gradovi ( Naziv) 
select t.city from (select distinct city from pubs.dbo.authors ) as t 


alter table Autori 
add GradID int constraint FK_Autori_Gradovi references Gradovi(GradID)
/*
2d. Kreirati dvije uskladistene procedure koja ce modifikovati podatke u tabelu Autori
-	Prvih deset autora iz tabele postaviti da su iz grada : San Francisco
-	Ostalim autorima podesiti grad na : Berkeley
*/
select * from Autori
select * from Gradovi
create procedure aut1
as
begin 
update Autori 
set GradID=65
where AutorID in (select top 10 AutorID from Autori) 
end

exec aut1

create procedure aut2
as begin 
update Autori 
set GradID=10
where GradID is null
end 
exec aut2
/*
3.	Kreirati pogled sa seljdeceom definicijom: Prezime i ime autora (spojeno),grad,naslov,cijena,izdavac i
biljeske ali samo one autore cije knjige imaju odredjenu cijenu i gdje je cijena veca od 10.
Takodjer naziv izdavaca u sredini imena treba ima ti slovo & i da su iz grada San Francisco.Obavezno testirati funkcijonalnost
*/

create view view_1
as
select A.Prezime + ' ' + A.Ime as [Ime i prezime autora], G.Naziv as NazivGrada, N.Naslov, N.Cijena, I.Naziv as NazivIzdavaca, I.Biljeske 
from Autori as A 
inner join Gradovi as G
on A.GradID=G.GradID
inner join NasloviAutori as NA
on NA.AutorID=A.AutorID
inner join Naslovi as N 
on N.NaslovID=NA.NaslovID
inner join Izdavaci as I 
on I.IzdavacID=N.IzdavacID
where N.Cijena is not null and N.Cijena>10
and I.Naziv like '%&%' and G.Naziv= 'San Francisco'
/*
4.	Modifikovati tabelu autori i dodati jednu kolonu:
-	Email,polje za unos 100 UNICODE kakraktera ,DEFAULT je NULL
*/
alter table Autori 
add Email nvarchar(100) default null

/*
5.	Kreirati dvije uskladistene procedure koje ce modifikovati podatke u tabeli Autori i svim autorima generisati novu email adresu:
-	Prva procedura u formatu Ime.Prezime@fit.ba svim autorima iz grada San Francisco
-	Druga procedura u formatu Prezime.ime@fit.ba svim autorima iz grada Berkeley
*/
create procedure autori1
as
begin 
update Autori
set Email=Ime+'.'+Prezime+'@fit.ba' 
where GradID in (select GradID from Gradovi where Naziv='San Francisco')
end 
exec autori1

create procedure autori2
as
begin 
update Autori 
set Email=Prezime+'.'+LOWER(Ime)+'@fit.ba'
where GradID in (select GradID from Gradovi where Naziv='Berkeley')
end
exec autori2

/*
6.	Iz baze podataka AdventureWorks2014 u lokalnu,privremenu,tabelu u vasu bazu podataka imoportovati zapise o osobama ,
a putem podupita. Lista kolona je Title,LastName,FirstName,
EmailAddress,PhoneNumber,CardNumber.
Kreirati dvije dodatne kolone UserName koja se sastoji od spojenog imena i prezimena(tacka izmedju) i
kolona Password za lozinku sa malim slovima dugacku 16 karaktera.Lozinka se generise putem SQL funkcije za
slucajne i jednistvene ID vrijednosti.Iz lozinke trebaju biti uklonjene sve crtice '-' i zamjenjene brojem '7'.
Uslovi su da podaci ukljucuju osobe koje imaju i nemaju kreditanu karticu, a 
NULL vrijesnot u koloni Titula treba zamjenuti sa 'N/A'.Sortirati prema prezimenu i imenu.
Testirati da li je tabela sa podacima kreirana
*/
select ('Teorija','a',7)
select* from AdventureWorks2014.Sales.PersonCreditCard
select * 
into osoba 
from (
select isnull(PP.Title,'N/A') as Title, PP.LastName, PP.FirstName, EA.EmailAddress, PH.PhoneNumber,CC.CardNumber, PP.FirstName+'.'+PP.LastName as [UserName],                        lower(replace(left(newid(),16),'-',7)) as Lozinka
 from AdventureWorks2014.Person.Person as PP
 inner join AdventureWorks2014.Person.EmailAddress as EA
 on PP.BusinessEntityID=EA.BusinessEntityID
 inner join AdventureWorks2014.Person.PersonPhone as PH 
 on PH.BusinessEntityID=PP.BusinessEntityID
 left join AdventureWorks2014.Sales.PersonCreditCard as PCC
 on PP.BusinessEntityID=PCC.BusinessEntityID
 left join AdventureWorks2014.Sales.CreditCard as CC
 on PCC.CreditCardID=CC.CreditCardID
) as t
 order by t.LastName, t.FirstName
 drop table osoba
/*
7.	Kreirati indeks koji ce nad privremenom tabelom iz prethodnog koraka,primarno,maksimalno 
ubrzati upite koje koriste kolonu UserName,a sekundarno nad kolonama LastName i FirstName.Napisati testni upit
*/
select * from osoba
create nonclustered index IX_UserName
on osoba(UserName)
include(LastName, FirstName)

select UserName, FirstName, LastName 
from osoba
where UserName like 'Catheri%' 


SELECT 
     p.Titula,
     p.FirstName,
     p.LAStName,
     p.EmailAddress,
     p.PhoneNumber,
     p.CardNumber,
     p.UserName,
     p.Lozinka
INTO #temp
FROM 
(
	SELECT 
          ISNULL(P.Title,'N/A') AS Titula,
          P.FirstName,
          P.LAStName,
          EA.EmailAddress,
          PP.PhoneNumber
          ,CC.CardNumber,
		LOWER(P.FirstName + '.' + P.LAStName) AS UserName,
		LOWER(REPLACE(LEFT(NEWID(),16), '-', '7')) AS Lozinka
	FROM AdventureWorks2014.Person.Person AS P 
          INNER JOIN AdventureWorks2014.Person.EmailAddress AS EA ON P.BusinessEntityID = EA.BusinessEntityID 
          INNER JOIN AdventureWorks2014.Person.PersonPhone AS PP ON P.BusinessEntityID = PP.BusinessEntityID 
          LEFT JOIN AdventureWorks2014.Sales.PersonCreditCard AS PCC ON P.BusinessEntityID = PCC.BusinessEntityID 
          LEFT JOIN AdventureWorks2014.Sales.CreditCard AS CC ON PCC.CreditCardID = CC.CreditCardID
) AS p
ORDER BY p.LastName,p.FirstName

/*
8.	Kreirati uskladistenu proceduru koja brise sve zapise iz privremen tabele koje nemaju kreditnu karticu.
Obavezno testirati funkcjionalnost
*/
create procedure brisi
as begin 

delete osoba
where CardNumber is null
end
exec brisi

/*
9.	Kreirati backup vase baze na default lokaciju servera i nakon toga obrisati privremenu tabelu
*/
backup database "4" 
to disk='4.bak'

drop table osoba

/*
10.	Kreirati proceduru koja brise sve zapise i svih tabela unutar jednog izvrsenja.Testirati da li su podaci obrisani
*/
create procedure brisi_sve
as
begin 
delete from NasloviAutori
delete from Autori
delete from Izdavaci
delete from Naslovi
delete from Gradovi
end

select * from Izdavaci
exec brisi_sve
