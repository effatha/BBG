select 
	it.ItemNo,
	[2020] = SUM(CASE WHEN YEAR(TransactionDAte) = 2020 THEN OrderQuantity ELSE 0 END),
	[2021] = SUM(CASE WHEN YEAR(TransactionDAte) = 2021 THEN OrderQuantity ELSE 0 END),
	[2022] = SUM(CASE WHEN YEAR(TransactionDAte) = 2022 THEN OrderQuantity ELSE 0 END),
	[2023] = SUM(CASE WHEN YEAR(TransactionDAte) = 2023 THEN OrderQuantity ELSE 0 END),
	[2024] = SUM(CASE WHEN YEAR(TransactionDAte) = 2024 THEN OrderQuantity ELSE 0 END)
FROM PL.PL_V_SALES_TRANSACTIONS s
INNER JOIN pl.pl_v_item it 
	on s.ItemId = it.ItemId
left join pl.pl_v_sales_channel ch
	on
		ch.ChannelId = s.ChannelId

WHERE
	YEAR(TransactionDAte) between 2020 and 2024
	AND
	ItemNo in ('10033132','10033133','10034972','10035464','10035469','10037804')
	AND
	--deliverycountry = 'DE'
	--and 
	--ch.ChannelCountry = 'DE'
	--and
	netOrderquantityest >0
	and 
	ISNULL(IncidentFlag,'N') ='N'
	and
	ch.ChannelGroup1 not in ('Mandanten','Intercompany','B2B')
	and
	ch.Channel not in ('Mandanten','Intercompany','B2B')

	and 
	ISNULL(ReasonforRejections,'') =''
	
	--and 
	--source = 'sge'
group by it.ItemNo
order by 1

--select * 
--from 
--pl.pl_v_item 
--where 	ItemNo in ('10033132','10033133','10034972','10035464','10035469','10037804')

