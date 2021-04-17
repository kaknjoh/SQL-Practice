/*
Napomena:
1. Prilikom bodovanja rješenja prioritet ima razultat koji treba upit da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, 
tada se rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, jer ni ta rješenja ne mogu vratiti tačan rezultat 
(broj zapisa, vrijednosti agregatnih funkcija...).
2. Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. 
Prilikom pregleda rada pokreće se kod koji se nalazi u sql skripti i sve ono što nije urađeno prema zahtjevima zadatka ili je pogrešno urađeno predstavlja grešku. 
Shodno navedenom na uvidu se ne prihvata prigovor da je neki dio koda posljedica previda ("nisam vidio", "slučajno sam to napisao"...) 
*/


/*
1.
a) Kreirati bazu pod vlastitim brojem indeksa.
*/
create database "2"
use "2"

/* 
b) Kreiranje tabela.
Prilikom kreiranja tabela voditi računa o odnosima između tabela.
I. Kreirati tabelu narudzba sljedeće strukture:
	narudzbaID, cjelobrojna varijabla, primarni ključ
	dtm_narudzbe, datumska varijabla za unos samo datuma
	dtm_isporuke, datumska varijabla za unos samo datuma
	prevoz, novčana varijabla
	klijentID, 5 unicode karaktera
	klijent_naziv, 40 unicode karaktera
	prevoznik_naziv, 40 unicode karaktera
*/
select * from narudzba
create table narudzba (
narudzbaID int primary key, 
dtm_narudzbe date,
dtm_isporuke date,
prevoz money, 
klijentID nvarchar(5), 
klijent_naziv nvarchar(40), 
prevoznik_naziv nvarchar(40)
) 
/*
II. Kreirati tabelu proizvod sljedeće strukture:
	- proizvodID, cjelobrojna varijabla, primarni ključ
	- mj_jedinica, 20 unicode karaktera
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_web, tekstualna varijabla
*/
create table proizvod 
(
proizvodID int primary key, 
mj_jedinica nvarchar(20), 
jed_cijena money,
kateg_naziv nvarchar(15), 
dobavljac_naziv nvarchar(40), 
dobavljac_web text ) 

/*
III. Kreirati tabelu narudzba_proizvod sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- proizvodID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla
*/


create table narudzba_proizvod
(
narudzbaID int not null, 
proizvodID int not null, 
uk_cijena money, 
constraint PK_narudzba_proizvod primary key(narudzbaID, proizvodID),
constraint FK_narudzba_proizvod_proizvod foreign key (proizvodID) references proizvod(proizvodID), 
constraint FK_narudzba_proizvod_narudzba foreign key (narudzbaID) references narudzba(narudzbaID)
) 

-------------------------------------------------------------------
/*
2. Import podataka
a) Iz tabela Customers, Orders i Shipers baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- Freight -> prevoz
	- CustomerID -> klijentID
	- CompanyName -> klijent_naziv
	- CompanyName -> prevoznik_naziv
*/
insert into narudzba (narudzbaID, dtm_narudzbe, dtm_isporuke, prevoz, klijentID, klijent_naziv, prevoznik_naziv)
select O.OrderID, O.OrderDate, O.ShippedDate, O.Freight, C.CustomerID, C.CompanyName, S.CompanyName
from NORTHWND.dbo.Orders as O
inner join NORTHWND.dbo.Customers as C
on O.CustomerID=C.CustomerID
inner join NORTHWND.dbo.Shippers as S
on S.ShipperID=O.ShipVia


/*
b) Iz tabela Categories, Product i Suppliers baze Northwind importovati podatke prema pravilu:
	- ProductID -> proizvodID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- HomePage -> dobavljac_web
*/
select * from NORTHWND.dbo.Products

insert into proizvod (proizvodID, mj_jedinica, jed_cijena, kateg_naziv, dobavljac_naziv, dobavljac_web) 
select P.ProductID, P.QuantityPerUnit, P.UnitPrice, C.CategoryName, S.CompanyName, S.HomePage from NORTHWND.dbo.Categories AS C
inner join NORTHWND.dbo.Products as P
on P.CategoryID=C.CategoryID
inner join NORTHWND.dbo.Suppliers as S
on S.SupplierID=P.SupplierID
/*
c) Iz tabele Order Details baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> proizvodID
	- uk_cijena <- proizvod jedinične cijene i količine
uz uslov da nije odobren popust na proizvod.
*/

insert into narudzba_proizvod (narudzbaID, proizvodID, uk_cijena)
select OrderID, ProductID, (UnitPrice*Quantity)
from NORTHWND.dbo.[Order Details]
where Discount=0
--10 bodova


-------------------------------------------------------------------
/*

3. 
Koristeći tabele proizvod i narudzba_proizvod kreirati pogled view_kolicina koji će imati strukturu:
	- proizvodID
	- kateg_naziv
	- jed_cijena
	- uk_cijena
	- kolicina - količnik ukupne i jedinične cijene
U pogledu trebaju biti samo oni zapisi kod kojih količina ima smisao (nije moguće da je na stanju 1,23 proizvoda).
Obavezno pregledati sadržaj pogleda.
*/
select * from proizvod
select * from narudzba_proizvod
create view view_kolicina
as
select p.proizvodID, p.kateg_naziv, p.jed_cijena, np.uk_cijena, np.uk_cijena/p.jed_cijena as kolicina 
from proizvod as p 
inner join narudzba_proizvod as np 
on p.proizvodID=np.proizvodID
where  floor(np.uk_cijena/p.jed_cijena)=np.uk_cijena/p.jed_cijena

drop view view_kolicina

select * from view_kolicina



--7 bodova


-------------------------------------------------------------------
/*
4. 
Koristeći pogled kreiran u 3. zadatku kreirati proceduru tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti). Proceduru pokrenuti za sljedeće nazive kategorija:
1. Produce
2. Beverages
*/


--8 bodova
create procedure proc_kolicina 
( 
@proizvodID int=null, 
@kateg_naziv nvarchar(50)=null, 
@jed_cijena money = null, 
@uk_cijena money =null, 
@kolicina money =null
) 
as 
begin 
select * from 
view_kolicina
where 
proizvodID=@proizvodID or kateg_naziv=@kateg_naziv or jed_cijena=@jed_cijena or uk_cijena=@uk_cijena or kolicina= @kolicina

end

exec proc_kolicina @kateg_naziv='Beverages'


------------------------------------------------
/*
5.
Koristeći pogled kreiran u 3. zadatku kreirati proceduru proc_br_kat_naziv koja će vršiti prebrojavanja po nazivu kategorije. 
Nakon kreiranja pokrenuti proceduru.
*/

create procedure proc_br_kat_naziv 
as
begin 
select kateg_naziv, count(*) as prebrojano 
from view_kolicina 
group by kateg_naziv
end

exec proc_br_kat_naziv


-------------------------------------------------------------------
/*
6.
a) Iz tabele narudzba_proizvod kreirati pogled view_suma sljedeće strukture:
	- narudzbaID
	- suma - sume ukupne cijene po ID narudžbe
Obavezno napisati naredbu za pregled sadržaja pogleda.
b) Napisati naredbu kojom će se prikazati srednja vrijednost sume zaokružena na dvije decimale.
c) Iz pogleda kreiranog pod a) dati pregled zapisa čija je suma veća od prosječne sume. Osim kolona iz pogleda, 
potrebno je prikazati razliku sume i srednje vrijednosti. 
Razliku zaokružiti na dvije decimale.
*/

--15 bodova

create view view_suma
as
select narudzbaID, sum(uk_cijena) as suma
from narudzba_proizvod
group by narudzbaID

select * from view_suma

select round(avg(suma),2) from view_suma


select * ,round( suma- (select avg(suma) from view_suma),2) from 
view_suma
where suma > ( select avg(suma) from view_suma)

-------------------------------------------------------------------
/*
7.
a) U tabeli narudzba dodati kolonu evid_br, 30 unicode karaktera 
b) Kreirati proceduru kojom će se izvršiti punjenje kolone evid_br na sljedeći način:
	- ako u datumu isporuke nije unijeta vrijednost, evid_br se dobija generisanjem slučajnog niza znakova
	- ako je u datumu isporuke unijeta vrijednost, evid_br se dobija spajanjem datum narudžbe i datuma isprouke uz umetanje donje crte između datuma
Nakon kreiranja pokrenuti proceduru.
Obavezno provjeriti sadržaj tabele narudžba.
*/


--15 bodova
alter table narudzba 
add evid_br nvarchar(30)

create procedure popuni 
as 
begin 
update narudzba 
set evid_br =left(newid(),30) 
where dtm_isporuke is  null 

update narudzba 
set evid_br= convert(nvarchar, dtm_narudzbe)+'_'+convert(nvarchar, dtm_isporuke)
where dtm_isporuke is not null 

end 

exec popuni 


-------------------------------------------------------------------
/*
8. Kreirati proceduru kojom će se dobiti pregled sljedećih kolona:
	- narudzbaID,
	- klijent_naziv,
	- proizvodID,
	- kateg_naziv,
	- dobavljac_naziv
Uslov je da se dohvate samo oni zapisi u kojima naziv kategorije sadrži samo 1 riječ.
Pokrenuti proceduru.
*/

--10 bodova
select * from narudzba
select * from proizvod

select charindex(' ', kateg_naziv) from proizvod
create procedure pregled
as
begin 
select n.narudzbaID, n.klijent_naziv, p.proizvodID, p.kateg_naziv, p.dobavljac_naziv from 
narudzba_proizvod as np 
inner join proizvod as p
on np.proizvodID=p.proizvodID
inner join narudzba as n 
on n.narudzbaID=np.narudzbaID
where charindex(' ', kateg_naziv)=0
end 

exec pregled



-------------------------------------------------------------------
/*
9.
U tabeli proizvod izvršiti update kolone dobavljac_web tako da se iz kolone dobavljac_naziv uzme prva riječ, 
a zatim se formira web adresa u formi www.prva_rijec.com. 
Update izvršiti pomoću dva upita, vodeći računa o broju riječi u nazivu. 
*/

select dobavljac_naziv,  substring(dobavljac_naziv, 0, charindex(' ', dobavljac_naziv) )  from proizvod
update proizvod 
set dobavljac_web='www.'+substring(dobavljac_naziv, 0, charindex(' ', dobavljac_naziv) ) +'.com'
where charindex(' ', dobavljac_naziv) =0


-------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. Pokrenuti proceduru.
*/

backup database "2" 
to disk ='2.bak'


create procedure brisi 
as
begin 

drop view view_kolicina
drop view view_suma
drop procedure popuni
drop procedure pregled
drop procedure proc_br_kat_naziv
drop procedure proc_kolicina
end 


exec brisi	