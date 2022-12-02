#Create schema G2T6
create schema G2T6;

#Use G2T6
use G2T6;

#Create table
create table officer
(officerID int primary key not null,
name varchar(50),
yearsemp int);

create table driver
(
DID int primary key not null,
NRIC char(9),
Name varchar(50),
DoB date,
Gender char(1)
);


create table service
(sid int not null primary key,
 normal boolean);
 
 

create table stop
(stopid int not null primary key,
locationdes varchar(50),
address varchar(50));

create table bus
(plateno char(8) not null primary key,
 fueltype varchar(10),
 capacity int);

create table normal
(sid int not null,
weekdayfreq int,
weekendfreq int,
constraint normal_pk primary key(sid),
constraint normal_fk foreign key(sid) references service(sid));

create table express
(sid int not null,
availableweekend boolean,
availableph boolean,
constraint express_pk primary key(sid),
constraint express_fk foreign key(sid) references service(sid));

create table company
(sid int not null,
company varchar(20),
constraint company_pk primary key(sid,company),
constraint company_fk foreign key(sid) references service(sid));

create table bustrip
(sid int not null,
TDate date not null,
starttime time not null,
endtime time,
plateno char(8),
did int,
constraint bustrip_pk primary key(sid,Tdate,starttime),
constraint bustrip_fk1 foreign key(sid) references service(sid),
constraint bustrip_fk2 foreign key(plateno) references bus(plateno),
constraint bustrip_fk3 foreign key(did) references driver(did));

create table cardtype
(type varchar(10) not null primary key,
discount float,
mintopamount int,
description varchar(200));

create table citylink
(cardid int not null ,
balance float,
expire date ,
type varchar(10),
oldcardid int,
constraint citylink_pk primary key(cardid),
constraint citylink_fk1 foreign key(type) references cardtype(type),
constraint citylink_fk2 foreign key(oldcardid) references citylink(cardid));


create table offence
(id int primary key not null,
NRIC char(9) ,
time time ,
penalty float ,
paycard int,
sid int,
sdate date,
stime time,
oid int,
constraint offence_fk1 foreign key(paycard) references citylink(cardid),
constraint offence_fk2 foreign key(sid,sdate,stime) references bustrip(sid,tdate,starttime),
constraint offence_fk3 foreign key(oid) references officer(officerid));


create table stoprank
(stopid int not null,
sid int not null,
rankorder int,
constraint stoprank_pk primary key(stopid,sid),
constraint stoprank_fk1 foreign key(stopid) references stop(stopid),
constraint stoprank_fk2 foreign key(sid) references service(sid));

create table ride
(cardid int not null,
rdate date not null ,
usephone boolean,
boardstop int,
sid int,
alightstop int,
boardtime time not null,
alighttime time,
constraint ride_pk primary key(cardid,rdate,boardtime),
constraint ride_fk1 foreign key(cardid) references citylink(cardid),
constraint ride_fk2 foreign key(boardstop,sid) references stoprank(stopid,sid),
constraint ride_fk3 foreign key(alightstop) references stop(stopid));


create table stoppair
(fromstop int not null,
tostop int not null,
basefee float,
constraint stoppair_pk primary key(fromstop,tostop),
constraint stoppair_fk1 foreign key(fromstop) references stop(stopid),
constraint stoppair_fk2 foreign key(tostop) references stop(stopid));





#Data import
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/service.txt' INTO
TABLE service FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/bus.txt' INTO
TABLE bus FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/officer.txt' INTO
TABLE officer FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/driver.txt' INTO
TABLE driver FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/stop.txt' INTO
TABLE stop FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/cardtype.txt' INTO
TABLE cardtype FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/normal.txt' INTO
TABLE normal FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/express.txt' INTO
TABLE express FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/company.txt' INTO
TABLE company FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/bustrip.txt' INTO
TABLE bustrip FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/citylink.txt' INTO
TABLE citylink FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/offence.txt' INTO
TABLE offence FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/stoprank.txt' INTO
TABLE stoprank FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/ride.txt' INTO
TABLE ride FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/G2T6/data/stoppair.txt' INTO
TABLE stoppair FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;










