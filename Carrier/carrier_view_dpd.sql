----/****** Script for SelectTopNRows command from SSMS  ******/
ALTER VIEW PL.PL_V_CARRIER_COSTS_DPD
AS

with cte_min_invoice as (
	SELECT [CD_PARCEL_NO], CD_INVOICE_NO, rank() over (partition by [CD_PARCEL_NO] order by [D_INVOICE_DATE] asc) first_invoice_rank
	FROM [L1].[L1_FACT_A_CARRIER_PARCEL_COSTS]
	where 1=1
	AND [T_CARRIER] = 'DPD'
	--AND [CD_PARCEL_NO] in('01475110884661')

),
cte_subsequent_invoices as (

	SELECT other.[CD_PARCEL_NO], SUM(other.[AMT_TOTAL_COST])[AMT_OTHER_CHARGES], STRING_AGG(other.CD_INVOICE_NO, ', ')T_OTHER_CHARGES_INVOICE,
	MAX(other.[D_INVOICE_DATE]) D_LAST_INVOICE 
	FROM [L1].[L1_FACT_A_CARRIER_PARCEL_COSTS] other
	INNER JOIN cte_min_invoice main_invoice
		on main_invoice.[CD_PARCEL_NO] = other.[CD_PARCEL_NO]
		and main_invoice.CD_INVOICE_NO = other.CD_INVOICE_NO
		and main_invoice.first_invoice_rank>1
	where 1=1
	AND other.[T_CARRIER] = 'DPD'
	--AND other.[CD_PARCEL_NO] in('01475110884661')
	--AND  CD_INVOICE_NO NOT IN ('273001591190')
	GROUP BY other.[CD_PARCEL_NO]
)
--SELECT DISTINCT CD_INVOICE_NO FROM cte_min_invoice where first_invoice_rank= 1 
--select * from cte_subsequent_invoices

SELECT 
	Carrier = invoices.[T_CARRIER]
    ,InvoiceDate = invoices.[D_INVOICE_DATE]
	,InvoiceNo = invoices.CD_INVOICE_NO
    ,ParcelNo = invoices.[CD_PARCEL_NO]
    ,Currency = invoices.[CD_CURRENCY]
	,[CustomerOrder]
	,ProcessId = salesorder.CD_DOCUMENT_NO
	,ProcessIdPosition = salesorder.CD_DOCUMENT_LINE
    ,DeliveryCountry = invoices.[CD_COUNTRY_DELIVERY]
    ,ShippingDate = ShipTime
	,InvoiceTotalCost = [AMT_TOTAL_COST]
	,NumberParcels = Count(*) over (partition by invoices.CD_INVOICE_NO,invoices.[CD_PARCEL_NO])
	,InvoiceParcelCost = [AMT_TOTAL_COST] / Count(*) over (partition by invoices.CD_INVOICE_NO,invoices.[CD_PARCEL_NO])
	,InvoiceOtherCharges = sub.[AMT_OTHER_CHARGES] / Count(*) over (partition by invoices.CD_INVOICE_NO,invoices.[CD_PARCEL_NO])
	,InvoiceNumberOtherCharges = T_OTHER_CHARGES_INVOICE
	,InvoiceLastDate = D_LAST_INVOICE
--	,LogbaseTotalCost = [TotalCost]
--    ,LogbaseParcelCost = [ParcelCost]
	,ParcelTotalCost=  [AMT_TOTAL_COST] / Count(*) over (partition by invoices.CD_INVOICE_NO,invoices.[CD_PARCEL_NO]) + ISNULL(sub.[AMT_OTHER_CHARGES] / Count(*) over (partition by invoices.CD_INVOICE_NO,invoices.[CD_PARCEL_NO]),0)
	,NumberDaysUntilInvoice = Datediff(day,D_INVOICE_DATE,ShipTime)
--	,DiffAmountInvoiceLogbase = ISNULL([AMT_TOTAL_COST],0) - ISNULL([TotalCost],0)
	,OrderShipmentCosts  = salesorder.AMT_SHIPPING_COST_EST_EUR
	,DiffAmountInvoiceOrder = ISNULL([AMT_TOTAL_COST],0) - ISNULL(salesorder.[AMT_SHIPPING_COST_EST_EUR],0)
	,ShipmentCostsSource = salesorder.CD_SHIPMENT_COSTS_SOURCE
	,SalesItem = salesorder.ID_ITEM
	,SalesItemParent = salesorder.ID_ITEM_PARENT
	,Fulfillment = salesorder.CD_FULFILLMENT
  FROM [L1].[L1_FACT_A_CARRIER_PARCEL_COSTS] invoices
  INNER JOIN cte_min_invoice min_inv 
	on min_inv.first_invoice_rank = 1 
	and min_inv.[CD_PARCEL_NO] = invoices.[CD_PARCEL_NO]
	and min_inv.CD_INVOICE_NO = invoices.CD_INVOICE_NO
  LEFT JOIN cte_subsequent_invoices sub
	on sub.CD_PARCEL_NO = invoices.CD_PARCEL_NO
  LEFT JOIN [L0].[L0_FACT_A_PARCEL_COST] parcel
	on invoices.[CD_PARCEL_NO] = parcel.trackingno
  LEFT JOIN (select distinct INHALT,VPOBJKEY,VENUM FROM [TEST].[L0_S4HANA_VEKP])	vekp 
	on vekp.INHALT = parcel.trackingno
		and vekp.VPOBJKEY = parcel.CustomerOrder
  LEFT JOIN (select distinct * from [TEST].[L0_S4HANA_VEPO])	vepo 
	on vekp.INHALT = parcel.trackingno
		and vepo.VENUM = vekp.VENUM
		and vekp.VPOBJKEY = VBELN
  LEFT JOIN [L1].L1_FACT_A_SALES_TRANSACTION delivery
	on delivery.CD_DOCUMENT_NO = isnull(vepo.VBELN,vekp.VPOBJKEY)
	and delivery.CD_DOCUMENT_LINE = ISNULL(VEPO.POSNR,'000010')
 -- LEFT JOIN L1.L1_DIM_A_ITEM item on item.ID_ITEM = delivery.ID_ITEM
	--and CD_ITEM_CLASS NOT IN ('Kitting-Component')
  LEFT JOIN [L1].L1_FACT_A_SALES_TRANSACTION salesorder
	on salesorder.CD_DOCUMENT_NO = delivery.CD_SALES_PROCESS_ID
		and salesorder.CD_DOCUMENT_LINE = delivery.CD_SALES_PROCESS_LINE
where 1=1
--	AND invoices.[CD_PARCEL_NO] in('01475110884661')
	--AND	YEAR([D_INVOICE_DATE]) = 2024
	--AND	MONTH([D_INVOICE_DATE]) = 4
	--AND Customerorder = '3005379887'
--	AND CD_INVOICE_NO = '276001492094'
--	AND (delivery.CD_DOCUMENT_NO is null OR (delivery.CD_DOCUMENT_NO IS NOT NULL AND item.ID_ITEM IS NOT NULL))
	--AND (ISNULL(salesorder.ID_ITEM,'0') =  ISNULL(salesorder.ID_ITEM_PARENT,ISNULL(salesorder.ID_ITEM,'0')))

	------	select * from pl.pl_v_sales_transactions where documentno = '3005343937'
	--		select * from [L0].[L0_FACT_A_PARCEL_COST] parcel
	--	where 
	--trackingno = '01475110945557'








	SELECT 
	FROM [L1].[L1_FACT_A_CARRIER_PARCEL_COSTS] invoices





	--01475179013271
	--01475179013272


	;with cte_parcel_view as (
		 SELECT InvoiceNo,InvoiceDate,ParcelNo,SUM(InvoiceParcelCost)InvoiceTotalCost
		 FROM 
		 PL.PL_V_CARRIER_COSTS_DPD
		 where 1=1
			AND	YEAR(InvoiceDate) = 2024
			AND	MONTH(InvoiceDate) = 4
			AND InvoiceNo = '276001492094'
		Group by InvoiceNo,InvoiceDate,ParcelNo
		--order by InvoiceDate,InvoiceNo
	),
	cte_parcel_invoices as (
	select CD_INVOICE_NO,D_INVOICE_DATE,[CD_PARCEL_NO],sum(AMT_TOTAL_COST) AMT_TOTAL_COST
	FROM [L1].[L1_FACT_A_CARRIER_PARCEL_COSTS] invoices
	where 1=1
		AND	YEAR(D_INVOICE_DATE) = 2024
		AND	MONTH(D_INVOICE_DATE) = 4
		AND CD_INVOICE_NO = '276001492094'
	Group by CD_INVOICE_NO,D_INVOICE_DATE,[CD_PARCEL_NO]
--	order by D_INVOICE_DATE,CD_INVOICE_NO
	)

	SELECT
		*
	FROM cte_parcel_invoices inv
	left JOIN cte_parcel_view pview 
		on pview.ParcelNo = inv.[CD_PARCEL_NO]
		and pview.InvoiceNo = inv.CD_INVOICE_NO
	where
		abs(ISNULL(pview.InvoiceTotalCost,0) - ISNULL(inv.AMT_TOTAL_COST,0)) > 0

----------------------------------------------------------------------------------------------------------------------
with cte_min_invoice as (
	SELECT [CD_PARCEL_NO], CD_INVOICE_NO, rank() over (partition by [CD_PARCEL_NO] order by [D_INVOICE_DATE] asc) first_invoice_rank
	FROM [L1].[L1_FACT_A_CARRIER_PARCEL_COSTS]
	where 1=1
	AND [T_CARRIER] = 'DPD'

),
cte_subsequent_invoices as (

	SELECT other.[CD_PARCEL_NO], SUM(other.[AMT_TOTAL_COST])[AMT_OTHER_CHARGES], STRING_AGG(other.CD_INVOICE_NO, ', ')T_OTHER_CHARGES_INVOICE,
	MAX(other.[D_INVOICE_DATE]) D_LAST_INVOICE 
	FROM [L1].[L1_FACT_A_CARRIER_PARCEL_COSTS] other
	INNER JOIN cte_min_invoice main_invoice
		on main_invoice.[CD_PARCEL_NO] = other.[CD_PARCEL_NO]
		and main_invoice.CD_INVOICE_NO = other.CD_INVOICE_NO
		and main_invoice.first_invoice_rank>1
	where 1=1
	AND other.[T_CARRIER] = 'DPD'
	--AND other.[CD_PARCEL_NO] in('01475110884661')
	--AND  CD_INVOICE_NO NOT IN ('273001591190')
	GROUP BY other.[CD_PARCEL_NO]
)
--SELECT DISTINCT CD_INVOICE_NO FROM cte_min_invoice where first_invoice_rank= 1 
--select * from cte_subsequent_invoices

SELECT 
COUNT(*)
  FROM [L1].[L1_FACT_A_CARRIER_PARCEL_COSTS] invoices
  INNER JOIN cte_min_invoice min_inv 
	on min_inv.first_invoice_rank = 1 
	and min_inv.[CD_PARCEL_NO] = invoices.[CD_PARCEL_NO]
	and min_inv.CD_INVOICE_NO = invoices.CD_INVOICE_NO
  LEFT JOIN cte_subsequent_invoices sub
	on sub.CD_PARCEL_NO = invoices.CD_PARCEL_NO
  LEFT JOIN [L0].[L0_FACT_A_PARCEL_COST] parcel
	on invoices.[CD_PARCEL_NO] = parcel.trackingno
  LEFT JOIN (select distinct INHALT,VPOBJKEY,VENUM FROM [TEST].[L0_S4HANA_VEKP])	vekp 
	on vekp.INHALT = parcel.trackingno
		and vekp.VPOBJKEY = parcel.CustomerOrder
  LEFT JOIN (select distinct * from [TEST].[L0_S4HANA_VEPO])	vepo 
	on vekp.INHALT = parcel.trackingno
		and vepo.VENUM = vekp.VENUM
		and vekp.VPOBJKEY = VBELN
  LEFT JOIN [L1].L1_FACT_A_SALES_TRANSACTION delivery
	on delivery.CD_DOCUMENT_NO = isnull(vepo.VBELN,vekp.VPOBJKEY)
	and delivery.CD_DOCUMENT_LINE = ISNULL(VEPO.POSNR,'000010')
 -- LEFT JOIN L1.L1_DIM_A_ITEM item on item.ID_ITEM = delivery.ID_ITEM
	--and CD_ITEM_CLASS NOT IN ('Kitting-Component')
  LEFT JOIN [L1].L1_FACT_A_SALES_TRANSACTION salesorder
	on salesorder.CD_DOCUMENT_NO = delivery.CD_SALES_PROCESS_ID
		and salesorder.CD_DOCUMENT_LINE = delivery.CD_SALES_PROCESS_LINE
where 1=1
	AND invoices.[CD_PARCEL_NO] in('01475110884661')

-------------------------------------------------------------------------------------------------------------------------------------
select * from [TEST].[L0_S4HANA_VEKP]	where INHALT = '01475110884661'


	select 
		ParcelNo,
		Currency,
		CustomerOrder,
		ProcessID,
		ProcessIdPosition,
		DeliveryCountry,
		Fulfillment,
		InvoiceDate,
		ShippingDate,
		SalesItem,
		SalesItemParent,
		ParcelTotalCost,
		OrderShipmentCosts,
		DiffAmountInvoiceOrder
	from  PL.PL_V_CARRIER_COSTS_DPD 
	where OrderShipmentCosts > 0 and abs(DiffAmountInvoiceOrder) >1
	order by 
	DiffAmountInvoiceOrder
	desc


select *	
from  PL.PL_V_CARRIER_COSTS_DPD 
where parcelno = '01475110887474'

select * from pl.pl_v_item where itemno = 10046131
select top 10  * from pl.pl_v_sales_transactions where itemid = 32600 and transactiontypeshort in ('ZAA') order by transactiondate desc


synw-bbg-dwh-weu-dev-01-ondemand.sql.azuresynapse.net


SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://stbbgdwhweudev01.dfs.core.windows.net/presentation-layer/presentation-layer/PL_V_ITEM/',
        FORMAT = 'DELTA'
    ) AS [result]
