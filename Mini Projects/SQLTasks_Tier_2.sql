/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

A1: SELECT name
    FROM Facilities
    WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

A2: SELECT count(*)
    FROM Facilities
    WHERE membercost = 0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

A3: SELECT facid, name, membercost, monthlymaintenance
    FROM Facilities
    WHERE membercost < (0.2 * monthlymaintenance);


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

A4: SELECT *
    FROM Facilities
    WHERE facid IN (1, 5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

A5: SELECT name, monthlymaintenance, CASE when monthlymaintenance > 100 then 'expensive' else 'cheap' END as  
    'label'
    FROM Facilities;
    

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

A6: SELECT firstname, surname
    FROM Members
    WHERE joindate = (SELECT max(joindate) FROM Members);


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

A7: SELECT f.name as court_name, concat(m.firstname, ' ', m.surname) as member_name
    FROM Members as m
    join Bookings as b on m.memid = b.memid
    join Facilities as f on b.facid = f.facid
    where m.memid <> 0 and f.name like 'Tennis Court%'
    order by concat(m.firstname, ' ', m.surname);

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

A8: SELECT f.name, concat(m.firstname, ' ', m.surname), 
    CASE when b.memid = 0 then slots*f.guestcost when b.memid <> 0 and slots*f.membercost > 30 then slots*f.membercost else NULL END as cost
    from Facilities as f join Bookings as b on f.facid = b.facid join Members as m on b.memid = m.memid
    where starttime like '2012-09-14%' 
    order by cost desc;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

A9: select facility, full_name, cost
    from
        (SELECT f.name as facility, concat(m.firstname, ' ', m.surname) as full_name, 
        CASE when b.memid = 0 then slots*f.guestcost when b.memid <> 0 and slots*f.membercost > 30 then 
        slots*f.membercost END as cost
        from Facilities as f join Bookings as b on f.facid = b.facid join Members as m on b.memid = 
        m.memid
        where starttime like '2012-09-14%' order by cost desc) cte
    where cost > 30;


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

A10: select name, sum(cost) as revenue
    from
        (SELECT f.facid, starttime, f.name as name, CASE when b.memid = 0 then slots*f.guestcost else 
        slots*f.membercost END as cost
        FROM Facilities f
        join Bookings b on f.facid = b.facid
        group by f.facid, starttime) cte
    group by name
    having sum(cost) < 1000
    order by revenue;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

A11: select concat(m1.surname, ',', m1.firstname) as member, case when concat(m2.surname, ',', 
    m2.firstname) is null then 'None' else concat(m2.surname, ',', m2.firstname) end as recommender
    from Members as m1
    join Members as m2 on m1.recommendedby = m2.memid
    where m1.memid <> 0 and m2.memid <> 0;


/* Q12: Find the facilities with their usage by member, but not guests */

A12: I'm assuming this question to mean that we are supposed to output the names of facilities which have only been used by members and not guests.

select distinct facid from Bookings
where facid not in
(select facid from Bookings where memid = 0);


/* Q13: Find the facilities usage by month, but not guests */

A13: I'm assuming this question to mean that I'm supposed to count the number of members who used a particular facility in a month.

select f.name as facility, month(starttime) as month, sum(memid*slots) as member_usage
from Bookings b join Facilities f on b.facid = f.facid
group by f.name, month(starttime)
order by f.name, month(starttime);



















