/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [ID_AMAZON_ORDER_DAILY]
      ,[CD_AMAZON_ORDER_DAILY]
      ,[CD_SOURCE_SYSTEM]
      ,[DT_LAST_UPDATED]
      ,[DT_PURCHASE]
      ,[D_ORDER]
      ,[NUM_ORDER_YEAR]
      ,[NUM_ORDER_MONTH]
      ,[NUM_ORDER_DAY]
      ,[NUM_ORDER_HOUR]
      ,[CD_AMAZON_ORDER]
      ,[CD_ORDER_STATUS]
      ,[CD_ORDER_CHANNEL]
      ,[T_FULFILLMENT_CHANNEL]
      ,[T_AMAZON_CHANNEL]
      ,[ID_MARKETING_ACCOUNT]
      ,[CD_MARKETPLACE]
      ,[CD_ACCOUNT]
      ,[CD_COUNTRY_INVOICE]
      ,[CD_COUNTRY]
      ,[CD_CURRENCY]
      ,[ID_ITEM]
      ,[CD_ITEM]
      ,[CD_ASIN]
      ,[CD_SKU]
      ,[CD_ITEM_STATUS]
      ,[AMT_ECOMMERCE_ITEM_TURNOVER_FC]
      ,[AMT_ECOMMERCE_ITEM_TURNOVER_DISCOUNT_FC]
      ,[AMT_ECOMMERCE_ITEM_VAT_FC]
      ,[AMT_ECOMMERCE_GROSS_ITEM_VALUE_FC]
      ,[AMT_ECOMMERCE_SHIPPING_PRICE_FC]
      ,[AMT_ECOMMERCE_ITEM_TURNOVER_EUR]
      ,[AMT_ECOMMERCE_ITEM_TURNOVER_DISCOUNT_EUR]
      ,[AMT_ECOMMERCE_ITEM_VAT_EUR]
      ,[AMT_ECOMMERCE_GROSS_ITEM_VALUE_EUR]
      ,[AMT_ECOMMERCE_SHIPPING_PRICE_EUR]
      ,[CNT_QUANTITY]
      ,[CD_ADDRESS_TYPE]
      ,[CD_SHIP_SERVICE_LEVEL]
      ,[CD_COUNTRY_DELIVERY]
      ,[T_STATE_DELIVERY]
      ,[T_CITY_DELIVERY]
      ,[CD_ZIP_DELIVERY]
      ,[DT_PURCHASE_LOCAL]
      ,[D_ORDER_LOCAL]
      ,[NUM_ORDER_YEAR_LOCAL]
      ,[NUM_ORDER_MONTH_LOCAL]
      ,[NUM_ORDER_DAY_LOCAL]
      ,[NUM_ORDER_HOUR_LOCAL]
      ,[D_EFF_FROM]
      ,[D_EFF_TO]
      ,[D_EFF_DELETED]
      ,[DT_DWH_CREATED]
      ,[DT_DWH_UPDATED]
  FROM [L1].[L1_FACT_A_AMAZON_ORDER_DAILY]
  where cd_amazon_order ='302-1691565-9469947'



  create table [Test].[AmazonReferences_audit] 
(
	reference  nvarchar(255),
	QtyOrder  int null,
	QtyRefund  int null,
	ExistsDL bit null default(0)

)




with cte_amazon_data as( 
	Select cd_amazon_order, sum(CNT_Quantity)CNT_Quantity
	FROM  [L1].[L1_FACT_A_AMAZON_ORDER_DAILY]
	where cd_item_status = 'Shipped'
		group by cd_amazon_order
)	,
, 
with cte_sap_qty as(

select 
	CD_MARKET_ORDER_ID,sum(VL_ORDER_QUANTITY)VL_ORDER_QUANTITY
from l1.[L1_FACT_A_SALES_TRANSACTION_KPI] fact
where ISNULL(T_CANCELLATION_REASON,'') = ''
group by CD_MARKET_ORDER_ID
)


Update audit set QtyOrderSap = VL_ORDER_QUANTITY
FROM [test].[AmazonReferences_audit] audit
--inner join cte_amazon_data d on audit.reference = d.cd_amazon_order
inner join cte_sap_qty sap on  audit.reference like ('%'+sap.CD_MARKET_ORDER_ID)

where 
	reference in (select c from cte_amazon_data)




		Select cd_amazon_order
		FROM  [L1].[L1_FACT_A_AMAZON_ORDER_DAILY] 
		group by cd_amazon_order
		having count(*) > 1


		select *  from [test].[AmazonReferences_audit] fact where cd_market_order_id = '303-7663907-1348302'



select 
	CustomerReference = VAITM.BSTKD,
	CNQty = VDITM.FKIMG,
	CNDocument = vditm.vbeln,
	InvoiceType =VDITM.FKART,
	SalesReference =VDITM.AUBEL,
	SalesType = vaitm.AUART
FROM [L0].[L0_S4HANA_2LIS_13_VDITM] VDITM
INNER JOIN [L0].[L0_S4HANA_Z_SD_VBFA] procid 
		ON procid.SUBSEQUENTDOCUMENT=VDITM.VBELN AND procid.SUBSEQUENTDOCUMENTITEM=VDITM.POSNR AND procid.PRECEDINGDOCUMENTCATEGORY = 'C'
INNER JOIN [L0].[L0_S4HANA_2LIS_11_VAITM] VAITM
	ON procid.[PRECEDINGDOCUMENT]=VAITM.VBELN AND procid.SUBSEQUENTDOCUMENTITEM=VAITM.POSNR --AND procid.VBTYP_V = 'C'
INNER JOIN [test].[AmazonReferences_audit] ref on ref.reference = vaitm.BSTKD

where 1=1
--vditm.fkart in ('ZG2')
and BSTKD = '028-0002363-6746763'




select 
	CustomerReference = vaitm.CD_MARKET_ORDER_ID,
	CNQty = vditm.VL_ITEM_QUANTITY,
	CNDocument = vditm.CD_DOCUMENT_NO,
	InvoiceType =vditm.CD_TYPE,
	SalesReference = vditm.CD_SALES_PROCESS_ID
FROM [L1].[L1_FACT_A_SALES_TRANSACTION] vditm
Left join [L1].[L1_FACT_A_SALES_TRANSACTION] vaitm
	on vaitm.CD_DOCUMENT_NO = vditm.CD_SALES_PROCESS_ID and vaitm.CD_DOCUMENT_LINE = vditm.CD_SALES_PROCESS_LINE
JOIN [test].[AmazonReferences_audit] ref on ref.reference = vaitm.CD_MARKET_ORDER_ID
where 1=1
and vditm.CD_TYPE in ('ZG2','G2')
and vaitm.CD_MARKET_ORDER_ID = '028-0002363-6746763'


select * FROM [L1].[L1_FACT_A_SALES_TRANSACTION] sales where cd_document_no = '6300518535'
