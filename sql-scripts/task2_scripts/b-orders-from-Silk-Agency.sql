SELECT o.O_Code, o.Total_Price, o.DateTime, o.Opr_Staff_Code, o.Cus_Code, o.Order_Status
FROM Order_TB o, Contains co, Category ca, Supplier s
WHERE   o.O_Code = co.O_Code
AND     co.C_Code = ca.C_Code
AND     ca.S_Code = s.S_Code
AND     s.Name = 'Silk Agency'