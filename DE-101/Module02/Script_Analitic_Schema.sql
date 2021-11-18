drop table if exists "product_dim" cascade;
CREATE TABLE product_dim
(
 prod_key     integer NOT NULL,
 product_id   varchar(15) NOT NULL,
 category     varchar(15)     NULL,
 subcategory  varchar(11)     NULL,
 product_name varchar(127)    NULL,
 CONSTRAINT PK_27 PRIMARY KEY ( prod_key )
);
insert into product_dim
select 100+row_number() over (),
product_id, category, subcategory, product_name from (select distinct on (product_id) product_id, category, subcategory, product_name from orders) a;

drop table if exists "customer_dim" cascade;
CREATE TABLE customer_dim
(
 cust_key      integer NOT NULL,
 customer_id   varchar(8) NOT NULL,
 customer_name varchar(22)    NULL,
 CONSTRAINT PK_35 PRIMARY KEY ( cust_key )
);
insert into customer_dim select 100+row_number() over(),
customer_id, customer_name from (select distinct on (customer_id) customer_id, customer_name from orders) a;

drop table if exists place_dim cascade;
CREATE TABLE place_dim
(
 geo_key     integer       NOT NULL,
 country     varchar(13)   NOT NULL,
 city        varchar(17)   NOT NULL,
 "state"       varchar(20) NOT NULL,
 postal_code int4              NULL,
 region      varchar(7)    NOT NULL,
 CONSTRAINT PK_5 PRIMARY KEY ( geo_key )
);
insert into place_dim select 100+row_number() over(),
country, city, state, postal_code, region from (select distinct country, city, state, postal_code, region from orders) a;


drop table if exists ship_dim cascade;
CREATE TABLE ship_dim
(
 ship_key  integer NOT NULL,
 ship_mode varchar(14) NOT NULL,
 CONSTRAINT PK_43 PRIMARY KEY ( ship_key )
);

insert into ship_dim
select 100+row_number() over (),
ship_mode from (select distinct ship_mode from orders) a;

-- ************************************** calendar_dim
drop table if exists calendar_dim cascade;
CREATE TABLE calendar_dim
(
 order_date date NOT NULL,
 ship_date  date NOT NULL,
 "year"       integer NOT NULL,
 "quarter"    integer NOT NULL,
 month      integer NOT NULL,
 month2     integer NOT NULL,
 day        integer NOT NULL,
 day_week   integer NOT NULL,
 CONSTRAINT PK_18 PRIMARY KEY ( order_date, ship_date )
);
insert into calendar_dim
select order_date, ship_date,
cast(extract(year from order_date) as integer),
cast(extract(quarter from order_date) as integer),
cast(extract(month from order_date) as integer),
cast(extract(year from order_date) as integer)*10 + cast(extract(month from order_date) as integer),
cast(extract(day from order_date) as integer),
cast(extract(isodow from order_date) as integer)
from (select distinct order_date, ship_date from orders) a;

-- ************************************** "order"
drop table if exists sales cascade;
CREATE TABLE "sales"
(
 row_id       integer NOT NULL,
 order_id     varchar(14) NOT NULL,
 order_date   date NOT NULL,
 ship_key     integer NULL,
 ship_date    date NOT NULL,
 cust_key     integer NOT NULL,
 sales        numeric(9,4) NOT NULL,
 quantity     integer NOT NULL,
 discount     numeric(4,2) NOT NULL,
 profit       numeric(21,16) NOT NULL,
 prod_key     integer NOT NULL,
 geo_key      integer     NULL,
 CONSTRAINT PK_47 PRIMARY KEY ( row_id ),
 CONSTRAINT FK_70 FOREIGN KEY ( prod_key ) REFERENCES product_dim ( prod_key ),
 CONSTRAINT FK_73 FOREIGN KEY ( geo_key ) REFERENCES place_dim ( geo_key ),
 CONSTRAINT FK_76 FOREIGN KEY ( cust_key ) REFERENCES customer_dim ( cust_key ),
 CONSTRAINT FK_79 FOREIGN KEY ( ship_key ) REFERENCES ship_dim ( ship_key ),
 CONSTRAINT FK_83 FOREIGN KEY ( order_date, ship_date ) REFERENCES calendar_dim ( order_date, ship_date )
);

CREATE INDEX fkIdx_72 ON "sales"
(
 prod_key
);

CREATE INDEX fkIdx_75 ON "sales"
(
 geo_key
);

CREATE INDEX fkIdx_78 ON "sales"
(
 cust_key
);

CREATE INDEX fkIdx_81 ON "sales"
(
 ship_key
);

CREATE INDEX fkIdx_86 ON "sales"
(
 order_date,
 ship_date
);

insert into sales
select row_id, order_id, order_date, ship_key, ship_date, cust_key, sales, quantity,
discount, profit, prod_key, geo_key
from(
select o.row_id, o.order_id, o.order_date, s.ship_key, o.ship_date, c.cust_key, o.sales, o.quantity,
o.discount, o.profit, p.prod_key, pl.geo_key
from orders as o 
left outer join ship_dim     as s  on o.ship_mode = s.ship_mode
left outer join customer_dim as c  on o.customer_id  = c.customer_id
left outer join product_dim  as p  on o.product_id  = p.product_id
left outer join place_dim    as pl on o.city  = pl.city and o.postal_code = pl.postal_code
) a
;

--select o.row_id, o.order_id, o.order_date, s.ship_key, o.ship_date, c.cust_key, o.sales, o.quantity,
--o.discount, o.profit, p.prod_key, pl.geo_key
--from orders as o 
--left outer join ship_dim     as s  on o.ship_mode = s.ship_mode
--left outer join customer_dim as c  on o.customer_id  = c.customer_id
--left outer join product_dim  as p  on o.product_id  = p.product_id
--left outer join place_dim    as pl on o.city  = pl.city 
--							 and o.postal_code = pl.postal_code 						
--order by o.row_id
--;





