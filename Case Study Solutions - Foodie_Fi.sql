use Foodie_fi;

1. How many customers has Foodie-Fi ever had?
Select count(distinct customer_id) as No_of_Customers
from subscriptions;

2. What is the monthly distribution of trial plan start_date values for our dataset -
 use the start of the month as the group by value.
 
 Select month(s.start_date) as Month_,count(p.plan_name) as Plan_Name
 from subscriptions as s
 join plans as p
 on s.plan_id = p.plan_id
 where p.plan_name = 'trial'
 group by 1
 order by 1
 
 3. What plan start_date values occur after the year 2020 for our dataset? Show the 
 breakdown by count of events for each plan_name.
 
 Select p.plan_name,count(p.plan_id) as total_count
 from plans p
 join subscriptions s
 on p.plan_id = s.plan_id
 where year(start_date) > 2020 
 group by 1
 order by 2 desc;
 
 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
 
 Select 
 count(customer_id) as churned_customer,
 round(100*count(s.customer_id)/(Select count(distinct customer_id) from subscriptions),1) as percentage_churned
 from plans as p
 join subscriptions as s
 on p.plan_id = s.plan_id
 where plan_name = 'churn';
 
 5. How many customers have churned straight after their initial free trial - what percentage is this 
 rounded to the nearest whole number?

 Select 
 (Select count(distinct customer_id) from subscriptions) as total_customers,
 count(*) as churned_customers,
 round(100*count(*)/(Select count(distinct customer_id) from subscriptions),0) as percentage_churned_customers
 from
 (Select *,
 row_number() over(partition by customer_id order by start_date) rank_
 from subscriptions) a
 where plan_id = 4 and rank_ = 2
 
6. What is the number and percentage of customer plans after their initial free trial?

with a as
(Select *,
row_number() over(partition by customer_id order by start_date) rank_
from subscriptions)

Select distinct p.plan_name,
count(case when rank_ = 2 then 1 end) as Plan_Count,
round(100*count(case when rank_ = 2 then 1 end)/(Select count(distinct customer_id) from subscriptions),0) as Plan_Percentage
from a
join plans p
on a.plan_id = p.plan_id
where a.plan_id != 0
group by 1;


7. How many customers have upgraded to an annual plan in 2020?
with a as
(Select *,
row_number() over(partition by customer_id order by start_date) as rank_
from subscriptions)

Select 
count(customer_id) as count_of_cutomers
from a 
where start_date between '2020-01-01' and '2020-12-31' and plan_id = 3

8. How many days on average does it take for a customer to an annual plan 
from the day they join Foodie-Fi?

with cte1 as
(Select 
customer_id,
min(start_date) as join_date
from subscriptions
group by 1),

cte2 as
(Select customer_id,
start_date as plan_date
from subscriptions
where plan_id = 3)

Select
round(avg(datediff(plan_date,join_date)),2) as avg_
from cte1
join cte2
on cte1.customer_id = cte2.customer_id

9. Can you further breakdown this average value into 30 day 
periods (i.e. 0-30 days, 31-60 days etc)

with cte1 as
(Select 
customer_id,
min(start_date) as join_date
from subscriptions
group by 1),

cte2 as
(Select customer_id,
start_date as plan_date
from subscriptions
where plan_id = 3),

cte3 as
(Select cte1.customer_id,datediff(plan_date,join_date) as days_difference,
case when datediff(plan_date,join_date) between 0 and 30 then '0 - 30 days'
	 when datediff(plan_date,join_date) between 31 and 60 then '31 - 60 days'
     when datediff(plan_date,join_date) between 61 and 90 then '61 - 90 days'
	 when datediff(plan_date,join_date) between 91 and 120 then '90 - 120 days'
     when datediff(plan_date,join_date) between 121 and 150 then '121 - 150 days'
	 when datediff(plan_date,join_date) between 151 and 180 then '151 - 180 days'
     when datediff(plan_date,join_date) between 181 and 210 then '181 - 210 days'
	 when datediff(plan_date,join_date) between 211 and 240 then '211 - 240 days'
	 when datediff(plan_date,join_date) between 241 and 270 then '241 - 270 days'
	 when datediff(plan_date,join_date) between 271 and 300 then '271 - 300 days'
     when datediff(plan_date,join_date) between 301 and 330 then '301 - 330 days'
	 when datediff(plan_date,join_date) > 330 then 'More than 330 days'
     end as Time_Periods
from cte1
join cte2
on cte1.customer_id = cte2.customer_id
group by 1)

Select Time_Periods,
count(Time_Periods) as cnt,
round(avg(days_difference),2) as avged_days_diff
from cte3
group by 1

10. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

Select count(a.customer_id) customer_count 
from
(Select s.*,p.plan_name,
lead(p.plan_name) over(partition by s.customer_id order by s.start_date) as leaded_plan
from subscriptions as s
join plans as p
on s.plan_id = p.plan_id 
where s.start_date between '2020-01-01' and '2020-12-31') as a
where a.leaded_plan = 'basic monthly' and a.plan_name = 'pro monthly'

OR

Select count(*) Customer_count
from subscriptions as s1
join subscriptions as s2
on s1.customer_id =  s2.customer_id
where s1.start_date between '2020-01-01' and '2020-12-31' 
and s1.plan_id = 2 and s2.plan_id = 1 
and s1.start_date < s2.start_date

