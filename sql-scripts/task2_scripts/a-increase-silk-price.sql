INSERT INTO Current_Price
SELECT  T2.C_Code, T2.Price*1.1 as new_price, '13-DEC-2022' as today
FROM
  (SELECT  p.C_Code, Max(p.Set_Date) as Set_Date
    FROM    Current_Price p, Category c
    WHERE   p.C_Code    = c.C_Code 
        AND c.Name      = 'Silk' 
        AND c."Date"    >= '01-SEP-2020'
    GROUP BY p.C_Code) T1
JOIN    Current_Price T2
ON      T1.C_Code = T2.C_Code
AND     T1.Set_Date = T2.Set_Date;