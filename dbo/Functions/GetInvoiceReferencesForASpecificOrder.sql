CREATE FUNCTION [dbo].[GetInvoiceReferencesForASpecificOrder]
(
	@order_reference VARCHAR(10)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @invoice_references AS VARCHAR(MAX)= ''

	SELECT 
        @invoice_references = STUFF(
            (
                SELECT  i.[invoice_reference] + ' | ' 
                FROM [dbo].[Invoices] i
                INNER JOIN [dbo].[Orders] o ON o.[order_id] = i.[order_id]
                WHERE o.[order_reference] = @order_reference
                FOR XML PATH('')
            ), 1, 1, '') 
    FROM [dbo].[Invoices] i
    INNER JOIN [dbo].[Orders] o ON o.[order_id] = i.[order_id]
    WHERE  o.[order_reference] = @order_reference
    GROUP BY o.[order_reference];

	RETURN @invoice_references
END
