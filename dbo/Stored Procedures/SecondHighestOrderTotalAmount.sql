CREATE PROCEDURE [dbo].[SecondHighestOrderTotalAmount]
AS
BEGIN TRY
	SELECT TOP 1*
	FROM
		(SELECT TOP 2
			CAST(SUBSTRING(REPLACE(o.[order_reference],'-','.'), 3, LEN(o.[order_reference]) - 2) AS NUMERIC(4,1)) AS order_reference,
			FORMAT(o.[order_date], 'MMMM dd, yyyy') AS order_date,
			s.[supplier_name],
			FORMAT(o.[order_total_amount], 'N2') AS order_total_amount,
			o.[order_status],
			[dbo].GetInvoiceReferencesForASpecificOrder(o.[order_reference]) AS invoice_references
		FROM [dbo].[Orders] o
		INNER JOIN [dbo].[Suppliers] s ON o.[supplier_id] = s.[supplier_id]
		LEFT JOIN [dbo].[Invoices] i ON o.[order_id] = i.[order_id]
		WHERE o.[order_total_amount] IS NOT NULL
		ORDER BY o.[order_total_amount] DESC) listoforders
	ORDER BY [order_total_amount] ASC
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_STATE() AS ErrorState,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH
