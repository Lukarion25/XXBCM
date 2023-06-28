CREATE TABLE [dbo].[Orders]
(
	[order_id]              INT IDENTITY(1,1) NOT NULL,
    [supplier_id]           INT,
    [order_reference]       VARCHAR(10),
    [order_date]            DATE,
    [order_total_amount]    DECIMAL(10, 2),
    [order_description]     VARCHAR(250),
    [order_status]          VARCHAR(9),
    CONSTRAINT [pk_order_id] PRIMARY KEY CLUSTERED ([order_id] ASC),
    CONSTRAINT [fk_order_supplier] FOREIGN KEY ([supplier_id]) REFERENCES [dbo].[Suppliers] ([supplier_id])
);
