CREATE PROCEDURE [dbo].[NumberOfOrderAndTotalAmountBySuppliers]
AS
BEGIN TRY
	SELECT
		s.[supplier_name],
		s.[supplier_contact_name],
		CASE
			WHEN s.[supplier_contact_number1] LIKE '_______' THEN CONCAT(SUBSTRING(supplier_contact_number1,1,3), '-',SUBSTRING(supplier_contact_number1,4,4)) 
			WHEN s.[supplier_contact_number1] LIKE '________' THEN CONCAT(SUBSTRING(supplier_contact_number1,1,4), '-',SUBSTRING(supplier_contact_number1,5,4))
			ELSE NULL
		END AS supplier_contact_number1,
		CASE
			WHEN s.[supplier_contact_number2] LIKE '_______' THEN CONCAT(SUBSTRING(supplier_contact_number2,1,3), '-',SUBSTRING(supplier_contact_number2,4,4)) 
	        WHEN s.[supplier_contact_number2] LIKE '________' THEN CONCAT(SUBSTRING(supplier_contact_number2,1,4), '-',SUBSTRING(supplier_contact_number2,5,4))
			ELSE NULL
		END AS supplier_contact_number2,
		COUNT(o.[order_reference]) AS total_orders,
		SUM(o.[order_total_amount]) AS order_total_amount
	FROM [dbo].[Suppliers] s
	INNER JOIN [dbo].[Orders] o ON s.[supplier_id] = o.[supplier_id]
	GROUP BY s.[supplier_name], s.[supplier_contact_name], s.[supplier_contact_number1], s.[supplier_contact_number2]
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
