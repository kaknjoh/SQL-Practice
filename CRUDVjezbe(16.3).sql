use publikacije



create table autor (

	autor_ID int constraint PK_autor primary key,
	autor_ime nvarchar(15),
	autor_prezime nvarchar(20),
	grad_autora_ID int,
	spol char(1)

)



drop table autor_1

create table autor (

	autor_ID int not null,
	autor_ime nvarchar(15),
	autor_prezime nvarchar(20),
	grad_autora_ID int,
	spol char(1),
	constraint PK_autor primary key(autor_ID),
	constraint FK_autor_grad foreign key(grad_autora_ID) references grad(grad_ID)

)


/*
b) citalac
	-	citalac_ID		cjelobrojna vrijednost	primarni kljuè
	-	citalac_ime		15 unicode karaktera	
	-	citalac_prezime	20 unicode karaktera	
	-	grad_citaoca_ID	cjelobrojna vrijednost	
	-	spol			1 karakter
	
	
*/
use publikacije
create table citalac(
	citalac_ID int not null,
	citalac_ime nvarchar(15),
	citalac_prezime nvarchar(20),
	grad_citaoca_ID int,
	spol char(1),
	constraint PK_citaoc primary key(citalac_ID),
	constraint FK_citalac_grad foreign key(grad_citaoca_ID) references grad(grad_ID)
	)
	

 create table grad (
	grad_ID int,
	naziv_grada nvarchar(15),
	constraint PK_grad primary key(grad_ID)

)
/*
c) forma_publikacije
	-	forma_pub_ID	cjelobrojna vrijednost	primarni kljuè
	-	forma_pub_naziv	15 unicode karaktera
	-	max_duz_zadrz	cjelobrojna vrijednost */

create table forma_publikacije(
	forma_pub_ID int, 
	forma_pub_naziv nvarchar(15),
	max_duz_zadrz int,
	constraint PK_forme_pub primary key(forma_pub_ID)
	)


/* 
f) izdavac
	-	izdavac_ID			cjelobrojna vrijednost	primarni kljuè
	-	grad_izdavaca_ID	cjelobrojna vrijednost
	-	naziv_izdavaca		15 unicode karaktera
*/

create table izdavac(
	izdavac_ID int not null,
	grad_izdavaca_ID int,
	naziv_izdavaca nvarchar(15),
	constraint PK_izdavaca primary key(izdavac_ID),
	constraint FK_izdavac_grad foreign key(grad_izdavaca_ID) references grad(grad_ID)

)
/*
i) zanr
	-	zanr_ID			cjelobrojna vrijednost		primarni kljuè
	-	zanr_naziv		15 unicode karaktera
*/

create table zanr(
	zanr_ID int not null,
	zanr_naziv nvarchar(15),
	constraint PK_zanr primary key (zanr_ID)
)


/*
h) publikacija
	-	pub_ID			cjelobrojna vrijednost		primarni kljuè
	-	naziv_pub		15 unicode karaktera	
	-	vrsta_pub_ID	cjelobrojna vrijednost	
	-	izdavac_ID		cjelobrojna vrijednost	
	-	zanr_ID			cjelobrojna vrijednost	
	-	cijena			decimalna vrijednost oblika 5 - 2	
	-	ISBN			13 unicode karaktera
	
	*/
	
create table publikacije(
	pub_ID int not null,
	naziv_pub nvarchar(15),
	vrsta_pub_ID int,
	izdavac_ID int ,
	zanr_ID int,
	cijena decimal(5,2),
	ISBN nvarchar(15),
	constraint PK_publikacije primary key(pub_ID),
	constraint FK_publikacije_izdavac foreign key(izdavac_ID) references izdavac(izdavac_ID),
	constraint FK_publikacije_zanr foreign key(zanr_ID) references zanr(zanr_ID),
	constraint FK_publikacije_forma_publikacije foreign key(vrsta_pub_ID) references forma_publikacije(forma_pub_ID)
	)



/*
g) autor_pub
	-	pub_ID			cjelobrojna vrijednost		primarni kljuè
	-	autor_ID		cjelobrojna vrijednost		primarni kljuè

*/

create table autor_pub(
	pub_ID int FOREIGN KEY REFERENCES publikacije(pub_ID),
	autor_ID int FOREIGN KEY REFERENCES autor(autor_ID),
	constraint PK_autor_pub primary key(pub_ID,autor_ID)
)

create table autor_pub(
	pub_ID int ,
	autor_ID int,
	constraint FK_autor_pub_publikacije FOREIGN KEY (pub_ID) REFERENCES publikacije(pub_ID),
	constraint FK_autor_pub_autor FOREIGN KEY (autor_ID) REFERENCES autor(autor_ID),

	constraint PK_autor_pub primary key(pub_ID,autor_ID)
)

/*
e) iznajmljivanje
	-	pub_ID			cjelobrojna vrijednost	primarni kljuè
	-	citalac_ID		15 unicode karaktera	primarni kljuè
	-	dtm_podizanja	datumska vrijednost		primarni kljuè
	-	dtm_vracanja	datumska vrijednost
	-	br_dana_zadr	cjelobrojna vrijednost

	*/

create table iznajmljivanje(
	pub_ID int,
	citalac_ID int,
	dtm_podizanja datetime,
	dtm_vracanja datetime,
	br_dana_zadr int,
	CONSTRAINT FK_iznajmljivanje_publikacije FOREIGN KEY(pub_ID) REFERENCES publikacije(pub_ID),
	CONSTRAINT FK_iznajmljivanje_citalac FOREIGN KEY(citalac_ID) REFERENCES citalac(citalac_ID),
	CONSTRAINT PK_iznajmljivanje primary key(pub_ID, citalac_ID, dtm_podizanja)
	)

drop table grad