select orders.category, orders.subcategory, 
	SUM(orders.sales), SUM(orders.profit)
	from orders
	group by orders.category, orders.subcategory;