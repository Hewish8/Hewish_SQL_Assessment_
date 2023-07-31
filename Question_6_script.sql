CREATE PROCEDURE NUM_ORDERS_AND_TOTAL_AMOUNT
AS
BEGIN
WITH Suppliers AS(
SELECT [SUPPLIER_ID]
	  ,[SUPPLIER_NAME] AS [Supplier Name]
      ,[SUPPLIER_CONTACT_NAME] AS [Supplier Contact Name]
      ,LEFT([SUPPLIER_CONTACT_NUMBER], CHARINDEX(',', [SUPPLIER_CONTACT_NUMBER] + ',') - 1) AS [Supplier Contact No. 1]
	  ,RIGHT([SUPPLIER_CONTACT_NUMBER], CHARINDEX(',', [SUPPLIER_CONTACT_NUMBER] + ',') - 1) AS [Supplier Contact No. 2]
  FROM [dbo].[SUPPLIERS]
), Orders AS (
SELECT [SUPPLIER_ID]
	  , COUNT([ORDER_REF]) AS [Total Orders]
      ,CAST(SUM([ORDER_TOTAL_AMOUNT])AS DECIMAL(10, 2)) AS [Order Total Amount]
  FROM [dbo].[ORDERS]
  WHERE ORDER_DATE BETWEEN '2022-01-01' AND '2022-08-31'
  GROUP BY [SUPPLIER_ID]
)
SELECT [Supplier Name], [Supplier Contact Name], [Supplier Contact No. 1], [Supplier Contact No. 2], [Total Orders], [Order Total Amount]
FROM Suppliers S LEFT JOIN Orders O ON S.[SUPPLIER_ID] = O.[SUPPLIER_ID]
 END; 


