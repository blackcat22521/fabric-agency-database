CREATE OR REPLACE PROCEDURE supplier_sort_categoryCount(
    start_date  IN DATE,
    end_date    IN DATE
)
IS
BEGIN
    dbms_output.put_line('S_Code   Category Count');
    FOR ROW IN (
        SELECT S_Code, Count(C_Code) as count_cat
        FROM Category
        WHERE "Date" >= start_date AND "Date" <= end_date
        GROUP BY S_Code
        ORDER BY count_cat DESC
    ) LOOP
        dbms_output.put_line(row.S_Code || '   ' || row.count_cat);
END LOOP;

END;
/

EXEC supplier_sort_categoryCount('01-JAN-2017', '01-JAN-2023');