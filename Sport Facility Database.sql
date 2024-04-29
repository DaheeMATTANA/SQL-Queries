-- ----- Sport Facility Database (credit : Jose Portilla, Pierian Data www.pieriantraining.com)


-- 1) A list of facilities that charge a fee to members?
-- A
SELECT *
FROM cd.facilities
WHERE membercost != 0;
-- B
SELECT *
FROM cd.facilities
WHERE membercost > 0;


-- 2) Produce a list facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost?
-- A
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost != 0
AND membercost < monthlymaintenance * 1/50;

-- B
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0
AND membercost < (monthlymaintenance/50.0);


-- 3) Retrieve all facilities with the word 'Tennis' in their name?
-- A
SELECT *
FROM cd.facilities
WHERE name LIKE '%Tennis%';

-- B
SELECT *
FROM cd.facilities
WHERE name ILIKE '%tennis%';


-- 4) Retrieve the details of facilities with ID 1 and 5?
SELECT *
FROM cd.facilities
WHERE facid IN(1, 5);


-- 5) Produce a list of members who joined after the start of September 2012?
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate >= '2012-09-01';


-- 6) Produce an ordered list of the first 10 surnames in the members table? The list must not contain duplicates.
SELECT DISTINCT surname
FROM cd.members
ORDER BY surname
LIMIT 10;


-- 7) Get the signup date of your last member
-- A
SELECT joindate
FROM cd.members
ORDER BY joindate DESC
LIMIT 1;

-- B
SELECT MAX(joindate)
FROM cd.members;


-- 8) Produce a count of the number of facilities that have a cost to guests of 10 or more.
SELECT COUNT(*)
FROM cd.facilities
WHERE guestcost >= 10;


-- 9) A list of the total number of slots booked per facility in the month of September 2012
-- A
SELECT facid, SUM(slots)
FROM cd.bookings
WHERE starttime BETWEEN '2012-09-01' AND '2012-10-01'
GROUP BY facid
ORDER BY SUM(slots);

-- B
SELECT facid, SUM(slots) AS total_slots
FROM cd.bookings
WHERE starttime >= '2012-09-01' 
AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY SUM(slots);


-- 10) Produce a list of facilities with more than 1000 slots booked
SELECT facid, SUM(slots)
FROM cd.bookings
GROUP BY facid
HAVING SUM(slots) > 1000
ORDER BY facid;


-- 11) A list of the start times for bookings for tennis courts, for the date '2012-09-21'?
-- A
SELECT starttime, name
FROM cd.bookings as b
INNER JOIN cd.facilities as f
ON b.facid = f.facid
WHERE DATE(starttime) = '2012-09-21'
AND name LIKE '%Tennis Court%'
ORDER BY starttime;

-- B
SELECT cd.bookings.starttime, cd.facilities.name
FROM cd.facilities
INNER JOIN cd.bookings
ON cd.facilities.facid = cd.bookings.facid
WHERE cd.facilities.facid IN(0, 1)
AND cd.bookings.starttime >= '2012-09-21'
AND cd.bookings.starttime < '2012-09-22'
ORDER BY cd.bookings.starttime;


-- 12) Retrieve a list of the start times for bookings by members named 'David Farrell'?
-- A
SELECT starttime
FROM cd.bookings as book
INNER JOIN cd.members as mem
ON book.memid = mem.memid
WHERE surname = 'Farrell'
AND firstname = 'David';

-- B
SELECT cd.bookings.starttime
FROM cd.bookings
INNER JOIN cd.members
ON cd.members.memid = cd.bookings.memid
WHERE cd.members.firstname = 'David'
AND cd.members.surname = 'Farrell';