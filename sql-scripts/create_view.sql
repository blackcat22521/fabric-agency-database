create or replace view order_contains as
select order_tb.datetime, order_tb.order_status, order_tb.cus_code, contains.* from order_tb inner join contains on order_tb.o_code = contains.o_code;

create or replace view newest_price as
WITH cte AS (
    SELECT current_price.*, ROW_NUMBER() OVER (PARTITION BY c_code ORDER BY set_date DESC) rn
    FROM current_price
)
SELECT *
FROM cte
WHERE rn = 1;

select * from newest_price;
create or replace view testing 
as select CATEGORY.c_code from CATEGORY where S_CODE = 'SU0001';

create or replace view order_contains_price as
select order_contains.*, newest_price.price from order_contains inner join newest_price on order_contains.c_code = newest_price.c_code order by cus_code;

create or replace view order_contains_total_price as
select order_contains_price.*, bolt.length, (bolt.length * order_contains_price. price) total_price from order_contains_price inner join bolt
on order_contains_price.b_code = bolt.b_code and order_contains_price.c_code = bolt.c_code;

create or replace view cus_order as
select order_contains_total_price.*, customer.fname, customer.lname 
from order_contains_total_price inner join customer on order_contains_total_price.cus_code = customer.code;

create or replace view ret as
select to_char(datetime, 'dd-mm-yyyy' ) datepart, to_char(datetime, 'HH24:MI:SS' ) timepart, cus_order.* from cus_order;

create or replace view final_ret as
select ret.*, cancel_order.reason from ret left join cancel_order on ret.o_code = cancel_order.o_code;
