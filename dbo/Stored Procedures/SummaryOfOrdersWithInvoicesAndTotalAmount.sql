CREATE PROCEDURE [dbo].[SummaryOfOrdersWithInvoicesAndTotalAmount]
AS
BEGIN TRY
	SELECT 
		CAST(SUBSTRING(REPLACE(o.[order_reference],'-','.'), 3, LEN(o.[order_reference]) - 2) AS NUMERIC(4,1)) AS order_reference,
		FORMAT(o.[order_date], 'MMM-yyyy') AS order_period,
		STUFF((SELECT ' ' +  UPPER(LEFT(VALUE, 1)) + LOWER(SUBSTRING(VALUE, 2, LEN(VALUE))) 
		FROM STRING_SPLIT(s.[supplier_name], ' ')
		ORDER BY (SELECT NULL)
        FOR XML PATH('')), 1, 1, '') AS supplier_name,
		FORMAT(o.[order_total_amount], 'N2') AS order_total_amount,
		o.[order_status],
		i.[invoice_reference],
		SUM(i.[invoice_amount]) AS invoice_amount,
		[dbo].GetActionBasedOnInvoiceStatus(o.[order_reference],i.[invoice_reference],o.[order_status]) AS [action]
	FROM [dbo].[Orders] o
	INNER JOIN [dbo].[Suppliers] s ON o.[supplier_id] = s.[supplier_id]
	LEFT JOIN [dbo].[Invoices] i ON o.[order_id] = i.[order_id]
	GROUP BY o.[order_reference],o.[order_date],s.[supplier_name], o.[order_total_amount], o.[order_status],i.[invoice_reference]
	ORDER BY o.[order_date] DESC
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
