-- create new datatype for the resutl
create or replace type t_record as object (
 c_code VARCHAR2(6 BYTE),
 name VARCHAR2(10 BYTE),
 color VARCHAR2(20 BYTE),
 pay_amount NUMBER(38,0)
);
/
-- create table type to return from function
create or replace type t_table as table of t_record;
/

-- function definition
create or replace function total_price (code in VARCHAR2)
return t_table as
    v_ret   t_table;
    total     NUMBER(38,0);
begin
    select 
      t_record(c_code, name, color, provided_quantity*purchased_price)
    bulk collect into
      v_ret
    from category
    where
      code = s_code;
      
    SELECT  sum(provided_quantity*purchased_price) 
    INTO    total 
    FROM    Category 
    WHERE   code = s_code;
    
    dbms_output.put_line('Total: ' || total);
    return v_ret;
  
end total_price;
/

--example
select * from table(total_price('SU0002'));
/
