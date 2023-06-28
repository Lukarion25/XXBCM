CREATE TABLE [dbo].[Suppliers]
(
	[supplier_id]               INT IDENTITY(1,1) NOT NULL,
    [supplier_name]             VARCHAR(50),
    [supplier_contact_name]     VARCHAR(50),
    [supplier_address]          VARCHAR(250),
    [supplier_contact_number1]  VARCHAR(8),
    [supplier_contact_number2]  VARCHAR(8),
    [supplier_email]            VARCHAR(50),
    CONSTRAINT[pk_suppliers_id] PRIMARY KEY CLUSTERED ([supplier_id] ASC),
); 