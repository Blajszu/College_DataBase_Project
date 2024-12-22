-- Usuwanie kluczy obcych
DECLARE @sql NVARCHAR(MAX) = (
    SELECT 
        STRING_AGG(
            'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + 
            QUOTENAME(OBJECT_NAME(parent_object_id)) +
            ' DROP CONSTRAINT ' + QUOTENAME(name) + ';',
            CHAR(10)
        )
    FROM sys.foreign_keys
);

-- Wykonanie skryptu usuwającego klucze obce
IF @sql IS NOT NULL
    EXEC sp_executesql @sql;

-- Usuwanie kluczy głównych
SET @sql = (
    SELECT 
        STRING_AGG(
            'ALTER TABLE ' + QUOTENAME(TABLE_SCHEMA) + '.' + 
            QUOTENAME(TABLE_NAME) +
            ' DROP CONSTRAINT ' + QUOTENAME(CONSTRAINT_NAME) + ';',
            CHAR(10)
        )
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_TYPE = 'PRIMARY KEY'
);

-- Wykonanie skryptu usuwającego klucze główne
IF @sql IS NOT NULL
    EXEC sp_executesql @sql;

-- Usuwanie tabel
SET @sql = (
    SELECT 
        STRING_AGG(
            'DROP TABLE ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) + ';',
            CHAR(10)
        )
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE'
);

-- Wykonanie skryptu usuwającego tabele
IF @sql IS NOT NULL
    EXEC sp_executesql @sql;
