drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from goldusers_signup;
select * from users;
select * from sales;
select * from product;


--which item was purchase first after they become the gold_member
with ct1 as 
(
select c.*, rank() over(partition by userid order by c.created_date) as ranks
from(
select u.*,s.created_date, s.product_id
from goldusers_signup as u join sales as s on u.userid=s.userid 
where s.created_date>u.gold_signup_date
) as c
)

select ct1.userid, ct1.gold_signup_date, ct1.created_date, p.product_name
from ct1 join product as p on ct1.product_id=p.product_id where ranks=1;


--which item was purchase first just before they become the gold_member

with ct1 as 
(
select c.*, rank() over(partition by userid order by c.created_date desc) as ranks
from(
select u.*,s.created_date, s.product_id
from goldusers_signup as u join sales as s on u.userid=s.userid 
where s.created_date<=u.gold_signup_date
) as c
)

select ct1.userid, ct1.gold_signup_date, ct1.created_date, p.product_name
from ct1 join product as p on ct1.product_id=p.product_id where ranks=1;



--total order and amount sent by each user before they become a member
select u.userid, count(created_date)as total, sum(p.price)
from goldusers_signup as u 
join sales as s on u.userid=s.userid 
join product as p on s.product_id = p.product_id
where s.created_date<=u.gold_signup_date
group by u.userid;


--calculate point gained by each user (for eg for product 'p1' 5rs = 1 point for  product 'p2' 10rs = 2 point for product 'p3' 5rs = 1 point)
with ct1 as
(
-- total price spent by each user on each product
select s.userid , sum(p.price) as total , p.product_name
from sales as s join product as p on s.product_id=p.product_id
group by s.userid,p.product_name
order by s.userid
)
--total point gained by each user
select ct1.userid ,sum(case when ct1.product_name='p1' then total/5 when ct1.product_name='p2' then total/2
 when ct1.product_name='p3' then (total/5) else 0 end) as ponts 
 from ct1
 group by ct1.userid;

   
   
--total point(5 point on every 10 rupese spent) earn by each user in the 1st year after becoming the gold member
with ct1 as
(
--total price spent by user in the 1st year after becoming the gold member
select u.*,s.created_date,  sum(p.price) as total_price
from goldusers_signup as u join sales as s on u.userid=s.userid 
join product as p on s.product_id=p.product_id
where s.created_date>=u.gold_signup_date and s.created_date<=u.gold_signup_date+365
group by u.userid, u.gold_signup_date, s.created_date
)
--total point
select * , ct1.total_price/2 as points from ct1;

--rank all the customer
select *, rank() over(partition by userid order by created_date) as Rank 
from sales;


















   