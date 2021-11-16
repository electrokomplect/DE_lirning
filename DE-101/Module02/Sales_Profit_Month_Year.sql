
select  cast(extract(year from order_date) as char(4)) as year,
		cast(extract(month from order_date) as integer) as month,
		SUM(sales) as Sales, SUM(profit) as profit 
		from orders 
		group by year, month
		order by year, month;
