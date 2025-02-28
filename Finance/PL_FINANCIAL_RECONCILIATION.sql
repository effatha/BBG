/****** Object:  View [TEST].[PL_FINANCIAL_RECONCILIATION]    Script Date: 11/08/2023 20:12:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [TEST].[PL_FINANCIAL_RECONCILIATION] AS (

/*****************************************************************************
** Turnover
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Turnover',
		commercial_kpi									= 'Turnover',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM(0),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(AMT_TURNOVER_ACTUAL),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(0),
		commercial_pl									= SUM(AMT_TURNOVER_ACTUAL)
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** Order Quantity
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Order Quantity',
		commercial_kpi									= 'Order Quantity',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM(0),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(AMT_ORDER_QUANTITY_ACTUAL),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(0),
		commercial_pl									= SUM(AMT_ORDER_QUANTITY_ACTUAL)
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** Value Added Taxes
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Value Added Taxes',
		commercial_kpi									= 'Value Added Taxes',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM(0),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(AMT_VALUE_ADDED_TAXES_ACTUAL),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(0),
		commercial_pl									= SUM(AMT_VALUE_ADDED_TAXES_ACTUAL)
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** Net Order Discounts 
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Net Order Discounts',
		commercial_kpi									= 'Net Order Discounts',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM(0),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(AMT_NET_ORDER_DISCOUNTS_ACTUAL),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(0),
		commercial_pl									= SUM(AMT_NET_ORDER_DISCOUNTS_ACTUAL)
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** Net Order Charges 
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Net Order Charges',
		commercial_kpi									= 'Net Order Charges',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM(0),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(AMT_NET_ORDER_CHARGES_ACTUAL),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(0),
		commercial_pl									= SUM(AMT_NET_ORDER_CHARGES_ACTUAL)
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION

/*****************************************************************************
** Gross Order Value
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Gross Order Value',
		commercial_kpi									= 'Gross Order Value',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM(0),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(AMT_GROSS_ORDER_VALUE_ACTUAL),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(0),
		commercial_pl									= SUM(AMT_GROSS_ORDER_VALUE_ACTUAL)
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION

/*****************************************************************************
** Cancelled Order Quantity
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Cancelled Order Quantity',
		commercial_kpi									= 'CancelledOrdersQuantityEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM(0),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(AMT_CANCELLED_ORDER_QUANTITY_ACTUAL),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(AMT_CANCELLED_ORDER_QUANTITY_ACTUAL) - SUM(AMT_CANCELLED_ORDER_QUANTITY_EST),
		commercial_pl									= SUM(AMT_CANCELLED_ORDER_QUANTITY_EST)
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** Cancelled Order Value
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Cancelled Order Value',
		commercial_kpi									= 'CancelledOrderValueEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM(0),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(AMT_CANCELLED_ORDER_VALUE_ACTUAL),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(AMT_CANCELLED_ORDER_VALUE_ACTUAL) - SUM(AMT_CANCELLED_ORDER_VALUE_EST),
		commercial_pl									= SUM(AMT_CANCELLED_ORDER_VALUE_EST)
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** Net Order Quantity
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Net Order Quantity',
		commercial_kpi									= 'NetOrderQuantityEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM(0),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(AMT_NET_ORDER_QUANTITY_ACTUAL),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(AMT_NET_ORDER_QUANTITY_ACTUAL) - SUM(AMT_NET_ORDER_QUANTITY_EST),
		commercial_pl									= SUM(AMT_NET_ORDER_QUANTITY_EST)
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** Net Order Value
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Net Order Value',
		commercial_kpi									= 'NetOrderValueEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM([AMT_NOV_FI]),
		fi_manual_postings								= SUM(0	),
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM([AMT_NOV_FI]),
		sage_invoice_cancellations						= SUM(0	),
		sales_orders_previous_periods					= SUM([AMT_NOV_ACTUAL_PRIOR_PERIODS])*-1,
		sales_order_not_invoiced_end_period				= SUM([AMT_NOV_ACTUAL_NOT_INVOICED_END_PERIOD]),
		sales_orders_actual_invoiced_in_same_period		= SUM([AMT_NOV_ACTUAL_INVOICED_IN_PERIOD]),
		delta_invoice_sales_actual						= SUM([AMT_NOV_FI]) -SUM([AMT_NOV_ACTUAL_PRIOR_PERIODS]) -SUM([AMT_NOV_ACTUAL_INVOICED_IN_PERIOD]),
		sales_order_actual								= SUM([AMT_NOV_ACTUAL_INVOICED_IN_PERIOD])+SUM([AMT_NOV_ACTUAL_NOT_INVOICED_END_PERIOD]),
		sage_intercompany								= SUM(0	),
		delta_proxy_error								=SUM([AMT_NOV_EST]) - (SUM([AMT_NOV_ACTUAL_INVOICED_IN_PERIOD])+SUM([AMT_NOV_ACTUAL_NOT_INVOICED_END_PERIOD])),
		commercial_pl									= SUM([AMT_NOV_EST])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION 
/*****************************************************************************
** Refunded Order Value
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Refunded Order Value',
		commercial_kpi									= 'RefundedOrderValueEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM([AMT_REFUNDS_FI]),
		fi_manual_postings								= SUM(0	),
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM([AMT_REFUNDS_FI]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM([AMT_REFUNDS_FI]) -SUM([AMT_REFUNDS_ACTUAL]),
		sales_order_actual								= SUM([AMT_REFUNDS_ACTUAL]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_REFUNDS_EST]) - SUM([AMT_REFUNDS_ACTUAL]),
		commercial_pl									= SUM([AMT_REFUNDS_EST])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]
		
		UNION 

/*****************************************************************************
** Revenue
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Revenue',
		commercial_kpi									= 'RevenueEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM([AMT_NOV_FI])-SUM([AMT_REFUNDS_FI]),
		fi_manual_postings								= SUM([AMT_REVENUE_MANUAL_POSTING])*-1,
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM([AMT_NOV_FI])-SUM([AMT_REFUNDS_FI])-SUM([AMT_REVENUE_MANUAL_POSTING]*-1),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM([AMT_NOV_ACTUAL_PRIOR_PERIODS])*-1,
		sales_order_not_invoiced_end_period				= SUM([AMT_NOV_ACTUAL_NOT_INVOICED_END_PERIOD]),
		sales_orders_actual_invoiced_in_same_period		= SUM([AMT_NOV_ACTUAL_INVOICED_IN_PERIOD]),
		delta_invoice_sales_actual						= (SUM([AMT_NOV_FI])-SUM([AMT_REFUNDS_FI])-SUM([AMT_REVENUE_MANUAL_POSTING]*-1))
															-
														((SUM([AMT_NOV_ACTUAL_NOT_INVOICED_END_PERIOD])+SUM([AMT_NOV_ACTUAL_INVOICED_IN_PERIOD]))-SUM([AMT_REFUNDS_ACTUAL])),
		sales_order_actual								= (SUM([AMT_NOV_ACTUAL_NOT_INVOICED_END_PERIOD])+SUM([AMT_NOV_ACTUAL_INVOICED_IN_PERIOD]))-SUM([AMT_REFUNDS_ACTUAL]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= (SUM([AMT_NOV_EST])-SUM([AMT_REFUNDS_EST])) - (SUM([AMT_NOV_FI])-SUM([AMT_REFUNDS_FI])-SUM([AMT_REVENUE_MANUAL_POSTING]*-1)),
		commercial_pl									= SUM([AMT_NOV_EST])-SUM([AMT_REFUNDS_EST])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** ProductCost
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Net Product Cost',
		commercial_kpi									= 'NetProductCostEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM(0 ),
		fi_manual_postings								= SUM(0	),
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM(0 ),
		sage_invoice_cancellations						= SUM(0	),
		sales_orders_previous_periods					= SUM(AMT_NET_PRODUCT_COST_ACTUAL_PRIOR_PERIODS)*-1,
		sales_order_not_invoiced_end_period				= SUM(AMT_NET_PRODUCT_COST_ACTUAL_NOT_INVOICE_END_PERIOD),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_NET_PRODUCT_COST_ACTUAL_INVOICED_IN_PERIOD),
		delta_invoice_sales_actual						= SUM(AMT_NET_PRODUCT_COST_ACTUAL_INVOICED_IN_PERIOD) - SUM(AMT_NET_PRODUCT_COST_ACTUAL_PRIOR_PERIODS),
		sales_order_actual								= SUM(AMT_NET_PRODUCT_COST_ACTUAL_INVOICED_IN_PERIOD)+SUM(AMT_NET_PRODUCT_COST_ACTUAL_NOT_INVOICE_END_PERIOD),
		sage_intercompany								= SUM(0	),
		delta_proxy_error								=SUM(AMT_NET_PRODUCT_COST_EST) - (SUM(AMT_NET_PRODUCT_COST_ACTUAL_INVOICED_IN_PERIOD)+SUM(AMT_NET_PRODUCT_COST_ACTUAL_NOT_INVOICE_END_PERIOD)),
		commercial_pl									= SUM(AMT_NET_PRODUCT_COST_EST)
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]
		
		UNION
/*****************************************************************************
** ProductCost WITH GTS
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Net Product Costs with GTS markup',
		commercial_kpi									= 'NetProductCostEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM(AMT_NET_PRODUCT_COST_FI),
		fi_manual_postings								= SUM(0	),
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM(AMT_NET_PRODUCT_COST_FI),
		sage_invoice_cancellations						= SUM(0	),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0	),
		delta_proxy_error								=SUM(0) ,
		commercial_pl									= SUM(0)
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]
		UNION

/*****************************************************************************
** ProductCost - ONLY GTS
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Net Product Cost - GTS markup',
		commercial_kpi									= 'NetProductCostEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM(0),
		fi_manual_postings								= SUM(0	),
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0	),
		sales_orders_previous_periods					= SUM(AMT_NET_PRODUCT_COST_GTS_ACTUAL_PRIOR_PERIODS)*-1,
		sales_order_not_invoiced_end_period				= SUM(AMT_NET_PRODUCT_COST_GTS_ACTUAL_NOT_INVOICE_END_PERIOD),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_NET_PRODUCT_COST_GTS_ACTUAL_INVOICED_IN_PERIOD),
		delta_invoice_sales_actual						= SUM(AMT_NET_PRODUCT_COST_GTS_ACTUAL_INVOICED_IN_PERIOD) - SUM(AMT_NET_PRODUCT_COST_GTS_ACTUAL_PRIOR_PERIODS),
		sales_order_actual								= SUM(AMT_NET_PRODUCT_COST_GTS_ACTUAL_INVOICED_IN_PERIOD)+SUM(AMT_NET_PRODUCT_COST_GTS_ACTUAL_NOT_INVOICE_END_PERIOD),
		sage_intercompany								= SUM(0	),
		delta_proxy_error								=SUM(0),
		commercial_pl									= SUM(0)
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION 
/*****************************************************************************
** FXHedgingImpactEst
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'FX hedging impact est.',
		commercial_kpi									= 'FXHedgingImpactEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM([AMT_ACTUAL_FX_HEDGING_IMPACT_VALUE]),
		fi_manual_postings								= SUM(0	),
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_FX_HEDGING_IMPACT_VALUE]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_ACTUAL_FX_HEDGING_IMPACT_VALUE]) - SUM([AMT_EST_FX_HEDGING_IMPACT_VALUE]),
		commercial_pl									= SUM([AMT_EST_FX_HEDGING_IMPACT_VALUE])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** COGSStockValueAdjustmentEst
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'COGS - Stock value adjustment est.',
		commercial_kpi									= 'COGSStockValueAdjustmentEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM([AMT_ACTUAL_STOCK_ADJUSTMENTS_VALUE]),
		fi_manual_postings								= SUM(0	),
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_STOCK_ADJUSTMENTS_VALUE]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_ACTUAL_STOCK_ADJUSTMENTS_VALUE]) - SUM([AMT_EST_STOCK_ADJUSTMENTS_VALUE]),
		commercial_pl									= SUM([AMT_EST_STOCK_ADJUSTMENTS_VALUE])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]
	
		UNION
/*****************************************************************************
** Demurrage  / Detention
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Demurrage  / Detention est.',
		commercial_kpi									= 'DemurrageDetention',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_ACTUAL_DEMURRAGE_DETENTION_VALUE]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_DEMURRAGE_DETENTION_VALUE]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_ACTUAL_DEMURRAGE_DETENTION_VALUE]) - SUM([AMT_EST_DEMURRAGE_DETENTION_VALUE]),
		commercial_pl									= SUM([AMT_EST_DEMURRAGE_DETENTION_VALUE])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

	
		UNION
/*****************************************************************************
** Deadfreight
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Deadfreight',
		commercial_kpi									= 'DeadfreightEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_ACTUAL_DEAD_FREIGHT_VALUE]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_DEAD_FREIGHT_VALUE]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_ACTUAL_DEAD_FREIGHT_VALUE]) - SUM([AMT_EST_DEAD_FREIGHT_VALUE]),
		commercial_pl									= SUM([AMT_EST_DEAD_FREIGHT_VALUE])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** Kickbacks
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Kickbacks',
		commercial_kpi									= 'KickbacksEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_ACTUAL_KICKBACKS_VALUE]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_KICKBACKS_VALUE]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_ACTUAL_KICKBACKS_VALUE]) - SUM([AMT_EST_KICKBACKS_VALUE]),
		commercial_pl									= SUM([AMT_EST_KICKBACKS_VALUE])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** 3rd party services est.
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= '3rd party services est',
		commercial_kpi									= '3rdpartyservicesEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_ACTUAL_THIRD_PARTY_SERVICES_VALUE]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_THIRD_PARTY_SERVICES_VALUE]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_ACTUAL_THIRD_PARTY_SERVICES_VALUE]) - SUM([AMT_EST_THIRD_PARTY_SERVICES_VALUE]),
		commercial_pl									= SUM([AMT_EST_THIRD_PARTY_SERVICES_VALUE])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** RMA
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'RMA',
		commercial_kpi									= 'RMAEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_ACTUAL_RMA_VALUE]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_RMA_VALUE]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_ACTUAL_RMA_VALUE]) - SUM([AMT_EST_RMA_VALUE]),
		commercial_pl									= SUM([AMT_EST_RMA_VALUE])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** SAMPLES
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Samples',
		commercial_kpi									= 'SamplesEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_ACTUAL_SAMPLES_VALUE]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_SAMPLES_VALUE]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_ACTUAL_SAMPLES_VALUE]) - SUM([AMT_EST_SAMPLES_VALUE]),
		commercial_pl									= SUM([AMT_EST_SAMPLES_VALUE])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]
		UNION
/*****************************************************************************
** Drop shipment (CEOTRA 9er Artikel) 
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Drop shipment (CEOTRA 9er Artikel)',
		commercial_kpi									= 'DropShipmentCEOTRA9erArtikelEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_ACTUAL_DROP_SHIPMENT_VALUE]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_DROP_SHIPMENT_VALUE]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_ACTUAL_DROP_SHIPMENT_VALUE]) - SUM([AMT_EST_DROP_SHIPMENT_VALUE]),
		commercial_pl									= SUM([AMT_EST_DROP_SHIPMENT_VALUE])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]
		UNION
/*****************************************************************************
** Inbound freight costs
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Inbound freight costs',
		commercial_kpi									= 'InboundfreightcostsEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_ACTUAL_INBOUND_FREIGHT_VALUE]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_INBOUND_FREIGHT_VALUE]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_ACTUAL_INBOUND_FREIGHT_VALUE]) - SUM([AMT_EST_INBOUND_FREIGHT_VALUE]),
		commercial_pl									= SUM([AMT_EST_INBOUND_FREIGHT_VALUE])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

				UNION
/*****************************************************************************
** Inbound freight costs
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Inbound freight costs',
		commercial_kpi									= 'InboundfreightcostsEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_ACTUAL_INBOUND_FREIGHT_VALUE]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_INBOUND_FREIGHT_VALUE]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_ACTUAL_INBOUND_FREIGHT_VALUE]) - SUM([AMT_EST_INBOUND_FREIGHT_VALUE]),
		commercial_pl									= SUM([AMT_EST_INBOUND_FREIGHT_VALUE])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]

		UNION
/*****************************************************************************
** Stock Adjustment
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_FISCAL_YEAR],
		posting_month									= [NUM_FISCAL_PERIOD],
		pl_structure									= 'Stock Adjustment',
		commercial_kpi									= 'StockAdjustmentEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_ACTUAL_STOCK_ADJUSTMENTS_VALUE]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_STOCK_ADJUSTMENTS_VALUE]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_ACTUAL_STOCK_ADJUSTMENTS_VALUE]) - SUM([AMT_EST_STOCK_ADJUSTMENTS_VALUE]),
		commercial_pl									= SUM([AMT_EST_STOCK_ADJUSTMENTS_VALUE])
        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]
		
--		UNION
--/*****************************************************************************
--** PO Cancellation
--*****************************************************************************/

--        SELECT 

--        posting_year									= [NUM_FISCAL_YEAR],
--		posting_month									= [NUM_FISCAL_PERIOD],
--		pl_structure									= 'PO Cancellation',
--		commercial_kpi									= 'POCancellationEst',
--		group_pl										= SUM(0),
--		out_of_scope_companies							= SUM(0),
--		intercompany_elimination						= SUM(0),
--		stand_alone_entities							= SUM(0),
--		delta_standalone_fi								= SUM(0),
--		fi_actuals										= SUM([AMT_ACTUAL_INBOUND_FREIGHT_VALUE]),
--		fi_manual_postings								= SUM(0),
--		intercompany_kickback							= SUM(0),
--		fi_actual_without_manual_postings 				= SUM([AMT_ACTUAL_INBOUND_FREIGHT_VALUE]),
--		sage_invoice_cancellations						= SUM(0),
--		sales_orders_previous_periods					= SUM(0),
--		sales_order_not_invoiced_end_period				= SUM(0),
--		sales_orders_actual_invoiced_in_same_period		= SUM(0),
--		delta_invoice_sales_actual						= SUM(0),
--		sales_order_actual								= SUM(0),
--		sage_intercompany								= SUM(0),
--		delta_proxy_error								= SUM([AMT_ACTUAL_INBOUND_FREIGHT_VALUE]) - SUM([AMT_EST_INBOUND_FREIGHT_VALUE]),
--		commercial_pl									= SUM([AMT_EST_INBOUND_FREIGHT_VALUE])
--        FROM TEST.L1_FACT_F_SALES_FINANCE_RECONCILIATION
--		GROUP BY [NUM_FISCAL_YEAR],[NUM_FISCAL_PERIOD]
);
GO


