#Question 1:
set @m1=8 ;
set @m2= 10;
set @Y=2019 ;
set @plateNo='SHA8254Z' ; 

select plateno AS 'Bus Plate', 
		extract(month from tdate) as Month, 
        count(DISTINCT sid) as 'Total number of unique services',
		count(*) as 'Total number of trips',
		count(distinct did) as 'Total number of drivers' 
        from bustrip 
where plateno=@plateno
	and extract(year from tdate) = @Y
	and extract(month from tdate) <=@m2 
	and extract(month from tdate) >=@m1
group by extract(month from tdate);


#Question 2:
set @d_string='PARK';

select s.stopid as 'Stop ID', locationdes AS 'Location', Address , st.sid as 'SID',
if (Normal = 0, 'Express', 'Normal') as Type, 
ifnull(weekdayfreq,"NULL") as 'Weekday Freq', ifnull(weekendfreq,"NULL") as 'Weekend Freq'
from stop s left join stoprank st on s.stopid=st.stopid join service sr on sr.sid = st.sid 
left join normal n on n.sid = sr.sid
WHERE locationdes like concat("%",@d_string,"%") OR address like concat("%",@d_string,"%");


#Question 3:
SELECT
	ReplacedCardId as "Replaced Card",
	expire as "expiry",
	NumberofRides as "Number of rides",
	X.oldcardid as "Old card",
	Y.OldNumberRides as "Number of Rides of Old card"
FROM
	(
	SELECT
		ReplacedCardId,
		expire,
		COUNT(cardid) AS NumberofRides,
		oldcardid 
	FROM
		( SELECT citylink.cardid AS ReplacedCardId, citylink.expire, oldcardid FROM citylink WHERE citylink.oldcardid IS NOT NULL ) T
		LEFT JOIN ride ON T.ReplacedCardId = ride.cardid 
	GROUP BY
		ReplacedCardId,expire,oldcardid 
	) X
	LEFT JOIN (
	SELECT
		oldcardid,
		COUNT(cardid) AS OldNumberRides 
	FROM
		( SELECT oldcardid FROM citylink WHERE citylink.oldcardid IS NOT NULL ) TT
		LEFT JOIN ride ON TT.oldcardid = ride.cardid 
	GROUP BY
		oldcardid 
	) Y ON X.oldcardid = Y.oldcardid order by expire desc; 
 
 
#Question 4:
delimiter $$
create procedure findXthPopularStop (IN startdate date, IN enddate date, in X int)
BEGIN

SELECT stop as 'Stop ID' from( select * ,
 CASE 
 WHEN @totalnumber = temp_final.totalnumber THEN @rank
 WHEN @totalnumber := temp_final.totalnumber THEN @rank := @rank +1
 END as 'rank'
 from(select @rank:=0)a,(
 select sum(totalnumber)as 'totalnumber'  ,stop
 from (
  select count(*) as totalnumber, boardstop as stop from ride
  where rdate between startdate and enddate
  group by boardstop
  
        union all
  
        select count(*) as totalnumber, new_alightstop as stop
        from(
   SELECT *,IFNULL(alightstop,laststop) as 'new_alightstop'
   FROM ride r
   JOIN ( select * from(
        
                  select s1.sid as 'stopranksid', s2.stopid as 'laststop', s2.rankorder as "maxrank"
 from(select sid, max(RankOrder)as maxrank from stoprank
 group by sid) as s1
join stoprank s2 on s1.maxrank=s2.rankorder and s1.sid=s2.sid
        ) as temp_finalstop 
   ) AS temp5 ON r.sid = temp5.stopranksid
   where rdate between startdate and enddate
        )as temp6
        where rdate between startdate and enddate
        group by alightstop
    ) as temp
 group by temp.stop
    order by totalnumber desc)  as temp_final ) as temp_final2
    where temp_final2.rank=x;
END$$
delimiter ;
call findXthPopularStop('2019-01-04','2020-10-30',5);


#Question 5：
set @sdate = '2020-01-09';
set @edate = '2021-05-05';
set @cid = 39;

select rdate as 'Ride date', sid as 'SID', boardstop as 'Board Stop',
temp2.locationdes as 'Board Location', alightstop as 'Alight Stop',
temp3.locationdes as 'Alight Location', basefee*(1-discount) as 'Fare Paid'
from(
 select cardid, rdate, r.sid, boardstop, alightstop, ifnull(alightstop, a.stopid) as "newAlightStop"  from ride r
 join (select s1.sid, s2.stopid, s2.rankorder as "maxrank"
   from(select sid, max(RankOrder)as maxrank from stoprank
   group by sid) as s1
 join stoprank s2 on s1.maxrank=s2.rankorder and s1.sid=s2.sid) a 
    on r.sid = a.sid
    ) temp1
left join stoppair s_p on temp1.BoardStop=s_p.fromstop and temp1.newalightStop=s_p.tostop
left join (SELECT StopID,LocationDes FROM stop) temp2 on temp1.BoardStop = temp2.StopID
left join (SELECT StopID,LocationDes FROM stop) temp3 on temp1.AlightStop = temp3.StopID
left join (select cardid, discount from citylink c 
   join cardtype t on c.type = t.type) temp4 on temp4.cardid = temp1.cardid
where temp1.cardid = @cid and rdate >= @sdate and rdate <= @edate;

#Question 6:
set @StartDate='2018-01-01' ;
set @EndDate= '2021-12-31';
set @sid= 167;

select sid as 'SID',
(select count(cardid) from ride where sid = @sid and rdate between @startdate and @enddate) 
as 'Number of Passengers ferried',
(Select count(stopid) from stoprank where  sid = @sid )as 'Total number of stops', 
COUNT(DISTINCT stopcount) as 'Total number of unique stops (board or alight)'
from  ((select sid, boardstop as stopcount from ride where sid = @sid 
and rdate between @startdate and @enddate)
 UNION ALL
 (select sid, alightstop as stopcount from ride 
 where sid = @sid and rdate between @startdate and @enddate))as stopcount;
 
    
#Question 7: 
SET @X = 5;
SELECT
 T1.officerID as 'Officer ID',
 T1.NAME as 'Name',
 T1.yearsemp as "Years employed",
 ifnull(T2.NumberofOffences,0) as "Number of Offences",
 ifnull(T2.NumberofOffencesPaidUsingCard,0) as "Number of offences paid using Card",
 ifnull(T2.penaltyAmountCollected,0) as "Penalty amount collected",
 ifnull(T3.uniqueBusTrip,0) as "Number of unique bus trips" 
FROM
 ( SELECT officerID, NAME, yearsemp FROM officer WHERE yearsemp >= @X ) T1
 LEFT JOIN (
 SELECT
  oid,
  COUNT( id ) AS NumberofOffences,
  COUNT( paycard ) AS NumberofOffencesPaidUsingCard,
  sum( penalty ) AS penaltyAmountCollected 
 FROM
  offence 
 GROUP BY
  oid 
 ) T2 ON T1.officerID = T2.oid
 LEFT JOIN (
 SELECT
  c.oid,
  COUNT( DISTINCT c.uniqueBusTripInfo ) AS uniqueBusTrip 
 FROM
  (
  SELECT
   oid,
   uniqueBusTripInfo 
  FROM
   offence a
   LEFT JOIN ( SELECT id, CONCAT( sid, sdate, stime ) AS uniqueBusTripInfo FROM offence ) b ON a.id = b.id 
  ) c 
 GROUP BY
 c.oid 
 ) T3 ON T2.oid = T3.oid;
    
    
#Question 8:
set @R = 4;
SELECT d_rank.rank as 'Rank',
did as 'Driver ID',
name as 'Name',
trips as 'Number of trips',
services as 'Number of unique services',
buses as 'Number of unique buses'
FROM (SELECT *,
	CASE 
	WHEN @trips = temp.trips THEN @rank
	WHEN @trips := temp.trips THEN @rank := @rank +1
	END as 'rank'
	FROM (SELECT @rank :=0) a,
     		  (SELECT d.did, name,
				COUNT(*) as 'trips',
				COUNT(DISTINCT sid) as 'services',
				COUNT(DISTINCT plateno)as 'buses'
     			FROM  bustrip b JOIN driver d ON b.did = d.did
     			GROUP BY did
				ORDER BY trips DESC
			  ) as temp
	) as d_rank
where d_rank.rank <= @R;