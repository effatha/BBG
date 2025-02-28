
/*****************************************************************************
** Turnover
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
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
		sales_order_actual								= SUM([AMT_TURNOVER_EUR]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(0),
		commercial_pl									= SUM([AMT_TURNOVER_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Order Quantity
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
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
		sales_order_actual								= SUM([VL_ORDER_QUANTITY]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(0),
		commercial_pl									= SUM([VL_ORDER_QUANTITY])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Value Added Taxes
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
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
		sales_order_actual								= SUM([AMT_VALUE_ADDED_TAX_EUR]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(0),
		commercial_pl									= SUM([AMT_VALUE_ADDED_TAX_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Net Order Discounts 
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
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
		sales_order_actual								= SUM([AMT_NET_DISCOUNT_EUR]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(0),
		commercial_pl									= SUM([AMT_NET_DISCOUNT_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Net Order Charges 
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
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
		sales_order_actual								= SUM([AMT_ORDER_CHARGES_EUR]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(0),
		commercial_pl									= SUM([AMT_ORDER_CHARGES_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION

/*****************************************************************************
** Gross Order Value
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
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
		sales_order_actual								= SUM([AMT_GROSS_ORDER_VALUE_EUR]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM(0),
		commercial_pl									= SUM([AMT_GROSS_ORDER_VALUE_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION

/*****************************************************************************
** Cancelled Order Quantity
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
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
		sales_order_actual								= SUM([VL_CANCELLED_ORDERS_QUANTITY_ACT]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([VL_CANCELLED_ORDERS_QUANTITY_ACT]) - SUM([VL_CANCELLED_ORDERS_QUANTITY_EST]),
		commercial_pl									= SUM([VL_CANCELLED_ORDERS_QUANTITY_EST])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Cancelled Order Value
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
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
		sales_order_actual								= SUM([AMT_CANCELLED_ORDER_VALUE_ACT_EUR]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_CANCELLED_ORDER_VALUE_ACT_EUR]) - SUM([AMT_CANCELLED_ORDER_VALUE_EST_EUR]),
		commercial_pl									= SUM([AMT_CANCELLED_ORDER_VALUE_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Net Order Quantity
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
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
		sales_order_actual								= SUM([VL_NET_ORDER_QUANTITY_ACT]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([VL_NET_ORDER_QUANTITY_ACT]) - SUM([VL_NET_ORDER_QUANTITY_EST]),
		commercial_pl									= SUM([VL_NET_ORDER_QUANTITY_EST])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Net Order Value
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Net Order Value',
		commercial_kpi									= 'NetOrderValueEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM([AMT_NET_ORDER_VALUE_FI_EUR]),
		fi_manual_postings								= SUM(0	),
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM([AMT_NET_ORDER_VALUE_FI_EUR]),
		sage_invoice_cancellations						= SUM(0	),
		sales_orders_previous_periods					= SUM([AMT_NET_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS])*-1,
		sales_order_not_invoiced_end_period				= SUM([AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED]),
		sales_orders_actual_invoiced_in_same_period		= SUM([AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]),
		delta_invoice_sales_actual						= SUM([AMT_NET_ORDER_VALUE_FI_EUR]) -SUM([AMT_NET_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS]) -SUM([AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]),
		sales_order_actual								= SUM([AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD])+SUM([AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED]),
		sage_intercompany								= SUM(0	),
		delta_proxy_error								=SUM([AMT_NET_ORDER_VALUE_EST_EUR]) - (SUM([AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD])+SUM([AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED])),
		commercial_pl									= SUM([AMT_NET_ORDER_VALUE_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION 
/*****************************************************************************
** Refunded Order Value
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Refunded Order Value',
		commercial_kpi									= 'RefundedOrderValueEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM([AMT_REFUNDED_ORDER_VALUE_FI_EUR]),
		fi_manual_postings								= SUM(0	),
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM([AMT_REFUNDED_ORDER_VALUE_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS]),
		sales_order_not_invoiced_end_period				= SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_NOT_INVOICED]),
		sales_orders_actual_invoiced_in_same_period		= SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]),
		delta_invoice_sales_actual						= SUM([AMT_REFUNDED_ORDER_VALUE_FI_EUR]) -SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS]) -SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]),
		sales_order_actual								= SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD])+SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_NOT_INVOICED]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_REFUNDED_ORDER_VALUE_EST_EUR]) - (SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD])+SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_NOT_INVOICED])),
		commercial_pl									= SUM([AMT_REFUNDED_ORDER_VALUE_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		
		UNION 

/*****************************************************************************
** Revenue
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Revenue',
		commercial_kpi									= 'RevenueEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM([AMT_NET_ORDER_VALUE_FI_EUR])-SUM([AMT_REFUNDED_ORDER_VALUE_FI_EUR]),
		fi_manual_postings								= SUM([AMT_REVENUE_MANUAL_POSTING_FI_EUR])*-1,
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM([AMT_NET_ORDER_VALUE_FI_EUR])-SUM([AMT_REFUNDED_ORDER_VALUE_FI_EUR])-SUM([AMT_REVENUE_MANUAL_POSTING_FI_EUR]*-1),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= (SUM([AMT_NET_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS])*-1) - SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS]),
		sales_order_not_invoiced_end_period				= SUM([AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED])-SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_NOT_INVOICED]),
		sales_orders_actual_invoiced_in_same_period		= SUM([AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD])-SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]),
		delta_invoice_sales_actual						= (SUM([AMT_NET_ORDER_VALUE_FI_EUR])-SUM([AMT_REFUNDED_ORDER_VALUE_FI_EUR])-SUM([AMT_REVENUE_MANUAL_POSTING_FI_EUR]*-1))
															-
														((SUM([AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED])+SUM([AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]))-SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]) - sum([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_NOT_INVOICED])),
		sales_order_actual								= (SUM([AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED])+SUM([AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]))-SUM([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD]) - sum([AMT_REFUNDED_ORDER_VALUE_ACT_EUR_NOT_INVOICED]),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= (SUM([AMT_NET_ORDER_VALUE_EST_EUR])-SUM([AMT_REFUNDED_ORDER_VALUE_EST_EUR])) - (SUM([AMT_NET_ORDER_VALUE_FI_EUR])-SUM([AMT_REFUNDED_ORDER_VALUE_FI_EUR])-SUM([AMT_REVENUE_MANUAL_POSTING_FI_EUR]*-1)),
		commercial_pl									= SUM([AMT_NET_ORDER_VALUE_EST_EUR])-SUM([AMT_REFUNDED_ORDER_VALUE_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** ProductCost
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
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
		sales_orders_previous_periods					= SUM([AMT_NET_PRODUCT_COST_ACT_EUR_PRIOR_PERIODS])*-1,
		sales_order_not_invoiced_end_period				= SUM([AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED]),
		sales_orders_actual_invoiced_in_same_period		= SUM([AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD]),
		delta_invoice_sales_actual						= SUM([AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD]) - SUM([AMT_NET_PRODUCT_COST_ACT_EUR_PRIOR_PERIODS]),
		sales_order_actual								= SUM([AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD])+SUM([AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED]),
		sage_intercompany								= SUM(0	),
		delta_proxy_error								= SUM([AMT_NET_PRODUCT_COST_EST_EUR]) - (SUM([AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD])+SUM([AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED])),
		commercial_pl									= SUM([AMT_NET_PRODUCT_COST_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		
		UNION
/*****************************************************************************
** ProductCost WITH GTS
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Net Product Costs with GTS markup',
		commercial_kpi									= 'NetProductCostEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM([AMT_NET_PRODUCT_COST_FI_EUR]),
		fi_manual_postings								= SUM(0	),
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM([AMT_NET_PRODUCT_COST_FI_EUR]),
		sage_invoice_cancellations						= SUM(0	),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0	),
		delta_proxy_error								=SUM(0) ,
		commercial_pl									= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		UNION

/*****************************************************************************
** ProductCost - ONLY GTS
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
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
		sales_orders_previous_periods					= SUM([AMT_NET_PRODUCT_COST_GTS_ACT_PRIOR_PERIODS])*-1,
		sales_order_not_invoiced_end_period				= SUM([AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED]),
		sales_orders_actual_invoiced_in_same_period		= SUM([AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD]),
		delta_invoice_sales_actual						= SUM([AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD]) - SUM([AMT_NET_PRODUCT_COST_GTS_ACT_PRIOR_PERIODS]),
		sales_order_actual								= SUM([AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD])+SUM([AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED]),
		sage_intercompany								= SUM(0	),
		delta_proxy_error								=SUM(0),
		commercial_pl									= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION 
/*****************************************************************************
** FXHedgingImpactEst
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'FX hedging impact est.',
		commercial_kpi									= 'FXHedgingImpactEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM([AMT_FX_HEDGING_IMPACT_FI_EUR]),
		fi_manual_postings								= SUM(0	),
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM([AMT_FX_HEDGING_IMPACT_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_FX_HEDGING_IMPACT_FI_EUR]) - SUM([AMT_FX_HEDGING_IMPACT_EST_EUR]),
		commercial_pl									= SUM([AMT_FX_HEDGING_IMPACT_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** COGSStockValueAdjustmentEst
*****************************************************************************/
        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'COGS - Stock value adjustment est.',
		commercial_kpi									= 'COGSStockValueAdjustmentEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		fi_actuals										= SUM([AMT_STOCK_ADJUSTMENTS_FI_EUR]),
		fi_manual_postings								= SUM(0	),
		intercompany_kickback							= SUM(0	),
		fi_actual_without_manual_postings 				= SUM([AMT_STOCK_ADJUSTMENTS_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_STOCK_ADJUSTMENTS_FI_EUR]) - SUM([AMT_STOCK_ADJUSTMENTS_EST_EUR]),
		commercial_pl									= SUM([AMT_STOCK_ADJUSTMENTS_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
	
		UNION
/*****************************************************************************
** Demurrage  / Detention
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Demurrage  / Detention est.',
		commercial_kpi									= 'DemurrageDetention',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_DEMURRAGE_DETENTION_FI_EUR]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_DEMURRAGE_DETENTION_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_DEMURRAGE_DETENTION_FI_EUR]) - SUM([AMT_DEMURRAGE_DETENTION_EST_EUR]),
		commercial_pl									= SUM([AMT_DEMURRAGE_DETENTION_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

	
		UNION
/*****************************************************************************
** Deadfreight
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Deadfreight',
		commercial_kpi									= 'DeadfreightEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_DEADFREIGHT_FI_EUR]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_DEADFREIGHT_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_DEADFREIGHT_FI_EUR]) - SUM([AMT_DEADFREIGHT_EST_EUR]),
		commercial_pl									= SUM([AMT_DEADFREIGHT_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Kickbacks
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Kickbacks',
		commercial_kpi									= 'KickbacksEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_KICKBACKS_FI_EUR]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_KICKBACKS_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_KICKBACKS_FI_EUR]) - SUM([AMT_KICKBACKS_EST_EUR]),
		commercial_pl									= SUM([AMT_KICKBACKS_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** 3rd party services est.
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= '3rd party services est',
		commercial_kpi									= '3rdpartyservicesEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_3RD_PARTY_SERVICES_FI_EUR]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_3RD_PARTY_SERVICES_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_3RD_PARTY_SERVICES_FI_EUR]) - SUM([AMT_3RD_PARTY_SERVICES_EST_EUR]),
		commercial_pl									= SUM([AMT_3RD_PARTY_SERVICES_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** RMA
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'RMA',
		commercial_kpi									= 'RMAEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_RMA_FI_EUR]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_RMA_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_RMA_FI_EUR]) - SUM([AMT_RMA_EST_EUR]),
		commercial_pl									= SUM([AMT_RMA_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** SAMPLES
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Samples',
		commercial_kpi									= 'SamplesEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_SAMPLES_FI_EUR]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_SAMPLES_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_SAMPLES_FI_EUR]) - SUM([AMT_SAMPLES_EST_EUR]),
		commercial_pl									= SUM([AMT_SAMPLES_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		UNION
/*****************************************************************************
** Drop shipment (CEOTRA 9er Artikel) 
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Drop shipment (CEOTRA 9er Artikel)',
		commercial_kpi									= 'DropShipmentCEOTRA9erArtikelEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR]) - SUM([AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR]),
		commercial_pl									= SUM([AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		UNION
/*****************************************************************************
** Inbound freight costs
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Inbound freight costs',
		commercial_kpi									= 'InboundfreightcostsEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_INBOUND_FREIGHT_COST_FI_EUR]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_INBOUND_FREIGHT_COST_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_INBOUND_FREIGHT_COST_FI_EUR]) - SUM([AMT_INBOUND_FREIGHT_COST_EST_EUR]),
		commercial_pl									= SUM([AMT_INBOUND_FREIGHT_COST_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

				UNION

/*****************************************************************************
** Stock Adjustment
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Stock Adjustment',
		commercial_kpi									= 'StockAdjustmentEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_STOCK_ADJUSTMENTS_FI_EUR]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_STOCK_ADJUSTMENTS_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_STOCK_ADJUSTMENTS_FI_EUR]) - SUM([AMT_STOCK_ADJUSTMENTS_EST_EUR]),
		commercial_pl									= SUM([AMT_STOCK_ADJUSTMENTS_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		
		UNION
/*****************************************************************************
** PO Cancellation
*****************************************************************************/

        SELECT 

        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'PO Cancellation',
		commercial_kpi									= 'POCancellationEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		fi_actuals										= SUM([AMT_PO_CANCELLATION_FI_EUR]),
		fi_manual_postings								= SUM(0),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM([AMT_PO_CANCELLATION_FI_EUR]),
		sage_invoice_cancellations						= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0),
		delta_proxy_error								= SUM([AMT_PO_CANCELLATION_FI_EUR]) - SUM([AMT_PO_CANCELLATION_EST_EUR]),
		commercial_pl									= SUM([AMT_PO_CANCELLATION_EST_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]




