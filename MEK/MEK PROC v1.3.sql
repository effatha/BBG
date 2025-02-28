------------------------------------------------------------------------------------
------ 1 st PART preparation PREWORK TABLE used later in WHILE CYCLE ---------------
------------------------------------------------------------------------------------

insert into [TEST].[L0_MEK_PREWORK]([RLDNR], [RBUKRS], [WERKS], [FISCYEARPER], [BWTAR], [KTOSL], [GJAHR], [BELNR], [DOCLN], [BLART], [AWREF], [AWITEM], [AWTYP], [MATNR], [ROW_NUM_DATE], [RWCUR], [WSL], [RHCUR], [HSL], [KSL], [MSL], [LBKUM], [MLPTYP], [MLCATEG], [TIMESTAMP], [BUDAT], [BLDAT], [BWART], [TCODE], KSCHL, [VL_HEP_TOTAL_STOCK], [VL_HEP_TOTAL_VALUE_HEDGED], [AMT_HEP_PRICE_HEDGED], [MEK_MATERIAL_VALUE], [MEK_FREIGHT_VALUE], [MEK_CUSTOM_VALUE], [MEK_HEDGING_VALUE], [MEK_MATERIAL_PRICE], [MEK_FREIGHT_PRICE], [MEK_CUSTOM_PRICE], [MEK_HEDGING_PRICE])
select --1 169
acd.RLDNR
,acd.RBUKRS
,acd.WERKS 
,left(acd.BUDAT,7) as FISCYEARPER
,acd.BWTAR
,acd.KTOSL 
,acd.GJAHR 
,acd.BELNR 
,acd.DOCLN 
,acd.BLART 
,acd.AWREF 
,acd.AWITEM
,acd.AWTYP 
,acd.MATNR 
,ROW_NUMBER() OVER ( ORDER BY acd.WERKS, acd.MATNR, left(acd.BUDAT,7), acd.[TIMESTAMP] , acd.BELNR, acd.DOCLN asc) as ROW_NUM_DATE
,acd.RWCUR
,acd.WSL
,acd.RHCUR 
,acd.HSL
,acd.KSL
,acd.MSL 
,acd.LBKUM
,acd.MLPTYP 
,acd.MLCATEG 
,acd.[TIMESTAMP] 
,acd.BUDAT 
,acd.BLDAT
,mdoc.BWART 
,bkpf.TCODE
,r.KSCHL
,SUM(CASE 
		WHEN acd.KTOSL='WRX' THEN 0 
		ELSE acd.MSL 
	END) OVER (PARTITION BY acd.MATNR,acd.WERKS ORDER BY acd.WERKS, acd.MATNR, left(acd.BUDAT,7), acd.[TIMESTAMP] , acd.BELNR, acd.DOCLN asc) AS VL_HEP_TOTAL_STOCK
,SUM(CASE 
		WHEN acd.KTOSL<>'BSX' THEN 0 
		ELSE acd.KSL 
	END) OVER (PARTITION BY acd.MATNR,acd.WERKS ORDER BY acd.WERKS, acd.MATNR, left(acd.BUDAT,7), acd.[TIMESTAMP] , acd.BELNR, acd.DOCLN asc) AS [VL_HEP_TOTAL_VALUE_HEDGED]
,CASE WHEN (SUM(CASE WHEN acd.KTOSL='WRX' THEN 0 ELSE acd.MSL END) OVER (PARTITION BY acd.MATNR,acd.WERKS ORDER BY acd.WERKS, acd.MATNR, left(acd.BUDAT,7), acd.[TIMESTAMP] , acd.BELNR, acd.DOCLN asc))=0 
	  then 0 
	  else (SUM(CASE WHEN acd.KTOSL<>'BSX' THEN 0 ELSE acd.KSL END) OVER (PARTITION BY acd.MATNR,acd.WERKS ORDER BY acd.WERKS, acd.MATNR, left(acd.BUDAT,7), acd.[TIMESTAMP] , acd.BELNR, acd.DOCLN asc))/(SUM(CASE WHEN acd.KTOSL='WRX' THEN 0 ELSE acd.MSL END) OVER (PARTITION BY acd.MATNR,acd.WERKS ORDER BY acd.WERKS, acd.MATNR, left(acd.BUDAT,7), acd.[TIMESTAMP] , acd.BELNR, acd.DOCLN asc)) 
	  end as [AMT_HEP_PRICE_HEDGED]
,0 as MEK_MATERIAL_VALUE
,0 as MEK_FREIGHT_VALUE
,0 as MEK_CUSTOM_VALUE
,0 as MEK_HEDGING_VALUE
,0 as MEK_MATERIAL_PRICE
,0 as MEK_FREIGHT_PRICE
,0 as MEK_CUSTOM_PRICE
,0 as MEK_HEDGING_PRICE

from [L0].[L0_S4HANA_0fi_acdoca_10] acd 

	left join L0.L0_S4HANA_2LIS_03_BF mdoc
		on  acd.aworg = mdoc.mjahr
		and acd.awref = mdoc.mblnr
		and right(acd.awitem, 4) = mdoc.zeile 

	left join [L0].[L0_S4HANA_Z_FI_BKPF] as bkpf -- source table: bkpf
		on acd.RBUKRS = bkpf.BUKRS 
		and acd.GJAHR = bkpf.GJAHR 
		and acd.BELNR = bkpf.BELNR
		
	left join L0.L0_S4HANA_2LIS_06_INV as r -- source table: rseg
		on acd.GJAHR = r.GJAHR
		and acd.AWREF = r.BELNR
		and acd.AWITEM = r.BUZEI

where acd.RLDNR = '0L' and acd.KTOSL in ('BSX','FR1','FR3','WRX') and acd.bwtar='100' and acd.werks not in ('5100', '5101', '')
and acd.MATNR like '%10030546%' --and acd.WERKS='1000') /*or (acd.MATNR like '%10035788%'  and acd.WERKS='1000') or 
--(acd.MATNR like '%10035788%' and acd.WERKS='1100')) --and acd.BELNR ='4903076262' ;*/

-----------------------------------------------------------------------
-----------------2 part--- used prework table [TEST].[L0_MEK_PREWORK]
-----------------------------------------------------------------------

DECLARE @Counter INT , @MaxId INT, @MekMaterialValue as NUMERIC(18,4), @MekMaterialPrice as NUMERIC(18,4)
, @MekFreightValue as NUMERIC(18,4), @MekFreightPrice as NUMERIC(18,4), @MekHedgingValue as NUMERIC(18,4), @MekHedgingPrice as NUMERIC(18,4)
, @MekCustomValue as NUMERIC(18,4), @MekCustomPrice as NUMERIC(18,4); 

SELECT @Counter = min(ROW_NUM_DATE) , @MaxId =30 /*max(ROW_NUM_DATE)*/  -- First and last record for loop 
FROM [TEST].[L0_MEK_PREWORK]

WHILE(@Counter IS NOT NULL
      AND @Counter <= 30) --@MaxId
BEGIN

WITH TEMP_VALUES as ------------------------VALUE PART------------------
(
SELECT 
CASE 
	WHEN (m.[MATNR] is null) or (m.[MATNR]<>mp.[MATNR]) or (m.[WERKS]<>mp.[WERKS]) THEN  -- checking previous record 
			CASE 
				WHEN (mp.BLART<>'RE' and mp.KTOSL='BSX' and mp.MLPTYP='BB') or (mp.MLPTYP='BBK' and mp.BWART in ('107','108')) THEN 0
				ELSE mp.KSL
			END 
	ELSE 
		CASE 
			WHEN (mp.BLART<>'RE' and mp.KTOSL='BSX' and mp.MLPTYP='BB') or (mp.MLPTYP='BBK' and mp.BWART in ('107','108')) or (mp.MSL<>0 and mp.HSL=0) or (mp.BLART='PR' and mp.TCODE='') THEN m.[MEK_MATERIAL_VALUE] 
			WHEN mp.BLART<>'RE' and mp.KTOSL='WRX' THEN -(mp.KSL) + m.[MEK_MATERIAL_VALUE]
			WHEN (mp.BLART='RE' and mp.KTOSL='BSX' and mp.KSCHL='') or (mp.BLART='PR' and mp.TCODE<>'') or (mp.MSL>0 and mp.BWART='641') THEN mp.KSL + m.[MEK_MATERIAL_VALUE] 
			ELSE m.[MEK_MATERIAL_PRICE]*mp.VL_HEP_TOTAL_STOCK
		END	 
END	as MekMaterialValue
,CASE 
	WHEN (m.[MATNR] is null) or (m.[MATNR]<>mp.[MATNR]) or (m.[WERKS]<>mp.[WERKS]) THEN  -- checking previous record 
			CASE 
				WHEN (mp.KTOSL='FR1'  and mp.KSCHL='') or  mp.KSCHL in ('ZFKV','ZFV1','ZFV2')  THEN -mp.KSL
				ELSE 0
			END 
	ELSE 
		CASE 
			WHEN (mp.KTOSL='BSX' and mp.MLPTYP='BB' and mp.KSCHL='') or (mp.MLPTYP='BBK' and mp.BWART in ('107','108')) or (mp.KTOSL in ('FR1','FR3') and mp.KSCHL in ('ZFKV','ZFV1','ZFV2')) or (mp.BWART in ('107','108') and mp.KTOSL<>'FR1') or (mp.KSL=0 and mp.MSL<>0) THEN m.[MEK_FREIGHT_VALUE]
			ELSE 
				CASE 
					WHEN (mp.KTOSL='FR1' and mp.BLART<>'RE') or  (mp.KSCHL in ('ZFKV','ZFV1','ZFV2')) THEN m.[MEK_FREIGHT_VALUE] + mp.KSL *
						(CASE 
							WHEN mp.KTOSL='BSX' and mp.KSCHL in ('ZFKV','ZFV1','ZFV2')  THEN 1
							ELSE -1
						END)
				ELSE mp.VL_HEP_TOTAL_STOCK * m.[MEK_FREIGHT_PRICE]
				END 
		END	 
END as MekFreightValue
,CASE 
	WHEN (m.[MATNR] is null) or (m.[MATNR]<>mp.[MATNR]) or (m.[WERKS]<>mp.[WERKS]) THEN  -- checking previous record 
			CASE 
				WHEN (mp.BLART='PR' and mp.TCODE='') THEN mp.KSL
				ELSE 0
			END 
	ELSE 
		CASE 
			WHEN (mp.BLART='PR' and mp.TCODE='') THEN m.[MEK_HEDGING_VALUE] + mp.KSL
			WHEN (mp.BLART<>'RE' and mp.KTOSL='BSX' and mp.MLPTYP='BB') or (mp.MLPTYP='BBK' and mp.BWART in ('107','108')) or (mp.MSL<>0 and mp.HSL=0) THEN m.[MEK_HEDGING_VALUE]
			ELSE m.[MEK_HEDGING_PRICE] *mp.VL_HEP_TOTAL_STOCK
		END	 
END as MekHedgingValue
,CASE 
	WHEN (m.[MATNR] is null) or (m.[MATNR]<>mp.[MATNR]) or (m.[WERKS]<>mp.[WERKS]) THEN  -- checking previous record 
			CASE 
				WHEN (mp.KTOSL='FR3'  and mp.KSCHL='')  or (mp.KTOSL in ('FR1','FR3') and mp.KSCHL in ('ZCU1','ZCU2')) THEN -mp.KSL
				ELSE 0
			END 
	ELSE 
		CASE 
			WHEN (mp.KTOSL='BSX' and mp.MLPTYP='BB' and mp.KSCHL='') or (mp.MLPTYP='BBK' and mp.BWART in ('107','108')) or (mp.KTOSL in ('FR1','FR3') and mp.KSCHL in ('ZCU1','ZCU2')) or (mp.BWART in ('107','108') and mp.KTOSL<>'FR3') or (mp.KSL=0 and mp.MSL<>0) THEN m.[MEK_CUSTOM_VALUE] 
			ELSE 
				CASE 
					WHEN (mp.KTOSL='FR3' and mp.BLART<>'RE') or  mp.KSCHL in ('ZCU1','ZCU2') THEN m.[MEK_CUSTOM_VALUE] + mp.KSL *
						(CASE 
							WHEN mp.KTOSL='BSX' and mp.KSCHL in ('ZCU1','ZCU2')  THEN 1
							ELSE -1
						END)
					ELSE mp.VL_HEP_TOTAL_STOCK * m.[MEK_CUSTOM_PRICE]
				END 
		END	 
END as MekCustomValue
,mp.ROW_NUM_DATE

FROM [TEST].[L0_MEK_PREWORK] mp
	left join [TEST].[L0_MEK] m
		on m.[ROW_NUM_DATE]=(mp.ROW_NUM_DATE) - 1 
		
WHERE mp.[ROW_NUM_DATE]=@Counter)

SELECT   ------------------------PRICE PART------------------

@MekMaterialValue = tv.MekMaterialValue
,@MekMaterialPrice = CASE 
						WHEN (m.[MATNR] is null) or (m.[MATNR]<>mp.[MATNR]) or (m.[WERKS]<>mp.[WERKS]) THEN  -- checking previous record 
								CASE 
									WHEN mp.VL_HEP_TOTAL_STOCK=0 THEN 0
									ELSE 
										tv.MekMaterialValue/mp.VL_HEP_TOTAL_STOCK
								END 
						ELSE 
							CASE 
								WHEN (mp.HSL<>0) and ((mp.BLART<>'RE' and mp.KTOSL='BSX' and mp.MLPTYP='BB') or (mp.MLPTYP='BBK' and mp.BWART in ('107','108'))) or mp.VL_HEP_TOTAL_STOCK=0 THEN m.MEK_MATERIAL_PRICE
								ELSE tv.MekMaterialValue/mp.VL_HEP_TOTAL_STOCK
							END	
					END
,@MekFreightValue = tv.MekFreightValue
,@MekFreightPrice = CASE 
						WHEN (m.[MATNR] is null) or (m.[MATNR]<>mp.[MATNR]) or (m.[WERKS]<>mp.[WERKS]) THEN -- checking previous record 
							CASE 
									WHEN ((mp.KTOSL='BSX' and mp.MLPTYP='BB' and mp.KSCHL='')  or (mp.MLPTYP='BBK' and  mp.BWART in ('107','108'))) THEN 0
									ELSE tv.MekFreightValue/mp.VL_HEP_TOTAL_STOCK
							END 
						ELSE 
							CASE 
								WHEN ((mp.KTOSL='BSX' and mp.MLPTYP='BB' and mp.KSCHL='') or (mp.VL_HEP_TOTAL_STOCK=0) or (mp.MLPTYP='BBK' and  mp.BWART in ('107','108'))) THEN m.MEK_FREIGHT_PRICE
								ELSE 
									CASE 
										WHEN mp.VL_HEP_TOTAL_STOCK=0 THEN 0
										ELSE tv.MekFreightValue/mp.VL_HEP_TOTAL_STOCK
									END
							END 
					END
,@MekHedgingValue = tv.MekHedgingValue
,@MekHedgingPrice = CASE 
						WHEN (m.[MATNR] is null) or (m.[MATNR]<>mp.[MATNR]) or (m.[WERKS]<>mp.[WERKS]) THEN  -- checking previous record 
								CASE 
									WHEN mp.VL_HEP_TOTAL_STOCK=0 THEN 0
									ELSE tv.MekHedgingValue/mp.VL_HEP_TOTAL_STOCK
								END 
						WHEN  mp.VL_HEP_TOTAL_STOCK=0 THEN m.MEK_HEDGING_PRICE
						ELSE tv.MekHedgingValue/mp.VL_HEP_TOTAL_STOCK
					END
,@MekCustomValue = tv.MekCustomValue
,@MekCustomPrice = CASE 
						WHEN (m.[MATNR] is null) or (m.[MATNR]<>mp.[MATNR]) or (m.[WERKS]<>mp.[WERKS]) THEN  -- checking previous record 
								CASE 
									WHEN ((mp.KTOSL='BSX' and mp.MLPTYP='BB' and mp.KSCHL='') or (mp.MLPTYP='BBK' and mp.BWART in ('107','108'))) THEN 0
									ELSE 
										CASE 
											WHEN mp.VL_HEP_TOTAL_STOCK=0 THEN 0
											ELSE tv.MekCustomValue/mp.VL_HEP_TOTAL_STOCK
										END 
								END 
						ELSE 
							CASE 
								WHEN ((mp.KTOSL='BSX' and mp.MLPTYP='BB' and mp.KSCHL='') or (mp.VL_HEP_TOTAL_STOCK=0) or (mp.MLPTYP='BBK' and  mp.BWART in ('107','108'))) THEN m.MEK_FREIGHT_PRICE 
								ELSE 
									CASE 
										WHEN mp.VL_HEP_TOTAL_STOCK=0 THEN 0
										ELSE tv.MekCustomValue/mp.VL_HEP_TOTAL_STOCK
									END
							END 
					END

FROM [TEST].[L0_MEK_PREWORK] mp
	left join [TEST].[L0_MEK] m
		on m.[ROW_NUM_DATE]=(mp.ROW_NUM_DATE) - 1  
	left join TEMP_VALUES tv
		on mp.ROW_NUM_DATE=tv.ROW_NUM_DATE

WHERE mp.[ROW_NUM_DATE]=@Counter

Insert into [TEST].[L0_MEK]([RLDNR], [RBUKRS], [WERKS], [FISCYEARPER], [BWTAR], [KTOSL], [GJAHR], [BELNR], [DOCLN], [BLART], [AWREF], [AWITEM], [AWTYP], [MATNR], [ROW_NUM_DATE], [RWCUR], [WSL], [RHCUR], [HSL], [KSL], [MSL], [LBKUM], [MLPTYP], [MLCATEG], [TIMESTAMP], [BUDAT], [BLDAT], [BWART], [TCODE], [VL_HEP_TOTAL_STOCK], [VL_HEP_TOTAL_VALUE_HEDGED], [AMT_HEP_PRICE_HEDGED], [MEK_MATERIAL_VALUE], [MEK_FREIGHT_VALUE], [MEK_CUSTOM_VALUE], [MEK_HEDGING_VALUE], [MEK_MATERIAL_PRICE], [MEK_FREIGHT_PRICE], [MEK_CUSTOM_PRICE], [MEK_HEDGING_PRICE],[KSCHL])
select [RLDNR], [RBUKRS], [WERKS], [FISCYEARPER], [BWTAR], [KTOSL], [GJAHR], [BELNR], [DOCLN], [BLART], [AWREF], [AWITEM], [AWTYP], [MATNR], [ROW_NUM_DATE], [RWCUR], [WSL], [RHCUR], [HSL], [KSL], [MSL], [LBKUM], [MLPTYP], [MLCATEG], [TIMESTAMP], [BUDAT], [BLDAT], [BWART], [TCODE], [VL_HEP_TOTAL_STOCK], [VL_HEP_TOTAL_VALUE_HEDGED], [AMT_HEP_PRICE_HEDGED], @MekMaterialValue, @MekFreightValue, @MekCustomValue, @MekHedgingValue, @MekMaterialPrice, @MekFreightPrice, @MekCustomPrice, @MekHedgingPrice, [KSCHL]
from [TEST].[L0_MEK_PREWORK]
where [ROW_NUM_DATE]=@Counter

SET @Counter  = @Counter  + 1      

END

-----------------------------------------------------------------------
-----------------3 part--- prepare [TEST].[L0_MEK] for [L1].[L1_FACT_F_MEK]
-----------------------------------------------------------------------

WITH TT as (
Select
m.*
,ROW_NUMBER() OVER (PARTITION BY MATNR,WERKS,BUDAT  ORDER BY BELNR desc) as ROW_NUM

from [TEST].[L0_MEK] m

--order by ROW_NUM_DATE asc
)

select

WERKS 
,MATNR 
,BUDAT
,[VL_HEP_TOTAL_STOCK] as VL_HEP_TOTAL_STOCK
,[VL_HEP_TOTAL_VALUE_HEDGED] as AMT_HEP_TOTAL_VALUE_HEDGED_EUR
,[AMT_HEP_PRICE_HEDGED] as AMT_HEP_PRICE_HEDGED_EUR
,[MEK_MATERIAL_VALUE] as AMT_MEK_MATERIAL_VALUE_EUR
,[MEK_FREIGHT_VALUE] as AMT_MEK_FREIGHT_VALUE_EUR
,[MEK_CUSTOM_VALUE] as AMT_MEK_CUSTOM_VALUE_EUR
,[MEK_HEDGING_VALUE] as AMT_MEK_HEDGING_VALUE_EUR
,[MEK_MATERIAL_PRICE] as AMT_MEK_MATERIAL_PRICE_EUR
,[MEK_FREIGHT_PRICE] as AMT_MEK_FREIGHT_PRICE_EUR
,[MEK_CUSTOM_PRICE] as AMT_MEK_CUSTOM_PRICE_EUR
,[MEK_HEDGING_PRICE] as AMT_MEK_HEDGING_PRICE_EUR

from TT

where ROW_NUM=1

ORDER BY WERKS, MATNR, BUDAT asc

---- through WERKS/MATNR/BUDAT join to [L1].[L1_FACT_F_MEK] ... In case any BUDAT will be missing in [TEST].[L0_MEK] then use for this BUDAT last available BUDAT 