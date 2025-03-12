-- add the purchasing types
INSERT INTO [L0].[L0_MI_TRANSACTION_TYPE]
(
	[TRANSACTIONTYPESHORT],
	[TRANSACTIONTYPE],
	[SOURCETYPE],
	[LOAD_TIMESTAMP]
)

SELECT 'K','Contract','BSTYP',getdate()
UNION
SELECT 'F','Purchasing Order','BSTYP',getdate()