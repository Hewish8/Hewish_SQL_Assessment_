CREATE PROCEDURE SECOND_HIGHEST_ORDER_TOTAL_AMOUNT
AS
BEGIN
WITH G1 AS (
SELECT CAST(SUBSTRING([ORDER_REF], 3, CASE WHEN CHARINDEX('-', [ORDER_REF]) > 0 THEN CHARINDEX('-', [ORDER_REF]) - 3 ELSE LEN([ORDER_REF]) - 2 END) AS INT) AS [Order Reference]
	  ,DATENAME(month, [ORDER_DATE]) + ' ' +
		RIGHT('0' + CAST(DATEPART(day, [ORDER_DATE]) AS VARCHAR(2)), 2) + ', ' +
		CAST(DATEPART(year, [ORDER_DATE]) AS VARCHAR(4)) AS [Order Date]
      ,UPPER(S.SUPPLIER_CONTACT_NAME) AS [Supplier Name]
      ,[ORDER_TOTAL_AMOUNT]
      ,[ORDER_STATUS]
	  ,[INVOICE_REF]
  FROM [dbo].[ORDERS] O
  LEFT JOIN [dbo].[SUPPLIERS] S ON O.[SUPPLIER_ID] = S.[SUPPLIER_ID]
  GROUP BY [ORDER_REF], [ORDER_DATE], [SUPPLIER_CONTACT_NAME], [ORDER_TOTAL_AMOUNT], [ORDER_STATUS], [INVOICE_REF]
), G2 AS (
SELECT [Order Reference], [Order Date], [Supplier Name], CAST(SUM([ORDER_TOTAL_AMOUNT])AS DECIMAL(10, 2))  AS  [Order Total Amount], [ORDER_STATUS] AS [Order Status], STRING_AGG([INVOICE_REF], '|') AS [Invoice References] FROM G1
GROUP BY [Order Reference], [Order Date], [Supplier Name], [ORDER_STATUS]
)
SELECT [Order Reference], [Order Date], [Supplier Name], [Order Total Amount], [Order Status],
ISNULL([Invoice References], (SELECT TOP(1) [Invoice References] FROM G2 A WHERE A.[Invoice References] IS NOT NULL AND A.[Order Reference] = B.[Order Reference])) AS [Invoice References]
FROM G2 B
ORDER BY [Order Total Amount] DESC
OFFSET 1 ROWS FETCH NEXT 1 ROW ONLY;

END;

 