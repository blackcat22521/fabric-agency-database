Khi insert supplier mới, cột S_Code có thể điền string tùy ý, đơn giản nhất là cứ điền empty string. DBMS sẽ tự động generate S_Code cho new supplier.

Sau khi insert xong thì new supplier đã có S_Code. Sử dụng [DML RETURNING Bind Variables](https://cx-oracle.readthedocs.io/en/latest/user_guide/bind.html#dml-returning-bind-variables) để get S_Code của supplier đó. 

Code minh họa:

```python
s_code = cursor.var(str)
cursor.execute("""
        insert into supplier
        values('', :name, :address, :bank_account, 
               tax_code, partner_staff_code)
        returning s_code into :s_code
    """,
    [name, address, bank_account, 
     tax_code, partner_staff_code])
print(s_code.getvalue())
```

Sau đó tiếp tục dùng s_code vừa nhận được để insert phone numbers.