select returns.returned, round(cast(count( distinct orders.order_id) as decimal) /
	cast((select count(distinct orders.order_id) from orders) as decimal)*100, 3) 
	from orders left join returns on orders.order_id = returns.order_id
	group by returns.returned
	;