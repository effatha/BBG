--- original table [TEST].[L0_S4HANA_2LIS_02_HDR_FULL] ; First Load timestamp '2025-03-18 10:56:29.000'
--- Backt table od data layer from olddwh: TEST.L0_S4HANA_2LIS_02_ITM_FULL ; from 19032025

select distinct load_timestamp from [TEST].[L0_S4HANA_2LIS_02_HDR]

---first we update the records in the new dwh to deleted (R) if they are not in the base table

UPDATE hdr SET 
    hdr.ROCANCEL = 'R', hdr.Load_timestamp = '2025-03-17' --- to be able to identify records updated
FROM  TEST.L0_S4HANA_2LIS_02_HDR hdr
LEFT JOIN TEST.L0_S4HANA_2LIS_02_HDR_FULL f
    on f.ebeln =hdr.ebeln 

WHERE 
    hdr.LOAD_TIMESTAMP = '2025-03-18 10:56:29.000' --- only from the full load 
    and 
    f.ebeln is null
    and ISNULL(hdr.ROCANCEL,'') = ''

--- second, we updated the matching records with the data from the old dwl bck


UPDATE hdr SET 
    hdr.HDRVORG = bck.HDRVORG
    ,hdr.ALIEF = bck.ALIEF
    ,hdr.ARECH = bck.ARECH
    ,hdr.BEDAT = bck.BEDAT
    ,hdr.BSART = bck.BSART
    ,hdr.BSTYP = bck.BSTYP
    ,hdr.BUDAT = bck.BUDAT
    ,hdr.EBELN = bck.EBELN
    ,hdr.EKGRP = bck.EKGRP
    ,hdr.EKORG = bck.EKORG
    ,hdr.KDATB = bck.KDATB
    ,hdr.KDATE = bck.KDATE
    ,hdr.LBLIF = bck.LBLIF
    ,hdr.LIFNR = bck.LIFNR
    ,hdr.LIFRE = bck.LIFRE
    ,hdr.LLIEF = bck.LLIEF
    ,hdr.LOGSY = bck.LOGSY
    ,hdr.ORGLOGSY = bck.ORGLOGSY
    ,hdr.RESWK = bck.RESWK
    ,hdr.STATU = bck.STATU
    ,hdr.SYDAT = bck.SYDAT
    ,hdr.WAERS = bck.WAERS
    ,hdr.WKURS = bck.WKURS
    ,hdr.BRESWK = bck.BRESWK
    ,hdr.BSAKZ = bck.BSAKZ
    ,hdr.BUKRS = bck.BUKRS
    ,hdr.FRGRL = bck.FRGRL
    ,hdr.FSH_ITEM_GROUP = bck.FSH_ITEM_GROUP
    ,hdr.HWAER = bck.HWAER
    ,hdr.KALSM = bck.KALSM
    ,hdr.KNUMV = bck.KNUMV
    ,hdr.KONZS = bck.KONZS
    ,hdr.KORNR = bck.KORNR
    ,hdr.KTWRT = bck.KTWRT
    ,hdr.KUFIX = bck.KUFIX
    ,hdr.KUNNR = bck.KUNNR
    ,hdr.KZKPF = bck.KZKPF
    ,hdr.LAND1 = bck.LAND1
    ,hdr.LOEKZ = bck.LOEKZ
    ,hdr.MEMORY = bck.MEMORY
    ,hdr.REVNO = bck.REVNO
    ,hdr.STAFO = bck.STAFO
    ,hdr.STAKO = bck.STAKO
    ,hdr.SUBMI = bck.SUBMI
    ,hdr.ZZ_DPAMT = bck.ZZ_DPAMT
    ,hdr.ZZ_DPPCT = bck.ZZ_DPPCT
    ,hdr.ZZ_DPTYP = bck.ZZ_DPTYP
    ,hdr.ZZ_FRGGR = bck.ZZ_FRGGR
    ,hdr.ZZ_FRGKE = bck.ZZ_FRGKE
    ,hdr.ZZ_INCO2 = bck.ZZ_INCO2
    ,hdr.ZZ_INCOV = bck.ZZ_INCOV
    ,hdr.ZZ_LASTCHANGEDATETIME = bck.ZZ_LASTCHANGEDATETIME
    ,hdr.NOHDR = bck.NOHDR
    ,hdr.PWLIF = bck.PWLIF
    ,hdr.PREST = bck.PREST
    ,hdr.PLIWK = bck.PLIWK
    ,hdr.PLIEF = bck.PLIEF
    ,hdr.PBEST = bck.PBEST
    ,hdr.PERIV = bck.PERIV
    ,hdr.ZZDPTYP = bck.ZZDPTYP
    ,hdr.ZZDPPER = bck.ZZDPPER
    ,hdr.ZZDPFIX = bck.ZZDPFIX
    ,hdr.ZZDPDAT = bck.ZZDPDAT
    ,hdr.ZZKONNR = bck.ZZKONNR
    ,hdr.ZZPRQNO = bck.ZZPRQNO
    ,hdr.ZZSUPPLIER_REF = bck.ZZSUPPLIER_REF
    ,hdr.ZZFORWARDER_REF = bck.ZZFORWARDER_REF
    ,hdr.ZZETD = bck.ZZETD
    ,hdr.ZZCONTRACT_REFERENCE = bck.ZZCONTRACT_REFERENCE
    ,hdr.ZZTRANSPORT_MODE = bck.ZZTRANSPORT_MODE
    ,hdr.ZZETA = bck.ZZETA
    ,hdr.ZZPORT_OF_LOADING = bck.ZZPORT_OF_LOADING
    ,hdr.ZZPORT_OF_DISCHARG = bck.ZZPORT_OF_DISCHARG
    ,hdr.ZZ_ZTERM = bck.ZZ_ZTERM
    ,hdr.ZZ_ZBD1T = bck.ZZ_ZBD1T
    ,hdr.ZZ_AEDAT = bck.ZZ_AEDAT
    ,hdr.ZZ_WEAKT = bck.ZZ_WEAKT
    ,hdr.Load_timestamp = '2025-03-16' --- to be able to identify records updated

SELECT *
FROM  L0.L0_S4HANA_2LIS_02_HDR hdr
INNER JOIN TEST.L0_S4HANA_2LIS_02_HDR bck
    on bck.ebeln =hdr.ebeln 
     
WHERE 
    hdr.LOAD_TIMESTAMP < bck.LOAD_TIMESTAMP



    -- insert new ones

INSERT INTO  L0.L0_S4HANA_2LIS_02_HDR 
(
ROCANCEL
,HDRVORG
,ALIEF
,ARECH
,BEDAT
,BSART
,BSTYP
,BUDAT
,EBELN
,EKGRP
,EKORG
,KDATB
,KDATE
,LBLIF
,LIFNR
,LIFRE
,LLIEF
,LOGSY
,ORGLOGSY
,RESWK
,STATU
,SYDAT
,WAERS
,WKURS
,BRESWK
,BSAKZ
,BUKRS
,FRGRL
,FSH_ITEM_GROUP
,HWAER
,KALSM
,KNUMV
,KONZS
,KORNR
,KTWRT
,KUFIX
,KUNNR
,KZKPF
,LAND1
,LOEKZ
,MEMORY
,REVNO
,STAFO
,STAKO
,SUBMI
,ZZ_DPAMT
,ZZ_DPPCT
,ZZ_DPTYP
,ZZ_FRGGR
,ZZ_FRGKE
,ZZ_INCO2
,ZZ_INCOV
,ZZ_LASTCHANGEDATETIME
,NOHDR
,PWLIF
,PREST
,PLIWK
,PLIEF
,PBEST
,PERIV
,ZZDPTYP
,ZZDPPER
,ZZDPFIX
,ZZDPDAT
,ZZKONNR
,ZZPRQNO
,ZZSUPPLIER_REF
,ZZFORWARDER_REF
,ZZETD
,ZZCONTRACT_REFERENCE
,ZZTRANSPORT_MODE
,ZZETA
,ZZPORT_OF_LOADING
,ZZPORT_OF_DISCHARG
,ZZ_ZTERM
,ZZ_ZBD1T
,ZZ_AEDAT
,ZZ_WEAKT
,LOAD_TIMESTAMP

)
SELECT
    bck.ROCANCEL
    ,bck.HDRVORG
    ,bck.ALIEF
    ,bck.ARECH
    ,bck.BEDAT
    ,bck.BSART
    ,bck.BSTYP
    ,bck.BUDAT
    ,bck.EBELN
    ,bck.EKGRP
    ,bck.EKORG
    ,bck.KDATB
    ,bck.KDATE
    ,bck.LBLIF
    ,bck.LIFNR
    ,bck.LIFRE
    ,bck.LLIEF
    ,bck.LOGSY
    ,bck.ORGLOGSY
    ,bck.RESWK
    ,bck.STATU
    ,bck.SYDAT
    ,bck.WAERS
    ,bck.WKURS
    ,bck.BRESWK
    ,bck.BSAKZ
    ,bck.BUKRS
    ,bck.FRGRL
    ,bck.FSH_ITEM_GROUP
    ,bck.HWAER
    ,bck.KALSM
    ,bck.KNUMV
    ,bck.KONZS
    ,bck.KORNR
    ,bck.KTWRT
    ,bck.KUFIX
    ,bck.KUNNR
    ,bck.KZKPF
    ,bck.LAND1
    ,bck.LOEKZ
    ,bck.MEMORY
    ,bck.REVNO
    ,bck.STAFO
    ,bck.STAKO
    ,bck.SUBMI
    ,bck.ZZ_DPAMT
    ,bck.ZZ_DPPCT
    ,bck.ZZ_DPTYP
    ,bck.ZZ_FRGGR
    ,bck.ZZ_FRGKE
    ,bck.ZZ_INCO2
    ,bck.ZZ_INCOV
    ,bck.ZZ_LASTCHANGEDATETIME
    ,bck.NOHDR
    ,bck.PWLIF
    ,bck.PREST
    ,bck.PLIWK
    ,bck.PLIEF
    ,bck.PBEST
    ,bck.PERIV
    ,bck.ZZDPTYP
    ,bck.ZZDPPER
    ,bck.ZZDPFIX
    ,bck.ZZDPDAT
    ,bck.ZZKONNR
    ,bck.ZZPRQNO
    ,bck.ZZSUPPLIER_REF
    ,bck.ZZFORWARDER_REF
    ,bck.ZZETD
    ,bck.ZZCONTRACT_REFERENCE
    ,bck.ZZTRANSPORT_MODE
    ,bck.ZZETA
    ,bck.ZZPORT_OF_LOADING
    ,bck.ZZPORT_OF_DISCHARG
    ,bck.ZZ_ZTERM
    ,bck.ZZ_ZBD1T
    ,bck.ZZ_AEDAT
    ,bck.ZZ_WEAKT

    ,bck.LOAD_TIMESTAMP 
FROM  TEST.L0_S4HANA_2LIS_02_HDR bck
LEFT JOIN L0.L0_S4HANA_2LIS_02_HDR hdr
    on bck.ebeln =hdr.ebeln 
WHERE 
    hdr.EBELN is null

    SELECT COUNT(*) FROM L0.L0_S4HANA_2LIS_02_HDR hdr

--with cte_dup as (
    SELECT EBELN
    FROM  L0.L0_S4HANA_2LIS_02_HDR HDR
    GROUP BY EBELN
    HAVING COUNT(*) >1
--    )

--    DELETE HDR
--    FROM  TEST.L0_S4HANA_2LIS_02_HDR HDR
--    INNER JOIN cte_dup d on d.EBELN = HDR.EBELN
--    WHERe
--        ROCANCEL IS NULL


--UPDATE TEST.L0_S4HANA_2LIS_02_HDR  SET ROCANCEL = '' WHERE ROCANCEL IS NULL