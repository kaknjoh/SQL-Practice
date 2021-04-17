create database _7_13


use _7_13



/* 


5. U vašoj bazi podataka keirati tabele sa sljedećim parametrima:
- Kupci
	- KupacID, automatski generator vrijednosti i primarni ključ
 	- Ime, polje za unos 35 UNICODE karaktera (obavezan unos),
	- Prezime, polje za unos 35 UNICODE karaktera (obavezan unos),
	- Telefon, polje za unos 15 karaktera (nije obavezan),
	- Email, polje za unos 50 karaktera (nije obavezan),
	- KorisnickoIme, polje za unos 15 karaktera (obavezan unos) jedinstvena vrijednost,
	- Lozinka, polje za unos 15 karaktera (obavezan unos)

	*/ 

	create table Kupci 
(
	KupacID int  identity(1,1) primary key ,
	Ime nvarchar(35) not null, 
	Prezime nvarchar(35) not null, 
	Telefon nvarchar(15), 
	Email nvarchar(50) , 
	KorisnickoIme nvarchar(15) not null unique, 
	Lozinka nvarchar(15) not null
)
/* 


- Proizvodi
	- ProizvodID, automatski generator vrijednosti i primarni ključ
	- Sifra, polje za unos 25 karaktera (obavezan unos)
	- Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
	- Cijena, polje za unos decimalnog broj (obavezan unos)
	- Zaliha, polje za unos cijelog broja (obavezan unos)
	*/ 
	create table Proizvodi
	(
		ProizvodID int identity(1,1) primary key, 
		Sifra nvarchar(25) not null,
		Naziv nvarchar(50) not null, 
		Cijena decimal(10,2) not null, 
		Zaliha int not null	
	)
	/*
- Narudzbe 

 	- NarudzbaID, automatski generator vrijednosti i primarni ključ
 	- KupacID, spoljni ključ prema tabeli Kupci,
	- ProizvodID, spoljni ključ prema tabeli Proizvodi,
	- Kolicina, polje za unos cijelog broja (obavezan unos)
	- Popust, polje za unos decimalnog broj (obavezan unos), DEFAULT JE 0
	*/ 
	create table Narudzbe
	(
		NarudzbaID int identity(1,1) primary key, 
		KupacID int, 
		ProizvodID int ,
		Kolicina int not null, 
		Popust decimal(10,2) default 0
		constraint FK_Narudzbe_Kupac foreign key (KupacID) references Kupci(KupacID), 
		constraint FK_Narudzbe_Proizvodi foreign key (ProizvodID) references Proizvodi(ProizvodID)
	)


	/*

6. Modifikovati tabele Proizvodi i Narudzbe i to sljedeća polja:
	- Zaliha (tabela Proizvodi) - omogućiti unos decimalnog broja
	- Kolicina (tabela Narudzbe) - omogućiti unos decimalnog broja

	*/ 
	alter table Proizvodi 
	alter column Zaliha decimal(10,2) 

	alter table Narudzbe
	alter column Kolicina decimal(10,2)
	/*
7. Koristeći bazu podataka AdventureWorksLT 2012 i tabelu SalesLT.Customer, preko INSERT I SELECT komande importovati 10 zapisa u tabelu Kupci i to sljedeće kolone:
	- FirstName -> Ime
	- LastName -> Prezime
	- Phone -> Telefon
	- EmailAddress -> Email
	- Sve do znaka '@' u koloni EmailAddress -> KorisnickoIme
	- Prvih 8 karaktera iz kolone PasswordHash -> Lozinka
	*/ 
	insert into Kupci (Ime, Prezime, Telefon, Email, KorisnickoIme, Lozinka)
	select top 10  PP.FirstName, PP.LastName, right(PH.PhoneNumber,12), EA.EmailAddress, substring(EA.EmailAddress, 1, charindex('@' , EA.EmailAddress)-1),left(PW.PasswordHash, 8)   from 
	AdventureWorks2014.Sales.Customer as C
	inner join AdventureWorks2014.Person.Person as PP
	on PP.BusinessEntityID=C.PersonID
	inner join AdventureWorks2014.Person.PersonPhone as PH
	on PP.BusinessEntityID=PH.BusinessEntityID
	inner join AdventureWorks2014.Person.EmailAddress as EA
	on PP.BusinessEntityID=EA.BusinessEntityID
	inner join AdventureWorks2014.Person.Password as PW
	on PP.BusinessEntityID=PW.BusinessEntityID
	/* 
8. Koristeći bazu podataka AdventureWorksLT2012 i tabelu SalesLT.Product importovati u temp tabelu po nazivom tempBrojDosijea (npr. temp2046) 5 proizvoda i to sljedeće kolone:
	
	- ProductName -> Sifra
	- Name -> Naziv
	- StandardCost -> Cijena
	*/ 

	select * from AdventureWorks2014.Production.Product
	select top 5  PP.ProductNumber as Sifra, PP.Name as Naziv , PP.StandardCost as Cijena
	into temp12
	from AdventureWorks2014.Production.Product as PP
	where PP.StandardCost>0

	alter table Proizvodi 
	add constraint PR_add_default default 0 for Zaliha
	insert into Proizvodi (Sifra, Naziv, Cijena)
	select Sifra, Naziv, Cijena from temp12

	/* 
9. U vašoj bazi podataka kreirajte stored proceduru koja će raditi INSERT podataka u tabelu Narudzbe. Podaci se moraju unijeti preko parametara. Također , u proceduru dodati ažuriranje (UPDATE) polja 'Zaliha' (tabela Proizvodi) u zavisnosti od prosljeđene količine. Proceduru pohranite pod nazivom usp_Narudzbe_Insert.
*/ 	
create procedure usp_Narudzbe_Insert
(	@KupacID int null, @ProizvodID int null ,
@Kolicina int null, @Popust decimal(10,2)
)
as 
begin 
insert into Narudzbe (KupacID, ProizvodID, Kolicina, Popust)
values (@KupacID, @ProizvodID, @Kolicina , @Popust)

update Proizvodi 
set Zaliha=@Kolicina
where ProizvodID=@ProizvodID
end


drop procedure usp_Narudzbe_Insert
alter table Proizvodi 
add constraint PR_add_default default 0 for Zaliha





/* 
10. Koristeći proceduru koju ste kreirali u prethodnom zadatku kreirati 5 narudžbi.
*/ 
select * from Kupci
select * from Proizvodi
 exec usp_Narudzbe_Insert @KupacID=9 , @ProizvodID=5, @Kolicina=12, @Popust=0
/* 
11. U vašoj bazi podataka kreirajte view koji će sadržavati sljedeća polja: ime kupca, prezime kupca, telefon, šifra proizvoda, naziv proizvoda, cijena, količina, te ukupno. View pohranite pod nazivom view_Kupci_Narudzbe.
*/
create view view_kupci_Narudzbe
as 
select K.Ime, K.Prezime, K.Telefon, P.Sifra, P.Naziv, P.Cijena, N.Kolicina, N.Kolicina*P.Cijena as Ukupno
from Kupci as K
inner join Narudzbe as N
on K.KupacID=N.KupacID 
inner join Proizvodi as P
on P.ProizvodID=N.ProizvodID

/*
12. U vašoj bazi podataka kreirajte stored proceduru koja će na osnovu proslijeđenog imena ili prezimena kupca (jedan parametar) kao rezultat vratiti sve njegove narudžbe. Kao izvor podataka koristite view kreiran u zadatku 8. Proceduru pohranite pod nazivom usp_Kupci_Narudzbe.

13. U vašoj bazi podataka kreirajte stored proceduru koja će raditi DELETE zapisa iz tabele Proizvodi. Proceduru pohranite pod nazivom usp_Proizvodi_Delete. Pokušajte obrisati jedan od proizvoda kojeg ste dodatli u zadatku 5. Modifikujte proceduru tako da obriše proizvod i svu njegovu historiju prodaje (Narudzbe).

*/ 
create procedure usp_Proizvodi_Delete 
( @ProizvodID int ) 
as 
begin
delete Proizvodi
where ProizvodID=@ProizvodID
end

exec usp_Proizvodi_Delete @ProizvodID=5

alter procedure usp_Proizvodi_Delete
(@ProizvodID int null) 
as 
begin 
delete Narudzbe
where ProizvodID=@ProizvodID

delete Proizvodi 
where ProizvodID=@ProizvodID

end 


select * from Narudzbe