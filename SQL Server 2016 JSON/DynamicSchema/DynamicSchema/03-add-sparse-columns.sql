------------------------------------------------------------------------
-- Author:			Davide Mauri 
-- Credits:			-
-- Copyright:		Attribution-NonCommercial-ShareAlike 2.5
-- Tab/indent size:	4
------------------------------------------------------------------------
USE DynamicSchema
GO

DECLARE C CURSOR FAST_FORWARD
FOR
SELECT 
	cmd = N'ALTER TABLE products_custom_data_sparse ADD ' + QUOTENAME([name]) + ' ' + 
	CASE [datatype] 
		WHEN 'S' THEN 'VARCHAR(MAX)'
		WHEN 'N' THEN 'NUMERIC(38,16)'
		WHEN 'D' THEN 'DATE'
		WHEN 'T' THEN 'TIME(7)'
	END + 
	' SPARSE NULL'
FROM 
	dbo.custom_attributes
;

DECLARE @cmd NVARCHAR(MAX);

OPEN C;

FETCH NEXT FROM C INTO @cmd;
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @cmd
	EXECUTE (@cmd);

	FETCH NEXT FROM C INTO @cmd;
END

CLOSE C
DEALLOCATE C
;
