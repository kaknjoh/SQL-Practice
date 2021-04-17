/*
ZAMJENSKI ZNAKOVI
% 		- mijenja bilo koji broj znakova
_ 		- mijenja tačno jedan znak


PRETRAŽIVANJE

[ListaZnakova]	-	pretražuje po bilo kojem znaku iz navedene liste pri čemu
					rezultat SADRŽI bilo koji od navedenih znakova
[^ListaZnakova]	-	pretražuje po bilo kojem znaku koji je naveden u listi pri čemu
					rezultat NE SADRŽI bilo koji od navedenih znakova
[A-C]			-	pretražuje po svim znakovima u intervalu između navedenih 
					uključujući i navedene znakove, pri čemu rezultat SADRŽI navedene znakove
[^A-C]			-	pretražuje po svim znakovima u intervalu između navedenih 
					uključujući i navedene znakove, pri čemu rezultat NE SADRŽI navedene znakove
*/



/* 
U bazi Northwind iz tabele Customers prikazati ime kompanije kupca i kontakt telefon i to samo onih koji u svome imenu posjeduju riječ „Restaurant“.
 Ukoliko naziv kompanije sadrži karakter (-), kupce izbaciti iz rezultata upita.*/
use NORTHWND
select * from Customers
select CompanyName, Phone
from Customers
where CompanyName like '%Restaurant%' and CompanyName not like '%-%'


/*
U bazi Northwind iz tabele Products prikazati proizvode čiji naziv počinje slovima „C“ ili „G“, drugo slovo može biti bilo koje,
 a treće slovo u nazivu je „A“ ili „O“. */

 select ProductName
from Products
where ProductName like '[CG]_[AO]%'


/*
U bazi Northwind iz tabele Products prikazati listu proizvoda čiji naziv počinje slovima „L“ ili  „T“ ili je ID proizvoda = 46.
 Lista treba da sadrži samo one proizvode čija se cijena po komadu kreće između 10 i 50. Upit napisati na dva načina.*/

 select * from Products

 select ProductName 
 from Products 
 where (ProductName like '[LT]%' or ProductID=46) and (UnitPrice between 10 and 50)


 /*
U bazi Northwind iz tabele Suppliers prikazati ime isporučitelja, 
državu i fax pri čemu isporučitelji dolaze iz Španije ili Njemačke, a nemaju unešen (nedostaje) broj faksa. Formatirati izlaz polja fax u obliku 'N/A'.*/

select * from Suppliers

select CompanyName, Country, ISNULL(Fax, 'N/A') as fax 
FROM Suppliers
where Country in ('Spain', 'Germany') and fax is null 

/*
Iz tabele Poslodavac dati pregled kolona PoslodavacID i Naziv pri čemu naziv poslodavca počinje slovom B. 
*/

use prihodi

select PoslodavacID, Naziv 
from Poslodavac
where Naziv like '[B]%'

/* 
Iz tabele Poslodavac dati pregled kolona PoslodvacID i Naziv pri čemu naziv poslodavca počinje slovom B, drugo može biti bilo koje slovo, treće je b i ostatak naziva mogu činiti sva slova.
*/

select PoslodavacID, Naziv 
from Poslodavac
where Naziv like '[B]_[b]%'

/*
Iz tabele Država dati pregled kolone Drzava pri čemu naziv države završava slovom a. Rezultat sortirati u rastućem redoslijedu.
*/

select * from Drzava

select Drzava from 
Drzava 
where Drzava like '%a'
order by 1

/*
Iz tabele Osoba dati pregled svih osoba kojima i ime i prezime počinju slovom a. Dati prikaz OsobaID, Prezime i Ime. Rezultat sortirati po prezimenu i imenu u rastućem redoslijedu.
*/

select OsobaID, PrezIme, Ime
from Osoba
where Ime like '[A]%' and PrezIme like '[A]%'
order by 1 

/*
Iz tabele Poslodavac dati pregled svih poslodavaca u čijem nazivu se na kraju ne nalaze slova m i e. Dati prikaz PoslodavcID i Naziv.
*/

SELECT PoslodavacID, Naziv 
from Poslodavac
where Naziv like '%[^me]'


/*
Iz tabele Osoba dati pregled svih osoba kojima se prezime završava suglasnikom. Dati prikaz OsobaID, Prezime i Ime. Rezultat sortirati po prezimenu u opadajućem redoslijedu.
*/
select OsobaID, PrezIme,Ime
from Osoba
where PrezIme like '%[^aeiou]'
order by 2 desc

/*
Iz tabele Osoba dati pregled svih osoba kojima ime počinje bilo kojim od prvih 10 slova engleskog alfabeta. Dati prikaz OsobaID, Prezime i Ime.
 Rezultat sortirati po prezimenu u opadajućem redoslijedu.
*/

select OsobaID, PrezIme, Ime 
from Osoba
where Ime like '[A-J]%'
order by 2 desc

/*
Iz tabele Osoba dati pregled kolona OsobaID, Prezime, Ime i Adresa uz uslov da se prikažu samo oni zapisi koji počinju bilo kojom cifrom u intervalu 1-9.
*/

select OsobaID, PrezIme, Ime, Adresa
from Osoba
where Adresa like '[1-9]%'
order by 2 desc


/*
Iz tabele Osoba dati pregled kolona OsobaID, Prezime, Ime i Adresa uz uslov da se prikažu samo oni zapisi koji ne počinju bilo kojom cifrom u intervalu 1-9.
*/


select OsobaID, PrezIme, Ime, Adresa
from Osoba
where Adresa not like '[1-9]%'
order by 2 desc