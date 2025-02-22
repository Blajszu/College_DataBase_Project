-- Usuwanie kluczy obcych
DECLARE @sql NVARCHAR(MAX);
DECLARE @schema NVARCHAR(128);
DECLARE @table NVARCHAR(128);
DECLARE @constraint NVARCHAR(128);

DECLARE foreignKeyCursor CURSOR FOR
SELECT 
    SCHEMA_NAME(schema_id),
    OBJECT_NAME(parent_object_id),
    name
FROM sys.foreign_keys;

OPEN foreignKeyCursor;
FETCH NEXT FROM foreignKeyCursor INTO @schema, @table, @constraint;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'ALTER TABLE ' + QUOTENAME(@schema) + '.' + QUOTENAME(@table) + 
               ' DROP CONSTRAINT ' + QUOTENAME(@constraint) + ';';
    PRINT @sql;
    EXEC sp_executesql @sql;

    FETCH NEXT FROM foreignKeyCursor INTO @schema, @table, @constraint;
END;

CLOSE foreignKeyCursor;
DEALLOCATE foreignKeyCursor;

-- Usuwanie kluczy głównych
DECLARE primaryKeyCursor CURSOR FOR
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE CONSTRAINT_TYPE = 'PRIMARY KEY';

OPEN primaryKeyCursor;
FETCH NEXT FROM primaryKeyCursor INTO @schema, @table, @constraint;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'ALTER TABLE ' + QUOTENAME(@schema) + '.' + QUOTENAME(@table) + 
               ' DROP CONSTRAINT ' + QUOTENAME(@constraint) + ';';
    PRINT @sql;
    EXEC sp_executesql @sql;

    FETCH NEXT FROM primaryKeyCursor INTO @schema, @table, @constraint;
END;

CLOSE primaryKeyCursor;
DEALLOCATE primaryKeyCursor;

-- Usuwanie tabel
DECLARE tableCursor CURSOR FOR
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

OPEN tableCursor;
FETCH NEXT FROM tableCursor INTO @schema, @table;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'DROP TABLE ' + QUOTENAME(@schema) + '.' + QUOTENAME(@table) + ';';
    PRINT @sql;
    EXEC sp_executesql @sql;

    FETCH NEXT FROM tableCursor INTO @schema, @table;
END;

CLOSE tableCursor;
DEALLOCATE tableCursor;