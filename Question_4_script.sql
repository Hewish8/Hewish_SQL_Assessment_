CREATE PROCEDURE ORDERS_SUMMARY
AS
BEGIN
WITH CTE AS (
    SELECT 
        CAST(SUBSTRING([ORDER_REF], 3, CASE WHEN CHARINDEX('-', [ORDER_REF]) > 0 THEN CHARINDEX('-', [ORDER_REF]) - 3 ELSE LEN([ORDER_REF]) - 2 END) AS INT) AS [Order Reference],
        UPPER(FORMAT(CONVERT(DATE, [ORDER_DATE], 103), 'MMM-yyyy')) AS [Order Period],
        UPPER(SUBSTRING(S.[SUPPLIER_NAME], 1, 1)) +
            LOWER(SUBSTRING(S.[SUPPLIER_NAME], 2, CHARINDEX(' ', S.[SUPPLIER_NAME] + ' ', 2) - 2)) +
            ' ' +
            UPPER(SUBSTRING(S.[SUPPLIER_NAME], CHARINDEX(' ', S.[SUPPLIER_NAME] + ' ', 2) + 1, 1)) +
            LOWER(SUBSTRING(S.[SUPPLIER_NAME], CHARINDEX(' ', S.[SUPPLIER_NAME] + ' ', 2) + 2, LEN(S.[SUPPLIER_NAME]))) AS [Supplier Name],
        CAST([ORDER_TOTAL_AMOUNT] AS DECIMAL(10, 2)) AS  [Order Total Amount],
        [ORDER_STATUS] AS [Order Status],
        I.[INVOICE_REF] AS [Invoice Reference],
        CAST([INVOICE_AMOUNT] AS DECIMAL(10, 2)) AS  [Invoice Total Amount],
		INVOICE_STATUS
    FROM [dbo].[ORDERS] O
    LEFT JOIN [dbo].[INVOICES] I ON O.[ORDER_ID] = I.[ORDER_ID]
    LEFT JOIN [dbo].[SUPPLIERS] S ON O.[SUPPLIER_ID] = S.[SUPPLIER_ID]
)

SELECT 
    [Order Reference],
    [Order Period],
    [Supplier Name],
    SUM([Order Total Amount]) AS [Order Total Amount],
    [Order Status],
    [Invoice Reference],
    SUM([Invoice Total Amount]) AS [Invoice Total Amount],
	CASE WHEN COUNT(*) = SUM(CASE WHEN INVOICE_STATUS = 'Paid' THEN 1 ELSE 0 END) THEN 'OK'
		 WHEN INVOICE_STATUS = 'Pending' THEN 'To follow up'
		 WHEN INVOICE_STATUS IS NULL THEN 'To verify'
		END AS Action
FROM CTE
GROUP BY [Order Reference], [Order Period], [Supplier Name], [Order Status], [Invoice Reference],INVOICE_STATUS
ORDER BY [Order Period] DESC;
END;