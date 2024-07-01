-- Subjective Questions -----
-- Question 1 :Recommend the three albums from the new record label that should be prioritised for advertising and promotion in the USA based on genre sales analysis.
            -- To determine this we will be doing album and genre Sales Analysis
	select  distinct(g.name) ,  a.title , Sum(il.quantity) 
            from customer c 
            join invoice i on i.customer_id = c.customer_id
            join invoice_line il on i.invoice_id = il.invoice_id
            join track t on il.track_id = t.track_id 
            join genre g on t.genre_id = g.genre_id 
            join album a on a.album_id = t.album_id
             join artist ar on ar.artist_id = a.artist_id
            where c.country = 'USA' 
            group by  g.name ,  a.album_id , a.title 
            order by Sum(il.quantity) desc
            Limit 10;

-- Question 2 :Determine the top-selling genres in countries other than the USA and identify any commonalities or differences.
    -- countrywise top genres
	with cte1 as (
           select  g.name , c.country , Sum(il.quantity) as s1,
              dense_rank()Over(partition by c.country order by Sum(il.quantity) desc) as r1
             from customer c 
             join invoice i on i.customer_id = c.customer_id
             join invoice_line il on i.invoice_id = il.invoice_id
             join track t on il.track_id = t.track_id 
             join genre g on t.genre_id = g.genre_id 
             join album a on a.album_id = t.album_id
             join artist ar on ar.artist_id = a.artist_id
             where c.country <> 'USA' 
             group by  g.name , c.country
             order by Sum(il.quantity) desc)
            select name , country , s1   -- Retreiving genre names from the countries
                 from cte1 where r1 <=2
                  order by country;
       
-- Question 3 :Customer Purchasing Behavior Analysis: How do the purchasing habits (frequency, basket size, spending amount) of long-term customers differ
--                 from those of new customers? What insights can these patterns provide about customer loyalty and retention strategies?
-- Purchasing Habits
select   c.customer_id , count(distinct i.invoice_id)  as invoice_count, count(il.track_id) as track_count , 
              ((count(il.track_id)/count(distinct i.invoice_id)))  as Average_Basket_Size
               from customer c join invoice i on c.customer_id = i.customer_id 
                join invoice_line il on il.invoice_id = i.invoice_id 
                 group by  c.customer_id ;
-- Monthly Analyis
  select Month(i.invoice_date) , count(distinct i.invoice_id) as invoice_count , count(il.track_id) as track_count 
			from invoice i join invoice_line il on i.invoice_id = il.invoice_id
              group by Month(i.invoice_date);
-- Customer Duration 
    select customer_id , datediff((select max(invoice_date) from invoice),min(invoice_date)) as d1 from  invoice
          group by customer_id
            order by d1 asc;  
            
-- Question 4.	Product Affinity Analysis: Which music genres, artists, or albums are frequently purchased together by customers? 
--       How can this information guide product recommendations and cross-selling initiatives?   
             -- Top 10 artists , genres , albums purchased together based on Sales Anaylis
	select  ar.name,g.name,a.title,count(*)
            from customer c 
            join invoice i on i.customer_id = c.customer_id
            join invoice_line il on i.invoice_id = il.invoice_id
            join track t on il.track_id = t.track_id 
            join genre g on t.genre_id = g.genre_id 
            join album a on a.album_id = t.album_id
			join artist ar on ar.artist_id = a.artist_id
            group by  g.name,ar.name,a.title
			order by Sum(il.quantity) desc
			Limit 10;
    -- Top 10 artists         
	select  ar.name,count(*)
            from customer c 
            join invoice i on i.customer_id = c.customer_id
            join invoice_line il on i.invoice_id = il.invoice_id
            join track t on il.track_id = t.track_id 
            join genre g on t.genre_id = g.genre_id 
            join album a on a.album_id = t.album_id
             join artist ar on ar.artist_id = a.artist_id
            group by  ar.name
             order by Sum(il.quantity) desc
             Limit 10;
    -- Top 10 genres         
	select  g.name,count(*)
            from customer c 
            join invoice i on i.customer_id = c.customer_id
            join invoice_line il on i.invoice_id = il.invoice_id
            join track t on il.track_id = t.track_id 
            join genre g on t.genre_id = g.genre_id 
            join album a on a.album_id = t.album_id
             join artist ar on ar.artist_id = a.artist_id
            group by  g.name
             order by Sum(il.quantity) desc
             Limit 10;
             
      -- Top 10 titles       
	select  a.title,count(*)
            from customer c 
            join invoice i on i.customer_id = c.customer_id
            join invoice_line il on i.invoice_id = il.invoice_id
            join track t on il.track_id = t.track_id 
            join genre g on t.genre_id = g.genre_id 
            join album a on a.album_id = t.album_id
             join artist ar on ar.artist_id = a.artist_id
            group by  a.title
             order by Sum(il.quantity) desc
             Limit 10;      
-- Question 5:	Regional Market Analysis: Do customer purchasing behaviors and churn rates vary across different geographic regions or store locations?
--                How might these correlate with local demographic or economic factors?  
    with recent_purchases as (
    select distinct customer_id
    from invoice
    where invoice_date >= DATE_SUB((select MAX(invoice_date) from invoice), Interval 3 Month)
),
customer_status as (
    select 
        c.customer_id,
        c.country,
        case
            when rp.customer_id is not null then 'active'
            else 'churned'
        end as status
    from 
        customer c
        left join recent_purchases rp on c.customer_id = rp.customer_id
)
select 
    country,
    count(case when status = 'active' then 1 end) as active_customers,
    count(case when status = 'churned' then 1 end) as churned_customers,
    count(*) as total_customers,
    count(case when status = 'churned' then 1 end) * 100.0 / count(*) as churn_rate
from 
    customer_status
group by
    country
order by
    churn_rate desc;
    -- Customer Purchasing Behaviour by Country
    Select billing_country,Count(invoice_id) as TotalInvoices , Sum(total) as TotalRevenue
	from invoice 
	group by billing_country
	Order by TotalRevenue desc;
    
-- Question 6.	Customer Risk Profiling: Based on customer profiles (age, gender, location, purchase history), 
    --            which customer segments are more likely to churn or pose a higher risk of reduced spending? What factors contribute to this risk?
    
   With cte1 as (
         Select customer_id , year(invoice_date) as year , Sum(total) as yearly_total  , Sum(Sum(total)) Over (partition by customer_id order by year(invoice_date)) as Runningtotal
          from invoice 
            group by customer_id , year(invoice_date)
            order by customer_id),
		cte2 as (
          Select customer_id , year , yearly_total , Lag(yearly_total) Over (partition by customer_id) as previousyear
                  from cte1)
    
        Select customer_id , year , yearly_total , yearly_total-previousyear as changeinamount ,
    Round(((yearly_total-previousyear)/(yearly_total)),2) * 100 as percentage_change
          from cte2;
          -- Create a CTE for all possible combinations of genres and countries
with all_combinations as (
    select distinct g.name as genre_name, c.country
    from genre g
    cross join (select distinct country from customer) c
),
--  Create the CTE for genres sold in each country
cte1 as (
    select g.name as genre_name, c.country, SUM(il.quantity) as total_quantity
    from customer c
    join invoice i on i.customer_id = c.customer_id
    join invoice_line il on i.invoice_id = il.invoice_id
    join track t on il.track_id = t.track_id
    join genre g on t.genre_id = g.genre_id
    group by g.name, c.country
),
--  Find the genres not sold in each country
unsold_genres as (
    select ac.genre_name, ac.country
    from all_combinations ac
    left join cte1 s on ac.genre_name = s.genre_name and ac.country = s.country
    where s.genre_name is null
)

select genre_name, country
from unsold_genres
Order by  country, genre_name;

-- Question 10.	How can you alter the "Albums" table to add a new column named "ReleaseYear" of type INTEGER to store the release year of each album?        
              Alter table album
                   add column ReleaseYear int;
                   
-- Question 11: Chinook is interested in understanding the purchasing behavior of customers based on their geographical location. They want to know the average total amount spent by customers from each country,
   --  along with the number of customers and the average number of tracks purchased per customer. Write an SQL query to provide this information. 
        With customer_summary as (
         select   c.customer_id , c.country,   count(il.track_id) as c1  , Sum(total)  as TotalRevenue
               from customer c join invoice i on c.customer_id = i.customer_id 
                join invoice_line il on il.invoice_id = i.invoice_id 
                 group by  c.customer_id,c.country) 
		  Select country , count(customer_id) as NumberofCustomers , Round(Avg(c1),0) as AverageNumberofTracks , Round(Avg(TotalRevenue),2) as AverageRevenue 
                   from customer_summary 
                     group by country;
  
 -- End of Subjective Questions -- 
                     
           