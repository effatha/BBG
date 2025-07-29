/******************************
** Name: Gets the SAP purchasing data 
** Auth: [Helder Barbosa]
** Date: 01/03/2025
**************************
** Change History
**************************
** PR   Date		 Author			Description 
** --   --------	 -------		------------------------------------
** 1	01/03/2025	Hbarbosa	     Initial Script
*/
 

 --TEST.WR_TX_L0_S4HANA_LIKP_LIPS_L1_FACT_A_DELIVERY_NOTES

ALTER PROCEDURE TEST.WR_TX_L0_S4HANA_LIKP_LIPS_L1_FACT_A_DELIVERY_NOTES
AS
BEGIN

TRUNCATE TABLE TEST.L1_FACT_A_INBOUND_DELIVERY_NOTES

;WITH CTE_GR_QTY AS (
    
	SELECT 
		CD_DELIVERY_DOCUMENT_NO = bf.ZZ_VBELN_IM,
		CD_DELIVERY_DOCUMENT_LINE = bf.ZZ_VBELP_IM,
		VL_GR_QTY = SUM(ISNULL(MENGE,0) * ISNULL(VL_MULTIPLIER,0))
    FROM L0.L0_S4HANA_2LIS_03_BF bf
	INNER JOIN TEST.[L0_MI_STOCK_INDICATOR] stck
		ON stck.BWART = bf.BWART 
			AND bf.SHKZG = stck.SHKZG
    WHERE  1=1
	--MBLNR = '5105661774'
    --EBELN = '4501020135' and EBELP = 190
	GROUP BY bf.ZZ_VBELN_IM, bf.ZZ_VBELP_IM
	

)


INSERT INTO TEST.L1_FACT_A_INBOUND_DELIVERY_NOTES (

CD_DELIVERY_NO
,CD_DELIVERY_LINE 		
,CD_PURCHASING_DOCUMENT_NO 
,CD_PURCHASING_DOCUMENT_LINE	
,CD_PRODUCTION_ORDER_NO 		
,CD_DELIVERY_STATUS			
,CD_STOCK_MOVEMENT_TYPE		
,CD_MOVEMENT_TYPE 				
,CD_DELIVERY_TYPE 				
,CD_PURCHASING_DOCUMENT_TYPE 	
,CD_SUB_DELIVERY_TYPE 		
,CD_TRANSPORT_TYPE 			
,CD_CONTAINER_ID 		
,VL_ITEM_QUANTITY			
,CD_UNIT 				
,CD_SHIPPING_RECEIVING_POINT
,CD_STORAGE_LOCATION			
,CD_PROFIT_CENTRE  				
,CD_ITEM 
,CD_BATCH 						
,CD_VOLUME_UNIT 
,CD_VOLUME 
,CD_MATERIAL_GROUP 				
,D_CREATED 					
,D_DELIVERY 					
,D_POSTING 						
,CD_VENDOR 					
,CD_INCOTERMS_L1 				
,CD_INCOTERMS_L2 				
,CD_OUTBOUND_HARBOUR 		
,CD_INBOUND_HARBOUR 
,DT_CREATED
,CD_STORAGE_LOCATION_1 
,CD_INBOUND_STORAGE_LOCATION 
,CD_TYPE 
,CD_GR_STATUS
,FL_DELETETION 
,VL_GR_QUANTITY_RECEIVED
,DT_DWH_CREATED
,DT_DWH_UPDATED
)

SELECT 

	CD_DELIVERY_NO = a.vbeln					-- DeliveryNumber
	,CD_DELIVERY_LINE = a.posnr					-- DeliveryPosition
	,CD_PURCHASING_DOCUMENT_NO = VGBEL			-- PONo
	,CD_PURCHASING_DOCUMENT_LINE = VGPOS		-- POPosition
	,CD_PRODUCTION_ORDER_NO = AUFNR				-- ProductionOrderNo
	,CD_DELIVERY_STATUS = vlstk					-- DeliveryDistributionStatus
	,CD_STOCK_MOVEMENT_TYPE = BWART				-- MovementCode
	,CD_MOVEMENT_TYPE = MTART					-- MovementType
	,CD_DELIVERY_TYPE = LFART					-- DeliveryType
	,CD_PURCHASING_DOCUMENT_TYPE = VGTYP		-- SalesDocCateg
	,CD_SUB_DELIVERY_TYPE = vbtyp				-- DeliverySubType
	,CD_TRANSPORT_TYPE = traty					-- TransportType
	,CD_CONTAINER_ID = traid					-- ContainerId
	,VL_ITEM_QUANTITY = LFIMG					-- Quantity
	,CD_UNIT = MEINS							-- Unit
	,CD_SHIPPING_RECEIVING_POINT = VSTEL		-- Shipping_Recvng_point
	,CD_STORAGE_LOCATION = LGORT				-- StorageLocation1
	,CD_PROFIT_CENTRE  = PRCTR					-- profitCentre
	,CD_ITEM = cast(MATNR AS INT)				-- DeliveryItemNo
	,CD_BATCH = CHARG							-- Batch
	,CD_VOLUME_UNIT = VOLEH
	,CD_VOLUME = VOLUM
	,CD_MATERIAL_GROUP = MATKL					-- MaterialGroup
	,DT_CREATED = erdat							-- DeliveryCreationDate
	,D_DELIVERY = lfdat							-- DeliveryDate
	,D_POSTING = FKDAT							-- BillingDate
	,CD_VENDOR = LIFNR							-- Vendor
	,CD_INCOTERMS_L1 = inco1					-- Incoterms1
	,CD_INCOTERMS_L2 = inco2					-- Incoterms
	,CD_OUTBOUND_HARBOUR = INCO2_L				-- OutboundHarbour
	,CD_INBOUND_HARBOUR = inco3_l				-- InboundHarbour
	,DT_CREATED = cast(concat([ERDAT],' ',substring([ERZET],1,2),':',substring([ERZET],3,2),':',substring([ERZET],5,2)) as datetime2) 
	,CD_STORAGE_LOCATION_1 = WERKS006
	,CD_INBOUND_STORAGE_LOCATION = WERKS
	,CD_TYPE = A.PSTYV 
	,CD_GR_STATUS = A.WBSTK 
	,FL_DELETETION = CASE WHEN deletionind.DeletionIndicator IS NULL THEN 'N' ELSE 'Y' END
	,VL_GR_QUANTITY_RECEIVED = gr.VL_GR_QTY
	--,
	,DT_DWH_CREATED = getdate()
	,DT_DWH_UPDATED= getdate()
FROM  [L0].[L0_S4HANA_Z_MM_LIKP_LIPS] AS A 
LEFT JOIN (
	SELECT cdpos.OBJECTID VBELN, RIGHT(cdpos.TABKEY,6) POSNR, 1 DeletionIndicator
	FROM TEST.[L0_S4HANA_Z_MM_CDHDR_CDPOS_L] AS cdpos WITH (NOLOCK)
	WHERE cdpos.TABNAME='LIPS'
	AND cdpos.CHNGIND = 'D'
	AND cdpos.OBJECTCLAS = 'Lieferung'
) AS deletionind
	ON a.VBELN = deletionind.VBELN AND a.POSNR = deletionind.POSNR
LEFT JOIN CTE_GR_QTY gr 
	ON 
		gr.CD_DELIVERY_DOCUMENT_NO = a.vbeln
		AND gr.CD_DELIVERY_DOCUMENT_LINE = a.POSNR
		
where 1=1

END



select count(*)  FROM  [TEST].[L0_S4HANA_Z_MM_LIKP_LIPS] AS A 
select count(*)  FROM  [L0].[L0_S4HANA_Z_MM_LIKP_LIPS] AS A 

--14.496.590