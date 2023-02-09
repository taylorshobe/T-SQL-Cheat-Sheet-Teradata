
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

SELECT SIZE(SPLIT(column_name, ','))
FROM table


-- With NULLS
SELECT SIZE(
	CASE WHEN column_name IS NULL 
	THEN array() 
	ELSE SPLIT(column_name, ',') 
	END
	)
FROM table


--- Combine two arrays

SELECT CONCAT_WS(',', words, CAST(person_id AS string)) AS combined
FROM table



-- Append speaker breaks
SELECT CONCAT_WS(',' , 
                CASE WHEN ntile(2) OVER(ORDER BY pos) = 1 
		     THEN CAST(person_id AS string) 
                     WHEN ntile(2) OVER(ORDER BY pos) = 2 AND LEAD(person_id) OVER(ORDER BY pos) <> person_id 
                     THEN CAST(person_id AS string) 
                     ELSE '' 
                     END,
                     words) AS combined
FROM (
  SELECT words, person_id, ROW_NUMBER() OVER(ORDER BY 1) - 1 AS pos
  FROM table) t


-- Append speaker id's
SELECT concat_ws(',', 
                case when lead(person_id) over (order by pos) <> person_id or lead(person_id) over (order by pos) is null then cast(person_id as string) 
                     else '' 
                end, 
                words) as combined
FROM (
  SELECT words, person_id, row_number() over (order by 1) - 1 as pos
  FROM table
) t



 -- Create new array | Speaker breaks
WITH cte AS (
  SELECT person_id, row_number() over (order by 1) - 1 as pos
  FROM table
)
SELECT collect_list(pos + 1)
FROM (
  SELECT pos, lag(person_id) over (order by pos) as prev_person_id
  FROM cte
) t
WHERE person_id <> prev_person_id OR prev_person_id is null
GROUP BY person_id;



