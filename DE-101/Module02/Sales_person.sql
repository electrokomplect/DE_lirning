select people.region, people.person,
	SUM(orders.sales), SUM(orders.profit)
	from people join orders on people.region = orders.region
	group by people.region, people.person;