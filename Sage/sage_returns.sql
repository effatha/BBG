/*****************************************
**	BERLIN  -- not used since aug 2020
******************************************/
select count(*) from [CT dwh 02 Data].returns.tret_retouren where iscurrent = 1
select max(Datum) from [CT dwh 02 Data].returns.tret_retouren where iscurrent = 1
;with reg_dates as(

	select rechnungsnummer,Mandant, max(Datum)Datum
	from  [CT dwh 02 Data].returns.tret_rma_kunde with(nolock) where iscurrent =1 and isdeletedflag = 0
	Group by rechnungsnummer,Mandant

)
SELECT
	DimTransactionDateKey = cast(format(ret.Datum,'yyyyMMdd') as int)
,	DimTransactionTimeKey = case when format(ret.Datum,'HHmmss') = '000000' then 240000 else cast(format(ret.Datum,'HHmmss') as int) end
,   ReturnNumber = cast(ret.retournr  as nvarchar(50))
,   ReturnCode1= ret.ReturnCode1
,   ReturnCode2  = ret.ReturnCode2
,   Creator =  ret.Ersteller
,   ReturnReason = ret.Ruecksendegrund
,   ComponentTEC =  cast(ret.ComponentTEC as nvarchar(250))
,   IssueTEC = ret.IssueTEC
,   ReturnSite = 'Berlin'
,   Companyid =  ret.Mandant
,   ItemNo =  cast(ret.Artikelnr as nvarchar(50))
,   ReturnError =  Fehler
,   ReturnErrorInfo =  fehlerinfo
,   WorkshopStatus = cast(isnull(Werkstattstatus,'unknown') as nvarchar(50))
,   WorkshopInfo =  Werkstattinfos
,   Class = Cast(Klassen as nvarchar(10))
,   InvoiceNumber =  ret.re_nr
,	IsDeleted =  isnull(IsDeleted,0)
,	ReturnSource =  NULL 
,	AccountingTransaction = Buchung
,	StoragePlace = Lagerplatz
,	FirstScan =	FirstScan
,	CustomerFeedback =	Art_Kdinfo
,	SerialNumber = [Serial]
,	RMA =	RMA
,	Editor =	Editor
,	ReturnQuantity =	cast(1  as decimal(15,3))
, 	FBACustomerReturnID = 0 
--,   RegistrationDate = rma.datum
,   DimRegistrationDateId = isnull(cast(format(rma.datum,'yyyyMMdd') as int),0)
,	MEK_Hedging =   round(isnull(ham1.MEK_Hedging,0) *  isnull(MAufschlag.Aufschlag,1),2)
,	MEK_Plan =  round(isnull(ham1.MEK_Plan_YoY,0) *  isnull(MAufschlag.Aufschlag,1),2)
,	MEK_WE =   round(isnull(ham1.MEK_WE,0) *  isnull(MAufschlag.Aufschlag,1),2)

FROM      [CT dwh 02 Data].returns.tret_retouren ret with(nolock)
INNER JOIN [CT dwh 02 Data].dbo.tErpKHKArtikel AS art WITH (NOLOCK) on art.Artikelnummer = ret.Artikelnr and art.mandant = ret.mandant
LEFT JOIN reg_dates rma 
	on rma.rechnungsnummer = ret.re_nr
	AND rma.mandant = ret.Mandant
LEFT JOIN [CT dwh 02 Data].[dbo].[tDwhHistorischerArtikelMEK] AS ham1 WITH(NOLOCK)
			ON ham1.[Artikelnummer] = '10' + RIGHT(ret.Artikelnr,6)
			AND ret.Artikelnr LIKE '[15]%'
			AND ham1.[Datum] = CAST(ret.Datum AS DATE)
LEFT JOIN (
			SELECT 1 AS [Mandant], CAST(1 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 2 AS [Mandant], CAST(1.3 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 3 AS [Mandant], CAST(1.2 AS MONEY) AS [Aufschlag]
		) AS MAufschlag
			ON MAufschlag.[Mandant] = ret.[Mandant]
/*****************************************
**	HWS ---- NOT USED
******************************************/

select count(*) from [CT dwh 02 Data].returns.tret_HWS_retouren where iscurrent = 1
select max(Datum) from [CT dwh 02 Data].returns.tret_HWS_retouren where iscurrent = 1

;with reg_dates as(

	select rechnungsnummer,Mandant, max(Datum)Datum
	from  [CT dwh 02 Data].returns.tret_rma_kunde with(nolock) where iscurrent =1 and isdeletedflag = 0
	Group by rechnungsnummer,Mandant

)
SELECT


	DimTransactionDateKey = cast(format(ret.Datum,'yyyyMMdd') as int)
,   DimTransactionTimeKey = case when format(ret.Datum,'HHmmss') = '000000' then 240000 else cast(format(ret.Datum,'HHmmss') as int) end
,   ReturnNumber = cast(ret.retournr  as nvarchar(50))
,   ReturnCode1= ret.ReturnCode1
,   ReturnCode2  = ret.ReturnCode2
,   Creator =  ret.Ersteller
,   ReturnReason = ret.Ruecksendegrund
,   ComponentTEC =  ''
,   IssueTEC = ''
,   ReturnSite = 'Loehne'
,   Companyid =  ret.Mandant
,   ItemNo =  cast(ret.Artikelnr as nvarchar(50))
,   ReturnError =  Fehler
,   ReturnErrorInfo =  fehlerinfo
,   WorkshopStatus = 'unknown'
,   WorkshopInfo =  ''
,   Class = Cast(Klassen as nvarchar(10))
,   InvoiceNumber =  ret.re_nr
,	IsDeleted =  cast(0 as bit)
,	ReturnSource =  null 
,	AccountingTransaction = Buchung
,	StoragePlace = Lagerplatz
,	FirstScan =	cast(0 as bit)
,	CustomerFeedback =	Art_Kdinfo
,	SerialNumber = [Serial]
,	RMA =	RMA
,	Editor =	Editor
,	ReturnQuantity =	cast(1  as decimal(15,3))
, 	FBACustomerReturnID = 0 
--,   RegistrationDate = rma.datum
,   DimRegistrationDateId = isnull(cast(format(rma.datum,'yyyyMMdd') as int),0)
,	MEK_Hedging =   round(isnull(ham1.MEK_Hedging,0) *  isnull(MAufschlag.Aufschlag,1),2)
,	MEK_Plan =  round(isnull(ham1.MEK_Plan_YoY,0) *  isnull(MAufschlag.Aufschlag,1),2)
,	MEK_WE =   round(isnull(ham1.MEK_WE,0) *  isnull(MAufschlag.Aufschlag,1),2)



FROM      [CT dwh 02 Data].returns.tret_HWS_retouren ret with(nolock)
INNER JOIN [CT dwh 02 Data].dbo.tErpKHKArtikel AS art WITH (NOLOCK) on art.Artikelnummer = ret.Artikelnr and art.mandant = ret.mandant
LEFT JOIN reg_dates rma 
	on rma.rechnungsnummer = ret.re_nr
	AND rma.mandant = ret.Mandant
LEFT JOIN [CT dwh 02 Data].[dbo].[tDwhHistorischerArtikelMEK] AS ham1 WITH(NOLOCK)
			ON ham1.[Artikelnummer] = '10' + RIGHT(ret.Artikelnr,6)
			AND ret.Artikelnr LIKE '[15]%'
			AND ham1.[Datum] = CAST(ret.Datum AS DATE)
LEFT JOIN (
			SELECT 1 AS [Mandant], CAST(1 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 2 AS [Mandant], CAST(1.3 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 3 AS [Mandant], CAST(1.2 AS MONEY) AS [Aufschlag]
		) AS MAufschlag
			ON MAufschlag.[Mandant] = ret.[Mandant]
WHERE  1 = 1
AND
	(
		(ret.ValidFrom >= ? AND 1=${Loading_Type})
			OR
		( 0=${Loading_Type})
		--(ret.Datum between  '${full_start_date}' and '${full_end_date}' AND 0=${Loading_Type})

)

and IsCurrent = 1   AND IsdeletedFlag = 0

/*****************************************
**	Hoppengarten --- last date of june 23
******************************************/

select count(*) from [CT dwh 02 Data].returns.tret_HG_retouren where iscurrent = 1
select max(Datum) from [CT dwh 02 Data].returns.tret_HG_retouren where iscurrent = 1


;with reg_dates as(

	select rechnungsnummer,Mandant, max(Datum)Datum
	from  [CT dwh 02 Data].returns.tret_rma_kunde with(nolock) where iscurrent =1 and isdeletedflag = 0
	Group by rechnungsnummer,Mandant

)
SELECT 
	DimTransactionDateKey = cast(format(ret.Datum,'yyyyMMdd') as int)
,	DimTransactionTimeKey = case when format(ret.Datum,'HHmmss') = '000000' then 240000 else cast(format(ret.Datum,'HHmmss') as int) end
,   ReturnNumber = cast(ret.retournr  as nvarchar(50))
,   ReturnCode1= ret.ReturnCode1
,   ReturnCode2  = ret.ReturnCode2
,   Creator =  ret.Ersteller
,   ReturnReason = ret.Ruecksendegrund
,   ComponentTEC =  cast(ret.ComponentTEC as nvarchar(250))
,   IssueTEC = IssueTEC
,   ReturnSite = 'Hoppegarten'
,   Companyid =  ret.Mandant
,   ItemNo =  cast(ret.Artikelnr as nvarchar(50))
,   ReturnError =  Fehler
,   ReturnErrorInfo =  fehlerinfo
,   WorkshopStatus = cast(isnull(Werkstattstatus,'unknown') as nvarchar(50))
,   WorkshopInfo =  Werkstattinfos
,   Class = Cast(Klassen as nvarchar(10))
,   InvoiceNumber =  ret.re_nr
,	IsDeleted =  isnull(IsDeleted,0)
,	ReturnSource =  RetourenursprungId 
,	AccountingTransaction = Buchung
,	StoragePlace = Lagerplatz
,	FirstScan =	FirstScan
,	CustomerFeedback =	Art_Kdinfo
,	SerialNumber = [Serial]
,	RMA =	RMA
,	Editor =	Editor
,	ReturnQuantity =	cast(1  as decimal(15,3))
, 	FBACustomerReturnID = 0 
--,   RegistrationDate = rma.datum
,   DimRegistrationDateId = isnull(cast(format(rma.datum,'yyyyMMdd') as int),0)
,	MEK_Hedging =   round(isnull(ham1.MEK_Hedging,0) *  isnull(MAufschlag.Aufschlag,1),2)
,	MEK_Plan =  round(isnull(ham1.MEK_Plan_YoY,0) *  isnull(MAufschlag.Aufschlag,1),2)
,	MEK_WE =   round(isnull(ham1.MEK_WE,0) *  isnull(MAufschlag.Aufschlag,1),2)

FROM      [CT dwh 02 Data].returns.tret_HG_retouren ret with(nolock)
INNER JOIN [CT dwh 02 Data].dbo.tErpKHKArtikel AS art WITH (NOLOCK) on art.Artikelnummer = ret.Artikelnr and art.mandant = ret.mandant
LEFT JOIN reg_dates rma 
	on rma.rechnungsnummer = ret.re_nr
	AND rma.mandant = ret.Mandant
LEFT JOIN [CT dwh 02 Data].[dbo].[tDwhHistorischerArtikelMEK] AS ham1 WITH(NOLOCK)
			ON ham1.[Artikelnummer] = '10' + RIGHT(ret.Artikelnr,6)
			AND ret.Artikelnr LIKE '[15]%'
			AND ham1.[Datum] = CAST(ret.Datum AS DATE)
LEFT JOIN (
			SELECT 1 AS [Mandant], CAST(1 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 2 AS [Mandant], CAST(1.3 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 3 AS [Mandant], CAST(1.2 AS MONEY) AS [Aufschlag]
		) AS MAufschlag
			ON MAufschlag.[Mandant] = ret.[Mandant]
WHERE  1 = 1
AND
	(
		(ret.ValidFrom >= ? AND 1=${Loading_Type})
		OR
		( 0=${Loading_Type})
	--	(ret.Datum between  '${full_start_date}' and '${full_end_date}' AND 0=${Loading_Type})

)

and IsCurrent = 1   AND IsdeletedFlag = 0



/*****************************************
**	Kali -- still in use
******************************************/
select count(*) from [CT dwh 02 Data].returns.tret_Kali_retouren  where iscurrent = 1
select max(Datum) from [CT dwh 02 Data].returns.tret_Kali_retouren  where iscurrent = 1


;with reg_dates as(

	select rechnungsnummer,Mandant, max(Datum)Datum
	from  [CT dwh 02 Data].returns.tret_rma_kunde with(nolock) where iscurrent =1 and isdeletedflag = 0
	Group by rechnungsnummer,Mandant

)
SELECT 


	DimTransactionDateKey = cast(format(ret.Datum,'yyyyMMdd') as int)
,	DimTransactionTimeKey = case when format(ret.Datum,'HHmmss') = '000000' then 240000 else cast(format(ret.Datum,'HHmmss') as int) end
,   ReturnNumber = cast(ret.retournr  as nvarchar(50))
,   ReturnCode1= ret.ReturnCode1
,   ReturnCode2  = ret.ReturnCode2
,   Creator =  ret.Ersteller
,   ReturnReason = ret.Ruecksendegrund
,   ComponentTEC =  ''
,   IssueTEC = ''
,   ReturnSite = 'Kali'
,   Companyid =  ret.Mandant
,   ItemNo =  cast(ret.Artikelnr as nvarchar(50))
,   ReturnError =  Fehler
,   ReturnErrorInfo =  fehlerinfo
,   WorkshopStatus = 'unknown'
,   WorkshopInfo =  ''
,   Class = Cast(Klassen as nvarchar(10))
,   InvoiceNumber =  ret.re_nr
,	IsDeleted =  isnull(IsDeleted,0)
,	ReturnSource =  RetourenursprungId 
,	AccountingTransaction = Buchung
,	StoragePlace = Lagerplatz
,	FirstScan =	FirstScan
,	CustomerFeedback =	Art_Kdinfo
,	SerialNumber = [Serial]
,	RMA =	RMA
,	Editor =	Editor
,	ReturnQuantity =	cast(1  as decimal(15,3))
, 	FBACustomerReturnID = 0 
--,   RegistrationDate = rma.datum
,   DimRegistrationDateId = isnull(cast(format(rma.datum,'yyyyMMdd') as int),0)
,	MEK_Hedging =   round(isnull(ham1.MEK_Hedging,0) *  isnull(MAufschlag.Aufschlag,1),2)
,	MEK_Plan =  round(isnull(ham1.MEK_Plan_YoY,0) *  isnull(MAufschlag.Aufschlag,1),2)
,	MEK_WE =   round(isnull(ham1.MEK_WE,0) *  isnull(MAufschlag.Aufschlag,1),2)

FROM      [CT dwh 02 Data].returns.tret_Kali_retouren ret with(nolock)
INNER JOIN [CT dwh 02 Data].dbo.tErpKHKArtikel AS art WITH (NOLOCK) on art.Artikelnummer = ret.Artikelnr and art.mandant = ret.mandant
LEFT JOIN reg_dates rma 
	on rma.rechnungsnummer = ret.re_nr
	AND rma.mandant = ret.Mandant
LEFT JOIN [CT dwh 02 Data].[dbo].[tDwhHistorischerArtikelMEK] AS ham1 WITH(NOLOCK)
			ON ham1.[Artikelnummer] = '10' + RIGHT(ret.Artikelnr,6)
			AND ret.Artikelnr LIKE '[15]%'
			AND ham1.[Datum] = CAST(ret.Datum AS DATE)
LEFT JOIN (
			SELECT 1 AS [Mandant], CAST(1 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 2 AS [Mandant], CAST(1.3 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 3 AS [Mandant], CAST(1.2 AS MONEY) AS [Aufschlag]
		) AS MAufschlag
			ON MAufschlag.[Mandant] = ret.[Mandant]


/*****************************************
**	FBA   --- not in used since august 22
******************************************/
select count(*) from [CT dwh 02 Data].dbo.terpLBAmazonFBAcustomerReturns  
select max(ReturnDate) from [CT dwh 02 Data].dbo.terpLBAmazonFBAcustomerReturns  



;with reg_dates as(

	select rechnungsnummer,Mandant, max(Datum)Datum
	from  [CT dwh 02 Data].returns.tret_rma_kunde with(nolock) where iscurrent =1 and isdeletedflag = 0
	Group by rechnungsnummer,Mandant

)
SELECT

	DimTransactionDateKey = cast(format(ret.ReturnDate,'yyyyMMdd') as int)
,	DimTransactionTimeKey = case when format(ret.ReturnDate,'HHmmss') = '000000' then 240000 else cast(format(ret.ReturnDate,'HHmmss') as int) end
,   ReturnNumber = cast(ret.OrderID  as nvarchar(50))
,   ReturnCode1= ''
,   ReturnCode2  = ''
,   Creator = 'unknown'
,   ReturnReason = ret.Reason
,   ComponentTEC =  ''
,   IssueTEC = ''
,   ReturnSite = 'FBA'
,   Companyid =  ret.Mandant
,   ItemNo =  cast(ret.Artikelnummer as nvarchar(50))
,   ReturnError =  Disposition
,   ReturnErrorInfo =  ''
,   WorkshopStatus = 'unknown'
,   WorkshopInfo =  ''
,   Class = Cast(NULL as nvarchar(10))
,   InvoiceNumber =  bel.USER_BelegjahrBelegnummer
,	IsDeleted =  cast(0 as bit)
,	ReturnSource =  NULL 
,	AccountingTransaction = ''
,	StoragePlace = 'unknown'
,	FirstScan =	cast(0 as bit)
,	CustomerFeedback = ''	
,	SerialNumber = ''
,	RMA =	NULL
,	Editor =	'unknown'
,	ReturnQuantity =	cast(Quantity  as decimal(15,3))
, 	FBACustomerReturnID = CustomerReturnsId 
--,   RegistrationDate = rma.datum
,   DimRegistrationDateId = isnull(cast(format(rma.datum,'yyyyMMdd') as int),0)
,   LastOrderRank = ROW_NUMBER() over (partition by OrderID,ret.Artikelnummer,CustomerReturnsId order by bel.belid desc )
,	MEK_Hedging =   round(isnull(ham1.MEK_Hedging,0) * Quantity * isnull(MAufschlag.Aufschlag,1),2)
,	MEK_Plan =  round(isnull(ham1.MEK_Plan_YoY,0) * Quantity *  isnull(MAufschlag.Aufschlag,1),2)
,	MEK_WE =   round(isnull(ham1.MEK_WE,0) * Quantity *  isnull(MAufschlag.Aufschlag,1),2)
FROM      [CT dwh 02 Data].dbo.terpLBAmazonFBAcustomerReturns ret with(nolock)
INNER JOIN [CT dwh 02 Data].dbo.tErpKHKArtikel AS art WITH (NOLOCK) on art.Artikelnummer = ret.Artikelnummer and art.mandant = ret.mandant
LEFT JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelege] as bel with(nolock)
  on bel.[Referenznummer] = ret.OrderID AND  bel.Belegkennzeichen = 'VSD' and ret.Mandant = bel.Mandant
LEFT JOIN reg_dates rma 
	on rma.rechnungsnummer = bel.USER_BelegjahrBelegnummer
	AND rma.mandant = ret.Mandant
LEFT JOIN [CT dwh 02 Data].[dbo].[tDwhHistorischerArtikelMEK] AS ham1 WITH(NOLOCK)
			ON ham1.[Artikelnummer] = '10' + RIGHT(ret.Artikelnummer,6)
			AND ret.Artikelnummer LIKE '[15]%'
			AND ham1.[Datum] = CAST(ret.ReturnDate AS DATE)
LEFT JOIN (
			SELECT 1 AS [Mandant], CAST(1 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 2 AS [Mandant], CAST(1.3 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 3 AS [Mandant], CAST(1.2 AS MONEY) AS [Aufschlag]
		) AS MAufschlag
			ON MAufschlag.[Mandant] = ret.[Mandant]
