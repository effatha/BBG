select
	acd.RBUKRS,
	acd.WERKS, 
	acd.FISCYEARPER, 
	acd.BWTAR, 
	acd.KTOSL, 
	acd.GJAHR, 
	acd.BELNR, 
	acd.DOCLN, 
	acd.BLART, 
	acd.AWREF, 
	acd.AWITEM,
	acd.AWTYP, 
	acd.MATNR, 
	acd.RWCUR, 
	acd.WSL, 
	acd.RHCUR, 
	acd.HSL,
	acd.KSL,
	acd.MSL, 
	acd.LBKUM,
	acd.MLPTYP, 
	acd.MLCATEG, 
	acd.TIMESTAMP, 
	acd.BUDAT, 
	acd.BLDAT, 
	mdoc.BWART, 
	bkpf.TCODE,
	case
		when acd.KTOSL='FR1' or acd.KTOSL='FR3' then 'BZNK'
		when acd.MLCATEG='ZU' and acd.BLART!='RE' and mdoc.BWART!='Z91' and mdoc.BWART!='Z92' then 'WE'
		when bkpf.TCODE='MR21' or bkpf.TCODE='MR22' then 'PÄ'
		when acd.MLCATEG='VN' or (acd.MLCATEG='ZU' and (mdoc.BWART='Z91' or mdoc.BWART='Z92')) then 'WA'
		when acd.BLART='RE' and acd.MLCATEG='ZU' then 'RE'
		else ''
	end as [TransactionType],
from tSAP_ACDOCA as acd -- corresponding extractor table: 0FI_ACDOCA_10
left join tSAP_MATDOC as mdoc -- corresponding extractor table: 2LIS_03_BF
	on  acd.aworg = mdoc.mjahr
	and acd.awref = mdoc.mblnr
	and right(acd.awitem, 4) = mdoc.zeile -- corresponding extractor table: Z_FI_BSEG_BKPF
left join tSAP_BKPF as bkpf 
	on acd.RBUKRS = bkpf.BUKRS 
	and acd.GJAHR = bkpf.GJAHR 
	and acd.BELNR = bkpf.BELNR
where acd.RLDNR = '0L' and acd.KTOSL in ('BSX','FR1','FR3') and acd.bwtar='100'
order by acd.WERKS, acd.MATNR, acd.FISCYEARPER, acd.TIMESTAMP, acd.BELNR, acd.DOCLN
