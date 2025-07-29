DECLARE @DOCUMENTO_NO AS VARCHAR(50)
DECLARE @ITEM AS VARCHAR(50)
DECLARE @DOCUMENTO_LINE AS INT

SET @DOCUMENTO_NO =  '4501021284'
--SET @ITEM =  '10034971'

SELECT 'L1_FACT_A_PURCHASING_TRANSACTIONS',CAST(CD_ITEM as int) ItemNO,FL_DELIVERY_COMPLETED,st.TXTMD,
* 
FROM TEST.L1_FACT_A_PURCHASING_TRANSACTIONS s
 LEFT JOIN L0.L0_S4HANA_0STOR_LOC_TEXT st 
      on st.werks = s.CD_PLANT and st.LGORT = s.CD_STORAGE_LOCATION
    WHERE 1=1
	    AND CD_COMPANY_CODE = '1000'
        AND CD_PURCHASING_CATEGORY IN ('Z101','Z102','Z103','Z105','Z106')
        AND CD_GR_MESSAGE <> 'X'  ---- Document is not fulfilled
        AND CD_DOCUMENT_NO = @DOCUMENTO_NO
       --AND
       --CASE 
       --     WHEN LEFT(CAST(CD_ITEM as int),2)='11' THEN '10' 
       --     ELSE LEFT(CAST(CD_ITEM as int),2) END 
       --     + RIGHT(CAST(CD_ITEM as int),6) = @ITEM

       AND (FL_DELIVERY_COMPLETED <> 'Y' OR (FL_DELIVERY_COMPLETED <> 'N' AND st.TXTMD like 'Kitting%') )

SELECT top 10 
'L1_FACT_A_INBOUND_DELIVERY_NOTES' ,
*
FROM TEST.L1_FACT_A_INBOUND_DELIVERY_NOTES 
WHERE 1=1
    AND
    CD_PURCHASING_DOCUMENT_NO = @DOCUMENTO_NO
    AND
    CD_ITEM =@ITEM

    select * from  TEST.[L0_MI_STOCK_INDICATOR]

  SELECT 'STOCK',bf.BWART,bf.SHKZG, bf.EBELN,bf.EBELP,bf.MATNR,bf.ZZ_VBELN_IM,bf.ZZ_VBELP_IM,bf.MENGE,bf.*
  FROM L0.L0_S4HANA_2LIS_03_BF bf
  --INNER JOIN TEST.[L0_MI_STOCK_INDICATOR] stck
  --		ON stck.BWART = bf.BWART 
		--	AND bf.SHKZG = stck.SHKZG
  WHERE
  EBELN = @DOCUMENTO_NO --and EBELP = 190
  --AND
  --MATNR = @ITEM
  ORDER BY bf.ZZ_VBELP_IM



  --SELECT * FROM  L0.L0_S4HANA_2LIS_03_BF bf where ZZ_VBELN_IM = '0180120627' and  ebeln = '4501012402' and ebelp = '00010'
  --SELECT ELIKZ,LOEKZ,* FROM  TEST.L0_S4HANA_2LIS_02_ITM bf where ebeln = '4501012925' and cast(matnr as int) = '10038759' --ebelp = '00010' 
  --SELECT ELIKZ,LOEKZ,* FROM  L0.L0_S4HANA_2LIS_02_ITM bf where ebeln = '4501012925' and cast(matnr as int) = '10038759'-- ebelp = '00010' 

  --SELECT * FROM  TEST.[L0_S4HANA_Z_MM_LIKP_LIPS] bf where VGBEL = '4501012402' and VGPOS = 10
  --SELECT max(load_timestamp) FROM  TEST.L0_S4HANA_2LIS_02_SCN bf where ebeln = '4501012402' and ebelp = '00010'


    SELECT top 10 * FROM  L0.L0_S4HANA_2LIS_02_ITM bf  order by load_timestamp desc

    where 
    ebeln = '4501021897' 
            and ebelp = 10
SELECT *    FROM TEST.L0_S4HANA_2LIS_02_HDR HDR where 
    ebeln = '4501021897' 



	   SELECT max(load_timestamp)
            FROM  [L0].[L0_S4HANA_2LIS_02_SCN] SCN
            where 
            EBELN = '4501018958'
            and ebelp = 10


 SELECT ITM.EBELP,
  *
    FROM L0.L0_S4HANA_2LIS_02_HDR HDR
    INNER JOIN L0.L0_S4HANA_2LIS_02_ITM ITM
        ON HDR.EBELN = ITM.EBELN
    LEFT JOIN TEST.L0_MI_TRANSACTION_TYPE TYP 
        ON TYP.TRANSACTIONTYPESHORT = HDR.BSTYP
        AND TYP.SOURCETYPE = 'BSTYP'
    LEFT JOIN [L0].[L0_S4HANA_2LIS_02_SCL] SCL
        ON 
            SCL.EBELN = ITM.EBELN
            AND
            SCL.EBELP = ITM.EBELP
    
    WHERE 1=1
    --AND
    --    ISNULL(itm.ROCANCEL,'') <> 'R'
    AND
        HDr.EBELN = '4501018795'
        AND 
        CAST(ITM.MATNR as int) = 10046212
        order by itm.ebelp



    SELECT 
        *
    FROM TEST.L1_FACT_A_INBOUND_DELIVERY_NOTES 
    WHERE
    CD_PURCHASING_DOCUMENT_NO = '4501018795'
    AND CD_ITEM = 10046212


    where 1=1
    FROM  [TEST].[L0_S4HANA_Z_MM_LIKP_LIPS] AS A 

SELECT
    MENGE, BWART, SHKZG,*
FROM L0.L0_S4HANA_2LIS_03_BF bf
WHERE
    ZZ_VBELN_IM = '0180720377'
    AND 
    ZZ_VBELP_IM = '10'


SELECT * FROM TEST.[L0_MI_STOCK_INDICATOR] stck

UPDATE TEST.[L0_MI_STOCK_INDICATOR]  SET VL_MULTIPLIER = 0 WHERE BWART = 122 and SHKZG ='H'


    
	SELECT     bf.MENGE, bf.BWART, bf.SHKZG,VL_MULTIPLIER,*

		--CD_DELIVERY_DOCUMENT_NO = bf.ZZ_VBELN_IM,
		--CD_DELIVERY_DOCUMENT_LINE = bf.ZZ_VBELP_IM,
		--VL_GR_QTY = SUM(ISNULL(MENGE,0) * ISNULL(VL_MULTIPLIER,0))
    FROM L0.L0_S4HANA_2LIS_03_BF bf
	INNER JOIN TEST.[L0_MI_STOCK_INDICATOR] stck
		ON stck.BWART = bf.BWART 
			AND bf.SHKZG = stck.SHKZG
    WHERE  1=1
	and bf.ZZ_VBELN_IM = '0180720377'    AND 
    ZZ_VBELP_IM = '900001'

	GROUP BY bf.ZZ_VBELN_IM, bf.ZZ_VBELP_IM
	


    select * from L0.L0_S4HANA_2LIS_02_ITM ITM where EBELN = '4501021095'
        AND 
        CAST(ITM.MATNR as int) = 11036074

    select * from TEST.L0_S4HANA_2LIS_02_ITM ITM where EBELN = '4501021095'
        AND 
        CAST(ITM.MATNR as int) = 11036074


select new.Load_timestamp, old.Load_timestamp, new.Menge,old.menge, * 
from L0.L0_S4HANA_2LIS_02_ITM new
inner join TEST.L0_S4HANA_2LIS_02_ITM old
on 
    new.ebeln = old.ebeln
    and new.ebelp =old.ebelp
 WHERE
    old.menge <> new.menge
and isnull(old.Rocancel,'') <> 'R'
and isnull(new.Rocancel,'') <> 'R'
and new.load_timestamp < '2025-03-18 11:26:18.0000000'



sELECT *  FROM TEST.L1_FACT_A_PURCHASING_TRANSACTIONS where CD_DOCUMENT_NO = '4501020975' 
sELECT * FROM TEST.L1_FACT_A_INBOUND_DELIVERY_NOTES where cd_delivery_no = '0180751775'
sELECT * FROM L0.L0_S4HANA_Z_MM_LIKP_LIPS where AUFNR = '0180809316'


SELECT DISTINCT 
		CD_PURCHASING_DOCUMENT_NO	= itm.EBELN,
		CD_PURCHASING_DOCUMENT_LINE = itm.EBELP,
        VL_ITEM_QTY = itm.MENGE
	FROM [L0].L0_S4HANA_2LIS_02_ITM itm
	LEFT JOIN [L0].L0_S4HANA_Z_MM_LIKP_LIPS lips
		on itm.EBELN = lips.VGBEL
			and CAST(itm.EBELP as int) = CAST(Lips.VGPOS as int)
	LEFT JOIN [L0].L0_S4HANA_2LIS_04_P_MATNR po
		on po.ZZ_CY_SEQNR = CONCAT(cast(itm.EBELN as bigint),CAST(itm.EBELP as int))
	LEFT JOIN [L0].L0_S4HANA_Z_MM_LIKP_LIPS lips_kit
		on lips_kit.AUFNR = po.AUFNR
		and lips_kit.POSNR_PP = po.POSNR
    WHERE
         lips_kit.FOLAR = 'DIG' --- Intercompany Billing
            AND
            ISNULL(itm.ROCANCEL,'')<>'R'
       -- ISNULL(lips_kit.vlstk,'') NOT IN('C','')
        and    ISNULL(lips_kit.vlstk,'') NOT IN('')

        and ebeln  = '4501020975' and cast(itm.matnr as int)=  '11028425'


  SELECT *  FROM [L0].L0_S4HANA_2LIS_02_ITM itm where ebeln = '4501021248' and cast(ebelp as int) = 230

SELECT * FROM TEST.L1_FACT_A_INBOUND_DELIVERY_NOTES where CD_PURCHASING_DOCUMENT_NO = '4501020975' and CD_PURCHASING_DOCUMENT_LINE = 50

SELECT* FROM [L0].L0_S4HANA_2LIS_04_P_MATNR po where ZZ_CY_SEQNR like '450102124850%'

sELECT top 10 * FROM TEST.L1_FACT_A_INBOUND_DELIVERY_NOTES where cd_delivery_no = '000001004956'
SELECT vlstk,* FROM [L0].L0_S4HANA_Z_MM_LIKP_LIPS where AUFNR = '000001004987'
sELECT * FROM L0.L0_S4HANA_0STOR_LOC_TEXT where txtmd = 'Kitting'


SELECT * FROM [TEST].[PL_V_FUTURE_INBOUND]  where CD_DOCUMENT_NO = '4501021248'