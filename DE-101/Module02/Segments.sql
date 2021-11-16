select  cast(extract(year from order_date) as char(4)) as year,
		cast(extract(month from order_date) as integer) as month,
		segment as segment,
		SUM(sales) as Sales, SUM(profit) as profit 
		from orders 
		group by year, month, segment
		order by year, month, segment;