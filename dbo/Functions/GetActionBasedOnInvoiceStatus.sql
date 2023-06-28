CREATE FUNCTION [dbo].[GetActionBasedOnInvoiceStatus](@order_reference VARCHAR(10), @invoice_reference VARCHAR(15), @order_status VARCHAR(9))
RETURNS VARCHAR(12)
AS
BEGIN
	DECLARE @action AS VARCHAR(12)= ''

	IF(@order_reference IS NULL OR @invoice_reference IS NULL OR @order_status IS NULL)
		BEGIN
			SET @action = 'To verify'
		END
	ELSE
		BEGIN
		SET @action =
				CASE
					WHEN EXISTS (
						SELECT 
							o.[order_reference],
							o.[order_status],
							i.[invoice_reference],
							i.[invoice_status]
						FROM [dbo].[Orders] o
						INNER JOIN [dbo].[Suppliers] s ON o.[supplier_id] = s.[supplier_id]
						LEFT JOIN [dbo].[Invoices] i ON o.[order_id] = i.[order_id]
						WHERE o.[order_reference] = @order_reference AND o.[order_status] = @order_status AND i.[invoice_reference] = @invoice_reference AND invoice_status = 'Pending'
								) THEN 'To follow up'
					WHEN EXISTS (
					SELECT 
							o.[order_reference],
							o.[order_status],
							i.[invoice_reference],
							i.[invoice_status]
						FROM [dbo].[Orders] o
						INNER JOIN [dbo].[Suppliers] s ON o.[supplier_id] = s.[supplier_id]
						LEFT JOIN [dbo].[Invoices] i ON o.[order_id] = i.[order_id]
						WHERE o.[order_reference] = @order_reference AND o.[order_status] = @order_status AND i.[invoice_reference] = @invoice_reference AND invoice_status IS NULL
								) THEN 'To verify'
					ELSE 'OK'
				END
		END
	RETURN @action
END
