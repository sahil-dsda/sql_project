-- Creating and use database
create database project;
use project;

-- 1 Customer Table 
create table customer(
customerId int primary key,
name varchar (100),
phone varchar(15),
email varchar(100),
 joindate date);
 
 insert into customer(customerId,name,phone,email,joindate)values
 (1, 'Rajan Pandey', '9876543210', 'rajan@example.com', '2024-01-10'),
(2, 'Jay Tiwari', '8765432109', 'jay@example.com', '2024-02-15'),
(3, 'Rakesh Yadav', '7654321098', 'rakesh1@example.com', '2024-03-01'),
(4, 'Harsh Singh', '6543210987', 'harshu@example.com', '2024-04-05');

select * from customer;

-- 2 Driver Table 
create table driver(
driverId int primary key,
name varchar (100),
phone varchar(15),
licenceNo varchar(20),
joindate date ,
rating float);

insert into driver(driverId , name , phone , licenceNo , joindate , rating)values
(1, 'Raj Singh', '9123456789', 'DL12345678', '2023-09-01', 4.5),
(2, 'Sunny Chaudhary', '9234567890', 'DL87654321', '2023-10-12', 3.2),
(3, 'Anshu P', '9345678901', 'DL23456789', '2024-01-20', 2.8),
(4, 'Alina Kapoor', '9456789012', 'DL34567890', '2024-03-15', 4.0);

select * from driver;

-- 3 cabs table 
create table cabs(
cabId int primary key,
driverId int ,
cabType varchar (20),
plateNo varchar (10),
foreign key (driverId) references driver (driverId));

insert into cabs(cabId , driverId , cabType , plateNo) values
(1, 1, 'Sedan', 'KA01AB1234'),
(2, 2, 'SUV', 'KA01CD5678'),
(3, 3, 'Sedan', 'KA01EF9012'),
(4, 4, 'SUV', 'KA01GH3456');

select * from cabs;

-- 4 Bookings Table

create table booking(
bookingId int primary key,
customerId int,
cabId int,
bookingTime datetime,
tripStartTime datetime ,
tripEndTime datetime ,
pickuplocation varchar(20),
dropoffLocation varchar(20),
status varchar (10),
foreign key (customerId) references customer(customerId),
foreign key (cabId) references cabs(cabId));

insert into booking(bookingId , customerId , cabId , bookingTime, tripStartTime , tripEndTime , pickupLocation , dropoffLocation , status) values	
(101, 1, 1, '2025-05-01 08:00:00', '2025-05-01 08:10:00', '2025-05-01 08:40:00', 'Downtown', 'Airport', 'Completed'),
(102, 2, 2, '2025-05-01 09:00:00', NULL, NULL, 'Station', 'Mall', 'Cancelled'),
(103, 1, 3, '2025-05-02 10:00:00', '2025-05-02 10:15:00', '2025-05-02 10:50:00', 'Downtown', 'Hospital', 'Completed'),
(104, 3, 4, '2025-05-03 11:30:00', '2025-05-03 11:45:00', '2025-05-03 12:30:00', 'Mall', 'University', 'Completed'),
(105, 4, 1, '2025-05-04 14:00:00', NULL, NULL, 'Airport', 'Downtown', 'Cancelled');

select * from booking;


-- Problem Statement:  
-- Customer and Booking Analysis


-- 1. Identify customers who have completed the most bookings. What insights can you draw about their behavior? 

select c.customerId , c.name ,
sum(b.status="Completed") as Complete_booking,
count(*) as Total_booking
from customer c 
join booking b on c.customerId = b.customerId
group by c.customerId , c.name 
order by  Complete_booking desc;

-- 2. Find customers who have canceled more than 30% of their total bookings. What could be the reason for frequent cancellations?

select c.customerId , c.name,
sum(b.status='Cancelled') as cancelled_bookings,
count(*) as Total_booking,
sum(b.status='Cancelled') / count(*) as cancel_ratio
from customer c 
join booking b on c.customerId = b.customerId
group by c.customerId
having cancel_ratio > 0.30;

-- 3. Determine the busiest day of the week for bookings. How can the company optimize cab availability on peak days?  

select dayname(bookingTime) as weekday ,
count(*) as bookings
from booking
group by weekday
order by bookings desc
limit 1;


-- Driver Performance & Efficiency 
-- 1. Identify drivers who have received an average rating below 3.0 in the past three months. What strategies can be implemented to improve their performance? 

select d.name , avg(t.driversRating) as avgOfRating
from driver d 
join cabs c on d.driverId = c.driverId
join booking b on c.cabId = b.cabId
join tripDetails t on b.bookingId = t.bookingId
where b.tripEndTime >= date_sub(curdate() ,interval 3 month)
group by d.driverId
having avgOfRating < 3.0;


-- 2. Find the top 5 drivers who have completed the longest trips in terms of distance. What does this say about their working patterns? 

select d.driverId , d.name , sum(t.distance) as TotalDistance , count(*) as CompletedTrips
from tripDetails t 
join booking b on t.bookingId = b.bookingId
join cabs c on b.cabId = c.cabId 
join driver d on c.driverId = d.driverId 
where status ="Completed"
group by d.driverId , d.name
order by TotalDistance desc 
limit 5;


-- 3. Identify drivers with a high percentage of canceled trips. Could this indicate driver unreliability?

select d.driverId , d.name,  
sum(b.status='Cancelled') as Cancelled_count ,
count(*) as Total_assigned ,
sum(b.status='Cancelled') / count(*) as Cancel_Ratio
from booking b
join cabs c on b.cabId = c.cabId
join driver d on c.driverId = d.driverId
group by d.driverId , d.name 
having Cancel_Ratio > 0.30;

-- Revenue & Business Metrics 


-- 1. Calculate the total revenue generated by completed bookings in the last 6 months. How has the revenue trend changed over time? 

select month(tripEndTime) as last6months , sum(fare) as sum_fare 
from booking b 
join tripDetails t on b.bookingId = t.bookingId 
where status='Completed' 
and tripEndTime >= date_sub(current_date(),interval 6 month)
group by last6months
order by last6months;


-- 2. Identify the top 3 most frequently traveled routes based on PickupLocation and DropoffLocation. Should the company allocate more cabs to these routes? 

select pickupLocation , dropoffLocation , count(*) as Total_Trips
from booking b 
where status='Completed'
group by pickupLocation , dropoffLocation 
order by Total_Trips desc
limit 3;


-- 3. Determine if higher-rated drivers tend to complete more trips and earn higher fares. Is there a direct correlation between driver ratings and earnings?


select d.driverId , d.name , 
avg(driversRating) as Avg_Rating , 
sum(b.status='Completed') as Completed_trips , 
sum(t.fare) as Total_earnings 
from driver d 
join cabs c on d.driverId = c.driverId 
join booking b on c.cabId = b.cabId 
join tripDetails t on b.bookingId = t.bookingId 
group by d.driverId , d.name
order by Avg_Rating desc;

-- Operational Efficiency & Optimization 


-- 1. Analyze the average waiting time (difference between booking time and trip start time) for different pickup locations. How can this be optimized to reduce delays? 

select pickupLocation ,
avg(timestampdiff(MINUTE , bookingTime, tripStartTime)) as avg_waiting_time
from booking b 
where tripStartTime is not null 
group by pickupLocation
order by avg_waiting_time desc;


-- 2. Identify the most common reasons for trip cancellations from customer feedback. What actions can be taken to reduce cancellations? 

select reasonForCancellation , count(*) as Count_of_reasons 
from feedback 
where reasonForCancellation is not null and reasonForCancellation <>''
group by reasonForCancellation
order by Count_of_reasons desc ;


-- 3. Find out whether shorter trips (low-distance) contribute significantly to revenue. Should the company encourage more short-distance rides?

