DECLARE @NUM_POSTING_YEAR INT = 2023 ,@NUM_POSTIG_MONTH INT = 1


;With CTE_L1 as (

/*****************************************************************************
** Turnover
*****************************************************************************/
        SELECT 
		pl_order_id										= 1,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Turnover',
		commercial_kpi									= 'Turnover',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(0),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM([AMT_TURNOVER_EUR]-[AMT_TURNOVER_INTERCOMPANY_EUR]),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(0),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM([AMT_TURNOVER_EUR]),
		sales_order_actual								= SUM([AMT_TURNOVER_EUR]),
		sage_intercompany								= SUM(0)
        FROM L1.[L1_FACT_F_SALES_FINANCE_RECONCILIATION]
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Order Quantity
*****************************************************************************/
        SELECT 
		pl_order_id										= 2,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Order Quantity',
		commercial_kpi									= 'Order Quantity',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(0),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(VL_ORDER_QUANTITY),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(0),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(VL_ORDER_QUANTITY),
		sales_order_actual								= SUM(VL_ORDER_QUANTITY),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Value Added Taxes
*****************************************************************************/
        SELECT 
		pl_order_id										= 3,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Value Added Taxes',
		commercial_kpi									= 'Value Added Taxes',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(0),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_VALUE_ADDED_TAX_EUR) * -1 ,
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(0),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_VALUE_ADDED_TAX_EUR) * -1 ,
		sales_order_actual								= SUM(AMT_VALUE_ADDED_TAX_EUR) * -1 ,
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Net Order Discounts 
*****************************************************************************/
        SELECT 
		pl_order_id										= 4,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Net Order Discounts',
		commercial_kpi									= 'Net Order Discounts',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(0),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_NET_DISCOUNT_EUR) * -1 ,
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(0),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_NET_DISCOUNT_EUR) * -1 ,
		sales_order_actual								= SUM(AMT_NET_DISCOUNT_EUR) * -1 ,
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Net Order Charges 
*****************************************************************************/
        SELECT 
		pl_order_id										= 5,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Net Order Charges',
		commercial_kpi									= 'Net Order Charges',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(0),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_ORDER_CHARGES_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(0),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_ORDER_CHARGES_EUR),
		sales_order_actual								= SUM(AMT_ORDER_CHARGES_EUR),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION

/*****************************************************************************
** Gross Order Value
*****************************************************************************/
        SELECT 
		pl_order_id										= 6,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Gross Order Value',
		commercial_kpi									= 'Gross Order Value',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(0),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_GROSS_ORDER_VALUE_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(0),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_GROSS_ORDER_VALUE_EUR),
		sales_order_actual								= SUM(AMT_GROSS_ORDER_VALUE_EUR),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION

/*****************************************************************************
** Cancelled Order Value
*****************************************************************************/
        SELECT 
		pl_order_id										= 7,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Cancelled Order Value',
		commercial_kpi									= 'CancelledOrderValueEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(0),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_CANCELLED_ORDER_VALUE_ACT_EUR) *-1,
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= (SUM(AMT_CANCELLED_ORDER_VALUE_ACT_EUR)-SUM(AMT_CANCELLED_ORDER_VALUE_EST_EUR)),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_CANCELLED_ORDER_VALUE_EST_EUR) * -1,
		sales_order_actual								= SUM(AMT_CANCELLED_ORDER_VALUE_ACT_EUR) * -1,
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Cancelled Order Quantity
*****************************************************************************/
        SELECT 
		pl_order_id										= 8,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Cancelled Order Quantity',
		commercial_kpi									= 'CancelledOrdersQuantityEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(0),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM([VL_CANCELLED_ORDERS_QUANTITY_ACT]),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM([VL_CANCELLED_ORDERS_QUANTITY_ACT])-SUM([VL_CANCELLED_ORDERS_QUANTITY_EST]),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM([VL_CANCELLED_ORDERS_QUANTITY_EST]),
		sales_order_actual								= SUM([VL_CANCELLED_ORDERS_QUANTITY_ACT]),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Net Order Value
*****************************************************************************/
        SELECT 
		pl_order_id										= 9,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Net Order Value',
		commercial_kpi									= 'NetOrderValueEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		--begin
		fi_actuals										= SUM(AMT_NET_ORDER_VALUE_FI_EUR),
		fi_actuals_intercompany							= SUM(AMT_NET_ORDER_VALUE_INTERCOMPANY_ACT_EUR_NOT_INVOICED),
		sales_orders_previous_periods					= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS *-1) ,
		sales_order_not_invoiced_end_period				= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED),
		fi_manual_postings								= SUM(AMT_NET_ORDER_VALUE_MANUAL_POSTING_FI_EUR),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= (SUM(AMT_NET_ORDER_VALUE_FI_EUR)+SUM(AMT_NET_ORDER_VALUE_MANUAL_POSTING_FI_EUR)+SUM(AMT_NET_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS *-1) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)
															-
														 SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD )- SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)
															)*-1,
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD ) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED),
		intercompany_sales								= SUM(AMT_NET_ORDER_VALUE_INTERCOMPANY_ACT_EUR_INVOICED_IN_PERIOD+AMT_NET_ORDER_VALUE_INTERCOMPANY_ACT_EUR_NOT_INVOICED),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_NET_ORDER_VALUE_EST_EUR)-(SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED))
																-SUM(AMT_NET_ORDER_VALUE_INTERCOMPANY_ACT_EUR_INVOICED_IN_PERIOD+AMT_NET_ORDER_VALUE_INTERCOMPANY_ACT_EUR_NOT_INVOICED),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(AMT_NET_ORDER_VALUE_FI_EUR) - SUM(AMT_NET_ORDER_VALUE_MANUAL_POSTING_FI_EUR),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_NET_ORDER_VALUE_EST_EUR),
		sales_order_actual								= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION 
/*****************************************************************************
** Net Order Quantity
*****************************************************************************/
        SELECT 
		pl_order_id										= 10,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Net Order Quantity',
		commercial_kpi									= 'NetOrderQuantityEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(VL_NET_ORDER_QUANTITY_ACT),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(VL_NET_ORDER_QUANTITY_ACT),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(VL_NET_ORDER_QUANTITY_EST)-SUM(VL_NET_ORDER_QUANTITY_ACT),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(VL_NET_ORDER_QUANTITY_EST),
		sales_order_actual								= SUM(VL_NET_ORDER_QUANTITY_ACT),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION

/*****************************************************************************
** Refunded Order Value
*****************************************************************************/
        SELECT 
		pl_order_id										= 11,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Refunds',
		commercial_kpi									= 'RefundedOrderValueEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		--begin
		fi_actuals										= SUM(AMT_REFUNDED_ORDER_VALUE_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(AMT_REFUNDED_MANUAL_POSTING_FI_EUR*-1),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_REFUNDED_ORDER_VALUE_FI_EUR)+SUM(AMT_REFUNDED_MANUAL_POSTING_FI_EUR*-1)+SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= (SUM(AMT_REFUNDED_ORDER_VALUE_FI_EUR)+SUM(AMT_REFUNDED_MANUAL_POSTING_FI_EUR*-1)+SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS))*-1-SUM(AMT_REFUNDED_ORDER_VALUE_EST_EUR*1) ,
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_REFUNDED_ORDER_VALUE_EST_EUR)*-1,
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		
		UNION 
/*****************************************************************************
** Returned Quantity
*****************************************************************************/
        SELECT 
		pl_order_id										= 12,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Returned Quantity',
		commercial_kpi									= 'ReturnedQuantityEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		--begin
		fi_actuals										= SUM(VL_REFUNDED_QTY_VALUE_FI-VL_REFUNDED_QTY_WITHOUT_RETURNS_VALUE_FI),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_RETURNED_QUANTITY_EST) - SUM(VL_REFUNDED_QTY_VALUE_FI-VL_REFUNDED_QTY_WITHOUT_RETURNS_VALUE_FI),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_RETURNED_QUANTITY_EST),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		
		UNION 
/*****************************************************************************
** Refunded Quantity
*****************************************************************************/
        SELECT 
		pl_order_id										= 13,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Refunded Quantity',
		commercial_kpi									= 'RefundedQuantityEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		--begin
		fi_actuals										= SUM(VL_REFUNDED_QTY_VALUE_FI),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_REFUNDED_QUANTITY_EST)- SUM(VL_REFUNDED_QTY_VALUE_FI),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_REFUNDED_QUANTITY_EST),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		
		UNION 
/*****************************************************************************
** Revenue
*****************************************************************************/

  --      SELECT 
		--pl_order_id										= 14,
  --      posting_year									= [NUM_POSTING_YEAR],
		--posting_month									= [NUM_POSTING_PERIOD],
		--pl_structure									= 'Revenue',
		--commercial_kpi									= 'RevenueEst',
		--group_pl										= SUM(0	),
		--out_of_scope_companies							= SUM(0	),
		--intercompany_elimination						= SUM(0	),
		--stand_alone_entities							= SUM(0	),
		--delta_standalone_fi								= SUM(0	),
		----begin
		--fi_actuals										= SUM(AMT_NET_ORDER_VALUE_FI_EUR)+SUM(AMT_REFUNDED_ORDER_VALUE_FI_EUR),
		--sales_orders_previous_periods					= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS*-1),
		--sales_order_not_invoiced_end_period				= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED),
		--fi_manual_postings								= SUM(AMT_NET_ORDER_VALUE_MANUAL_POSTING_FI_EUR * -1)+SUM(AMT_REFUNDED_MANUAL_POSTING_FI_EUR*-1),
		----z92_sage_documents								= SUM(0),
		--cost_returns									= SUM(0),
		--delta_invoice_sales_actual						=(SUM(AMT_NET_ORDER_VALUE_FI_EUR)+SUM(AMT_NET_ORDER_VALUE_MANUAL_POSTING_FI_EUR * -1)+SUM(AMT_NET_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS *-1) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)
		--													-
		--												 SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD )- SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)) *-1
		--												 ,
		--sales_orders_actual_invoiced_in_same_period		= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)-SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD),
		--intercompany_sales								= SUM(AMT_NET_ORDER_VALUE_INTERCOMPANY_ACT_EUR),
		--returns_documents								= SUM(0),			
		--delta_proxy_error								= SUM(0),

		--intercompany_kickback							= SUM(0),
		--fi_actual_without_manual_postings 				= SUM(AMT_NET_ORDER_VALUE_FI_EUR)-SUM(AMT_REFUNDED_ORDER_VALUE_FI_EUR),
		--sage_invoice_cancellations						= SUM(0),
		--commercial_pl									= SUM(AMT_NET_ORDER_VALUE_EST_EUR)-SUM(AMT_REFUNDED_ORDER_VALUE_EST_EUR) - SUM(AMT_RETURN_ORDER_VALUE_EST_EUR),
		--sales_order_actual								= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)-(SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS)+SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD)),
		--sage_intercompany								= SUM(0)
  --      FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		--GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		--UNION
/*****************************************************************************
** ProductCost (with GTS)
*****************************************************************************/
        SELECT 
		pl_order_id										= 15,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Net Product Cost',
		commercial_kpi									= 'NetProductCostEst',
		group_pl										= SUM([AMT_GROUP_REPORTING_COGS_FI_EUR]),
		out_of_scope_companies							= SUM([AMT_OUT_SCOPE_COMPANIES_COGS_FI_EUR]	),
		intercompany_elimination						= SUM([AMT_IC_ELIMINATION_COGS_FI_EUR]),
		stand_alone_entities							= SUM([AMT_IN_SCOPE_STANDALONE_COGS_FI_EUR]),
		delta_standalone_fi								= SUM([AMT_IN_SCOPE_STANDALONE_COGS_FI_EUR])-SUM(AMT_NET_PRODUCT_COST_FI_EUR),
		--begin
		fi_actuals										= SUM(AMT_NET_PRODUCT_COST_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(AMT_NET_PRODUCT_COST_ACT_EUR_PRIOR_PERIODS)+SUM(AMT_NET_PRODUCT_COST_GTS_ACT_PRIOR_PERIODS),
		sales_order_not_invoiced_end_period				= SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED)+SUM(AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(AMT_NET_PRODUCT_COST_FI_Z92),
		cost_returns									= SUM(AMT_NET_PRODUCT_COST_FI_RETURNS),
		delta_invoice_sales_actual						= SUM(AMT_NET_PRODUCT_COST_FI_EUR) - (SUM(AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD )+SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED)-
															(SUM(AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD +AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED))),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD )+SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED)-
															(SUM(AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD +AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED)),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(AMT_NET_PRODUCT_COST_FI_RETURNS),			
		delta_proxy_error								= SUM(AMT_NET_PRODUCT_COST_EST_EUR+AMT_REPLACEMENT_PRODUCT_COST_EST)-SUM(AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD )+SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED)-
															(SUM(AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD +AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED)),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_NET_PRODUCT_COST_EST_EUR)+SUM(AMT_REPLACEMENT_PRODUCT_COST_EST),
		sales_order_actual								= SUM(AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD )+SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED)-
															(SUM(AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD +AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED)),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		
		UNION
/*****************************************************************************
** ProductCost WITHout GTS
*****************************************************************************/
        SELECT 
		pl_order_id										= 16,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Net Product Costs without GTS markup',
		commercial_kpi									= 'NetProductCostEst',
		group_pl										= SUM([AMT_GROUP_REPORTING_COGS_FI_EUR]),
		out_of_scope_companies							= SUM([AMT_OUT_SCOPE_COMPANIES_COGS_FI_EUR]	),
		intercompany_elimination						= SUM([AMT_IC_ELIMINATION_COGS_FI_EUR]),
		stand_alone_entities							= SUM([AMT_IN_SCOPE_STANDALONE_COGS_FI_EUR]),
		delta_standalone_fi								= SUM([AMT_IN_SCOPE_STANDALONE_COGS_FI_EUR])-SUM(AMT_NET_PRODUCT_COST_FI_EUR),
		--begin
		fi_actuals										= SUM(AMT_NET_PRODUCT_COST_FI_EUR - AMT_NET_PRODUCT_COST_GTS_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(AMT_NET_PRODUCT_COST_ACT_EUR_PRIOR_PERIODS),
		sales_order_not_invoiced_end_period				= SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(AMT_NET_PRODUCT_COST_FI_EUR - AMT_NET_PRODUCT_COST_GTS_FI_EUR)-SUM(AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD +AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD )+SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_NET_PRODUCT_COST_EST_EUR)-SUM(AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD )+SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_NET_PRODUCT_COST_EST_EUR),
		sales_order_actual								= SUM(AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD )+SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH

		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		UNION

/*****************************************************************************
** ProductCost - ONLY GTS
*****************************************************************************/

        SELECT 
		pl_order_id										= 17,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Net Product Cost - GTS markup',
		commercial_kpi									= 'NetProductCostEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		--begin
		fi_actuals										= SUM(AMT_NET_PRODUCT_COST_GTS_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(AMT_NET_PRODUCT_COST_GTS_ACT_PRIOR_PERIODS),
		sales_order_not_invoiced_end_period				= SUM(AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(AMT_NET_PRODUCT_COST_GTS_FI_EUR) -(SUM(AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED)  +  SUM([AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD])),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_NET_PRODUCT_COST_GTS_ACT_PRIOR_PERIODS)+SUM(AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(0),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(0),
		sales_order_actual								= SUM(AMT_NET_PRODUCT_COST_GTS_ACT_PRIOR_PERIODS)+SUM(AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION 
/*****************************************************************************
** Replacement Quantity
*****************************************************************************/
        SELECT 
		pl_order_id										= 18,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Replacement Quantity',
		commercial_kpi									= 'ReplacementQuantityEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		--begin
		fi_actuals										= SUM(VL_REPLACEMENT_QTY_VALUE_FI),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(0),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(VL_REPLACEMENT_QTY_VALUE_FI)-SUM(AMT_REPLACEMENT_ORDER_QUANTITY_EST),
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_REPLACEMENT_ORDER_QUANTITY_EST),
		sales_order_actual								= SUM(0),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		
		UNION 
/*****************************************************************************
** PC0 WIth GTS
*****************************************************************************/
  --      SELECT 
		--pl_order_id										= 19,
  --      posting_year									= [NUM_POSTING_YEAR],
		--posting_month									= [NUM_POSTING_PERIOD],
		--pl_structure									= 'PC0 w GTS',
		--commercial_kpi									= 'PC0 w GTS',
		--group_pl										= SUM(0	),
		--out_of_scope_companies							= SUM(0	),
		--intercompany_elimination						= SUM(0	),
		--stand_alone_entities							= SUM(0	),
		--delta_standalone_fi								= SUM(0	),
		----begin
		--fi_actuals										= SUM(AMT_NET_ORDER_VALUE_FI_EUR)-SUM(AMT_REFUNDED_ORDER_VALUE_FI_EUR)-sum(AMT_NET_PRODUCT_COST_FI_EUR),
		--fi_actuals_intercompany							= SUM(0),
		--sales_orders_previous_periods					= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS)-SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS)-(SUM(AMT_NET_PRODUCT_COST_ACT_EUR_PRIOR_PERIODS)+SUM(AMT_NET_PRODUCT_COST_GTS_ACT_PRIOR_PERIODS)),
		--sales_order_not_invoiced_end_period				= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)-SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_NOT_INVOICED) - (SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED)+SUM(AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED)),
		--fi_manual_postings								= SUM(0),
		----z92_sage_documents								= SUM(0),
		--cost_returns									= SUM(0),
		--delta_invoice_sales_actual						= SUM(AMT_NET_ORDER_VALUE_FI_EUR)-SUM(AMT_REFUNDED_ORDER_VALUE_FI_EUR)-sum(AMT_NET_PRODUCT_COST_FI_EUR) - (SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)-SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD)-(SUM(AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD )+SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED)-
		--													(SUM(AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD +AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED)))),
		--sales_orders_actual_invoiced_in_same_period		= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)-SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD)-(SUM(AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD )+SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED)-
		--													(SUM(AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD +AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED))),
		--intercompany_sales								= SUM(AMT_NET_ORDER_VALUE_INTERCOMPANY_ACT_EUR),
		--returns_documents								= SUM(0),			
		--delta_proxy_error								= SUM(0),

		--intercompany_kickback							= SUM(0),
		--fi_actual_without_manual_postings 				= SUM(AMT_NET_ORDER_VALUE_FI_EUR)-SUM(AMT_REFUNDED_ORDER_VALUE_FI_EUR),
		--sage_invoice_cancellations						= SUM(0),
		--commercial_pl									= SUM(AMT_NET_ORDER_VALUE_EST_EUR)-SUM(AMT_REFUNDED_ORDER_VALUE_EST_EUR) - SUM(AMT_RETURN_ORDER_VALUE_EST_EUR)-SUM(AMT_NET_PRODUCT_COST_EST_EUR),
		--sales_order_actual								= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)-(SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS)+SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD)),
		--sage_intercompany								= SUM(0)
  --      FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		--		WHERE 
		--	1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
		--	--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		--GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		
		--UNION 
/*****************************************************************************
** PC0 WIthout GTS
*****************************************************************************/
  --      SELECT 
		--pl_order_id										= 20,
  --      posting_year									= [NUM_POSTING_YEAR],
		--posting_month									= [NUM_POSTING_PERIOD],
		--pl_structure									= 'PC0 w/o GTS',
		--commercial_kpi									= 'PC0 w/o GTS',
		--group_pl										= SUM(0	),
		--out_of_scope_companies							= SUM(0	),
		--intercompany_elimination						= SUM(0	),
		--stand_alone_entities							= SUM(0	),
		--delta_standalone_fi								= SUM(0	),
		----begin
		--fi_actuals										= SUM(AMT_NET_ORDER_VALUE_FI_EUR)-SUM(AMT_REFUNDED_ORDER_VALUE_FI_EUR)-sum(AMT_NET_PRODUCT_COST_FI_EUR),
		--fi_actuals_intercompany							= SUM(0),
		--sales_orders_previous_periods					= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS)-SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS)-(SUM(AMT_NET_PRODUCT_COST_ACT_EUR_PRIOR_PERIODS)+SUM(AMT_NET_PRODUCT_COST_GTS_ACT_PRIOR_PERIODS)),
		--sales_order_not_invoiced_end_period				= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)-SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_NOT_INVOICED) - (SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED)+SUM(AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED)),
		--fi_manual_postings								= SUM(0),
		----z92_sage_documents								= SUM(0),
		--cost_returns									= SUM(0),
		--delta_invoice_sales_actual						= SUM(AMT_NET_ORDER_VALUE_FI_EUR)-SUM(AMT_REFUNDED_ORDER_VALUE_FI_EUR)-sum(AMT_NET_PRODUCT_COST_FI_EUR) - (SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)-SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD)-(SUM(AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD )+SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED)-
		--													(SUM(AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD +AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED)))),
		--sales_orders_actual_invoiced_in_same_period		= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)-SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD)-(SUM(AMT_NET_PRODUCT_COST_ACT_EUR_INVOICED_IN_PERIOD )+SUM(AMT_NET_PRODUCT_COST_ACT_EUR_NOT_INVOICED)-
		--													(SUM(AMT_NET_PRODUCT_COST_GTS_ACT_INVOICED_IN_PERIOD +AMT_NET_PRODUCT_COST_GTS_ACT_NOT_INVOICED))),
		--intercompany_sales								= SUM(AMT_NET_ORDER_VALUE_INTERCOMPANY_ACT_EUR),
		--returns_documents								= SUM(0),			
		--delta_proxy_error								= SUM(0),

		--intercompany_kickback							= SUM(0),
		--fi_actual_without_manual_postings 				= SUM(AMT_NET_ORDER_VALUE_FI_EUR)-SUM(AMT_REFUNDED_ORDER_VALUE_FI_EUR),
		--sage_invoice_cancellations						= SUM(0),
		--commercial_pl									= SUM(AMT_NET_ORDER_VALUE_EST_EUR)-SUM(AMT_REFUNDED_ORDER_VALUE_EST_EUR) - SUM(AMT_RETURN_ORDER_VALUE_EST_EUR)-SUM(AMT_NET_PRODUCT_COST_EST_EUR),
		--sales_order_actual								= SUM(AMT_NET_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD) + SUM(AMT_NET_ORDER_VALUE_ACT_EUR_NOT_INVOICED)-(SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_PRIOR_PERIODS)+SUM(AMT_REFUNDED_ORDER_VALUE_ACT_EUR_INVOICED_IN_PERIOD)),
		--sage_intercompany								= SUM(0)
  --      FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
		--		WHERE 
		--	1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
		--	--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		--GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		
		--UNION 
/*****************************************************************************
** FXHedgingImpactEst
*****************************************************************************/
        SELECT 
		pl_order_id										= 21,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'COGS - FX hedging impact',
		commercial_kpi									= 'FXHedgingImpactEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		--begin
		fi_actuals										= SUM(AMT_FX_HEDGING_IMPACT_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_FX_HEDGING_IMPACT_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_FX_HEDGING_IMPACT_EST_EUR)* -1 -SUM(AMT_FX_HEDGING_IMPACT_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_FX_HEDGING_IMPACT_EST_EUR) * -1,
		sales_order_actual								= SUM(AMT_FX_HEDGING_IMPACT_FI_EUR),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** COGSStockValueAdjustmentEst
*****************************************************************************/
        SELECT 
		pl_order_id										= 22,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'COGS - Stock Value adjustment',
		commercial_kpi									= 'COGSStockValueAdjustmentEst',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		--begin
		fi_actuals										= SUM(AMT_COGS_STOCK_ADJUSTMENTS_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_COGS_STOCK_ADJUSTMENTS_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM([AMT_COGS_STOCK_ADJUSTMENTS_EST_EUR])* -1 -SUM([AMT_COGS_STOCK_ADJUSTMENTS_FI_EUR]),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM([AMT_COGS_STOCK_ADJUSTMENTS_EST_EUR]) * -1,
		sales_order_actual								= SUM(AMT_COGS_STOCK_ADJUSTMENTS_FI_EUR),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
	
		UNION
/*****************************************************************************
** COGS - Operations
*****************************************************************************/
        SELECT 
		pl_order_id										= 23,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'COGS - Operations',
		commercial_kpi									= 'COGS - Operations',
		group_pl										= SUM(0	),
		out_of_scope_companies							= SUM(0	),
		intercompany_elimination						= SUM(0	),
		stand_alone_entities							= SUM(0	),
		delta_standalone_fi								= SUM(0	),
		--begin
		fi_actuals										= SUM(AMT_DEMURRAGE_DETENTION_FI_EUR)+SUM(AMT_DEADFREIGHT_FI_EUR)+SUM(AMT_KICKBACKS_FI_EUR)+SUM(AMT_3RD_PARTY_SERVICES_FI_EUR)+SUM(AMT_RMA_FI_EUR)+SUM(AMT_SAMPLES_FI_EUR)+SUM(AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR)+SUM(AMT_INBOUND_FREIGHT_COST_FI_EUR)+SUM(AMT_STOCK_VALUE_ADJUSTMENTS_FI_EUR)+SUM(AMT_PO_CANCELLATION_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_DEMURRAGE_DETENTION_FI_EUR)+SUM(AMT_DEADFREIGHT_FI_EUR)+SUM(AMT_KICKBACKS_FI_EUR)+SUM(AMT_3RD_PARTY_SERVICES_FI_EUR)+SUM(AMT_RMA_FI_EUR)+SUM(AMT_SAMPLES_FI_EUR)+SUM(AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR)+SUM(AMT_INBOUND_FREIGHT_COST_FI_EUR)+SUM(AMT_STOCK_VALUE_ADJUSTMENTS_FI_EUR)+SUM(AMT_PO_CANCELLATION_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_DEMURRAGE_DETENTION_FI_EUR)+SUM(AMT_DEADFREIGHT_FI_EUR)+SUM(AMT_KICKBACKS_FI_EUR)+SUM(AMT_3RD_PARTY_SERVICES_FI_EUR)+SUM(AMT_RMA_FI_EUR)+SUM(AMT_SAMPLES_FI_EUR)+SUM(AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR)+SUM(AMT_INBOUND_FREIGHT_COST_FI_EUR)+SUM(AMT_STOCK_VALUE_ADJUSTMENTS_FI_EUR)+SUM(AMT_PO_CANCELLATION_FI_EUR)
															-
															(SUM(AMT_DEMURRAGE_DETENTION_EST_EUR)+SUM(AMT_DEADFREIGHT_EST_EUR)+SUM(AMT_KICKBACKS_EST_EUR)+SUM(AMT_3RD_PARTY_SERVICES_EST_EUR)+SUM(AMT_RMA_EST_EUR)+SUM(AMT_SAMPLES_EST_EUR)+SUM(AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR)+SUM(AMT_INBOUND_FREIGHT_COST_EST_EUR)+SUM([AMT_COGS_STOCK_ADJUSTMENTS_EST_EUR])+SUM(AMT_PO_CANCELLATION_EST_EUR)* -1),
											
		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= (SUM(AMT_DEMURRAGE_DETENTION_EST_EUR)+SUM(AMT_DEADFREIGHT_EST_EUR)+SUM(AMT_KICKBACKS_EST_EUR)+SUM(AMT_3RD_PARTY_SERVICES_EST_EUR)+SUM(AMT_RMA_EST_EUR)+SUM(AMT_SAMPLES_EST_EUR)+SUM(AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR)+SUM(AMT_INBOUND_FREIGHT_COST_EST_EUR)+SUM([AMT_COGS_STOCK_ADJUSTMENTS_EST_EUR])+SUM(AMT_PO_CANCELLATION_EST_EUR)) * -1,
		sales_order_actual								= SUM(AMT_COGS_STOCK_ADJUSTMENTS_FI_EUR),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
	
		UNION

/*****************************************************************************
** Demurrage  / Detention
*****************************************************************************/

        SELECT 
		pl_order_id										= 24,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Demurrage  / Detention est.',
		commercial_kpi									= 'DemurrageDetention',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(AMT_DEMURRAGE_DETENTION_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_DEMURRAGE_DETENTION_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_DEMURRAGE_DETENTION_EST_EUR)* -1-SUM(AMT_DEMURRAGE_DETENTION_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_DEMURRAGE_DETENTION_EST_EUR)* -1,
		sales_order_actual								= SUM(AMT_DEMURRAGE_DETENTION_FI_EUR),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

	
		UNION
/*****************************************************************************
** Deadfreight
*****************************************************************************/

        SELECT 
		pl_order_id										= 25,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Deadfreight',
		commercial_kpi									= 'DeadfreightEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
				--begin
		fi_actuals										= SUM(AMT_DEADFREIGHT_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_DEADFREIGHT_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_DEADFREIGHT_EST_EUR)* -1-SUM(AMT_DEADFREIGHT_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_DEADFREIGHT_EST_EUR)* -1,
		sales_order_actual								= SUM(AMT_DEADFREIGHT_FI_EUR),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Kickbacks
*****************************************************************************/

        SELECT 
		pl_order_id										= 26,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Kickbacks',
		commercial_kpi									= 'KickbacksEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(AMT_KICKBACKS_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_KICKBACKS_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_KICKBACKS_EST_EUR)* -1-SUM(AMT_KICKBACKS_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_KICKBACKS_EST_EUR)* -1,
		sales_order_actual								= SUM(AMT_KICKBACKS_FI_EUR),
		sage_intercompany								= SUM(0)
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** 3rd party services est.
*****************************************************************************/

        SELECT 
		pl_order_id										= 27,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= '3rd party services est',
		commercial_kpi									= '3rdpartyservicesEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(AMT_3RD_PARTY_SERVICES_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_3RD_PARTY_SERVICES_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_3RD_PARTY_SERVICES_EST_EUR)* -1-SUM(AMT_3RD_PARTY_SERVICES_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_3RD_PARTY_SERVICES_EST_EUR)* -1,
		sales_order_actual								= SUM(AMT_3RD_PARTY_SERVICES_FI_EUR),
		sage_intercompany								= SUM(0)

        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** RMA
*****************************************************************************/

        SELECT 
		pl_order_id										= 28,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'RMA',
		commercial_kpi									= 'RMAEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(AMT_RMA_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_RMA_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_RMA_EST_EUR)* -1-SUM(AMT_RMA_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_RMA_EST_EUR)* -1,
		sales_order_actual								= SUM(AMT_RMA_FI_EUR),
		sage_intercompany								= SUM(0)

        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** SAMPLES
*****************************************************************************/

        SELECT 
		pl_order_id										= 29,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Samples',
		commercial_kpi									= 'SamplesEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(AMT_SAMPLES_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_SAMPLES_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_SAMPLES_EST_EUR)* -1-SUM(AMT_SAMPLES_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_SAMPLES_EST_EUR)* -1,
		sales_order_actual								= SUM(AMT_SAMPLES_FI_EUR),
		sage_intercompany								= SUM(0)

        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		UNION
/*****************************************************************************
** Drop shipment (CEOTRA 9er Artikel) 
*****************************************************************************/

        SELECT 
		pl_order_id										= 30,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Drop shipment (CEOTRA 9er Artikel)',
		commercial_kpi									= 'DropShipmentCEOTRA9erArtikelEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR)* -1-SUM(AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_EST_EUR)* -1,
		sales_order_actual								= SUM(AMT_DROPSHIPMENT_CEOTRA9ER_ARTIKEL_FI_EUR),
		sage_intercompany								= SUM(0)

        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION

/*****************************************************************************
** Inbound freight costs
*****************************************************************************/

        SELECT 
		pl_order_id										= 31,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Inbound freight costs',
		commercial_kpi									= 'InboundfreightcostsEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(AMT_INBOUND_FREIGHT_COST_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_INBOUND_FREIGHT_COST_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_INBOUND_FREIGHT_COST_EST_EUR)* -1-SUM(AMT_INBOUND_FREIGHT_COST_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_INBOUND_FREIGHT_COST_EST_EUR)* -1,
		sales_order_actual								= SUM(AMT_INBOUND_FREIGHT_COST_FI_EUR),
		sage_intercompany								= SUM(0)

        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

				UNION

/*****************************************************************************
** Stock Adjustment
*****************************************************************************/

        SELECT 
		pl_order_id										= 32,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Stock Adjustment',
		commercial_kpi									= 'StockAdjustmentEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(AMT_STOCK_VALUE_ADJUSTMENTS_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_STOCK_VALUE_ADJUSTMENTS_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM([AMT_COGS_STOCK_ADJUSTMENTS_EST_EUR])* -1-SUM(AMT_STOCK_VALUE_ADJUSTMENTS_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM([AMT_COGS_STOCK_ADJUSTMENTS_EST_EUR])* -1,
		sales_order_actual								= SUM(AMT_STOCK_VALUE_ADJUSTMENTS_FI_EUR),
		sage_intercompany								= SUM(0)

        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]
		
		UNION
/*****************************************************************************
** PO Cancellation
*****************************************************************************/

        SELECT 
		pl_order_id										= 33,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'PO Cancellation',
		commercial_kpi									= 'POCancellationEst',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(AMT_PO_CANCELLATION_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_PO_CANCELLATION_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_PO_CANCELLATION_EST_EUR)* -1-SUM(AMT_PO_CANCELLATION_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(AMT_PO_CANCELLATION_EST_EUR)* -1,
		sales_order_actual								= SUM(AMT_PO_CANCELLATION_FI_EUR),
		sage_intercompany								= SUM(0)

        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION
/*****************************************************************************
** Other Costs Effects
*****************************************************************************/

        SELECT 
		pl_order_id										= 34,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'Other Costs Effects',
		commercial_kpi									= 'Other Costs Effects',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(AMT_OTHER_COSTS_EFFECTS_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_OTHER_COSTS_EFFECTS_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM([AMT_OTHER_COSTS_EFFECTS_EST_EUR])* -1-SUM(AMT_OTHER_COSTS_EFFECTS_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM([AMT_OTHER_COSTS_EFFECTS_EST_EUR])* -1,
		sales_order_actual								= SUM(AMT_OTHER_COSTS_EFFECTS_FI_EUR),
		sage_intercompany								= SUM(0)

        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		UNION

/*****************************************************************************
** COGS RECONCILIATION
*****************************************************************************/

        SELECT 
		pl_order_id										= 35,
        posting_year									= [NUM_POSTING_YEAR],
		posting_month									= [NUM_POSTING_PERIOD],
		pl_structure									= 'COGS RECONCILIATION',
		commercial_kpi									= 'COGS RECONCILIATION',
		group_pl										= SUM(0),
		out_of_scope_companies							= SUM(0),
		intercompany_elimination						= SUM(0),
		stand_alone_entities							= SUM(0),
		delta_standalone_fi								= SUM(0),
		--begin
		fi_actuals										= SUM(AMT_COGS_RECONCILIATION_FI_EUR),
		fi_actuals_intercompany							= SUM(0),
		sales_orders_previous_periods					= SUM(0),
		sales_order_not_invoiced_end_period				= SUM(0),
		fi_manual_postings								= SUM(0),
		--z92_sage_documents								= SUM(0),
		cost_returns									= SUM(0),
		delta_invoice_sales_actual						= SUM(0),
		sales_orders_actual_invoiced_in_same_period		= SUM(AMT_COGS_RECONCILIATION_FI_EUR),
		intercompany_sales								= SUM(0),
		returns_documents								= SUM(0),			
		delta_proxy_error								= SUM(AMT_COGS_RECONCILIATION_FI_EUR),

		intercompany_kickback							= SUM(0),
		fi_actual_without_manual_postings 				= SUM(0),
		sage_invoice_cancellations						= SUM(0),
		commercial_pl									= SUM(0),
		sales_order_actual								= SUM(AMT_COGS_RECONCILIATION_FI_EUR),
		sage_intercompany								= SUM(0)

        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
				WHERE 
			1=1--[NUM_POSTING_YEAR] = @NUM_POSTING_YEAR 
			--AND [NUM_POSTING_PERIOD] = @NUM_POSTIG_MONTH
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

		
),
CTE_GROUP_COMPANY AS (
        SELECT 
			posting_year									= [NUM_POSTING_YEAR],
			posting_month									= [NUM_POSTING_PERIOD],
			pl_structure									= 'Revenue',
			group_pl										= SUM([AMT_GROUP_REPORTING_REVENUE_FI_EUR]),
			out_of_scope_companies							= SUM([AMT_OUT_SCOPE_COMPANIES_REVENUE_FI_EUR]),
			intercompany_elimination						= SUM([AMT_IC_ELIMINATION_REVENUE_FI_EUR]),
			stand_alone_entities							= SUM([AMT_IN_SCOPE_STANDALONE_REVENUE_FI_EUR])
        FROM L1.L1_FACT_F_SALES_FINANCE_RECONCILIATION
--				WHERE 
--			[NUM_POSTING_YEAR] = 2023 
--			AND [NUM_POSTING_PERIOD] = 1
		GROUP BY [NUM_POSTING_YEAR],[NUM_POSTING_PERIOD]

),
CTE_REVENUE AS (
SELECT *
FROM CTE_L1
UNION

        SELECT 
		pl_order_id										= 14,
        posting_year									= l1.posting_year,
		posting_month									= l1.posting_month,
		pl_structure									= 'Revenue',
		commercial_kpi									= 'RevenueEst',
		group_pl										= MAX(rev.group_pl),
		out_of_scope_companies							= MAX(rev.out_of_scope_companies),
		intercompany_elimination						= MAX(rev.intercompany_elimination),
		stand_alone_entities							= MAX(rev.stand_alone_entities),
		delta_standalone_fi								= SUM(delta_standalone_fi),
		--begin
		fi_actuals										= SUM(fi_actuals),
		fi_actuals_intercompany							= SUM(fi_actuals_intercompany),
		sales_orders_previous_periods					= SUM(sales_orders_previous_periods),
		sales_order_not_invoiced_end_period				= SUM(sales_order_not_invoiced_end_period),
		fi_manual_postings								= SUM(fi_manual_postings),
		--z92_sage_documents								= SUM(--z92_sage_documents),
		cost_returns									= SUM(cost_returns),
		delta_invoice_sales_actual						= SUM(delta_invoice_sales_actual),
		sales_orders_actual_invoiced_in_same_period		= SUM(sales_orders_actual_invoiced_in_same_period),
		intercompany_sales								= SUM(intercompany_sales),
		returns_documents								= SUM(returns_documents),
		delta_proxy_error								= SUM(delta_proxy_error),
		intercompany_kickback							= SUM(intercompany_kickback),
		fi_actual_without_manual_postings 				= SUM(fi_actual_without_manual_postings),
		sage_invoice_cancellations						= SUM(sage_invoice_cancellations),
		commercial_pl									= SUM(commercial_pl),
		sales_order_actual								= SUM(sales_order_actual),
		sage_intercompany								= SUM(sage_intercompany)
        FROM CTE_L1 l1
		LEFT JOIN CTE_GROUP_COMPANY rev
			on rev.posting_year= l1.posting_year and rev.posting_month= l1.posting_month and rev.pl_structure = 'Revenue'
		WHERE 
			l1.pl_structure in ('Net Order Value','Refunds')
		GROUP BY l1.posting_year,l1.posting_month
		


),
CTE_PC0 AS (

SELECT *
FROM CTE_REVENUE
UNION

        SELECT 
		pl_order_id										= 19,
        posting_year									= posting_year,
		posting_month									= posting_month,
		pl_structure									= 'PC0 w GTS',
		commercial_kpi									= 'PC0 w GTS',
		group_pl										= SUM(group_pl),
		out_of_scope_companies							= SUM(out_of_scope_companies),
		intercompany_elimination						= SUM(intercompany_elimination),
		stand_alone_entities							= SUM(stand_alone_entities),
		delta_standalone_fi								= SUM(delta_standalone_fi),
		--begin
		fi_actuals										= SUM(fi_actuals),
		fi_actuals_intercompany							= SUM(fi_actuals_intercompany),
		sales_orders_previous_periods					= SUM(sales_orders_previous_periods),
		sales_order_not_invoiced_end_period				= SUM(sales_order_not_invoiced_end_period),
		fi_manual_postings								= SUM(fi_manual_postings),
		--z92_sage_documents								= SUM(--z92_sage_documents),
		cost_returns									= SUM(cost_returns),
		delta_invoice_sales_actual						= SUM(delta_invoice_sales_actual),
		sales_orders_actual_invoiced_in_same_period		= SUM(sales_orders_actual_invoiced_in_same_period),
		intercompany_sales								= SUM(intercompany_sales),
		returns_documents								= SUM(returns_documents),
		delta_proxy_error								= SUM(delta_proxy_error),
		intercompany_kickback							= SUM(intercompany_kickback),
		fi_actual_without_manual_postings 				= SUM(fi_actual_without_manual_postings),
		sage_invoice_cancellations						= SUM(sage_invoice_cancellations),
		commercial_pl									= SUM(commercial_pl),
		sales_order_actual								= SUM(sales_order_actual),
		sage_intercompany								= SUM(sage_intercompany)
        FROM CTE_REVENUE
		WHERE 
			pl_structure in ('Revenue','Net Product Cost')
		GROUP BY posting_year,posting_month
UNION

        SELECT 
		pl_order_id										= 20,
        posting_year									= posting_year,
		posting_month									= posting_month,
		pl_structure									= 'PC0 w/o GTS',
		commercial_kpi									= 'PC0 w/o GTS',
		group_pl										= SUM(group_pl),
		out_of_scope_companies							= SUM(out_of_scope_companies),
		intercompany_elimination						= SUM(intercompany_elimination),
		stand_alone_entities							= SUM(stand_alone_entities),
		delta_standalone_fi								= SUM(delta_standalone_fi),
		--begin
		fi_actuals										= SUM(fi_actuals),
		fi_actuals_intercompany							= SUM(fi_actuals_intercompany),
		sales_orders_previous_periods					= SUM(sales_orders_previous_periods),
		sales_order_not_invoiced_end_period				= SUM(sales_order_not_invoiced_end_period),
		fi_manual_postings								= SUM(fi_manual_postings),
		--z92_sage_documents								= SUM(--z92_sage_documents),
		cost_returns									= SUM(cost_returns),
		delta_invoice_sales_actual						= SUM(delta_invoice_sales_actual),
		sales_orders_actual_invoiced_in_same_period		= SUM(sales_orders_actual_invoiced_in_same_period),
		intercompany_sales								= SUM(intercompany_sales),
		returns_documents								= SUM(returns_documents),
		delta_proxy_error								= SUM(delta_proxy_error),
		intercompany_kickback							= SUM(intercompany_kickback),
		fi_actual_without_manual_postings 				= SUM(fi_actual_without_manual_postings),
		sage_invoice_cancellations						= SUM(sage_invoice_cancellations),
		commercial_pl									= SUM(commercial_pl),
		sales_order_actual								= SUM(sales_order_actual),
		sage_intercompany								= SUM(sage_intercompany)
        FROM CTE_REVENUE
		WHERE 
			pl_structure in ('Revenue','Net Product Costs without GTS markup')
		GROUP BY posting_year,posting_month
)
SELECT *
FROM CTE_PC0
UNION

        SELECT 
		pl_order_id										= 36,
        posting_year									= posting_year,
		posting_month									= posting_month,
		pl_structure									= 'PC1 w GTS',
		commercial_kpi									= 'PC1 w GTS',
		group_pl										= SUM(group_pl),
		out_of_scope_companies							= SUM(out_of_scope_companies),
		intercompany_elimination						= SUM(intercompany_elimination),
		stand_alone_entities							= SUM(stand_alone_entities),
		delta_standalone_fi								= SUM(delta_standalone_fi),
		--begin
		fi_actuals										= SUM(fi_actuals),
		fi_actuals_intercompany							= SUM(fi_actuals_intercompany),
		sales_orders_previous_periods					= SUM(sales_orders_previous_periods),
		sales_order_not_invoiced_end_period				= SUM(sales_order_not_invoiced_end_period),
		fi_manual_postings								= SUM(fi_manual_postings),
		--z92_sage_documents								= SUM(--z92_sage_documents),
		cost_returns									= SUM(cost_returns),
		delta_invoice_sales_actual						= SUM(delta_invoice_sales_actual),
		sales_orders_actual_invoiced_in_same_period		= SUM(sales_orders_actual_invoiced_in_same_period),
		intercompany_sales								= SUM(intercompany_sales),
		returns_documents								= SUM(returns_documents),
		delta_proxy_error								= SUM(delta_proxy_error),
		intercompany_kickback							= SUM(intercompany_kickback),
		fi_actual_without_manual_postings 				= SUM(fi_actual_without_manual_postings),
		sage_invoice_cancellations						= SUM(sage_invoice_cancellations),
		commercial_pl									= SUM(commercial_pl),
		sales_order_actual								= SUM(sales_order_actual),
		sage_intercompany								= SUM(sage_intercompany)
        FROM CTE_REVENUE
		WHERE 
			pl_structure in ('PC0 w/o GTS','COGS - Operations','COGS - FX hedging impact','COGS - Stock Value adjustment','Other Costs Effects','COGS RECONCILIATION')
		GROUP BY posting_year,posting_month
UNION


        SELECT 
		pl_order_id										= 37,
        posting_year									= posting_year,
		posting_month									= posting_month,
		pl_structure									= 'PC1 w/o GTS',
		commercial_kpi									= 'PC1 w/o GTS',
		group_pl										= SUM(group_pl),
		out_of_scope_companies							= SUM(out_of_scope_companies),
		intercompany_elimination						= SUM(intercompany_elimination),
		stand_alone_entities							= SUM(stand_alone_entities),
		delta_standalone_fi								= SUM(delta_standalone_fi),
		--begin
		fi_actuals										= SUM(fi_actuals),
		fi_actuals_intercompany							= SUM(fi_actuals_intercompany),
		sales_orders_previous_periods					= SUM(sales_orders_previous_periods),
		sales_order_not_invoiced_end_period				= SUM(sales_order_not_invoiced_end_period),
		fi_manual_postings								= SUM(fi_manual_postings),
		--z92_sage_documents								= SUM(--z92_sage_documents),
		cost_returns									= SUM(cost_returns),
		delta_invoice_sales_actual						= SUM(delta_invoice_sales_actual),
		sales_orders_actual_invoiced_in_same_period		= SUM(sales_orders_actual_invoiced_in_same_period),
		intercompany_sales								= SUM(intercompany_sales),
		returns_documents								= SUM(returns_documents),
		delta_proxy_error								= SUM(delta_proxy_error),
		intercompany_kickback							= SUM(intercompany_kickback),
		fi_actual_without_manual_postings 				= SUM(fi_actual_without_manual_postings),
		sage_invoice_cancellations						= SUM(sage_invoice_cancellations),
		commercial_pl									= SUM(commercial_pl),
		sales_order_actual								= SUM(sales_order_actual),
		sage_intercompany								= SUM(sage_intercompany)
        FROM CTE_REVENUE
		WHERE 
			pl_structure in ('PC0 w/o GTS','COGS - Operations','COGS - FX hedging impact','COGS - Stock Value adjustment','Other Costs Effects','COGS RECONCILIATION')
		GROUP BY posting_year,posting_month