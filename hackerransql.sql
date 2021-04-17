create database hackerrank_vjezba

use hackerrank_vjezba

create table Hackers 
(
	hacker_id int constraint PK_Hackers primary key, 
	name nvarchar(55)
)

create table Submissions(
submissions_id int constraint PK_Submissions primary key, 
hacker_id int, 
challenge_id int, 
score int, 
constraint FK_Submissions_Hackers foreign key (hacker_id) references Hackers(hacker_id)
)

insert into Hackers values

(


'36071', 'Frank'), (
'49438', 'Patrick'),( 
'74842', 'Lisa'),(
'80305', 'Kimberly'),( 
'84072', 'Bonnie'),(
'87868' , 'Michael'),( 
'92118', 'Todd'),(
'95895', 'Joe')
select * from Hackers

insert into Submissions values 

(40742, 26071,49593,20),
(17513,4806,49593,32),
(68846,80305,19797,19),
(41002,26071,89343,36),
(52826, 49438, 49593, 9),
(31093,26071,19797,2),
(81614,84072,49593,100),
(44829,26071,89343,17),
(75147,80305,49593,48),
(14115, 4806,49593,76),
(6943, 4071, 19797, 95),
(12855,4806,25917,13),
(73343,80305,49593,42),
(84264,84072,63132,0),
(9951,4071,49593,43),
(45104,49438,25917,34),
(53795,74842, 19797,5),
(26363, 26071, 19797, 29),
(10063, 4071, 49593, 96)


create table Difficulty (
difficulty_level int constraint PK_Difficulty primary key,
score int)

insert into Difficulty values (1,20),
(2,30),
(3,40),(4,60),(5,80),(6,100),(7,120)

insert into Challenges values 
(4810,92118,4),
(36566,74842,7),
(66730,49438,6),
(71055,49438,2),
(21089,84072,1),



use NORTHWND

select * from Products

select SupplierID
create table Challenges(
challenge_id int constraint PK_Challenge primary key, 
hacker_id int, 
difficulty_level int,
constraint FK_Challenges_Hackers foreign key (hacker_id) references Hackers(hacker_id),
constraint FK_Challenges_Difficulty foreign key(difficulty_level) references Difficulty(difficulty_level)
)

ALTER TABLE Submissions
ADD CONSTRAINT FK_sub_challe
FOREIGN KEY (challenge_id) REFERENCES Challenges(challenge_id)


/* Iz tabela Hackers i Submission dati listu svih hackera i sumu bodova na nacin da se uzima najveci broj bodova po jednom rijesenom celendu */ 
select h.hacker_id, h.name, sum(score)
from Hackers as h
inner join 
(select hacker_id , max(score) as score
from Submissions
group by challenge_id, hacker_id) max_score 
on h.hacker_id=max_score.hacker_id
group by h.hacker_id, h.name
having sum(score) >0 
order by 3 desc


select score, count(score)
from Submissions
group by score




/* Write a query to output the names of those students whose best friends got offered a higher salary than them. 
Names must be ordered by the salary amount offered to the best friends. It is guaranteed that no two students got same salary offer. 
https://www.hackerrank.com/challenges/placements/problem Link */



create table Students (
ID int primary key ,
Name nvarchar(55))


create table Friends(
ID int primary key, 
Friend_ID int ,
constraint FK_Friends_Students foreign key (Friend_ID) references Students(ID))


create table Packages(
ID int primary key, 
Salary nvarchar(55), 
constraint FK_Packages_Students foreign key (ID) references Students(ID))




insert into Students values(
1, 'Ashley'),
(2, 'Samantha'),
(3,'Julia'),
(4,'Scarlet')

insert into Friends values (
1, 2),
(2,3),
(3,4),
(4,1)



insert into Packages values 
(1, '15.20'),
(2,'10.06'),
(3,'11.55'),
(4,'12.12')


alter table Packages 
alter column Salary float






select *
from(
    select Name , Sa.Salary as Sal , T.Salary from Students as  S
    inner join Friends as F
    on S.ID=F.ID
    inner join Packages as Sa
    on F.Friend_ID=Sa.ID
    inner join Packages as T
    on S.ID=T.ID
    where Sa.Salary>T.Salary
    
) as w
order by w.Sal

