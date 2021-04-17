/*	
*******************************************************************************************************************
			Ispit iz Naprednih baza podataka 11.07.2020.godine
*******************************************************************************************************************

*/

/*
	0. Ispitni zadatak imenovati vasim brojem indeksa (File--Save As)
	
*/

/*
	1. Kreirati novu baze podataka kroz SQL kod, koja nosi ime vaseg broja indeksa
	   Napomena: default postavke servera
	(5) bodova
*/


create database _12

use _12

/*	2a. Unutar svoje baze podataka kreirati tabele sa sljedecom strukturom.
		Napomena: Baza podataka je simulacija rezervacije letova

Osobe
	OsobaID, automatski generator neparnih vrijednosti i primarni kljuc
	Prezime, polje za unos 50 UNICODE karaktera (obavezan unos)
	Ime, polje za unos 50 UNICODE karaktera (obavezan unos)
	Email, polje za unos 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
	DatumRodjenja, polje za unos datuma, DEFAULT je NULL
	DatumKreiranjaZapisa, polje za unos datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa
	
*/
create table Osobe (
	OsobaID int identity(1,2) primary key, 
	Prezime nvarchar(50) not null, 
	Ime nvarchar(50) not null, 
	Email nvarchar(100) not null unique, 
	DatumRodjenja datetime default null, 
	DatumKreiranjaZapisa datetime not null default getdate()

)




/*
Kreirati ALIAS tip podatka za vrstu kreditne kartice, a na osnovu 25 UNICODE karaktera sa obaveznim unosom

*/ 
create type vrstakartice 
from nvarchar(25) not null

/* 
OsobeKartice
	OsobaKarticaID, automatski generator parnih vrijednosti i primarni kljuc
	TipKartice, koristiti ALIAS za tip kreditne kartice
	BrojKartice, polje za unos 25 UNICODE karaktera (obavezan unos)
	MjesecIsteka, tip podatka za najmanji opseg cijelog broja
	GodinaIsteka, tip podatka za sljedeci najmanji opseg cijelog broja
	DatumKreiranjaZapisa, polje za unos datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa
*/ 
create table OsobeKartice 
(
	OsobaKarticaID int identity(2,2) primary key, 
	TipKartice vrstakartice, 
	BrojKartice nvarchar(25) not null,
	MjesecIsteka tinyint, 
	GodinaIsteka smallint, 
	DatumKreiranjaZapisa datetime  not null default getdate()

)
/* 
Letovi
	LetID, automatski generator vrijednosti i primarni kljuc
	BrojLeta, polje za unos 4 UNICODE karaktera (obavezan unos)
	Polaziste, polje za unos 20 UNICODE karaktera (obavezan unos)
	Destinacija, polje za unos 20 UNICODE karaktera (obavezan unos)
	DatumKreiranjaZapisa, polje za unos datuma dodavanja zapisa (obavezan unos) DEFAULT je trenutni datum
	
	*/ 
	create table Letovi
	(
		LetID int identity(1,1) primary key , 
		BrojLeta nvarchar(4) not null, 
		Polaziste nvarchar(20) not null,
		Destinacija nvarchar(20) not null,
		DatumKreiranjaZapisa datetime not null default getdate() 

	)
	/* 
Rezervacije (Napomena: Putnik moze napraviti samo jednu rezervaciju unutar leta, sto je bitno za PK)
	RezervacijaID, automatski generator vrijednosti
	DatumRezervacije, polje za unos datuma (obavezan unos) DEFAULT je trenutni datum
	DatumKreiranjaZapisa, polje za unos datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
	DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa, DEFAULT je NULL

	(10) bodova
*/
create table Rezervacije 
( 
	RezervacijaID int identity(1,1), 

	DatumRezervacije datetime not null default getdate(), 
	DatumKreiranjaZapisa datetime default getdate(), 
	DatumModifikovanjaZapisa datetime default null,
	constraint PK_Rezervacije primary key (RezervacijaID,DatumRezervacije), 
	

) 








/*
	2b.	Modifikovati tabelu "Osobe" i dodati jednu izracunatu (trajno pohranjenju) 
		kolonu pod nazivom "GodinaRodjenja". 
		
		Napomena: Uzeti samo godinu iz polja "DatumRodjenja"
	(5) bodova

*/

alter table Osobe
add GodinaRodjenja as year(DatumRodjenja)






/*
	2c. Unosenje testnih podataka
	
	Iz baze podataka "AdventureWorks2014", a putem podupita selektovati zapise iz tabela: 
	(Person.Person, Person.EmailAddress i HumanResources.Employee) 
	(Kolone: LastName, FirstName, EmailAddress i BirthDate) i dodati u tabelu "Osobe". 
	
	*/ 
	insert into Osobe (Prezime,Ime, Email, DatumRodjenja)
	select PP.LastName, PP.FirstName, (select EA.EmailAddress from AdventureWorks2014.Person.EmailAddress as EA where EA.BusinessEntityID=PP.BusinessEntityID), (select HRE.BirthDate from AdventureWorks2014.HumanResources.Employee as HRE where HRE.BusinessEntityID=PP.BusinessEntityID) from AdventureWorks2014.Person.Person as PP where 
	PP.BusinessEntityID in (select EA.BusinessEntityID from  AdventureWorks2014.Person.EmailAddress as EA ) and PP.BusinessEntityID in ( select HRE.BusinessEntityID from  AdventureWorks2014.HumanResources.Employee as HRE ) 
	
	select * from Osobe
	select * from AdventureWorks2014.Person.Person

	/* 
	Napomena: Obavezno komandom testirati da li su podaci u tabeli nakon import operacije.

	Iz baze podataka "AdventureWorks2014", a putem podupita selektovati zapise iz tabela: 
	(Sales.PersonCreditCard i Sales.CreditCard) 
	(Kolone: tip kartice, broj kartice, mjesec i godina isteka) i dodati u tabelu "OsobeKartice". 
	
	*/ 
	select * from AdventureWorks2014.Sales.PersonCreditCard
	select * from AdventureWorks2014.Sales.CreditCard
	insert into OsobeKartice (TipKartice, BrojKartice, MjesecIsteka, GodinaIsteka)
	select CC.CardType, CC.CardNumber, CC.ExpMonth, CC.ExpYear
	from  AdventureWorks2014.Sales.CreditCard as CC
	where CC.CreditCardID in  (select CreditCardID from AdventureWorks2014.Sales.PersonCreditCard) 

	select * from  AdventureWorks2014.Sales.CreditCard as CC 
	inner join  AdventureWorks2014.Sales.PersonCreditCard as PCC
	on CC.CreditCardID=PCC.CreditCardID
	/* 
	Napomena:Obavezno komandom testirati da li su podaci u tabeli nakon import operacije.

	Jednom SQL komandom, u tabelu Letovi dodati tri zapisa sa sljedecim parametrima:
	  - 1023, SJJ, LHR
	  - 4844, LAX, SEA
	  - 5321, JFK, SFO
	
	Napomena: Obavezno komandom testirati da li su podaci u tabeli
	(5) bodova
*/
insert into Letovi
(BrojLeta, Polaziste, Destinacija) 
values 
(1023, 'SJJ', 'LHR'), 
(4844, 'LAX', 'SEA'), 
(5321, 'JFK', 'SFO')





/*
	3. Putem procedure, modifikovati sve tabela u vasoj bazi i dodati novu kolonu 
	   u svim tabelama (istovremeno): "DatumModifikovanjaZapisa" polje za unos 
	   datuma izmjene zapisa, DEFAULT je NULL
	(5) bodova
*/

create procedure proc_dodaj_kolonu 
as 
begin 
alter table Osobe
add DatumModifikovanjaZapisa datetime default null
alter table OsobeKartice 
add DatumModifikovanjaZapisa datetime default null
alter table Letovi 
add DatumModifikovanjaZapisa datetime default null

end 

exec proc_dodaj_kolonu




/*
	4. Kreirati uskladistenu proceduru koja ce vrsiti upis podataka u tabelu "Rezervacije" 
	   (sva polja), 4 zapisa proizvoljnog karaktera.
		
		Napomena:Obavezno komandom testirati da li su podaci u tabeli nakon izvrsenja procedure.
  
	(10) bodova
*/


create procedure proc_unesi_rezervacije

as 
begin 
insert into Rezervacije 
(  DatumRezervacije) 
values 
( '2020-09-12 10:59:01'),
( '2020-09-12 10:59:07'),
( '2020-09-12 10:59:10'),
( '2020-09-12 10:52:01')
end 


exec proc_unesi_rezervacije
/*
	5. Kreirati uskladistenu proceduru koja ce vrsiti izmjenu u tabeli "Rezervacije", 
	   tako sto ce  modifikovati datum rezervacije. Obratite paznju na broj atributa koje je 
	   potrebno izmjeniti kako bi poslovni proces bio kompletan. 
		
	   Napomena:Obavezno komandom testirati da li su podaci u u tabeli modifikovani nakon izvrsenja procedure.
  	(10) bodova
 */
 

 create procedure proc_update_rezervacije (
 @RezervacijaID int null, 
 @DatumRezervacije date null)
 as 
 begin 
 update Rezervacije 
 set DatumRezervacije=@DatumRezervacije, 
 DatumModifikovanjaZapisa=getdate()
 where RezervacijaID=@RezervacijaID	
 end
 

 exec proc_update_rezervacije @RezervacijaID=1, @DatumRezervacije='2020-10-02'

 select * from Rezervacije


/*
	6. Kreirati pogled sa sljedecom definicijom: Prezime i ime osobe, broj leta i broj rezervacije, 
		ali samo za one osobe koje su modfikovale rezervaciju. Dodati i jednu ekstra kolonu koja 
		pokazuje koliko je prošlo minuta od incijalne rezervacije pa do njenje izmjene.
		
		Napomena: Obavezno komandom testirati funkcionalnost view objekta.
	(5) bodova
*/

create view view_modifikovane_rezervacije
as
select O.Ime + O.Prezime as [Ime i prezime osobe], L.BrojLeta , R.RezervacijaID as [Broj rezervacije], datediff(MINUTE, R.DatumKreiranjaZapisa, R.DatumModifikovanjaZapisa) as [Vrijeme izmedu rezervacija]
from Osobe as O
inner join Rezervacije as R
on convert(date, R.DatumKreiranjaZapisa)=convert(date,O.DatumKreiranjaZapisa)
inner join Letovi as L
on convert(date, L.DatumKreiranjaZapisa)=convert(date, R.DatumKreiranjaZapisa)
where R.DatumModifikovanjaZapisa is not null 

select * from Rezervacije




/* 
						GRANICA ZA OCJENU 6 (55 bodova) 
*/

/*
	7a. Modifikovati tabele "Osobe" i dodati nove dvije kolone:
		Lozinka, polje za unos 100 UNICODE karaktera, DEFAULT je NULL
		Telefon, polje za unos 100 UNICODE karaktera, DEFAULT je NULL
	(5) bodova
*/


create procedure proc_alter_osobe
as
begin 
alter table Osobe
add Lozinka nvarchar(100) default null
alter table Osobe
add Telefon nvarchar(100) default null
end 

exec proc_alter_osobe

/*
	7b. Kreirati uskladistenu proceduru koja ce iz baze podataka "AdventureWorks2014" i tabela:
	(Person.Person, Person.Password, Person.EmailAddress i Person.PersonPhone) mapirati 
	odgovarajuce kolone sa pripadajucim podacima te ih prebaciti u tabelu "Osobe". 
	Voditi racuna da import ukljuci samo one osobe koji nisu zaposlenici. 
	
	Napomena: Obavezno komandom testirati da li su podaci u u tabeli
	(5) bodova
*/
create procedure proc_insert_osobe
as
begin 
insert into Osobe
(Prezime, Ime, Email, Lozinka,Telefon)
select PP.LastName, PP.FirstName, EA.EmailAddress,PW.PasswordHash, PH.PhoneNumber
from AdventureWorks2014.Person.Person as PP
inner join AdventureWorks2014.Person.EmailAddress as EA
on EA.BusinessEntityID=PP.BusinessEntityID
inner join AdventureWorks2014.Person.PersonPhone as PH
on PP.BusinessEntityID=PH.BusinessEntityID
inner join 
AdventureWorks2014.Person.Password as PW
on PW.BusinessEntityID=PP.BusinessEntityID
left join AdventureWorks2014.HumanResources.Employee as HRE
on PP.BusinessEntityID=HRE.BusinessEntityID
where HRE.BusinessEntityID is null
end



exec proc_insert_osobe


/* 
						GRANICA ZA OCJENU 7 (65 bodova) 
*/

/*
	8. Kreirati okidac nad tabelom "Osobe" za sve UPDATE operacije sa ciljem  da se nakon 
	   modifikovanja zapisa upise podatak o izmjeni u kolonu "DatumModifikovanjaZapisa".
	(10) bodova
*/


create trigger trig_update_osobe
on Osobe after update 
as 
begin 
update Osobe 
set DatumModifikovanjaZapisa=getdate()
from Osobe as O
inner join inserted as i 
on O.OsobaID=i.OsobaID
end 



/* 
						GRANICA ZA OCJENU 8 (75 bodova) 
*/

/*
	9a. Svim osobama u Vasoj bazi podataka generisati novu email adresu u formatu: 
		Ime.PrezimeOsobaID@ptf.unze.ba.ba, lozinku dugacku 16 karaktera putem SQL funkcije 
		koja generise slucajne jedinstvene vrijednosti.
		
		Napomena: Obavezno testirati da li su podaci modifikovani i da li je okidac iz zadatka 8 funkcionalan. U slucaju da okidac
		nije "reagovao" zadatak "9a" nece biti priznat
	(5) bodova
*/
update Osobe
set Email=O.Ime+'.'+O.Prezime+convert(nvarchar,O.OsobaID)+'@ptf.unze.ba.ba', 
Lozinka=left(newid(),16)
from Osobe as O


select * from Osobe



/*
	9b. Kreirati backup vase baze na default lokaciju servera, bez navodjenja staze (path).
	(5) bodova
*/

backup database _12 
to disk='h12.bak'

/* 
						GRANICA ZA OCJENU 9 (85 bodova) 
*/


/*
	10a. Kreirati uskladištenu proceduru koja brise sve osoba bez rezervacije.
	
		 Napomena: Obavezno testirati funkcionalnost procedure i obrisane podatke.
	(5) bodova
*/


create procedure proc_delete
as
begin 
delete Osobe
where DatumKreiranjaZapisa  in (select O.DatumKreiranjaZapisa from Osobe as O inner join Rezervacije as R on convert(Date,O.DatumKreiranjaZapisa)=convert(date, R.DatumKreiranjaZapisa) where O.DatumKreiranjaZapisa>R.DatumKreiranjaZapisa)
end 

exec proc_delete 


/*
	10b. Kreirati proceduru koja brise sve zapise iz svih tabela unutar jednog izvrsenja. 
		
		Napomena: Testirati da li su podaci obrisani.
	(5) bodova
*/
create procedure proc_delete_all
as
begin 
delete from Rezervacije
delete from Osobe
delete from Letovi
delete from OsobeKartice
end


exec proc_delete_all




/* 
						GRANICA ZA OCJENU 10 (95 bodova) 
*/

/*
	10c. Uraditi restore rezervene kopije baze podataka iz koraka 9b. 
	
		 Napomena: Provjeriti da li su podaci u tabelama.
	(5) bodova
*/
use master
alter database _12
set offline 


drop database _12

restore database _12
from disk='h12.bak' 
with replace

use _12
select * from Osobe