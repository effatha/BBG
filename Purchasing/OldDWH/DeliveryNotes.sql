;with cte_max as(
	Select ? as maxdate
	
)
SELECT DISTINCT LIPS.vbeln AS DeliveryNumber
            ,LIPS.posnr AS DeliveryPosition
            ,LIPS.VGBEL AS PONo
            ,LIPS.VGPOS AS POPosition
            ,LIPS.AUFNR AS ProductionOrderNo
            ,LIPS.vlstk AS DeliveryDistributionStatus 
            ,LIPS.BWART AS MovementCode -- dim (required as is, no text description)
            ,LIPS.MTART AS MovementType --dim (required as is, no text description)
            ,LIPS.LFART AS DeliveryType --dim (required as is, no text description)
            ,LIPS.VGTYP AS SalesDocCateg --dim (required as is, no text description)
            ,LIPS.vbtyp AS DeliverySubType --dim (required as is, no text description)
            ,LIPS.traty AS TransportType --dim (required as is, no text description)
            ,LIPS.traid AS ContainerId
            ,LIPS.LFIMG AS Quantity
            ,LIPS.MEINS AS Unit
            ,LIPS.VSTEL AS Shipping_Recvng_point
            ,LIPS.LGORT AS StorageLocation1  --dim (required as is, no text description)
            ,LIPS.PRCTR AS profitCentre 
            ,SUBSTRING(LIPS.MATNR, PATINDEX('%[^0]%',LIPS.MATNR), LEN(LIPS.MATNR)) AS ItemNo
            ,LIPS.CHARG AS Batch 
            ,LIPS.VOLEH
            ,LIPS.VOLUM AS VOLUME
            ,LIPS.MATKL AS MaterialGroup
            ,CAST(FORMAT(LIPS.erdat,'yyyyMMdd') AS INT) AS DeliveryCreationDimCalendarID
			,cast(concat(substring(LIPS.[ERZET],1,2),substring(LIPS.[ERZET],3,2),substring(LIPS.[ERZET],5,2))%1000000 AS INT) as DeliverycreationDimTimeId
            ,CAST(FORMAT(LIPS.lfdat ,'yyyyMMdd') AS INT) AS  DeliveryDimCalendarID
            ,CAST(FORMAT(LIPS.FKDAT,'yyyyMMdd') AS INT) AS   BillingDimCalendarId
            ,LIPS.LIFNR AS Vendor
            ,LIPS.inco1 AS Incoterms1
            ,LIPS.inco2 AS Incoterms
            ,LIPS.INCO2_L AS OutboundHarbour
            ,LIPS.inco3_l AS InboundHarbour             
            ,LIPS.WERKS006 AS Plant1
            ,LIPS.WERKS AS Receiving_Plant
,'DeliveryNote'	AS TransactionTypeDetail
,'unknown' AS TransactionTypeShort 
,DeletionIndicator = CAST(CASE WHEN cdpos.row_id is null THEN 0 ELSE 1 END AS NVARCHAR(1))
,'unknown' as TransportTypeDescription
,case when bf.row_id is null then 'XX' else 'C' END AS DeliveryStatusNew
FROM [CT dwh 02 Data].dbo.tSAPZ_MM_LIKP_LIPS AS LIPS with(nolock)
LEFT JOIN [CT dwh 02 Data].[dbo].[tSAPZ_MM_CDHDR_CDPOS_L] cdpos
	on  LIPS.VBELN = cdpos.OBJECTID 
    and right(cdpos.TABKEY,6) = LIPS.POSNR
    and TABNAME='LIPS' 
    and cdpos.is_current = 1
	AND cdpos.OBJECTCLAS = 'LIEFERUNG'
	and cdpos.CHNGIND = 'D'
    and cdpos.is_current = 1
LEFT JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_03_BF] BF with(nolock)
ON BF.ZZ_VBELN_IM = LIPS.VBELN
AND BF.is_current=1
AND BF.AUFNR <> ''
CROSS JOIN cte_max as cmax
WHERE 1 = 1
and LIPS.is_current=1
and 
(
	(
		(
		LIPS.valid_from > cmax.maxdate
		OR
		cdpos.valid_from > cmax.maxdate
OR
		bf.valid_from > cmax.maxdate
		)
		AND 0 = ${Loading_Type} -- Incremental Load
	)
	OR
	(
		1 = ${Loading_Type}-- Full Load
	)
)
