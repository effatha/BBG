CREATE TABLE TEST.L0_MI_PURCH_FX_RATES(
	CurrencyCode				VARCHAR(10) ,
	FX_rates				    DECIMAL(19,4),
	ValidFrom					Date,
	ValidTo						date,
	[LOAD_TIMESTAMP] [DATETIME] NULL

	)

	insert into TEST.L0_MI_PURCH_FX_RATES(CurrencyCode,FX_rates,ValidFrom,ValidTo,[LOAD_TIMESTAMP])
	SELECT 'USD','1.07','2021-01-01','2199-01-01', '2025-08-13'
	union SELECT 'CNY','7.79','2021-01-01','2199-01-01', '2025-08-13' 
		union SELECT 'GBP','0.85','2021-01-01','2199-01-01', '2025-08-13' 
				union SELECT 'EUR','1','2021-01-01','2199-01-01', '2025-08-13' 