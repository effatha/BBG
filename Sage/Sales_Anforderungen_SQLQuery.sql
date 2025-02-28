DECLARE @Mandant INT = 0	-- 0 = alle Mandanten
DECLARE @JahrVon INT = 2020
DECLARE @JahrBis INT = 2020
DECLARE @MonatVon INT = 1
DECLARE @MonatBis INT = 12
----DECLARE @TagVon INT = 1
--DECLARE @TagBis INT = 31

SELECT
	[Mandant]
	, [Jahr]
	, [Monat]
	--, [Tag]
	--, [StatistikWirkungUmsatz]
	--, [Gleichgewichtsstatistik]
	--, [VorID]
	--, [BelID]
	--, [ReferenzBelID]
	--, [Belegnummer]
	, [Belegkennzeichen]
	, [Belegart]
	--, [Vertreter]
	, [Zahlungsart]
	--, [Carrier]
	--, [A0Empfaenger]
	--, [A0Name]
	, [Channel]
	, [Channel_Planung]
	--, [Kundengruppennummer]
	, [Kundengruppe]
	, [Country]
	--, [Rechnungsland]
	--, [Lieferland]
	, [Flag_SalesView]
	, [Flag_FBA]
	, [Flag_PBM]
	, [Flag_B2B]
	--, [Flag_EOL]
	, [Flag_0EUR_Rechnung]
	, [Gutschriftenart]
	--, [Artikelnummer]
	--, [Artikelbezeichnung]
	, [Artikelart]
	--, [Sourcer]
	--, [Produktkategorie]
	, [Artikelgruppe_Ebene1]
	--, [Artikelgruppe_Ebene2]
	--, [Artikelgruppe_Ebene3]
	--, [OwnBrand]
	--, [OwnBrand_bereinigt]
	--, [Brand]
	--, [Brand_bereinigt]
	--, [CatMan]
	, SUM([Umsatz vor Retouren]) AS [Umsatz vor Retouren]
	, SUM([Retournierter Umsatz]) AS [Retournierter Umsatz]
	, SUM([Umsatz nach Retouren]) AS [Umsatz nach Retouren]
	, SUM([Belegfuß vor Retouren]) AS [Belegfuß vor Retouren]
	, SUM([Belegfuß nach Retouren]) AS [Belegfuß nach Retouren]
	, SUM([Menge vor Retouren]) AS [Menge vor Retouren]
	, SUM([Menge nach Retouren]) AS [Menge nach Retouren]
	, SUM([Wareneinsatz MEK WE vor Retouren]) AS [Wareneinsatz MEK WE vor Retouren]
	, SUM([Retournierter Wareneinsatz MEK WE]) AS [Retournierter Wareneinsatz MEK WE]	
	, SUM([Wareneinsatz MEK WE nach Retouren]) AS [Wareneinsatz MEK WE nach Retouren]
	, SUM([Wareneinsatz MEK Hedging vor Retouren]) AS [Wareneinsatz MEK Hedging vor Retouren]
	, SUM([Retournierter Wareneinsatz MEK Hedging]) AS [Retournierter Wareneinsatz MEK Hedging]	
	, SUM([Wareneinsatz MEK Hedging nach Retouren]) AS [Wareneinsatz MEK Hedging nach Retouren]
	, SUM([Wareneinsatz MEK Plan vor Retouren]) AS [Wareneinsatz MEK Plan vor Retouren]
	, SUM([Retournierter Wareneinsatz MEK Plan]) AS [Retournierter Wareneinsatz MEK Plan]	
	, SUM([Wareneinsatz MEK Plan nach Retouren]) AS [Wareneinsatz MEK Plan nach Retouren]

FROM
(
SELECT
	bel.Mandant,
	YEAR(bel.Belegdatum) AS Jahr,
	MONTH(bel.Belegdatum) AS Monat,
	DAY(bel.Belegdatum) AS Tag,	-- nie auskommentieren!!!
	--bela.StatistikWirkungUmsatz,
	--bela.Gleichgewichtsstatistik,
	--bel.VorID,
	--bel.BelID,
	--bel.ReferenzBelID,
	bel.Belegnummer,	-- nie auskommentieren!!!
	bel.Belegkennzeichen,
	bel.Belegart,
	--bel.Vertreter,
	kz.Zahlungskond AS Zahlungsart,
	--vlog.Frachtfuehrer AS Carrier,
	--bel.A0Empfaenger,
	--REPLACE(REPLACE(REPLACE(bel.[A0Name1], CHAR(13) + CHAR(10), '<br>'), CHAR(10), '<br>'), CHAR(13), '<br>') AS A0Name,

	CASE
		WHEN Map.KG_Bezeichnung IN ('Mandanten','Weiterberechnung') THEN Map.KG_Bezeichnung
		WHEN bel.Kundengruppe IN ('51','52','60','61','62','63','64','65','66','79','82','83','84','86','88') THEN 'Andere Marktplätze'
		WHEN Gruppen.Tag IN ('Amazon','eBay','Shop','SK','Mandanten','Weiterberechnung') THEN Gruppen.Tag
		ELSE 'Diverse/B2B'
	END AS Channel,

	CASE
		WHEN Map.KG_Bezeichnung IN ('Mandanten','Weiterberechnung') THEN Map.KG_Bezeichnung
		WHEN bel.Kundengruppe IN ('88') THEN 'Darty'
		WHEN bel.Kundengruppe IN ('63') THEN 'La Redoute'
		WHEN Gruppen.Tag IN ('Amazon','Cdiscount','eBay','FNAC','Mandanten','Otto','Shop','SK','Weiterberechnung') THEN Gruppen.Tag
		WHEN bel.Kundengruppe IN ('51','52','60','61','62','63','64','65','66','79','82','83','84','86','88') THEN 'Andere Marktplätze'
		ELSE 'Diverse/B2B'
	END AS Channel_Planung,

	--bel.Kundengruppe AS Kundengruppennummer,

	CASE 
		WHEN Map.KG_Bezeichnung IN ('Mandanten','Weiterberechnung') THEN Map.KG_Bezeichnung
		WHEN bel.Kundengruppe IN ('88') THEN 'Darty'
		WHEN bel.Kundengruppe IN ('38') THEN 'CS B2B'
		WHEN bel.Kundengruppe IN ('11','16','20','21','26','27','30','31','32','33','34','36','37','40','41','42','75','92','93','99') THEN 'E-Star'
		WHEN bel.Kundengruppe IN ('101','102','103','104','105') THEN 'Auna'
		WHEN bel.Kundengruppe IN ('89','200','201','202','203','204','205','218','219','220','221','222','223','224','225') THEN 'Klarstein'
		WHEN bel.Kundengruppe IN ('301') THEN 'Numan'
		WHEN bel.Kundengruppe IN ('400','401','402','403','404','405','406','407','408','409','410') THEN 'CapitalSports'
		WHEN bel.Kundengruppe IN ('45','46','47','48','49') THEN 'Blumfeldt'
		WHEN Gruppen.Tag IN ('Amazon','Cdiscount','eBay','FNAC','Groupon','Laden','Mandanten','MeinPaket','Otto','SK','Telefonverkauf','Weiterberechnung') THEN Gruppen.Tag 
		ELSE ISNULL(Gruppen.Bezeichnung,'n/a')
	END AS Kundengruppe,

	CASE
		WHEN Map.KG_Bezeichnung IN ('Mandanten') THEN 'DE ' + Map.KG_Bezeichnung
		WHEN (bel.Kundengruppe = 16 AND bel.Mandant = 1) THEN 'DE Mandanten' 
		WHEN Map.KG_Bezeichnung IN ('Weiterberechnung') THEN Map.KG_Bezeichnung
		WHEN bel.A1Land IN ('DE','ES','FR','GB','IT') THEN bel.A1Land
		WHEN Gruppen.Tag IN ('SK') THEN 'SK'
		ELSE 'INT'
	END AS Country,

	--bel.A0Land AS Rechnungsland,
	--bel.A1Land AS Lieferland,

	CASE 
		WHEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW),0) = 0 THEN 0
		WHEN artikel.Artikelnummer IN ('90000050') THEN 1
		WHEN artikel.Artikelnummer IN ('90000028','90000029','90000128') THEN 0
		WHEN left(artikel.Artikelnummer,1) = 9 AND left(artikel.Matchcode,6) = 'Kulanz' THEN 0
		WHEN left(artikel.Artikelnummer,1) = 9 THEN 0
		ELSE 1
	END AS Flag_SalesView,

	CASE 
		WHEN bel.[Belegkennzeichen] IN ('VSD') AND Gruppen.Tag IN ('Amazon') THEN 1
		WHEN ref.[Belegkennzeichen] IN ('VSD') AND Gruppen.Tag IN ('Amazon') THEN 1
		ELSE 0
	END AS Flag_FBA,

	CASE 
		WHEN lao.[OrderID] IS NOT NULL THEN 1
		ELSE 0
	END AS Flag_PBM,

	CASE 
		WHEN bel.[Vertreter] IN ('V0004','V3001','V3002','V3003','V3004','V3005','V3006','V3007') AND bel.[Mandant] = 1 THEN 1
		WHEN bel.[Vertreter] IN ('V0004','V3001','V3002','V3003','V3004','V3005','V3006','V3007') AND bel.[Mandant] = 3 THEN 1
		WHEN bel.[Kundengruppe] IN ('23','24','25','28','35','106','113','207','214','215') THEN 1
		WHEN bel.[Mandant] = 2 THEN 1
		ELSE 0
	END AS Flag_B2B,

	--CASE 
	--	WHEN ISNULL(artikel.IstEinmalartikel, 0) = -1 THEN 1 
	--	ELSE 0
	--END AS Flag_EOL,

	CASE
		WHEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW),0) = 0 THEN 1
		ELSE 0
	END AS Flag_0EUR_Rechnung,

	CASE 	
		WHEN bela.StatistikWirkungUmsatz <> -1 THEN 'n/a'
		WHEN bel.[Belegkennzeichen] IN ('VFN','VFT','VSY') THEN 'Storno/NiLi'
		WHEN bel.[Belegkennzeichen] IN ('VFM') AND NOT (left(artikel.Artikelnummer,1) = 9 OR (ref.[Belegkennzeichen] IN ('VSD') AND Gruppen.Tag IN ('Amazon'))) THEN 'Kundenstorno'
		WHEN bel.[Belegkennzeichen] IN ('VFS') AND NOT left(artikel.Artikelnummer,1) = 9 THEN 'Korrekturen'
		WHEN left(artikel.Artikelnummer,1) = 9 AND left(artikel.Matchcode,6) = 'Kulanz' THEN 'Kulanzen'
		WHEN left(artikel.Artikelnummer,2) = 91 THEN 'Kulanzen'
		WHEN left(artikel.Artikelnummer,1) = 9 THEN 'Sonstige 9er Artikel'
		WHEN Gruppen.Tag IN ('SK') AND bel.Belegkennzeichen IN ('VFG') AND kz.Zahlungskond IN ('NN') THEN 'Kundengutschriften SK manuell'
		ELSE 'Kundengutschriften'
	END	AS Gutschriftenart,

	artikel.Artikelnummer,	-- nie auskommentieren!!!
	--REPLACE(REPLACE(REPLACE(artikel.Matchcode, CHAR(13) + CHAR(10), '<br>'), CHAR(10), '<br>'), CHAR(13), '<br>') AS Artikelbezeichnung,

	CASE	
		WHEN left(artikel.Artikelnummer,1) = 1 AND artikel.Stuecklistentyp = 2 THEN '1_Kitting'
		WHEN left(artikel.Artikelnummer,1) = 1 THEN '1_A-Ware'
		WHEN left(artikel.Artikelnummer,1) = 3 THEN '3_UK Plug-Artikel'
		WHEN left(artikel.Artikelnummer,1) = 4 THEN '4_Zubehör'
		WHEN left(artikel.Artikelnummer,1) = 5 THEN '5_B-Ware'
		WHEN left(artikel.Artikelnummer,1) = 6 THEN '6_Set-Artikel'
		WHEN left(artikel.Artikelnummer,1) = 7 THEN '7_Kitting'
		WHEN artikel.Artikelnummer IN ('90000050') THEN '9_Voucher'
		WHEN artikel.Artikelnummer IN ('90000028','90000029','90000128') THEN '9_Defektgeräte'
		WHEN left(artikel.Artikelnummer,1) = 9 AND left(artikel.Matchcode,6) = 'Kulanz' THEN '9_Kulanzen'
		WHEN left(artikel.Artikelnummer,1) = 9 THEN '9_Sonstige 9er Artikel'
		ELSE 'Other'
	END AS Artikelart,

	--artikel.USER_Sourcer AS Sourcer,

	--CASE	
	--	WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht physische Artikel: Mandanten'
	--	WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht physische Artikel: sonst. Erlöse'
	--	ELSE (isnull(produktkategorie.Bezeichnung,'No Category') + ' (' + case when Markenklasse.Bezeichnung = 'X' then 'Z' else isnull(Markenklasse.Bezeichnung,'Z') END +')') 
	--END	AS Produktkategorie,

	CASE 
		WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht physische Artikel: Mandanten'
		WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht physische Artikel: sonst. Erlöse'
		ELSE Artgruppe1.Bezeichnung
	END AS Artikelgruppe_Ebene1,

	--CASE 
	--	WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht physische Artikel: Mandanten'
	--	WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht physische Artikel: sonst. Erlöse'
	--	ELSE Artgruppe2.Bezeichnung
	--END AS Artikelgruppe_Ebene2,

	--CASE 
	--	WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht physische Artikel: Mandanten'
	--	WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht physische Artikel: sonst. Erlöse'
	--	ELSE Artgruppe3.Bezeichnung
	--END AS Artikelgruppe_Ebene3,

	--CASE 	
	--	WHEN isnull(artikel.User_Markenklasse,0) in (3,4) THEN 'ja' 
	--	WHEN isnull(artikel.User_Markenklasse,0) in (1,2) THEN 'nein' 
	--	ELSE 'nicht klassifiziert' 
	--END	AS OwnBrand,

	--CASE WHEN isnull(artikel.User_VKMarke,'') IN (	
	--	'Auna',
	--	'BESOA',
	--	'Blumfeldt',
	--	'CapitalS',
	--	'DURAMAXX',
	--	'FrontStage',
	--	'KLARFIT',
	--	'Klarstein',
	--	'Lightcraft',
	--	'Malone',
	--	'Numan',
	--	'oneConcept',
	--	'SCHUBERT',
	--	'Waldbeck',
	--	'Yuk',
	--	'resident',
	--	'auna_pro') THEN 'ja'  
	--	WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht klassifiziert'
	--	WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht klassifiziert'
	--	ELSE 'nein'
	--END	AS OwnBrand_bereinigt,

	--CASE 	
	--	WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht physische Artikel: Mandanten' 
	--	WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht physische Artikel: sonst. Erlöse'
	--	ELSE isnull(artikel.User_VKMarke,'<no name>') 
	--END	AS Brand,

	--CASE 	
	--	WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht physische Artikel: Mandanten' 
	--	WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht physische Artikel: sonst. Erlöse'
	--	WHEN isnull(artikel.User_VKMarke,'') IN (	
	--	'Auna',
	--	'BESOA',
	--	'Blumfeldt',
	--	'CapitalS',
	--	'DURAMAXX',
	--	'FrontStage',
	--	'KLARFIT',
	--	'Klarstein',
	--	'Lightcraft',
	--	'Malone',
	--	'Numan',
	--	'oneConcept',
	--	'SCHUBERT',
	--	'Waldbeck',
	--	'Yuk',
	--	'resident',
	--	'auna_pro') THEN artikel.User_VKMarke
	--	ELSE 'Fremdmarke' 
	--END	AS Brand_bereinigt,

	--CASE	
	--	WHEN bel.Belegdatum >= getdate()-8 then artikel.User_categorymanagement 
	--	ELSE 'n/a'
	--END	AS CatMan,

--- Umsätze + BF

	round(sum(CASE WHEN bela.StatistikWirkungUmsatz = 1 THEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW),0) ELSE 0 END),2) AS [Umsatz vor Retouren]
	,round(sum(CASE WHEN bela.StatistikWirkungUmsatz = -1 THEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW),0) ELSE 0 END),2) AS [Retournierter Umsatz]
	,round(sum(isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW) * bela.StatistikWirkungUmsatz,0)),2) AS [Umsatz nach Retouren]
	
	,round(sum(CASE WHEN bela.StatistikWirkungUmsatz = 1  AND bel.[ZWInternEW] > 0 
					THEN isnull((((bel.[Nettobetrag] * isnull(bel.[WKzKursFw],1)) - bel.[ZWInternEW]) * ((isnull(stueck.[GesamtpreisInternEW], pos.[GesamtpreisInternEW])) / bel.[ZWInternEW])) * bela.[StatistikWirkungUmsatz],0) 
					ELSE 0
			  END), 2) AS [Belegfuß vor Retouren]
	,round(CASE WHEN bel.[ZWInternEW] > 0 
					THEN isnull((((bel.[Nettobetrag] * isnull(bel.[WKzKursFw],1)) - bel.[ZWInternEW]) * ((isnull(stueck.[GesamtpreisInternEW], pos.[GesamtpreisInternEW])) / bel.[ZWInternEW])) * bela.[StatistikWirkungUmsatz],0) 
					ELSE 0 
			  END, 2) AS [Belegfuß nach Retouren]

--- Mengen

	,sum(CASE	
			WHEN artikel.Artikelnummer like '9%' AND artikel.Artikelnummer NOT IN ('90000028','90000029') THEN 0 
			ELSE CASE WHEN bela.StatistikWirkungMenge = 1 THEN isnull(isnull(stueck.mengebasis,pos.menge),0) ELSE 0 
		END END) AS [Menge vor Retouren]

	,sum(CASE
			WHEN artikel.Artikelnummer like '9%' AND artikel.Artikelnummer NOT IN ('90000028','90000029') THEN 0 
			ELSE isnull(isnull(stueck.mengebasis,pos.menge),0) * bela.[StatistikWirkungUmsatz] 
		END) AS [Menge nach Retouren]

	,count(DISTINCT bel.[VorID]) AS [Anzahl Vorgänge]

--- Roherlös aus den Belegen

	,round(sum(CASE WHEN bela.StatistikWirkungUmsatz = 1 THEN isnull(isnull(stueck.roherloes,pos.roherloes),0) END), 2) AS [Roherlös vor Retouren]
	,round(sum(CASE WHEN bela.StatistikWirkungUmsatz = -1 THEN isnull(isnull(stueck.roherloes,pos.roherloes),0) END), 2) AS [Retournierter Roherlös]  
	,round(sum(isnull(isnull(stueck.roherloes,pos.roherloes) * bela.StatistikWirkungUmsatz,0)),2) AS [Roherlös nach Retouren]

--- MEK WE

	,round(sum(CASE WHEN artikel.Artikelnummer like '4%' OR artikel.Artikelnummer like '6%' OR artikel.Artikelnummer like '7%' AND bela.StatistikWirkungUmsatz = 1 THEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW),0) - isnull(isnull(stueck.roherloes,pos.roherloes),0)
				ELSE CASE WHEN bela.StatistikWirkungUmsatz = 1 THEN isnull((isnull(ham1.[MEK_WE],ham2.[MEK_WE]) * mAufschlag.[Aufschlag]*isnull(isnull(stueck.mengebasis,pos.menge),0)),0) END END), 2) AS [Wareneinsatz MEK WE vor Retouren]

	,round(sum(CASE WHEN artikel.Artikelnummer like '4%' OR artikel.Artikelnummer like '6%' OR artikel.Artikelnummer like '7%' AND bela.StatistikWirkungUmsatz = -1 THEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW),0) - isnull(isnull(stueck.roherloes,pos.roherloes),0)
				ELSE CASE WHEN bela.StatistikWirkungUmsatz = -1 THEN isnull((isnull(ham1.[MEK_WE],ham2.[MEK_WE]) * mAufschlag.[Aufschlag]*isnull(isnull(stueck.mengebasis,pos.menge),0)),0) END END), 2) AS [Retournierter Wareneinsatz MEK WE]
	
	,round(sum(CASE WHEN artikel.Artikelnummer like '4%' OR artikel.Artikelnummer like '6%' OR artikel.Artikelnummer like '7%' THEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW) * bela.StatistikWirkungUmsatz,0) - isnull(isnull(stueck.roherloes,pos.roherloes) * bela.StatistikWirkungUmsatz,0)
				ELSE isnull(isnull(ham1.[MEK_WE],ham2.[MEK_WE]) * mAufschlag.[Aufschlag] * CASE WHEN artikel.Artikelnummer like '9%' THEN 0 ELSE isnull(isnull(stueck.mengebasis,pos.menge),0) * bela.[StatistikWirkungUmsatz] END,0) 
				END),2) AS [Wareneinsatz MEK WE nach Retouren]

--- MEK Hedging

	,round(sum(CASE WHEN artikel.Artikelnummer like '4%' OR artikel.Artikelnummer like '6%' OR artikel.Artikelnummer like '7%' AND bela.StatistikWirkungUmsatz = 1 THEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW),0) - isnull(isnull(stueck.roherloes,pos.roherloes),0)
				ELSE CASE WHEN bela.StatistikWirkungUmsatz = 1 THEN isnull((isnull(ham1.[MEK_Hedging],ham2.[MEK_Hedging]) * mAufschlag.[Aufschlag]*isnull(isnull(stueck.mengebasis,pos.menge),0)),0) END END), 2) AS [Wareneinsatz MEK Hedging vor Retouren]

	,round(sum(CASE WHEN artikel.Artikelnummer like '4%' OR artikel.Artikelnummer like '6%' OR artikel.Artikelnummer like '7%' AND bela.StatistikWirkungUmsatz = -1 THEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW),0) - isnull(isnull(stueck.roherloes,pos.roherloes),0)
				ELSE CASE WHEN bela.StatistikWirkungUmsatz = -1 THEN isnull((isnull(ham1.[MEK_Hedging],ham2.[MEK_Hedging]) * mAufschlag.[Aufschlag]*isnull(isnull(stueck.mengebasis,pos.menge),0)),0) END END), 2) AS [Retournierter Wareneinsatz MEK Hedging]
	
	,round(sum(CASE WHEN artikel.Artikelnummer like '4%' OR artikel.Artikelnummer like '6%' OR artikel.Artikelnummer like '7%' THEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW) * bela.StatistikWirkungUmsatz,0) - isnull(isnull(stueck.roherloes,pos.roherloes) * bela.StatistikWirkungUmsatz,0)
				ELSE isnull(isnull(ham1.[MEK_Hedging],ham2.[MEK_Hedging]) * mAufschlag.[Aufschlag] * CASE WHEN artikel.Artikelnummer like '9%' THEN 0 ELSE isnull(isnull(stueck.mengebasis,pos.menge),0) * bela.[StatistikWirkungUmsatz] END,0) 
				END),2) AS [Wareneinsatz MEK Hedging nach Retouren]

--- MEK PLAN

	,round(sum(CASE WHEN artikel.Artikelnummer like '4%' OR artikel.Artikelnummer like '6%' OR artikel.Artikelnummer like '7%' AND bela.StatistikWirkungUmsatz = 1 THEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW),0) - isnull(isnull(stueck.roherloes,pos.roherloes),0)
				ELSE CASE WHEN bela.StatistikWirkungUmsatz = 1 THEN isnull((isnull(ham1.[MEK_Plan_YoY],ham2.[MEK_Plan_YoY]) * mAufschlag.[Aufschlag]*isnull(isnull(stueck.mengebasis,pos.menge),0)),0) END END), 2) AS [Wareneinsatz MEK Plan vor Retouren]

	,round(sum(CASE WHEN artikel.Artikelnummer like '4%' OR artikel.Artikelnummer like '6%' OR artikel.Artikelnummer like '7%' AND bela.StatistikWirkungUmsatz = -1 THEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW),0) - isnull(isnull(stueck.roherloes,pos.roherloes),0)
				ELSE CASE WHEN bela.StatistikWirkungUmsatz = -1 THEN isnull((isnull(ham1.[MEK_Plan_YoY],ham2.[MEK_Plan_YoY]) * mAufschlag.[Aufschlag]*isnull(isnull(stueck.mengebasis,pos.menge),0)),0) END END), 2) AS [Retournierter Wareneinsatz MEK Plan]
	
	,round(sum(CASE WHEN artikel.Artikelnummer like '4%' OR artikel.Artikelnummer like '6%' OR artikel.Artikelnummer like '7%' THEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW) * bela.StatistikWirkungUmsatz,0) - isnull(isnull(stueck.roherloes,pos.roherloes) * bela.StatistikWirkungUmsatz,0)
				ELSE isnull(isnull(ham1.[MEK_Plan_YoY],ham2.[MEK_Plan_YoY]) * mAufschlag.[Aufschlag] * CASE WHEN artikel.Artikelnummer like '9%' THEN 0 ELSE isnull(isnull(stueck.mengebasis,pos.menge),0) * bela.[StatistikWirkungUmsatz] END,0) 
				END),2) AS [Wareneinsatz MEK Plan nach Retouren]

FROM	[OLReweAbf].[dbo].[KHKVKBelegarten] AS bela WITH(NOLOCK)
		INNER JOIN [OLReweAbf].[dbo].[KHKVKBelege] AS bel WITH(NOLOCK)
			ON  bela.Kennzeichen = bel.Belegkennzeichen
			AND CASE WHEN @Mandant = 0 THEN @Mandant ELSE bel.[Mandant] END = @Mandant
			AND YEAR(bel.Belegdatum) BETWEEN @JahrVon AND @JahrBis
			AND MONTH(bel.Belegdatum) BETWEEN @MonatVon AND @MonatBis
			--AND DAY(bel.Belegdatum) BETWEEN @TagVon AND @TagBis
		LEFT JOIN [OLReweAbf].[dbo].[KHKVKBelegePositionen] AS pos WITH(NOLOCK)
			ON  bel.BelID = pos.BelID
			AND bel.Mandant = pos.Mandant
		LEFT JOIN [OLReweAbf].[dbo].[KHKVKBelegeStuecklisten] AS stueck WITH(NOLOCK)
			ON  pos.BelPosID = stueck.BelPosID
			AND pos.Mandant = stueck.Mandant
			AND stueck.Artikelnummer NOT LIKE '7%' -- neue Bedingung
		LEFT JOIN [ChalTecDWH].[dbo].[HistorischerArtikelMEK] AS ham1 WITH(NOLOCK)
			ON ham1.[Artikelnummer] = '10' + RIGHT(ISNULL(stueck.[Artikelnummer],pos.[Artikelnummer]),6)
			AND ISNULL(stueck.[Artikelnummer],pos.[Artikelnummer]) LIKE '[15]%'
			AND ham1.[Datum] = CAST(bel.[Belegdatum] AS DATE)
		LEFT JOIN (
				SELECT 
					[Artikelnummer]
					,[MEK_WE]
					,[MEK_Hedging]
					,[MEK_Plan_YoY]
					,rank() over (partition by Artikelnummer order by Datum desc, [MEK_Plan_YoY] desc, Mandant asc) AS Rang
				FROM [ChalTecDWH].[dbo].[HistorischerArtikelMEK]
				WHERE Artikelnummer like '1%'
			) AS ham2
			ON ham2.[Artikelnummer] = '10' + RIGHT(ISNULL(stueck.[Artikelnummer],pos.[Artikelnummer]),6)
			AND ISNULL(stueck.[Artikelnummer],pos.[Artikelnummer]) LIKE '[15]%'
			AND ham2.Rang = 1
		LEFT JOIN (
			SELECT 1 AS [Mandant], CAST(1 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 2 AS [Mandant], CAST(1.3 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 3 AS [Mandant], CAST(1.2 AS MONEY) AS [Aufschlag]
		) AS MAufschlag
			ON MAufschlag.[Mandant] = bel.[Mandant]
		LEFT JOIN [OLReweAbf].[dbo].[KHKVKBelegeZKD] AS kz WITH(NOLOCK)
			ON kz.[BelID] = bel.[BelID]
			AND kz.[Mandant] = bel.[Mandant]
		INNER JOIN [OLReweAbf].[dbo].[KHKArtikel] AS artikel WITH(NOLOCK)
			ON  ISNULL(stueck.Artikelnummer, pos.Artikelnummer) = artikel.Artikelnummer
			AND artikel.Mandant = 1
		LEFT JOIN [OLReweAbf].[dbo].[KHKGruppen] AS produktkategorie WITH(NOLOCK)
			ON  produktkategorie.Mandant = 1
			AND artikel.User_produktkategorie = produktkategorie.gruppe
			AND produktkategorie.typ = 1000000603
		LEFT JOIN [OLReweAbf].[dbo].[KHKGruppen] AS Markenklasse WITH(NOLOCK)
			ON  Markenklasse.Mandant = 1
			AND artikel.User_Markenklasse = Markenklasse.gruppe
			AND Markenklasse.typ = 1000000600
		LEFT JOIN [OLReweAbf].[dbo].[KHKGruppen] AS Gruppen WITH(NOLOCK)
			ON  bel.Kundengruppe = gruppen.gruppe
			AND Gruppen.typ = 11
			AND bel.Mandant = Gruppen.Mandant
		LEFT JOIN [OLReweAbf].[dbo].[ChalTec_Kundennummer_Mapping] AS Map
			ON bel.A0Empfaenger = Map.Kundennummer
			AND bel.Mandant = Map.Mandant 
		LEFT JOIN [OLReweAbf].[dbo].[KHKVKBelege] AS ref WITH(NOLOCK)
			ON  ref.BelID = bel.ReferenzBelID
			AND ref.Mandant = bel.Mandant
		LEFT OUTER JOIN [OLReweAbf].[dbo].[KHKArtikelgruppen] AS Artgruppe1
			ON artikel.Hauptartikelgruppe = artgruppe1.Artikelgruppe
			and artgruppe1.Mandant = 1
			and len(artgruppe1.Artikelgruppe) = 9
		LEFT OUTER JOIN [OLReweAbf].[dbo].[KHKArtikelgruppen] AS Artgruppe2
			ON artikel.Vaterartikelgruppe = artgruppe2.Artikelgruppe
			and artgruppe2.Mandant = 1
			and len(artgruppe2.Artikelgruppe) = 9
		LEFT OUTER JOIN [OLReweAbf].[dbo].[KHKArtikelgruppen] AS Artgruppe3
			ON artikel.Artikelgruppe = artgruppe3.Artikelgruppe
			and artgruppe3.Mandant = 1
			and len(artgruppe3.Artikelgruppe) = 9
		LEFT JOIN 
			(
			SELECT 
				BelID
				, Mandant
				, Frachtfuehrer
				, ROW_NUMBER() OVER (PARTITION BY BelID, Mandant ORDER BY ID DESC) AS Anzahl
			FROM [OLReweAbf].[dbo].[LBVLogVersanddaten] WITH (NOLOCK)
			) AS vlog
			ON bel.BelID = vlog.BelID
			AND bel.Mandant = vlog.Mandant
			AND vlog.Anzahl = 1
		LEFT JOIN [OLReweAbf].[dbo].[LBAmazonOrders] AS lao WITH(NOLOCK)
			ON lao.[OrderID] = bel.[Matchcode]
			AND lao.[Mandant] = bel.[Mandant]
			AND lao.[IsPrime] = -1

WHERE  
1=1
AND bela.StatistikWirkungUmsatz <> 0
AND artikel.Artikelnummer NOT IN ('10035048','10035049','10035050','10035051','10035052','10035073','10035074','10035075','10035076')
AND NOT 	CASE
				WHEN Map.KG_Bezeichnung IN ('Mandanten','Weiterberechnung') THEN Map.KG_Bezeichnung
				WHEN bel.Kundengruppe IN ('51','52','60','61','62','63','64','65','66','79','82','83','84','86','88') THEN 'Andere Marktplätze'
				WHEN Gruppen.Tag IN ('Amazon','eBay','Shop','SK','Mandanten','Weiterberechnung') THEN Gruppen.Tag
				ELSE 'Diverse/B2B'
			END = 'Mandanten'
AND NOT 	CASE
				WHEN Map.KG_Bezeichnung IN ('Mandanten','Weiterberechnung') THEN Map.KG_Bezeichnung
				WHEN bel.Kundengruppe IN ('51','52','60','61','62','63','64','65','66','79','82','83','84','86','88') THEN 'Andere Marktplätze'
				WHEN Gruppen.Tag IN ('Amazon','eBay','Shop','SK','Mandanten','Weiterberechnung') THEN Gruppen.Tag
				ELSE 'Diverse/B2B'
			END = 'Weiterberechnung'
AND NOT bel.VorID in (
					'9626811'
					,'9672915'
					,'9702176'
					,'9706607'
					,'9715626'
					,'9732554'
					,'9747301'
					,'9750402'
					,'9753291'
					,'9753927'
					,'9758098'
					,'9758104'
					,'9758105'
					,'9758304'
					,'9761976'
					,'9762262'
					,'9762794'
					,'9762864'
					,'10040050'
					,'10042335'
					,'10043609'
					,'10040763'
					,'10041013'
					,'10041749'
					,'10040450'
					,'10041767'
					,'10044308'
					,'10455749'
					,'10458590'
					,'10455750'
					,'10455751'
					,'11613296'		--ab hier OTTO doppelte Belege in 12/2019
					,'11646521'
					,'11646522'
					,'11649021'
					,'11653389'
					,'11653728'
					,'11653729'
					,'11653730'
					,'11653731'
					,'11653733'
					,'11653734'
					,'11653735'
					,'11653736'
					,'11653737'
					,'11653740'
					,'11653744'
					,'11653745'
					,'11653746'
					,'11653747'
					,'11653748'
					,'11653749'
					,'11688503'
					,'11688505'
					,'11688506'
					,'11688507'
					,'11688508'
					,'11693021'
					,'11695818'
					,'11710467'
					,'11710469'
					,'11710471'
					,'11710472'
					,'11710473'
					,'11712834'
					,'11717945'
					,'11727976'
					,'11727977'
					,'11727978'
					,'11727981'
					,'11727982'
					,'11744310'
					,'11744311'
					,'11744314'
					,'11744315'
					,'11744316'
					,'11744317'
					,'11744850'
					,'11811670'
					,'11813885'
					,'11819057'
					,'11819058'
					)

GROUP BY
	bel.Mandant,
	YEAR(bel.Belegdatum),
	MONTH(bel.Belegdatum),
	DAY(bel.Belegdatum),	-- nie auskommentieren!!!
	--bela.StatistikWirkungUmsatz,
	--bela.Gleichgewichtsstatistik,
	--bel.VorID,
	--bel.BelID,
	--bel.ReferenzBelID,
	bel.Belegnummer,	-- nie auskommentieren!!!
	bel.Belegkennzeichen,
	bel.Belegart,
	--bel.Vertreter,
	kz.Zahlungskond,
	--vlog.Frachtfuehrer,
	--bel.A0Empfaenger,
	--bel.A0Name1,

	CASE
		WHEN Map.KG_Bezeichnung IN ('Mandanten','Weiterberechnung') THEN Map.KG_Bezeichnung
		WHEN bel.Kundengruppe IN ('51','52','60','61','62','63','64','65','66','79','82','83','84','86','88') THEN 'Andere Marktplätze'
		WHEN Gruppen.Tag IN ('Amazon','eBay','Shop','SK','Mandanten','Weiterberechnung') THEN Gruppen.Tag
		ELSE 'Diverse/B2B'
	END,

	CASE
		WHEN Map.KG_Bezeichnung IN ('Mandanten','Weiterberechnung') THEN Map.KG_Bezeichnung
		WHEN bel.Kundengruppe IN ('88') THEN 'Darty'
		WHEN bel.Kundengruppe IN ('63') THEN 'La Redoute'
		WHEN Gruppen.Tag IN ('Amazon','Cdiscount','eBay','FNAC','Mandanten','Otto','Shop','SK','Weiterberechnung') THEN Gruppen.Tag
		WHEN bel.Kundengruppe IN ('51','52','60','61','62','63','64','65','66','79','82','83','84','86','88') THEN 'Andere Marktplätze'
		ELSE 'Diverse/B2B'
	END,

	--bel.Kundengruppe,

	CASE 
		WHEN Map.KG_Bezeichnung IN ('Mandanten','Weiterberechnung') THEN Map.KG_Bezeichnung
		WHEN bel.Kundengruppe IN ('88') THEN 'Darty'
		WHEN bel.Kundengruppe IN ('38') THEN 'CS B2B'
		WHEN bel.Kundengruppe IN ('11','16','20','21','26','27','30','31','32','33','34','36','37','40','41','42','75','92','93','99') THEN 'E-Star'
		WHEN bel.Kundengruppe IN ('101','102','103','104','105') THEN 'Auna'
		WHEN bel.Kundengruppe IN ('89','200','201','202','203','204','205','218','219','220','221','222','223','224','225') THEN 'Klarstein'
		WHEN bel.Kundengruppe IN ('301') THEN 'Numan'
		WHEN bel.Kundengruppe IN ('400','401','402','403','404','405','406','407','408','409','410') THEN 'CapitalSports'
		WHEN bel.Kundengruppe IN ('45','46','47','48','49') THEN 'Blumfeldt'
		WHEN Gruppen.Tag IN ('Amazon','Cdiscount','eBay','FNAC','Groupon','Laden','Mandanten','MeinPaket','Otto','SK','Telefonverkauf','Weiterberechnung') THEN Gruppen.Tag 
		ELSE ISNULL(Gruppen.Bezeichnung,'n/a')
	END,

	CASE
		WHEN Map.KG_Bezeichnung IN ('Mandanten') THEN 'DE ' + Map.KG_Bezeichnung
		WHEN (bel.Kundengruppe = 16 AND bel.Mandant = 1) THEN 'DE Mandanten' 
		WHEN Map.KG_Bezeichnung IN ('Weiterberechnung') THEN Map.KG_Bezeichnung
		WHEN bel.A1Land IN ('DE','ES','FR','GB','IT') THEN bel.A1Land
		WHEN Gruppen.Tag IN ('SK') THEN 'SK'
		ELSE 'INT'
	END,

	--bel.A0Land,
	--bel.A1Land,

	CASE 
		WHEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW),0) = 0 THEN 0
		WHEN artikel.Artikelnummer IN ('90000050') THEN 1
		WHEN artikel.Artikelnummer IN ('90000028','90000029','90000128') THEN 0
		WHEN left(artikel.Artikelnummer,1) = 9 AND left(artikel.Matchcode,6) = 'Kulanz' THEN 0
		WHEN left(artikel.Artikelnummer,1) = 9 THEN 0
		ELSE 1
	END,

	CASE 
		WHEN bel.[Belegkennzeichen] IN ('VSD') AND Gruppen.Tag IN ('Amazon') THEN 1
		WHEN ref.[Belegkennzeichen] IN ('VSD') AND Gruppen.Tag IN ('Amazon') THEN 1
		ELSE 0
	END,

	CASE 
		WHEN lao.[OrderID] IS NOT NULL THEN 1
		ELSE 0
	END,

	CASE 
		WHEN bel.[Vertreter] IN ('V0004','V3001','V3002','V3003','V3004','V3005','V3006','V3007') AND bel.[Mandant] = 1 THEN 1
		WHEN bel.[Vertreter] IN ('V0004','V3001','V3002','V3003','V3004','V3005','V3006','V3007') AND bel.[Mandant] = 3 THEN 1
		WHEN bel.[Kundengruppe] IN ('23','24','25','28','35','106','113','207','214','215') THEN 1
		WHEN bel.[Mandant] = 2 THEN 1
		ELSE 0
	END,

	--CASE 
	--	WHEN ISNULL(artikel.IstEinmalartikel, 0) = -1 THEN 1 
	--	ELSE 0
	--END,

	CASE
		WHEN isnull(isnull(stueck.gesamtpreisinternEW,pos.gesamtpreisinternEW),0) = 0 THEN 1
		ELSE 0
	END,

	CASE 	
		WHEN bela.StatistikWirkungUmsatz <> -1 THEN 'n/a'
		WHEN bel.[Belegkennzeichen] IN ('VFN','VFT','VSY') THEN 'Storno/NiLi'
		WHEN bel.[Belegkennzeichen] IN ('VFM') AND NOT (left(artikel.Artikelnummer,1) = 9 OR (ref.[Belegkennzeichen] IN ('VSD') AND Gruppen.Tag IN ('Amazon'))) THEN 'Kundenstorno'
		WHEN bel.[Belegkennzeichen] IN ('VFS') AND NOT left(artikel.Artikelnummer,1) = 9 THEN 'Korrekturen'
		WHEN left(artikel.Artikelnummer,1) = 9 AND left(artikel.Matchcode,6) = 'Kulanz' THEN 'Kulanzen'
		WHEN left(artikel.Artikelnummer,2) = 91 THEN 'Kulanzen'
		WHEN left(artikel.Artikelnummer,1) = 9 THEN 'Sonstige 9er Artikel'
		WHEN Gruppen.Tag IN ('SK') AND bel.Belegkennzeichen IN ('VFG') AND kz.Zahlungskond IN ('NN') THEN 'Kundengutschriften SK manuell'
		ELSE 'Kundengutschriften'
	END,

	artikel.Artikelnummer,	-- nie auskommentieren!!!
	artikel.Matchcode,	-- nicht auskommentieren, wenn Artikel- oder Gutschriftenart ausgegeben wird!!!

	CASE	
		WHEN left(artikel.Artikelnummer,1) = 1 AND artikel.Stuecklistentyp = 2 THEN '1_Kitting'
		WHEN left(artikel.Artikelnummer,1) = 1 THEN '1_A-Ware'
		WHEN left(artikel.Artikelnummer,1) = 3 THEN '3_UK Plug-Artikel'
		WHEN left(artikel.Artikelnummer,1) = 4 THEN '4_Zubehör'
		WHEN left(artikel.Artikelnummer,1) = 5 THEN '5_B-Ware'
		WHEN left(artikel.Artikelnummer,1) = 6 THEN '6_Set-Artikel'
		WHEN left(artikel.Artikelnummer,1) = 7 THEN '7_Kitting'
		WHEN artikel.Artikelnummer IN ('90000050') THEN '9_Voucher'
		WHEN artikel.Artikelnummer IN ('90000028','90000029','90000128') THEN '9_Defektgeräte'
		WHEN left(artikel.Artikelnummer,1) = 9 AND left(artikel.Matchcode,6) = 'Kulanz' THEN '9_Kulanzen'
		WHEN left(artikel.Artikelnummer,1) = 9 THEN '9_Sonstige 9er Artikel'
		ELSE 'Other'
	END,

	--artikel.USER_Sourcer,

	--CASE	
	--	WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht physische Artikel: Mandanten'
	--	WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht physische Artikel: sonst. Erlöse'
	--	ELSE (isnull(produktkategorie.Bezeichnung,'No Category') + ' (' + case when Markenklasse.Bezeichnung = 'X' then 'Z' else isnull(Markenklasse.Bezeichnung,'Z') END +')') 
	--END,

	CASE 
		WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht physische Artikel: Mandanten'
		WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht physische Artikel: sonst. Erlöse'
		ELSE Artgruppe1.Bezeichnung
	END,

	--CASE 
	--	WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht physische Artikel: Mandanten'
	--	WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht physische Artikel: sonst. Erlöse'
	--	ELSE Artgruppe2.Bezeichnung
	--END,

	--CASE 
	--	WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht physische Artikel: Mandanten'
	--	WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht physische Artikel: sonst. Erlöse'
	--	ELSE Artgruppe3.Bezeichnung
	--END,

	--CASE 	
	--	WHEN isnull(artikel.User_Markenklasse,0) in (3,4) THEN 'ja' 
	--	WHEN isnull(artikel.User_Markenklasse,0) in (1,2) THEN 'nein' 
	--	ELSE 'nicht klassifiziert' 
	--END,

	--CASE WHEN isnull(artikel.User_VKMarke,'') IN (	
	--	'Auna',
	--	'BESOA',
	--	'Blumfeldt',
	--	'CapitalS',
	--	'DURAMAXX',
	--	'FrontStage',
	--	'KLARFIT',
	--	'Klarstein',
	--	'Lightcraft',
	--	'Malone',
	--	'Numan',
	--	'oneConcept',
	--	'SCHUBERT',
	--	'Waldbeck',
	--	'Yuk',
	--	'resident',
	--	'auna_pro') THEN 'ja'  
	--	WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht klassifiziert'
	--	WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht klassifiziert'
	--	ELSE 'nein'
	--END,

	--CASE 	
	--	WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht physische Artikel: Mandanten' 
	--	WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht physische Artikel: sonst. Erlöse'
	--	ELSE isnull(artikel.User_VKMarke,'<no name>') 
	--END,

	--CASE 	
	--	WHEN artikel.Artikelnummer like '9%' and bel.Kundengruppe in (16) and bel.Mandant = 1 THEN 'nicht physische Artikel: Mandanten' 
	--	WHEN artikel.Artikelnummer like '9%' and not (bel.Kundengruppe in (16) and bel.Mandant = 1) THEN 'nicht physische Artikel: sonst. Erlöse'
	--	WHEN isnull(artikel.User_VKMarke,'') IN (	
	--	'Auna',
	--	'BESOA',
	--	'Blumfeldt',
	--	'CapitalS',
	--	'DURAMAXX',
	--	'FrontStage',
	--	'KLARFIT',
	--	'Klarstein',
	--	'Lightcraft',
	--	'Malone',
	--	'Numan',
	--	'oneConcept',
	--	'SCHUBERT',
	--	'Waldbeck',
	--	'Yuk',
	--	'resident',
	--	'auna_pro') THEN artikel.User_VKMarke
	--	ELSE 'Fremdmarke' 
	--END,

	--CASE	
	--	WHEN bel.Belegdatum >= getdate()-8 then artikel.User_categorymanagement 
	--	ELSE 'n/a'
	--END,

	ROUND(CASE WHEN bel.[ZWInternEW] > 0 THEN ISNULL((((bel.[Nettobetrag] * ISNULL(bel.[WKzKursFw],1)) - bel.[ZWInternEW]) * ((ISNULL(stueck.[GesamtpreisInternEW], pos.[GesamtpreisInternEW])) / bel.[ZWInternEW])) * bela.[StatistikWirkungUmsatz],0) ELSE 0 END, 2)
) AS TMP

GROUP BY
	[Mandant]
	, [Jahr]
	, [Monat]
	--, [Tag]
	--, [StatistikWirkungUmsatz]
	--, [Gleichgewichtsstatistik]
	--, [VorID]
	--, [BelID]
	--, [ReferenzBelID]
	--, [Belegnummer]
	, [Belegkennzeichen]
	, [Belegart]
	--, [Vertreter]
	, [Zahlungsart]
	--, [Carrier]
	--, [A0Empfaenger]
	--, [A0Name]
	, [Channel]
	, [Channel_Planung]
	--, [Kundengruppennummer]
	, [Kundengruppe]
	, [Country]
	--, [Rechnungsland]
	--, [Lieferland]
	, [Flag_SalesView]
	, [Flag_FBA]
	, [Flag_PBM]
	, [Flag_B2B]
	--, [Flag_EOL]
	, [Flag_0EUR_Rechnung]
	, [Gutschriftenart]
	--, [Artikelnummer]
	--, [Artikelbezeichnung]
	, [Artikelart]
	--, [Sourcer]
	--, [Produktkategorie]
	, [Artikelgruppe_Ebene1]
	--, [Artikelgruppe_Ebene2]
	--, [Artikelgruppe_Ebene3]
	--, [OwnBrand]
	--, [OwnBrand_bereinigt]
	--, [Brand]
	--, [Brand_bereinigt]
	--, [CatMan]