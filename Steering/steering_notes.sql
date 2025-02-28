/**************************************************
**	Lookup file with EV Items
***************************************************/
SELECT * from [L0].[L0_MI_PLAN_PRICE_EV_TARGETS] where itemno = '10039028'
SELECT * from [L0].[L0_MI_PLAN_PRICE_EV_TARGETS] where itemno = '10039028'

/**************************************************
**	Lookup file Marketing rates and commissions
***************************************************/
SELECT * from [L0].[L0_MI_PLAN_PRICE_COUNTRY_MARKETING_COMMISSIONS]
SELECT * from [L0].L0_MI_BUSINESS_PLAN_MARKETING_RATES
SELECT * from [L0].L0_MI_BUSINESS_PLAN_COMMISSIONS_MARKETPLACES
select top 10 * from [L1].[L1_DIM_A_CS_COMMISSIONS_AMAZON]

SELECT top 10 * from WR.WR_V_L0_MI_BUSINESS_PLAN 

/**************************************************
** EV TArgets
***************************************************/

select * from [L1].[L1_FACT_F_PLAN_PRICE]
select * from [L0].[L0_MI_BUSINESS_PLAN_COUNTRY_SHARE]

/**************************************************
**	Final view that joins EV target calculation with list price and plan price for 2025
***************************************************/
 SELECT * FROM PL.PL_V_PORTFOLIO_STEERING_TOOL

 SELECT * FROM  PL.PL_V_LAST_MEK_V3  -- use this for mek

 /**************************************************
**	Points to check
***************************************************/
---- MEK calculation (check logic)
--- Check VAT inclusive in all prices ---- Cheked/// all the prices without VAT 
--- Change calculation to marketing rates used in Business plan ---		[L0].[L0_MI_BUSINESS_PLAN_MARKETING_RATES] mkt
--- current Return/refund rates calculated over L2 + Country
-- change the NOQ to Quantity on turnover
--- Add delta columns : BS - EVTarget , ASP - EVTarget
--- ListPrice is with Discounts
-- claculate both delta rates related to EvTarget
-- Do you wnat to include Extra freight costs into shipment costs? --- include
--- MEK 1400 -- how to deal




