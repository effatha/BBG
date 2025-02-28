select 
	acd.RBUKRS,
	--acd.WERKS, 
	--acd.FISCYEARPER, 
	--acd.BWTAR, 
	acd.KTOSL, 
	--acd.GJAHR, 
	acd.BELNR, 
	acd.DOCLN, 
	acd.BLART, 
	acd.AWREF, 
	acd.AWITEM,
	--acd.AWTYP, 
	acd.MATNR, 
	acd.RWCUR, 
	acd.WSL, 
	acd.RHCUR, 
	acd.HSL,
	acd.KSL,
	acd.MSL, 
	acd.LBKUM,
	acd.MLPTYP, 
	--acd.MLCATEG, 
	acd.TIMESTAMP
	--acd.BUDAT, 
	--acd.BLDAT,
	--mdoc.BWART, 
	--bkpf.TCODE
--	rseg.KSCHL
,SUM(CASE WHEN acd.KTOSL='WRX' THEN 0 ELSE acd.MSL END) OVER (PARTITION BY acd.MATNR,acd.WERKS ORDER BY acd.WERKS, acd.MATNR, acd.[TIMESTAMP], acd.BELNR, acd.DOCLN asc) AS HEP_TOTAL_STOCK
,SUM(CASE WHEN acd.KTOSL<>'BSX' THEN 0 ELSE acd.KSL END) OVER (PARTITION BY acd.MATNR,acd.WERKS ORDER BY acd.WERKS, acd.MATNR, acd.[TIMESTAMP], acd.BELNR, acd.DOCLN asc) AS HEP_TOTAL_VALUE_HEDGED
,CASE WHEN (SUM(CASE WHEN acd.KTOSL='WRX' THEN 0 ELSE acd.MSL END) OVER (PARTITION BY acd.MATNR,acd.WERKS ORDER BY acd.WERKS, acd.MATNR, acd.[TIMESTAMP], acd.BELNR, acd.DOCLN asc))=0 then 0 else (SUM(CASE WHEN acd.KTOSL<>'BSX' THEN 0 ELSE acd.KSL END) OVER (PARTITION BY acd.MATNR,acd.WERKS ORDER BY acd.WERKS, acd.MATNR, acd.[TIMESTAMP], acd.BELNR, acd.DOCLN asc))/(SUM(CASE WHEN acd.KTOSL='WRX' THEN 0 ELSE acd.MSL END) OVER (PARTITION BY acd.MATNR,acd.WERKS ORDER BY acd.WERKS, acd.MATNR, acd.[TIMESTAMP], acd.BELNR, acd.DOCLN asc)) end as HEP_PRICE_HEDGED
,SPLIT_STOCK_MATERIAL = SUM(
			CASE WHEN (acd.BLART = 'RE' AND acd.KTOSL='BSX' AND acd.MLPTYP = 'BB') OR ((acd.MLPTYP = 'BBK') AND (BWART IN('107','108')) )
						THEN 0 								
		ELSE acd.HSL END) OVER (PARTITION BY acd.MATNR,acd.WERKS ORDER BY acd.WERKS, acd.MATNR, acd.[TIMESTAMP], acd.BELNR, acd.DOCLN asc) 
from l0.L0_S4HANA_0FI_ACDOCA_10 as acd -- source table: acdoca
left join l0.L0_S4HANA_2LIS_03_BF as mdoc -- source table: matdoc
	on  acd.aworg = mdoc.mjahr
	and acd.awref = mdoc.mblnr
	and right(acd.awitem, 4) = mdoc.zeile 
left join l0.L0_S4HANA_Z_FI_BKPF as bkpf -- source table: bkpf
	on acd.RBUKRS = bkpf.BUKRS 
	and acd.GJAHR = bkpf.GJAHR 
	and acd.BELNR = bkpf.BELNR
--left join 2LIS_06_INV as r -- source table: rseg
--	on acd.aworg = r.gjahr
--	and acd.awref = r.belnr
--	and right(acd.awitem, 4) = r.buzei
where 
	acd.RLDNR = '0L' 
	and acd.KTOSL in ('BSX','FR1','FR3','WRX') 
	and acd.bwtar='100' 
	and isnull(acd.werks,'') not in ('5100', '5101', '')
	and cast(acd.MATNR as int ) ='10030546'
	and (TIMESTAMP like '202007%' or TIMESTAMP like '202008%' or TIMESTAMP like '202009%')
order by acd.WERKS, acd.MATNR, acd.TIMESTAMP, acd.BELNR, acd.DOCLN

/****************************
KTOSL => Tax Transaction Key
WRX => GR/IR Clearing account (Goods Receipt and Invoice receipt clearing)
BSX = > Inventory Posting
FR1 => Freight  clearing
FR3 => Customs Clearing
****************************/


Select Distinct KTOSL from l0.L0_S4HANA_0FI_ACDOCA_10 