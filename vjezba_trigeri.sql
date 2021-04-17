use vjezba_trigeri


select * from AdventureWorks2014.Purchasing.Vendor


/* Kreirati tabele osoba i dobavljac */ 
/* Tabela osoba treba da sadrzi ime i prezime, srednje ime , Modified date kao datum modifikovanja , tabelu dostavljac koja sadrzi broj racuna naziv, credit rejting i modified date */ 



create table dobavljac 
(
 BusinessEntityID int, 
 BrojRacuna nvarchar(55) not null ,
 KreditRejting int not null, 
 ModifiedDate datetime default getdate()
 )

 alter table dobavljac
alter column BusinessEntityID int not null


alter table dobavljac 
add constraint PK_dobavljac primary key (BusinessEntityID)


 create table	Osoba
 (
	BusinessEntityID int primary key, 
	Ime nvarchar(55) not null ,
	Prezime nvarchar(55) not null,
	SrednjeIme nvarchar(55) not null ,
	ModifiedDate datetime default getdate()
) 



create trigger update_modified_date
on Osoba after update
as 
begin 
set nocount on 
update Osoba
set ModifiedDate=getdate()
from Osoba
inner join inserted i 
on i.BusinessEntityID=Osoba.BusinessEntityID
end



create trigger dobavljac_modified_date
on dobavljac after update
as 
begin 
set nocount on 
update dobavljac
set ModifiedDate=getdate()
from dobavljac d
inner join inserted i 
on i.BusinessEntityID=d.BusinessEntityID
end



insert into dobavljac (BusinessEntityID, BrojRacuna, KreditRejting) 
select BusinessEntityID, AccountNumber, CreditRating 
from AdventureWorks2014.Purchasing.Vendor

/* Po trenutnoj postavci tabele Srednje ime kod nas je definisano tako da ne smije biti null sto nema neke logike dakle moramo alterovat tabelu da to promjenimo */ 

alter table Osoba
alter column SrednjeIme nvarchar(55)

insert into Osoba (BusinessEntityID, Ime , Prezime , SrednjeIme) 
select BusinessEntityID, FirstName, LastName,  MiddleName
from AdventureWorks2014.Person.Person


update dobavljac
set BrojRacuna=3 
where BusinessEntityID=1492

select * from dobavljac