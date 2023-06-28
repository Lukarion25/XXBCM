CREATE PROCEDURE [dbo].[MigrateData]
AS
BEGIN TRY
    BEGIN TRANSACTION
    -- Insert data into Suppliers table
    INSERT INTO [dbo].[Suppliers] (
        [supplier_name], 
        [supplier_contact_name], 
        [supplier_address], 
        [supplier_contact_number1], 
        [supplier_contact_number2], 
        [supplier_email])
    SELECT DISTINCT
        [SUPPLIER_NAME],
        [SUPP_CONTACT_NAME],
		REPLACE(REPLACE([SUPP_ADDRESS],' - ,', ''), '-, ',''),
        REPLACE(REPLACE(SUBSTRING([SUPP_CONTACT_NUMBER], 1, CHARINDEX(',', [SUPP_CONTACT_NUMBER] + ',') - 1), ' ', ''), '.', ''),
        CASE 
			WHEN CHARINDEX('S',REPLACE(SUBSTRING([SUPP_CONTACT_NUMBER], CHARINDEX(',', [SUPP_CONTACT_NUMBER] + ',') + 1, 9), ' ', '')) > 0 THEN REPLACE(REPLACE(SUBSTRING([SUPP_CONTACT_NUMBER], CHARINDEX(',', [SUPP_CONTACT_NUMBER] + ',') + 1, 9), ' ', ''), 'S', '5')
			WHEN CHARINDEX('o',REPLACE(SUBSTRING([SUPP_CONTACT_NUMBER], CHARINDEX(',', [SUPP_CONTACT_NUMBER] + ',') + 1, 9), ' ', '')) > 0 THEN REPLACE(REPLACE(SUBSTRING([SUPP_CONTACT_NUMBER], CHARINDEX(',', [SUPP_CONTACT_NUMBER] + ',') + 1, 9), ' ', ''), 'o', '0')
			WHEN CHARINDEX('I',REPLACE(SUBSTRING([SUPP_CONTACT_NUMBER], CHARINDEX(',', [SUPP_CONTACT_NUMBER] + ',') + 1, 9), ' ', '')) > 0 THEN REPLACE(REPLACE(SUBSTRING([SUPP_CONTACT_NUMBER], CHARINDEX(',', [SUPP_CONTACT_NUMBER] + ',') + 1, 9), ' ', ''), 'I', '1')
			ELSE REPLACE(SUBSTRING([SUPP_CONTACT_NUMBER], CHARINDEX(',', [SUPP_CONTACT_NUMBER] + ',') + 1, 9), ' ', '')
		END,
        SUPP_EMAIL
    FROM [dbo].[XXBCM_ORDER_MGT];

    -- Insert data into Orders table
    INSERT INTO [dbo].[Orders] (
        [order_reference], 
        [order_date], 
        [supplier_id], 
        [order_total_amount], 
        [order_description], 
        [order_status])
    SELECT 
        [ORDER_REF], 
        CASE
	        WHEN [ORDER_DATE] LIKE '__-__-____' THEN CONVERT(DATE, [ORDER_DATE], 105)
	        WHEN [ORDER_DATE] LIKE '__-___-____' THEN CONVERT(DATE, [ORDER_DATE], 106)
        END,
        s.[supplier_id],
        CONVERT(DECIMAL(10, 2), REPLACE([ORDER_TOTAL_AMOUNT], ',', '')), 
        [ORDER_DESCRIPTION], 
        [ORDER_STATUS]
    FROM [dbo].[XXBCM_ORDER_MGT] o
    JOIN [dbo].[Suppliers] s ON o.[SUPPLIER_NAME] = s.[supplier_name];

    -- Insert data into Invoices table
    INSERT INTO [dbo].[Invoices] (
        [order_id], 
        [invoice_reference], 
        [invoice_date], 
        [invoice_status], 
        [invoice_hold_reason], 
        [invoice_amount], 
        [invoice_description])
    SELECT 
        ord.[order_id], 
        [INVOICE_REFERENCE], 
	    CASE
	        WHEN [INVOICE_DATE] LIKE '__-__-____' THEN CONVERT(DATE, [INVOICE_DATE], 105)
	        WHEN [INVOICE_DATE] LIKE '__-___-____' THEN CONVERT(DATE, [INVOICE_DATE], 106)
        END,
        [INVOICE_STATUS], 
        [INVOICE_HOLD_REASON],
	    CASE
		    WHEN CHARINDEX('o', [INVOICE_AMOUNT]) > 0 THEN CONVERT(DECIMAL(10, 2), REPLACE(REPLACE([INVOICE_AMOUNT], ',', ''), 'o', '0'))
		    WHEN CHARINDEX('I', [INVOICE_AMOUNT]) > 0 THEN CONVERT(DECIMAL(10, 2), REPLACE(REPLACE([INVOICE_AMOUNT], ',', ''), 'I', '1'))
		    WHEN CHARINDEX('S', [INVOICE_AMOUNT]) > 0 THEN CONVERT(DECIMAL(10, 2), REPLACE(REPLACE([INVOICE_AMOUNT], ',', ''), 'S', '5'))
		ELSE  CONVERT(DECIMAL(10, 2), REPLACE([INVOICE_AMOUNT], ',', ''))
	    END,
        [INVOICE_DESCRIPTION]
    FROM [dbo].[XXBCM_ORDER_MGT] o
    JOIN [dbo].[Orders] ord ON o.[ORDER_REF] = ord.[order_reference] AND O.[ORDER_DESCRIPTION] = ord.[order_description]
    WHERE o.[INVOICE_REFERENCE] IS NOT NULL
    COMMIT TRANSACTION
END TRY

BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_STATE() AS ErrorState,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;

    ROLLBACK TRANSACTION
END CATCH
