SELECT
			 
			 ProcessID = cast(Belege.VorID as nvarchar(10))
			,CompanyID = Belege.Mandant
			,TransactionTypeShort = Belege.Belegkennzeichen
			,TransactionTypeDetail = Belegarten.Bezeichnung 
			,DocumentNo = cast(Belege.Belegnummer  as nvarchar(10))
			,DocumentID = Belege.BelID
			,DocumentPositionID = ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID) 
			,DocumentItemPosition = ISNULL(substring(BelegePositionen.Position,1,1),1)
			,ReferenceDocumentID = cast(Belege.ReferenzBelID as nvarchar(10))
			,ItemNo = ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer)
			,ItemNoProduct = BelegePositionen.Artikelnummer

			,Quantity = CAst(ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) as decimal(15,3))
			,NetPrice = cast(CAST(CASE
							WHEN ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0 THEN (ISNULL(Stuecklisten.GesamtPreisInternEW, BelegePositionen.GesamtPreisInternEW))	
							ELSE 0
						END as  decimal(15,3)) 
						+ Cast(CASE WHEN ZWInternEW > 0 THEN Cast((Nettobetrag * isnull(WKzKursFw,1) - [ZWInternEW]) * 
						(isnull(Stuecklisten.[GesamtpreisInternEW], BelegePositionen.[GesamtpreisInternEW])/ZWInternEW) as decimal(9,4)) ELSE 0 END as decimal(15,3))
						as decimal(13,2))
			,DeliveryCountry = Belege.A1Land
			,InvoiceCountry = Belege.A0Land
			,CustomerID = Belege.A0Empfaenger
			,MEK_WE = abs(round((CASE WHEN (ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '4%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '6%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '7%') 
					and ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0  THEN 
								(isnull(isnull(Stuecklisten.gesamtpreisinternEW,BelegePositionen.gesamtpreisinternEW) ,0) - isnull(isnull(Stuecklisten.roherloes,BelegePositionen.roherloes) ,0))/ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
				ELSE isnull(ham1.[MEK_WE] *  (CASE WHEN  BELEGE.mandant = 2 AND Belege.Belegkennzeichen in ('VVA','VVB','VVM','VVN') AND BELEGE.Kundengruppe = 116 THEN 1 ELSE mAufschlag.[Aufschlag] END)  * CASE WHEN ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '9%' THEN 0 ELSE 1 END,0) 
				END),2)) * ( CAst(ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) as decimal(15,3)))
			,MEK_Hedging = abs(round((CASE WHEN (ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '4%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer)like '6%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '7%') and ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0  THEN (isnull(isnull(Stuecklisten.gesamtpreisinternEW,BelegePositionen.gesamtpreisinternEW),0) - isnull(isnull(Stuecklisten.roherloes,BelegePositionen.roherloes) ,0))/ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
				ELSE isnull(ham1.[MEK_Hedging] *  (CASE WHEN  BELEGE.mandant = 2 AND Belege.Belegkennzeichen in ('VVA','VVB','VVM','VVN') AND BELEGE.Kundengruppe = 116 THEN 1 ELSE mAufschlag.[Aufschlag] END)  * CASE WHEN ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '9%' THEN 0 ELSE 1 END,0) 
				END),2))* ( CAst(ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) as decimal(15,3)))
			,MEK_Plan = abs(round((CASE WHEN (ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '4%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '6%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '7%') and ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0  THEN (isnull(isnull(Stuecklisten.gesamtpreisinternEW,BelegePositionen.gesamtpreisinternEW) ,0) - isnull(isnull(Stuecklisten.roherloes,BelegePositionen.roherloes) ,0))/ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
				ELSE isnull(ham1.[MEK_Plan_YoY] *  (CASE WHEN  BELEGE.mandant = 2 AND Belege.Belegkennzeichen in ('VVA','VVB','VVM','VVN') AND BELEGE.Kundengruppe = 116 THEN 1 ELSE mAufschlag.[Aufschlag] END)  * CASE WHEN ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer)like '9%' THEN 0 ELSE 1 END,0) 
				END),2))* ( CAst(ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) as decimal(15,3)))
			,ChannelID = Belege.Kundengruppe
			,ChannelID_new = CONCAT(cast(Belege.Kundengruppe as nvarchar(40)),CASE WHEN amz_mkp.OrderID IS NOT NULL THEN right(amz_mkp.SalesChannel,2) ELSE '' END)
			,NetPriceForeign = CAST(CAST (CASE
								WHEN ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0 
									THEN (ISNULL(Stuecklisten.GesamtpreisInternEW, BelegePositionen.GesamtpreisIntern ) / Case when Stuecklisten.GesamtpreisInternEW is null then 1 else isnull(WKzKursFw,1) end)	
								ELSE 0
							   END as   decimal(13,2)) -- now we had  the document footer
								+Cast(CASE WHEN ZWInternEW > 0 THEN Cast((Nettobetrag * isnull(WKzKursFw,1) - [ZWInternEW]) * (isnull(Stuecklisten.[GesamtpreisInternEW], BelegePositionen.[GesamtpreisInternEW])/ZWInternEW) as decimal(9,4)) ELSE 0 END as  decimal(13,2))
								as decimal(13,2))

			,IncidentFlag = Cast(CASE WHEN incident.ProcessID IS NOT NULL THEN 1 ELSE 0 END as bit)
			,DimTransactionDateKey = cast(format(Belegdatum,'yyyyMMdd') as int)
			,DimTransactionTimeKey = case when format(Belegdatum,'HHmmss') = '000000' then 240000 else cast(format(Belegdatum,'HHmmss') as int) end
			,Salesman = Belege.Vertreter
			,DocumentFooter = Cast(CASE WHEN ZWInternEW > 0 THEN Cast((Nettobetrag * isnull(WKzKursFw,1) - [ZWInternEW]) * (isnull(Stuecklisten.[GesamtpreisInternEW], BelegePositionen.[GesamtpreisInternEW])/ZWInternEW) as decimal(9,4)) ELSE 0 END as decimal(15,3))
			,Currency = Belege.wkz
			,Channel = CASE WHEN  Channel.Kundengruppe = '116' and  Belegkennzeichen in ('VVA','VVB','VVM','VVN') THEN ISNULL(ISNULL( ChannelNameSAP,Channel.Channel), Gruppen.Bezeichnung)
						ELSE ISNULL(IntCompany.[KG_Bezeichnung],ISNULL(ISNULL( ChannelNameSAP,Channel.Channel), Gruppen.Bezeichnung)) END		-- DEVTCK-18382 - Sales channel fallback
			,Channel_new=CASE	WHEN amz_mkp.OrderID IS NOT NULL														
									THEN amz_mkp.SalesChannel
								WHEN  Channel.Kundengruppe = '116' and  Belegkennzeichen in ('VVA','VVB','VVM','VVN')	
									THEN ISNULL(ISNULL( ChannelNameSAP,Channel.Channel), Gruppen.Bezeichnung)
								ELSE ISNULL(IntCompany.[KG_Bezeichnung],ISNULL(ISNULL( ChannelNameSAP,Channel.Channel), Gruppen.Bezeichnung)) END
			,ChannelGroupI = CASE WHEN  Channel.Kundengruppe = '116' and  Belegkennzeichen in ('VVA','VVB','VVM','VVN') 
									THEN Channel.ChannelGroupI
									ELSE ISNULL(IntCompany.[KG_Bezeichnung],Channel.ChannelGroupI) END
			,ChannelGroupII =  CASE WHEN  Channel.Kundengruppe = '116' and  Belegkennzeichen in ('VVA','VVB','VVM','VVN') 
									THEN Channel.ChannelGroupII
									ELSE ISNULL(IntCompany.[KG_Bezeichnung],Channel.ChannelGroupII) END
			,Fulfillment = 
							case 
								When belege.Kundengruppe in ('116') THEN 'own fulfilment'
								when (belege.Vertreter in ('V0004','V3001','V3002','V3003','V3004','V3005','V3006','V3007') AND belege.mandant in (1,3)) 
												OR (belege.Kundengruppe in ('23','24','25','28','35','106','113','207','214','215')) OR belege.mandant = 2 THEN 'B2B'
								when fba.vorid IS NOT NULL THEN 'FBA' 
								when amazon.KHKVORID IS NOT NULL THEN 'PBM'
							else 'own fulfillment'
							end
			,Intercompany = IntCompany.[KG_Bezeichnung]
			,GrossDocumentFooter = cast(isnull((Cast(CASE WHEN ZWInternEW > 0 THEN Cast((Nettobetrag * isnull(WKzKursFw,1) - [ZWInternEW]) * (isnull(Stuecklisten.[GesamtpreisInternEW], BelegePositionen.[GesamtpreisInternEW])/ZWInternEW) as decimal(9,4)) ELSE 0 END as decimal(15,3))),0) * (1 + (ISNULL(Steuer.Steuersatz, 19)/100))as decimal(15,3))
			,GrossPrice = cast(isnull((CAST(CASE
							WHEN ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0 THEN (ISNULL(Stuecklisten.GesamtPreisInternEW, BelegePositionen.GesamtPreisInternEW))	
							ELSE 0
						END as  decimal(15,3))),0) * (1 + (ISNULL(Steuer.Steuersatz, 19)/100)) as  decimal(15,3))
		    ,GrossPriceForeignCurrency = cast(isnull((CAST(CAST (CASE
								WHEN ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0 
									THEN (ISNULL(Stuecklisten.GesamtpreisInternEW, BelegePositionen.GesamtpreisIntern ) / Case when Stuecklisten.GesamtpreisInternEW is null then 1 else isnull(WKzKursFw,1) end)	
								ELSE 0
							   END as   decimal(13,2)) -- now we had  the document footer
								+Cast(CASE WHEN ZWInternEW > 0 THEN Cast((Nettobetrag * isnull(WKzKursFw,1) - [ZWInternEW]) * (isnull(Stuecklisten.[GesamtpreisInternEW], BelegePositionen.[GesamtpreisInternEW])/ZWInternEW) as decimal(9,4)) ELSE 0 END as  decimal(13,2))
								as decimal(13,2))),0) * (1 + (ISNULL(Steuer.Steuersatz, 19)/100)) as decimal(13,2))
		    ,GrossDocumentFooterForeignCurrency = cast(isnull((Cast(CASE WHEN ZWInternEW > 0 THEN Cast((Nettobetrag * isnull(WKzKursFw,1) - [ZWInternEW]) * (isnull(Stuecklisten.[GesamtpreisInternEW], BelegePositionen.[GesamtpreisInternEW])/ZWInternEW) as decimal(9,4)) ELSE 0 END as decimal(15,3))),0) * (1 + (ISNULL(Steuer.Steuersatz, 19)/100))/ISNULL(WkzKursFW, 1) as decimal(13,2))
			,Carrier = vlog.Frachtfuehrer
			,MarketplaceOrderid = isnull(amz_mkp.OrderID, BELEGE.User_ShopSaleID)
			,SalesAccount = CASE WHEN amz_mkp.OrderID IS NOT NULL THEN amz_mkp.SalesChannel END
			,PaymentMethod = payment.Zahlungskond
			,cast(BELEGE.A1PLZ as [nvarchar] (100)) as DeliveryZipCode	
			,cast(BELEGE.A1Ort as [nvarchar] (250)) as DeliveryCity
			,QuantityProduct = CASE WHEN ISNULL(Stuecklisten.Artikelnummer, isnull(BelegePositionen.Artikelnummer,'')) = BelegePositionen.Artikelnummer then BelegePositionen.Menge when isnull(Subitems.NSubItems,0) = 0 THEN 0 ELSE  cast(1/isnull(Subitems.NSubItems,1) as money) * isnull(BelegePositionen.Menge,0) * isnull(Stuecklisten.MengeBasis,1) END 
			,StorageID = CAST(lager.PlatzID as nvarchar(7))
			,StorageLocation = lager.Platzbezeichnung
			,DimOrderDateKey = cast(format(USER_CD,'yyyyMMdd') as int)
			,DimOrderTimeKey = case when format(USER_CD,'HHmmss') = '000000' then 240000 else cast(format(USER_CD,'HHmmss') as int) end
		From
		[CT dwh 02 Data].dbo.tErpKHKVKBelege AS Belege WITH (NOLOCK)
		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegarten AS Belegarten WITH(NOLOCK) 
			ON 	 Belegarten.Kennzeichen = Belege.Belegkennzeichen   
		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegePositionen AS BelegePositionen WITH(NOLOCK)
			ON Belege.Mandant = BelegePositionen.Mandant
			AND Belege.BelID = BelegePositionen.BelID
			AND BelegePositionen.IsDeletedFlag = 0
		LEFT JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegeStuecklisten As Stuecklisten WITH(NOLOCK)
			ON BelegePositionen.Mandant = Stuecklisten.Mandant
			AND BelegePositionen.BelPosID = Stuecklisten.BelPosID
			AND Stuecklisten.ArtikelNummer not like '7%'
			AND Stuecklisten.IsDeletedFlag = 0
		INNER JOIN EntriesToLoad AS EntriesToLoad
			ON Belege.VorID = EntriesToLoad.VorID
			AND Belege.BelID = EntriesToLoad.BelID
			AND Belege.Mandant = EntriesToLoad.Mandant
			AND ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID) = EntriesToLoad.PositionId

		LEFT JOIN (
				SELECT VORID,ent.BelID,ent.Mandant,BelPosID,sum(qty)NSubItems
				FROM EntriesToLoad ent
				GROUP BY VORID,ent.BelID,ent.Mandant,BelPosID
			) Subitems on Subitems.BelID = belege.BelID and Subitems.Mandant = Belege.Mandant and Subitems.BelPosID = BelegePositionen.BelPosID
	
		LEFT JOIN [CT dwh 02 Data].[dbo].tErpChalTec_Kundennummer_Mapping IntCompany
			ON 
			 Belege.Mandant = IntCompany.Mandant
			AND BELEGE.A0Empfaenger = IntCompany.Kundennummer
		LEFT JOIN [CT dwh 02 Data].[dbo].[tDwhHistorischerArtikelMEK] AS ham1 WITH(NOLOCK)
			ON ham1.[Artikelnummer] = '10' + RIGHT(ISNULL(Stuecklisten.[Artikelnummer],BelegePositionen.[Artikelnummer]),6)
			AND ISNULL(Stuecklisten.[Artikelnummer],BelegePositionen.[Artikelnummer]) LIKE '[15]%'
			AND ham1.[Datum] = CAST(BELEGE.[Belegdatum] AS DATE)
		LEFT JOIN (
			SELECT 1 AS [Mandant], CAST(1 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 2 AS [Mandant], CAST(1.3 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 3 AS [Mandant], CAST(1.2 AS MONEY) AS [Aufschlag]
		) AS MAufschlag
			ON MAufschlag.[Mandant] = BELEGE.[Mandant]
		LEFT JOIN [CT dwh 00 Meta].[config].[tIncidentFlag] incident WITH (NOLOCK)
			ON BELEGE.VorID =  incident.processid and BELEGE.BelId = incident.DocumentId and incident.CompanyId = Belege.Mandant
			AND incident.[IncidentDataType]='Sales' AND incident.Source = 'Sage'
		LEFT JOIN [CT dwh 00 Meta].[dbo].[tChannelAndGroupConfigSales] Channel
			ON Belege.Kundengruppe = Channel.Kundengruppe
			AND Belege.Mandant = Channel.Mandant
		LEFT JOIN [CT dwh 02 Data].[dbo].[tERPKHKGruppen] AS Gruppen WITH(NOLOCK)
			ON  BELEGE.Kundengruppe = gruppen.gruppe
			AND Gruppen.typ = 11
			AND BELEGE.Mandant = Gruppen.Mandant
		LEFT JOIN(
					select KHKVORID,Mandant 
					from [CT dwh 02 Data].[dbo].[tErpLBAmazonOrders] amazon WITH (NOLOCK) 
					WHERE amazon.IsPrime = -1
					Group by KHKVORID,Mandant
				) amazon on amazon.KHKVORID = belege.vorid and amazon.mandant = belege.mandant

		LEFT JOIN(
					select bel.VorID,bel.Mandant 
					from [CT dwh 02 Data].[dbo].[tErpKHKVKBelege] bel WITH (NOLOCK) 
					INNER JOIN EntriesToLoad ent on ent.VorID = bel.VorID and ent.Mandant = bel.Mandant
					INNER JOIN  [CT dwh 02 Data].[dbo].[tERPKHKGruppen] AS gr WITH(NOLOCK)
						ON  bel.Kundengruppe = gr.gruppe
						AND gr.typ = 11
						AND bel.Mandant = gr.Mandant
					WHERE   bel.Belegkennzeichen in ('VSD')
							and gr.Tag = 'Amazon'			
					Group by bel.VorID,bel.Mandant
				) fba on fba.VorID = belege.vorid and fba.mandant = belege.mandant
		LEFT JOIN  [CT dwh 02 Data].[dbo].[tErpKHKSteuertabelle] AS Steuer WITH (NOLOCK)
				ON ISNULL(BelegePositionen.Steuercode, Stuecklisten.Steuercode) = Steuer.Steuercode
		LEFT JOIN 	(
					
						SELECT  distinct Mandant,BelID, Frachtfuehrer, rank() over (partition by mandant,belid order by id desc) rank
					  FROM [CT dwh 02 Data].[dbo].tErpLBVLogVersanddaten WITH(NOLOCK) 
					  where belid in (select distinct belid from EntriesToLoad with(nolock))

				)	vlog 

				ON vlog.BelID = belege.BelId and vlog.mandant = belege.mandant and rank= 1
		Left JOIN  [CT dwh 02 Data].[dbo].[tErpLBAmazonOrders] amz_mkp with(nolock)
			on amz_mkp.KHKVorID = belege.VorId and  belege.Mandant = amz_mkp.Mandant
		Left JOIN  (select Belid,mandant,Zahlungskond,rank() over (partition by belid,mandant order by id desc) last_row  from [CT dwh 02 Data].[dbo].[tErpKHKVKBelegeZKD] zkd with(nolock) where belid in (select distinct belid from EntriesToLoad) ) payment
			on payment.Belid = belege.Belid and  belege.Mandant = payment.Mandant and last_row = 1
		LEFT JOIN lagerposition AS lager WITH(NOLOCK)
				on lager.BelPosID = BelegePositionen.BelPosID
				And lager.Mandant = BelegePositionen.Mandant
				and lager.BelPosStID = ISNULL(CASE WHEN BelegePositionen.BelPosID <> ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID) THEN ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID) ELSE 0 END,0)
				and lager.LagerRank = 1
	
	WHERE
		ISNULL(Stuecklisten.Artikelnummer, isnull(BelegePositionen.Artikelnummer,'')) <> ''
		AND belege.VORID>0
		AND BELEGE.IsDeletedFlag = 0


