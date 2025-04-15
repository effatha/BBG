--- original table [TEST].[L0_S4HANA_2LIS_02_ITM_FULL] ; First Load timestamp '2025-03-18 11:26:18.0000000'
--- Backt table od data layer from olddwh: TEST.L0_S4HANA_2LIS_02_ITM_FULL ; from 19032025


---first we update the records in the new dwh to deleted (R) if they are not in the base table

UPDATE itm SET 
    itm.ROCANCEL = 'R', itm.Load_timestamp = '2025-03-17' --- to be able to identify records updated
FROM  TEST.L0_S4HANA_2LIS_02_ITM itm
LEFT JOIN TEST.L0_S4HANA_2LIS_02_ITM_FULL f
    on f.ebeln =itm.ebeln 
    and 
       f.ebelp =itm.ebelp
WHERE 
    itm.LOAD_TIMESTAMP = '2025-03-18 11:26:18.0000000' --- only from the full load 
    and 
    f.ebeln is null
    and ISNULL(itm.ROCANCEL,'') = ''

--- second, we updated the matching records with the data from the old dwl bck


UPDATE itm SET 
     itm.BEDAT = bck.BEDAT
    ,itm.BSART = bck.BSART
    ,itm.BSTYP = bck.BSTYP
    ,itm.BUDAT = bck.BUDAT
    ,itm.EBELN = bck.EBELN
    ,itm.EKGRP = bck.EKGRP
    ,itm.EKORG = bck.EKORG
    ,itm.HWAER = bck.HWAER
    ,itm.KDATB = bck.KDATB
    ,itm.KDATE = bck.KDATE
    ,itm.LBLIF = bck.LBLIF
    ,itm.LIFNR = bck.LIFNR
    ,itm.LIFRE = bck.LIFRE
    ,itm.LLIEF = bck.LLIEF
    ,itm.LOGSY = bck.LOGSY
    ,itm.ORGLOGSY = bck.ORGLOGSY
    ,itm.RESWK = bck.RESWK
    ,itm.STATU = bck.STATU
    ,itm.SYDAT = bck.SYDAT
    ,itm.WAERS = bck.WAERS
    ,itm.WKURS = bck.WKURS
    ,itm.BRESWK = bck.BRESWK
    ,itm.BSAKZ = bck.BSAKZ
    ,itm.BUKRS = bck.BUKRS
    ,itm.KALSM = bck.KALSM
    ,itm.KNUMV = bck.KNUMV
    ,itm.KTWRT = bck.KTWRT
    ,itm.SUBMI = bck.SUBMI
    ,itm.AFNAM = bck.AFNAM
    ,itm.AKTNR = bck.AKTNR
    ,itm.AKTWE = bck.AKTWE
    ,itm.ALAV = bck.ALAV
    ,itm.ALIEF = bck.ALIEF
    ,itm.BSGRU = bck.BSGRU
    ,itm.BWAPPLNM = bck.BWAPPLNM
    ,itm.BWVORG = bck.BWVORG
    ,itm.EBELP = bck.EBELP
    ,itm.ELIKZ = bck.ELIKZ
    ,itm.EMATN = bck.EMATN
    ,itm.EREKZ = bck.EREKZ
    ,itm.KONNR = bck.KONNR
    ,itm.KTMNG = bck.KTMNG
    ,itm.KTPNR = bck.KTPNR
    ,itm.KZMAB = bck.KZMAB
    ,itm.KZPOS = bck.KZPOS
    ,itm.KZTAB = bck.KZTAB
    ,itm.LAVI = bck.LAVI
    ,itm.LFZTA = bck.LFZTA
    ,itm.LGORT = bck.LGORT
    ,itm.LMEIN = bck.LMEIN
    ,itm.MABW = bck.MABW
    ,itm.MATKL = bck.MATKL
    ,itm.MATNR = bck.MATNR
    ,itm.MEINS = bck.MEINS
    ,itm.MENGE = bck.MENGE
    ,itm.NETPR = bck.NETPR
    ,itm.NETWR = bck.NETWR
    ,itm.PEINH = bck.PEINH
    ,itm.PSTYP = bck.PSTYP
    ,itm.PWEV = bck.PWEV
    ,itm.PWFR = bck.PWFR
    ,itm.PWMT = bck.PWMT
    ,itm.PWTT = bck.PWTT
    ,itm.PWWE = bck.PWWE
    ,itm.REPOS = bck.REPOS
    ,itm.TABW = bck.TABW
    ,itm.TXZ01 = bck.TXZ01
    ,itm.UMREN = bck.UMREN
    ,itm.UMREZ = bck.UMREZ
    ,itm.WEBRE = bck.WEBRE
    ,itm.WEPOS = bck.WEPOS
    ,itm.WERKS = bck.WERKS
    ,itm.XERSY = bck.XERSY
    ,itm.ZWERT = bck.ZWERT
    ,itm.BANFN = bck.BANFN
    ,itm.BNFPO = bck.BNFPO
    ,itm.BRGEW = bck.BRGEW
    ,itm.BRTWR = bck.BRTWR
    ,itm.BRTWR_R = bck.BRTWR_R
    ,itm.BSTAE = bck.BSTAE
    ,itm.CHARG = bck.CHARG
    ,itm.CNFM_QTY = bck.CNFM_QTY
    ,itm.CON_ID = bck.CON_ID
    ,itm.EFFWR = bck.EFFWR
    ,itm.EFFWR_R = bck.EFFWR_R
    ,itm.EGLKZ = bck.EGLKZ
    ,itm.ESOKZ = bck.ESOKZ
    ,itm.GEWEI = bck.GEWEI
    ,itm.IDNLF = bck.IDNLF
    ,itm.INFNR = bck.INFNR
    ,itm.KNTTP = bck.KNTTP
    ,itm.KZAVI = bck.KZAVI
    ,itm.KZKPO = bck.KZKPO
    ,itm.KZWEV = bck.KZWEV
    ,itm.KZWI1 = bck.KZWI1
    ,itm.KZWI2 = bck.KZWI2
    ,itm.KZWI3 = bck.KZWI3
    ,itm.KZWI4 = bck.KZWI4
    ,itm.KZWI5 = bck.KZWI5
    ,itm.KZWI6 = bck.KZWI6
    ,itm.LOEKZ = bck.LOEKZ
    ,itm.LTSNR = bck.LTSNR
    ,itm.MEPRF = bck.MEPRF
    ,itm.MFRNR = bck.MFRNR
    ,itm.MFRPN = bck.MFRPN
    ,itm.MPO_MATNR = bck.MPO_MATNR
    ,itm.MPROF = bck.MPROF
    ,itm.MWSKZ = bck.MWSKZ
    ,itm.NAVNW = bck.NAVNW
    ,itm.NETWR_R = bck.NETWR_R
    ,itm.NTGEW = bck.NTGEW
    ,itm.OBJID = bck.OBJID
    ,itm.OBJID_COM = bck.OBJID_COM
    ,itm.PLANNING_GUID = bck.PLANNING_GUID
    ,itm.PRDAT = bck.PRDAT
    ,itm.PUNEI = bck.PUNEI
    ,itm.RELOC_ID = bck.RELOC_ID
    ,itm.RELOC_SEQ_ID = bck.RELOC_SEQ_ID
    ,itm.RESLO = bck.RESLO
    ,itm.RETPO = bck.RETPO
    ,itm.SATNR = bck.SATNR
    ,itm.SGT_RCAT = bck.SGT_RCAT
    ,itm.SGT_SCAT = bck.SGT_SCAT
    ,itm.STAFO = bck.STAFO
    ,itm.STAPO = bck.STAPO
    ,itm.TWRKZ = bck.TWRKZ
    ,itm.VOLEH = bck.VOLEH
    ,itm.VOLUM = bck.VOLUM
    ,itm.VRTKZ = bck.VRTKZ
    ,itm.WEBAZ = bck.WEBAZ
    ,itm.WEUNB = bck.WEUNB
    ,itm.ZZ_AEDAT = bck.ZZ_AEDAT
    ,itm.ZZ_INCO2_L = bck.ZZ_INCO2_L
    ,itm.ZZ_INCO3_L = bck.ZZ_INCO3_L
    ,itm.ZZ_INFNR = bck.ZZ_INFNR
    ,itm.ZZ_KO_PRCTR = bck.ZZ_KO_PRCTR
    ,itm.ZZ_MTART = bck.ZZ_MTART
    ,itm.ZZ_STAWN = bck.ZZ_STAWN
    ,itm.ZZ_UNIQUEID = bck.ZZ_UNIQUEID
    ,itm.PERIV = bck.PERIV
    ,itm.QUAN_INT = bck.QUAN_INT
    ,itm.TIME_INT = bck.TIME_INT
    ,itm.NOTIME = bck.NOTIME
    ,itm.NOQUAN = bck.NOQUAN
    ,itm.NOPOS = bck.NOPOS
    ,itm.PWLIF = bck.PWLIF
    ,itm.PREST = bck.PREST
    ,itm.PLIWK = bck.PLIWK
    ,itm.PLIEF = bck.PLIEF
    ,itm.PBEST = bck.PBEST
    ,itm.MGABW = bck.MGABW
    ,itm.LFABW = bck.LFABW
    ,itm.MAXBW = bck.MAXBW
    ,itm.VVABW = bck.VVABW
    ,itm.UZEIT = bck.UZEIT
    ,itm.MCEX_UEBTO = bck.MCEX_UEBTO
    ,itm.MCEX_UEBTK = bck.MCEX_UEBTK
    ,itm.MCEX_UNTTO = bck.MCEX_UNTTO
    ,itm.ZMM_IM_READY_DATE = bck.ZMM_IM_READY_DATE
    ,itm.ZMM_MRD = bck.ZMM_MRD
    ,itm.ZMM_QC_DATE = bck.ZMM_QC_DATE
    ,itm.ZMM_ETD = bck.ZMM_ETD
    ,itm.ZZ_ZTERM = bck.ZZ_ZTERM
    ,itm.ZZ_INCO1 = bck.ZZ_INCO1
    ,itm.ZZ_INCO2 = bck.ZZ_INCO2
    ,itm.ZZ_DPTYP = bck.ZZ_DPTYP
    ,itm.ZZ_DPPCT = bck.ZZ_DPPCT
    ,itm.ZZ_DPAMT = bck.ZZ_DPAMT
    ,itm.ZZ_DPDAT = bck.ZZ_DPDAT
    ,itm.ZZ_NETPR = bck.ZZ_NETPR
    ,itm.ZZ_NETPR_TC_UNROUNDED = bck.ZZ_NETPR_TC_UNROUNDED
    ,itm.ZZ_NETPR_HC_UNROUNDED = bck.ZZ_NETPR_HC_UNROUNDED
    ,itm.ZREFBS = bck.ZREFBS
    ,itm.ZREFPS = bck.ZREFPS
    ,itm.ZCONTRACT_REFERENCE = bck.ZCONTRACT_REFERENCE
    ,itm.Load_timestamp = '2025-03-16' --- to be able to identify records updated
FROM  TEST.L0_S4HANA_2LIS_02_ITM itm
INNER JOIN TEST.L0_S4HANA_2LIS_02_ITM_FULL bck
    on bck.ebeln =itm.ebeln 
    and 
       bck.ebelp =itm.ebelp
WHERE 
    itm.LOAD_TIMESTAMP = '2025-03-18 11:26:18.0000000'



    -- insert new ones

INSERT INTO  TEST.L0_S4HANA_2LIS_02_ITM 
(
    ROCANCEL
    ,BEDAT
    ,BSART
    ,BSTYP
    ,BUDAT
    ,EBELN
    ,EKGRP
    ,EKORG
    ,HWAER
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
    ,KALSM
    ,KNUMV
    ,KTWRT
    ,SUBMI
    ,AFNAM
    ,AKTNR
    ,AKTWE
    ,ALAV
    ,ALIEF
    ,BSGRU
    ,BWAPPLNM
    ,BWVORG
    ,EBELP
    ,ELIKZ
    ,EMATN
    ,EREKZ
    ,KONNR
    ,KTMNG
    ,KTPNR
    ,KZMAB
    ,KZPOS
    ,KZTAB
    ,LAVI
    ,LFZTA
    ,LGORT
    ,LMEIN
    ,MABW
    ,MATKL
    ,MATNR
    ,MEINS
    ,MENGE
    ,NETPR
    ,NETWR
    ,PEINH
    ,PSTYP
    ,PWEV
    ,PWFR
    ,PWMT
    ,PWTT
    ,PWWE
    ,REPOS
    ,TABW
    ,TXZ01
    ,UMREN
    ,UMREZ
    ,WEBRE
    ,WEPOS
    ,WERKS
    ,XERSY
    ,ZWERT
    ,BANFN
    ,BNFPO
    ,BRGEW
    ,BRTWR
    ,BRTWR_R
    ,BSTAE
    ,CHARG
    ,CNFM_QTY
    ,CON_ID
    ,EFFWR
    ,EFFWR_R
    ,EGLKZ
    ,ESOKZ
    ,GEWEI
    ,IDNLF
    ,INFNR
    ,KNTTP
    ,KZAVI
    ,KZKPO
    ,KZWEV
    ,KZWI1
    ,KZWI2
    ,KZWI3
    ,KZWI4
    ,KZWI5
    ,KZWI6
    ,LOEKZ
    ,LTSNR
    ,MEPRF
    ,MFRNR
    ,MFRPN
    ,MPO_MATNR
    ,MPROF
    ,MWSKZ
    ,NAVNW
    ,NETWR_R
    ,NTGEW
    ,OBJID
    ,OBJID_COM
    ,PLANNING_GUID
    ,PRDAT
    ,PUNEI
    ,RELOC_ID
    ,RELOC_SEQ_ID
    ,RESLO
    ,RETPO
    ,SATNR
    ,SGT_RCAT
    ,SGT_SCAT
    ,STAFO
    ,STAPO
    ,TWRKZ
    ,VOLEH
    ,VOLUM
    ,VRTKZ
    ,WEBAZ
    ,WEUNB
    ,ZZ_AEDAT
    ,ZZ_INCO2_L
    ,ZZ_INCO3_L
    ,ZZ_INFNR
    ,ZZ_KO_PRCTR
    ,ZZ_MTART
    ,ZZ_STAWN
    ,ZZ_UNIQUEID
    ,PERIV
    ,QUAN_INT
    ,TIME_INT
    ,NOTIME
    ,NOQUAN
    ,NOPOS
    ,PWLIF
    ,PREST
    ,PLIWK
    ,PLIEF
    ,PBEST
    ,MGABW
    ,LFABW
    ,MAXBW
    ,VVABW
    ,UZEIT
    ,MCEX_UEBTO
    ,MCEX_UEBTK
    ,MCEX_UNTTO
    ,ZMM_IM_READY_DATE
    ,ZMM_MRD
    ,ZMM_QC_DATE
    ,ZMM_ETD
    ,ZZ_ZTERM
    ,ZZ_INCO1
    ,ZZ_INCO2
    ,ZZ_DPTYP
    ,ZZ_DPPCT
    ,ZZ_DPAMT
    ,ZZ_DPDAT
    ,ZZ_NETPR
    ,ZZ_NETPR_TC_UNROUNDED
    ,ZZ_NETPR_HC_UNROUNDED
    ,ZREFBS
    ,ZREFPS
    ,ZCONTRACT_REFERENCE
    ,LOAD_TIMESTAMP
)
SELECT
     ROCANCEL = ''
    ,bck.BEDAT
    ,bck.BSART
    ,bck.BSTYP
    ,bck.BUDAT
    ,bck.EBELN
    ,bck.EKGRP
    ,bck.EKORG
    ,bck.HWAER
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
    ,bck.KALSM
    ,bck.KNUMV
    ,bck.KTWRT
    ,bck.SUBMI
    ,bck.AFNAM
    ,bck.AKTNR
    ,bck.AKTWE
    ,bck.ALAV
    ,bck.ALIEF
    ,bck.BSGRU
    ,bck.BWAPPLNM
    ,bck.BWVORG
    ,bck.EBELP
    ,bck.ELIKZ
    ,bck.EMATN
    ,bck.EREKZ
    ,bck.KONNR
    ,bck.KTMNG
    ,bck.KTPNR
    ,bck.KZMAB
    ,bck.KZPOS
    ,bck.KZTAB
    ,bck.LAVI
    ,bck.LFZTA
    ,bck.LGORT
    ,bck.LMEIN
    ,bck.MABW
    ,bck.MATKL
    ,bck.MATNR
    ,bck.MEINS
    ,bck.MENGE
    ,bck.NETPR
    ,bck.NETWR
    ,bck.PEINH
    ,bck.PSTYP
    ,bck.PWEV
    ,bck.PWFR
    ,bck.PWMT
    ,bck.PWTT
    ,bck.PWWE
    ,bck.REPOS
    ,bck.TABW
    ,bck.TXZ01
    ,bck.UMREN
    ,bck.UMREZ
    ,bck.WEBRE
    ,bck.WEPOS
    ,bck.WERKS
    ,bck.XERSY
    ,bck.ZWERT
    ,bck.BANFN
    ,bck.BNFPO
    ,bck.BRGEW
    ,bck.BRTWR
    ,bck.BRTWR_R
    ,bck.BSTAE
    ,bck.CHARG
    ,bck.CNFM_QTY
    ,bck.CON_ID
    ,bck.EFFWR
    ,bck.EFFWR_R
    ,bck.EGLKZ
    ,bck.ESOKZ
    ,bck.GEWEI
    ,bck.IDNLF
    ,bck.INFNR
    ,bck.KNTTP
    ,bck.KZAVI
    ,bck.KZKPO
    ,bck.KZWEV
    ,bck.KZWI1
    ,bck.KZWI2
    ,bck.KZWI3
    ,bck.KZWI4
    ,bck.KZWI5
    ,bck.KZWI6
    ,bck.LOEKZ
    ,bck.LTSNR
    ,bck.MEPRF
    ,bck.MFRNR
    ,bck.MFRPN
    ,bck.MPO_MATNR
    ,bck.MPROF
    ,bck.MWSKZ
    ,bck.NAVNW
    ,bck.NETWR_R
    ,bck.NTGEW
    ,bck.OBJID
    ,bck.OBJID_COM
    ,bck.PLANNING_GUID
    ,bck.PRDAT
    ,bck.PUNEI
    ,bck.RELOC_ID
    ,bck.RELOC_SEQ_ID
    ,bck.RESLO
    ,bck.RETPO
    ,bck.SATNR
    ,bck.SGT_RCAT
    ,bck.SGT_SCAT
    ,bck.STAFO
    ,bck.STAPO
    ,bck.TWRKZ
    ,bck.VOLEH
    ,bck.VOLUM
    ,bck.VRTKZ
    ,bck.WEBAZ
    ,bck.WEUNB
    ,bck.ZZ_AEDAT
    ,bck.ZZ_INCO2_L
    ,bck.ZZ_INCO3_L
    ,bck.ZZ_INFNR
    ,bck.ZZ_KO_PRCTR
    ,bck.ZZ_MTART
    ,bck.ZZ_STAWN
    ,bck.ZZ_UNIQUEID
    ,bck.PERIV
    ,bck.QUAN_INT
    ,bck.TIME_INT
    ,bck.NOTIME
    ,bck.NOQUAN
    ,bck.NOPOS
    ,bck.PWLIF
    ,bck.PREST
    ,bck.PLIWK
    ,bck.PLIEF
    ,bck.PBEST
    ,bck.MGABW
    ,bck.LFABW
    ,bck.MAXBW
    ,bck.VVABW
    ,bck.UZEIT
    ,bck.MCEX_UEBTO
    ,bck.MCEX_UEBTK
    ,bck.MCEX_UNTTO
    ,bck.ZMM_IM_READY_DATE
    ,bck.ZMM_MRD
    ,bck.ZMM_QC_DATE
    ,bck.ZMM_ETD
    ,bck.ZZ_ZTERM
    ,bck.ZZ_INCO1
    ,bck.ZZ_INCO2
    ,bck.ZZ_DPTYP
    ,bck.ZZ_DPPCT
    ,bck.ZZ_DPAMT
    ,bck.ZZ_DPDAT
    ,bck.ZZ_NETPR
    ,bck.ZZ_NETPR_TC_UNROUNDED
    ,bck.ZZ_NETPR_HC_UNROUNDED
    ,bck.ZREFBS
    ,bck.ZREFPS
    ,bck.ZCONTRACT_REFERENCE
    ,LOAD_TIMESTAMP = '2025-03-15'
FROM  TEST.L0_S4HANA_2LIS_02_ITM_FULL bck
LEFT JOIN TEST.L0_S4HANA_2LIS_02_ITM itm
    on bck.ebeln =itm.ebeln 
    and 
       bck.ebelp =itm.ebelp
WHERE 
    itm.EBELN is null