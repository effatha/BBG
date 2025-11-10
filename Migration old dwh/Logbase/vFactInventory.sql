SELECT top 10

       Warehouse								= 'Kali'
	  ,SAPStorageLocation						= 1000
	  ,[InventurlisteID]						= Inventurliste.ID
	  ,[Id]										= InventurlistenpositiON.ID
      ,[Owner]									= InventurlistenpositiON.[Betreiber]
	  ,[InventoryList]							= Inventurliste.[Nummer]
      ,[InventoryVariant]						= Inventurliste.[InventurVariante]
      ,[InventoryType]							= Inventurliste.[Typ]
	  ,[InventoryListStatus]					= Inventurliste.[Status]
	  ,[StorageLocation]						= Lagerort.[Name]
	  ,[StorageArea]							= Lagerbereich.[Name]
	  ,[RackCoordinateFrom]						= Inventurliste.[KoordinateRegalVON]
      ,[RackCoordinateTo]						= Inventurliste.[KoordinateRegalBis]
      ,[ColumnCoordinateFrom]					= Inventurliste.[KoordinateSaeuleVON]
      ,[ColumnCoordinateTo]						= Inventurliste.[KoordinateEbeneVON] 
      ,[LevelCoordinateFrom]					= Inventurliste.[KoordinateEbeneVON]
      ,[LevelCoordinateTo]						= Inventurliste.[KoordinateEbeneBis]
	  ,[Material]								= Artikelstamm.Nummer
      ,[StorageBin]								= Lagerplatz.[Name]
      ,[LeIdent]								= InventurlistenpositiON.[LeIdent]
      ,[Ean]									= InventurlistenpositiON.[Ean]
      ,[IsQuantity]								= InventurlistenpositiON.MengeIst
      ,[TargetQuantity]							= InventurlistenpositiON.MengeSoll
      ,[Quality]								= InventurlistenpositiON.[WarenzustAND]
	  ,[InventoryListNew]						= Inventurliste.[ZeitNeu]
      ,[InventoryListUpdate]					= Inventurliste.[ZeitAend]
      ,[BBD]									= InventurlistenpositiON.[MHD]
      ,[Charge]									= InventurlistenpositiON.[Charge]
      ,[Comment]								= InventurlistenpositiON.[Meldung]
	  ,[InventoryListPositionStatus]			= InventurlistenpositiON.[Status]
	  ,[InventoryLiPoCreationStartDate]			= InventurlistenpositiON.[ZeitNeu]
      ,[DimInventoryLiPoCreationEndDate]		= InventurlistenpositiON.[ZeitAend]
FROM  [CT dwh 02 Data].kali.[tWMSInventurliste] as Inventurliste WITH(NOLOCK)
INNER JOIN  [CT dwh 02 Data].kali.[tWMSInventurlistenpositiON] as InventurlistenpositiON WITH(NOLOCK)
		ON  InventurlistenpositiON.InventurlisteId=Inventurliste.Id
LEFT JOIN   [CT dwh 02 Data].kali.[tWMSLager] as Lager WITH(NOLOCK)
		ON  Lager.Id=Inventurliste.LagerId
LEFT JOIN  [CT dwh 02 Data].kali.[tWMSArtikelstamm] as Artikelstamm WITH(NOLOCK)
		ON Artikelstamm.Id=InventurlistenpositiON.ArtikelstammId
LEFT JOIN  [CT dwh 02 Data].kali.[tWMSLagerplatz] as Lagerplatz WITH(NOLOCK)
		ON  Lagerplatz.Id=InventurlistenpositiON.LagerplatzId
LEFT JOIN  [CT dwh 02 Data].kali.[tWMSLagerbereich] as Lagerbereich WITH(NOLOCK)
		ON  Lagerbereich.Id=Inventurliste.LagerbereichId
	LEFT JOIN  [CT dwh 02 Data].kali.[tWMSLagerort] as Lagerort WITH(NOLOCK)
		ON  Lagerort.Id=Inventurliste.LagerortId
