with cte_purchasing AS 
(	select distinct 
		ProcessId,
		ItemNo,
		Suppliercode,
		EOL,
		OrderDate,
		OrderItemPriceForeignCurrency,
		Currency,ProcessIDLastChangeDate,
		[GTS or Direct] = 	case when CreditorsNumber IN ('707063430','707063420','707063440','707063480','707063470','707063490','707063400','707063410','708000004','707407400','707410000') OR SupplierGroupNumber='IC00' then 'GTS' else 'Direct' end,
		LastOrderRanking = RANK() OVER(partition by ItemNo order by orderdate desc,ProcessIDLastChangeDAte desc,ProcessID desc),
		FirstOrderRanking = RANK() OVER(partition by ItemNo order by orderdate asc,ProcessIDLastChangeDAte asc,ProcessID asc)
	from [CT dwh 03 Intelligence].[dbo].[vFactPurchasingOrdersTransactions] 
	where 1= 1
		AND ISNULL(OrderItemPriceForeignCurrency,0) > 0

),
CTE_current_Price as 
(
	SELECT *
	FROM cte_purchasing 
	Where LastOrderRanking = 1
)
,
cte_last_price as 
(

	SELECT 
		p.ProcessId,
		p.ItemNo,
		p.EOL,
		p.OrderDate,
		p.OrderItemPriceForeignCurrency,
		p.Currency,
		p.[GTS or Direct] ,
		LastPriceOrderRanking = RANK() OVER(partition by p.ItemNo  order by p.orderdate desc,p.ProcessIDLastChangeDAte desc)
	FROM cte_purchasing p
	join CTE_current_Price cp
		on p.ItemNo = cp.ItemNo
	Where
		p.OrderItemPriceForeignCurrency <> cp.OrderItemPriceForeignCurrency
),
cte_previous_date as 
(

	SELECT 
		p.ProcessId,
		p.ItemNo,
		p.Suppliercode,
		p.EOL,
		p.OrderDate,
		p.OrderItemPriceForeignCurrency,
		p.Currency,
		p.[GTS or Direct] ,
		LastPriceOrderRanking = RANK() OVER(partition by p.ItemNo  order by p.orderdate asc,p.ProcessIDLastChangeDAte asc)
	FROM cte_purchasing p
	join CTE_current_Price cp
		on p.ItemNo = cp.ItemNo
	Where
		p.OrderItemPriceForeignCurrency = cp.OrderItemPriceForeignCurrency
	


)


SELECT 
	p.ItemNo,
	p.Suppliercode,
	p.ProcessId,
	p.EOL,
	p.Currency,
	p.[GTS or Direct],
	CurrentPrice = p.OrderItemPriceForeignCurrency,
	LastOrderDate = p.OrderDate,
	PriceChangeDate = f.OrderDate,
	PreviousPrice = l.OrderItemPriceForeignCurrency,
	FirstOrderDate = ft.OrderDate
FROM CTE_current_Price p
left JOIN cte_last_price l
	on p.ItemNo = l.ItemNo and LastPriceOrderRanking = 1
left JOIN cte_previous_date f
	on p.ItemNo = f.ItemNo and f.LastPriceOrderRanking = 1
left JOIN cte_purchasing ft
	on p.ItemNo = ft.ItemNo and ft.FirstOrderRanking = 1
--where  
--	p.ItemNo like '4%'