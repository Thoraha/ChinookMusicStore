-- Objective Questions
-- Question-1)  Does any table have missing values or duplicates? If yes how would you handle it ? ----
    
UPDATE customer SET state = 'BW' WHERE postal_code = '70174';
UPDATE customer SET state = 'OS' WHERE postal_code = '0171';
UPDATE customer SET state = 'CZ-01' WHERE city = 'Prague';
UPDATE customer SET state = 'AT-WI' WHERE postal_code = '1010';
UPDATE customer SET state = 'BXL' WHERE postal_code = '1000';
UPDATE customer SET state = 'CP' WHERE postal_code = '1720';
UPDATE customer SET state = 'LIS' WHERE city = 'Lisbon';
UPDATE customer SET state = 'OPO' WHERE city = 'Porto';
UPDATE customer SET state = 'BE' WHERE  city = 'Berlin';
UPDATE customer SET state = 'HE' WHERE postal_code = '60316';
UPDATE customer SET state = 'FR-75C' WHERE city = 'Paris';
UPDATE customer SET state = 'FR-69' WHERE postal_code = '69002';
UPDATE customer SET state = 'FR-33' WHERE postal_code = '33000';
UPDATE customer SET state = 'BFC' WHERE postal_code = '21000';
UPDATE customer SET state = 'FI-18' WHERE postal_code = '00530';
UPDATE customer SET state = 'HU' WHERE city = 'Budapest';
UPDATE customer SET state = 'PL-14' WHERE postal_code = '00-358';
UPDATE customer SET state = 'MD' WHERE postal_code = '28015';
UPDATE customer SET state = 'SE-18' WHERE postal_code = '11230';
UPDATE customer SET state = 'LND' WHERE city = 'London';
UPDATE customer SET state = 'EDH' WHERE postal_code = 'EH4 1HH';
UPDATE customer SET state = 'AR-A' WHERE postal_code = '1106';
UPDATE customer SET state = 'CL' WHERE city = 'Santiago';
UPDATE customer SET state = 'DL' WHERE postal_code = '110017';
UPDATE customer SET state = 'KA' WHERE postal_code = '560001';
-- Updating invocie table from customertable
UPDATE invoice AS i
JOIN customer AS c ON c.customer_id = i.customer_id
SET i.billing_state = c.state;

-- Question 2 Find the top-selling tracks and top artist in the USA and identify their most famous genres?
-- Top Tracks
SELECT  t.name AS track_name
 FROM  customer c
 JOIN  invoice i ON c.customer_id = i.customer_id
 JOIN  invoice_line il ON i.invoice_id = il.invoice_id
 JOIN  track t ON il.track_id = t.track_id
  WHERE  c.country = 'USA'
 GROUP BY   t.name
 ORDER  BY SUM(il.quantity) DESC
 LIMIT 5;
-- Top Artists
Select   ar.name  as Artist_name
	from customer c join invoice i on c.customer_id = i.customer_id 
	join invoice_line il on il.invoice_id = i.invoice_id 
	join track t on il.track_id = t.track_id 
	join album a on a.album_id = t.album_id
	join artist ar on ar.artist_id = a.artist_id
	where c.country = 'USA'
	group by  ar.name 
	order by Sum(il.quantity) desc
	limit 5;
    
-- Top Genres
Select  g.name
	from customer c 
	join invoice i on i.customer_id = c.customer_id
	join invoice_line il on i.invoice_id = il.invoice_id
	join track t on il.track_id = t.track_id 
	join genre g on t.genre_id = g.genre_id 
	join album a on a.album_id = t.album_id
	join artist ar on ar.artist_id = a.artist_id
	where c.country = 'USA' 
	group by  g.name
	order by Sum(il.quantity) desc
	Limit 5;
-- Question 3   What is  the customer demographic breakdown (age, gender, location) of Chinook's customer base?
 -- Numbers of customers from each country
	Select country , count(*) as TotalCustomers 
		from customer 
		group by country
        order by TotalCustomers desc;
        
-- Question 4 Calculate the total revenue and number of invoices for each country, state, and city:
-- Number of Invoices from Country
Select billing_country as Country ,Count(invoice_id) as TotalInvoices , Sum(total) as TotalRevenue
	from invoice 
	group by billing_country
	Order by TotalRevenue desc;
  -- Number of Invoices from each State
Select billing_state,Count(invoice_id) as TotalInvoices , Sum(total) as TotalRevenue
	from invoice 
	group by billing_state
	Order by TotalRevenue desc;
-- Number of Invoices from City
 Select billing_city,Count(invoice_id) as TotalInvoices , Sum(total) as TotalRevenue
	from invoice 
	group by billing_city
	Order by TotalRevenue desc;
-- Number of Invoices from each country , state and city
Select billing_country as Country,
    billing_state as State,
    billing_city as City,
    Count(invoice_id) as TotalInvoices , Sum(total) as TotalRevenue
	from invoice 
	group by billing_country,billing_state,billing_city
	Order by TotalRevenue desc;
    
    -- 5.	Find the top 5 customers by total revenue in each country
	-- Ranking total revneue  based on each country
With cte1 as (
	Select concat(c.first_name," " ,c.last_name) as customer_name,
    c.country , 
    Sum(i.total) as total_revenue,
	dense_rank() over (Partition by c.country order by Sum(i.total) desc) as r1
	from customer c join invoice i 
	on c.customer_id = i.customer_id 
	group by customer_name , c.country
   )
   Select customer_name , country     -- Top 5 Customers
	from cte1 where r1<=5;
  
    -- Question 6.	Identify the top-selling track for each customer
 -- Ranking each customer based on number of tracks 
With cte as (
	Select Concat(c.first_name," ",c.last_name) as customer_name ,c.first_name , t.name , Count(*) ,
		dense_rank()Over(Partition by c.first_name order by Count(*) desc , t.name asc ) as r1 
		from invoice_line il 
		join invoice i on il.invoice_id = i.invoice_id 
		join track t  on il.track_id = t.track_id 
		join customer c on c.customer_id = i.customer_id 
		group by customer_name,c.first_name , t.name)
                            
	Select customer_name , name from cte where r1 =1 ;   -- Top purchased tracks of each customer
 --  Question 7.	Are there any patterns or trends in customer purchasing behavior (e.g., frequency of purchases, preferred payment methods, average order value)? 
 -- Quarterly,Yearly  Sale Analyis 
     Select quarter(invoice_date) as quarter , year(invoice_date) as year, Sum(total)
		from invoice 
		group by quarter(invoice_date),year(invoice_date);
 -- Quarterly Sale Analysis
      Select quarter(invoice_date) as Quarter , Count(*) as NumberofInvoices , Sum(total) as TotalRevenue
        from invoice
        group by quarter(invoice_date);
 --  Customer Purchasing Power
     Select   c.customer_id , Count(distinct i.invoice_id)  as invoice_count, Count(il.track_id) as track_count , 
              ((Count(il.track_id)/Count(distinct i.invoice_id)))  as Average_Basket_Size
               from customer c join invoice i on c.customer_id = i.customer_id 
                join invoice_line il on il.invoice_id = i.invoice_id 
                 group by  c.customer_id ;
 -- Customer Tenure 
    Select customer_id , datediff((Select max(invoice_date) from invoice),min(invoice_date)) as d1 from  invoice
          group by customer_id
            order by d1 asc;
 
  -- Question 8.What is the customer churn rate?
     -- Churn rate
   With latest_date as (                -- LastInvoiceDate
			Select Max(invoice_date) as Max_date from invoice 
					),
		Recent_purchases as (            -- Finding the customers who purchased in last 3 months 
			Select 
					Distinct i.customer_id 
					from invoice i ,latest_date l 
					where invoice_date >= date_sub(l.Max_date,Interval 3 Month)
							),
        Customer_status as (            -- To find whether customer is active or inactive
					Select c.customer_id ,
					Case when rp.customer_id is not null then 'Active'
							                             Else 'Churned'
						End as status 
							from Customer c  left join Recent_purchases rp
							on c.customer_id = rp.customer_id
                            )
		Select Round(Count(Case When status = 'churned' then 1 end) * 100.0 / count(*),2) AS churn_rate
               from 
                     customer_status;
                     
-- Question 9.	Calculate the percentage of total sales contributed by each genre in the USA and identify the best-selling genres and artists.                    
	-- Genre Percentage
            With Cte1 as (
            Select  g.name , sum(il.quantity) as C1,  -- C1 means genres bought 
           Sum(Sum(il.quantity)) Over () as S1   -- S1 means total number of genres sold
            from customer c 
            join invoice i on i.customer_id = c.customer_id
            join invoice_line il on i.invoice_id = il.invoice_id
            join track t on il.track_id = t.track_id 
            join genre g on t.genre_id = g.genre_id 
            join album a on a.album_id = t.album_id
             join artist ar on ar.artist_id = a.artist_id
            where c.country = 'USA' 
            group by  g.name
            order by Sum(il.quantity) desc)
           Select name , Round(((C1/S1) * 100),2) as Sales_Percent
             from cte1;
  -- Top Genres and Artists
		Select  ar.name as artist_name ,g.name as genre_name
            from customer c 
            join invoice i on i.customer_id = c.customer_id
            join invoice_line il on i.invoice_id = il.invoice_id
            join track t on il.track_id = t.track_id 
            join genre g on t.genre_id = g.genre_id 
            join album a on a.album_id = t.album_id
             join artist ar on ar.artist_id = a.artist_id
            where c.country = 'USA' 
            group by  g.name,ar.name
            order by Sum(il.quantity) desc
            Limit 10;
       
-- Question  10.Find customers who have purchased tracks from at least 3 different genres
   --  Customers who bought atleast 3 genres
        Select  Concat(c.first_name, " ",c.last_name) as customer_name
            from customer c 
            join invoice i on i.customer_id = c.customer_id
            join invoice_line il on i.invoice_id = il.invoice_id
            join track t on il.track_id = t.track_id 
            join genre g on t.genre_id = g.genre_id 
            group by  c.first_name,c.customer_id
            having
            Count(distinct g.name) >= 3;
            
  -- Question 11 Rank genres based on their sales performance in the US    
     -- Ranking genres based on their sales
     Select  g.name,
          dense_rank()Over(Order by Sum(il.quantity)desc) as R1
            from customer c 
            join invoice i on i.customer_id = c.customer_id
            join invoice_line il on i.invoice_id = il.invoice_id
            join track t on il.track_id = t.track_id 
            join genre g on t.genre_id = g.genre_id 
            join album a on a.album_id = t.album_id
             join artist ar on ar.artist_id = a.artist_id
            where c.country = 'USA' 
            group by  g.name
            order by R1 ;
-- Question 12 Identify customers who have not made a purchase in the last 3 months
		-- To do this we need last transaction date
	With last_invoice_date as (
    Select Max(invoice_date) as  max_invoice_date
    from invoice
    ),
    recent_purchases as (
    select distinct customer_id
    From invoice, last_invoice_date
    where invoice.invoice_date >= DATE_SUB(last_invoice_date.max_invoice_date, Interval 3 month)
     )
     -- Select customers who have not made a purchase in the last 3 months
      Select
      concat(first_name," ",c.last_name) as Customer_Name
      From
    customer c
     Where
    c.customer_id Not in (Select customer_id from recent_purchases);
    
 -- End of Objective Questions   
            
      
       
		
   
   

    