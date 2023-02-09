
Teradata
---------------------------------------------------
CREATE FUNCTION CountArrayElements (@Array VARCHAR(8000))
RETURNS INTEGER
BEGIN
   DECLARE @Count INTEGER
   SET @Count = 0
   DECLARE @Element VARCHAR(8000)

   WHILE CHARINDEX(',', @Array) > 0
   BEGIN
      SET @Element = SUBSTRING(@Array, 1, CHARINDEX(',', @Array) - 1)
      SET @Array = SUBSTRING(@Array, CHARINDEX(',', @Array) + 1, LEN(@Array))
      SET @Count = @Count + 1
   END

   SET @Count = @Count + 1

   RETURN @Count
END

SELECT dbo.CountArrayElements('element1,element2,element3')

SELECT dbo.CountArrayElements(column_name)
FROM database.table


--------------------------------------------
HiveQL

SELECT size(split(column_name, ','))
FROM table