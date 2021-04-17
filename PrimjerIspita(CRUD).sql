/*
1. Kreirati bazu podataka radna.
*/
create database radna
use radna

/*2. Vodeći računa o strukturi tabela kreirati odgovarajuće veze (vanjske ključeve) 

a) Kreirati tabelu autor koja će se sastojati od sljedećih polja:
	au_id		varchar(11)	primarni ključ
	au_lname	varchar(40)	
	au_fname	varchar(20)	
	phone		char(15)	
	address		varchar(40)	obavezan unos
	city		varchar(20)	obavezan unos
	state		char(2)	obavezan unos
	zip			char(5)	obavezan unos
	contract	bit	
*/
create table autor (
	au_id varchar(11) PRIMARY KEY, 
	au_lname varchar(40),
	au_fname varchar(20),
	phone char(15),
	adress varchar (40) , 
	city varchar(20), 
	state char(2),
	zip char(5),
	contact bit );

	
/*
b) Kreirati tabelu naslov koja će se sastojati od sljedećih polja:
	title_id	varchar(6), primarni ključ
	title		varchar(80)	
	type		char(12)	
	pub_id		char(4)	obavezan unos
	price		money	obavezan unos
	advance		money	obavezan unos
	royalty		int	obavezan unos
	ytd_sales	int	obavezan unos
	notes		varchar(200)	obavezan unos
	pubdate		datetime	
		
*/
create table naslov (
	title_id varchar(6) PRIMARY KEY, 
	title		varchar(80)	,
	type		char(12),
	pub_id		char(4) ,
	price		money , 
	advance		money,
	royalty		int ,
	ytd_sales	int,
	notes		varchar(200),
	pubdate datetime );

/*
c) Kreirati tabelu naslov_autor koja će se sastojati od sljedećih polja:
	au_id		varchar(11)	
	title_id	varchar(6)	
	au_ord		tinyint	obavezan unos
	royaltyper	int	obavezan unos
*/
create table naslov_autora(
au_id varchar(11),
title_id varchar(6),
au_ord tinyint not null,
royaltyper int not null, 
CONSTRAINT PK_naslov_autor PRIMARY KEY(au_id,title_id,au_ord),
CONSTRAINT FK_naslov_autor__autor FOREIGN KEY(au_id) REFERENCES autor(au_id),
CONSTRAINT FK_naslov_autor__naslov FOREIGN KEY(title_id) REFERENCES naslov(title_id),
);



/*
3. Insert (import) podataka.
	a) u tabelu autori podatke iz tabele authors baze pubs, ali tako da se u koloni phone tabele autor prve 3 cifre smjeste u zagradu.
	b) u tabelu naslovi podatke iz tabele titles baze pubs, ali tako da se izvrši zaokruživanje vrijednosti (podaci ne smiju imati decimalne vrijednosti) u koloni price
	c) u tabelu naslov_autor podatke iz tabele titleauthor baze pubs, pri čemu će se u koloni au_ord vrijednosti iz tabele titleauthor zamijeniti na sljedeći način:
	1 -> 101
	2 -> 102
	3 -> 103
*/
insert into autor
select au_id,au_lname,au_fname,'('+ left(phone,3)+')'
+ SUBSTRING(phone,5,9),address,city,state,zip,contract 
from pubs.dbo.authors

select SUBSTRING(phone,5,8)
from pubs.dbo.authors


/*
4. Izvršiti update podataka u koloni contract tabele autor po sljedećem pravilu:
	0 -> ostaviti prazno
	1 -> DA
*/

/*
5. Kopirati tabelu sales iz baze pubs u tabelu prodaja u bazi radna.
*/

/*
6. Kopirati tabelu autor u tabelu autor1, izbrisati sve podatke, a nakon toga u tabelu autor1 importovati podatke iz tabele autor uz uslov da ID autora započinje brojevima 1, 2 ili 3 i da autor ima zaključen ugovor (contract).
*/

/* 
7. U tabelu autor1 importovati podatke iz tabele autor uz uslov da adresa počinje cifrom 3, a na trećem mjestu se nalazi cifra 1.
*/


/*
8. Kopirati tabelu naslov u tabelu naslov1, izbrisati sve podatke, a nakon toga u tabelu naslov1 importovati podatke iz tabele naslov na način da se cijena (price) koriguje na sljedeći način:
	- naslov čija je cijena veća ili jednaka 15 KM cijenu smanjiti za 20% (podaci trebaju biti zaokruženi na 2 decimale)
	- naslov čija je cijena manja od 15 KM cijenu smanjiti za 15% (podaci trebaju biti zaokruženi na 2 decimale)
*/


/*
9. Kopirati tabelu naslov_autor u tabelu naslov_autor1, a nakon toga u tabelu naslov_autor1 dodati novu kolonu isbn.
*/


/*
10. Kolonu isbn popuniti na način da se iz au_id preuzmu prve 3 cifre i srednja crta, te se na to dodaju posljednje 4 cifre iz title_id.
*/

/*
11. U tabelu autor1 dodati kolonu sifra koja će se popunjavati slučajno generisanim nizom znakova, pri čemu je broj znakova ograničen na 15.
*/


/*
12. Tabelu Order Details iz baze Northwind kopirati u tabelu detalji_narudzbe.
*/

/*
13. U tabelu detalji_narudzbe dodati izračunate kolone cijena_s_popustom i ukupno. cijena_s_popustom će se računati pomoću kolona UnitPrice i Discount, a ukupno pomoću kolona Quantity i cijena_s_popustom. Obje kolone trebaju biti formirani kao numerički tipovi sa dva decimalna mjesta.
*/

/*
14. U tabelu detalji_narudzbe izvršiti insert podataka iz tabele Order Details baze Northwind.
*/


/*
15. Kreirati tabelu uposlenik koja će se sastojati od sljedećih polja:
	uposlenikID	cjelobrojna vrijednost, primarni ključ, automatsko punjenje sa inkrementom 1 i početnom vrijednošću 1
	emp_id		char(9)	
	fname		varchar(20)	
	minit		char(1)	
	lname		varchar(30)	
	job_id		smallint	
	job_lvl		tinyint	
	pub_id		char(4)	
	hire_date	datetime, defaultna vrijednost je aktivni datum	
*/

/*
16. U sve kolone tabele uposlenik osim hire_date insertovati podatke iz tabele employee baze pubs.
*/


/*
17. U tabelu uposlenik dodati kolonu sifra veličine 10 unicode karaktera, a nakon toga kolonu sifra popuniti slučajno generisanim karakterima, uz uslov d
*/