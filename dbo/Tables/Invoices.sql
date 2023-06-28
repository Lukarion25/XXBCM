CREATE TABLE [dbo].[Invoices]
(
	[invoice_id]            INT IDENTITY(1,1) NOT NULL,
    [order_id]              INT,
    [invoice_reference]     VARCHAR(15),
    [invoice_date]          DATE,
    [invoice_status]        VARCHAR(8),
    [invoice_hold_reason]   VARCHAR(250),
    [invoice_amount]        DECIMAL(10, 2),
    [invoice_description]   VARCHAR(250),
    CONSTRAINT [pk_invoice_id] PRIMARY KEY CLUSTERED ([invoice_id] ASC),
    CONSTRAINT [fk_invoice_order] FOREIGN KEY ([order_id]) REFERENCES [dbo].[Orders] ([order_id])
);
