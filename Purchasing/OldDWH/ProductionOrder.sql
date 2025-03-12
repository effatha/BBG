;with cte_max as(
	Select ? as maxdate
	
)
SELECT 
	DocumentNo = cast(MATNR.AUFNR as nvarchar(20)) --- in ticket -- ProductionOrderNo
   ,PositionId = cast(MATNR.POSNR as nvarchar(10))   ---- in ticket: ProductionOrderItemNo
	,DeliveryNo = LP.VBELN   
   ,DeliveryItemNo = LP.POSNR
   ,CompanyCode = MATNR.BUKRS
	,PurchaseOrderNo = cast(MATNR.ZZ_EBELN as nvarchar(20))
   ,PurchaseOrderLineItemNo = cast(MATNR.ZZ_EBELP as nvarchar(10))
   --,BasicFinishDate = CAST(FORMAT(MATNR.GLTRP,'yyyyMMdd') AS INT)	
   ,ProductionOrderItemNo  = SUBSTRING(MATNR.MATNR, PATINDEX('%[^0]%', MATNR.MATNR), LEN(MATNR.MATNR)) ---- ItemNo for SAP lookup
   ,POReferenceNo = MATNR.ZZ_CY_SEQNR -- instead of CY_SEQNR
   ,ProductionOrderCreationDate = CAST(FORMAT(MATNR.ERDAT,'yyyyMMdd') AS INT)	
   ,ProductionOrderCnfrdFnshDate = CAST(FORMAT(MATNR.GETRI,'yyyyMMdd') AS INT)	
   ,Plant = MATNR.WERKS
   ,ProductionOrderSchFnshDate = CAST(FORMAT(MATNR.GLTRS,'yyyyMMdd') AS INT)	
   ,ProductionOrderActStartDate = CAST(FORMAT(MATNR.GSTRI,'yyyyMMdd') AS INT)	
   ,ProductionOrderBasicStrtDate = CAST(FORMAT(MATNR.GSTRP,'yyyyMMdd') AS INT)	
   ,ProductionOrderSchStrtDate = CAST(FORMAT(MATNR.GSTRS,'yyyyMMdd') AS INT)	
   ,ProductionOrderActDlvDate = CAST(FORMAT(MATNR.LTRMI,'yyyyMMdd') AS INT)	
   ,ProductionOrderPlnDlvDate = CAST(FORMAT(MATNR.LTRMP,'yyyyMMdd') AS INT)	
   ,ProductionOrderUnitofMeasure = MATNR.MEINS
   ,ProductionOrderScrapQty = Cast(PAMNG as decimal(18,4))
   ,ProductionOrderTotQtyPlan = Cast(PGMNG as decimal(18,4))
   ,ProductionOrderItemScrapQty = Cast(PSAMG as decimal(18,4))
   ,ProductionOrderItemQty =Cast(PSMNG as decimal(18,4))
   ,ProductionOrderSalesOrder = KDAUF 
   ,Unit = DFZEH
   ,GRQty = cast(WEMNG as decimal(18,4))
   ,DeliveryCreationDate  = CAST(FORMAT(LP.ERDAT,'yyyyMMdd') AS INT)	
   ,TransactionTypeShort = 'SPO'
   ,TransactionTypeDetail = 'ProductionOrder'
   ,ProductionOrderBasicFnshDate = CAST(FORMAT(MATNR.GLTRP ,'yyyyMMdd') AS INT)	
   ,Processid = cast(MATNR.ZZ_EBELN as nvarchar(20))
from [CT dwh 02 Data].dbo.[tSAP2LIS_04_P_MATNR] MATNR
LEFT JOIN [CT dwh 02 Data].dbo.tSAPZ_MM_LIKP_LIPS LP 
	ON LP.AUFNR = MATNR.AUFNR
		AND LP.POSNR_PP = MATNR.POSNR and LP.is_current = 1 and LP.is_deleted = 0
CROSS JOIN cte_max as cmax
where 
	MATNR.is_current = 1 and MATNR.is_deleted = 0

AND
	(	
	(
			(		MATNR.valid_from				> cmax.maxdate
				OR	LP.valid_from			> cmax.maxdate
			)
			AND 0 = ${Loading_Type} -- Incremental Load
		)
		OR 
		(
			1 = ${Loading_Type} -- Full Load
		)
)
