USE [CT dwh 02 Data]
GO
/****** Object:  View [dbo].[vMktCrmEmailCampaignsForResponses]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vMktCrmEmailCampaignsForResponses]

AS
-- heute importierte Kampagnen
SELECT DISTINCT CAST(launches.email_campaign_id AS VARCHAR(20)) AS EmailCampaignId, launches.Account, launches.launch_date
FROM [CT dwh 01 Stage].dbo.[tMkt_CrmEmailCampaignLaunches] launches
  JOIN [CT dwh 01 Stage].dbo.[tMkt_CrmEmailCampaigns] campaigns
    ON launches.Account = campaigns.Account AND launches.email_campaign_id = campaigns.id
WHERE CAST(launches.launch_date AS DATE) >= DATEADD(dd, -14, CAST(GETDATE() AS DATE))
  AND CONVERT(DATETIME, launches.launch_date, 120) <= GETDATE()
  AND campaigns.deleted = ''

-- fehlende Responses zu ehemaligen Kampagnen
UNION
SELECT DISTINCT CAST(launches.email_campaign_id AS VARCHAR(20)) AS EmailCampaignId, launches.Account, MIN(launches.launch_date) AS launch_date
FROM [CT dwh 02 Data].dbo.[tMktCrmEmailCampaignLaunches] launches
  JOIN [CT dwh 02 Data].dbo.[tMktCrmEmailCampaigns] campaigns
    ON launches.Account = campaigns.Account AND launches.email_campaign_id = campaigns.id
  LEFT OUTER JOIN [CT dwh 02 Data].dbo.tMktCrmEmailCampaignResponses AS responses
    ON campaigns.Account = responses.Account AND campaigns.id = responses.email_campaign_id
      AND DATEADD(dd, 13, CAST(launches.launch_date AS DATE)) <= responses.[date]
WHERE responses.email_campaign_id IS NULL
  AND campaigns.[status] != -6
  AND YEAR(launches.launch_date) >= 2016
  AND CONVERT(DATETIME, launches.launch_date, 120) <= GETDATE()
  AND campaigns.deleted = ''
GROUP BY CAST(launches.email_campaign_id AS VARCHAR(20)), launches.Account
GO
/****** Object:  View [dbo].[vMktCrmEmailCampaignsForImport]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vMktCrmEmailCampaignsForImport]

AS

SELECT DISTINCT CAST(id AS VARCHAR(20)) AS EmailCampaignId, Account, id
FROM [CT dwh 01 Stage].[dbo].[tMkt_CrmEmailCampaignsList]
UNION
SELECT EmailCampaignId, Account, CAST(EmailCampaignId AS INT) AS id
FROM [CT dwh 02 Data].[dbo].[vMktCrmEmailCampaignsForResponses]
GO
/****** Object:  View [dbo].[vAmzMarketplace]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vAmzMarketplace]
AS

select 100001 as MarketPlaceId, N'amazon.de' as MarketPlaceName, N'A1PA6795UKMFR9' as MarketplaceCode
UNION
select 100002 as MarketPlaceId, N'amazon.es' as MarketPlaceName, N'A1RKKUPIHCS9HS' as MarketplaceCode
UNION
select 100003 as MarketPlaceId, N'amazon.fr' as MarketPlaceName, N'A13V1IB3VIYZZH' as MarketplaceCode
UNION
select 100004 as MarketPlaceId, N'amazon.it' as MarketPlaceName, N'APJ6JRA9NG5V4' as MarketplaceCode
UNION
select 100005 as MarketPlaceId, N'amazon.co.uk' as MarketPlaceName, N'A1F83G8C2ARO7P' as MarketplaceCode
UNION
select 100006 as MarketPlaceId, N'amazon.com' as MarketPlaceName, N'ATVPDKIKX0DER' as MarketplaceCode


GO
/****** Object:  View [dbo].[vErpAmazonPrices]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vErpAmazonPrices]
AS

SELECT 
						  
  --ai.[Artikelnummer]
  i.ItemId, i.Mandant, 
					--	 , ai.[Mandant]
					--	 , ai.MarketplaceID
					p.MarketPlaceId
						 , CONVERT(numeric(18,2), min(CASE 
							WHEN GETDATE() BETWEEN ai.[SaleStartDate] AND ai.[SaleEndDate] THEN ai.[SalePrice]
								ELSE ai.[ListingPrice]
						   END))  AS Einzelpreis
						   , CAST(GETDATE() as date) currentdate
						 
						
					FROM 
						[tERPLBAmazonItems] ai  
						INNER JOIN tErpKHKArtikel i ON ai.Artikelnummer = i.Artikelnummer and ai.Mandant = i.Mandant
						INNER JOIN vAmzMarketplace p ON p.MarketPlaceName = ai.MarketplaceID
					WHERE ai.[Artikelnummer] LIKE '1%'
						AND ai.[Aktiv] = -1
						AND ai.ListingAktiv = -1
						AND ai.[Mandant] = 1
						AND
							CASE 
								WHEN GETDATE() BETWEEN ai.[SaleStartDate] AND ai.[SaleEndDate] THEN ai.[SalePrice]
									ELSE ai.[ListingPrice]
							END IS NOT NULL
					GROUP BY 	
					 i.ItemId, i.Mandant, 
										p.MarketPlaceId
					

GO
/****** Object:  View [dbo].[TableCountRows]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [CT dwh 02 Data]
--GO

--/****** Object:  View [dbo].[TableCountRows]    Script Date: 17/10/2024 10:18:46 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO





CREATE view [dbo].[TableCountRows]
AS
SELECT TableName,SUM([Rows])RowsCount
FROM (
SELECT 
    cs.name +'.' +t.NAME AS TableName,
    i.name as indexName,
    p.[Rows]
FROM 
    sys.tables t
INNER JOIN 
	sys.schemas cs on t.schema_id = cs.schema_id
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
WHERE 
    t.NAME NOT LIKE 'dt%' AND
    i.OBJECT_ID > 255 AND   
    i.index_id <= 1
GROUP BY 
    t.NAME, i.object_id, i.index_id, i.name, p.[Rows],cs.name

	) tableinfo
where TableName not in (
'akeneo.tItemFamily'
,'amazon.tBuyerSellerContactResponseTimeData'
,'amazon.tCustomerExperienceData'
,'amazon.tCustomerServiceData'
,'amazon.tODRData'
,'amazon.tOrderDefectsData'
,'amazon.tPerformanceCheckListData'
,'amazon.tReturnDissatisfactionData'
,'amazon.tTrackingInformationData'
,'bratislava.tPohodaReport'
,'bratislava.tPohodaReport_Union'
,'bratislava.tWMSAdresse'
,'bratislava.tWMSArtikelstamm'
,'bratislava.tWMSAuftragskonfiguration'
,'bratislava.tWMSAuftragsstornierung'
,'bratislava.tWMSCarrier'
,'bratislava.tWMSCarrierCutOff'
,'bratislava.tWMSCarrierMatrix'
,'bratislava.tWMSCarrierServiceLevel'
,'bratislava.tWMSEigner'
,'bratislava.tWMSGate'
,'bratislava.tWMSHandlingUnit'
,'bratislava.tWMSInventurliste'
,'bratislava.tWMSInventurlistenposition'
,'bratislava.tWMSKundenauftrag'
,'bratislava.tWMSKundenauftragsposition'
,'bratislava.tWMSLager'
,'bratislava.tWMSLagerauftrag'
,'bratislava.tWMSLagerauftragsposition'
,'bratislava.tWMSLagerbereich'
,'bratislava.tWMSLagerBuchung'
,'bratislava.tWMSLagerLE'
,'bratislava.tWMSLagerort'
,'bratislava.tWMSLagerplatz'
,'bratislava.tWMSLagerQuant'
,'bratislava.tWMSLand'
,'bratislava.tWMSLoopHandlingType'
,'bratislava.tWMSLoopLagerauftragStatus'
,'bratislava.tWMSOrderState'
,'bratislava.tWMSPackstueck'
,'bratislava.tWMSPackstueckposition'
,'bratislava.tWMSParcelState'
,'bratislava.tWMSPick'
,'bratislava.tWMSPickliste'
,'bratislava.tWMSRuestLE'
,'bratislava.tWMSRuestposition'
,'bratislava.tWMSSperrgrund'
,'bratislava.tWMSStornierungsgrund'
,'bratislava.tWMSTour'
,'bratislava.tWMSTransport'
,'bratislava.tWMSTransportposition'
,'bratislava.tWMSWareneingang'
,'bratislava.tWMSWareneingangsposition'
,'c4po.tDebugInfoAPI'
,'c4po.temp_bratislava_Jan2023'
,'c4po.temp_hoppegarten_Jan2023'
,'c4po.temp_kali_Jan2023'
,'c4po.temp_werne_Jan2023'
,'c4po.tInputAPI'
,'c4po.tInputAPIfinished'
,'c4po.tOutputAPI'
,'c4po.tOutputAPI_20220107'
,'c4po.tOutputAPI_20220114'
,'c4po.tOutputAPI_Live'
,'carriercost.tDachser'
,'carriercost.tDHLType1'
,'carriercost.tDHLType2'
,'carriercost.tDPD'
,'carriercost.tGLS'
,'carriercost.tSevenSenders'
,'carriercost.tSlovakParcelService'
,'carriercost.tUPS'
,'cognigy.tChatHistory'
,'cognigy.tConversations'
,'cognigy.tExecutedSteps'
,'cognigy.tInputs'
,'cognigy.tSteps'
,'dbo.__MK_UPSTransportCosts_20190627'
,'dbo.__PH_Chaltec_WaehrungenKurseHistorie'
,'dbo.__PH_OrdersDeliveryDates_20190424'
,'dbo._temp_MEKGaps'
,'dbo._temp_orderInv'
,'dbo._temp_tErpKHKLagerorte'
,'dbo.Admin_Wartung_Index_Protokoll'
,'dbo.ChalTec_CarrierTool'
,'dbo.FactSales_Staging'
,'dbo.FactSales_Staging_temp'
,'dbo.FactSales_Staging_temp2'
,'dbo.GeoLocationLog'
,'dbo.lips_test1'
,'dbo.sysdiagrams'
,'dbo.tAmzFbaFulfillmentInventoryHealthData'
,'dbo.tAmzFbaMyiUnsuppressedInventoryData'
,'dbo.tAmzFbaRestockInventoryRecommendationsReport'
,'dbo.tAmzFbaStrandedInventoryUiData'
,'dbo.tAmzInventory'
,'dbo.tAmzOrderItems'
,'dbo.tAmzOrders'
,'dbo.tAmzPageSalesAndTrafficByChildItem'
,'dbo.tAmzProduct'
,'dbo.tAmzProductPrice'
,'dbo.tAmzProductReviews'
,'dbo.tAmzProductSalesRank'
,'dbo.tAuxSurrogateKeyReference'
,'dbo.tAuxUnicodeSurrogateKeyReference'
,'dbo.tBIAmazonMarketplaces'
,'dbo.tBIAmazonPricesHistory'
,'dbo.tBIAmazonSellers'
,'dbo.tBIebayPricesHistory'
,'dbo.tBIShopPricesHistory'
,'dbo.tCtrShipmentPriceList'
,'dbo.tCTWebShopChalTec_OxidCon_Articles_Map'
,'dbo.tCTWebShopChalTec_OxidCon_OrderDetails'
,'dbo.tCTWebShopChalTec_OxidCon_Orders'
,'dbo.tCTWebShopChalTec_OxidCon_OrderVouchers'
,'dbo.tCTWebShopChalTec_OxidCon_ShopConfig'
,'dbo.tCTWebShopChalTec_OxidCon_ShopConfig_bck'
,'dbo.tCTWebShopChalTec_OxidCon_ShopConfigMall'
,'dbo.tCTWebShopChalTec_OxidCon_ShopConfigMultiMall'
,'dbo.tDCAmazon_ParentASIN_Job'
,'dbo.tDCChalTec_Amazon_PerformanceReports'
,'dbo.tDCChalTec_Amazon_PerformanceReports_OrderDefects'
,'dbo.tDCChalTec_USAItemMapping'
,'dbo.tDCCM_Amazon_Questions'
,'dbo.tDCCM_Amazon_Rezension'
,'dbo.tDCRenta_ArtikelBerechnet'
,'dbo.tDWHArtikelMOQs'
,'dbo.tDWHDIO_Korrekturfaktor_statisch'
,'dbo.tDWHDIO_Korrekturfaktor_statisch_20240614'
,'dbo.tDWHForecast'
,'dbo.tDWHForecastABCAnalyse'
,'dbo.tDWHForecastABCAnalyse_20240613'
,'dbo.tDWHForecastPreCollection'
,'dbo.tDWHForecastResult'
,'dbo.tDWHForecastResult_20240613'
,'dbo.tDWHForecastResultHistory'
,'dbo.tDwhHistorischerArtikelMEK_TEST'
,'dbo.tDWHLRW_Reloaded_blacklisted_Sales'
,'dbo.tDWHLRW_Reloaded_Result_Short'
,'dbo.tDWHLRW_Reloaded_RunRate_Article_Sales_this_year_vs_last_year'
,'dbo.tDWHLRW_Reloaded_RunRate_Category_Level1_Sales_this_year_vs_last_year'
,'dbo.tDWHLRW_Reloaded_RunRate_Category_Level3_Sales_this_year_vs_last_year'
,'dbo.tDwhSalesProcess'
,'dbo.tDWHSalesTarget'
,'dbo.teBayBaygraph_TEMP'
,'dbo.teBayTrafficReportDay'
,'dbo.teBayTrafficReportItem'
,'dbo.temp_tErpLBAmazonFBAManagedInventory'
,'dbo.tempMapAdressenCity'
,'dbo.tErp_KHKArtikelLieferant'
,'dbo.tErpAdditionalCharge'
,'dbo.tErpChalTec_Kundennummer_Mapping'
,'dbo.tErpChaltec_Multishops'
,'dbo.tErpChaltec_Preislisten_Land_Mapping'
,'dbo.tErpChalTec_ProcessIncidents'
,'dbo.tErpChaltec_Repricing_History'
,'dbo.tErpChaltec_Repricing_Reason'
,'dbo.tERPChalTec_StockService_Data'
,'dbo.tERPChalTec_StockServiceWarehouseSAGESAPMap'
,'dbo.tErpChaltec_WaehrungenKurseHistorie'
,'dbo.tErpChaltecCountryCodes'
,'dbo.tErpChannel'
,'dbo.tErpCustomer'
,'dbo.tErpKHKArtikel'
,'dbo.tErpKHKArtikel_bkp_1848_18062024'
,'dbo.tErpKHKArtikelbewertungMEKHistorie'
,'dbo.tErpKHKArtikelBezeichnung'
,'dbo.tErpKHKArtikelgruppen'
,'dbo.tErpKHKArtikelgruppen_Backup'
,'dbo.tErpKHKArtikelgruppen_bkp_1848_18062024'
,'dbo.tErpKHKArtikelKunden'
,'dbo.tErpKHKArtikelLagerbewegungen'
,'dbo.tErpKHKArtikelLieferant'
,'dbo.tErpKHKArtikelStueckliste'
,'dbo.tErpKHKArtikelVarianten'
,'dbo.tErpKHKArtikelZubehoer'
,'dbo.tErpKHKAuswertungskreiseJournale'
,'dbo.tErpKHKBuchungserfassung'
,'dbo.tErpKHKBuchungserfassungAkz'
,'dbo.tErpKHKDispoArtikel'
,'dbo.tErpKHKDispoArtikel_bkp_1848_18062024'
,'dbo.tErpKHKEKBelegarten'
,'dbo.tErpKHKEKBelege'
,'dbo.tErpKHKEKBelegePositionen'
,'dbo.tErpKHKEKBelegePositionenLager'
,'dbo.tErpKHKEKBelegeVorgaenge'
,'dbo.tErpKHKEKBelegeZKD'
,'dbo.tErpKHKEKVorgaenge'
,'dbo.tErpKHKEKVorgaengePositionen'
,'dbo.tErpKHKGruppen'
,'dbo.tErpKHKInkassoarten'
,'dbo.tErpKHKLagerorte'
,'dbo.tErpKHKLagerplaetze'
,'dbo.tErpKHKLagerplatzbestaende'
,'dbo.tERPKHKLagerplatzbestaende_bkp_1848_18062024'
,'dbo.tErpKHKLagerplatzbuchungen'
,'dbo.tErpKHKMandanten'
,'dbo.tErpKHKOpNebensatz'
,'dbo.tErpKHKPreislisten'
,'dbo.tErpKHKPreislistenArtikel'
,'dbo.tErpKHKSachkonten'
,'dbo.tErpKHKStatEK'
,'dbo.tErpKHKStatEKArtikel'
,'dbo.tErpKHKSteuertabelle'
,'dbo.tErpKHKVertreter'
,'dbo.tERPKHKVertreter_bkp_1848_18062024'
,'dbo.tErpKHKVKBelegarten'
,'dbo.tErpKHKVKBelegePositionen_bckup_20220125'
,'dbo.tErpKHKVKBelegePositionen_DELETE'
,'dbo.tErpKHKVKBelegeStuecklisten'
,'dbo.tErpKHKVKVorgaenge'
,'dbo.tErpKHKWaehrungenKurse'
,'dbo.tERPKHKWaehrungenKurse_bkp_1848_18062024'
,'dbo.tErpKHKZahlungskonditionen'
,'dbo.tErpKHKZessionare'
,'dbo.tErpKHKZuschlagsarten'
,'dbo.tErpLBAmazonAllOrders'
,'dbo.tErpLBAmazonAllOrdersItems'
,'dbo.tErpLBAmazonFBACustomerReturns'
,'dbo.tErpLBAmazonFBAManagedInventory'
,'dbo.tERPLBAmazonFBAShipments'
,'dbo.tErpLBAmazonFBAShipmentsItems'
,'dbo.tErpLBAmazonItems'
,'dbo.tErpLBAmazonListings'
,'dbo.tErpLBAmazonOrders'
,'dbo.tErpLBAmazonOrdersItems'
,'dbo.tErpLBAmazonPayments'
,'dbo.tErpLBAmazonSellers'
,'dbo.tErpLBAmazonSellersBACKUP'
,'dbo.tERPLBCustomImportBelege'
,'dbo.tErpLBebayAuctions'
,'dbo.tErpLBebayItems'
,'dbo.tErpLBebayItemsVariations'
,'dbo.tErpLBebaySales'
,'dbo.tErpLBebaySellers'
,'dbo.tErpLBebaySites'
,'dbo.tErpLBFulfillmentHermesArtikelVarianten'
,'dbo.tErpLBShop'
,'dbo.tErpLBShopCustomers'
,'dbo.tErpLBShopItems'
,'dbo.tErpLBShopItemsDescriptions'
,'dbo.tErpLBShopSales'
,'dbo.tErpLBSysPayPalAPITransactions'
,'dbo.tErpLBSysStock'
,'dbo.tErpPriceRankList'
,'dbo.tFSETAShipmentSchedule'
,'dbo.tFSETAShipmentScheduleHK'
,'dbo.tGAAdwordsCampaignStats'
,'dbo.tGABrowser'
,'dbo.tGACampaign'
,'dbo.tGAChannelBasicStats'
,'dbo.tGAChannelConversions'
,'dbo.tGADeviceBranding'
,'dbo.tGADeviceCategory'
,'dbo.tGADeviceCategoryReport'
,'dbo.tGADeviceInputSelector'
,'dbo.tGADeviceMarketingName'
,'dbo.tGADeviceModel'
,'dbo.tGAMarketingChannelMetadata'
,'dbo.tGAMarketingCosts'
,'dbo.tGAMarketingCosts_BACKUP_20170206'
,'dbo.tGAMedium'
,'dbo.tGAMobileDevice01'
,'dbo.tGAMobileDevice01TR'
,'dbo.tGAMobileDeviceTR'
,'dbo.tGAOSystem'
,'dbo.tGAPlatform'
,'dbo.tGAPlatformTR'
,'dbo.tGASource'
,'dbo.tGATrafficSources'
,'dbo.tGATrafficSourcesTR'
,'dbo.tGAWAdGroup'
,'dbo.tGAWCampaign'
,'dbo.tGAWCustomer'
,'dbo.tGAWCustomer_BACKUP'
,'dbo.tGAWCustomerHierarchy'
,'dbo.tGAWebShopMetadata'
,'dbo.tGAWRAccountPerformanceReport'
,'dbo.tGAWRCampaignPerformanceReport'
,'dbo.tGeoAddressesResolved'
,'dbo.tGeoCity'
,'dbo.tGeoCountry'
,'dbo.tGeoProxyServer'
,'dbo.tGeoRegion'
,'dbo.tJTelAcdAgentStatus'
,'dbo.tJTelAcdCallMarkers'
,'dbo.tJTelAcdGroups'
,'dbo.tJTelAcdStatisticsLogin'
,'dbo.tJTelAcdStatisticsPartB'
,'dbo.tJTelAcdStatisticsTransactionCodes'
,'dbo.tJTelLanguages'
,'dbo.tJTelOpeningTimes'
,'dbo.tJTelOpeningTimesEntries'
,'dbo.tJTelServiceNumbers'
,'dbo.tJTelStatisticsPartA'
,'dbo.tJTelStatisticsPartB'
,'dbo.tJTelStatisticsPartIVR'
,'dbo.tJTelStatisticsPartO'
,'dbo.tJTelStatisticsPartZ'
,'dbo.tJTelUsers'
,'dbo.tLogChalTec_OrdersDeliveryDates'
,'dbo.tLogisticsChalTecWMS_ProductNoMapping'
,'dbo.tLogParcellab_Courier_Codes'
,'dbo.tLogParcellab_Tracking_Status'
,'dbo.tLogParcellab_Tracking_Status_20240614'
,'dbo.tLogTransportCosts_DHL_Lieferadressen'
,'dbo.tLogTransportCosts_DHL_Sendungen'
,'dbo.tLogTransportCosts_DHL_Sperrgut'
,'dbo.tLogTransportCosts_UPS'
,'dbo.tMappingCustomerNumberChannel'
,'dbo.tMappingGAChannelMetadata'
,'dbo.tMappingJtelUsersVertreter'
,'dbo.tMappingMarketingCampaignsCustomerGroups'
,'dbo.tMappingWebshopCountry'
,'dbo.tMappingWebshopCustomerGroup'
,'dbo.tMktAffilinetCreatives'
,'dbo.tMktAffilinetOrders'
,'dbo.tMktAffilinetPrograms'
,'dbo.tMktAffilinetPublishers'
,'dbo.tMktAffilinetRates'
,'dbo.tMktAffilinetStatistics'
,'dbo.tMktAffilinetTransactionStates'
,'dbo.tMktAffilinetValuationTypes'
,'dbo.tMktCityList'
,'dbo.tMktCrmEmailCampaignLaunches'
,'dbo.tMktCrmEmailCampaignResponses'
,'dbo.tMktCrmEmailCampaigns'
,'dbo.tMktCrmEmailCampaigns_BACKUP_20190125'
,'dbo.tMktCrmEmailCampaignStates'
,'dbo.tMktCrmEmailCategories'
,'dbo.tMktFeedDynamixCampaignMetadata'
,'dbo.tMktFeedDynamixPartner'
,'dbo.tMktGoogleDocsCostBing'
,'dbo.tMktGoogleDocsCostFacebook'
,'dbo.tMktGoogleDocsCostMappingTable'
,'dbo.tMktGoogleDocsCostNewsletter'
,'dbo.tMktReportMarketingDailyRevenueReportDetailedIntermediate'
,'dbo.tMktWeather'
,'dbo.tmpekbz3'
,'dbo.tmpEntriesToLoadDeliveryDates'
,'dbo.tmpEntriesToLoadDhl'
,'dbo.tRepKeepaProducts'
,'dbo.tRetRet_HG_Retouren'
,'dbo.tRetret_HWS_retouren'
,'dbo.tRetret_KaLi_retouren'
,'dbo.tRetret_KaLi_retouren_20240619'
,'dbo.tRetret_retouren'
,'dbo.tSAP0ACCOUNT_TEXT'
,'dbo.tSAP0BILL_TYPE_TEXT'
,'dbo.tSAP0COMPANY_CODE_TEXT'
,'dbo.tSAP0CUST_SALES_ATTR'
,'dbo.tSAP0CUSTOMER_ATTR'
,'dbo.tSAP0DEL_TYPE_TEXT'
,'dbo.tSAP0DISTR_CHAN_TEXT'
,'dbo.tSAP0DOC_TYPE_TEXT'
,'dbo.tSAP0FI_ACDOCA_10'
,'dbo.tSAP0INFO_REC_ATTR'
,'dbo.tSAP0KSCHL_TEXT'
,'dbo.tSAP0MAT_PLANT_ATTR'
,'dbo.tSAP0MAT_PLANT_ATTR_20221121'
,'dbo.tSAP0MATERIAL_ATTR'
,'dbo.tSAP0MATERIAL_TEXT'
,'dbo.tSAP0MATL_GROUP_TEXT'
,'dbo.tSAP0ORD_REASON_TEXT'
,'dbo.tSAP0PROD_HIER_TEXT'
,'dbo.tSAP0PROFIT_CTR_TEXT'
,'dbo.tSAP0PUR_GROUP_TEXT'
,'dbo.tSAP0REASON_REJ_TEXT'
,'dbo.tSAP0SALESORG_TEXT'
,'dbo.tSAP0STOR_LOC_TEXT'
,'dbo.tSAP0VEN_COMPC_ATTR'
,'dbo.tSAP0VEN_PURORG_ATTR'
,'dbo.tSAP0VENDOR_TEXT'
,'dbo.tSAP2LIS_02_CGR'
,'dbo.tSAP2LIS_02_HDR'
,'dbo.tSAP2LIS_02_ITM'
,'dbo.tSAP2LIS_02_ITM_20240516'
,'dbo.tSAP2LIS_02_SCL'
,'dbo.tSAP2LIS_02_SCN'
,'dbo.tSAP2LIS_03_BF'
,'dbo.tSAP2LIS_03_BF_BCK20230117'
,'dbo.tSAP2LIS_04_P_MATNR'
,'dbo.tSAP2LIS_06_INV'
,'dbo.tSAP2LIS_11_VAHDR'
,'dbo.tSAP2LIS_11_VAITM'
,'dbo.tSAP2LIS_11_VAITM_live'
,'dbo.tSAP2LIS_11_VAKON_bck3005'
,'dbo.tSAP2LIS_11_VAKON_bk20230612'
,'dbo.tSAP2LIS_11_VAKON_bk20230612_v2'
,'dbo.tSAP2LIS_11_VAKON_LIVE_until310523'
,'dbo.tSAP2LIS_11_VASTH'
,'dbo.tSAP2LIS_11_VASTI'
,'dbo.tSAP2LIS_12_VCHDR'
,'dbo.tSAP2LIS_12_VCHDR_v2'
,'dbo.tSAP2LIS_12_VCITM'
,'dbo.tSAP2LIS_12_VCITM_Live'
,'dbo.tSAP2LIS_12_VCITM_v2'
,'dbo.tSAP2LIS_13_VDHDR'
,'dbo.tSAP2LIS_13_VDITM'
,'dbo.tSAP2LIS_13_VDITM_old'
,'dbo.tSAPEINA'
,'dbo.tSAPEINE'
,'dbo.tSAPEKBE'
,'dbo.tSAPEKES'
,'dbo.tSAPEKET'
,'dbo.tSAPEKKO'
,'dbo.tSAPEKKO_messages'
,'dbo.tSAPEKPO'
,'dbo.tSAPLFA1'
,'dbo.tSAPLFB1'
,'dbo.tSAPLIKP'
,'dbo.tSAPLIPS'
,'dbo.tSAPLIS_02_HDR'
,'dbo.tSAPMARA'
,'dbo.tSAPMARC'
,'dbo.tSAPMATERIAL_ATTR'
,'dbo.tSAPMBEW'
,'dbo.tSAPMBEW_bck_20240403'
,'dbo.tSAPMBEW_HB'
,'dbo.tSAPMVKE'
,'dbo.tSAPT024'
,'dbo.tSAPT179_Hierarchie'
,'dbo.tSAPT179T'
,'dbo.tSAPZ_BOM_DATA'
,'dbo.tSAPZ_FI_BSEG_BKPF'
,'dbo.tSAPZ_FI_BSEG_BKPF_v2'
,'dbo.tSAPZ_FI_GL_LINEITEMS'
,'dbo.tSAPZ_FI_ZFI_AMAZON'
,'dbo.tSAPZ_MM_A017_KONP'
,'dbo.tSAPZ_MM_CDHDR_CDPOS'
,'dbo.tSAPZ_MM_CDHDR_CDPOS_BOM'
,'dbo.tSAPZ_MM_CDHDR_CDPOS_L'
,'dbo.tSAPZ_MM_CDHDR_CDPOS_V'
,'dbo.tSAPZ_MM_EINA_EINE'
,'dbo.tSAPZ_MM_EKBE'
,'dbo.tSAPZ_MM_EKBZ'
,'dbo.tSAPZ_MM_EKPA'
,'dbo.tSAPZ_MM_LIKP_LIPS'
,'dbo.tSAPZ_MM_LIKP_LIPS_bck'


)

Group by TableName
having SUM([Rows]) >= 10000000


--drop table dbo.tMktFeedDynamixProductConversions
--drop table dbo.tLogParcellab_Tracking_Jobs_20240614
--drop table dbo.teBayBaygraph
--drop table dbo.tGAWRShoppingPerformanceReport
--drop table dbo.tErpKHKBuchungsjournal
--drop table dbo.tLogTransportCosts_DPD

--drop table dbo.tGAWRAdGroupPerformanceReport

--select top 10 * from dbo.tLogParcellab_Checkpoints order by cd desc


--select count(*) from [CT dwh 02 Data].dbo.tSAP0FI_ACDOCA_10
GO
/****** Object:  View [dbo].[vAmzMerchant]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vAmzMerchant]
AS
select 100001 as MerchantId, N'Estar' as MerchantName, N'ABV9J41D2VYA9' as MerchantCode 
UNION
select 100002 as MerchantId, N'Klarstein' as MerchantName, N'A3DC01MIVCFBA7' as MerchantCode 
UNION
select 100003 as MerchantId, N'Berlin Brands Group' as MerchantName, N'A30XOMV9QY5XX9' as MerchantCode 


GO
/****** Object:  View [dbo].[vAuxExtractByMaxTimeStamp]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vAuxExtractByMaxTimeStamp]

AS
SELECT 1000 AS TableId, 'KHKArtikel' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKArtikel
UNION
SELECT 1001 AS TableId, 'KHKAdressen' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKAdressen
UNION
SELECT 1002 AS TableId, 'KHKVKBelege' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKVKBelege
UNION
SELECT 1003 AS TableId, 'KHKGruppen' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKGruppen
UNION
SELECT 1004 AS TableId, 'KHKVKBelegeStuecklisten' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKVKBelegeStuecklisten
UNION
SELECT 1005 AS TableId, 'LBSysStock' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBSysStock
UNION
SELECT 1013 AS TableId, 'KHKVKBelegeZuschlaege' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKVKBelegeZuschlaege
UNION
SELECT 1014 AS TableId, 'KHKVKBelegeZKD' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKVKBelegeZKD
UNION
SELECT 1015 AS TableId, 'KHKVKBelegePositionen' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKVKBelegePositionen
UNION
SELECT 1028 AS TableId, 'KHKKontokorrent' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKKontokorrent
UNION
SELECT 1027 AS TableId, 'KHKSachkonten' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKSachkonten
UNION
SELECT 1020 AS TableId, 'KHKBuchungsjournal' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKBuchungsjournal
UNION
SELECT 1024 AS TableId, 'KHKLagerplatzbestaende' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKLagerplatzbestaende
UNION
SELECT 1025 AS TableId, 'KHKOpHauptsatz' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKOpHauptsatz
UNION
SELECT 1032 AS TableId, 'KHKVKBelegarten' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKVKBelegarten
UNION
SELECT 2003 AS TableId, 'KHKArtikelgruppen' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKArtikelgruppen
UNION
SELECT 2012 AS TableId, 'KHKLagerplaetze' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKLagerplaetze
UNION
SELECT 2021 AS TableId, 'KHKVKVorgaenge' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKVKVorgaenge
UNION
SELECT 2023 AS TableId, 'KHKVKVorgaengePositionen' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKVKVorgaengePositionen
UNION
SELECT 2044 AS TableId, 'KHKMandanten' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKMandanten
UNION
SELECT 2048 AS TableId, 'KHKZuschlagsarten' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKZuschlagsarten
UNION
SELECT 2050 AS TableId, 'LBShop' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBShop
UNION
SELECT 2051 AS TableId, 'LBShopSales' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBShopSales
UNION
SELECT 2047 AS TableId, 'KHKVKBelegeVorgaenge' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKVKBelegeVorgaenge
UNION
SELECT 1031 AS TableId, 'KHKSteuertabelle' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKSteuertabelle
UNION
SELECT 1011 AS TableId, 'KHKEKBelege' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKEKBelege
UNION
SELECT 1007 AS TableId, 'KHKEKBelegePositionen' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKEKBelegePositionen
UNION
SELECT 1033 AS TableId, 'KHKEKVorgaenge' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKEKVorgaenge
UNION
SELECT 1034 AS TableId, 'KHKEKVorgaengePositionen' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKEKVorgaengePositionen
UNION
SELECT 2055 AS TableId, 'LBAmazonItems' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBAmazonItems
UNION
SELECT 2056 AS TableId, 'Chaltec_WaehrungenKurseHistorie' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpChaltec_WaehrungenKurseHistorie
UNION
SELECT 2057 AS TableId, 'LBAmazonListings' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBAmazonListings
UNION
SELECT 2042 AS TableId, 'KHKEKBelegarten' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKEKBelegarten
UNION
SELECT 2020 AS TableId, 'LBVLogVersanddaten' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBVLogVersanddaten
UNION
SELECT 2059 AS TableId, 'LBEbaySellers' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBEbaySellers
UNION
SELECT 2060 AS TableId, 'LBEbaySites' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBEbaySites
UNION
SELECT 2061 AS TableId, 'KHKPreislisten' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKPreislisten
UNION
SELECT 2062 AS TableId, 'LBEBayAuctions' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBEBayAuctions
UNION
SELECT 2063 AS TableId, 'LBEBayItems' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBEBayItems
UNION
SELECT 2014 AS TableId, 'LBAmazonOrders' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBAmazonOrders
UNION
SELECT 2015 AS TableId, 'LBAmazonOrdersItems' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBAmazonOrdersItems
UNION
SELECT 1009 AS TableId, 'LBEbaySales' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBEbaySales
UNION
SELECT 2013 AS TableId, 'LBAmazonSellers' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpLBAmazonSellers
UNION
SELECT 2008 AS TableId, 'KHKArtikelVarianten' AS Tablename, ISNULL(MAX([Timestamp]), 0) AS MaxTimestamp FROM dbo.tErpKHKArtikelVarianten
GO
/****** Object:  View [dbo].[vCheckTableChanges]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vCheckTableChanges] as 
Select QM_fields.TableName,QM_fields.ColumnName,QM_fields.DataType QM_DataType, live_fields.DataType Live_DataType, 
QM_fields.precision QM_Lengh,live_fields.precision Live_Lengh,QM_fields.scale QM_MaxLength,live_fields.scale Live_MaxLength
  FROM 
   (
   SELECT t.name TableName, col.name ColumnName,tt.name DataType, col.max_length,col.precision,col.scale
		from sys.tables t
		inner join sys.all_columns col
			on col.object_id = t.object_id
		inner join sys.types tt
			on tt.user_type_id = col.user_type_id
   ) QM_fields
   Left join  
   (
   SELECT t.name TableName, col.name ColumnName,tt.name DataType, col.max_length,col.precision,col.scale
		from [BISERVER].[CT dwh 02 Data].sys.tables t
		inner join [BISERVER].[CT dwh 02 Data].sys.all_columns col
			on col.object_id = t.object_id
		inner join [BISERVER].[CT dwh 02 Data].sys.types tt
			on tt.user_type_id = col.user_type_id
   ) live_fields
   			on QM_fields.TableName = live_fields.TableName
			and QM_fields.ColumnName= live_fields.ColumnName
				
		where 
		 live_fields.TableName is null 
		 or
		 live_fields.DataType <> QM_fields.DataType
		 or
		 live_fields.max_length <> QM_fields.max_length
		  or
		 live_fields.precision <> QM_fields.precision
GO
/****** Object:  View [dbo].[vErpArtikelgruppen]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vErpArtikelgruppen]

AS

WITH ItemCategory as (
SELECT ItemCategoryId,Artikelgruppe,Bezeichnung  FROM [dbo].[tErpKHKArtikelgruppen] ItemCategory
   where ItemCategory.Mandant = 1
  and ItemCategory.[Bezeichnung] <> 'Haushalt ALT'
  and (LEN(ItemCategory.Artikelgruppe) = 9
  or ItemCategory.Artikelgruppe = 'EMPTY')
)



SELECT	Artikelgruppen.[ItemCategoryId] ItemCategoryId
		, ParentItemCategory.ItemCategoryId ParentItemCategoryId
		, Artikelgruppen.[Artikelgruppe] ItemCategoryCode
		, Artikelgruppen.[VaterArtikelgruppe] ParentItemCategoryCode
	    , MainItemCategory.ItemCategoryId  MainItemCategoryId 
	    , MainItemCategory.Artikelgruppe MainItemCategoryCode
	    , MainItemCategory.Bezeichnung MainItemCategory
        , Artikelgruppen.[Bezeichnung] ItemCategory
        , Artikelgruppen.[mdRecordToLoadFlag]
  FROM [dbo].[tErpKHKArtikelgruppen] Artikelgruppen
  LEFT OUTER JOIN ItemCategory ParentItemCategory
  ON ParentItemCategory.Artikelgruppe = Artikelgruppen.[VaterArtikelgruppe]
  LEFT OUTER JOIN ItemCategory MainItemCategory
  ON MainItemCategory.Artikelgruppe = Artikelgruppen.[Hauptartikelgruppe]
  where Artikelgruppen.Mandant = 1
  and Artikelgruppen.[Bezeichnung] <> 'Haushalt ALT'
  and (LEN(Artikelgruppen.Artikelgruppe) = 9
  or Artikelgruppen.Artikelgruppe = 'EMPTY')
GO
/****** Object:  View [dbo].[vErpChaltecCountryCodes]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vErpChaltecCountryCodes]
AS
SELECT [CountryId]
      ,[CountryCode]
	  , [CountryName]
      ,[mdLogId]
      ,[mdInsertDate]
	  ,[mdRecordToLoadFlag]
  FROM [CT dwh 02 Data].[dbo].[tErpChaltecCountryCodes]
GO
/****** Object:  View [dbo].[vErpCity]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vErpCity]
AS
select 
c.CityId, 
c.ISOCityId, 
c.[CityName], 
c.Lat as Latitude, 
c.Lon as Longitude, 
isnull(cnt.CountryId, 1) as CountryId, 
c.[mdLogId], 
c.[mdInsertDate], 
c.[mdRecordToLoadFlag]
from [CT dwh 02 Data].[dbo].tMktCityList c 
left join [CT dwh 02 Data].[dbo].[tErpChaltecCountryCodes] cnt on cnt.CountryCode = c.CityCountry


GO
/****** Object:  View [dbo].[vErpCustomerGroup]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vErpCustomerGroup]

AS

WITH  MainChannel as (
			SELECT 10 MainChannelId,'Amazon' MainChannelname UNION
			SELECT 20,'eBay' UNION
			SELECT 30,'Weiterberechnung' UNION
			SELECT 40,'SK' UNION
			SELECT 50,'Shop' UNION
			SELECT 60,'Mandanten' UNION
			SELECT 99,'Diverse/B2B'
					),
Channel as (
			SELECT 10 ChannelId,'Amazon' Channelname UNION
			SELECT 15 ,'Cdiscount'  UNION
			SELECT 20 ,'eBay' UNION
			SELECT 25 ,'FNAC'  UNION
			SELECT 30 ,'Groupon'  UNION
			SELECT 35 ,'Laden'  UNION
			SELECT 40 ,'Mandanten' UNION
			SELECT 45 ,'MeinPaket' UNION
			SELECT 50 ,'SK' UNION
			SELECT 55 ,'Shop' UNION
			SELECT 60 ,'Telefonverkauf' UNION
			SELECT 65 ,'Weiterberechnung' UNION
			SELECT 99 ,'Diverse/B2B'
			)
			
						 

SELECT GroupId CustomerGroupId
      , [Mandant] CompanyId
	  ,[Gruppe] CustomerGroupcode
      ,[Bezeichnung] CustomerGroupname
      --,[Tag] 
	  --, case 
   --             when Tag IN
			--	('Amazon','Cdiscount','eBay','FNAC','Groupon','Laden','Mandanten','MeinPaket','SK','Shop','Telefonverkauf','Weiterberechnung') then Tag  
			--		ELSE 'Diverse/B2B' 
   --     END Channel,
   --     case 
                                               
   --             when Tag IN ('Amazon','eBay','Weiterberechnung','SK', 'Shop', 'Mandanten') then Tag  
   --             ELSE 'Diverse/B2B' 
   --     END MainChannel   
       , isnull(MainChannel.MainChannelId,99) MainChannelId
	   , isnull(MainChannel.MainChannelname,'Diverse/B2B') MainChannelname
	   , isnull(Channel.ChannelId,99) ChannelId
	   , isnull(Channel.Channelname,'Diverse/B2B') Channelname
  --INTO [CT dwh 03 Intelligence].dbo.tDimChannel
  FROM [CT dwh 02 Data].[dbo].[tErpKHKGruppen] t
  LEFT OUTER JOIN MainChannel
  ON MainChannel.MainChannelname = ltrim(rtrim(t.Tag))
  LEFT OUTER JOIN Channel
  ON Channel.Channelname = ltrim(rtrim(t.Tag))
  where Typ = 11
  
GO
/****** Object:  View [dbo].[vErpEBayPrices]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vErpEBayPrices]
AS

 SELECT 
  i.ItemId, i.Mandant 
	  --li.Artikelnummer 	, li.Mandant
	, lsi.ebaySiteID
	 , CONVERT(numeric(18,2), 
	 MIN(li.StartPrice)) AS Einzelpreis
	, CAST(GETDATE() as date) currentdate
FROM [tErpLBebayItems] AS li 
INNER JOIN tErpKHKArtikel i ON li.Artikelnummer = i.Artikelnummer and li.Mandant = i.Mandant
				INNER JOIN [tErpLBebayAuctions] AS la 
					ON la.[Mandant] = li.[Mandant]
					AND la.[Artikelnummer] = li.[Artikelnummer]
					AND la.[AuspraegungId] = li.[AuspraegungId]
					AND la.[ItemsItemID] = li.[ItemId]
			     INNER JOIN [tErpLBebaySellers] AS ls WITH(NOLOCK)
					ON ls.[Mandant] = la.[Mandant]
					AND ls.[SellerID] = la.[SellerID]
					AND ls.[SiteID] = la.[SiteID]
				INNER JOIN [tErpLBebaySites] AS lsi 
					ON lsi.[SiteID] = ls.[SiteID]
					AND lsi.[Aktiv] = ls.[Aktiv]
WHERE 
	la.[EndTime] > GETDATE()
	AND li.StartPrice IS NOT NULL
	AND li.[Duration] = - 1
	AND li.Aktiv = -1
    AND li.Artikelnummer LIKE '1%'
	AND li.Mandant = 1
GROUP BY 
      i.ItemId, i.Mandant 	, lsi.ebaySiteID
union 
SELECT 
  i.ItemId, i.Mandant 
	  --li.Artikelnummer 	, li.Mandant
	, lsi.ebaySiteID
	 , CONVERT(numeric(18,2), 
	 MIN(li.StartPrice)) AS Einzelpreis
	, CAST(GETDATE() as date) currentdate
FROM [tErpLBebayItems] AS li 
INNER JOIN tErpKHKArtikel i ON li.Artikelnummer = i.Artikelnummer and li.Mandant = i.Mandant
				INNER JOIN [tErpLBebayAuctions] AS la 
					ON la.[Mandant] = li.[Mandant]
					AND la.[Artikelnummer] = li.[Artikelnummer]
					AND la.[AuspraegungId] = li.[AuspraegungId]
					AND la.[ItemsItemID] = li.[ItemId]
			     INNER JOIN [tErpLBebaySellers] AS ls WITH(NOLOCK)
					ON ls.[Mandant] = la.[Mandant]
					AND ls.[SellerID] = la.[SellerID]
					AND ls.[SiteID] = la.[SiteID]
				INNER JOIN [tErpLBebaySites] AS lsi 
					ON lsi.[SiteID] = ls.[SiteID]
					AND lsi.[Aktiv] = ls.[Aktiv]
WHERE 
	la.[EndTime] > GETDATE()
	AND li.StartPrice IS NOT NULL
	AND li.[Duration] = - 1
	AND li.Aktiv = -1
    AND li.Artikelnummer LIKE '1%'
	AND li.Mandant = 3
GROUP BY 
      i.ItemId, i.Mandant 	, lsi.ebaySiteID






GO
/****** Object:  View [dbo].[vErpKHKArtikel]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vErpKHKArtikel]

AS


WITH ItemBrandclass as ( SELECT
                         GroupId ItemBrandclassId
					     ,[Gruppe] ItemBrandclassCode
						,cast([Bezeichnung] as varchar(50)) ItemBrandclass
						,CASE
						   WHEN [Bezeichnung] IN('X', 'Z') THEN 'ja'
						   WHEN [Bezeichnung] IN('A', 'B') THEN 'nein'
						   ELSE 'nicht klassifiziert'
						 END AS OwnBrand 
  FROM [CT dwh 02 Data].[dbo].[tErpKHKGruppen]
  where Typ = 1000000600
  and Mandant = 1

 ),
 ItemSalesBrand as ( SELECT 
                     Mandant CompanyId
					, GroupId ItemSalesBrandId 
                    , [Gruppe] ItemSalesBrandCode 
                    , cast([Bezeichnung] as varchar(50)) ItemSalesBrand 
         FROM [CT dwh 02 Data].[dbo].[tErpKHKGruppen]
        where Typ = 1000000601  
		--and Mandant = 1
)
,
 ItemGroup as ( SELECT 
                        Mandant CompanyId
						, GroupId ItemGroupId
					    , [Gruppe] ItemGroupcode
						,[Bezeichnung] ItemGroup 
  FROM [CT dwh 02 Data].[dbo].[tErpKHKGruppen]
  where Typ = 1000000603
 -- and Mandant = 1
  UNION
  SELECT 1, 10000000,9,'Unknown'
  UNION
  SELECT 2, 10000000,9,'Unknown'
  UNION
  SELECT 3, 10000000,9,'Unknown'
  UNION
  SELECT 4, 10000000,9,'Unknown'
), 
CategoryManager as ( SELECT 
                     Mandant CompanyId
                    , GroupId CategoryManagerId 
                    , [Gruppe] CategoryManagerCode 
                    , cast([Bezeichnung] as varchar(50)) CategoryManager
         FROM [CT dwh 02 Data].[dbo].[tErpKHKGruppen]
        where Typ = 1000000701  
		--and Mandant = 1
		), 
Purchaser as ( SELECT 
                    Mandant CompanyId
                    , GroupId PurchaserId 
                    , [Gruppe] PurchaserCode 
                    , cast([Bezeichnung] as varchar(50)) Purchaser
         FROM [CT dwh 02 Data].[dbo].[tErpKHKGruppen]
        where Typ = 1000000700  
		--and Mandant = 1
		), 
Sourcer as ( SELECT 
                    Mandant CompanyId
                    , GroupId SourcerId 
                    , [Gruppe] SourcerCode 
                    , cast([Bezeichnung] as varchar(50)) Sourcer
         FROM [CT dwh 02 Data].[dbo].[tErpKHKGruppen]
        where Typ = 1000000702  
		--and Mandant = 1
		)
---Caption join in vDimItem in Analysis Layer
--ItemType as (
--SELECT 1 ItemTypeLevelId1,'Standard' ItemTypeLevel1,1 ItemTypeLevel2Id,'Standard SKU' ItemTypeLevel2 UNION
--SELECT 1,'Standard',2,'Accessory SKU' UNION
--SELECT 3,'Standard',2,'Standard SKU incl. fixed UK plug' UNION
--SELECT 5,'Second-Hand',51,'Second-Hand SKU (B)' UNION
--SELECT 5,'Second-Hand',52,'Second-Hand SKU (B) with packaging damage' UNION
--SELECT 5,'Second-Hand',53,'Second-Hand SKU (B) with usage traces' UNION
--SELECT 5,'Second-Hand',55,'Second-Hand SKU (B) with non-specified issues' UNION
--SELECT 5,'Second-Hand',56,'Second-Hand SKU (B) marked as junk' UNION
--SELECT 6,'Set',6, 'Set SKU' UNION
--SELECT 6,'Set',65,'Dummy SKU' UNION
--SELECT 7,'Kitting',7,'Kitting SKU' UNION
--SELECT 9,'Discounts',9,'Vouchers, Coupons, Discounts'
--)

SELECT 
       [Mandant] CompanyId
	  ,[ItemId]
      ,[Artikelnummer] ItemNo
      ,[Bezeichnung1] ItemDescription1
      ,[Bezeichnung2] ItemDescription2
      ,[Artikelgruppe] ItemCategoryCode
      ,[Hersteller] Manufacturer
      ,isnull(CategoryManager.CategoryManager, 'Unknown') [Category Manager]
	  ,isnull(Purchaser.Purchaser, 'Unknown') [Purchaser]
	  ,isnull(Sourcer.Sourcer, 'Unknown') [Sourcer]
	  ,isnull(ItemGroup.ItemGroupId,10000000) ItemGroupId
	  ,isnull(ItemGroup.ItemGroup, 'Unknown') ItemGroup 
	  ,isnull(ItemBrandclass.ItemBrandclassId,0) ItemBrandclassId
	  ,ItemBrandclass.ItemBrandclass ItemBrandclass
	  ,isnull(ItemSalesBrand.ItemSalesBrandId,'') ItemSalesBrandId
      ,isnull(ItemSalesBrand.ItemSalesBrand,'Unknown') ItemSalesBrand
      
      ,ItemBrandclass.OwnBrand
	  ,CASE
         WHEN ItemSalesBrand.ItemSalesBrand IN(
           'Auna',
           'Austin',
           'Capital Sports',
           'DURAMAXX',
           'Electronic-Star',
           'FrontStage',
           'KLARFIT',
           'Klarstein',
           'Lightcraft',
           'Malone',
           'oneConcept',
           'Resident DJ',
           'SCHUBERT',
           'Takira',
           'Blumfeldt',
           'Numan',
           'Yukatana',
           'Langley'
         ) THEN 'ja'  
         WHEN LEFT(dim.[Artikelnummer], 1) = '9' THEN 'nicht klassifiziert'
         ELSE 'nein'
       END AS [OwnBrandAdjusted]
      
	  ,CASE 
			WHEN isnumeric(substring([Artikelnummer],1,1)) = 1  THEN 
				CASE 
					WHEN cast(substring([Artikelnummer],1,1) as int) IN (1,3,5,6,7,9) THEN cast(substring([Artikelnummer],1,1) as int)
					ELSE 99
				END
			ELSE 99
		END ItemTypeLevel1Id
	  ,CASE 
			WHEN isnumeric(substring([Artikelnummer],1,1)) = 1  
				AND isnumeric(substring([Artikelnummer],2,1)) = 1 THEN
				CASE
					WHEN cast(substring([Artikelnummer],1,1) as int) = 1
						AND upper(USER_Markenklasse) = 3 THEN 2   -- Markenklasse = X
					WHEN cast(substring([Artikelnummer],1,1) as int) = 3 THEN 3
					WHEN cast(substring([Artikelnummer],1,1) as int) = 5 
						AND cast(substring([Artikelnummer],2,1)  as int) < 2 THEN 5
					WHEN cast(substring([Artikelnummer],1,1) as int) = 5 
						AND cast(substring([Artikelnummer],2,1)  as int) = 2 THEN cast(substring([Artikelnummer],1,2) as int) 
					WHEN cast(substring([Artikelnummer],1,1) as int) = 5 
						AND cast(substring([Artikelnummer],2,1)  as int) = 3 THEN cast(substring([Artikelnummer],1,2) as int) 
					WHEN cast(substring([Artikelnummer],1,1) as int) = 5 
						AND cast(substring([Artikelnummer],2,1)  as int) = 5 THEN cast(substring([Artikelnummer],1,2) as int) 
					WHEN cast(substring([Artikelnummer],1,1) as int) = 5 
						AND cast(substring([Artikelnummer],2,1)  as int) = 6 THEN cast(substring([Artikelnummer],1,2) as int) 	
					WHEN cast(substring([Artikelnummer],1,1) as int) = 6 
						AND cast(substring([Artikelnummer],2,1)  as int) = 5 THEN cast(substring([Artikelnummer],1,2) as int) 
					WHEN cast(substring([Artikelnummer],1,1) as int) = 9   THEN 9
					ELSE cast(substring([Artikelnummer],1,1) as int)
				END
			ELSE 0
		END ItemTypeLevel2Id
	  ,[mdRecordToLoadFlag]
      ,[mdLogId]
      ,[mdInsertDate]
  FROM [dbo].[tErpKHKArtikel] dim
  LEFT OUTER JOIN ItemGroup
  ON dim.Mandant = ItemGroup.CompanyId AND ItemGroup.ItemGroupcode = isnull(dim.[User_produktkategorie],9)
  LEFT OUTER JOIN ItemBrandclass
  ON ItemBrandclass.ItemBrandclassCode = isnull([User_Markenklasse],0)
  LEFT OUTER JOIN ItemSalesBrand  
  ON dim.Mandant = ItemSalesBrand.CompanyId AND ItemSalesBrand.ItemSalesBrandCode = isnull([User_VKMarke],'')
  LEFT OUTER JOIN CategoryManager  
  ON dim.Mandant = CategoryManager.CompanyId AND CategoryManager.CategoryManagerCode = isnull(dim.[USER_CategoryManagement],'')
  LEFT OUTER JOIN Purchaser  
  ON dim.Mandant = Purchaser.CompanyId AND Purchaser.PurchaserCode = isnull(dim.[USER_Einkaeufer],'')
  LEFT OUTER JOIN Sourcer  
  ON dim.Mandant = Sourcer.CompanyId AND Sourcer.SourcerCode = isnull(dim.[USER_Sourcer],'')
--  where Mandant = 1

GO
/****** Object:  View [dbo].[vErpKHKArtikelgruppen]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[vErpKHKArtikelgruppen]

AS

WITH ItemCategory as (
SELECT ItemCategoryId,Artikelgruppe,Bezeichnung, Mandant  FROM [dbo].[tErpKHKArtikelgruppen] ItemCategory
   where 
   --ItemCategory.Mandant = 1  and 
   ItemCategory.[Bezeichnung] <> 'Haushalt ALT'
  and ItemCategory.[Bezeichnung] <> 'Hifi Sets'
  and (LEN(ItemCategory.Artikelgruppe) = 9
  or ItemCategory.Artikelgruppe = 'EMPTY')
)



SELECT	Artikelgruppen.Mandant AS CompanyId
        , Artikelgruppen.[ItemCategoryId] ItemCategoryId
		, ParentItemCategory.ItemCategoryId ParentItemCategoryId
		, Artikelgruppen.[Artikelgruppe] ItemCategoryCode
		, Artikelgruppen.[VaterArtikelgruppe] ParentItemCategoryCode
	    , MainItemCategory.ItemCategoryId  MainItemCategoryId 
	    , MainItemCategory.Artikelgruppe MainItemCategoryCode
	    , MainItemCategory.Bezeichnung MainItemCategory
        , Artikelgruppen.[Bezeichnung] ItemCategory
        , Artikelgruppen.[gruppenebene] CategoryLevel
        , Artikelgruppen.[mdRecordToLoadFlag]
  FROM [dbo].[tErpKHKArtikelgruppen] Artikelgruppen
  LEFT OUTER JOIN ItemCategory ParentItemCategory
  ON ParentItemCategory.Artikelgruppe = Artikelgruppen.[VaterArtikelgruppe] AND Artikelgruppen.Mandant = ParentItemCategory.Mandant
  LEFT OUTER JOIN ItemCategory MainItemCategory
  ON MainItemCategory.Artikelgruppe = Artikelgruppen.[Hauptartikelgruppe] AND MainItemCategory.Mandant = Artikelgruppen.Mandant
  where 
  --Artikelgruppen.Mandant = 1
  --and 
  Artikelgruppen.[Bezeichnung] <> 'Haushalt ALT'
  and Artikelgruppen.[Bezeichnung] <> 'Hifi Sets'
  and (LEN(Artikelgruppen.Artikelgruppe) = 9
  or Artikelgruppen.Artikelgruppe = 'EMPTY')


GO
/****** Object:  View [dbo].[vErpKHKMandanten]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vErpKHKMandanten]

AS


SELECT [Mandant] CompanyId
      ,[Wert] Companyname
      ,[mdLogId]
      ,[mdInsertDate]
      ,[mdRecordToLoadFlag]
--  INTO [CT dwh 03 Intelligence].dbo.tDimCompany
  FROM [dbo].[tErpKHKMandanten]
  WHERE Eigenschaft = 1
GO
/****** Object:  View [dbo].[vErpKHKVKBelege]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[vErpKHKVKBelege]

AS

WITH Documentype AS (
						SELECT DocumentTypeId
								, Kennzeichen  DocumentTypeCode
								, Bezeichnung  DocumentType
								, MainDocumentTypeId
								, StatistikWirkungUmsatz StatisticOperatorRevenue
								, StatistikWirkungMenge StatisticOperatorAmount
								--, case MainDocumentTypeId
								--		when 0 then cast('Sales Quote' as varchar(30)) 
								--		when 1 then cast('Sales Order' as varchar(30)) 
								--		when 2 then cast('Sales Invoice' as varchar(30)) 
								--		when 3 then cast('Sales Cr. Memo' as varchar(30)) 
								--		when 4 then cast('Delivery Note' as varchar(30)) 
								--		when 5 then cast('ReDelivery note' as varchar(30)) 
								--		else  cast('Other Documents' as varchar(30)) 
								--end MainDocumentType
						  FROM [CT dwh 02 Data].[dbo].[tErpKHKVKBelegarten]
						)

SELECT dim.BelID SalesDocumentId
	   , dim.Mandant CompanyId
	   , dim.Belegnummer DocumentNo
	   , dim.Belegdatum DocumentDate
	   , Documentype.MainDocumentTypeId
	   , Documentype.DocumentTypeId
	   , Documentype.StatisticOperatorRevenue
	   , Documentype.StatisticOperatorAmount
	   , dim.Belegkennzeichen DocumentTypeCode
	   , dim.VorID ProcessId
	   , dim.mdRecordToLoadFlag
-- INTO [CT dwh 03 Intelligence].dbo.tDimSalesDocument   	
 FROM tErpKHKVKBelege dim
 LEFT OUTER JOIN Documentype
 ON Documentype.DocumentTypeCode = dim.Belegkennzeichen
 LEFT OUTER JOIN dbo.tErpKHKVKVorgaenge VkVorgang
 ON VkVorgang.Mandant = dim.Mandant
 and VkVorgang.VorID = dim.VorID
 where Belegjahr >= 2014







GO
/****** Object:  View [dbo].[vErpKHKVKVorgang]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vErpKHKVKVorgang]

AS
WITH ProcessNoDistinct AS (
					SELECT VkBeleg.Mandant
						, VkBeleg.VorID
						, min(VkBeleg.BelId) BelId
					FROM [dbo].[tErpKHKVKBelege] VkBeleg
					--WHERE 					VkBeleg.ReferenzBelID <> 0
					--and VkBeleg.VorID = 3984075
					--and VkBeleg.VorID = 4725973
					GROUP BY VkBeleg.Mandant,VkBeleg.VorID
					)
select 
	VkVorgang.Mandant CompanyId
	,VkVorgang.VorID ProcessId
	,cast(concat(VkVorgang.Mandant,'-',VkVorgang.VorID)  as varchar(30)) ProcessNo
	,cast(concat(VkBeleg.Belegjahr,'-',VkBeleg.Belegnummer) as varchar(30)) InitalDocumentNo
	,VkBeleg.Belegjahr DocumentYear
	,cast(VkBeleg.Belegdatum as date) DocumentDate
	,cast(VkVorgang.Erstanlage as date) ProcessDate
	,Belegkennzeichen  DocumentType
	,VkBeleg.Belegnummer DocumentNo
	,VkBeleg.A0Empfaenger CustomerNo
	,VkBeleg.WKz CurrencyCode
--INTO [CT dwh 03 Intelligence].dbo.tDimSalesProcess
from [dbo].[tErpKHKVKVorgaenge] VkVorgang
join [CT dwh 02 Data].[dbo].[tErpKHKVKBelege] VkBeleg
on VkBeleg.Mandant = VkVorgang.Mandant
AND VkBeleg.VorID = VkVorgang.VorID
join ProcessNoDistinct
ON ProcessNoDistinct.Mandant  = VkBeleg.Mandant
AND ProcessNoDistinct.BelId = VkBeleg.BelID
--where VkVorgang.Mandant = 1
--and VkBeleg.Belegjahr = 2016
--and VkVorgang.VorID = 4725973


GO
/****** Object:  View [dbo].[vErpKHKZuschlagsarten]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vErpKHKZuschlagsarten]

AS
WITH 
AddChargeEn as 
(
	SELECT 1 ZuschlagId, 'Shipping & Packaging' Zuschlagsart UNION
	SELECT 2 ZuschlagId, 'Payment Differencens' Zuschlagsart UNION
	SELECT 3 ZuschlagId, 'Collection Fees' Zuschlagsart UNION
	SELECT 4 ZuschlagId, 'Klarna Fees' Zuschlagsart UNION
	SELECT 5 ZuschlagId, 'COD Fees' Zuschlagsart UNION
	SELECT 6 ZuschlagId, 'Cdiscount Fees' Zuschlagsart UNION
	SELECT 99 ZuschlagId, 'Unknown' Zuschlagsart  
)
SELECT 
    En.[ZuschlagID] AdditionalChargeId,
	En.[Zuschlagsart] AdditionalCharge,
	[mdLogId],
	[mdInsertDate],
	[mdRecordToLoadFlag]
FROM 
	[dbo].[tErpKHKZuschlagsarten] De 
	LEFT OUTER JOIN AddChargeEn En ON De.ZuschlagID = En.ZuschlagID
WHERE De.Mandant = 1 and En.[ZuschlagID] IS NOT NULL











GO
/****** Object:  View [dbo].[vErpPriceRankList]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vErpPriceRankList]
AS

SELECT 
  1 as rlID
, 'Deutschland' as rlName
, 100001 as AmazonID
, 24017969 as EBayID
, 24156912 as ShopID
UNION 
SELECT 2, 'Spain', 100002, 24017974, 24156954
UNION 
SELECT 3, 'France', 100003, 24017968, 24156953
UNION 
SELECT 4, 'Italy', 100004, 24017971, 24156942
UNION 
SELECT 5, 'Great Britain', 100005, 24017964, 24156914 






GO
/****** Object:  View [dbo].[vErpShopPrices]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[vErpShopPrices]
AS

select 
       i.ItemId, i.Mandant 
		 --, shop.Artikelnummer
    -- , shop.ListeId
	, p.PriceListId
    , CONVERT(numeric(18,2),  min(shop.einzelpreis)) as Price
    , CAST(GETDATE() as date) currentdate
from terplbsyspreise shop
INNER JOIN tErpKHKPreislisten p ON p.ID = shop.ListeId and p.Mandant = shop.Mandant
INNER JOIN tErpKHKArtikel i ON shop.Artikelnummer = i.Artikelnummer and shop.Mandant = i.Mandant
where einzelpreis is not null
group by i.ItemId, i.Mandant , p.PriceListId




GO
/****** Object:  View [dbo].[vGABrowser]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vGABrowser]

AS


SELECT distinct Browser as Browser_Name from tGAPlatform
UNION 
SELECT distinct Browser as Browser_Name from tGAPlatformTR
GO
/****** Object:  View [dbo].[vGACampaign]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vGACampaign]

AS
SELECT DISTINCT campaign AS CampaignName FROM tGATrafficSources
UNION 
SELECT DISTINCT campaign AS CampaignName FROM tGATrafficSourcesTR
UNION
SELECT DISTINCT campaign AS CampaignName FROM tGAAdwordsCampaignStats
UNION
SELECT DISTINCT campaign AS CampaignName FROM tGAChannelBasicStats
UNION
SELECT DISTINCT campaign AS CampaignName FROM tGAChannelConversions
GO
/****** Object:  View [dbo].[vGADeviceBranding]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vGADeviceBranding]

AS


SELECT distinct mobdevice_branding  as DeviceBranding_Name from tGAMobileDevice
UNION 
SELECT distinct mobdevice_branding  as DeviceBranding_Name from tGAMobileDeviceTR


GO
/****** Object:  View [dbo].[vGADeviceCategory]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vGADeviceCategory]

AS


SELECT distinct device_category as DeviceCategory_Name from tGAMobileDevice
UNION 
SELECT distinct device_category as DeviceCategory_Name from tGAMobileDeviceTR


GO
/****** Object:  View [dbo].[vGADeviceInputSelector]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vGADeviceInputSelector]

AS


SELECT distinct mobdevice_inputselector  as DeviceInputSelector_Name from tGAMobileDevice
UNION 
SELECT distinct mobdevice_inputselector  as DeviceInputSelector_Name from tGAMobileDeviceTR


GO
/****** Object:  View [dbo].[vGADeviceMarketingName]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vGADeviceMarketingName]

AS


SELECT distinct mobdevice_mktname  as DeviceMarketingName_Name from tGAMobileDevice
UNION 
SELECT distinct mobdevice_mktname  as DeviceMarketingName_Name from tGAMobileDeviceTR


GO
/****** Object:  View [dbo].[vGAMedium]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vGAMedium]

AS


SELECT distinct Medium as Medium_Name from tGATrafficSources
UNION 
SELECT distinct Medium as Medium_Name from tGATrafficSourcesTR
GO
/****** Object:  View [dbo].[vGAOSystem]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vGAOSystem]

AS


SELECT distinct Opersystem as OSystem_Name from tGAPlatform
UNION 
SELECT distinct Opersystem as OSystem_Name from tGAPlatformTR
GO
/****** Object:  View [dbo].[vGASource]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vGASource]

AS


SELECT distinct Source as Source_Name from tGATrafficSources
UNION 
SELECT distinct Source as Source_Name from tGATrafficSourcesTR
GO
/****** Object:  View [dbo].[vGAWAdGroup]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vGAWAdGroup]

AS

SELECT 
  adg.[AdGroupid]
, ISNULL(c.CampaignId,1 ) as CampaignId
, ISNULL(cr.CustomerId, 1) as CustomerId
, adg.[group_name] 
, adg.[status] 
, adg.[adGroupType] 
FROM 
	dbo.tGAWAdGroup adg 
LEFT JOIN dbo.tGAWCampaign c on adg.campaign_id = c.campaign_id
LEFT JOIN dbo.tGAWCustomer cr on cr.customer_id = adg.customer_id
GO
/****** Object:  View [dbo].[vGAWCampaign]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vGAWCampaign]

AS


SELECT ISNULL(cr.[CustomerId], 1) as CustomerId
      ,[CampaignId]
      ,[campaign_name]
      ,[status]
      ,[startdate]
      ,[enddate]
      ,[advertisingchanneltype]
 
FROM [dbo].[tGAWCampaign] cp 
 LEFT JOIN [dbo].[tGAWCustomer] cr on cr.customer_id = cp.customer_id
GO
/****** Object:  View [dbo].[vGAWCustomer]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vGAWCustomer]
AS
SELECT 
  CustomerId
 ,customer_id As CustomerCode 
 ,Customer_name  AS CustomerName
 ,Canmanage AS CanManage  
 ,CASE WHEN Customer_name like '%PLA%' THEN 1 ELSE 0 END AS IsShopping
FROM [CT dwh 02 Data].[dbo].[tGAWCustomer]
GO
/****** Object:  View [dbo].[vGAWCustomerHierarchy]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vGAWCustomerHierarchy]

AS

select h.CustomerId, c.customer_name as CustomerName, h.ParentCustomerId
, h.CustomerId as Level1CustomerId, c.customer_name as Level1CustomerName
, NULL as Level2CustomerId, NULL as Level2CustomerName
, NULL as Level3CustomerId, NULL as Level3CustomerName
, NULL as Level4CustomerId, NULL as Level4CustomerName
from [dbo].[tGAWCustomerHierarchy] h 
inner join [dbo].[tGAWCustomer] c on c.CustomerId = h.CustomerId
where h.Level = 1
union all 
select h.CustomerId, c.customer_name as CustomerName, h.ParentCustomerId
, h.ParentCustomerId as Level1CustomerId, (select customer_name from [dbo].[tGAWCustomer] cc where cc.CustomerId = h.ParentCustomerId) as Level1CustomerName
, h.CustomerId as Level2CustomerId, c.customer_name as Level2CustomerName
, NULL as Level3CustomerId, NULL as Level3CustomerName
, NULL as Level4CustomerId, NULL as Level4CustomerName
from [dbo].[tGAWCustomerHierarchy] h 
inner join [dbo].[tGAWCustomer] c on c.CustomerId = h.CustomerId
where Level = 2
union all
select h.CustomerId, c.customer_name as CustomerName, h.ParentCustomerId
, (select CustomerId from [dbo].[tGAWCustomerHierarchy] where ParentCustomerId = 0) as Level1CustomerId 
, (select cc.customer_name from [dbo].[tGAWCustomerHierarchy] hh inner join [dbo].[tGAWCustomer] cc on cc.CustomerId = hh.CustomerId where hh.ParentCustomerId = 0) as Level1CustomerName
, h.ParentCustomerId as Level2CustomerId 
, (select cc.customer_name from [dbo].[tGAWCustomerHierarchy] hh inner join [dbo].[tGAWCustomer] cc on cc.CustomerId = hh.CustomerId where hh.CustomerId = h.ParentCustomerId) as Level2CustomerName
, h.CustomerId as Level3CustomerId, c.customer_name as Level3CustomerName
, NULL as Level4CustomerId, NULL as Level4CustomerName
from [dbo].[tGAWCustomerHierarchy] h 
inner join [dbo].[tGAWCustomer] c on c.CustomerId = h.CustomerId
where h.Level = 3
union all 
select h.CustomerId, c.customer_name as CustomerName, h.ParentCustomerId
, (select CustomerId from [dbo].[tGAWCustomerHierarchy] where ParentCustomerId = 0) as Level1CustomerId 
, (select cc.customer_name from [dbo].[tGAWCustomerHierarchy] hh inner join [dbo].[tGAWCustomer] cc on cc.CustomerId = hh.CustomerId where hh.ParentCustomerId = 0) as Level1CustomerName
, (select ParentCustomerId from [dbo].[tGAWCustomerHierarchy] hh where hh.CustomerId = h.ParentCustomerId ) as Level2CustomerId 
, (select cc.customer_name from [dbo].[tGAWCustomerHierarchy] hh inner join [dbo].[tGAWCustomer] cc on cc.CustomerId = hh.ParentCustomerId where hh.CustomerId = h.ParentCustomerId) as Level2CustomerName
, ParentCustomerId as Level3CustomerId
, (select cc.customer_name from [dbo].[tGAWCustomerHierarchy] hh inner join [dbo].[tGAWCustomer] cc on cc.CustomerId = hh.CustomerId where hh.CustomerId = h.ParentCustomerId) as Level3CustomerName
, h.CustomerId as Level4CustomerId 
, c.customer_name as Level4CustomerName
from [dbo].[tGAWCustomerHierarchy] h 
inner join [dbo].[tGAWCustomer] c on c.CustomerId = h.CustomerId
where h.Level = 4
GO
/****** Object:  View [dbo].[vGeoCity]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vGeoCity]
AS
select distinct 
cc.CountryId, 
r.regionid, 
CONVERT(nvarchar(255), 
case when mc.locality = '' then 'zzUnknown' else mc.locality end 
) as CityName
from tempMapAdressenCity mc
inner join tErpChaltecCountryCodes cc on cc.CountryCode = mc.country_code 
inner join tGeoRegion r on  r.RegionName = mc.administrative_area_level_1 and r.CountryId = cc.CountryId
where mc.Result = 'OK'

GO
/****** Object:  View [dbo].[vGeoRegion]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vGeoRegion]
AS
select distinct 
cc.CountryId, 
CONVERT(nvarchar(255), 
case when mc.administrative_area_level_1 = '' then 'zzUnknown' else administrative_area_level_1 end 
) as RegionName
from tempMapAdressenCity mc
inner join tErpChaltecCountryCodes cc on cc.CountryCode = mc.country_code and mc.Result = 'OK'

GO
/****** Object:  View [dbo].[vMissingProcessIDsInFactAllSales]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[vMissingProcessIDsInFactAllSales] AS
SELECT belege.VorID as ProcessId, belege.BelID as DocumentId, belege.Mandant as CompanyId, belege.mdInsertDate FROM [CT dwh 02 Data].dbo.tERPKHKVKBelege belege WITH (NOLOCK)
INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegePositionen belpos WITH (NOLOCK)
	ON belpos.BelID = belege.BelID
	and belpos.Mandant = belege.Mandant
	AND belpos.IsDeletedFlag = 0
INNER JOIN [CT dwh 02 Data].dbo.tErpKHKArtikel AS Art WITH (NOLOCK)
	ON belpos.Artikelnummer = Art.Artikelnummer
	AND belpos.Mandant = Art.Mandant
INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegarten AS Belegarten WITH(NOLOCK) 
	ON 	 Belegarten.Kennzeichen = belege.Belegkennzeichen   
LEFT OUTER JOIN [CT dwh 02 Data].dbo.tFactAllSalesTransactions fact WITH (NOLOCK)
	ON belege.VorID = fact.ProcessId
	AND belege.Mandant = fact.CompanyId
	AND belege.BelID = fact.DocumentId
WHERE fact.ProcessId IS NULL  
	AND belege.IsDeletedFlag = 0
	and belege.Belegdatum >= cast('2016-01-01' as date)
	AND belege.VORID > 0
	AND belege.VorID not in (15581848, 15912440, 15974964
,15982038
,15984112
,15993040
,16000278
,16021946
,16026715
,16037940
,16042964
,16047012
,16050536
,16050951
,16051692
,16075689
,16084517
,15994828
,16047088
,16089675
,16101214
,16101293
,16101550
,16101696)
	AND belege.mdRecordToLoadFlag = 0
GO
/****** Object:  View [dbo].[vMktAffilinetCreatives]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vMktAffilinetCreatives]

AS

SELECT DISTINCT CreativeType
FROM tMktAffilinetOrders
GO
/****** Object:  View [dbo].[vMktAffilinetRates]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vMktAffilinetRates]

AS

SELECT DISTINCT RateMode, RateDescription
FROM tMktAffilinetOrders
GO
/****** Object:  View [dbo].[vMktAffilinetTransactionStates]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vMktAffilinetTransactionStates]

AS

SELECT DISTINCT TransactionStatus AS TransactionState
FROM tMktAffilinetOrders
WHERE TransactionStatus IS NOT NULL
GO
/****** Object:  View [dbo].[vMktAffilinetValuationTypes]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vMktAffilinetValuationTypes]

AS

SELECT DISTINCT ValuationType
FROM tMktAffilinetStatistics
GO
/****** Object:  View [dbo].[vMktCrmEmailCampaignsResponseDateRanges]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vMktCrmEmailCampaignsResponseDateRanges]

AS

WITH maxResponses as(
  SELECT c.Account, c.id as EmailCampaignId, MAX(COALESCE(r.[date], c.created, CAST(c.mdInsertDate AS DATE))) as maxResponseDate
  FROM [CT dwh 02 Data].dbo.[tMktCrmEmailCampaigns] c
    LEFT OUTER JOIN [CT dwh 02 Data].dbo.[tMktCrmEmailCampaignResponses] r
	  ON c.Account = r.Account AND c.id = r.email_campaign_id
  GROUP BY c.Account, c.id
)
SELECT ISNULL(c.Account, maxResponses.Account) AS Account, ISNULL(c.id, maxResponses.EmailCampaignId) AS EmailCampaignId, COALESCE(l.launch_date, c.created, maxResponses.maxResponseDate) AS DateFrom,
  IIF(DATEADD(dd, 13, COALESCE(l.launch_date, c.created, maxResponses.maxResponseDate)) > CAST(GETDATE() - 1 AS DATE), CAST(GETDATE() - 1 AS DATE), DATEADD(dd, 13, COALESCE(l.launch_date, c.created, maxResponses.maxResponseDate))) AS DateTo
FROM [CT dwh 01 Stage].dbo.[tMkt_CrmEmailCampaigns] c
  LEFT OUTER JOIN [CT dwh 01 Stage].dbo.[tMkt_CrmEmailCampaignLaunches] l
    ON c.Account = l.Account AND c.id = l.email_campaign_id
  FULL OUTER JOIN maxResponses
    ON c.Account = maxResponses.Account and c.id = maxResponses.EmailCampaignId
GO
/****** Object:  View [dbo].[vMktCrmEmailCampaignStates]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vMktCrmEmailCampaignStates]

AS

SELECT 1 AS StateId, 'In design' AS EmailCampaignState
UNION
SELECT 2 AS StateId, 'Tested' AS EmailCampaignState
UNION
SELECT 3 AS StateId, 'Launched' AS EmailCampaignState
UNION
SELECT 4 AS StateId, 'Ready to launch' AS EmailCampaignState
UNION
SELECT -3 AS StateId, 'Deactivated' AS EmailCampaignState
UNION
SELECT -6 AS StateId, 'Aborted' AS EmailCampaignState
GO
/****** Object:  View [dbo].[vMktFeedDynamixPartner]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vMktFeedDynamixPartner]

AS

SELECT DISTINCT partner_uid AS PartnerUid, MAX([partner]) AS [Partner]
FROM tMktFeedDynamixProductConversions
GROUP BY partner_uid

GO
/****** Object:  View [dbo].[vMktSource]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vMktSource]
AS
SELECT 
distinct source as Source from tGAChannelBasicStats
where date > '2016-01-01'
UNION 
select distinct source as Source from [dbo].[tGAChannelConversions]
where date > '2016-01-01'
UNION 
select distinct source as Source from [dbo].[tGAAdwordsCampaignStats]
where date > '2016-01-01'


GO
/****** Object:  View [dbo].[vProductHierarchieSAP]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vProductHierarchieSAP] AS
with stufe3                               as
    (
        select *
        FROM
            [CT dwh 01 Stage].[dbo].[tSAP_T179_Hierarchie] with (nolock)
        where
            stufe = 3
    )
select
    stufe3.MANDT
  , s1.PRODH     as ProductHierarchie1
  , PH1.VTEXT    as ProductHierarchie1_txt
  , s2.PRODH     as ProductHierarchie2
  , PH2.VTEXT    as ProductHierarchie2_txt
  , stufe3.PRODH as ProductHierarchie3
  , PH3.VTEXT    as ProductHierarchie3_txt
from
    stufe3
    join
        [CT dwh 01 Stage].[dbo].[tSAP_T179_Hierarchie] s1 with (nolock)
        on
            s1.stufe            = 1
            and s1.MANDT        = stufe3.MANDT
            and stufe3.PRODH LIKE s1.PRODH + '%'
    join
        [CT dwh 01 Stage].[dbo].[tSAP_T179_Hierarchie] s2 with (nolock)
        on
            s2.stufe            = 2
            and s2.MANDT        = stufe3.MANDT
            and stufe3.PRODH LIKE s2.PRODH + '%'
    join
        [CT dwh 01 Stage].[dbo].[tSAP_T179T] as PH1 with (nolock)
        on
            s1.PRODH      = PH1.PRODH
            AND PH1.SPRAS = 'E'
    join
        [CT dwh 01 Stage].[dbo].[tSAP_T179T] as PH2 with (nolock)
        on
            s2.PRODH      = PH2.PRODH
            AND PH2.SPRAS = 'E'
    join
        [CT dwh 01 Stage].[dbo].[tSAP_T179T] as PH3 with (nolock)
        on
            stufe3.PRODH  = PH3.PRODH
            AND PH3.SPRAS = 'E'
GO
/****** Object:  View [dbo].[vSAP_Validation_VAHDR_VAITM]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[vSAP_Validation_VAHDR_VAITM] AS

SELECT VAHDR.[row_id]							AS [VAHDR_row_id]
      ,VAHDR.[version]						AS [VAHDR_version]
      ,VAHDR.[valid_from]						AS [VAHDR_valid_from]
      ,VAHDR.[valid_to]						AS [VAHDR_valid_to]
      ,VAHDR.[VBELN]							AS [VAHDR_VBELN]
      ,VAHDR.[ANGDT]							AS [VAHDR_ANGDT]
      ,VAHDR.[ANZAU]							AS [VAHDR_ANZAU]
      ,VAHDR.[AUART]							AS [VAHDR_AUART]
      ,VAHDR.[AUGRU]							AS [VAHDR_AUGRU]
      ,VAHDR.[BNDDT]							AS [VAHDR_BNDDT]
      ,VAHDR.[BUKRS]							AS [VAHDR_BUKRS]
      ,VAHDR.[ERDAT]							AS [VAHDR_ERDAT]
      ,VAHDR.[FAKSK]							AS [VAHDR_FAKSK]
      ,VAHDR.[HWAER]							AS [VAHDR_HWAER]
      ,VAHDR.[is_current]						AS [VAHDR_is_current]
      ,VAHDR.[is_deleted]						AS [VAHDR_is_deleted]
      ,VAHDR.[KUNNR]							AS [VAHDR_KUNNR]
      ,VAHDR.[KURST]							AS [VAHDR_KURST]
      ,VAHDR.[KVGR1]							AS [VAHDR_KVGR1]
      ,VAHDR.[KVGR2]							AS [VAHDR_KVGR2]
      ,VAHDR.[KVGR3]							AS [VAHDR_KVGR3]
      ,VAHDR.[KVGR4]							AS [VAHDR_KVGR4]
      ,VAHDR.[KVGR5]							AS [VAHDR_KVGR5]
      ,VAHDR.[LIFSK]							AS [VAHDR_LIFSK]
      ,VAHDR.[PERIV]							AS [VAHDR_PERIV]
      ,VAHDR.[PVRTNR]							AS [VAHDR_PVRTNR]
      ,VAHDR.[SPARA]							AS [VAHDR_SPARA]
      ,VAHDR.[STWAE]							AS [VAHDR_STWAE]
      ,VAHDR.[VBTYP]							AS [VAHDR_VBTYP]
      ,VAHDR.[VDATU]							AS [VAHDR_VDATU]
      ,VAHDR.[VGTYP_AK]						AS [VAHDR_VGTYP_AK]
      ,VAHDR.[VKBUR]							AS [VAHDR_VKBUR]
      ,VAHDR.[VKGRP]							AS [VAHDR_VKGRP]
      ,VAHDR.[VKORG]							AS [VAHDR_VKORG]
      ,VAHDR.[VTWEG]							AS [VAHDR_VTWEG]
      ,VAHDR.[WAERK]							AS [VAHDR_WAERK]
      ,VAHDR.[ZZ_UPD_TMSTMP]					AS [VAHDR_ZZ_UPD_TMSTMP]
	  ,VAITM.[row_id]						AS [VAITM_row_id]
      ,VAITM.[version]					AS [VAITM_version]
      ,VAITM.[valid_from]					AS [VAITM_valid_from]
      ,VAITM.[valid_to]					AS [VAITM_valid_to]
      ,VAITM.[POSNR]						AS [VAITM_POSNR]
      ,VAITM.[VBELN]						AS [VAITM_VBELN]
      ,VAITM.[ABGRU]						AS [VAITM_ABGRU]
      ,VAITM.[ABSTA]						AS [VAITM_ABSTA]
      ,VAITM.[AEDAT]						AS [VAITM_AEDAT]
      ,VAITM.[ANGDT]						AS [VAITM_ANGDT]
      ,VAITM.[ANZAUPO]					AS [VAITM_ANZAUPO]
      ,VAITM.[APOPLANNED]					AS [VAITM_APOPLANNED]
      ,VAITM.[AUART]						AS [VAITM_AUART]
      ,VAITM.[AUGRU]						AS [VAITM_AUGRU]
      ,VAITM.[AWAHR]						AS [VAITM_AWAHR]
      ,VAITM.[BNDDT]						AS [VAITM_BNDDT]
      ,VAITM.[BRGEW]						AS [VAITM_BRGEW]
      ,VAITM.[BUKRS]						AS [VAITM_BUKRS]
      ,VAITM.[BWAPPLNM]					AS [VAITM_BWAPPLNM]
      ,VAITM.[BWVORG]						AS [VAITM_BWVORG]
      ,VAITM.[BZIRK]						AS [VAITM_BZIRK]
      ,VAITM.[CHARG]						AS [VAITM_CHARG]
      ,VAITM.[CMKUA]						AS [VAITM_CMKUA]
      ,VAITM.[EAN11]						AS [VAITM_EAN11]
      ,VAITM.[ERDAT]						AS [VAITM_ERDAT]
      ,VAITM.[ERNAM]						AS [VAITM_ERNAM]
      ,VAITM.[ERZET]						AS [VAITM_ERZET]
      ,VAITM.[FAKSK]						AS [VAITM_FAKSK]
      ,VAITM.[FAKSP]						AS [VAITM_FAKSP]
      ,VAITM.[FBUDA]						AS [VAITM_FBUDA]
      ,VAITM.[FKDAT]						AS [VAITM_FKDAT]
      ,VAITM.[GEWEI]						AS [VAITM_GEWEI]
      ,VAITM.[HWAER]						AS [VAITM_HWAER]
      ,VAITM.[INCO1]						AS [VAITM_INCO1]
      ,VAITM.[INCO2]						AS [VAITM_INCO2]
      ,VAITM.[is_current]					AS [VAITM_is_current]
      ,VAITM.[is_deleted]					AS [VAITM_is_deleted]
      ,VAITM.[KBMENG]						AS [VAITM_KBMENG]
      ,VAITM.[KDGRP]						AS [VAITM_KDGRP]
      ,VAITM.[KLMENG]						AS [VAITM_KLMENG]
      ,VAITM.[KMEIN]						AS [VAITM_KMEIN]
      ,VAITM.[KNUMA_AG]					AS [VAITM_KNUMA_AG]
      ,VAITM.[KPEIN]						AS [VAITM_KPEIN]
      ,VAITM.[KTGRD]						AS [VAITM_KTGRD]
      ,VAITM.[KUNNR]						AS [VAITM_KUNNR]
      ,VAITM.[KURSK]						AS [VAITM_KURSK]
      ,VAITM.[KURSK_DAT]					AS [VAITM_KURSK_DAT]
      ,VAITM.[KURST]						AS [VAITM_KURST]
      ,VAITM.[KVGR1]						AS [VAITM_KVGR1]
      ,VAITM.[KVGR2]						AS [VAITM_KVGR2]
      ,VAITM.[KVGR3]						AS [VAITM_KVGR3]
      ,VAITM.[KVGR4]						AS [VAITM_KVGR4]
      ,VAITM.[KVGR5]						AS [VAITM_KVGR5]
      ,VAITM.[KWMENG]						AS [VAITM_KWMENG]
      ,VAITM.[KZWI1]						AS [VAITM_KZWI1]
      ,VAITM.[KZWI2]						AS [VAITM_KZWI2]
      ,VAITM.[KZWI3]						AS [VAITM_KZWI3]
      ,VAITM.[KZWI4]						AS [VAITM_KZWI4]
      ,VAITM.[KZWI5]						AS [VAITM_KZWI5]
      ,VAITM.[KZWI6]						AS [VAITM_KZWI6]
      ,VAITM.[LFMNG]						AS [VAITM_LFMNG]
      ,VAITM.[LGORT]						AS [VAITM_LGORT]
      ,VAITM.[LIFSK]						AS [VAITM_LIFSK]
      ,VAITM.[LSMENG]						AS [VAITM_LSMENG]
      ,VAITM.[MATKL]						AS [VAITM_MATKL]
      ,VAITM.[MATNR]						AS [VAITM_MATNR]
      ,VAITM.[MATWA]						AS [VAITM_MATWA]
      ,VAITM.[MCBW_NETPR_AVKM]			AS [VAITM_MCBW_NETPR_AVKM]
      ,VAITM.[MCEX_APCAMPAIGN]			AS [VAITM_MCEX_APCAMPAIGN]
      ,VAITM.[MEINS]						AS [VAITM_MEINS]
      ,VAITM.[MVGR1]						AS [VAITM_MVGR1]
      ,VAITM.[MVGR2]						AS [VAITM_MVGR2]
      ,VAITM.[MVGR3]						AS [VAITM_MVGR3]
      ,VAITM.[MVGR4]						AS [VAITM_MVGR4]
      ,VAITM.[MVGR5]						AS [VAITM_MVGR5]
      ,VAITM.[MWSBP]						AS [VAITM_MWSBP]
      ,VAITM.[NETPR]						AS [VAITM_NETPR]
      ,VAITM.[NETWR]						AS [VAITM_NETWR]
      ,VAITM.[NTGEW]						AS [VAITM_NTGEW]
      ,VAITM.[PABLA]						AS [VAITM_PABLA]
      ,VAITM.[PERIV]						AS [VAITM_PERIV]
      ,VAITM.[PKUNRE]						AS [VAITM_PKUNRE]
      ,VAITM.[PKUNRG]						AS [VAITM_PKUNRG]
      ,VAITM.[PKUNWE]						AS [VAITM_PKUNWE]
      ,VAITM.[PRODH]						AS [VAITM_PRODH]
      ,VAITM.[PRSDT]						AS [VAITM_PRSDT]
      ,VAITM.[PS_POSID]					AS [VAITM_PS_POSID]
      ,VAITM.[PSPDNR]						AS [VAITM_PSPDNR]
      ,VAITM.[PSTYV]						AS [VAITM_PSTYV]
      ,VAITM.[PVRTNR]						AS [VAITM_PVRTNR]
      ,VAITM.[ROUTE]						AS [VAITM_ROUTE]
      ,VAITM.[SOBKZ]						AS [VAITM_SOBKZ]
      ,VAITM.[SPARA]						AS [VAITM_SPARA]
      ,VAITM.[SPART]						AS [VAITM_SPART]
      ,VAITM.[STADAT]						AS [VAITM_STADAT]
      ,VAITM.[STCUR]						AS [VAITM_STCUR]
      ,VAITM.[STWAE]						AS [VAITM_STWAE]
      ,VAITM.[SUGRD]						AS [VAITM_SUGRD]
      ,VAITM.[UEBTK]						AS [VAITM_UEBTK]
      ,VAITM.[UEBTO]						AS [VAITM_UEBTO]
      ,VAITM.[UMVKN]						AS [VAITM_UMVKN]
      ,VAITM.[UMVKZ]						AS [VAITM_UMVKZ]
      ,VAITM.[UMZIN]						AS [VAITM_UMZIN]
      ,VAITM.[UMZIZ]						AS [VAITM_UMZIZ]
      ,VAITM.[UNTTO]						AS [VAITM_UNTTO]
      ,VAITM.[UVALL]						AS [VAITM_UVALL]
      ,VAITM.[UVFAK]						AS [VAITM_UVFAK]
      ,VAITM.[UVPRS]						AS [VAITM_UVPRS]
      ,VAITM.[UVVLK]						AS [VAITM_UVVLK]
      ,VAITM.[VBTYP]						AS [VAITM_VBTYP]
      ,VAITM.[VDATU]						AS [VAITM_VDATU]
      ,VAITM.[VGBEL]						AS [VAITM_VGBEL]
      ,VAITM.[VGPOS]						AS [VAITM_VGPOS]
      ,VAITM.[VGTYP]						AS [VAITM_VGTYP]
      ,VAITM.[VGTYP_AK]					AS [VAITM_VGTYP_AK]
      ,VAITM.[VKBUR]						AS [VAITM_VKBUR]
      ,VAITM.[VKGRP]						AS [VAITM_VKGRP]
      ,VAITM.[VKORG]						AS [VAITM_VKORG]
      ,VAITM.[VOLEH]						AS [VAITM_VOLEH]
      ,VAITM.[VOLUM]						AS [VAITM_VOLUM]
      ,VAITM.[VRKME]						AS [VAITM_VRKME]
      ,VAITM.[VSTEL]						AS [VAITM_VSTEL]
      ,VAITM.[VTWEG]						AS [VAITM_VTWEG]
      ,VAITM.[WAERK]						AS [VAITM_WAERK]
      ,VAITM.[WAERK_VBAK]					AS [VAITM_WAERK_VBAK]
      ,VAITM.[WAKTION]					AS [VAITM_WAKTION]
      ,VAITM.[WAVWR]						AS [VAITM_WAVWR]
      ,VAITM.[WERKS]						AS [VAITM_WERKS]
      ,VAITM.[WMINR]						AS [VAITM_WMINR]
      ,VAITM.[ZIEME]						AS [VAITM_ZIEME]
      ,VAITM.[ZMENG]						AS [VAITM_ZMENG]
      ,VAITM.[ZWERT]						AS [VAITM_ZWERT]
      ,VAITM.[ZZ_CPD_UPDAT]				AS [VAITM_ZZ_CPD_UPDAT]
      ,VAITM.[ZZ_SGT_RCAT]				AS [VAITM_ZZ_SGT_RCAT]
	  ,VAKON.[row_id]							AS [VAKON_row_id]
      ,VAKON.[version]						AS [VAKON_version]
      ,VAKON.[valid_from]						AS [VAKON_valid_from]
      ,VAKON.[valid_to]						AS [VAKON_valid_to]
      ,VAKON.[KSCHL]							AS [VAKON_KSCHL]
      ,VAKON.[POSNR]							AS [VAKON_POSNR]
      ,VAKON.[VBELN]							AS [VAKON_VBELN]
      ,VAKON.[ABGRU]							AS [VAKON_ABGRU]
      ,VAKON.[ABSTA]							AS [VAKON_ABSTA]
      ,VAKON.[AEDAT]							AS [VAKON_AEDAT]
      ,VAKON.[AUART]							AS [VAKON_AUART]
      ,VAKON.[AUGRU]							AS [VAKON_AUGRU]
      ,VAKON.[BUKRS]							AS [VAKON_BUKRS]
      ,VAKON.[BWAPPLNM]						AS [VAKON_BWAPPLNM]
      ,VAKON.[BWVORG]							AS [VAKON_BWVORG]
      ,VAKON.[BZIRK]							AS [VAKON_BZIRK]
      ,VAKON.[EAN11]							AS [VAKON_EAN11]
      ,VAKON.[ERDAT]							AS [VAKON_ERDAT]
      ,VAKON.[ERNAM]							AS [VAKON_ERNAM]
      ,VAKON.[ERZET]							AS [VAKON_ERZET]
      ,VAKON.[FAKSK]							AS [VAKON_FAKSK]
      ,VAKON.[FAKSP]							AS [VAKON_FAKSP]
      ,VAKON.[FBUDA]							AS [VAKON_FBUDA]
      ,VAKON.[FKDAT]							AS [VAKON_FKDAT]
      ,VAKON.[HWAER]							AS [VAKON_HWAER]
      ,VAKON.[INCO1]							AS [VAKON_INCO1]
      ,VAKON.[INCO2]							AS [VAKON_INCO2]
      ,VAKON.[is_current]						AS [VAKON_is_current]
      ,VAKON.[is_deleted]						AS [VAKON_is_deleted]
      ,VAKON.[KAPPL]							AS [VAKON_KAPPL]
      ,VAKON.[KDGRP]							AS [VAKON_KDGRP]
      ,VAKON.[KHERK]							AS [VAKON_KHERK]
      ,VAKON.[KINAK]							AS [VAKON_KINAK]
      ,VAKON.[KNTYP]							AS [VAKON_KNTYP]
      ,VAKON.[KOAID]							AS [VAKON_KOAID]
      ,VAKON.[KSTAT]							AS [VAKON_KSTAT]
      ,VAKON.[KTGRD]							AS [VAKON_KTGRD]
      ,VAKON.[KUNNR]							AS [VAKON_KUNNR]
      ,VAKON.[KURSK]							AS [VAKON_KURSK]
      ,VAKON.[KURSK_DAT]						AS [VAKON_KURSK_DAT]
      ,VAKON.[KURST]							AS [VAKON_KURST]
      ,VAKON.[KVARC]							AS [VAKON_KVARC]
      ,VAKON.[KVGR1]							AS [VAKON_KVGR1]
      ,VAKON.[KVGR2]							AS [VAKON_KVGR2]
      ,VAKON.[KVGR3]							AS [VAKON_KVGR3]
      ,VAKON.[KVGR4]							AS [VAKON_KVGR4]
      ,VAKON.[KVGR5]							AS [VAKON_KVGR5]
      ,VAKON.[KWERT]							AS [VAKON_KWERT]
      ,VAKON.[KWMENG]							AS [VAKON_KWMENG]
      ,VAKON.[MATKL]							AS [VAKON_MATKL]
      ,VAKON.[MATNR]							AS [VAKON_MATNR]
      ,VAKON.[MATWA]							AS [VAKON_MATWA]
      ,VAKON.[MVGR1]							AS [VAKON_MVGR1]
      ,VAKON.[MVGR2]							AS [VAKON_MVGR2]
      ,VAKON.[MVGR3]							AS [VAKON_MVGR3]
      ,VAKON.[MVGR4]							AS [VAKON_MVGR4]
      ,VAKON.[MVGR5]							AS [VAKON_MVGR5]
      ,VAKON.[PERIV]							AS [VAKON_PERIV]
      ,VAKON.[PKUNRE]							AS [VAKON_PKUNRE]
      ,VAKON.[PKUNRG]							AS [VAKON_PKUNRG]
      ,VAKON.[PKUNWE]							AS [VAKON_PKUNWE]
      ,VAKON.[PRODH]							AS [VAKON_PRODH]
      ,VAKON.[PRSDT]							AS [VAKON_PRSDT]
      ,VAKON.[PS_POSID]						AS [VAKON_PS_POSID]
      ,VAKON.[PSTYV]							AS [VAKON_PSTYV]
      ,VAKON.[PVRTNR]							AS [VAKON_PVRTNR]
      ,VAKON.[SPARA]							AS [VAKON_SPARA]
      ,VAKON.[SPART]							AS [VAKON_SPART]
      ,VAKON.[STADAT]							AS [VAKON_STADAT]
      ,VAKON.[STCUR]							AS [VAKON_STCUR]
      ,VAKON.[STUNR]							AS [VAKON_STUNR]
      ,VAKON.[STWAE]							AS [VAKON_STWAE]
      ,VAKON.[UVPRS]							AS [VAKON_UVPRS]
      ,VAKON.[VARCOND]						AS [VAKON_VARCOND]
      ,VAKON.[VBTYP]							AS [VAKON_VBTYP]
      ,VAKON.[VGTYP_AK]						AS [VAKON_VGTYP_AK]
      ,VAKON.[VKBUR]							AS [VAKON_VKBUR]
      ,VAKON.[VKGRP]							AS [VAKON_VKGRP]
      ,VAKON.[VKORG]							AS [VAKON_VKORG]
      ,VAKON.[VRKME]							AS [VAKON_VRKME]
      ,VAKON.[VTWEG]							AS [VAKON_VTWEG]
      ,VAKON.[WAERK]							AS [VAKON_WAERK]
      ,VAKON.[WAERK_VBAK]						AS [VAKON_WAERK_VBAK]
      ,VAKON.[WAKTION]						AS [VAKON_WAKTION]
      ,VAKON.[ZAEHK]							AS [VAKON_ZAEHK]
      ,VAKON.[ZIEME]							AS [VAKON_ZIEME]
      ,VAKON.[ZMENG]							AS [VAKON_ZMENG]
  FROM [CT dwh 02 Data].[dbo].[tSAP2LIS_11_VAHDR] AS VAHDR WITH (NOLOCK)
  INNER JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_11_VAITM] AS VAITM WITH (NOLOCK)
	ON VAHDR.VBELN = VAITM.VBELN
  LEFT JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_11_VAKON] AS VAKON WITH (NOLOCK)
   ON VAHDR.VBELN = VAKON.VBELN and VAITM.POSNR = VAKON.POSNR and VAKON.is_current = 1
   
   WHERE VAHDR.is_current = 1 and VAITM.is_current = 1 
GO
/****** Object:  View [dbo].[vSAP_Validation_VCHDR_VCITM]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[vSAP_Validation_VCHDR_VCITM] AS

SELECT 
	  VCHDR.[row_id]			AS [VCHDR_row_id]
      ,VCHDR.[version]		AS [VCHDR_version]
      ,VCHDR.[valid_from]		AS [VCHDR_valid_from]
      ,VCHDR.[valid_to]		AS [VCHDR_valid_to]
      ,VCHDR.[VBELN]			AS [VCHDR_VBELN]
      ,VCHDR.[ABLAD]			AS [VCHDR_ABLAD]
      ,VCHDR.[ANZLI]			AS [VCHDR_ANZLI]
      ,VCHDR.[BTGEW]			AS [VCHDR_BTGEW]
      ,VCHDR.[BUKRS]			AS [VCHDR_BUKRS]
      ,VCHDR.[BZIRK]			AS [VCHDR_BZIRK]
      ,VCHDR.[ERDAT]			AS [VCHDR_ERDAT]
      ,VCHDR.[FAKSK]			AS [VCHDR_FAKSK]
      ,VCHDR.[GEWEI]			AS [VCHDR_GEWEI]
      ,VCHDR.[INCO1]			AS [VCHDR_INCO1]
      ,VCHDR.[INCO2]			AS [VCHDR_INCO2]
      ,VCHDR.[is_current]		AS [VCHDR_is_current]
      ,VCHDR.[is_deleted]		AS [VCHDR_is_deleted]
      ,VCHDR.[KDGRP]			AS [VCHDR_KDGRP]
      ,VCHDR.[KUNAG]			AS [VCHDR_KUNAG]
      ,VCHDR.[KUNNR]			AS [VCHDR_KUNNR]
      ,VCHDR.[LFART]			AS [VCHDR_LFART]
      ,VCHDR.[LFDAT]			AS [VCHDR_LFDAT]
      ,VCHDR.[LIFNR]			AS [VCHDR_LIFNR]
      ,VCHDR.[LIFSK]			AS [VCHDR_LIFSK]
      ,VCHDR.[LSTEL]			AS [VCHDR_LSTEL]
      ,VCHDR.[MCBW_ANZPK]		AS [VCHDR_MCBW_ANZPK]
      ,VCHDR.[NTGEW]			AS [VCHDR_NTGEW]
      ,VCHDR.[PERIV]			AS [VCHDR_PERIV]
      ,VCHDR.[PKUNRE]			AS [VCHDR_PKUNRE]
      ,VCHDR.[PKUNRG]			AS [VCHDR_PKUNRG]
      ,VCHDR.[PSPDNR]			AS [VCHDR_PSPDNR]
      ,VCHDR.[PVRTNR]			AS [VCHDR_PVRTNR]
      ,VCHDR.[ROUTE]			AS [VCHDR_ROUTE]
      ,VCHDR.[VBTYP]			AS [VCHDR_VBTYP]
      ,VCHDR.[VKORG]			AS [VCHDR_VKORG]
      ,VCHDR.[VOLEH]			AS [VCHDR_VOLEH]
      ,VCHDR.[VOLUM]			AS [VCHDR_VOLUM]
      ,VCHDR.[VSTEL]			AS [VCHDR_VSTEL]
      ,VCHDR.[WA_DELAY_LF]	AS [VCHDR_WA_DELAY_LF]
      ,VCHDR.[WADAT]			AS [VCHDR_WADAT]
      ,VCHDR.[WADAT_IST]		AS [VCHDR_WADAT_IST]
	   ,VCITM.[row_id]			AS [VCITM_row_id]
      ,VCITM.[version]		AS [VCITM_version]
      ,VCITM.[valid_from]		AS [VCITM_valid_from]
      ,VCITM.[valid_to]		AS [VCITM_valid_to]
      ,VCITM.[POSNR]			AS [VCITM_POSNR]
      ,VCITM.[VBELN]			AS [VCITM_VBELN]
      ,VCITM.[ABLAD]			AS [VCITM_ABLAD]
      ,VCITM.[AEDAT]			AS [VCITM_AEDAT]
      ,VCITM.[AKTNR]			AS [VCITM_AKTNR]
      ,VCITM.[ANZLIPOS]		AS [VCITM_ANZLIPOS]
      ,VCITM.[BRGEW]			AS [VCITM_BRGEW]
      ,VCITM.[BUKRS]			AS [VCITM_BUKRS]
      ,VCITM.[BWAPPLNM]		AS [VCITM_BWAPPLNM]
      ,VCITM.[BWVORG]			AS [VCITM_BWVORG]
      ,VCITM.[BZIRK]			AS [VCITM_BZIRK]
      ,VCITM.[CHARG]			AS [VCITM_CHARG]
      ,VCITM.[EAN11]			AS [VCITM_EAN11]
      ,VCITM.[ERDAT]			AS [VCITM_ERDAT]
      ,VCITM.[ERNAM]			AS [VCITM_ERNAM]
      ,VCITM.[ERZET]			AS [VCITM_ERZET]
      ,VCITM.[FAKSK]			AS [VCITM_FAKSK]
      ,VCITM.[FAKSP]			AS [VCITM_FAKSP]
      ,VCITM.[GEWEI]			AS [VCITM_GEWEI]
      ,VCITM.[GSBER]			AS [VCITM_GSBER]
      ,VCITM.[INCO1]			AS [VCITM_INCO1]
      ,VCITM.[INCO2]			AS [VCITM_INCO2]
      ,VCITM.[is_current]		AS [VCITM_is_current]
      ,VCITM.[is_deleted]		AS [VCITM_is_deleted]
      ,VCITM.[KDGRP]			AS [VCITM_KDGRP]
      ,VCITM.[KOMKZ]			AS [VCITM_KOMKZ]
      ,VCITM.[KOQUA]			AS [VCITM_KOQUA]
      ,VCITM.[KOSTA]			AS [VCITM_KOSTA]
      ,VCITM.[KUNAG]			AS [VCITM_KUNAG]
      ,VCITM.[KUNNR]			AS [VCITM_KUNNR]
      ,VCITM.[KVGR1]			AS [VCITM_KVGR1]
      ,VCITM.[KVGR2]			AS [VCITM_KVGR2]
      ,VCITM.[KVGR3]			AS [VCITM_KVGR3]
      ,VCITM.[KVGR4]			AS [VCITM_KVGR4]
      ,VCITM.[KVGR5]			AS [VCITM_KVGR5]
      ,VCITM.[KZVBR]			AS [VCITM_KZVBR]
      ,VCITM.[LFART]			AS [VCITM_LFART]
      ,VCITM.[LFDAT]			AS [VCITM_LFDAT]
      ,VCITM.[LFIMG]			AS [VCITM_LFIMG]
      ,VCITM.[LGMNG]			AS [VCITM_LGMNG]
      ,VCITM.[LGNUM]			AS [VCITM_LGNUM]
      ,VCITM.[LGORT]			AS [VCITM_LGORT]
      ,VCITM.[LGPLA]			AS [VCITM_LGPLA]
      ,VCITM.[LGTYP]			AS [VCITM_LGTYP]
      ,VCITM.[LIFNR]			AS [VCITM_LIFNR]
      ,VCITM.[LIFSK]			AS [VCITM_LIFSK]
      ,VCITM.[LSTEL]			AS [VCITM_LSTEL]
      ,VCITM.[MATKL]			AS [VCITM_MATKL]
      ,VCITM.[MATNR]			AS [VCITM_MATNR]
      ,VCITM.[MATWA]			AS [VCITM_MATWA]
      ,VCITM.[MCEX_APCAMPAIGN]AS [VCITM_MCEX_APCAMPAIGN]
      ,VCITM.[MEINS]			AS [VCITM_MEINS]
      ,VCITM.[MVGR1]			AS [VCITM_MVGR1]
      ,VCITM.[MVGR2]			AS [VCITM_MVGR2]
      ,VCITM.[MVGR3]			AS [VCITM_MVGR3]
      ,VCITM.[MVGR4]			AS [VCITM_MVGR4]
      ,VCITM.[MVGR5]			AS [VCITM_MVGR5]
      ,VCITM.[NTGEW]			AS [VCITM_NTGEW]
      ,VCITM.[PERIV]			AS [VCITM_PERIV]
      ,VCITM.[PKUNRE]			AS [VCITM_PKUNRE]
      ,VCITM.[PKUNRG]			AS [VCITM_PKUNRG]
      ,VCITM.[POSAR]			AS [VCITM_POSAR]
      ,VCITM.[PRODH]			AS [VCITM_PRODH]
      ,VCITM.[PS_POSID]		AS [VCITM_PS_POSID]
      ,VCITM.[PSPDNR]			AS [VCITM_PSPDNR]
      ,VCITM.[PSTYV]			AS [VCITM_PSTYV]
      ,VCITM.[PVRTNR]			AS [VCITM_PVRTNR]
      ,VCITM.[ROUTE]			AS [VCITM_ROUTE]
      ,VCITM.[SPARA]			AS [VCITM_SPARA]
      ,VCITM.[STADAT]			AS [VCITM_STADAT]
      ,VCITM.[UMVKN]			AS [VCITM_UMVKN]
      ,VCITM.[UMVKZ]			AS [VCITM_UMVKZ]
      ,VCITM.[VBEAF]			AS [VCITM_VBEAF]
      ,VCITM.[VBEAV]			AS [VCITM_VBEAV]
      ,VCITM.[VBTYP]			AS [VCITM_VBTYP]
      ,VCITM.[VDATU]			AS [VCITM_VDATU]
      ,VCITM.[VGBEL]			AS [VCITM_VGBEL]
      ,VCITM.[VGPOS]			AS [VCITM_VGPOS]
      ,VCITM.[VGTYP]			AS [VCITM_VGTYP]
      ,VCITM.[VKBUR]			AS [VCITM_VKBUR]
      ,VCITM.[VKGRP]			AS [VCITM_VKGRP]
      ,VCITM.[VKORG]			AS [VCITM_VKORG]
      ,VCITM.[VOLEH]			AS [VCITM_VOLEH]
      ,VCITM.[VOLUM]			AS [VCITM_VOLUM]
      ,VCITM.[VRKME]			AS [VCITM_VRKME]
      ,VCITM.[VSTEL]			AS [VCITM_VSTEL]
      ,VCITM.[VTWEG]			AS [VCITM_VTWEG]
      ,VCITM.[WA_DELAY_LF]	AS [VCITM_WA_DELAY_LF]
      ,VCITM.[WADAT]			AS [VCITM_WADAT]
      ,VCITM.[WADAT_IST]		AS [VCITM_WADAT_IST]
      ,VCITM.[WBSTA]			AS [VCITM_WBSTA]
      ,VCITM.[WERKS]			AS [VCITM_WERKS]
FROM [CT dwh 02 Data].[dbo].[tSAP2LIS_12_VCHDR] AS VCHDR WITH (NOLOCK)
INNER JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_12_VCITM] AS VCITM WITH (NOLOCK)
	ON VCHDR.VBELN = VCITM.VBELN
WHERE VCHDR.is_current = 1 and VCITM.is_current = 1
GO
/****** Object:  View [dbo].[vSAP_Validation_VDHDR_VDITM]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[vSAP_Validation_VDHDR_VDITM] AS

SELECT VDHDR.[row_id]			AS [VDHDR_row_id]
      ,VDHDR.[version]		AS [VDHDR_version]
      ,VDHDR.[valid_from]		AS [VDHDR_valid_from]
      ,VDHDR.[valid_to]		AS [VDHDR_valid_to]
      ,VDHDR.[VBELN]			AS [VDHDR_VBELN]
      ,VDHDR.[ANZFK]			AS [VDHDR_ANZFK]
      ,VDHDR.[BUKRS]			AS [VDHDR_BUKRS]
      ,VDHDR.[BZIRK]			AS [VDHDR_BZIRK]
      ,VDHDR.[ERDAT]			AS [VDHDR_ERDAT]
      ,VDHDR.[FKART]			AS [VDHDR_FKART]
      ,VDHDR.[FKDAT]			AS [VDHDR_FKDAT]
      ,VDHDR.[FKTYP]			AS [VDHDR_FKTYP]
      ,VDHDR.[HWAER]			AS [VDHDR_HWAER]
      ,VDHDR.[is_current]		AS [VDHDR_is_current]
      ,VDHDR.[is_deleted]		AS [VDHDR_is_deleted]
      ,VDHDR.[KDGRP]			AS [VDHDR_KDGRP]
      ,VDHDR.[KUNAG]			AS [VDHDR_KUNAG]
      ,VDHDR.[KUNRG]			AS [VDHDR_KUNRG]
      ,VDHDR.[KURRF]			AS [VDHDR_KURRF]
      ,VDHDR.[KURST]			AS [VDHDR_KURST]
      ,VDHDR.[PERIV]			AS [VDHDR_PERIV]
      ,VDHDR.[PVRTNR]			AS [VDHDR_PVRTNR]
      ,VDHDR.[STWAE]			AS [VDHDR_STWAE]
      ,VDHDR.[VBTYP]			AS [VDHDR_VBTYP]
      ,VDHDR.[VKORG]			AS [VDHDR_VKORG]
      ,VDHDR.[VTWEG]			AS [VDHDR_VTWEG]
      ,VDHDR.[WAERK]			AS [VDHDR_WAERK]
      ,VDHDR.[ZTERM]			AS [VDHDR_ZTERM]
	  ,VDITM.[row_id]							AS [VDITM_row_id]
      ,VDITM.[version]						AS [VDITM_version]
      ,VDITM.[valid_from]						AS [VDITM_valid_from]
      ,VDITM.[valid_to]						AS [VDITM_valid_to]
      ,VDITM.[POSNR]							AS [VDITM_POSNR]
      ,VDITM.[VBELN]							AS [VDITM_VBELN]
      ,VDITM.[AEDAT]							AS [VDITM_AEDAT]
      ,VDITM.[AKTNR]							AS [VDITM_AKTNR]
      ,VDITM.[ANZFKPOS]						AS [VDITM_ANZFKPOS]
      ,VDITM.[AUBEL]							AS [VDITM_AUBEL]
      ,VDITM.[AUPOS]							AS [VDITM_AUPOS]
      ,VDITM.[BONBA]							AS [VDITM_BONBA]
      ,VDITM.[BONUS]							AS [VDITM_BONUS]
      ,VDITM.[BRGEW]							AS [VDITM_BRGEW]
      ,VDITM.[BRTWR]							AS [VDITM_BRTWR]
      ,VDITM.[BUKRS]							AS [VDITM_BUKRS]
      ,VDITM.[BWAPPLNM]						AS [VDITM_BWAPPLNM]
      ,VDITM.[BWVORG]							AS [VDITM_BWVORG]
      ,VDITM.[BZIRK]							AS [VDITM_BZIRK]
      ,VDITM.[CHARG]							AS [VDITM_CHARG]
      ,VDITM.[EAN11]							AS [VDITM_EAN11]
      ,VDITM.[ERDAT]							AS [VDITM_ERDAT]
      ,VDITM.[FAREG]							AS [VDITM_FAREG]
      ,VDITM.[FBUDA]							AS [VDITM_FBUDA]
      ,VDITM.[FKART]							AS [VDITM_FKART]
      ,VDITM.[FKDAT]							AS [VDITM_FKDAT]
      ,VDITM.[FKIMG]							AS [VDITM_FKIMG]
      ,VDITM.[FKLMG]							AS [VDITM_FKLMG]
      ,VDITM.[FKTYP]							AS [VDITM_FKTYP]
      ,VDITM.[GEWEI]							AS [VDITM_GEWEI]
      ,VDITM.[HWAER]							AS [VDITM_HWAER]
      ,VDITM.[is_current]						AS [VDITM_is_current]
      ,VDITM.[is_deleted]						AS [VDITM_is_deleted]
      ,VDITM.[KDGRP]							AS [VDITM_KDGRP]
      ,VDITM.[KNUMA_AG]						AS [VDITM_KNUMA_AG]
      ,VDITM.[KOKRS]							AS [VDITM_KOKRS]
      ,VDITM.[KOSTL]							AS [VDITM_KOSTL]
      ,VDITM.[KUNAG]							AS [VDITM_KUNAG]
      ,VDITM.[KUNRG]							AS [VDITM_KUNRG]
      ,VDITM.[KURRF]							AS [VDITM_KURRF]
      ,VDITM.[KURSK]							AS [VDITM_KURSK]
      ,VDITM.[KURSK_DAT]						AS [VDITM_KURSK_DAT]
      ,VDITM.[KURST]							AS [VDITM_KURST]
      ,VDITM.[KVGR1]							AS [VDITM_KVGR1]
      ,VDITM.[KVGR2]							AS [VDITM_KVGR2]
      ,VDITM.[KVGR3]							AS [VDITM_KVGR3]
      ,VDITM.[KVGR4]							AS [VDITM_KVGR4]
      ,VDITM.[KVGR5]							AS [VDITM_KVGR5]
      ,VDITM.[KZWI1]							AS [VDITM_KZWI1]
      ,VDITM.[KZWI2]							AS [VDITM_KZWI2]
      ,VDITM.[KZWI3]							AS [VDITM_KZWI3]
      ,VDITM.[KZWI4]							AS [VDITM_KZWI4]
      ,VDITM.[KZWI5]							AS [VDITM_KZWI5]
      ,VDITM.[KZWI6]							AS [VDITM_KZWI6]
      ,VDITM.[LGORT]							AS [VDITM_LGORT]
      ,VDITM.[LMENG]							AS [VDITM_LMENG]
      ,VDITM.[MATKL]							AS [VDITM_MATKL]
      ,VDITM.[MATNR]							AS [VDITM_MATNR]
      ,VDITM.[MATWA]							AS [VDITM_MATWA]
      ,VDITM.[MCEX_APCAMPAIGN]				AS [VDITM_MCEX_APCAMPAIGN]
      ,VDITM.[MEINS]							AS [VDITM_MEINS]
      ,VDITM.[MVGR1]							AS [VDITM_MVGR1]
      ,VDITM.[MVGR2]							AS [VDITM_MVGR2]
      ,VDITM.[MVGR3]							AS [VDITM_MVGR3]
      ,VDITM.[MVGR4]							AS [VDITM_MVGR4]
      ,VDITM.[MVGR5]							AS [VDITM_MVGR5]
      ,VDITM.[MWSBP]							AS [VDITM_MWSBP]
      ,VDITM.[NETWR]							AS [VDITM_NETWR]
      ,VDITM.[NTGEW]							AS [VDITM_NTGEW]
      ,VDITM.[PERIV]							AS [VDITM_PERIV]
      ,VDITM.[PKUNRE]							AS [VDITM_PKUNRE]
      ,VDITM.[PKUNWE]							AS [VDITM_PKUNWE]
      ,VDITM.[POSAR]							AS [VDITM_POSAR]
      ,VDITM.[PRODH]							AS [VDITM_PRODH]
      ,VDITM.[PROVG]							AS [VDITM_PROVG]
      ,VDITM.[PRSDT]							AS [VDITM_PRSDT]
      ,VDITM.[PS_POSID]						AS [VDITM_PS_POSID]
      ,VDITM.[PSTYV]							AS [VDITM_PSTYV]
      ,VDITM.[PVRTNR]							AS [VDITM_PVRTNR]
      ,VDITM.[SKFBP]							AS [VDITM_SKFBP]
      ,VDITM.[SMENG]							AS [VDITM_SMENG]
      ,VDITM.[SPARA]							AS [VDITM_SPARA]
      ,VDITM.[SPART]							AS [VDITM_SPART]
      ,VDITM.[STADAT]							AS [VDITM_STADAT]
      ,VDITM.[STCUR]							AS [VDITM_STCUR]
      ,VDITM.[STWAE]							AS [VDITM_STWAE]
      ,VDITM.[UMVKN]							AS [VDITM_UMVKN]
      ,VDITM.[UMVKZ]							AS [VDITM_UMVKZ]
      ,VDITM.[VBTYP]							AS [VDITM_VBTYP]
      ,VDITM.[VDATU]							AS [VDITM_VDATU]
      ,VDITM.[VGBEL]							AS [VDITM_VGBEL]
      ,VDITM.[VGPOS]							AS [VDITM_VGPOS]
      ,VDITM.[VKBUR]							AS [VDITM_VKBUR]
      ,VDITM.[VKGRP]							AS [VDITM_VKGRP]
      ,VDITM.[VKORG]							AS [VDITM_VKORG]
      ,VDITM.[VOLEH]							AS [VDITM_VOLEH]
      ,VDITM.[VOLUM]							AS [VDITM_VOLUM]
      ,VDITM.[VRKME]							AS [VDITM_VRKME]
      ,VDITM.[VSTEL]							AS [VDITM_VSTEL]
      ,VDITM.[VTWEG]							AS [VDITM_VTWEG]
      ,VDITM.[WAERK]							AS [VDITM_WAERK]
      ,VDITM.[WAVWR]							AS [VDITM_WAVWR]
      ,VDITM.[WERKS]							AS [VDITM_WERKS]
	  	,VDKON.[row_id]							AS [VDKON_row_id]
      ,VDKON.[version]						AS [VDKON_version]
      ,VDKON.[valid_from]						AS [VDKON_valid_from]
      ,VDKON.[valid_to]						AS [VDKON_valid_to]
      ,VDKON.[KSCHL]							AS [VDKON_KSCHL]
      ,VDKON.[POSNR]							AS [VDKON_POSNR]
      ,VDKON.[VBELN]							AS [VDKON_VBELN]
      ,VDKON.[AEDAT]							AS [VDKON_AEDAT]
      ,VDKON.[AKTNR]							AS [VDKON_AKTNR]
      ,VDKON.[AUBEL]							AS [VDKON_AUBEL]
      ,VDKON.[AUPOS]							AS [VDKON_AUPOS]
      ,VDKON.[BONUS]							AS [VDKON_BONUS]
      ,VDKON.[BUKRS]							AS [VDKON_BUKRS]
      ,VDKON.[BWAPPLNM]						AS [VDKON_BWAPPLNM]
      ,VDKON.[BWVORG]							AS [VDKON_BWVORG]
      ,VDKON.[BZIRK]							AS [VDKON_BZIRK]
      ,VDKON.[EAN11]							AS [VDKON_EAN11]
      ,VDKON.[ERDAT]							AS [VDKON_ERDAT]
      ,VDKON.[ERNAM]							AS [VDKON_ERNAM]
      ,VDKON.[FBUDA]							AS [VDKON_FBUDA]
      ,VDKON.[FKART]							AS [VDKON_FKART]
      ,VDKON.[FKDAT]							AS [VDKON_FKDAT]
      ,VDKON.[FKIMG]							AS [VDKON_FKIMG]
      ,VDKON.[FKTYP]							AS [VDKON_FKTYP]
      ,VDKON.[HWAER]							AS [VDKON_HWAER]
      ,VDKON.[is_current]						AS [VDKON_is_current]
      ,VDKON.[is_deleted]						AS [VDKON_is_deleted]
      ,VDKON.[KAPPL]							AS [VDKON_KAPPL]
      ,VDKON.[KDGRP]							AS [VDKON_KDGRP]
      ,VDKON.[KHERK]							AS [VDKON_KHERK]
      ,VDKON.[KINAK]							AS [VDKON_KINAK]
      ,VDKON.[KNTYP]							AS [VDKON_KNTYP]
      ,VDKON.[KOAID]							AS [VDKON_KOAID]
      ,VDKON.[KOKRS]							AS [VDKON_KOKRS]
      ,VDKON.[KOSTL]							AS [VDKON_KOSTL]
      ,VDKON.[KSTAT]							AS [VDKON_KSTAT]
      ,VDKON.[KUNAG]							AS [VDKON_KUNAG]
      ,VDKON.[KUNRG]							AS [VDKON_KUNRG]
      ,VDKON.[KURRF]							AS [VDKON_KURRF]
      ,VDKON.[KURSK]							AS [VDKON_KURSK]
      ,VDKON.[KURSK_DAT]						AS [VDKON_KURSK_DAT]
      ,VDKON.[KVARC]							AS [VDKON_KVARC]
      ,VDKON.[KVGR1]							AS [VDKON_KVGR1]
      ,VDKON.[KVGR2]							AS [VDKON_KVGR2]
      ,VDKON.[KVGR3]							AS [VDKON_KVGR3]
      ,VDKON.[KVGR4]							AS [VDKON_KVGR4]
      ,VDKON.[KVGR5]							AS [VDKON_KVGR5]
      ,VDKON.[KWERT]							AS [VDKON_KWERT]
      ,VDKON.[LOGSYS]							AS [VDKON_LOGSYS]
      ,VDKON.[MATKL]							AS [VDKON_MATKL]
      ,VDKON.[MATNR]							AS [VDKON_MATNR]
      ,VDKON.[MATWA]							AS [VDKON_MATWA]
      ,VDKON.[MVGR1]							AS [VDKON_MVGR1]
      ,VDKON.[MVGR2]							AS [VDKON_MVGR2]
      ,VDKON.[MVGR3]							AS [VDKON_MVGR3]
      ,VDKON.[MVGR4]							AS [VDKON_MVGR4]
      ,VDKON.[MVGR5]							AS [VDKON_MVGR5]
      ,VDKON.[PERIV]							AS [VDKON_PERIV]
      ,VDKON.[PKUNRE]							AS [VDKON_PKUNRE]
      ,VDKON.[PKUNWE]							AS [VDKON_PKUNWE]
      ,VDKON.[POSAR]							AS [VDKON_POSAR]
      ,VDKON.[PRODH]							AS [VDKON_PRODH]
      ,VDKON.[PROVG]							AS [VDKON_PROVG]
      ,VDKON.[PRSDT]							AS [VDKON_PRSDT]
      ,VDKON.[PS_POSID]						AS [VDKON_PS_POSID]
      ,VDKON.[PSPDNR]							AS [VDKON_PSPDNR]
      ,VDKON.[PSTYV]							AS [VDKON_PSTYV]
      ,VDKON.[PVRTNR]							AS [VDKON_PVRTNR]
      ,VDKON.[SPARA]							AS [VDKON_SPARA]
      ,VDKON.[SPART]							AS [VDKON_SPART]
      ,VDKON.[STADAT]							AS [VDKON_STADAT]
      ,VDKON.[STUNR]							AS [VDKON_STUNR]
      ,VDKON.[STWAE]							AS [VDKON_STWAE]
      ,VDKON.[VARCOND]						AS [VDKON_VARCOND]
      ,VDKON.[VBTYP]							AS [VDKON_VBTYP]
      ,VDKON.[VGBEL]							AS [VDKON_VGBEL]
      ,VDKON.[VGPOS]							AS [VDKON_VGPOS]
      ,VDKON.[VKBUR]							AS [VDKON_VKBUR]
      ,VDKON.[VKGRP]							AS [VDKON_VKGRP]
      ,VDKON.[VKORG]							AS [VDKON_VKORG]
      ,VDKON.[VRKME]							AS [VDKON_VRKME]
      ,VDKON.[VTWEG]							AS [VDKON_VTWEG]
      ,VDKON.[WAERK]							AS [VDKON_WAERK]
      ,VDKON.[ZAEHK]							AS [VDKON_ZAEHK]
  FROM [CT dwh 02 Data].[dbo].[tSAP2LIS_13_VDHDR] AS VDHDR WITH (NOLOCK)
  INNER JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_13_VDITM] AS VDITM WITH (NOLOCK)
	ON VDHDR.VBELN = VDITM.VBELN
	LEFT JOIN [CT dwh 02 Data].[dbo].[tSAP2LIS_13_VDKON] AS VDKON WITH (NOLOCK)
   ON VDHDR.VBELN = VDKON.VBELN and VDITM.POSNR = VDKON.POSNR and VDKON.is_current = 1

   WHERE VDHDR.is_current = 1 and VDITM.is_current = 1 
GO
/****** Object:  View [plentymarket].[vASIN_ParentASIN_hierarchy]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [plentymarket].[vASIN_ParentASIN_hierarchy]
as
(
SELECT distinct
	child.BBGArtNum
	,[ASIN] = child.[ASIN]
	,Parent_ASIN = parent.[ASIN]
	,SKU = child.VariationSkusku
	,CountryId = child.[VariationMarketIdentNumberCountryIDDE]
	,ActualStateUpToDate = child.mdinsertdate
	--,child.IsActive
	--,child.VariationMarketIdentNumberIDDE
	--,child.VariationId
from [CT dwh 02 Data].plentymarket.tPMAmazonListings child
left join [CT dwh 02 Data].plentymarket.tPMAmazonListings parent on child.ParentVariationId = parent.ItemID
where 1=1 and child.asin !=parent.ASIN
	

)
GO
/****** Object:  View [wilson].[vReturnSummary]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [wilson].[vReturnSummary]
as
(


Select
			RO.[ReturnWarehouseId] as ReturnSiteId, ---- Dimension [tDimReturnSite]
			Rw.[value] as ReturnSite,
			RO.[ReturnOrderId] as ReturnNumber, --- already in fact table
			RO.[ArticleNumber] as ItemNo,
			oi.OrderPosition as OrderPosition,
			RO.[ReturnUserDescription] as CustomerFeedback,--- already exists
			cast(format(RO.[CreatedOn] ,'yyyyMMdd') as int) as RegistrationDate,  --- already exists  (make it a fk to dimcalendar)
			--RO.[ReturnOrderId] as ReturnSource, --- already exists but with different purpose(RetourenursprungId); create new one/rethink the field; is this really the retiurnorderid intended? 
			RO.[ReturnUserDescription] as ReturnErrorInfo, --alreaddy exists
			1 as ReturnQuantity,
			cast(format(MRR.[CreatedOn] ,'yyyyMMdd') as int) as ReturnDate   , --- transactiondate??
			MRR.[SerialNumber]      , --- already exist
			MRR.[CreatedBy] as Creator,-- already exist;link to tDimUser ;DimCreatorUserID
			ror.[Value] as ReturnReason, -- already exists (tdimreturnReason)
			RR.[Code] as ReturnCode1, -- already exists
			oi.[Condition] as StoragePlace, -- already exists (tDimStoragePlace)
			TCR.[Value] as WorkshopStatus, -- already exists [sales].[tDimWorkshopStatus]
			MTC.[TechnicianComments] as WorkshopInfo,-- already exists
			INSCC.[Code] as Class,-- already exists
			MAT.RMA, -- already exists
			INSC.[Value] as AccountingTransaction
			,INSCC.Value as InspectionOutcome
			,o.ExpiryDays      -- for if return was made inside or outside cooling period 
			,o.CoolingOffExpirationDate  -- for if return was made inside or outside cooling period 
			, Case When ro.valid_from > OI.valid_from And ro.valid_from > O.valid_from And ro.valid_from > isnull(MRR.valid_from,getdate()-30) Then ro.valid_from
              When  OI.valid_from > ro.valid_from And OI.valid_from > O.valid_from And OI.valid_from > isnull(MRR.valid_from,getdate()-30) Then OI.valid_from
			  When  O.valid_from > ro.valid_from And O.valid_from > OI.valid_from And O.valid_from > isnull(MRR.valid_from,getdate()-30) Then O.valid_from
			  When  MRR.valid_from > ro.valid_from And MRR.valid_from > OI.valid_from And MRR.valid_from > O.valid_from Then MRR.valid_from
    Else ro.valid_from
	End As Valid_from
		FROM  [CT dwh 02 Data].[wilson].[tReturnOrder] ro 
		INNER JOIN [CT dwh 02 Data].[wilson].[tOrderItem] as OI on OI.id = RO.OrderItemId and oi.is_current = 1
		INNER JOIN [CT dwh 02 Data].[wilson].[tOrder] as O on o.Id = oi.OrderId and o.is_current = 1
		left join 
				(
					select *, rank() over(partition by returnorderid order by id desc) LastRet  
					from[CT dwh 02 Data].[wilson].[tMaskReceiveReturn]  with(nolock) where is_current = 1
				)as MRR on MRR.ReturnOrderId = RO.Id and MRR.LastRet = 1
		left join [CT dwh 02 Data].[wilson].[tReturnRequestConfig] as RRC on RRC.ID = RO.ReturnRequestConfigId and RRC.is_current = 1 
		left join [CT dwh 02 Data].[wilson].[tReturnOrderReason] as ROR on ROR.Id = RO.ReturnOrderId and ROR.is_current = 1
		left join [CT dwh 02 Data].[wilson].[tReturnReason] as RR on rr.id = rrc.ReturnReasonId and RR.is_current = 1
		left join (
					Select *, rank() over(partition by returnorderid order by id desc) LastRet 
					from [CT dwh 02 Data].[wilson].[tMaskTechnicalCheck] with(nolock) where is_current = 1
		)	as MTC on MTC.ReturnOrderId = RO.Id  and MTC.LastRet = 1
		left join [CT dwh 02 Data].[wilson].[tTechnicalCheckResult] as TCR on TCR.Id = MTC.TechnicalCheckResultId and TCR.is_current = 1
		left join (
				Select *,rank() over(partition by returnorderid order by id desc) LastRet from [CT dwh 02 Data].[wilson].[tReturnInspection] with(nolock)
				where is_current = 1
			)as INS on INS.ReturnOrderId = RO.Id and INS.LastRet = 1
		left join [CT dwh 02 Data].[wilson].[tReturnInspectionConditionCode] as INSCC on INS.ReturnInspectionConditionCodeId = INSCC.ID and INSCC.is_current = 1
		left join [CT dwh 02 Data].[wilson].[tMaterial] as MAT on MAT.ArticleNumber = oi.ArticleNumber and MAT.is_current = 1
		left join [CT dwh 02 Data].[wilson].[tReturnInspectionCompensation] as INSC on INS.ReturnInspectionCompensationId = INSC.ID and INSC.is_current = 1
		left join [CT dwh 02 Data].[wilson].[tReturnWarehouse] as rw on rw.id = ro.ReturnWarehouseId and rw.is_current = 1






)
GO
/****** Object:  StoredProcedure [dbo].[spCheckForDuplicates]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spCheckForDuplicates] AS
BEGIN
-- ============================================================================
-- Author:			Tim Steska
-- Create date:		14.03.2024
-- Title:			Check for Duplicates
-- Description:		Checks for duplicates in Data Layer and writes result to 
--					the table [CT dwh 00 Meta].[dbo].tDataLayerCheckDuplicates.
--					Checked tables are taken from the metadata injection tables
--					and inserted manually (insert new tables under 'other').
--					The procdure is triggered from VisualCron and an alert is
--					there if duplicates are found.
-- Related ticket:	DWH-1799
-- ============================================================================

	DECLARE @tablelist TABLE (
		q_schema NVARCHAR(300),
		q_table NVARCHAR(300),
		q_key NVARCHAR(300),
		q_current_column NVARCHAR(300)
	)

	-- oxid
	INSERT INTO @tablelist 
	SELECT TargetSchema, TargetTable, PKField, 'IsCurrent'
	FROM [CT dwh 00 Meta].[dbo].[tPentahooxidTableMergeConfig]
	WHERE TargetDbName = 'CT dwh 02 Data'

	-- sales, purcahsing, finance
	INSERT INTO @tablelist 
	SELECT TargetSchema, TargetTable, PrimaryKey, 'is_current'
	FROM [CT dwh 00 Meta].[dbo].[tPentahoTableMergeXtractorConfig]
	WHERE TargetDbName = 'CT dwh 02 Data'

	-- other
	INSERT INTO @tablelist (q_schema, q_table, q_key, q_current_column)
	VALUES 
	('forecast', 'tCountryChannelAdjustment', 'ItemNo,Year,Month,Channel,Country', 'is_current'),
	('forecast', 'tPlanPriceCountryChannelAdjustments', 'ItemNo,Year,Month,Channel,Country', 'is_current'),
	('dbo', 'tAmzFbaMyiUnsuppressedInventoryData', 'Marketplace,seller_id,asin,sku', 'valid_to')


	DECLARE @schemaname NVARCHAR(300), @tablename NVARCHAR(300), @primarykey NVARCHAR(300), @currentcol NVARCHAR(300)
	DECLARE @sql NVARCHAR(4000) = '', @returndup INT = 1
	DECLARE @msg NVARCHAR(4000) = ''
	DECLARE table_queue CURSOR FOR
		SELECT q_schema, q_table, q_key, q_current_column
		FROM @tablelist

	OPEN table_queue

	FETCH NEXT FROM table_queue
	INTO @schemaname, @tablename, @primarykey, @currentcol

	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SET @sql = '
			IF EXISTS (
				SELECT 1/0
				FROM [CT dwh 02 Data].INFORMATION_SCHEMA.tables
				WHERE TABLE_SCHEMA = ''' + @schemaname + '''
					AND TABLE_NAME = ''' + @tablename + '''
				)
			BEGIN
				SELECT @returndup = IIF(SUM(cnt-1) > 0,
										SUM(cnt-1),
										0)
				FROM (
					SELECT ' + @primarykey + ', COUNT(1) AS cnt
					FROM [CT dwh 02 Data].' + @schemaname + '.' + @tablename + ' WITH (NOLOCK)
					WHERE ' + @currentcol + '=' +
						CASE WHEN @currentcol = 'valid_to' THEN '''2200-01-01''' ELSE '1' END + '
					GROUP BY ' + @primarykey +'
					HAVING COUNT(1)>1
				) AS _
			END
			ELSE BEGIN
				SELECT @returndup = NULL
			END
			'

		SET @msg = CONVERT(varchar, SYSDATETIME(), 121) + 
			' --- Starting duplicate search for ' + @schemaname + '.' + @tablename
		RAISERROR (@msg, 10, 1) WITH NOWAIT

		EXECUTE sp_executesql @sql, N'@returndup INT OUTPUT', @returndup = @returndup OUTPUT
		
		IF @returndup IS NOT NULL
		BEGIN
			SET @msg = CONVERT(varchar, SYSDATETIME(), 121) + 
				' --- ' + cast(@returndup AS varchar) + ' duplicates found for ' + @schemaname + '.' + @tablename
		END
		ELSE BEGIN
			SET @msg = CONVERT(varchar, SYSDATETIME(), 121) + 
				' --- Table not found: ' + @schemaname + '.' + @tablename
		END
		RAISERROR (@msg, 10, 1) WITH NOWAIT

		IF NOT EXISTS (SELECT 1/0 FROM [CT dwh 00 Meta].[dbo].tDataLayerCheckDuplicates
				   WHERE SchemaName = @schemaname AND TableName = @tablename)
		BEGIN
			INSERT INTO [CT dwh 00 Meta].[dbo].tDataLayerCheckDuplicates (SchemaName, TableName)
			VALUES (@schemaname, @tablename)
		END
		UPDATE [CT dwh 00 Meta].[dbo].tDataLayerCheckDuplicates
		SET PrimaryKey = @primarykey, Duplicates = @returndup, LastChecked = GETDATE()
		WHERE SchemaName = @schemaname AND TableName = @tablename


		FETCH NEXT FROM table_queue
		INTO @schemaname, @tablename, @primarykey, @currentcol
	END

	CLOSE table_queue
	DEALLOCATE table_queue
	
	
END
GO
/****** Object:  StoredProcedure [dbo].[spFactAmzProductReviews]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spFactAmzProductReviews]
AS BEGIN
	SET NOCOUNT OFF

	MERGE [CT dwh 03 Intelligence].[dbo].[tFactAmzProductReviews] AS t 
	USING [CT dwh 02 Data].[dbo].[tAmzProductReviews] AS s ON 
		(
			t.[Id]=s.[Id]
		) 
	WHEN MATCHED 
		AND t.[Id]					<>		s.[Id] 
		OR	t.[ASIN]				<>		s.[ASIN] 
		OR	t.[Url]					<>		s.[Url] 
		OR	t.[Country]				<>		s.[Country] 
		OR	t.[TotalReviews]		<>		s.[TotalReviews] 
		OR	t.[ReviewFiveStars]		<>		s.[ReviewFiveStars] 
		OR	t.[ReviewFourStars]		<>		s.[ReviewFourStars] 
		OR	t.[ReviewThreeStars]	<>		s.[ReviewThreeStars] 
		OR	t.[ReviewTwoStars]		<>		s.[ReviewTwoStars] 
		OR	t.[ReviewOneStars]		<>		s.[ReviewOneStars] 
		OR	t.[RunTime]				<>		s.[RunTime] 
		OR	t.[CreatedAt]			<>		s.[CreatedAt] 
		OR	t.[LoadedAt]			<>		s.[LoadedAt] 
		OR	t.[DataIssue]			<>		s.[DataIssue] 
		OR	t.[mdLogId]				<>		s.[mdLogId] 
		OR	t.[mdInsertDate]		<>		s.[mdInsertDate] 
	THEN UPDATE SET
		--	t.[Id]					=		s.[Id],
			t.[ASIN]				=		s.[ASIN]
		,	t.[Url]					=		s.[Url]
		,	t.[Country]				=		s.[Country]
		,	t.[TotalReviews]		=		s.[TotalReviews]
		,	t.[ReviewFiveStars]		=		s.[ReviewFiveStars]
		,	t.[ReviewFourStars]		=		s.[ReviewFourStars]
		,	t.[ReviewThreeStars]	=		s.[ReviewThreeStars]
		,	t.[ReviewTwoStars]		=		s.[ReviewTwoStars]
		,	t.[ReviewOneStars]		=		s.[ReviewOneStars]
		,	t.[RunTime]				=		s.[RunTime]
		,	t.[CreatedAt]			=		s.[CreatedAt]
		,	t.[LoadedAt]			=		s.[LoadedAt]
		,	t.[DataIssue]			=		s.[DataIssue]
		,	t.[mdLogId]				=		s.[mdLogId]
		,	t.[mdInsertDate]		=		s.[mdInsertDate] 
	WHEN NOT MATCHED BY TARGET THEN 
	INSERT (
		[Id]
		,[ASIN]
		,[Url]
		,[Country]
		,[TotalReviews]
		,[ReviewFiveStars]
		,[ReviewFourStars]
		,[ReviewThreeStars]
		,[ReviewTwoStars]
		,[ReviewOneStars]
		,[RunTime]
		,[CreatedAt]
		,[LoadedAt]
		,[DataIssue]
		,[mdLogId]
		,[mdInsertDate]
	) 
	VALUES 
	(
		s.[Id]
		,s.[ASIN]
		,s.[Url]
		,s.[Country]
		,s.[TotalReviews]
		,s.[ReviewFiveStars]
		,s.[ReviewFourStars]
		,s.[ReviewThreeStars]
		,s.[ReviewTwoStars]
		,s.[ReviewOneStars]
		,s.[RunTime]
		,s.[CreatedAt]
		,s.[LoadedAt]
		,s.[DataIssue]
		,s.[mdLogId]
		,s.[mdInsertDate]
	);
END
GO
/****** Object:  StoredProcedure [dbo].[spFactDwhHistorischerLagerbestand]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spFactDwhHistorischerLagerbestand]
AS


IF  EXISTS (SELECT * FROM [CT dwh 03 Intelligence].sys.objects 
WHERE object_id = OBJECT_ID(N'[CT dwh 03 Intelligence].dbo.tFactDwhHistorischerLagerbestand')  
AND type in ('U'))
DROP TABLE [CT dwh 03 Intelligence].dbo.tFactDwhHistorischerLagerbestand;


with 
Stock as
(
select 
  cast (convert(char(10), datum, 112) as INT) as [DateId]
, Datum as [Date]
, Artikelnummer
, sum(isnull(Bestand,0)) as [Remaining Stock]
from 
[dbo].[tDwhHistorischerLagerbestand]
WHERE  PlatzID in (670,865)
group by cast (convert(char(10), datum, 112) as INT), Datum, Artikelnummer
), 
StockFBA as 
(
select 
cast (convert(char(10), datum, 112) as INT) as [DateID]
, Datum as [Date]
, Artikelnummer
, sum(isnull([FBA_Available_and_inTransit_Stock],0)) as [Remaining Stock FBA]
from 
[dbo].[tDwhHistorischerLagerbestandFBA]
group by cast (convert(char(10), datum, 112) as INT), Datum, Artikelnummer
)
select 
s.Date, s.DateId, s.Artikelnummer, s.[Remaining Stock], f.[Remaining Stock FBA], 0 as [Expected Days]
INTO [CT dwh 03 Intelligence].dbo.tFactDwhHistorischerLagerbestand
from 
Stock s
left join StockFBA f on s.Date = f.Date and s.Artikelnummer = f.Artikelnummer





GO
/****** Object:  StoredProcedure [dbo].[spFactGADeviceCategoryReport]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spFactGADeviceCategoryReport] 
AS

IF EXISTS (SELECT * FROM [CT dwh 03 Intelligence].sys.objects WHERE object_id = OBJECT_ID(N'[CT dwh 03 Intelligence].dbo.tFactGADeviceCategoryReport') AND type in ('U'))
  DROP TABLE [CT dwh 03 Intelligence].dbo.tFactGADeviceCategoryReport;

SELECT
  s.WebshopCode, 
  --ISNULL(CAST( CONVERT(CHAR(10), CONVERT(datetime,r.[date],121), 112) AS INT), 20000101) [DateId],
  CONVERT(CHAR(10), [date], 121) AS DateId,
  device_category,
  CONVERT(INT, [sessions]) AS [Sessions],
  CONVERT(NUMERIC(18, 2), CAST(REPLACE(Pnewsessions, ',', '.') AS FLOAT)) AS [% New Sessions],
  CONVERT(INT, newUsers) AS [New Users],
  CONVERT(NUMERIC(18, 2), CAST(REPLACE(bounceRate, ',', '.') AS FLOAT)) AS [Bounce Rate],
  CONVERT(NUMERIC(18, 2), CAST(REPLACE(pagesessions, ',', '.') AS FLOAT)) AS [Page/Sessions],
  CONVERT(NUMERIC(18, 2), CAST(REPLACE([avg.sessionDuration], ',', '.') AS FLOAT)) AS [Avg. session duration],
  CONVERT(INT, transactions) AS [Transactions],
  CONVERT(NUMERIC(18, 2), CAST(REPLACE([CR], ',', '.') AS FLOAT)) AS [CR],
  CONVERT(NUMERIC(18, 2), CAST(REPLACE([Revenue], ',', '.') AS FLOAT)) AS [Revenue]
INTO [CT dwh 03 Intelligence].dbo.tFactGADeviceCategoryReport
FROM [dbo].[tGADeviceCategoryReport] r
  LEFT JOIN tGAWebShopMetadata s
    ON r.gaviewid = s.GAViewId
GO
/****** Object:  StoredProcedure [dbo].[spFactGARMobileDeviceCreate]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spFactGARMobileDeviceCreate] 
AS

IF  EXISTS (SELECT * FROM [CT dwh 03 Intelligence].sys.objects 
WHERE object_id = OBJECT_ID(N'[CT dwh 03 Intelligence].dbo.tFactGARMobileDevice')  
AND type in ('U'))
DROP TABLE [CT dwh 03 Intelligence].dbo.tFactGARMobileDevice;


WITH MainQuery AS
(
select 
ISNULL(CAST(CONVERT(CHAR(10),md.[date],112) AS INT), 20000101) [DateId], 
md.date, 
ISNULL(b.DeviceBrandingId, 1)  as DeviceBrandingId, 
ISNULL(m.DeviceModelId, 1)  as DeviceModelId, 
ISNULL(ins.DeviceInputSelectorId, 1)  as DeviceInputSelectorId, 
ISNULL(mn.DeviceMarketingNameId, 1)  as DeviceMarketingNameId, 
ISNULL(ws.WebshopId, 1)  as WebshopID
,CONVERT(INT, md.Users) as Users 
,CONVERT(INT, md.NewUsers) as NewUsers 
,CONVERT(INT, md.[Sessions]) as [Sessions] 
,CONVERT(INT, md.[bounces]) as [bounces]
,CONVERT(INT, md.[SessionDuration]) as [SessionDuration]  
,CONVERT(INT, md.[Hits]) as [Hits]  
,CONVERT(INT, md.[OrganicSearches]) as [OrganicSearches]  
, 0 as Transactions
from tGAMobileDevice md
left join tGAWebShopMetadata ws on ws.GAViewId = md.gaviewid
left join tGADeviceBranding b on b.DeviceBranding_name = md.mobdevice_branding
left join tGADeviceModel m on m.DeviceModel_name = md.mobdevice_model
left join tGADeviceInputSelector ins on ins.DeviceInputSelector_name = md.mobdevice_inputselector
left join tGADeviceMarketingName mn on mn.DeviceMarketingName_name = md.mobdevice_mktname
UNION ALL
select 
ISNULL(CAST(CONVERT(CHAR(10),md.[date],112) AS INT), 20000101) [DateId], 
md.date, 
ISNULL(b.DeviceBrandingId, 1)  as DeviceBrandingId, 
ISNULL(m.DeviceModelId, 1)  as DeviceModelId, 
ISNULL(ins.DeviceInputSelectorId, 1)  as DeviceInputSelectorId, 
ISNULL(mn.DeviceMarketingNameId, 1)  as DeviceMarketingNameId, 
ISNULL(ws.WebshopId, 1)  as WebshopID
,CONVERT(INT, md.Users) as Users 
,CONVERT(INT, md.NewUsers) as NewUsers 
,CONVERT(INT, md.[Sessions]) as [Sessions] 
,CONVERT(INT, md.[bounces]) as [bounces]
,CONVERT(INT, md.[SessionDuration]) as [SessionDuration]  
,CONVERT(INT, md.[Hits]) as [Hits]  
,CONVERT(INT, md.[OrganicSearches]) as [OrganicSearches]  
, 1 as Transactions
from tGAMobileDeviceTR md
left join tGAWebShopMetadata ws on ws.GAViewId = md.gaviewid
left join tGADeviceBranding b on b.DeviceBranding_name = md.mobdevice_branding
left join tGADeviceModel m on m.DeviceModel_name = md.mobdevice_model
left join tGADeviceInputSelector ins on ins.DeviceInputSelector_name = md.mobdevice_inputselector
left join tGADeviceMarketingName mn on mn.DeviceMarketingName_name = md.mobdevice_mktname
)
select 
[DateId], 
[Date], 
DeviceBrandingId, 
DeviceModelId, 
DeviceInputSelectorId
DeviceMarketingNameId, 
WebshopID, 
sum(Users) as Users, 
sum(NewUsers) as NewUsers, 
sum(Sessions) as Sessions, 
sum(bounces) as Bounces, 
sum(SessionDuration) as SessionDuration, 
sum(Hits) as Hits, 
sum(OrganicSearches) as OrganicSearches,
sum(Transactions) as Transactions
INTO [CT dwh 03 Intelligence].dbo.tFactGARMobileDevice
from MainQuery
group by 
[DateId], 
[Date], 
DeviceBrandingId, 
DeviceModelId, 
DeviceInputSelectorId,
DeviceMarketingNameId, 
WebshopID










 
 

 


 




 
GO
/****** Object:  StoredProcedure [dbo].[spFactGARPlatformCreate]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spFactGARPlatformCreate] 
AS

IF  EXISTS (SELECT * FROM [CT dwh 03 Intelligence].sys.objects 
WHERE object_id = OBJECT_ID(N'[CT dwh 03 Intelligence].dbo.tFactGARPlatform')  
AND type in ('U'))
DROP TABLE [CT dwh 03 Intelligence].dbo.tFactGARPlatform;


WITH MainQuery AS
(
select 
ISNULL(CAST(CONVERT(CHAR(10),p.[date],112) AS INT), 20000101) [DateId], 
p.date as Date, 
ISNULL(b.BrowserId, 1)  as BrowserId, 
ISNULL(s.OSystemId, 1)  as OSystemId, 
ISNULL(ws.WebshopId, 1)  as WebshopID
,CONVERT(INT, p.Users) as Users 
,CONVERT(INT, p.NewUsers) as NewUsers 
,CONVERT(INT, p.[Sessions]) as [Sessions] 
,CONVERT(INT, p.[bounces]) as [bounces]
,CONVERT(INT, p.[SessionDuration]) as [SessionDuration]  
,CONVERT(INT, p.[Hits]) as [Hits]  
,CONVERT(INT, p.[OrganicSearches]) as [OrganicSearches]  
, 0 as Transactions
from tGAPLatform p
left join tGAWebShopMetadata ws on ws.GAViewId = p.gaviewid
left join tGABrowser b on b.Browser_name = p.browser
left join tGAOSystem s on s.OSystem_name = p.opersystem
UNION ALL
select 
ISNULL(CAST(CONVERT(CHAR(10),pt.[date],112) AS INT), 20000101) [DateId], 
pt.date as Date, 
ISNULL(b.BrowserId, 1)  as BrowserId, 
ISNULL(s.OSystemId, 1)  as OSystemId, 
ISNULL(ws.WebshopId, 1)  as WebshopID 
,CONVERT(INT, pt.Users) as Users 
,CONVERT(INT, pt.NewUsers) as NewUsers 
,CONVERT(INT, pt.[Sessions]) as [Sessions] 
,CONVERT(INT, pt.[bounces]) as [bounces]
,CONVERT(INT, pt.[SessionDuration]) as [SessionDuration]  
,CONVERT(INT, pt.[Hits]) as [Hits]  
,CONVERT(INT, pt.[OrganicSearches]) as [OrganicSearches] 
, 1 as Transactions 
from tGAPLatformTR pt
left join tGAWebShopMetadata ws on ws.GAViewId = pt.gaviewid
left join tGABrowser b on b.Browser_name = pt.browser
left join tGAOSystem s on s.OSystem_name = pt.opersystem
)
select 
[DateId], 
[Date], 
BrowserId, 
OSystemId, 
WebshopID, 
sum(Users) as Users, 
sum(NewUsers) as NewUsers, 
sum(Sessions) as Sessions, 
sum(bounces) as Bounces, 
sum(SessionDuration) as SessionDuration, 
sum(Hits) as Hits, 
sum(OrganicSearches) as OrganicSearches,
sum(Transactions) as Transactions
INTO [CT dwh 03 Intelligence].dbo.tFactGARPlatform
from MainQuery
group by 
[DateId], 
[Date], 
BrowserId, 
OSystemId, 
WebshopID










 
 

 


 




 
GO
/****** Object:  StoredProcedure [dbo].[spFactGARTrafficeSourcesCreate]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spFactGARTrafficeSourcesCreate] 
AS

IF  EXISTS (SELECT * FROM [CT dwh 03 Intelligence].sys.objects 
WHERE object_id = OBJECT_ID(N'[CT dwh 03 Intelligence].dbo.tFactGARTrafficSources')  
AND type in ('U'))
DROP TABLE [CT dwh 03 Intelligence].dbo.tFactGARTrafficSources;


WITH MainQuery AS
(
select 
ISNULL(CAST(CONVERT(CHAR(10),ts.[date],112) AS INT), 20000101) [DateId], 
ts.date, 
ISNULL(c.CampaignId, 1)  as CampaignId, 
ISNULL(s.SourceId, 1)  as SourceId, 
ISNULL(m.MediumId, 1)  as MediumId, 
COALESCE(ch.MChannelId,map.MChannelId, 1) as ChannelId, 
ISNULL(ws.WebshopId, 1)  as WebshopID
,CONVERT(INT, ts.Users) as Users 
,CONVERT(INT, ts.NewUsers) as NewUsers 
,CONVERT(INT, ts.[Sessions]) as [Sessions] 
,CONVERT(INT, ts.[bounces]) as [bounces]
,CONVERT(INT, ts.[SessionDuration]) as [SessionDuration]  
,CONVERT(INT, ts.[Hits]) as [Hits]  
,CONVERT(INT, ts.[OrganicSearches]) as [OrganicSearches]  
, 0 as Transactions
from tGATrafficSources ts
left join tGAWebShopMetadata ws on ws.GAViewId = ts.gaviewid
left join tGACampaign c on ts.campaign = c.campaign_name
left join tGASource s on ts.source = s.Source_name 
left join tGAMedium m on ts.medium = m.medium_name 
left join [tGAMarketingChannelMetadata] ch on ch.MChannelName = ts.channelGrouping
left join [tMappingGAChannelMetadata] map on map.[GAMarketingChannel] = ts.channelGrouping
UNION ALL
select 
ISNULL(CAST(CONVERT(CHAR(10),ts.[date],112) AS INT), 20000101) [DateId], 
ts.date, 
ISNULL(c.CampaignId, 1)  as CampaignId, 
ISNULL(s.SourceId, 1)  as SourceId, 
ISNULL(m.MediumId, 1)  as MediumId, 
COALESCE(ch.MChannelId,map.MChannelId, 1) as ChannelId, 
ISNULL(ws.WebshopId, 1)  as WebshopID 
,CONVERT(INT, ts.Users) as Users 
,CONVERT(INT, ts.NewUsers) as NewUsers 
,CONVERT(INT, ts.[Sessions]) as [Sessions] 
,CONVERT(INT, ts.[bounces]) as [bounces]
,CONVERT(INT, ts.[SessionDuration]) as [SessionDuration]  
,CONVERT(INT, ts.[Hits]) as [Hits]  
,CONVERT(INT, ts.[OrganicSearches]) as [OrganicSearches]  
, 1 as Transactions
from tGATrafficSourcesTR ts
left join tGAWebShopMetadata ws on ws.GAViewId = ts.gaviewid
left join tGACampaign c on ts.campaign = c.campaign_name
left join tGASource s on ts.source = s.Source_name 
left join tGAMedium m on ts.medium = m.medium_name 
left join [tGAMarketingChannelMetadata] ch on ch.MChannelName = ts.channelGrouping
left join [tMappingGAChannelMetadata] map on map.[GAMarketingChannel] = ts.channelGrouping
)
select 
[DateId], 
[Date], 
CampaignId, 
SourceId, 
MediumId, 
ChannelId, 
WebshopID, 
sum(Users) as Users, 
sum(NewUsers) as NewUsers, 
sum(Sessions) as Sessions, 
sum(bounces) as Bounces, 
sum(SessionDuration) as SessionDuration, 
sum(Hits) as Hits, 
sum(OrganicSearches) as OrganicSearches,
sum(Transactions) as Transactions
INTO [CT dwh 03 Intelligence].dbo.tFactGARTrafficSources
from MainQuery
group by 
[DateId], 
[Date], 
CampaignId, 
SourceId, 
MediumId, 
ChannelId, 
WebshopID










 
 

 


 




 
GO
/****** Object:  StoredProcedure [dbo].[spFactMAdwordsCampaignStatsCreate]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spFactMAdwordsCampaignStatsCreate] 
AS

IF  EXISTS (SELECT * FROM [CT dwh 03 Intelligence].sys.objects 
WHERE object_id = OBJECT_ID(N'[CT dwh 03 Intelligence].dbo.tFactMAdwordsCampaignStats')  
AND type in ('U'))
DROP TABLE [CT dwh 03 Intelligence].dbo.tFactMAdwordsCampaignStats;


SELECT  
ISNULL(CAST(CONVERT(CHAR(10),cs.[date],112) AS INT), 20000101) [DateId]
,cs.[campaign]
,cs.[source]
,cs.[medium]
,cs.[impressions]
,cs.[adClicks]
,cs.[adCost]
,ISNULL(m.WebShopId,1) as WebShopId
, CASE
 WHEN (cs.[campaign] like 'AS_%' OR cs.[campaign] like 'BS_%') AND ( cs.[campaign] like '%_BR_%' OR cs.[campaign] like '%_EBR_%') THEN 6467408  -- SEM_b
 WHEN (cs.[campaign] like 'AS_%' OR cs.[campaign] like 'BS_%')  THEN 6467409  -- SEM_nb
 WHEN cs.[campaign] like 'PLA_%BR_%' THEN 6498270   -- PLA_b
 WHEN cs.[campaign] like 'PLA_%' THEN 6498271 -- PLA_nb
 WHEN cs.[campaign] like 'DIS_%' THEN 6467404   -- GDN_AD
 WHEN cs.[campaign] like 'RD_%' THEN 6467405   -- GDN_RC
 WHEN cs.[campaign] like '%_RM_%' THEN 6467405    --GDN_RC
 ELSE 1 
END as MChannelId
into [CT dwh 03 Intelligence].dbo.tFactMAdwordsCampaignStats
from tGAAdwordsCampaignStats cs
left join [dbo].[tGAWebShopMetadata] m on m.GAViewId = cs.gaviewid


/*
  
 ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMChannelBasicStat] ADD  CONSTRAINT [pktFactMChannelBasicStat] PRIMARY KEY CLUSTERED 
(
	[DateId] ,
	[MChannelId] ,
	[WebShopId] ,
	[campaign], 
	[source], 
	[medium]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,  ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
*/
ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMAdwordsCampaignStats]  WITH NOCHECK ADD  CONSTRAINT [fkFactMAdwordsCampaignStatsWebShop] FOREIGN KEY([WebShopId])
REFERENCES [CT dwh 03 Intelligence].[dbo].[tDimWebShop] ([WebShopId])
ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMAdwordsCampaignStats] NOCHECK CONSTRAINT [fkFactMAdwordsCampaignStatsWebShop]



GO
/****** Object:  StoredProcedure [dbo].[spFactMarketingCostsCreate]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spFactMarketingCostsCreate] 
AS

IF  EXISTS (SELECT * FROM [CT dwh 03 Intelligence].sys.objects 
WHERE object_id = OBJECT_ID(N'[CT dwh 03 Intelligence].dbo.tFactMarketingCosts')  
AND type in ('U'))
DROP TABLE [CT dwh 03 Intelligence].dbo.tFactMarketingCosts;


SELECT 
       ISNULL(CAST(CONVERT(CHAR(10),mc.[date],112) AS INT), 20000101) [DateId]
	  ,mc.[ID]
      ,cn.[webshopcode] as webshop_code
      ,mc.[channel_code]
      ,mc.[costs]
      ,isnull(w. [WebShopId],1) as WebShopId
	  ,isnull(c.mchannelid, 1) as MChannelId
into [CT dwh 03 Intelligence].dbo.tFactMarketingCosts
FROM [CT dwh 02 Data].[dbo].[tGAMarketingCosts] mc 
 left join [CT dwh 02 Data].[dbo].[tMappingWebshopCountry] cn on mc.shop = cn.Shop and mc.country_code = cn.CountryCode
  left join [CT dwh 02 Data].[dbo].[tGAWebShopMetadata] w ON w.[WebshopCode] = cn.webshopcode
  left join [CT dwh 02 Data].[dbo].[tGAMarketingChannelMetadata] c on c.mchannelcode = mc.[channel_code]
  



ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMarketingCosts]  WITH NOCHECK ADD  CONSTRAINT [fkFactMarketingCostsWebShop] FOREIGN KEY([WebShopId])
REFERENCES [CT dwh 03 Intelligence].[dbo].[tDimWebShop] ([WebShopId])
ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMarketingCosts] NOCHECK CONSTRAINT [fkFactMarketingCostsWebShop]

ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMarketingCosts]  WITH NOCHECK ADD  CONSTRAINT [fkFactMarketingCostsMChannel] FOREIGN KEY([MChannelId])
REFERENCES [CT dwh 03 Intelligence].[dbo].[tDimMarketingChannel] ([MChannelId])
ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMarketingCosts] NOCHECK CONSTRAINT [fkFactMarketingCostsMChannel]

GO
/****** Object:  StoredProcedure [dbo].[spFactMChannelBasicStatCreate]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spFactMChannelBasicStatCreate] 
AS

IF  EXISTS (SELECT * FROM [CT dwh 03 Intelligence].sys.objects 
WHERE object_id = OBJECT_ID(N'[CT dwh 03 Intelligence].dbo.tFactMChannelBasicStat')  
AND type in ('U'))
DROP TABLE [CT dwh 03 Intelligence].dbo.tFactMChannelBasicStat;


SELECT  
ISNULL(CAST(CONVERT(CHAR(10),bs.[date],112) AS INT), 20000101) [DateId]
, [sessions]
,newUsers
,campaign
,[source]
, medium
, bounces
, CONVERT(bigint, sessionDuration) as sessionDuration
, pageviews
,ISNULL(m.WebShopId,1) as WebShopId
,isnull(c2.[MChannelId],1) as MChannelId
into [CT dwh 03 Intelligence].dbo.tFactMChannelBasicStat
from tGAChannelBasicStats bs
left join [dbo].[tGAWebShopMetadata] m on m.GAViewId = bs.gaviewid
left join [dbo].[tGAMarketingChannelMetadata] c on c.[MChannelName] = bs.channelGrouping
left join [dbo].[tMappingGAChannelMetadata] map on map.[GAMarketingChannel] = bs.channelGrouping
left join [dbo].[tGAMarketingChannelMetadata] c2 on c2.[MChannelCode] = isnull(c.MChannelCode, map.GAChannelCode)


  /*
 ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMChannelBasicStat] ADD  CONSTRAINT [pktFactMChannelBasicStat] PRIMARY KEY CLUSTERED 
(
	[DateId] ,
	[MChannelId] ,
	[WebShopId] ,
	[campaign], 
	[source], 
	[medium]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,  ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

*/

ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMChannelBasicStat]  WITH NOCHECK ADD  CONSTRAINT [fkFactMChannelBasicStatWebShop] FOREIGN KEY([WebShopId])
REFERENCES [CT dwh 03 Intelligence].[dbo].[tDimWebShop] ([WebShopId])
ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMChannelBasicStat] NOCHECK CONSTRAINT [fkFactMChannelBasicStatWebShop]

ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMChannelBasicStat]  WITH NOCHECK ADD  CONSTRAINT [fkFactMChannelBasicStatMChannel] FOREIGN KEY([MChannelId])
REFERENCES [CT dwh 03 Intelligence].[dbo].[tDimMarketingChannel] ([MChannelId])
ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMChannelBasicStat] NOCHECK CONSTRAINT [fkFactMChannelBasicStatMChannel]

GO
/****** Object:  StoredProcedure [dbo].[spFactMChannelConversionsCreate]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spFactMChannelConversionsCreate] 
AS

IF EXISTS (SELECT * FROM [CT dwh 03 Intelligence].sys.objects 
WHERE object_id = OBJECT_ID(N'[CT dwh 03 Intelligence].dbo.tFactMChannelConversions') AND type in ('U'))
DROP TABLE [CT dwh 03 Intelligence].dbo.tFactMChannelConversions;


IF EXISTS (SELECT * FROM [CT dwh 03 Intelligence].sys.objects 
WHERE object_id = OBJECT_ID(N'[CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp') AND type in ('U'))
DROP TABLE [CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp;

/****************************************************************************/
/*** get all transactions matched via KHKVKBelege (column Referenznummer) ***/
/****************************************************************************/
WITH TranList AS (
  SELECT rr, tl.[date], tl.transactionId, tl.transactions, tl.transactionRevenue, tl.gaviewid, tl.channelGrouping, tl.campaign, tl.[source], tl.medium
  FROM (
    SELECT ROW_NUMBER() OVER(PARTITION BY transactionid, gaviewid ORDER BY [date]) AS rr, cc.channelGrouping, cc.[date], cc.transactionId, cc.transactions, cc.transactionRevenue,
      cc.gaviewid, cc.campaign, cc.[source], cc.medium
    FROM [dbo].[tGAChannelConversions] cc 
    WHERE transactionid <> 0
  ) tl WHERE rr = 1
)

SELECT DISTINCT
  l.transactionId
, l.gaviewid
, l.transactions
, l.transactionRevenue
, l.channelGrouping
, l.campaign
, l.[source]
, l.medium
, CAST(CONVERT(CHAR(8), l.[date], 112) AS INT) [TransactionDateId]
, wmap.Mandant AS CompanyId
, ISNULL(b.vorid, 1) AS ProcessId
, ISNULL(wd.WebShopId, 1) AS WebShopId
, ISNULL(c2.[MChannelId], 1) AS MChannelId
, ISNULL(CustomerGroup.CustomerGroupId, 1) CustomerGroupId
INTO [CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp
FROM TranList l 
  INNER JOIN [CT dwh 02 Data].dbo.tGAWebShopMetadata wd
    ON wd.GAViewId = l.gaviewid
  INNER JOIN [CT dwh 02 Data].dbo.tMappingWebshopCustomerGroup wmap
    ON wmap.WebshopCode = wd.WebshopCode
  INNER JOIN [CT dwh 02 Data].dbo.TErpKHKVKBelege b
    ON b.Referenznummer = CAST(l.transactionid AS varchar(20)) AND b.Kundengruppe = wmap.CustomerGroup AND b.Mandant = wmap.Mandant AND b.Belegjahr = YEAR(l.[date])
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[tGAMarketingChannelMetadata] c
    ON c.[MChannelName] = l.channelGrouping
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[tMappingGAChannelMetadata] map
    ON map.[GAMarketingChannel] = l.channelGrouping
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[tGAMarketingChannelMetadata] c2
    ON c2.[MChannelCode] = ISNULL(c.MChannelCode, map.GAChannelCode)
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[vErpCustomerGroup] CustomerGroup
    ON CustomerGroup.CustomerGroupCode = wmap.CustomerGroup AND CustomerGroup.CompanyId = wmap.Mandant
;

/*************************************************************************************************/
/*** get all transactions matched via KHKVKBelege (column Referenznummer - OX-[transactionid]) ***/
/*************************************************************************************************/
WITH TranList AS (
  SELECT rr, tl.[date], tl.transactionId, tl.transactions, tl.transactionRevenue, tl.gaviewid, tl.channelGrouping, tl.campaign, tl.[source], tl.medium
  FROM (
    SELECT ROW_NUMBER() OVER(PARTITION BY transactionid, gaviewid ORDER BY [date]) AS rr, cc.channelGrouping, cc.[date], cc.transactionId, cc.transactions, cc.transactionRevenue,
      cc.gaviewid, cc.campaign, cc.[source], cc.medium
    FROM [dbo].[tGAChannelConversions] cc 
    WHERE transactionid <> 0
  ) tl WHERE rr = 1
)

INSERT INTO [CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp(
  transactionId, gaviewid, transactions, transactionRevenue, channelGrouping, campaign, [source], medium, TransactionDateId, CompanyId, ProcessId, WebShopId, MChannelId, CustomerGroupId
)
SELECT DISTINCT
  l.transactionId
, l.gaviewid
, l.transactions
, l.transactionRevenue
, l.channelGrouping
, l.campaign
, l.[source]
, l.medium
, CAST(CONVERT(CHAR(8), l.[date], 112) AS INT) [TransactionDateId]
, wmap.Mandant AS CompanyId
, ISNULL(b.vorid, 1) AS ProcessId
, ISNULL(wd.WebShopId, 1) AS WebShopId
, ISNULL(c2.[MChannelId], 1) AS MChannelId
, ISNULL(CustomerGroup.CustomerGroupId, 1) CustomerGroupId
FROM TranList l 
  INNER JOIN [CT dwh 02 Data].dbo.tGAWebShopMetadata wd
    ON wd.GAViewId = l.gaviewid
  INNER JOIN [CT dwh 02 Data].dbo.tMappingWebshopCustomerGroup wmap
    ON wmap.WebshopCode = wd.WebshopCode
  INNER JOIN [CT dwh 02 Data].dbo.TErpKHKVKBelege b
    ON b.Referenznummer = 'OX-' + CAST(l.transactionid AS varchar(20)) AND b.Kundengruppe = wmap.CustomerGroup AND b.Mandant = wmap.Mandant AND b.Belegjahr = YEAR(l.[date])
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[tGAMarketingChannelMetadata] c
    ON c.[MChannelName] = l.channelGrouping
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[tMappingGAChannelMetadata] map
    ON map.[GAMarketingChannel] = l.channelGrouping
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[tGAMarketingChannelMetadata] c2
    ON c2.[MChannelCode] = ISNULL(c.MChannelCode, map.GAChannelCode)
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[vErpCustomerGroup] CustomerGroup
    ON CustomerGroup.CustomerGroupCode = wmap.CustomerGroup AND CustomerGroup.CompanyId = wmap.Mandant
  LEFT JOIN [CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp f
    ON CAST(CONVERT(CHAR(8), l.[date], 112) AS INT) = f.TransactionDateId AND l.campaign = f.campaign AND l.[source] = f.[source] AND l.medium = f.medium AND
      l.channelGrouping = f.channelGrouping AND l.gaviewid = f.gaviewid AND l.transactionId = f.transactionId
WHERE f.transactionId IS NULL
;

/********************************************************************/
/*** get all transactions matched via LBShopSales (column SaleID) ***/
/********************************************************************/
WITH TranList AS (
  SELECT rr, tl.[date], tl.transactionId, tl.transactions, tl.transactionRevenue, tl.gaviewid, tl.channelGrouping, tl.campaign, tl.[source], tl.medium
  FROM (
    SELECT ROW_NUMBER() OVER(PARTITION BY transactionid, gaviewid ORDER BY [date]) AS rr, cc.channelGrouping, cc.[date], cc.transactionId, cc.transactions, cc.transactionRevenue,
      cc.gaviewid, cc.campaign, cc.[source], cc.medium
    FROM [dbo].[tGAChannelConversions] cc 
    WHERE transactionid <> 0
  ) tl WHERE rr = 1
)

INSERT INTO [CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp(
  transactionId, gaviewid, transactions, transactionRevenue, channelGrouping, campaign, [source], medium, TransactionDateId, CompanyId, ProcessId, WebShopId, MChannelId, CustomerGroupId
)
SELECT 
  l.transactionId
, l.gaviewid
, l.transactions
, l.transactionRevenue
, l.channelGrouping
, l.campaign
, l.[source]
, l.medium
, CAST(CONVERT(CHAR(8), l.[date], 112) AS INT) [TransactionDateId] 
, ss.KHKClient AS CompanyId
, ISNULL(b.VorId, 1) AS ProcessId
, ISNULL(wd.WebShopId, 1) AS WebShopId
, ISNULL(c.[MChannelId], 1) AS MChannelId
, ISNULL(CustomerGroup.CustomerGroupId, 1) CustomerGroupId

FROM TranList l 
  INNER JOIN [CT dwh 02 Data].dbo.[tErpLBShopSales] ss
    ON ss.Saleid = CAST(l.transactionid AS INT) 
  INNER JOIN [CT dwh 02 Data].dbo.[tErpLBShop] s
    ON ss.ShopId = s.ShopId
  INNER JOIN [CT dwh 02 Data].dbo.TErpKHKVKBelege b
    ON b.belid = ss.KHKDocId AND b.mandant = ss.KHKClient AND b.Belegjahr = YEAR(l.[date])
  LEFT OUTER JOIN [CT dwh 02 Data].dbo.tGAWebShopMetadata wd
    ON l.gaviewid = wd.GAViewId
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[tMappingGAChannelMetadata] map
    ON map.[GAMarketingChannel] = l.channelGrouping
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[tGAMarketingChannelMetadata] c
    ON c.MChannelCode = map.GAChannelCode
  LEFT OUTER JOIN [CT dwh 02 Data].dbo.tMappingWebshopCustomerGroup wmap
    ON wmap.CustomerGroup = s.CustomerGroup AND wmap.mandant = ss.KHKClient
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[vErpCustomerGroup] CustomerGroup
    ON  CustomerGroup.CustomerGroupCode = s.CustomerGroup AND CustomerGroup.CompanyId = ss.KHKClient
  LEFT JOIN [CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp f
    ON CAST(CONVERT(CHAR(8), l.[date], 112) AS INT) = f.TransactionDateId AND l.campaign = f.campaign AND l.[source] = f.[source] AND l.medium = f.medium AND
      l.channelGrouping = f.channelGrouping AND l.gaviewid = f.gaviewid AND l.transactionId = f.transactionId
WHERE ss.saleid IS NOT NULL AND f.transactionId IS NULL
;

/********************************************************************/
/*** get all transactions not matching KHKVKBelege or LBShopsales ***/
/********************************************************************/
WITH TranList AS (
  SELECT rr, tl.[date], tl.transactionId, tl.transactions, tl.transactionRevenue, tl.gaviewid, tl.channelGrouping, tl.campaign, tl.[source], tl.medium
  FROM (
    SELECT ROW_NUMBER() OVER(PARTITION BY transactionid, gaviewid ORDER BY [date]) AS rr, cc.channelGrouping, cc.[date], cc.transactionId, cc.transactions, cc.transactionRevenue,
      cc.gaviewid, cc.campaign, cc.[source], cc.medium
    FROM [dbo].[tGAChannelConversions] cc 
    WHERE transactionid <> 0
  ) tl WHERE rr = 1
)

INSERT INTO [CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp(
  transactionId, gaviewid, transactions, transactionRevenue, channelGrouping, campaign, [source], medium, TransactionDateId, CompanyId, ProcessId, WebShopId, MChannelId, CustomerGroupId
)
SELECT DISTINCT
  l.transactionId
, l.gaviewid
, l.transactions
, l.transactionRevenue
, l.channelGrouping
, l.campaign
, l.[source]
, l.medium
, CAST(CONVERT(CHAR(8), l.[date], 112) AS INT) [TransactionDateId]
, wmap.Mandant AS CompanyId
, 1 AS ProcessId
, ISNULL(wd.WebShopId, 1) AS WebShopId
, ISNULL(c2.[MChannelId], 1) AS MChannelId
, ISNULL(CustomerGroup.CustomerGroupId, 1) CustomerGroupId
FROM TranList l 
  INNER JOIN [CT dwh 02 Data].dbo.tGAWebShopMetadata wd
    ON wd.GAViewId = l.gaviewid
  INNER JOIN [CT dwh 02 Data].dbo.tMappingWebshopCustomerGroup wmap
    ON wmap.WebshopCode = wd.WebshopCode
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[tGAMarketingChannelMetadata] c
    ON c.[MChannelName] = l.channelGrouping
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[tMappingGAChannelMetadata] map
    ON map.[GAMarketingChannel] = l.channelGrouping
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[tGAMarketingChannelMetadata] c2
    ON c2.[MChannelCode] = ISNULL(c.MChannelCode, map.GAChannelCode)
  LEFT OUTER JOIN [CT dwh 02 Data].[dbo].[vErpCustomerGroup] CustomerGroup
    ON CustomerGroup.CustomerGroupCode = wmap.CustomerGroup AND CustomerGroup.CompanyId = wmap.Mandant
  LEFT JOIN [CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp f
    ON CAST(CONVERT(CHAR(8), l.[date], 112) AS INT) = f.TransactionDateId AND l.campaign = f.campaign AND l.[source] = f.[source] AND l.medium = f.medium AND
      l.channelGrouping = f.channelGrouping AND l.gaviewid = f.gaviewid AND l.transactionId = f.transactionId
WHERE f.transactionId IS NULL
;

WITH NetRevenue AS (
  SELECT
    c.transactionId, 
    c.Webshopid, 
    c.MchannelId,
    c.CompanyId, 
    c.ProcessId, 
    SUM(ISNULL(s.InvoiceItemAmountNetLcy, 0)) - SUM(ISNULL(s.CrMemoItemAmountNetLcy, 0)) + SUM(ISNULL(g.[InvoiceAddChargeExclVatLcy], 0)) - SUM(ISNULL([CrMemoAddChargeExclVatLcy], 0)) AS NetRevenue, 
    SUM(ISNULL(s.[OrderItemAmountNetNCLcy], 0)) AS NetNonConfirmed 
  FROM [CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp c 
    LEFT OUTER JOIN [CT dwh 03 Intelligence].dbo. tFactSales s
      ON c.CompanyId = s.CompanyId AND c.ProcessId = s.ProcessId
    LEFT OUTER JOIN [CT dwh 03 Intelligence].dbo.tFactSalesCharge g
      ON s.CompanyId = g.CompanyId AND s.SalesDocumentId = g.SalesDocumentId AND s.DocumentLineId = g.DocumentLineId AND s.SetLineId = g.SetLineId
  WHERE c.ProcessId <> 0
  GROUP BY c.transactionId, c.Webshopid, c.MchannelId, c.CompanyId, c.ProcessId
)
SELECT 
  c.transactionId
, c.gaviewid
, c.transactions
, c.transactionRevenue
, c.channelGrouping
, c.campaign
, c.[source]
, c.medium
, c.[TransactionDateId]
, c.CompanyId
, ISNULL(p.ProcessId, 0) AS ProcessId
, c.WebShopId
, c.MChannelId
, c.CustomerGroupId
, ISNULL(r.NetRevenue, 0) AS NetRevenue
, ISNULL(r.NetNonConfirmed, 0) AS NetNonConfirmed
, CASE WHEN ISNULL(r.NetNonConfirmed, 0) = 0 THEN 0 ELSE 1 END OrderAmountNonConfirmed
INTO [CT dwh 03 Intelligence].dbo.tFactMChannelConversions
FROM [CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp c 
  LEFT OUTER JOIN NetRevenue r
    ON c.transactionid = r.transactionid AND c.webshopid = r.webshopid AND c.mchannelid = r.mchannelid AND c.processid = r.processid
--  LEFT OUTER JOIN [CT dwh 03 Intelligence].dbo.tDimSalesProcess p
--    ON p.CompanyId = c.CompanyId AND p.ProcessId = c.ProcessId
  LEFT OUTER JOIN [CT dwh 04 Analysis].dbo.vDimSalesProcess p
    ON p.CompanyId = c.CompanyId AND p.ProcessId = c.ProcessId
;


IF  EXISTS (SELECT * FROM [CT dwh 03 Intelligence].sys.objects 
WHERE object_id = OBJECT_ID(N'[CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp') AND type in ('U'))
DROP TABLE [CT dwh 03 Intelligence].dbo.tFactMChannelConversions_temp;


ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMChannelConversions]  WITH NOCHECK ADD CONSTRAINT [fkFactMChannelConversionsWebShop] FOREIGN KEY([WebShopId])
REFERENCES [CT dwh 03 Intelligence].[dbo].[tDimWebShop] ([WebShopId])
ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMChannelConversions] NOCHECK CONSTRAINT [fkFactMChannelConversionsWebShop]

ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMChannelConversions]  WITH NOCHECK ADD CONSTRAINT [fkFactMChannelConversionsMChannel] FOREIGN KEY([MChannelId])
REFERENCES [CT dwh 03 Intelligence].[dbo].[tDimMarketingChannel] ([MChannelId])
ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactMChannelConversions] NOCHECK CONSTRAINT [fkFactMChannelConversionsMChannel]
GO
/****** Object:  StoredProcedure [dbo].[spFactPurchasingOrdersTransactionsVerticalSAP]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spFactPurchasingOrdersTransactionsVerticalSAP] AS BEGIN
SET NOCOUNT ON;

-- quick fix to exclude deleted Deliverynotes (DWH-1126)

PRINT LTRIM(CAST(GETDATE() AS NVARCHAR(20))) + ' start!'

SELECT 
	LI.*
INTO #tSAPZ_MM_LIKP_LIPS
FROM [CT dwh 02 Data].[dbo].[tSAPZ_MM_LIKP_LIPS] AS LI WITH (NOLOCK) 
LEFT JOIN
(
	SELECT
		CAST(OBJECTID AS NVARCHAR(10)) AS OBJECTID
		, CAST(RIGHT(TABKEY,6) AS NVARCHAR(6)) AS POSNR
	FROM [CT dwh 02 Data].[dbo].[tSAPZ_MM_CDHDR_CDPOS_L] WITH (NOLOCK)
	WHERE 1 = 1
		AND is_current = 1
		AND CHNGIND = 'D'
		AND OBJECTCLAS = 'LIEFERUNG' 
		AND TABNAME IN ('LIKP', 'LIPS')
) AS CD_L
	ON LI.VBELN = CD_L.OBJECTID
	AND LI.POSNR = CD_L.POSNR
WHERE 1 = 1
	AND LI.is_current = 1
	AND CD_L.OBJECTID IS NULL

PRINT LTRIM(CAST(GETDATE() AS NVARCHAR(20))) + ' #tSAPZ_MM_LIKP_LIPS filled to exclude deleted Deliverynotes'

CREATE INDEX idx_#tSAPZ_MM_LIKP_LIPS ON #tSAPZ_MM_LIKP_LIPS (VBELN, VGBEL, VGPOS);

PRINT LTRIM(CAST(GETDATE() AS NVARCHAR(20))) + ' Index on #tSAPZ_MM_LIKP_LIPS created'

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

TRUNCATE TABLE [CT dwh 03 Intelligence].[dbo].[tFactPurchasingOrdersTransactionsVerticalSAP]

PRINT LTRIM(CAST(GETDATE() AS NVARCHAR(20))) + ' tFactPurchasingOrdersTransactionsVerticalSAP truncated'

MERGE [CT dwh 03 Intelligence].[dbo].[tFactPurchasingOrdersTransactionsVerticalSAP] AS t
USING (
        SELECT
            EKKO.EKORG                                             AS CompanyId
          , ISNULL(TTC.TransactionType, 'Other')                   AS TransactionType
          , ISNULL(EKKO.BSART, 'Bestellung Andere')                AS TransactionTypeDetail
          , RIGHT(EKPO.[MATNR], 8)                                 AS ItemNo
            -- , MARA.[MFRNR]                                           AS ModelName
          , TMP_ModelName.ModelName   AS ModelName
          , EKPO.TXZ01                AS [Description]
          , ph.ProductHierarchie1_txt AS ProductHierarchie1
          , ph.ProductHierarchie2_txt AS ProductHierarchie2
          , ph.ProductHierarchie3_txt AS ProductHierarchie3
          , brand.USER_VKMarke        AS Brand
          , MARA.MSTAE                AS EOL
          , T024.EKNAM                AS Dispatcher --/26.08.2020/FT: before: EKKO.EKGRP
          , MARA.VOLUM                AS Volume
          , MARA.LAENG                AS [Length]
          , MARA.BREIT                AS Width
          , MARA.HOEHE                AS Height
          , MARA.MTART                AS ItemType
          , EKKO.WAERS                AS Currency
          , EKKO.BEDAT                AS TransactionDate
          , EKPO.MENGE                AS Quantity
          , EKPO.NETPR                AS ItemPriceForeignCurrency
          , (EKPO.NETPR *
            CASE
                WHEN EKKO.WKURS < 0
                    THEN (1 / ABS(EKKO.WKURS))
                    ELSE ABS(EKKO.WKURS)
            END) AS ItemPrice
            --, case when EKPO.MENGE > 0 THEN (EKPO.NETPR * EKKO.WKURS)/EKPO.MENGE   eLSE 0 end                AS ItemPrice
          , EKPO.NETWR AS ValueForeignCurrency
            --, (ABS(EKPO.NETPR))             AS ValueForeignCurrency
          , (EKPO.NETWR *
            CASE
                WHEN EKKO.WKURS < 0
                    THEN (1 / ABS(EKKO.WKURS))
                    ELSE ABS(EKKO.WKURS)
            END) AS [Value]
            --, (ABS(EKPO.NETPR * EKKO.WKURS))       AS [Value]
          , CASE
                WHEN EKKO.WKURS < 0
                    THEN (1 / ABS(EKKO.WKURS))
                    ELSE ABS(EKKO.WKURS)
            END AS ExchangeRate
            -- hier wechseln wir von BUDAT auf BEDAT
          , EKKO.BEDAT AS PostingDate
            --, EKKO.EBELN                                             AS DocumentNo // FT am 23.07.2020
            -- lt. https://jira.chal-tec.com/browse/DEVTCK-16637 soll EKKO.EBELN nun die ProcessID sein
          , EKKO.EBELN       AS ProcessID
          , EKPO.EBELP       AS ProcessPosition -- FT: 07.08.2020
          , EKPO.EBELN       AS DocumentNo
          , EKPO.ZMM_MRD     AS MaterialReadyDate
          , EKPO.ZMM_QC_DATE AS PlannedQCDate
		  --  24.09.2020/FT: nach Rücksprache mit Michael implementiert. Falsche Werte durch SAP
         -- , case when TRY_CONVERT(datetime, EKPO.ZMM_ETD) IS NOT NULL THEN EKPO.ZMM_ETD ELSE NULL End     AS PlannedETD
		  , EKPO.ZMM_ETD as PlannedETD
		  --  24.09.2020/FT: nach Rücksprache mit Michael implementiert. Falsche Werte durch SAP
          --, case when TRY_CONVERT(datetime, EKPO.ZMM_ETD) IS NOT NULL THEN EKPO.ZMM_ETD ELSE NULL end     AS ETD
		  --, EKPO.ZMM_ETD as ETD --changed
		  ,LIS.[ZZETD] as ETD	--changed
          , EKKO.[ZTERM]     AS Paymentterms
          , ITM.[ZZ_INCO1]   AS Incoterms
          , LFA1.[NAME1]     AS CreditorsName
          , SAP_MARA.MATKL   AS SupplierCode --LFA1.[SORTL]     AS SupplierCode --20.08.2020/FT: Ticket 17074 -> comes from tSAP_MARA.MATKL
          , LFB1.[ALTKN]     AS CreditorsNumber
          , LFB1.[FRGRP]     AS SupplierGroupNumber
            --, CASE
            --      WHEN EKES.[EBTYP] = 'Z3'
            --          THEN -1
            --          ELSE 0
            --  END AS DeliveryAdvise
          , case
                when
                    (
                        select
                            EBTYP
                        from
                            (
                                SELECT
                                    top 1 EBTYP
                                FROM
                                    [CT dwh 01 Stage].[dbo].[tSAP_EKES] AS EKES WITH (NOLOCK)
                                where
                                    EKPO.MANDT     = EKES.MANDT
                                    AND EKPO.EBELN = EKES.EBELN
                                    and EKES.ebtyp = 'Z3'
                            )
                            as x
                    )
                    = 'Z3'
                    then -1
                    else 0
            end                                    AS DeliveryAdvise
          , DATEADD(DAY, EKKO.ZBD1T, EKPO.ZMM_ETD) AS DueDate
		  --  24.09.2020/FT: nach Rücksprache mit Michael implementiert. Falsche Werte durch SAP
		  --, case when TRY_CONVERT(datetime, EKPO.ZMM_ETD) IS NOT NULL THEN DATEADD(DAY, EKKO.ZBD1T, EKPO.ZMM_ETD) ELSE NULL end AS DueDate
            /*
            , CASE
            WHEN EKES.[EBTYP] = 'Z3'
            THEN -1
            ELSE 0
            END AS BookingConfirmed
            */
          , case
                when
                    (
                        select
                            EBTYP
                        from
                            (
                                SELECT
                                    top 1 EBTYP
                                FROM
                                    [CT dwh 01 Stage].[dbo].[tSAP_EKES] AS EKES WITH (NOLOCK)
                                where
                                    EKPO.MANDT     = EKES.MANDT
                                    AND EKPO.EBELN = EKES.EBELN
                                    and EKES.ebtyp = 'Z3'
                            )
                            as x
                    )
                    = 'Z3'
                    then -1
                    else 0
            end as BookingConfirmed
          --, CASE --changed 
          --      WHEN LIKP.[ZZ_ETAPORT] < '1753-01-01'
          --          THEN '1753-01-01'
          --          ELSE LIKP.[ZZ_ETAPORT]
          --  END AS ETAPort
          , CASE 
                WHEN LIS.[ZZETA] < '1753-01-01'
                    THEN '1753-01-01'
                    ELSE LIS.[ZZETA]
            END AS ETAPort
          , CASE
                WHEN TTC.TransactionType = 'DeliveryNote'
                    THEN LIKP.[TRAID]
                    ELSE NULL
            END            AS ContainerNumber
          , ITM.[ZZ_DPPCT] AS PercentageDesposit
		  /* https://jira.chal-tec.com/browse/DEVTCK-17312
          , CASE
                WHEN ITM.[ZZ_DPTYP] = 'V'
                    THEN ITM.[ZZ_INCO2_L]
                    ELSE NULL
            END AS OutboundHarbour
          , CASE
                WHEN ITM.[ZZ_DPTYP] = 'N'
                    THEN ITM.[ZZ_INCO2_L]
                    ELSE NULL
            END AS InboundHarbour
			*/
		  , LIKP.INCO2_L as OutboundHarbour
		  , LIKP.INCO3_L as InboundHarbour
          , (ROW_NUMBER() OVER (PARTITION BY
                                CASE
                                    WHEN EKKO.EKORG = ''
                                        THEN '1000'
                                        ELSE EKKO.EKORG
                                END, TTC.TransactionType, EKKO.EBELN, MARA.[MATNR] ORDER BY
                                EKKO.BEDAT)) AS PositionIdRC
          , EKET.EINDT                       as ETAWarehouse
		  -- //26.08.2020/FT: https://jira.chal-tec.com/browse/DEVTCK-17112
           /*,
		  case
                when PRCD_ZCU2.KKURS < 0
                    then PRCD_ZCU2.KAWRT/PRCD_ZCU2.KKURS
                    else case
                when PRCD_ZCU2.KKURS > 0
                    then PRCD_ZCU2.KAWRT*PRCD_ZFV1.KKURS
                    else PRCD_ZCU2.KAWRT
            end
            end as ImportDutiesPlan
          , case
                when PRCD_ZFKV.KKURS < 0
                    then PRCD_ZFKV.KAWRT/PRCD_ZFKV.KKURS
                    else case
                when PRCD_ZFKV.KKURS > 0
                    then PRCD_ZFKV.KAWRT*PRCD_ZFV1.KKURS
                    else PRCD_ZFKV.KAWRT
            end
            end as SeaFreightPlan
          , case
                when PRCD_ZFV1.KKURS < 0
                    then PRCD_ZFV1.KAWRT/PRCD_ZFV1.KKURS
                    else case
                when PRCD_ZFV1.KKURS > 0
                    then PRCD_ZFV1.KAWRT*PRCD_ZFV1.KKURS
                    else PRCD_ZFV1.KAWRT
            end 
            end as OperationCostPlan
		 */
		 ,case
                when PPR0.KKURS < 0
                    then PRCD_ZCU2.KWERT/ABS(PPR0.KKURS)
                    else case
                when PPR0.KKURS > 0
                    then PRCD_ZCU2.KWERT*PPR0.KKURS
                    else PRCD_ZCU2.KWERT
            end
            end as ImportDutiesPlan
          , case
                when PPR0.KKURS < 0
                    then PRCD_ZFKV.KWERT/ABS(PPR0.KKURS)
                    else case
                when PPR0.KKURS > 0
                    then PRCD_ZFKV.KWERT*PPR0.KKURS
                    else PRCD_ZFKV.KWERT
            end
            end as SeaFreightPlan
          , case
                when PPR0.KKURS < 0
                    then PRCD_ZFV1.KWERT/ABS(PPR0.KKURS)
                    else case
                when PPR0.KKURS > 0
                    then PRCD_ZFV1.KWERT*PPR0.KKURS
                    else PRCD_ZFV1.KWERT
            end 
            end as OperationCostPlan
		, PRCD_ZCU2.KWERT as ImportDutiesPlanFC
		, PRCD_ZFKV.KWERT as SeaFreightPlanFC
		, PRCD_ZFV1.KWERT as OperationCostPlanFC
		--, CASE --changed
  --              WHEN EKKO.EKORG = '1000' OR EKKO.EKORG = ''
  --                  THEN left(EM_F06.message, 80)
  --                  ELSE NULL
  --          END              AS ForwarderReference
		, CASE 
                WHEN EKKO.EKORG = '1000' OR EKKO.EKORG = ''
                    THEN left(LIS.[ZZFORWARDER_REF], 80)
                    ELSE NULL
            END              AS ForwarderReference
		--, CASE	--changed
  --              WHEN EKKO.EKORG = '1000' OR EKKO.EKORG = ''
  --                  THEN left(EM_F01.message, 80)
  --                  ELSE NULL
  --          END AS SupplierReference
		, CASE
                WHEN EKKO.EKORG = '1000' OR EKKO.EKORG = ''
                    THEN left(LIS.[ZZSUPPLIER_REF], 80)
                    ELSE NULL
            END AS SupplierReference
		, EKKO.AEDAT as ProcessIDCreationDate
		,	CONVERT(datetime, 
			  SUBSTRING(cast([LASTCHANGEDATETIME] as varchar), 1, 4) + '-' 
			+ SUBSTRING(cast([LASTCHANGEDATETIME] as varchar), 5, 2) + '-' 
			+ SUBSTRING(cast([LASTCHANGEDATETIME] as varchar), 7, 2) + ' ' 
			+ SUBSTRING(cast([LASTCHANGEDATETIME] as varchar), 9, 2) + ':'
			+ SUBSTRING(cast([LASTCHANGEDATETIME] as varchar), 11, 2) + ':' 
			+ SUBSTRING(cast([LASTCHANGEDATETIME] as varchar), 13, 2), 120) AS ProcessIDLastChangeDate 
		, CASE WHEN EKKO.WEAKT='X' THEN -1 ELSE 0 END as ProcessFulfilled
		--, left(EM_F05.message, 50) as Forwarder	--changed	--> https://jira.chal-tec.com/browse/DEVTCK-17452
		, EKPA.[TEXT_EKPA_LIFN2] as Forwarder
		, NULL as DeliveryNoteStatus
		, EKPO.WERKS as Plant
		, MARC_CC.STAWN as CommodityCode
		, EKPO.LGORT as StorageLocation
		, LIS.[ZZKONNR] as ContractNumber				--changed
		, LIS.[ZZPORT_OF_DISCHARG] as PortOfDischarg	--changed
		, LIS.[ZZPORT_OF_LOADING] as PortOfLoading		--changed
		, LIS .[ZZTRANSPORT_MODE] as TransportMode		--changed
        FROM
            [CT dwh 01 Stage].[dbo].[tSAP_EKPO] AS EKPO WITH (NOLOCK)
            INNER JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_EKKO] AS EKKO WITH (NOLOCK)
                ON
                    EKPO.EBELN = EKKO.EBELN
					and EKPO.MANDT = EKKO.MANDT
            INNER JOIN
                [CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAP] AS TTC WITH (NOLOCK)
                ON
                    EKKO.BSTYP     = TTC.BSTYP
                    AND EKKO.BSART = TTC.BSART
			LEFT JOIN	--changed
                 [CT dwh 02 Data].[dbo].[tSAPZ_MM_EKPA] AS EKPA WITH (NOLOCK)
                ON
                    EKPA.EBELN	= EKPO.EBELN
					AND EKPA.EBELP = '00000'
					AND EKPA.PARVW = 'FS' --changed
					AND EKPA.is_current = 1 --changed
			LEFT JOIN	--changed
                 [CT dwh 02 Data].[dbo].[tSAP2LIS_02_HDR] AS LIS WITH (NOLOCK)
                ON
                    LIS.EBELN	= EKKO.EBELN
					AND LIS.is_current = 1 --changed
				
            LEFT JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_MATERIAL_ATTR] AS MARA WITH (NOLOCK)
                ON
                    MARA.MATNR = EKPO.MATNR
            LEFT JOIN
                (
                    SELECT
                        MATNR
					  , MANDT
                      , IDNLF AS ModelName
                      , ROW_NUMBER() OVER (PARTITION BY MATNR,MANDT ORDER BY
                                           INFNR DESC) AS Anzahl
                    FROM
                        [CT dwh 01 Stage].[dbo].[tSAP_EINA] WITH (NOLOCK)
                    WHERE
                        1 = 1
                )
                AS TMP_ModelName
                ON
                    MARA.MATNR               = TMP_ModelName.MATNR
                    AND TMP_ModelName.Anzahl = 1
            LEFT JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_LFA1] AS LFA1 WITH (NOLOCK)
                ON
                    EKKO.MANDT     = LFA1.MANDT
                    AND EKKO.LIFNR = LFA1.LIFNR
            LEFT JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_LFB1] AS LFB1 WITH (NOLOCK)
                ON
                    EKKO.MANDT     = LFB1.MANDT
                    AND EKKO.LIFNR = LFB1.LIFNR
					and EKKO.BUKRS = LFB1.BUKRS
            LEFT JOIN
                (
                    SELECT
                        MANDT
                      , EBELN
                      , EBELP
                      , ETENS
                      , EBTYP
                      , VBELN
                      , ROW_NUMBER() OVER (PARTITION BY MANDT, EBELN, EBELP ORDER BY
                                           ETENS DESC) AS IdRC
                    FROM
                         [CT dwh 01 Stage].[dbo].[tSAP_EKES] AS EKES WITH (NOLOCK)
                )
                AS EKES
                ON
                    EKPO.MANDT     = EKES.MANDT
                    AND EKPO.EBELN = EKES.EBELN
                    AND EKPO.EBELP = EKES.EBELP
                    /* Wähle immer den letzten Eintrag, daher ORDER BY DESC */
                    AND EKES.IdRC = 1
            LEFT JOIN
					(
					SELECT DISTINCT
						VBELN
						, INCO2_L
						, INCO3_L
						, TRAID
					FROM #tSAPZ_MM_LIKP_LIPS WITH (NOLOCK)
					WHERE 1 = 1
					) AS LIKP
                    ON EKES.VBELN = LIKP.VBELN
            LEFT JOIN
                (
                    SELECT distinct
                        BUKRS
                      , EBELN
                      , EBELP
                      , [ZZ_INCO1]   -- Incoterms
                      , [ZZ_DPTYP]   -- N: Inbound, V: Outboundtyp
                      , [ZZ_DPPCT]   -- PercentageDesposit
                      , [ZZ_INCO2_L] -- OutboundHarbour
					  , [ZZ_INCO3_L] -- InboundHarbour
                    FROM
                        [CT dwh 02 Data].[dbo].[tSAP2LIS_02_ITM] with (nolock)
					WHERE 1 = 1
					AND is_current = 1
                )
                AS ITM
                ON
                    EKPO.BUKRS     = ITM.BUKRS
                    AND EKPO.EBELN = ITM.EBELN
                    AND EKPO.EBELP = ITM.EBELP
            LEFT JOIN
                [CT dwh 02 Data].[dbo].[vProductHierarchieSAP] ph with (nolock)
                on
                    MARA.PRDHA = ph.ProductHierarchie3
            LEFT JOIN
                (
                    SELECT
                        Artikelnummer
                      , USER_VKMarke
                    FROM
                        [CT dwh 02 Data].[dbo].[tErpKHKArtikel] AS Art WITH (NOLOCK)
                    WHERE
                        1                          = 1
                        AND Mandant                = 1
                        AND Artikelnummer       LIKE '[17]%'
                        AND USER_VKMarke IS NOT NULL
                )
                brand
                on
                    RIGHT(EKPO.MATNR, 8) = brand.Artikelnummer
            LEFT JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_EKET] EKET with (nolock)
                on
                    EKET.MANDT     = EKPO.MANDT
                    AND EKET.EBELN = EKPO.EBELN
                    AND EKET.EBELP = EKPO.EBELP
            LEFT JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_MARA] SAP_MARA with (nolock)
                on
                    EKPO.MANDT     = SAP_MARA.MANDT
                    AND EKPO.MATNR = SAP_MARA.MATNR
			LEFT JOIN
				 [CT dwh 01 Stage].[dbo].[tSAP_MARC] MARC with (nolock)
				on
					EKPO.MATNR	= MARC.MATNR
					AND MARC.WERKS in ('1000', '1100') -- //15.10.2020 DEVTCK-17593
					AND EKPO.WERKS = MARC.WERKS
			LEFT JOIN -- look at: https://jira.chal-tec.com/browse/DEVTCK-17659
				 [CT dwh 01 Stage].[dbo].[tSAP_MARC] MARC_CC with (nolock)
				on
					EKPO.MATNR	= MARC_CC.MATNR
					AND MARC_CC.WERKS in ('1000')
			LEFT JOIN
				 [CT dwh 01 Stage].[dbo].[tSAP_T024] T024 with (nolock)
				on
					MARC.EKGRP		= T024.EKGRP
					AND EKKO.MANDT	= T024.MANDT
			LEFT JOIN (select MAX(ZAEHK) over (partition by KNUMV, KPOSN, KSCHL) as ZAEHK_MAX, KNUMV, KPOSN, ZAEHK, KKURS, KAWRT, KWERT
						from  [CT dwh 01 Stage].[dbo].[tSAP_PRCD_ELEMENTS] with (nolock) where KSCHL = 'ZCU2') as PRCD_ZCU2
				on
					PRCD_ZCU2.ZAEHK_MAX				= PRCD_ZCU2.ZAEHK 
					AND PRCD_ZCU2.KNUMV				= EKKO.KNUMV 
					AND right(PRCD_ZCU2.KPOSN,5)	= EKPO.EBELP
			LEFT JOIN (select MAX(ZAEHK) over (partition by KNUMV, KPOSN, KSCHL) as ZAEHK_MAX, KNUMV, KPOSN, ZAEHK, KKURS, KAWRT, KWERT
						from [CT dwh 01 Stage].[dbo].[tSAP_PRCD_ELEMENTS] with (nolock) where KSCHL = 'ZFKV') as  PRCD_ZFKV
				on
					PRCD_ZFKV.ZAEHK_MAX				= PRCD_ZFKV.ZAEHK  
					AND PRCD_ZFKV.KNUMV				= EKKO.KNUMV 
					AND right(PRCD_ZFKV.KPOSN,5)	= EKPO.EBELP
			LEFT JOIN (select MAX(ZAEHK) over (partition by KNUMV, KPOSN, KSCHL) as ZAEHK_MAX, KNUMV, KPOSN, ZAEHK, KKURS, KAWRT, KWERT
						from  [CT dwh 01 Stage].[dbo].[tSAP_PRCD_ELEMENTS] with (nolock) where KSCHL = 'ZFV1') as PRCD_ZFV1
				on
					PRCD_ZFV1.ZAEHK_MAX				= PRCD_ZFV1.ZAEHK  
					AND PRCD_ZFV1.KNUMV				= EKKO.KNUMV 
					AND right(PRCD_ZFV1.KPOSN,5)	= EKPO.EBELP
			LEFT JOIN (select MAX(ZAEHK) over (partition by KNUMV, KPOSN, KSCHL) as ZAEHK_MAX, KNUMV, KPOSN, ZAEHK, KKURS, KAWRT, KWERT
						from  [CT dwh 01 Stage].[dbo].[tSAP_PRCD_ELEMENTS] with (nolock) where KSCHL = 'PPR0') as PPR0
				on
					PPR0.ZAEHK_MAX				= PPR0.ZAEHK  
					AND PPR0.KNUMV				= EKKO.KNUMV 
					AND right(PPR0.KPOSN,5)		= EKPO.EBELP
			LEFT JOIN (Select message, EBELB, MANDT FROM [CT dwh 01 Stage].[dbo].[tSAP_EKKO_messages] with (nolock) where TextID = 'F06') AS EM_F06
				on EKKO.EBELN = EM_F06.EBELB
					AND EKKO.MANDT = EM_F06.MANDT
			LEFT JOIN (Select message, EBELB, MANDT FROM [CT dwh 01 Stage].[dbo].[tSAP_EKKO_messages] with (nolock) where TextID = 'F01') AS EM_F01
				on EKKO.EBELN = EM_F01.EBELB
					AND EKKO.MANDT = EM_F01.MANDT
			LEFT JOIN (Select message, EBELB, MANDT FROM [CT dwh 01 Stage].[dbo].[tSAP_EKKO_messages] with (nolock) where TextID = 'F05') AS EM_F05
				on EKKO.EBELN = EM_F05.EBELB
				AND EKKO.MANDT = EM_F05.MANDT
        WHERE
            1 = 1
            AND EKPO.LOEKZ not in ('L'
                                 , 'X') --//Anforderung: DEVTCK-17066
        UNION ALL
        -- andere DocmentTypes (außer DeliveryNotes, die kommen extra)
        SELECT
            NULL                                                        AS CompanyId
          , ISNULL(TTC.TransactionType, 'Other')                        AS TransactionType
          , ISNULL(TTC.TransactionTypeDetail, 'Bestellung Andere EKBE') AS TransactionTypeDetail
          , RIGHT(EKBE.[MATNR], 8)                                      AS ItemNo
            --, MARA.[MFRNR]                                                AS ModelName
          , TMP_ModelName.ModelName   AS ModelName
          , ''                        AS [Description]
          , ph.ProductHierarchie1_txt AS ProductHierarchie1
          , ph.ProductHierarchie2_txt AS ProductHierarchie2
          , ph.ProductHierarchie3_txt AS ProductHierarchie3
          , brand.USER_VKMarke        AS Brand
          , MARA.MSTAE                AS EOL
          , ''                        AS Dispatcher
          , MARA.VOLUM                AS Volume
          , MARA.LAENG                AS [Length]
          , MARA.BREIT                AS Width
          , MARA.HOEHE                AS Height
          , MARA.MTART                AS ItemType
          , EKBE.WAERS                AS Currency
          , CASE
                WHEN TTC.TransactionType = 'StockReceipt'
                    THEN EKBE.BUDAT
                    ELSE EKBE.BLDAT
            END                       AS TransactionDate
          , EKBE.MENGE                AS Quantity
          , case
                when EKBE.MENGE > 0
                    then EKBE.WRBTR/EKBE.MENGE
                    ELSE 0
            end AS ItemPriceForeignCurrency
            --, EKBE.BPMNG                                                  AS ItemPriceForeignCurrency
          , case
                when EKBE.MENGE > 0
                    then EKBE.DMBTR/EKBE.MENGE
                    ELSE 0
            end AS ItemPrice
            --, case when EKBE.MENGE > 0 then EKBE.DMBTR/EKBE.MENGE ELSE 0 end AS ItemPrice
          , (EKBE.WRBTR) AS ValueForeignCurrency
            --, (ABS(EKBE.WRBTR))           AS ValueForeignCurrency
          , (EKBE.DMBTR) AS [Value]
            --, (ABS(EKBE.DMBTR))           AS [Value]
          , ABS(EKBE.WKURS) AS ExchangeRate
          , EKBE.BUDAT      AS PostingDate
            --, EKBE.EBELN                                                  AS DocumentNo // FT am 23.07.2020
            -- lt. https://jira.chal-tec.com/browse/DEVTCK-16637 soll EKKO.EBELN nun die ProcessID sein
          , EKBE.EBELN AS ProcessID
          , EKBE.EBELP AS ProcessPosition -- FT: 07.08.2020
          , EKBE.BELNR AS DocumentNo
          , NULL       AS MaterialReadyDate
          , NULL       AS PlannedQCDate
          , NULL       AS PlannedETD
          , NULL       AS ETD
          , NULL       AS Paymentterms
          , NULL       AS Incoterms
          , NULL       AS CreditorsName
          , NULL       AS SupplierCode
          , NULL       AS CreditorsNumber
          , NULL       AS SupplierGroupNumber
            --, CASE
            --      WHEN EKES.[EBTYP] = 'Z3'
            --          THEN -1
            --          ELSE 0
            --  END AS DeliveryAdvise
          , case
                when
                    (
                        select
                            EBTYP
                        from
                            (
                                SELECT
                                    top 1 EBTYP
                                FROM
                                    [CT dwh 01 Stage].[dbo].[tSAP_EKES] AS EKES WITH (NOLOCK)
                                where
                                    EKBE.MANDT     = EKES.MANDT
                                    AND EKBE.EBELN = EKES.EBELN
                                    and ekes.ebtyp = 'Z3'
                            )
                            as x
                    )
                    = 'Z3'
                    then -1
                    else 0
            end  as DeliveryAdvise
          , NULL AS DueDate
            /*,CASE
            WHEN EKES.[EBTYP] = 'Z3'
            THEN -1
            ELSE 0
            END AS BookingConfirmed
            */
          , case
                when
                    (
                        select
                            EBTYP
                        from
                            (
                                SELECT
                                    top 1 EBTYP
                                FROM
                                    [CT dwh 01 Stage].[dbo].[tSAP_EKES] AS EKES WITH (NOLOCK)
                                where
                                    EKBE.MANDT     = EKES.MANDT
                                    AND EKBE.EBELN = EKES.EBELN
                                    and ekes.ebtyp = 'Z3'
                            )
                            as x
                    )
                    = 'Z3'
                    then -1
                    else 0
            end as BookingConfirmed
          , CASE 
                WHEN LIS.[ZZETA] < '1753-01-01'
                    THEN '1753-01-01'
                    ELSE LIS.[ZZETA]
            END AS ETAPort
		  /*
		  changed on 21.12.2021/FT: https://jira.chal-tec.com/browse/DEVTCK-20904
		  CASE
                WHEN LIKP.[ZZ_ETAPORT] < '1753-01-01'
                    THEN '1753-01-01'
                    ELSE LIKP.[ZZ_ETAPORT]
            END AS ETAPort
			*/
          , CASE
                WHEN TTC.TransactionType = 'DeliveryNote'
                    THEN LIKP.[TRAID]
                    ELSE NULL
            END  AS ContainerNumber
          , NULL AS PercentageDesposit
          , NULL AS OutboundHarbour
          , NULL AS InboundHarbour
          , (ROW_NUMBER() OVER (PARTITION BY
                                CASE
                                    WHEN EKBE.WERKS = ''
                                        THEN '1000'
                                        ELSE EKBE.WERKS
                                END, TTC.TransactionType, EKBE.EBELN, EKBE.[MATNR] ORDER BY
                                EKBE.BUDAT)) AS PositionIdRC
          , EKET.EINDT                       as ETAWarehouse
		  , NULL as ImportDutiesPlan
		  , NULL as SeaFreightPlan
		  , NULL as OperationCostPlan
		  , NULL as ImportDutiesPlanFC
		  , NULL as SeaFreightPlanFC
		  , NULL as OperationCostPlanFC
		  , NULL AS ForwarderReference
		  , NULL AS SupplierReference
		  , NULL AS ProcessIDCreationDate
		  , NULL AS ProcessIDLastChangeDate
		  , NULL AS ProcessFulfilled
		  , NULL as Forwarder
		  , NULL as DeliveryNoteStatus
		  , EKBE.WERKS as Plant
		  , NULL as CommunityCode
		  , NULL as StorageLocation
		  , NULL as ContractNumber		--changed
		  , NULL as PortOfDischarg		--changed
		  , NULL as PortOfLoading		--changed
		  , NULL as TransportMode		--changed
        FROM
             [CT dwh 01 Stage].[dbo].[tSAP_EKBE] AS EKBE WITH (NOLOCK)
            INNER JOIN
                [CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAPEKBE] AS TTC WITH (NOLOCK)
                ON
                    (
                        EKBE.VGABE     = TTC.VGABE
                        AND EKBE.BWART = ISNULL(TTC.BWART,'')
                        AND EKBE.SHKZG = ISNULL(TTC.SHKZG,'')
                    )
            LEFT JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_MATERIAL_ATTR] AS MARA WITH (NOLOCK)
                ON
                    MARA.MATNR = EKBE.MATNR
            LEFT JOIN
                (
                    SELECT
                        MATNR
					  , MANDT
                      , IDNLF AS ModelName
                      , ROW_NUMBER() OVER (PARTITION BY MATNR ORDER BY
                                           INFNR DESC) AS Anzahl
                    FROM
                        [CT dwh 01 Stage].[dbo].[tSAP_EINA] WITH (NOLOCK)
                    WHERE
                        1 = 1
                )
                AS TMP_ModelName
                ON
                    MARA.MATNR               = TMP_ModelName.MATNR
                    AND TMP_ModelName.Anzahl = 1
					AND EKBE.MANDT			 = TMP_ModelName.MANDT
            LEFT JOIN
                (
                    SELECT
                        MANDT
                      , EBELN
                      , EBELP
                      , ETENS
                      , EBTYP
                      , VBELN
                      , ROW_NUMBER() OVER (PARTITION BY MANDT, EBELN, EBELP ORDER BY
                                           ETENS DESC) AS IdRC
                    FROM
                         [CT dwh 01 Stage].[dbo].[tSAP_EKES] AS EKES WITH (NOLOCK)
                )
                AS EKES
                ON
                    EKBE.MANDT     = EKES.MANDT
                    AND EKBE.EBELN = EKES.EBELN
                    AND EKBE.EBELP = EKES.EBELP
                    AND EKES.IdRC  = 1
					AND EKBE.ETENS = EKES.ETENS
            LEFT JOIN
					(
					SELECT DISTINCT
						VBELN
						, TRAID
					FROM #tSAPZ_MM_LIKP_LIPS WITH (NOLOCK)
					WHERE 1 = 1
					) AS LIKP
                    ON EKES.VBELN = LIKP.VBELN
			LEFT JOIN	--changed on 21.12.2021/FT: https://jira.chal-tec.com/browse/DEVTCK-20904
                 [CT dwh 02 Data].[dbo].[tSAP2LIS_02_HDR] AS LIS WITH (NOLOCK)
                ON
                    LIS.EBELN	= EKES.EBELN
					AND LIS.is_current = 1 --changed
            LEFT JOIN
                [CT dwh 02 Data].[dbo].[vProductHierarchieSAP] ph with (nolock)
                on
                    MARA.PRDHA = ph.ProductHierarchie3
            LEFT JOIN
                (
                    SELECT
                        Artikelnummer
                      , USER_VKMarke
                    FROM
                        [CT dwh 02 Data].[dbo].[tErpKHKArtikel] AS Art WITH (NOLOCK)
                    WHERE
                        1                          = 1
                        AND Mandant                = 1
                        AND Artikelnummer       LIKE '[17]%'
                        AND USER_VKMarke IS NOT NULL
                )
                brand
                on
                    RIGHT(EKBE.MATNR, 8) = brand.Artikelnummer
            LEFT JOIN
                 [CT dwh 01 Stage].[dbo].[tSAP_EKET] EKET with (nolock)
                on
                    EKET.MANDT     = EKBE.MANDT
                    AND EKET.EBELN = EKBE.EBELN
                    AND EKET.EBELP = EKBE.EBELP		
        WHERE
            TTC.VGABE not in ('8') -- DeliveryNotes müssen wir extra behandeln -> Ticket 17100 vom 20.08.2020
        
		UNION ALL
        SELECT
            NULL    	                                                AS CompanyId
          , ISNULL(TTC.TransactionType, 'Other')                        AS TransactionType
          , ISNULL(TTC.TransactionTypeDetail, 'Bestellung Andere EKBE') AS TransactionTypeDetail
          , RIGHT(LIKP_LIPS.[MATNR], 8)                                      AS ItemNo
          , NULL                                                        AS ModelName
          , ''                                                          AS [Description]
          , NULL                                                        AS ProductHierarchie1
          , NULL                                                        AS ProductHierarchie2
          , NULL                                                        AS ProductHierarchie3
          , NULL                                                        AS Brand
          , NULL                                                        AS EOL
          , ''                                                          AS Dispatcher
          , NULL                                                        AS Volume
          , NULL                                                        AS [Length]
          , NULL                                                        AS Width
          , NULL                                                        AS Height
          , NULL                                                        AS ItemType
          , NULL                                                        AS Currency
          , LIKP_LIPS.ERDAT                                                  AS TransactionDate
          , LIKP_LIPS.LFIMG                                                  AS Quantity
          , 0                                                           AS ItemPriceForeignCurrency
          , 0                                                           AS ItemPrice
          , 0                                                           AS ValueForeignCurrency
          , 0                                                           AS [Value]
          , 0                                                           AS ExchangeRate
          , NULL                                                        AS PostingDate
          , LIKP_LIPS.VGBEL                                                  AS ProcessID
          , RIGHT(LIKP_LIPS.VGPOS, 5)                                        AS ProcessPosition -- FT: 07.08.2020  -- kommt 6 stellig aus der LIPS.VGPOS
          , LIKP_LIPS.VBELN                                                  AS DocumentNo
          , NULL                                                        AS MaterialReadyDate
          , NULL                                                        AS PlannedQCDate
          , NULL                                                        AS PlannedETD
          , NULL                                                        AS ETD
          , NULL                                                        AS Paymentterms
          , NULL                                                        AS Incoterms
          , NULL                                                        AS CreditorsName
          , NULL                                                        AS SupplierCode
          , NULL                                                        AS CreditorsNumber
          , NULL                                                        AS SupplierGroupNumber
          , NULL                                                        AS DeliveryAdvise
          , NULL                                                        AS DueDate
          , NULL                                                        AS BookingConfirmed
          , NULL                                                        AS ETAPort
          , LIKP_LIPS.[TRAID]                                                AS ContainerNumber
          , NULL                                                        AS PercentageDesposit
          , NULL                                                        AS OutboundHarbour
          , NULL                                                        AS InboundHarbour
          , (ROW_NUMBER() OVER (PARTITION BY
                                CASE
                                    WHEN LIKP_LIPS.WERKS006 = ''
                                        THEN '1000'
                                        ELSE LIKP_LIPS.WERKS006
                                END, TTC.TransactionType, LIKP_LIPS.VBELN, LIKP_LIPS.[MATNR] ORDER BY
                                LIKP_LIPS.VGPOS)) AS PositionIdRC
          , NULL                             AS ETAWarehouse
		  , NULL														AS ImportDutiesPlan
		  , NULL														AS SeaFreightPlan
		  , NULL														AS OperationCostPlan
		  , NULL														AS ImportDutiesPlanFC
		  , NULL														AS SeaFreightPlanFC
		  , NULL														AS OperationCostPlanFC
		  , NULL														AS ForwarderReference
		  , NULL														AS SupplierReference
		  , NULL														AS ProcessIDCreationDate
		  , NULL														AS ProcessIDLastChangeDate
		  , NULL														AS ProcessFulfilled
		  , NULL														AS Forwarder
		  , LIKP_LIPS.VLSTK													AS DeliveryNoteStatus
		  , LIKP_LIPS.WERKS006													AS Plant
		  , NULL														AS CommunityCode
		  , NULL														AS StorageLocation
		  , NULL														AS ContractNumber		--changed
		  , NULL														AS PortOfDischarg		--changed
		  , NULL														AS PortOfLoading		--changed
		  , NULL														AS TransportMode		--changed

        FROM
             #tSAPZ_MM_LIKP_LIPS AS LIKP_LIPS WITH (NOLOCK)
            INNER JOIN
                [CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAPEKBE] AS TTC WITH (NOLOCK)
                ON
                    (
                        '8'      = TTC.VGABE -- nur DeliveryNotes
                        AND '' = ISNULL(TTC.BWART,'')
                        AND '' = ISNULL(TTC.SHKZG,'')
                    )
			-- wir holen uns hier die Bestellungen, um zu prüfen, ob wir DeliveryNotes haben, die keiner Bestellung mehr zugrunde liegen
			-- diese möchten wir natürlich nicht verarbeiten, da wir diese später nicht verbinden können und es somit zum Fehler kommt.
			LEFT JOIN (
				select 
					EKKO.EBELN as ProcessId
					, EKPO.EBELP as ProcessPosition
					, EKKO.BSART
					, EKKO.BSTYP
					, EKPO.LOEKZ 
					, EKPO.MANDT
				from 
					 [CT dwh 01 Stage].[dbo].[tSAP_EKPO] AS EKPO WITH (NOLOCK)
				INNER JOIN 
					 [CT dwh 01 Stage].[dbo].[tSAP_EKKO] AS EKKO WITH (NOLOCK)
					ON EKPO.EBELN = EKKO.EBELN
						AND EKPO.MANDT = EKKO.MANDT
				INNER JOIN
				-- alle ausgrenzen, deren TransactionType wir nicht berücksichtigen
					[CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAP] AS TTC2 WITH (NOLOCK)
					ON
						EKKO.BSTYP     = TTC2.BSTYP
						AND EKKO.BSART = TTC2.BSART
				-- und alle auslassen, deren Order ein Loeschkennzeichen hat
				WHERE EKPO.LOEKZ not in ('X', 'L')
			) as EKPO
			on 
				EKPO.ProcessId = LIKP_LIPS.VGBEL 
				AND EKPO.ProcessPosition = right(LIKP_LIPS.VGPOS, 5)
		WHERE
		-- //15.10.2020 DEVTCK-17593
            LIKP_LIPS.WERKS006 in (1000, 1100)
            --AND LIPS.LGORT in ('1000'		--// 15.10.2020 DEVTCK-17593
            --                 , '1004') 
			AND LIKP_LIPS.POSNR like '9%'
            --AND LIPS.LFIMG != 0
			--and LIPS.VGBEL = '4501000069' -- lt. Definition des Tickets 17100
            --and LIPS.CHARG != 'A'
			-- https://jira.chal-tec.com/browse/DEVTCK-17163 -> see this ticket and comment from Frank Tylinski (27.08.2020)
			--AND LIPS.VGBEL != ''			-- es gibt DeliveryNotes, die haben kein VGBEL. Dadurch das das unser Matching-Kriterium ist, passt später keine Bestellung und der Datensatz ist leer und verursacht Fehler bei der Übertragung in das ChalTecDWH
		-- Neu: OutboundDeliveryNotes
		UNION ALL
		SELECT
            NULL    	                                                AS CompanyId
          , ISNULL(TTC.TransactionType, 'Other')                        AS TransactionType
          , ISNULL(TTC.TransactionTypeDetail, 'Bestellung Andere EKBE') AS TransactionTypeDetail
          , RIGHT(LIKP_LIPS.[MATNR], 8)                                      AS ItemNo
          , NULL                                                        AS ModelName
          , ''                                                          AS [Description]
          , NULL                                                        AS ProductHierarchie1
          , NULL                                                        AS ProductHierarchie2
          , NULL                                                        AS ProductHierarchie3
          , NULL                                                        AS Brand
          , NULL                                                        AS EOL
          , ''                                                          AS Dispatcher
          , NULL                                                        AS Volume
          , NULL                                                        AS [Length]
          , NULL                                                        AS Width
          , NULL                                                        AS Height
          , NULL                                                        AS ItemType
          , NULL                                                        AS Currency
          , LIKP_LIPS.ERDAT                                                  AS TransactionDate
          , LIKP_LIPS.LFIMG                                                  AS Quantity
          , 0                                                           AS ItemPriceForeignCurrency
          , 0                                                           AS ItemPrice
          , 0                                                           AS ValueForeignCurrency
          , 0                                                           AS [Value]
          , 0                                                           AS ExchangeRate
          , NULL                                                        AS PostingDate
          , LIKP_LIPS.VGBEL                                                  AS ProcessID
          , RIGHT(LIKP_LIPS.VGPOS, 5)                                        AS ProcessPosition -- FT: 07.08.2020  -- kommt 6 stellig aus der LIPS.VGPOS
		  --, RIGHT(LIPS.POSNR, 5)										AS ProcessPosition --FT: 23.10.2020 -- für ausgehende soll die POSNR unsere Verknüpfung sein?!				
          , LIKP_LIPS.VBELN                                                  AS DocumentNo
          , NULL                                                        AS MaterialReadyDate
          , NULL                                                        AS PlannedQCDate
          , NULL                                                        AS PlannedETD
          , NULL                                                        AS ETD
          , NULL                                                        AS Paymentterms
          , NULL                                                        AS Incoterms
          , NULL                                                        AS CreditorsName
          , NULL                                                        AS SupplierCode
          , NULL                                                        AS CreditorsNumber
          , NULL                                                        AS SupplierGroupNumber
          , NULL                                                        AS DeliveryAdvise
          , NULL                                                        AS DueDate
          , NULL                                                        AS BookingConfirmed
          , NULL                                                        AS ETAPort
          , LIKP_LIPS.[TRAID]                                                AS ContainerNumber
          , NULL                                                        AS PercentageDesposit
          , NULL                                                        AS OutboundHarbour
          , NULL                                                        AS InboundHarbour
          , (ROW_NUMBER() OVER (PARTITION BY
                                CASE
                                    WHEN LIKP_LIPS.WERKS006 = ''
                                        THEN '1000'
                                        ELSE LIKP_LIPS.WERKS006
                                END, TTC.TransactionType, LIKP_LIPS.VBELN, LIKP_LIPS.[MATNR] ORDER BY
                                LIKP_LIPS.VGPOS)) AS PositionIdRC
          , NULL                             AS ETAWarehouse
		  , NULL														AS ImportDutiesPlan
		  , NULL														AS SeaFreightPlan
		  , NULL														AS OperationCostPlan
		  , NULL														AS ImportDutiesPlanFC
		  , NULL														AS SeaFreightPlanFC
		  , NULL														AS OperationCostPlanFC
		  , NULL														AS ForwarderReference
		  , NULL														AS SupplierReference
		  , NULL														AS ProcessIDCreationDate
		  , NULL														AS ProcessIDLastChangeDate
		  , NULL														AS ProcessFulfilled
		  , NULL														AS Forwarder
		  , LIKP_LIPS.VLSTK													AS DeliveryNoteStatus
		  , LIKP_LIPS.WERKS006													AS Plant
		  , NULL														AS CommunityCode
		  , NULL														AS StorageLocation
		  , NULL														AS ContractNumber		--changed
		  , NULL														AS PortOfDischarg		--changed
		  , NULL														AS PortOfLoading		--changed
		  , NULL														AS TransportMode		--changed
        FROM
             #tSAPZ_MM_LIKP_LIPS AS LIKP_LIPS WITH (NOLOCK)
            INNER JOIN
                [CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAPEKBE] AS TTC WITH (NOLOCK)
                ON
                    (
                        'X'      = TTC.VGABE -- nur DeliveryNotes
                        AND '' = ISNULL(TTC.BWART,'')
                        AND '' = ISNULL(TTC.SHKZG,'')
                    )
			-- wir holen uns hier die Bestellungen, um zu prüfen, ob wir DeliveryNotes haben, die keiner Bestellung mehr zugrunde liegen
			-- diese möchten wir natürlich nicht verarbeiten, da wir diese später nicht verbinden können und es somit zum Fehler kommt.
			LEFT JOIN (
				select 
					EKKO.EBELN as ProcessId
					, EKPO.EBELP as ProcessPosition
					, EKKO.BSART
					, EKKO.BSTYP
					, EKPO.LOEKZ 
					, EKPO.MANDT
				from 
					 [CT dwh 01 Stage].[dbo].[tSAP_EKPO] AS EKPO WITH (NOLOCK)
				INNER JOIN 
					 [CT dwh 01 Stage].[dbo].[tSAP_EKKO] AS EKKO WITH (NOLOCK)
					ON EKPO.EBELN = EKKO.EBELN
						AND EKPO.MANDT = EKKO.MANDT
				INNER JOIN
				-- alle ausgrenzen, deren TransactionType wir nicht berücksichtigen
					[CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSAP] AS TTC2 WITH (NOLOCK)
					ON
						EKKO.BSTYP     = TTC2.BSTYP
						AND EKKO.BSART = TTC2.BSART
				-- und alle auslassen, deren Order ein Loeschkennzeichen hat
				WHERE EKPO.LOEKZ not in ('X', 'L')
			) as EKPO
			on 
				EKPO.ProcessId = LIKP_LIPS.VGBEL 
				AND EKPO.ProcessPosition = right(LIKP_LIPS.VGPOS, 5)
				
		WHERE
			-- //15.10.2020 DEVTCK-17593
			--    LIPS.WERKS in (1000, 1100)
			-- keine Werks, da immer 5100
			1=1
			and LIKP_LIPS.VBELN like '008%'
			and LIKP_LIPS.POSNR like '0%'
			
       )
    AS s
ON
    (
        t.ItemNo         =s.ItemNo
        --AND t.CompanyId  = s.CompanyId
        and t.DocumentNo = s.DocumentNo
        --and t.PositionIdRC    = s.PositionIdRC -- ?? should we also change this to EBELP ? PositionIdRC looks anyways a little bit strange to me, regarding the definition behind it (18.08.2020, Micha)
        and t.ProcessPosition = s.ProcessPosition
        and t.TransactionType = s.TransactionType
		and t.Plant = s.Plant
    )
WHEN MATCHED
    AND t.TransactionType         <>s.TransactionType
    OR t.TransactionTypeDetail    <>s.TransactionTypeDetail
    OR t.ModelName                <>s.ModelName
    OR t.[Description]            <>s.[Description]
    OR t.ProductHierarchie1       <>s.ProductHierarchie1
    OR t.ProductHierarchie2       <>s.ProductHierarchie2
    OR t.ProductHierarchie3       <>s.ProductHierarchie3
    OR t.Brand                    <>s.Brand
    OR t.EOL                      <>s.EOL
    OR t.Dispatcher               <>s.Dispatcher
    OR t.Volume                   <>s.Volume
    OR t.[Length]                 <>s.[Length]
    OR t.Width                    <>s.Width
    OR t.Height                   <>s.Height
    OR t.ItemType                 <>s.ItemType
    OR t.Currency                 <>s.Currency
    OR t.TransactionDate          <>s.TransactionDate
    OR t.Quantity                 <>s.Quantity
    OR t.ItemPriceForeignCurrency <>s.ItemPriceForeignCurrency
    OR t.ItemPrice                <>s.ItemPrice
    OR t.ValueForeignCurrency     <>s.ValueForeignCurrency
    OR t.[Value]                  <>s.[Value]
    OR t.ExchangeRate             <>s.ExchangeRate
    OR t.PostingDate              <>s.PostingDate
    OR t.DocumentNo               <>s.DocumentNo
    OR t.ProcessID                <>s.ProcessID
    OR t.ProcessPosition          <>s.ProcessPosition
    OR t.MaterialReadyDate        <>s.MaterialReadyDate
    OR t.PlannedQCDate            <>s.PlannedQCDate
    OR t.PlannedETD               <>s.PlannedETD
    OR t.ETD                      <>s.ETD
    OR t.Paymentterms             <>s.Paymentterms
    OR t.Incoterms                <>s.Incoterms
    OR t.SupplierCode             <>s.SupplierCode
    OR t.CreditorsNumber          <>s.CreditorsNumber
    OR t.SupplierGroupNumber      <>s.SupplierGroupNumber
    OR t.DeliveryAdvise           <>s.DeliveryAdvise
    OR t.DueDate                  <>s.DueDate
    OR t.ETAPort                  <>s.ETAPort
    OR t.ContainerNumber          <>s.ContainerNumber
    OR t.PercentageDesposit       <>s.PercentageDesposit
    OR t.OutboundHarbour          <>s.OutboundHarbour
    OR t.InboundHarbour           <>s.InboundHarbour
    OR t.ETAWarehouse             <>s.ETAWarehouse
    OR t.BookingConfirmed         <>s.BookingConfirmed 
	OR t.ImportDutiesPlan		  <>s.ImportDutiesPlan
	OR t.SeaFreightPlan			  <>s.SeaFreightPlan
	OR t.OperationCostPlan		  <>s.OperationCostPlan
	OR t.ProcurementCostsPlan	  <>(isnull(s.ImportDutiesPlan,0)+isnull(s.SeaFreightPlan,0)+isnull(s.OperationCostPlan,0))
	OR t.ImportDutiesPlanFC		  <>s.ImportDutiesPlanFC
	OR t.SeaFreightPlanFC		  <>s.SeaFreightPlanFC
	OR t.OperationCostPlanFC	  <>s.OperationCostPlanFC
	OR t.ProcurementCostsPlanFC	  <>(isnull(s.ImportDutiesPlanFC,0)+isnull(s.SeaFreightPlanFC,0)+isnull(s.OperationCostPlanFC,0))
	OR t.ForwarderReference		  <>s.ForwarderReference
	OR t.SupplierReference	      <>s.SupplierReference
	OR t.ProcessIDCreationDate	  <>s.ProcessIDCreationDate
	OR t.ProcessIDLastChangeDate  <>s.ProcessIDLastChangeDate
	OR t.ProcessFulfilled         <>s.ProcessFulfilled
	OR t.Forwarder				  <>s.Forwarder
	OR t.DeliveryNoteStatus       <>s.DeliveryNoteStatus
	OR t.CompanyId				  <>s.CompanyId
	OR t.CommodityCode			  <>s.CommodityCode
	OR t.Plant					  <>s.Plant
	OR t.StorageLocation		  <>s.StorageLocation
	OR t.ContractNumber			  <>s.ContractNumber		 --changed
	OR t.PortOfDischarg			  <>s.PortOfDischarg		 --changed
	OR t.PortOfLoading			  <>s.PortOfLoading			 --changed
	OR t.TransportMode			  <>s.TransportMode			 --changed
THEN
UPDATE
SET t.TransactionType          =s.TransactionType
  , t.TransactionTypeDetail    =s.TransactionTypeDetail
  , t.ModelName                =s.ModelName
  , t.[Description]            =s.[Description]
  , t.ProductHierarchie1       =s.ProductHierarchie1
  , t.ProductHierarchie2       =s.ProductHierarchie2
  , t.ProductHierarchie3       =s.ProductHierarchie3
  , t.Brand                    =s.Brand
  , t.EOL                      =s.EOL
  , t.Dispatcher               =s.Dispatcher
  , t.Volume                   =s.Volume
  , t.[Length]                 =s.[Length]
  , t.Width                    =s.Width
  , t.Height                   =s.Height
  , t.ItemType                 =s.ItemType
  , t.Currency                 =s.Currency
  , t.TransactionDate          =s.TransactionDate
  , t.Quantity                 =s.Quantity
  , t.ItemPriceForeignCurrency =s.ItemPriceForeignCurrency
  , t.ItemPrice                =s.ItemPrice
  , t.ValueForeignCurrency     =s.ValueForeignCurrency
  , t.[Value]                  =s.[Value]
  , t.ExchangeRate             =s.ExchangeRate
  , t.PostingDate              =s.PostingDate
  , t.DocumentNo               =s.DocumentNo
  , t.MaterialReadyDate        =s.MaterialReadyDate
  , t.PlannedQCDate            =s.PlannedQCDate
  , t.PlannedETD               =s.PlannedETD
  , t.ETD                      =s.ETD
  , t.Paymentterms             =s.Paymentterms
  , t.Incoterms                =s.Incoterms
  , t.CreditorsName            =s.CreditorsName
  , t.SupplierCode             =s.SupplierCode
  , t.CreditorsNumber          =s.CreditorsNumber
  , t.SupplierGroupNumber      =s.SupplierGroupNumber
  , t.DeliveryAdvise           =s.DeliveryAdvise
  , t.DueDate                  =s.DueDate
  , t.ETAPort                  =s.ETAPort
  , t.ContainerNumber          =s.ContainerNumber
  , t.PercentageDesposit       =s.PercentageDesposit
  , t.OutboundHarbour          =s.OutboundHarbour
  , t.InboundHarbour           =s.InboundHarbour
  , t.PositionIdRC             =s.PositionIdRC
  , t.IsChanged                =1
  , t.LastModified             =GETDATE()
  , t.ProcessID                =s.ProcessID
  , t.ETAWarehouse             =s.ETAWarehouse
  , t.BookingConfirmed         =s.BookingConfirmed
  , t.ProcessPosition          =s.ProcessPosition
  , t.ImportDutiesPlan		   =s.ImportDutiesPlan
  , t.SeaFreightPlan		   =s.SeaFreightPlan
  , t.OperationCostPlan		   =s.OperationCostPlan
  , t.ProcurementCostsPlan	   =(isnull(s.ImportDutiesPlan,0)+isnull(s.SeaFreightPlan,0)+isnull(s.OperationCostPlan,0))
  , t.ImportDutiesPlanFC	   =s.ImportDutiesPlanFC
  , t.SeaFreightPlanFC		   =s.SeaFreightPlanFC
  , t.OperationCostPlanFC	   =s.OperationCostPlanFC
  , t.ProcurementCostsPlanFC   =(isnull(s.ImportDutiesPlanFC,0)+isnull(s.SeaFreightPlanFC,0)+isnull(s.OperationCostPlanFC,0))
  , t.ForwarderReference	   =s.ForwarderReference
  , t.SupplierReference	       =s.SupplierReference
  , t.ProcessIDCreationDate	   =s.ProcessIDCreationDate
  , t.ProcessIDLastChangeDate  =s.ProcessIDLastChangeDate
  , t.ProcessFulfilled         =s.ProcessFulfilled
  , t.Forwarder				   =s.Forwarder
  , t.DeliveryNoteStatus       =s.DeliveryNoteStatus
  , t.CompanyId				   =s.CompanyId
  , t.CommodityCode			   =s.CommodityCode
  , t.Plant					   =s.Plant
  , t.StorageLocation		   =s.StorageLocation
  , t.ContractNumber		   =s.ContractNumber		 --changed
  , t.PortOfDischarg		   =s.PortOfDischarg		 --changed
  , t.PortOfLoading			   =s.PortOfLoading			 --changed
  , t.TransportMode			   =s.TransportMode			 --changed
WHEN NOT MATCHED BY TARGET THEN
INSERT
    (CompanyId
      , ItemNo
      , TransactionType
      , TransactionTypeDetail
      , ModelName
      , [Description]
      , ProductHierarchie1
      , ProductHierarchie2
      , ProductHierarchie3
      , Brand
      , EOL
      , Dispatcher
      , Volume
      , [Length]
      , Width
      , Height
      , ItemType
      , Currency
      , TransactionDate
      , Quantity
      , ItemPriceForeignCurrency
      , ItemPrice
      , ValueForeignCurrency
      , [Value]
      , ExchangeRate
      , PostingDate
      , DocumentNo
      , PositionIdRC
      , IsChanged
      , LastModified
      , ProcessID
      , ProcessPosition
      , MaterialReadyDate
      , PlannedQCDate
      , PlannedETD
      , ETD
      , Paymentterms
      , Incoterms
      , CreditorsName
      , SupplierCode
      , CreditorsNumber
      , SupplierGroupNumber
      , DeliveryAdvise
      , DueDate
      , ETAPort
      , ContainerNumber
      , PercentageDesposit
      , OutboundHarbour
      , InboundHarbour
      , ETAWarehouse
      , BookingConfirmed
	  , ImportDutiesPlan		
	  , SeaFreightPlan		
	  , OperationCostPlan		
	  , ProcurementCostsPlan
	  , ImportDutiesPlanFC
	  , SeaFreightPlanFC
	  , OperationCostPlanFC
	  , ProcurementCostsPlanFC
      , ForwarderReference
      , SupplierReference
	  , ProcessIDCreationDate
	  , ProcessIDLastChangeDate
	  , ProcessFulfilled
	  , Forwarder
	  , DeliveryNoteStatus
	  , StorageLocation
	  , CommodityCode
	  , Plant
	  , ContractNumber
	  , PortOfDischarg
	  , PortOfLoading 
	  , TransportMode 
    )
    VALUES
    (s.CompanyId
      , s.ItemNo
      , s.TransactionType
      , s.TransactionTypeDetail
      , s.ModelName
      , s.[Description]
      , s.ProductHierarchie1
      , s.ProductHierarchie2
      , s.ProductHierarchie3
      , s.Brand
      , s.EOL
      , s.Dispatcher
      , s.Volume
      , s.[Length]
      , s.Width
      , s.Height
      , s.ItemType
      , s.Currency
      , s.TransactionDate
      , s.Quantity
      , s.ItemPriceForeignCurrency
      , s.ItemPrice
      , s.ValueForeignCurrency
      , s.[Value]
      , s.ExchangeRate
      , s.PostingDate
      , s.DocumentNo
      , s.PositionIdRC
      , 1
      , GETDATE()
      , s.ProcessID
      , s.ProcessPosition
      , s.MaterialReadyDate
      , s.PlannedQCDate
      , s.PlannedETD
      , s.ETD
      , s.Paymentterms
      , s.Incoterms
      , s.CreditorsName
      , s.SupplierCode
      , s.CreditorsNumber
      , s.SupplierGroupNumber
      , s.DeliveryAdvise
      , s.DueDate
      , s.ETAPort
      , s.ContainerNumber
      , s.PercentageDesposit
      , s.OutboundHarbour
      , s.InboundHarbour
      , s.ETAWarehouse
      , s.BookingConfirmed
	  , s.ImportDutiesPlan		
	  , s.SeaFreightPlan		
	  , s.OperationCostPlan		
	  , (isnull(s.ImportDutiesPlan,0)	+ isnull(s.SeaFreightPlan,0) + isnull(s.OperationCostPlan,0))
	  , s.ImportDutiesPlanFC		
	  , s.SeaFreightPlanFC		
	  , s.OperationCostPlanFC		
	  , (isnull(s.ImportDutiesPlanFC,0)	+ isnull(s.SeaFreightPlanFC,0) + isnull(s.OperationCostPlanFC,0))
      , s.ForwarderReference
      , s.SupplierReference
	  , s.ProcessIDCreationDate
	  , s.ProcessIDLastChangeDate
	  , s.ProcessFulfilled
	  , s.Forwarder
	  , s.DeliveryNoteStatus
	  , s.StorageLocation
	  , s.CommodityCode
	  , s.Plant
	  , s.ContractNumber
	  , s.PortOfDischarg
	  , s.PortOfLoading 
	  , s.TransportMode 
    )
;

PRINT LTRIM(CAST(GETDATE() AS NVARCHAR(20))) + ' MERGE finished'

DROP TABLE #tSAPZ_MM_LIKP_LIPS

END

GO
/****** Object:  StoredProcedure [dbo].[spFactWeatherCreate]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spFactWeatherCreate] 
AS

IF  EXISTS (SELECT * FROM [CT dwh 03 Intelligence].sys.objects 
WHERE object_id = OBJECT_ID(N'[CT dwh 03 Intelligence].dbo.tFactWeather')  
AND type in ('U'))
DROP TABLE [CT dwh 03 Intelligence].dbo.tFactWeather;


SELECT  
CAST(CONVERT(CHAR(8),w.[Date],112) AS INT) [DateId] 
,ISNULL(c.[CityId], 1) as CityId
, w.[Date]
,w.[Temp] as Temperature
,w.[Temp_Min] as TemperatureMinimal
,w.[Temp_Max] as TemperatureMaximal
,w.[Pressure] as Pressure
,w.[Sea_level] as SeaLevel
,w.[Grnd_level] as GroundLevel
,w.[Humidity] as Humidity
,w.[Wind_speed] as WindSpeed
,w.[Wind_deg] as WindDegree
,w.[Rain_1h] as Rain1Hour
,w.[Rain_3h] as Rain3Hour
,w.[Rain_24h] as Rain24Hour
,w.[Rain_today] as RainToday
,w.[Snow_1h] as Snow1Hour
,w.[Snow_3h] as Snow3Hour
,w.[Snow_24h] as Snow24Hour
,w.[Snow_today] as SnowToday
,w.[Clouds_all] as CloudsAll
,w.[Weather_main] as WeatherMain
,w.[Weather_description] as WeatherDesription
INTO [CT dwh 03 Intelligence].dbo.tFactWeather
from tMktweather w 
left join tMktCityList c on c.ISOCityId = w.IsoCityId


ALTER TABLE [CT dwh 03 Intelligence].dbo.tFactWeather ALTER COLUMN CityId int NOT NULL
ALTER TABLE [CT dwh 03 Intelligence].dbo.tFactWeather ALTER COLUMN [Date] datetime NOT NULL

  
 ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactWeather] ADD  CONSTRAINT [pktFacttFactWeather] PRIMARY KEY CLUSTERED 
(
	[Date] ,
	[CityId] 
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,  ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]



ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactWeather]  WITH NOCHECK ADD  CONSTRAINT [fkFactWeatherDate] FOREIGN KEY([DateId])
REFERENCES [CT dwh 03 Intelligence].[dbo].tAuxPeriodBase ([DateId])
ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactWeather] NOCHECK CONSTRAINT [fkFactWeatherDate]


ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactWeather]  WITH NOCHECK ADD  CONSTRAINT [fkFactWeatherCity] FOREIGN KEY([CityId])
REFERENCES [CT dwh 03 Intelligence].[dbo].[tDimCity] ([CityId])
ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tFactWeather] NOCHECK CONSTRAINT [fkFactWeatherCity]


GO
/****** Object:  StoredProcedure [dbo].[spGAWCustomerHierarchyCreate]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spGAWCustomerHierarchyCreate] 
AS
declare @country table  (id int identity (1,1), name varchar(50)) 
insert @country values ('DE'), ('ES'), ('FR'), ('IT'), ('UK'), 
  ('AT'), ('BE'), ('CH'), ('FI'), ('IE'), ('NL'), ('PL'), ('PT'), ('SE')

declare @brand table  (id int identity (1,1), name varchar(50), short_name varchar(50)) 
insert @brand (name, short_name) values ('Auna', 'au'), ('Klarstein', 'ks'), ('Capital Sports', 'cs'), ('Numan', 'nu'), ('EStar', 'es'), ('EStar', 'ht')


declare @i int = 0, @j int = 0

declare @sqltext varchar(max) = 'insert into [dbo].[tGAWCustomerHierarchy] (CustomerId, ParentCustomerId, Level)
select CustomerId, 0 as ParentCustomerId, 1 as Level  
from [dbo].[tGAWCustomer] where customer_name = ''Chal-Tec''
union all
select CustomerId, (select CustomerID from [dbo].[tGAWCustomer] where customer_name = ''Chal-Tec'') as ParentCustomerId  , 2 as level
from [dbo].[tGAWCustomer] where customer_name in (''MCC Ceotra'', ''MCC Chal-Tec'')
union all
select CustomerId, (select CustomerID from [dbo].[tGAWCustomer] where customer_name = ''MCC Chal-Tec'') as ParentCustomerId, 3 as level
from [dbo].[tGAWCustomer] where customer_name like (''%MCC%Estar%'') and customer_name not in (''MCC Ceotra'', ''MCC Chal-Tec'')
union all
select CustomerId, (select CustomerID from [dbo].[tGAWCustomer] where customer_name = ''MCC Ceotra'') as ParentCustomerId, 3 as level
from [dbo].[tGAWCustomer] where customer_name like (''%MCC%'') and customer_name not like (''%Estar%'') and customer_name not in (''MCC Ceotra'', ''MCC Chal-Tec'')
'

select @i = max(id) from @country

while (@i > 0)
begin 
select @j = max(id) from @brand
while (@j > 0)
begin 
set @sqltext +=  
'union all select CustomerId, isnull((select CustomerID from [dbo].[tGAWCustomer]
where customer_name = ''MCC ' + isnull((select name from @brand where id = @j), '') +' ' + isnull((select name from @country where id = @i),'') +'''), 0)  as ParentCustomerId, 4 as level 
from [dbo].[tGAWCustomer] where customer_name like (''%' + isnull((select name from @country where id = @i),'') +' ' + isnull((select short_name from @brand where id = @j),'')+'%'') '

set @j = @j-1
end
set @i = @i-1
end 

set @sqltext +=  ' union all
select CustomerId,isnull((select CustomerID from [dbo].[tGAWCustomer]  where customer_name = ''MCC EStar BE''), 0)  as ParentCustomerId, 4 as level from [dbo].[tGAWCustomer] where customer_name like (''%BF %es%'') 
union all 
select CustomerId,isnull((select CustomerID from [dbo].[tGAWCustomer]  where customer_name = ''MCC EStar BE''), 0)  as ParentCustomerId, 4 as level from [dbo].[tGAWCustomer] where customer_name like (''%BD %es%'') 
union all 
select CustomerId,isnull((select CustomerID from [dbo].[tGAWCustomer]  where customer_name = ''MCC EStar CH''), 0)  as ParentCustomerId, 4 as level from [dbo].[tGAWCustomer] where customer_name like (''%CF %es%'') 
union all 
select CustomerId,isnull((select CustomerID from [dbo].[tGAWCustomer]  where customer_name = ''MCC EStar CH''), 0)  as ParentCustomerId, 4 as level from [dbo].[tGAWCustomer] where customer_name like (''%CI %es%'') 
union all
select CustomerId,isnull((select CustomerID from [dbo].[tGAWCustomer]  where customer_name = ''MCC EStar UK''), 0)  as ParentCustomerId, 4 as level from [dbo].[tGAWCustomer] where customer_name = ''DE ep SEM 00 EBR''
union all
select CustomerId,isnull((select CustomerID from [dbo].[tGAWCustomer]  where customer_name = ''MCC EStar UK''), 0)  as ParentCustomerId, 4 as level from [dbo].[tGAWCustomer] where customer_name = ''DE HR Recruiting SEM''
'

truncate table [dbo].[tGAWCustomerHierarchy]
--select  @sqltext
exec (@sqltext)


delete from [dbo].[tGAWCustomerHierarchy] where CustomerId = ParentCustomerId

--delete [dbo].[tGAWCustomerHierarchy] 
--from [tGAWCustomerHierarchy] h 
--inner join [dbo].[tGAWCustomer] c on c.CustomerId = h.CustomerId
--where (c.customer_name like '%old%' or c.customer_name like '%test%')

DELETE [dbo].[tGAWCustomerHierarchy] 
FROM [tGAWCustomerHierarchy] h 
  INNER JOIN [dbo].[tGAWCustomer] c
    ON c.CustomerId = h.CustomerId
WHERE h.ParentCustomerId = 0 and c.customer_name <> 'Chal-Tec'
GO
/****** Object:  StoredProcedure [dbo].[spLoadDeliveryNotesLogisticsTemp]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE Proc [dbo].[spLoadDeliveryNotesLogisticsTemp]
AS

BEGIN

DECLARE @start_time DATETIME = GETDATE()
PRINT LTRIM(GETDATE()) + ' START!';

DROP TABLE IF EXISTS [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp_loading]
CREATE TABLE [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp_loading](
	[DeliveryNotesLogisticsTempId] [bigint] IDENTITY(1,1) NOT NULL, [DeliveryNumber] [nvarchar](12) NULL, [DeliveryPosition] [nvarchar](6) NULL, [PONo] [nvarchar](12) NULL, [POPosition] [nvarchar](6) NULL, [ProductionOrderNo] [nvarchar](12) NULL,
	[DeliveryDistributionStatus] [nvarchar](1) NULL, [MovementCode] [nvarchar](3) NULL, [MovementType] [nvarchar](4) NULL, [DeliveryType] [nvarchar](4) NULL, [SalesDocCateg] [nvarchar](4) NULL, [DeliverySubType] [nvarchar](4) NULL,
	[TransportType] [nvarchar](4) NULL, [ContainerId] [nvarchar](20) NULL, [Quantity] [decimal](13, 3) NULL, [Unit] [nvarchar](3) NULL, [Shipping_Recvng_point] [nvarchar](4) NULL, [StorageLocation1] [nvarchar](4) NULL, [profitCentre] [nvarchar](10) NULL,
	[DeliveryItemNo] [int] NULL, [Batch] [nvarchar](10) NULL, [VOLEH] [nvarchar](3) NULL, [VOLUM] [decimal](15, 3) NULL, [MaterialGroup] [nvarchar](9) NULL, [DeliveryCreationDate] [date] NULL, [DeliveryDate] [date] NULL, [BillingDate] [date] NULL,
	[Vendor] [nvarchar](10) NULL, [Incoterms1] [nvarchar](3) NULL, [Incoterms] [nvarchar](28) NULL, [OutboundHarbour] [nvarchar](100) NULL, [InboundHarbour] [nvarchar](100) NULL, [Deliverycreationdatetime] [datetime2](7) NULL, [Plant1] [nvarchar](4) NULL,
	[Receiving_Plant] [nvarchar](4) NULL, [Source] [varchar](4) NULL, [SupplierCode] [varchar](50) NULL, [ModelName] [varchar](100) NULL, [Description] [varchar](100) NULL, [Brand] [varchar](100) NULL, [EOL] [varchar](2) NULL, [Volume] [float] NULL,
	[TEU] [money] NULL, [Length] [int] NULL, [Width] [int] NULL, [Height] [int] NULL, [ItemType] [varchar](4) NULL, [Forwarder] [varchar](50) NULL, [ETA WH] [date] NULL, [ETAPort] [datetime] NULL, [DeliveryAdvise] [smallint] NULL, [ProcessId] [bigint] NULL,
	[CompanyId] [smallint] NULL, [SupplierGroupNumber] [varchar](15) NULL, [SupplierReference] [varchar](1000) NULL, [ItemNo] [varchar](50) NULL, [Kitting?] [varchar](50) NULL, [ForwarderReference] [varchar](100) NULL, [OutboundHarbour1] [varchar](100) NULL,
	[InboundHarbour1] [varchar](100) NULL, [BookingConfirmed] [smallint] NULL, [DeliveryNoteItemPrice] [money] NULL, [DeliveryNoteValue] [money] NULL, [DeliveryNoteDocumentNo] [varchar](100) NULL, [DeliveryNoteStatus] [varchar](1) NULL,
	[Containernummer] [varchar](20) NULL, [ProcessIDCreationDate] [date] NULL, [ProcessIDLastChangeDate] [datetime] NULL, [ItemProcessFulfilled] [smallint] NULL, [ProcessFulfilled] [smallint] NULL, [ImportDutiesPlan] [money] NULL,
	[LastModified] [datetime] NULL, [ProcessPosition] [varchar](20) NULL, [StorageLocation] [varchar](4) NULL, [Dispatcher] [varchar](20) NULL, [QTY] [money] NULL, [DeletionIndicator] [bit] NULL, [TypeCategory] [nvarchar](4) NULL,
	CONSTRAINT [PK_tDeliveryNotesLogisticsTemp_loading] PRIMARY KEY CLUSTERED
(
	[DeliveryNotesLogisticsTempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];

ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp_loading] ADD  CONSTRAINT [DF__tDelivery__Delet__2075C9F0_loading]  DEFAULT ((0)) FOR [DeletionIndicator];

INSERT INTO [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp_loading] WITH(TABLOCK)
(
						[DeliveryNumber]
					  ,[DeliveryPosition]
					  ,[PONo]
					  ,[POPosition]
					  ,[ProductionOrderNo]
					  ,[DeliveryDistributionStatus]
					  ,[MovementCode]
					  ,[MovementType]
					  ,[DeliveryType]
					  ,[SalesDocCateg]
					  ,[DeliverySubType]
					  ,[TransportType]
					  ,[ContainerId]
					  ,[Quantity]
					  ,[Unit]
					  ,[Shipping_Recvng_point]
					  ,[StorageLocation1]
					  ,[profitCentre]
					  ,[DeliveryItemNo]
					  ,[Batch]
					  ,[VOLEH]
					  ,[VOLUM]
					  ,[MaterialGroup]
					  ,[DeliveryCreationDate]
					  ,[DeliveryDate]
					  ,[BillingDate]
					  ,[Vendor]
					  ,[Incoterms1]
					  ,[Incoterms]
					  ,[OutboundHarbour]
					  ,[InboundHarbour]
					  ,[Source]
					  ,[SupplierCode]
					  ,[ModelName]
					  ,[Description]
					  ,[Brand]
					  ,[EOL]
					  ,[Volume]
					  ,[TEU]
					  ,[Length]
					  ,[Width]
					  ,[Height]
					  ,[ItemType]
					  ,[Forwarder]
					  ,[ETA WH]
					  ,[ETAPort]
					  ,[DeliveryAdvise]
					  ,[ProcessId]
					  ,[CompanyId]
					  ,[SupplierGroupNumber]
					  ,[SupplierReference]
					  ,[ItemNo]
					  ,[Kitting?]
					  ,[ForwarderReference]
					  ,[OutboundHarbour1]
					  ,[InboundHarbour1]
					  ,[BookingConfirmed]
					  ,[DeliveryNoteItemPrice]
					  ,[DeliveryNoteValue]
					  ,[DeliveryNoteDocumentNo]
					  ,[DeliveryNoteStatus]
					  ,[Containernummer]
					  ,[ProcessIDCreationDate]
					  ,[ProcessIDLastChangeDate]
					  ,[ItemProcessFulfilled]
					  ,[ProcessFulfilled]
					  ,[ImportDutiesPlan]
					  ,[LastModified]
					  ,[ProcessPosition]
					  ,[StorageLocation]
					  ,[Dispatcher]
					  ,[QTY]
					  ,Deliverycreationdatetime
					  ,Plant1
					  ,Receiving_Plant
					  ,TypeCategory
                      ,DeletionIndicator
					  )
SELECT a.vbeln AS DeliveryNumber
	,a.posnr AS DeliveryPosition
	,VGBEL AS PONo
	,VGPOS AS POPosition
	,AUFNR AS ProductionOrderNo
	,vlstk AS DeliveryDistributionStatus
	,BWART AS MovementCode
	,MTART AS MovementType
	,LFART AS DeliveryType
	,VGTYP AS SalesDocCateg
	,vbtyp AS DeliverySubType
	,traty AS TransportType
	,traid AS ContainerId
	,LFIMG AS Quantity
	,MEINS AS Unit
	,VSTEL AS Shipping_Recvng_point
	,LGORT AS StorageLocation1
	,PRCTR AS profitCentre
	,cast(MATNR AS INT) AS DeliveryItemNo
	,CHARG AS Batch
	,VOLEH
	,VOLUM
	,MATKL AS MaterialGroup
	,erdat AS DeliveryCreationDate
	,lfdat AS DeliveryDate
	,FKDAT AS BillingDate
	,LIFNR AS Vendor
	,inco1 AS Incoterms1
	,inco2 AS Incoterms
	,INCO2_L AS OutboundHarbour
	,inco3_l AS InboundHarbour
	,b.[Source]
	,b.[SupplierCode]
	,b.[ModelName]
	,b.[Description]
	,b.[Brand]
	,b.[EOL]
	,b.[Volume]
	,b.[TEU]
	,[Length]
	,[Width]
	,[Height]
	,[ItemType]
	,[Forwarder]
	,[ETA WH]
	,ETAPort ETAPort
	,[DeliveryAdvise]
	,[ProcessId]
	,[CompanyId]
	,[SupplierGroupNumber]
	,[SupplierReference]
	,[ItemNo]
	,[Kitting?]
	,[ForwarderReference]
	,[OutboundHarbour] AS OutboundHarbour1
	,[InboundHarbour] AS InboundHarbour1
	,[BookingConfirmed]
	,[DeliveryNoteItemPrice]
	,[DeliveryNoteValue]
	,[DeliveryNoteDocumentNo]
	,[DeliveryNoteStatus]
	,[Containernummer]
	,[ProcessIDCreationDate]
	,[ProcessIDLastChangeDate]
	,[ItemProcessFulfilled]
	,[ProcessFulfilled]
	,[ImportDutiesPlan]
	,[LastModified]
	,[ProcessPosition]
	,[StorageLocation]
	,Dispatcher
	,(DeliveryNoteQuantity) QTY
	,cast(concat([ERDAT],' ',substring([ERZET],1,2),':',substring([ERZET],3,2),':',substring([ERZET],5,2)) as datetime2) as Deliverycreationdatetime
	,WERKS006 AS Plant1
	,WERKS AS Receiving_Plant
	,A.PSTYV AS TypeCategory
	,COALESCE(deletionind.DeletionIndicator, 0) DeletionIndicator
FROM [CT dwh 02 Data].dbo.tSAPZ_MM_LIKP_LIPS AS A with(nolock)
LEFT OUTER JOIN (
	SELECT DISTINCT c.OrderDocumentNo
		,c.[Source]
		,c.[SupplierCode]
		,c.[ModelName]
		,c.[Description]
		,c.[Brand]
		,c.[EOL]
		,c.[Volume]
		,c.[TEU]
		,[Length]
		,[Width]
		,[Height]
		,[ItemType]
		,[Forwarder]
		,[ETAWarehouse] [ETA WH]
		,ETAPort ETAPort
		,[DeliveryAdvise]
		,[ProcessId]
		,[CompanyId]
		,[SupplierGroupNumber]
		,[SupplierReference]
		,CASE 
			WHEN LEFT([ItemNo], 2) = '11'
				THEN '10' + RIGHT(Itemno, 6)
			ELSE ItemNo
			END [ItemNo]
		,CASE 
			WHEN LEFT(ITEMno, 2) = '11'
				THEN 'ist Kitting'
			ELSE 'kein Kitting'
			END [Kitting?]
		,[ForwarderReference]
		,[OutboundHarbour]
		,[InboundHarbour]
		,[BookingConfirmed]
		,[DeliveryNoteItemPrice]
		,[DeliveryNoteValue]
		,[DeliveryNoteDocumentNo]
		,[DeliveryNoteStatus]
		,[ContainerNumber] [Containernummer]
		,[ProcessIDCreationDate]
		,[ProcessIDLastChangeDate]
		,[ItemProcessFulfilled]
		,[ProcessFulfilled]
		,[ImportDutiesPlan]
		,[LastModified]
		,[ProcessPosition]
		,[StorageLocation]
		,Dispatcher
		,[DeliveryNoteQuantity]
		,POPosIsDeleted
	FROM [CT dwh 03 Intelligence].[dbo].[vFactPurchasingOrdersTransactions] c
	Where Source = 'SAP'
) AS b 
ON (
	a.vgbel = b.OrderDocumentNo
	AND cast(a.vgpos as int) = cast(b.ProcessPosition as int) --RIGHT(a.VGPOS, 5) = b.ProcessPosition 
/*
	AND b.DeliveryNoteQuantity > 0
	AND b.CompanyId = 1000
	AND b.POPosIsDeleted = 0 
*/
)
LEFT JOIN (
	SELECT cdpos.OBJECTID VBELN, RIGHT(cdpos.TABKEY,6) POSNR, 1 DeletionIndicator
	FROM [CT dwh 02 Data].[dbo].[tSAPZ_MM_CDHDR_CDPOS_L] AS cdpos WITH (NOLOCK)
	WHERE cdpos.TABNAME='LIPS'
	AND cdpos.CHNGIND = 'D'
	AND cdpos.OBJECTCLAS = 'Lieferung'
	AND cdpos.is_current = 1
) AS deletionind
ON a.VBELN = deletionind.VBELN AND a.POSNR = deletionind.POSNR
WHERE a.is_current = 1

DECLARE @total_rows_affected INT = @@rowcount;
PRINT LTRIM(GETDATE()) + ' Insert finished';

/**************************************************************************
** Update Deletiong flag in delivery document no is in cdpos_L
HB: 2022-06-03 - DWH -39
M.Kother: 2023-06.06 - New version to reflect also the positions DWH-1168 
***************************************************************************/

--UPDATE dev 
--SET DeletionIndicator = 1
--from  [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp]  dev
--INNER JOIN [CT dwh 02 Data].[dbo].[tSAPZ_MM_CDHDR_CDPOS_L] cdpos
--	on  dev.DeliveryNumber = cdpos.OBJECTID and TABNAME='LIKP'

-- M.Kother 06.06.2023 - New version to include also the positions

-- UPDATE dev 
-- SET DeletionIndicator = 1
-- FROM [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp_loading] AS dev
-- INNER JOIN [CT dwh 02 Data].[dbo].[tSAPZ_MM_CDHDR_CDPOS_L] AS cdpos WITH (NOLOCK)
-- 	ON  dev.DeliveryNumber = cdpos.OBJECTID 
-- 	AND dev.DeliveryPosition = RIGHT(cdpos.TABKEY,6)
-- 	AND cdpos.TABNAME='LIPS'
-- 	AND cdpos.CHNGIND = 'D'
-- 	AND cdpos.OBJECTCLAS = 'Lieferung'
-- 	AND cdpos.is_current = 1

-- PRINT LTRIM(GETDATE()) + ' Update DeletionIndicator finished';

CREATE NONCLUSTERED INDEX [NonClusteredIndextDeliveryNotesLogisticsTemp_loading] ON [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp_loading]
(
	[DeliveryNumber] ASC,
	[DeliveryPosition] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY];

PRINT LTRIM(GETDATE()) + ' New index created';

TRUNCATE TABLE [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp];

PRINT LTRIM(GETDATE()) + ' Facttable truncated';

ALTER TABLE [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp_loading] SWITCH TO [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp]

PRINT LTRIM(GETDATE()) + ' New data switched in';

DROP TABLE IF EXISTS [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesLogisticsTemp_loading]

PRINT LTRIM(GETDATE()) + ' Cleaned up loading table';

DECLARE @db_id INT = DB_ID()
EXEC [CT dwh 00 Meta]..sp_Log_ProcedureCall
    @object_id = @@PROCID,
    @database_id = @db_id,
    @total_rows_affected = @total_rows_affected,
    @start_time = @start_time
    -- @log_message = '';

PRINT LTRIM(GETDATE()) + ' END!'

END



GO
/****** Object:  StoredProcedure [dbo].[spLoadFactBaseDataToIntelligence]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spLoadFactBaseDataToIntelligence]
AS BEGIN
	/*
	-- select * from [CT dwh 03 Intelligence].[dbo].[tItemMasterData]
	-- at first, we truncate the whole table
	TRUNCATE TABLE [CT dwh 03 Intelligence].[dbo].[tItemMasterData]

	-- after that, we copy all rows from Stage Layer MARA-Table to Intelligence
	INSERT INTO [CT dwh 03 Intelligence].[dbo].[tItemMasterData]
	(
		   [MANDT]
		  ,[Material_MATNR]
		  ,[Created On]
		  ,[Created by]
		  ,[Last Change]
		  ,[Changed by]
		  ,[Compl. maint. status]
		  ,[Maintenance status]
		  ,[DF at client level]
		  ,[Material type]
		  ,[Industry Sector]
		  ,[Material Group]
		  ,[Old material number]
		  ,[Base Unit of Measure]
		  ,[Order Unit]
		  ,[Document]
		  ,[Document type]
		  ,[Doc. Version]
		  ,[Page format_ZEIFO]
		  ,[Document change no.]
		  ,[Page number]
		  ,[Number of sheets]
		  ,[Prod./insp. memo]
		  ,[Page format_FORMT]
		  ,[Size/dimensions]
		  ,[Basic material]
		  ,[Industry Std Desc.]
		  ,[Lab/Office]
		  ,[Purchasing value key]
		  ,[Gross weight]
		  ,[Net weight]
		  ,[Weight unit]
		  ,[Volume]
		  ,[Volume unit_VOLEH]
		  ,[Container reqmts]
		  ,[Storage conditions]
		  ,[Temp. conditions]
		  ,[Low-Level Code]
		  ,[Transportation Group]
		  ,[Haz. material number]
		  ,[Division]
		  ,[Competitor]
		  ,[EAN Number]
		  ,[Number of GR slips]
		  ,[Procurement rule]
		  ,[Source of supply]
		  ,[Season]
		  ,[Label type]
		  ,[Label form]
		  ,[Field deactivated]
		  ,[EAN/UPC]
		  ,[EAN category]
		  ,[Length]
		  ,[Width]
		  ,[Height]
		  ,[Unit of Dimension]
		  ,[Product hierarchy]
		  ,[Stock Transfer Net Change Costing]
		  ,[CAD Indicator]
		  ,[QM proc. active]
		  ,[Allowed pkg weight]
		  ,[Unit of weight]
		  ,[Allowed pkg volume]
		  ,[Volume unit_ERVOE]
		  ,[Excess wt tolerance]
		  ,[Excess volume tol.]
		  ,[Variable Purchase Order Unit]
		  ,[Revision Level Assgd]
		  ,[Material is configurable]
		  ,[Batch management]
		  ,[Packaging Mat. Type]
		  ,[Maximum level]
		  ,[Stackability factor]
		  ,[Matl Grp Pack.Matls]
		  ,[Authorization Group]
		  ,[Valid From_DATAB]
		  ,[Valid to]
		  ,[Season Year]
		  ,[Price Band Category]
		  ,[With empties BOM]
		  ,[Ext. Material Group]
		  ,[Cross-plant CM]
		  ,[Material Category]
		  ,[Co-product]
		  ,[Follow-up material]
		  ,[Pricing Ref. Matl]
		  ,[X-Plant Matl Status]
		  ,[X-distr.chain status]
		  ,[Valid from_MSTDE]
		  ,[Valid from_MSTDV]
		  ,[Tax classification]
		  ,[Catalog Profile]
		  ,[Min. Rem. Shelf Life]
		  ,[Total shelf life]
		  ,[Storage percentage]
		  ,[Content unit]
		  ,[Net contents]
		  ,[ComparisonPriceUnit]
		  ,[Labeling matl grpg]
		  ,[Gross contents]
		  ,[Conversion Method]
		  ,[Internal object no.]
		  ,[Environmentally rlvt]
		  ,[Product allocation]
		  ,[Pricing profile]
		  ,[Qual.f.FreeGoodsDis.]
		  ,[Manufacturer Part No.]
		  ,[Manufacturer]
		  ,[Int. material number]
		  ,[Mfr part profile]
		  ,[Units of meas. usage]
		  ,[Rollout]
		  ,[DG indicator profile]
		  ,[Highly viscous]
		  ,[In bulk/liquid]
		  ,[Serialization level]
		  ,[Closed]
		  ,[Appr.Batch Recd Req.]
		  ,[Assign effect. vals]
		  ,[Material completion level]
		  ,[Period Ind. for SLED]
		  ,[Rounding rule SLED]
		  ,[Product Composition]
		  ,[Gen. item cat. grp]
		  ,[Logistical variants]
		  ,[Material is locked]
		  ,[Indicator for relevance in CM]
		  ,[Assortment List Type]
		  ,[Expiration Date]
		  ,[EAN Variant]
		  ,[Generic Material]
		  ,[Reference matl for packing]
		  ,[GDS-Relevant]
		  ,[Origin Acceptance]
		  ,[Standard HU Type]
		  ,[Pilferable]
		  ,[WH Storage Condition]
		  ,[WH Material Group]
		  ,[Handling Indicator]
		  ,[Relevant for HS]
		  ,[Handling Unit Type]
		  ,[Varb. Tare Weight]
		  ,[Maximum Capacity]
		  ,[Overcapacity Toler.]
		  ,[Max. Pack. Length]
		  ,[Max. Pack. Width]
		  ,[Max. Pack. Height]
		  ,[Unit of Measurement]
		  ,[Country of origin]
		  ,[Material freight grp]
		  ,[Quarant. Per.]
		  ,[Quarantine Time Unit]
		  ,[Quality Inspection Group]
		  ,[Serial No. Profile]
		  ,[Form Name]
		  ,[Logistics Unit of Measure]
		  ,[Material Is a CW Material]
		  ,[CW Profile for CW Quantity]
		  ,[Catch Weight Tolerance Group]
		  ,[Adjustment Profile (Merchandise Distr.)]
		  ,[Intellectual Property]
		  ,[Variant Price Allowed]
		  ,[Medium]
		  ,[Commodity]
		  ,[Cont. Non-Textile Parts of Animal Origin]
		  ,[Textile Composition Maintenance Active]
		  ,[Last Changed Time]
		  ,[Material_MATNR_EXTERNAL]
		  ,[Category of a Logistical Material]
		  ,[Material Number of Sales Material]
		  ,[Identification Tag Type]
		  ,[Segmentation Structure]
		  ,[Segmentation Strategy]
		  ,[Segmentation Status]
		  ,[Segmentation Strategy Scope]
		  ,[Segmentation Relevant]
		  ,[ANP Code]
		  ,[Protected Species Management Code]
		  ,[Fashion Attribute 1]
		  ,[Fashion Attribute 2]
		  ,[Fashion Attribute 3]
		  ,[Season Usage]
		  ,[Season Active in Inventory Management]
		  ,[Material Conv. ID]
		  ,[Dummy Field]
		  ,[Product]
		  ,[Product ID]
		  ,[Maturation Time]
		  ,[Reqd Min. Shelf Life]
		  ,[Reqd Max. Shelf Life]
		  ,[Preferred Unit of Measure]
		  ,[Reference Product for Package Building]
		  ,[Product Shape]
		  ,[Product Orientation Profile]
		  ,[Overhang Threshold %]
		  ,[Bridge Threshold %]
		  ,[Maximum Slope for Bridges °]
		  ,[Absolute Height Threshold]
		  ,[UoM of Absolute Height Threshold]
		  ,[Material Is Activated for CW]
		  ,[Valuation UoM]
		  ,[CW Tolerance Group]
		  ,[Fixed Tare]
		  ,[Ref.Unit of Measure TARE Calculation]
		  ,[Loading Units]
		  ,[Loading Unit Group]
		  ,[Structure Category]
		  ,[Tolerance Type ID]
		  ,[Counting Group]
		  ,[DSD Grouping]
		  ,[Cable Diameter]
		  ,[Unit for Dimensions]
		  ,[Cable Diameter Allowance in Percent]
		  ,[Bending Factor]
		  ,[Inner Width]
		  ,[Outer Diameter]
		  ,[Core Diameter]
		  ,[Load Capacity]
		  ,[R-O Flange Thick.]
		  ,[R-O Flange Height]
		  ,[Coil Delivery]
		  ,[Run-Out Flange]
		  ,[No. Vertical Layers]
		  ,[Smallest Permitted Clearance]
		  ,[Serialization Type]
		  ,[Synchronization Active]
		  ,[Last Synchronization Time]
		  ,[Indicator Changed Since Integration]
		  ,[Profile Relevant Country]
		  ,[Product Category]
		  ,[Tilting Allowed]
		  ,[No Stacking]
		  ,[Only Bottom Layer]
		  ,[Only Top Layer]
		  ,[Stacking Factor]
		  ,[Load without PKM]
		  ,[PKM Overhang Depth]
		  ,[PKM Overhang Width]
		  ,[Max. Stacking Height]
		  ,[Min. Stacking Height]
		  ,[Max.StackH Tolerance]
		  ,[No. Mat / Closed PKM]
		  ,[VSO Unit of Measure]
		  ,[Closed PKM Required]
		  ,[Packaging Code]
		  ,[DG Packaging Status]
		  ,[Material Condition Mgmt]
		  ,[Return Code]
		  ,[Return to Logistics Level]
		  ,[NATO Stock Number]
		  ,[Overlength Part Number]
		  ,[Spare Part Class Code]
		  ,[Variable ObjectID]
		  ,[MS Book Part Number]
		  ,[SU Batch Default Value]
		  ,[Goods Rcpt to Posted Single-Unit Bch]
		  ,[Form-Fit-Function class]
		  ,[Supersession chain number]
		  ,[Creation Status]
		  ,[Int. Char. Number_COLOR_ATINN]
		  ,[Int. Char. Number_SIZE1_ATINN]
		  ,[Int. Char. Number_SIZE2_ATINN]
		  ,[Color]
		  ,[Main Size]
		  ,[Second Size]
		  ,[Free Charact. Value]
		  ,[Care Code]
		  ,[Brand]
		  ,[Component 1]
		  ,[Percentage Share 1]
		  ,[Component 2]
		  ,[Percentage Share 2]
		  ,[Component 3]
		  ,[Percentage Share 3]
		  ,[Component 4]
		  ,[Percentage Share 4]
		  ,[Component 5]
		  ,[Percentage Share 5]
		  ,[Fashion Grade]
	)
	SELECT [MANDT]
		  ,[MATNR]
		  ,[ERSDA]
		  ,[ERNAM]
		  ,[LAEDA]
		  ,[AENAM]
		  ,[VPSTA]
		  ,[PSTAT]
		  ,[LVORM]
		  ,[MTART]
		  ,[MBRSH]
		  ,[MATKL]
		  ,[BISMT]
		  ,[MEINS]
		  ,[BSTME]
		  ,[ZEINR]
		  ,[ZEIAR]
		  ,[ZEIVR]
		  ,[ZEIFO]
		  ,[AESZN]
		  ,[BLATT]
		  ,[BLANZ]
		  ,[FERTH]
		  ,[FORMT]
		  ,[GROES]
		  ,[WRKST]
		  ,[NORMT]
		  ,[LABOR]
		  ,[EKWSL]
		  ,[BRGEW]
		  ,[NTGEW]
		  ,[GEWEI]
		  ,[VOLUM]
		  ,[VOLEH]
		  ,[BEHVO]
		  ,[RAUBE]
		  ,[TEMPB]
		  ,[DISST]
		  ,[TRAGR]
		  ,[STOFF]
		  ,[SPART]
		  ,[KUNNR]
		  ,[EANNR]
		  ,[WESCH]
		  ,[BWVOR]
		  ,[BWSCL]
		  ,[SAISO]
		  ,[ETIAR]
		  ,[ETIFO]
		  ,[ENTAR]
		  ,[EAN11]
		  ,[NUMTP]
		  ,[LAENG]
		  ,[BREIT]
		  ,[HOEHE]
		  ,[MEABM]
		  ,[PRDHA]
		  ,[AEKLK]
		  ,[CADKZ]
		  ,[QMPUR]
		  ,[ERGEW]
		  ,[ERGEI]
		  ,[ERVOL]
		  ,[ERVOE]
		  ,[GEWTO]
		  ,[VOLTO]
		  ,[VABME]
		  ,[KZREV]
		  ,[KZKFG]
		  ,[XCHPF]
		  ,[VHART]
		  ,[FUELG]
		  ,[STFAK]
		  ,[MAGRV]
		  ,[BEGRU]
		  ,[DATAB]
		  ,[LIQDT]
		  ,[SAISJ]
		  ,[PLGTP]
		  ,[MLGUT]
		  ,[EXTWG]
		  ,[SATNR]
		  ,[ATTYP]
		  ,[KZKUP]
		  ,[KZNFM]
		  ,[PMATA]
		  ,[MSTAE]
		  ,[MSTAV]
		  ,[MSTDE]
		  ,[MSTDV]
		  ,[TAKLV]
		  ,[RBNRM]
		  ,[MHDRZ]
		  ,[MHDHB]
		  ,[MHDLP]
		  ,[INHME]
		  ,[INHAL]
		  ,[VPREH]
		  ,[ETIAG]
		  ,[INHBR]
		  ,[CMETH]
		  ,[CUOBF]
		  ,[KZUMW]
		  ,[KOSCH]
		  ,[SPROF]
		  ,[NRFHG]
		  ,[MFRPN]
		  ,[MFRNR]
		  ,[BMATN]
		  ,[MPROF]
		  ,[KZWSM]
		  ,[SAITY]
		  ,[PROFL]
		  ,[IHIVI]
		  ,[ILOOS]
		  ,[SERLV]
		  ,[KZGVH]
		  ,[XGCHP]
		  ,[KZEFF]
		  ,[COMPL]
		  ,[IPRKZ]
		  ,[RDMHD]
		  ,[PRZUS]
		  ,[MTPOS_MARA]
		  ,[BFLME]
		  ,[MATFI]
		  ,[CMREL]
		  ,[BBTYP]
		  ,[SLED_BBD]
		  ,[GTIN_VARIANT]
		  ,[GENNR]
		  ,[RMATP]
		  ,[GDS_RELEVANT]
		  ,[WEORA]
		  ,[HUTYP_DFLT]
		  ,[PILFERABLE]
		  ,[WHSTC]
		  ,[WHMATGR]
		  ,[HNDLCODE]
		  ,[HAZMAT]
		  ,[HUTYP]
		  ,[TARE_VAR]
		  ,[MAXC]
		  ,[MAXC_TOL]
		  ,[MAXL]
		  ,[MAXB]
		  ,[MAXH]
		  ,[MAXDIM_UOM]
		  ,[HERKL]
		  ,[MFRGR]
		  ,[QQTIME]
		  ,[QQTIMEUOM]
		  ,[QGRP]
		  ,[SERIAL]
		  ,[PS_SMARTFORM]
		  ,[LOGUNIT]
		  ,[CWQREL]
		  ,[CWQPROC]
		  ,[CWQTOLGR]
		  ,[ADPROF]
		  ,[IPMIPPRODUCT]
		  ,[ALLOW_PMAT_IGNO]
		  ,[MEDIUM]
		  ,[COMMODITY]
		  ,[ANIMAL_ORIGIN]
		  ,[TEXTILE_COMP_IND]
		  ,[LAST_CHANGED_TIME]
		  ,[MATNR_EXTERNAL]
		  ,[LOGISTICAL_MAT_CATEGORY]
		  ,[SALES_MATERIAL]
		  ,[IDENTIFICATION_TAG_TYPE]
		  ,[SGT_CSGR]
		  ,[SGT_COVSA]
		  ,[SGT_STAT]
		  ,[SGT_SCOPE]
		  ,[SGT_REL]
		  ,[ANP]
		  ,[PSM_CODE]
		  ,[FSH_MG_AT1]
		  ,[FSH_MG_AT2]
		  ,[FSH_MG_AT3]
		  ,[FSH_SEALV]
		  ,[FSH_SEAIM]
		  ,[FSH_SC_MID]
		  ,[DUMMY_PRD_INCL_EEW_PS]
		  ,[SCM_MATID_GUID16]
		  ,[SCM_MATID_GUID22]
		  ,[SCM_MATURITY_DUR]
		  ,[SCM_SHLF_LFE_REQ_MIN]
		  ,[SCM_SHLF_LFE_REQ_MAX]
		  ,[SCM_PUOM]
		  ,[RMATP_PB]
		  ,[PROD_SHAPE]
		  ,[MO_PROFILE_ID]
		  ,[OVERHANG_TRESH]
		  ,[BRIDGE_TRESH]
		  ,[BRIDGE_MAX_SLOPE]
		  ,[HEIGHT_NONFLAT]
		  ,[HEIGHT_NONFLAT_UOM]
		  ,[/CWM/XCWMAT]
		  ,[/CWM/VALUM]
		  ,[/CWM/TOLGR]
		  ,[/CWM/TARA]
		  ,[/CWM/TARUM]
		  ,[/BEV1/LULEINH]
		  ,[/BEV1/LULDEGRP]
		  ,[/BEV1/NESTRUCCAT]
		  ,[/DSD/SL_TOLTYP]
		  ,[/DSD/SV_CNT_GRP]
		  ,[/DSD/VC_GROUP]
		  ,[/SAPMP/KADU]
		  ,[/SAPMP/ABMEIN]
		  ,[/SAPMP/KADP]
		  ,[/SAPMP/BRAD]
		  ,[/SAPMP/SPBI]
		  ,[/SAPMP/TRAD]
		  ,[/SAPMP/KEDU]
		  ,[/SAPMP/SPTR]
		  ,[/SAPMP/FBDK]
		  ,[/SAPMP/FBHK]
		  ,[/SAPMP/RILI]
		  ,[/SAPMP/FBAK]
		  ,[/SAPMP/AHO]
		  ,[/SAPMP/MIFRR]
		  ,[/STTPEC/SERTYPE]
		  ,[/STTPEC/SYNCACT]
		  ,[/STTPEC/SYNCTIME]
		  ,[/STTPEC/SYNCCHG]
		  ,[/STTPEC/COUNTRY_REF]
		  ,[/STTPEC/PRDCAT]
		  ,[/VSO/R_TILT_IND]
		  ,[/VSO/R_STACK_IND]
		  ,[/VSO/R_BOT_IND]
		  ,[/VSO/R_TOP_IND]
		  ,[/VSO/R_STACK_NO]
		  ,[/VSO/R_PAL_IND]
		  ,[/VSO/R_PAL_OVR_D]
		  ,[/VSO/R_PAL_OVR_W]
		  ,[/VSO/R_PAL_B_HT]
		  ,[/VSO/R_PAL_MIN_H]
		  ,[/VSO/R_TOL_B_HT]
		  ,[/VSO/R_NO_P_GVH]
		  ,[/VSO/R_QUAN_UNIT]
		  ,[/VSO/R_KZGVH_IND]
		  ,[PACKCODE]
		  ,[DG_PACK_STATUS]
		  ,[MCOND]
		  ,[RETDELC]
		  ,[LOGLEV_RETO]
		  ,[NSNID]
		  ,[OVLPN]
		  ,[ADSPC_SPC]
		  ,[VARID]
		  ,[MSBOOKPARTNO]
		  ,[DPCBT]
		  ,[XGRDT]
		  ,[IMATN]
		  ,[PICNUM]
		  ,[BSTAT]
		  ,[COLOR_ATINN]
		  ,[SIZE1_ATINN]
		  ,[SIZE2_ATINN]
		  ,[COLOR]
		  ,[SIZE1]
		  ,[SIZE2]
		  ,[FREE_CHAR]
		  ,[CARE_CODE]
		  ,[BRAND_ID]
		  ,[FIBER_CODE1]
		  ,[FIBER_PART1]
		  ,[FIBER_CODE2]
		  ,[FIBER_PART2]
		  ,[FIBER_CODE3]
		  ,[FIBER_PART3]
		  ,[FIBER_CODE4]
		  ,[FIBER_PART4]
		  ,[FIBER_CODE5]
		  ,[FIBER_PART5]
		  ,[FASHGRD]
	  FROM [CT dwh 01 Stage].[dbo].[tSAP_MARA]
	  WITH (NOLOCK)
	  */
	  /*
	  -- WORKING with Spoon generated table data

	  INSERT INTO [CT dwh 03 Intelligence].[dbo].[tItemMasterData]
	(
		   [MANDT]
		  ,[Loading Unit Group]
		  ,[Loading Units]
		  ,[Structure Category]
		  ,[Fixed Tare]
		  ,[Ref.Unit of Measure TARE Calculation]
		  ,[CW Tolerance Group]
		  ,[Valuation UoM]
		  ,[Material Is Activated for CW]
		  ,[Tolerance Type ID]
		  ,[Counting Group]
		  ,[DSD Grouping]
		  ,[Unit for Dimensions]
		  ,[No. Vertical Layers]
		  ,[Bending Factor]
		  ,[Run-Out Flange]
		  ,[R-O Flange Thick.]
		  ,[R-O Flange Height]
		  ,[Cable Diameter Allowance in Percent]
		  ,[Cable Diameter]
		  ,[Core Diameter]
		  ,[Smallest Permitted Clearance]
		  ,[Coil Delivery]
		  ,[Inner Width]
		  ,[Load Capacity]
		  ,[Outer Diameter]
		  ,[Profile Relevant Country]
		  ,[Product Category]
		  ,[Serialization Type]
		  ,[Synchronization Active]
		  ,[Indicator Changed Since Integration]
		  ,[Last Synchronization Time]
		  ,[Only Bottom Layer]
		  ,[Closed PKM Required]
		  ,[No. Mat / Closed PKM]
		  ,[Max. Stacking Height]
		  ,[Load without PKM]
		  ,[Min. Stacking Height]
		  ,[PKM Overhang Depth]
		  ,[PKM Overhang Width]
		  ,[VSO Unit of Measure]
		  ,[No Stacking]
		  ,[Stacking Factor]
		  ,[Tilting Allowed]
		  ,[Max.StackH Tolerance]
		  ,[Only Top Layer]
		  ,[Adjustment Profile (Merchandise Distr.)]
		  ,[Spare Part Class Code]
		  ,[Stock Transfer Net Change Costing]
		  ,[Changed by]
		  ,[Document change no.]
		  ,[Variant Price Allowed]
		  ,[Cont. Non-Textile Parts of Animal Origin]
		  ,[ANP Code]
		  ,[Material Category]
		  ,[Assortment List Type]
		  ,[Authorization Group]
		  ,[Container reqmts]
		  ,[Logistical variants]
		  ,[Old material number]
		  ,[Number of sheets]
		  ,[Page number]
		  ,[Int. material number]
		  ,[Brand]
		  ,[Width]
		  ,[Gross weight]
		  ,[Maximum Slope for Bridges °]
		  ,[Bridge Threshold %]
		  ,[Creation Status]
		  ,[Order Unit]
		  ,[Source of supply]
		  ,[Procurement rule]
		  ,[CAD Indicator]
		  ,[Care Code]
		  ,[Conversion Method]
		  ,[Indicator for relevance in CM]
		  ,[Color]
		  ,[Int. Char. Number_COLOR_ATINN]
		  ,[Commodity]
		  ,[Material completion level]
		  ,[Internal object no.]
		  ,[CW Profile for CW Quantity]
		  ,[Material Is a CW Material]
		  ,[Catch Weight Tolerance Group]
		  ,[Valid From_DATAB]
		  ,[DG Packaging Status]
		  ,[Low-Level Code]
		  ,[SU Batch Default Value]
		  ,[Dummy Field]
		  ,[EAN/UPC]
		  ,[EAN Number]
		  ,[Purchasing value key]
		  ,[Field deactivated]
		  ,[Unit of weight]
		  ,[Allowed pkg weight]
		  ,[Created by]
		  ,[Created On]
		  ,[Volume unit_ERVOE]
		  ,[Allowed pkg volume]
		  ,[Labeling matl grpg]
		  ,[Label type]
		  ,[Label form]
		  ,[Ext. Material Group]
		  ,[Fashion Grade]
		  ,[Prod./insp. memo]
		  ,[Component 1]
		  ,[Component 2]
		  ,[Component 3]
		  ,[Component 4]
		  ,[Component 5]
		  ,[Percentage Share 1]
		  ,[Percentage Share 2]
		  ,[Percentage Share 3]
		  ,[Percentage Share 4]
		  ,[Percentage Share 5]
		  ,[Page format_FORMT]
		  ,[Free Charact. Value]
		  ,[Fashion Attribute 1]
		  ,[Fashion Attribute 2]
		  ,[Fashion Attribute 3]
		  ,[Material Conv. ID]
		  ,[Season Active in Inventory Management]
		  ,[Season Usage]
		  ,[Maximum level]
		  ,[GDS-Relevant]
		  ,[Generic Material]
		  ,[Weight unit]
		  ,[Excess wt tolerance]
		  ,[Size/dimensions]
		  ,[EAN Variant]
		  ,[Relevant for HS]
		  ,[Absolute Height Threshold]
		  ,[UoM of Absolute Height Threshold]
		  ,[Country of origin]
		  ,[Handling Indicator]
		  ,[Height]
		  ,[Handling Unit Type]
		  ,[Standard HU Type]
		  ,[Identification Tag Type]
		  ,[Highly viscous]
		  ,[In bulk/liquid]
		  ,[Form-Fit-Function class]
		  ,[Net contents]
		  ,[Gross contents]
		  ,[Content unit]
		  ,[Intellectual Property]
		  ,[Period Ind. for SLED]
		  ,[Product allocation]
		  ,[Competitor]
		  ,[Assign effect. vals]
		  ,[Closed]
		  ,[Material is configurable]
		  ,[Co-product]
		  ,[Follow-up material]
		  ,[Revision Level Assgd]
		  ,[Environmentally rlvt]
		  ,[Units of meas. usage]
		  ,[Lab/Office]
		  ,[Last Change]
		  ,[Length]
		  ,[Last Changed Time]
		  ,[Valid to]
		  ,[Category of a Logistical Material]
		  ,[Return to Logistics Level]
		  ,[Logistics Unit of Measure]
		  ,[DF at client level]
		  ,[Matl Grp Pack.Matls]
		  ,[Material is locked]
		  ,[Material Group]
		  ,[Material_MATNR]
		  ,[Material_MATNR_EXTERNAL]
		  ,[Max. Pack. Width]
		  ,[Maximum Capacity]
		  ,[Overcapacity Toler.]
		  ,[Unit of Measurement]
		  ,[Max. Pack. Height]
		  ,[Max. Pack. Length]
		  ,[Industry Sector]
		  ,[Material Condition Mgmt]
		  ,[Unit of Dimension]
		  ,[Medium]
		  ,[Base Unit of Measure]
		  ,[Material freight grp]
		  ,[Manufacturer]
		  ,[Manufacturer Part No.]
		  ,[Total shelf life]
		  ,[Storage percentage]
		  ,[Min. Rem. Shelf Life]
		  ,[With empties BOM]
		  ,[Product Orientation Profile]
		  ,[Mfr part profile]
		  ,[MS Book Part Number]
		  ,[X-Plant Matl Status]
		  ,[X-distr.chain status]
		  ,[Valid from_MSTDE]
		  ,[Valid from_MSTDV]
		  ,[Material type]
		  ,[Gen. item cat. grp]
		  ,[Industry Std Desc.]
		  ,[Qual.f.FreeGoodsDis.]
		  ,[NATO Stock Number]
		  ,[Net weight]
		  ,[EAN category]
		  ,[Overhang Threshold %]
		  ,[Overlength Part Number]
		  ,[Packaging Code]
		  ,[Supersession chain number]
		  ,[Pilferable]
		  ,[Price Band Category]
		  ,[Pricing Ref. Matl]
		  ,[Product hierarchy]
		  ,[Product Shape]
		  ,[DG indicator profile]
		  ,[Product Composition]
		  ,[Form Name]
		  ,[Protected Species Management Code]
		  ,[Maintenance status]
		  ,[Quality Inspection Group]
		  ,[QM proc. active]
		  ,[Quarant. Per.]
		  ,[Quarantine Time Unit]
		  ,[Storage conditions]
		  ,[Catalog Profile]
		  ,[Rounding rule SLED]
		  ,[Return Code]
		  ,[Reference matl for packing]
		  ,[Reference Product for Package Building]
		  ,[Season Year]
		  ,[Season]
		  ,[Rollout]
		  ,[Material Number of Sales Material]
		  ,[Cross-plant CM]
		  ,[Product]
		  ,[Product ID]
		  ,[Maturation Time]
		  ,[Preferred Unit of Measure]
		  ,[Reqd Max. Shelf Life]
		  ,[Reqd Min. Shelf Life]
		  ,[Serial No. Profile]
		  ,[Serialization level]
		  ,[Segmentation Strategy]
		  ,[Segmentation Structure]
		  ,[Segmentation Relevant]
		  ,[Segmentation Strategy Scope]
		  ,[Segmentation Status]
		  ,[Main Size]
		  ,[Int. Char. Number_SIZE1_ATINN]
		  ,[Second Size]
		  ,[Int. Char. Number_SIZE2_ATINN]
		  ,[Expiration Date]
		  ,[Division]
		  ,[Pricing profile]
		  ,[Stackability factor]
		  ,[Haz. material number]
		  ,[Tax classification]
		  ,[Varb. Tare Weight]
		  ,[Temp. conditions]
		  ,[Textile Composition Maintenance Active]
		  ,[Transportation Group]
		  ,[Variable Purchase Order Unit]
		  ,[Variable ObjectID]
		  ,[Packaging Mat. Type]
		  ,[Volume unit_VOLEH]
		  ,[Excess volume tol.]
		  ,[Volume]
		  ,[ComparisonPriceUnit]
		  ,[Compl. maint. status]
		  ,[Origin Acceptance]
		  ,[Number of GR slips]
		  ,[WH Material Group]
		  ,[WH Storage Condition]
		  ,[Basic material]
		  ,[Batch management]
		  ,[Appr.Batch Recd Req.]
		  ,[Goods Rcpt to Posted Single-Unit Bch]
		  ,[Document type]
		  ,[Page format_ZEIFO]
		  ,[Document]
		  ,[Doc. Version]
	)
	SELECT
		   [MANDT]
		  ,[/BEV1/LULDEGRP]
		  ,[/BEV1/LULEINH]
		  ,[/BEV1/NESTRUCCAT]
		  ,[/CWM/TARA]
		  ,[/CWM/TARUM]
		  ,[/CWM/TOLGR]
		  ,[/CWM/VALUM]
		  ,[/CWM/XCWMAT]
		  ,[/DSD/SL_TOLTYP]
		  ,[/DSD/SV_CNT_GRP]
		  ,[/DSD/VC_GROUP]
		  ,[/SAPMP/ABMEIN]
		  ,[/SAPMP/AHO]
		  ,[/SAPMP/BRAD]
		  ,[/SAPMP/FBAK]
		  ,[/SAPMP/FBDK]
		  ,[/SAPMP/FBHK]
		  ,[/SAPMP/KADP]
		  ,[/SAPMP/KADU]
		  ,[/SAPMP/KEDU]
		  ,[/SAPMP/MIFRR]
		  ,[/SAPMP/RILI]
		  ,[/SAPMP/SPBI]
		  ,[/SAPMP/SPTR]
		  ,[/SAPMP/TRAD]
		  ,[/STTPEC/COUNTRY_REF]
		  ,[/STTPEC/PRDCAT]
		  ,[/STTPEC/SERTYPE]
		  ,[/STTPEC/SYNCACT]
		  ,[/STTPEC/SYNCCHG]
		  ,[/STTPEC/SYNCTIME]
		  ,[/VSO/R_BOT_IND]
		  ,[/VSO/R_KZGVH_IND]
		  ,[/VSO/R_NO_P_GVH]
		  ,[/VSO/R_PAL_B_HT]
		  ,[/VSO/R_PAL_IND]
		  ,[/VSO/R_PAL_MIN_H]
		  ,[/VSO/R_PAL_OVR_D]
		  ,[/VSO/R_PAL_OVR_W]
		  ,[/VSO/R_QUAN_UNIT]
		  ,[/VSO/R_STACK_IND]
		  ,[/VSO/R_STACK_NO]
		  ,[/VSO/R_TILT_IND]
		  ,[/VSO/R_TOL_B_HT]
		  ,[/VSO/R_TOP_IND]
		  ,[ADPROF]
		  ,[ADSPC_SPC]
		  ,[AEKLK]
		  ,[AENAM]
		  ,[AESZN]
		  ,[ALLOW_PMAT_IGNO]
		  ,[ANIMAL_ORIGIN]
		  ,[ANP]
		  ,[ATTYP]
		  ,[BBTYP]
		  ,[BEGRU]
		  ,[BEHVO]
		  ,[BFLME]
		  ,[BISMT]
		  ,[BLANZ]
		  ,[BLATT]
		  ,[BMATN]
		  ,[BRAND_ID]
		  ,[BREIT]
		  ,[BRGEW]
		  ,[BRIDGE_MAX_SLOPE]
		  ,[BRIDGE_TRESH]
		  ,[BSTAT]
		  ,[BSTME]
		  ,[BWSCL]
		  ,[BWVOR]
		  ,[CADKZ]
		  ,[CARE_CODE]
		  ,[CMETH]
		  ,[CMREL]
		  ,[COLOR]
		  ,[COLOR_ATINN]
		  ,[COMMODITY]
		  ,[COMPL]
		  ,[CUOBF]
		  ,[CWQPROC]
		  ,[CWQREL]
		  ,[CWQTOLGR]
		  ,[DATAB]
		  ,[DG_PACK_STATUS]
		  ,[DISST]
		  ,[DPCBT]
		  ,[DUMMY_PRD_INCL_EEW_PS]
		  ,[EAN11]
		  ,[EANNR]
		  ,[EKWSL]
		  ,[ENTAR]
		  ,[ERGEI]
		  ,[ERGEW]
		  ,[ERNAM]
		  ,[ERSDA]
		  ,[ERVOE]
		  ,[ERVOL]
		  ,[ETIAG]
		  ,[ETIAR]
		  ,[ETIFO]
		  ,[EXTWG]
		  ,[FASHGRD]
		  ,[FERTH]
		  ,[FIBER_CODE1]
		  ,[FIBER_CODE2]
		  ,[FIBER_CODE3]
		  ,[FIBER_CODE4]
		  ,[FIBER_CODE5]
		  ,[FIBER_PART1]
		  ,[FIBER_PART2]
		  ,[FIBER_PART3]
		  ,[FIBER_PART4]
		  ,[FIBER_PART5]
		  ,[FORMT]
		  ,[FREE_CHAR]
		  ,[FSH_MG_AT1]
		  ,[FSH_MG_AT2]
		  ,[FSH_MG_AT3]
		  ,[FSH_SC_MID]
		  ,[FSH_SEAIM]
		  ,[FSH_SEALV]
		  ,[FUELG]
		  ,[GDS_RELEVANT]
		  ,[GENNR]
		  ,[GEWEI]
		  ,[GEWTO]
		  ,[GROES]
		  ,[GTIN_VARIANT]
		  ,[HAZMAT]
		  ,[HEIGHT_NONFLAT]
		  ,[HEIGHT_NONFLAT_UOM]
		  ,[HERKL]
		  ,[HNDLCODE]
		  ,[HOEHE]
		  ,[HUTYP]
		  ,[HUTYP_DFLT]
		  ,[IDENTIFICATION_TAG_TYPE]
		  ,[IHIVI]
		  ,[ILOOS]
		  ,[IMATN]
		  ,[INHAL]
		  ,[INHBR]
		  ,[INHME]
		  ,[IPMIPPRODUCT]
		  ,[IPRKZ]
		  ,[KOSCH]
		  ,[KUNNR]
		  ,[KZEFF]
		  ,[KZGVH]
		  ,[KZKFG]
		  ,[KZKUP]
		  ,[KZNFM]
		  ,[KZREV]
		  ,[KZUMW]
		  ,[KZWSM]
		  ,[LABOR]
		  ,[LAEDA]
		  ,[LAENG]
		  ,[LAST_CHANGED_TIME]
		  ,[LIQDT]
		  ,[LOGISTICAL_MAT_CATEGORY]
		  ,[LOGLEV_RETO]
		  ,[LOGUNIT]
		  ,[LVORM]
		  ,[MAGRV]
		  ,[MATFI]
		  ,[MATKL]
		  ,[MATNR]
		  ,[MATNR_EXTERNAL]
		  ,[MAXB]
		  ,[MAXC]
		  ,[MAXC_TOL]
		  ,[MAXDIM_UOM]
		  ,[MAXH]
		  ,[MAXL]
		  ,[MBRSH]
		  ,[MCOND]
		  ,[MEABM]
		  ,[MEDIUM]
		  ,[MEINS]
		  ,[MFRGR]
		  ,[MFRNR]
		  ,[MFRPN]
		  ,[MHDHB]
		  ,[MHDLP]
		  ,[MHDRZ]
		  ,[MLGUT]
		  ,[MO_PROFILE_ID]
		  ,[MPROF]
		  ,[MSBOOKPARTNO]
		  ,[MSTAE]
		  ,[MSTAV]
		  ,[MSTDE]
		  ,[MSTDV]
		  ,[MTART]
		  ,[MTPOS_MARA]
		  ,[NORMT]
		  ,[NRFHG]
		  ,[NSNID]
		  ,[NTGEW]
		  ,[NUMTP]
		  ,[OVERHANG_TRESH]
		  ,[OVLPN]
		  ,[PACKCODE]
		  ,[PICNUM]
		  ,[PILFERABLE]
		  ,[PLGTP]
		  ,[PMATA]
		  ,[PRDHA]
		  ,[PROD_SHAPE]
		  ,[PROFL]
		  ,[PRZUS]
		  ,[PS_SMARTFORM]
		  ,[PSM_CODE]
		  ,[PSTAT]
		  ,[QGRP]
		  ,[QMPUR]
		  ,[QQTIME]
		  ,[QQTIMEUOM]
		  ,[RAUBE]
		  ,[RBNRM]
		  ,[RDMHD]
		  ,[RETDELC]
		  ,[RMATP]
		  ,[RMATP_PB]
		  ,[SAISJ]
		  ,[SAISO]
		  ,[SAITY]
		  ,[SALES_MATERIAL]
		  ,[SATNR]
		  ,[SCM_MATID_GUID16]
		  ,[SCM_MATID_GUID22]
		  ,[SCM_MATURITY_DUR]
		  ,[SCM_PUOM]
		  ,[SCM_SHLF_LFE_REQ_MAX]
		  ,[SCM_SHLF_LFE_REQ_MIN]
		  ,[SERIAL]
		  ,[SERLV]
		  ,[SGT_COVSA]
		  ,[SGT_CSGR]
		  ,[SGT_REL]
		  ,[SGT_SCOPE]
		  ,[SGT_STAT]
		  ,[SIZE1]
		  ,[SIZE1_ATINN]
		  ,[SIZE2]
		  ,[SIZE2_ATINN]
		  ,[SLED_BBD]
		  ,[SPART]
		  ,[SPROF]
		  ,[STFAK]
		  ,[STOFF]
		  ,[TAKLV]
		  ,[TARE_VAR]
		  ,[TEMPB]
		  ,[TEXTILE_COMP_IND]
		  ,[TRAGR]
		  ,[VABME]
		  ,[VARID]
		  ,[VHART]
		  ,[VOLEH]
		  ,[VOLTO]
		  ,[VOLUM]
		  ,[VPREH]
		  ,[VPSTA]
		  ,[WEORA]
		  ,[WESCH]
		  ,[WHMATGR]
		  ,[WHSTC]
		  ,[WRKST]
		  ,[XCHPF]
		  ,[XGCHP]
		  ,[XGRDT]
		  ,[ZEIAR]
		  ,[ZEIFO]
		  ,[ZEINR]
		  ,[ZEIVR]
	FROM [CT dwh 02 Data].[dbo].[tSAP_MARA]
	WITH (NOLOCK)
	WHERE valid_to = '2200-01-01' and is_deleted = 0
	  */

	-- 28.10.2020/FT -> https://jira.chal-tec.com/browse/DEVTCK-17601
	-- delete all
	TRUNCATE TABLE [CT dwh 03 Intelligence].[dbo].[tStorageLocationDataForMaterial]

	INSERT INTO [CT dwh 03 Intelligence].[dbo].[tStorageLocationDataForMaterial]
	(
	   [MANDT]
      ,[Material]
      ,[Plant]
      ,[Storage location]
      ,[Maintenance status]
      ,[DF stor. loc. level]
      ,[Year current period]
      ,[Current period]
      ,[Phys. Inv. Block]
      ,[Unrestricted_LABST]
      ,[Stock in transfer_UMLME]
      ,[Quality Inspection_INSME]
      ,[Restricted-Use Stock_EINME]
      ,[Blocked_SPEME]
      ,[Returns_RETME]
      ,[Unrestr.-use stock_VMLAB]
      ,[Stock in transfer_VMUML]
      ,[In quality insp._VMINS]
      ,[Restricted-use stock_VMEIN]
      ,[Blocked_VMSPE]
      ,[Returns_VMRET]
      ,[Warehouse stock CY]
      ,[Qual. insp. stock CY]
      ,[Restricted-use stock_KZILE]
      ,[Blocked stock]
      ,[Warehouse stock PY]
      ,[QuallnspStock prv.pd]
      ,[Restricted use, PP]
      ,[Blocked stock prev.pd]
      ,[Sloc MRP indicator]
      ,[Spec.proc.type: SLoc]
      ,[Reorder point]
      ,[Replenishment qty]
      ,[Country of origin]
      ,[Preference indicator]
      ,[Export indicator]
      ,[Storage bin]
      ,[Unrestr. Consignment_KLABS]
      ,[Cnsgt in Inspection_KINSM]
      ,[Restr. Consignment_KEINM]
      ,[Blocked Consignment_KSPEM]
      ,[Date of Last Count]
      ,[Profit Center]
      ,[Created On]
      ,[SP stock value]
      ,[St.trnsfr/SP (SLoc)]
      ,[Picking area]
      ,[Invent. corr. factor]
      ,[MARDH rec. already exists for per. befor]
      ,[Fiscal year of current physical inventor]
      ,[MD PRODUCT Storage location]
      ,[Allocated Stock Quantity]
      ,[Unrestricted_/CWM/LABST]
      ,[Quality Inspection_/CWM/INSME]
      ,[Restricted-Use Stock_/CWM/EINME]
      ,[Blocked_/CWM/SPEME]
      ,[Returns_/CWM/RETME]
      ,[Stock in transfer_/CWM/UMLME]
      ,[Unrestr. Consignment_/CWM/KLABS]
      ,[Cnsgt in Inspection_/CWM/KINSM]
      ,[Restr. Consignment_/CWM/KEINM]
      ,[Blocked Consignment_/CWM/KSPEM]
      ,[Unrestr.-use stock_/CWM/VMLAB]
      ,[In quality insp._/CWM/VMINS]
      ,[Restricted-Use Stock/CWM/VMEIN]
      ,[Blocked_/CWM/VMSPE]
      ,[Returns_/CWM/VMRET]
      ,[Stock in transfer_/CWM/VMUML]
	)
	SELECT [MANDT]
      ,RIGHT([MATNR],LEN([MATNR])-CHARINDEX(LEFT(REPLACE([MATNR],'0',''),1),[MATNR])+1) --DEVTCK-17779
      ,[WERKS]
      ,[LGORT]
      ,[PSTAT]
      ,[LVORM]
      ,[LFGJA]
      ,[LFMON]
      ,[SPERR]
      ,[LABST]
      ,[UMLME]
      ,[INSME]
      ,[EINME]
      ,[SPEME]
      ,[RETME]
      ,[VMLAB]
      ,[VMUML]
      ,[VMINS]
      ,[VMEIN]
      ,[VMSPE]
      ,[VMRET]
      ,[KZILL]
      ,[KZILQ]
      ,[KZILE]
      ,[KZILS]
      ,[KZVLL]
      ,[KZVLQ]
      ,[KZVLE]
      ,[KZVLS]
      ,[DISKZ]
      ,[LSOBS]
      ,[LMINB]
      ,[LBSTF]
      ,[HERKL]
      ,[EXPPG]
      ,[EXVER]
      ,[LGPBE]
      ,[KLABS]
      ,[KINSM]
      ,[KEINM]
      ,[KSPEM]
      ,[DLINL]
      ,[PRCTL]
      ,[ERSDA]
      ,[VKLAB]
      ,[VKUML]
      ,[LWMKB]
      ,[BSKRF]
      ,[MDRUE]
      ,[MDJIN]
      ,[DUMMY_STL_INCL_EEW_PS]
      ,[FSH_SALLOC_QTY_S]
      ,[/CWM/LABST]
      ,[/CWM/INSME]
      ,[/CWM/EINME]
      ,[/CWM/SPEME]
      ,[/CWM/RETME]
      ,[/CWM/UMLME]
      ,[/CWM/KLABS]
      ,[/CWM/KINSM]
      ,[/CWM/KEINM]
      ,[/CWM/KSPEM]
      ,[/CWM/VMLAB]
      ,[/CWM/VMINS]
      ,[/CWM/VMEIN]
      ,[/CWM/VMSPE]
      ,[/CWM/VMRET]
      ,[/CWM/VMUML]
  FROM [CT dwh 01 Stage].[dbo].[tSAP_MARD]
  WITH (NOLOCK)

  --> 12.11.2020/FT: https://jira.chal-tec.com/browse/DEVTCK-17731
  -- delete all data
  TRUNCATE TABLE [CT dwh 03 Intelligence].[dbo].[tPurchasingInfoRecordGeneralData]
  /*
  -- 16.12.2020/FT: Umstellung auf die Spoon Tabelle -> https://jira.chal-tec.com/browse/DEVTCK-18053
  INSERT INTO [CT dwh 03 Intelligence].[dbo].[tPurchasingInfoRecordGeneralData]
           ([MANDT]
           ,[Purchasing info rec.]
           ,[Material]
           ,[Material Group]
           ,[Vendor]
           ,[Complete info record]
           ,[Created on]
           ,[Created by]
           ,[Info Short Text]
           ,[Sort Term]
           ,[Order Unit]
           ,[Equal To]
           ,[Denominator]
           ,[Supplier Material Number]
           ,[Salesperson]
           ,[Telephone]
           ,[1st Reminder/Exped.]
           ,[2nd Reminder/Exped.]
           ,[3rd Reminder/Exped.]
           ,[Certificate Number]
           ,[Valid to]
           ,[Country of Origin]
           ,[Certificate Category]
           ,[Number]
           ,[Base Unit of Measure]
           ,[Region]
           ,[Variable Purchase Order Unit]
           ,[Supplier Subrange]
           ,[SSR Sort Seq. Number]
           ,[Supplier Mat. Group]
           ,[Return Agreement]
           ,[Available from]
           ,[Available to]
           ,[Prior Supplier]
           ,[Points]
           ,[Points unit]
           ,[Regular Supplier]
           ,[Manufacturer]
           ,[Ext. Include]
           ,[Time Stamp]
           ,[Business Purpose Completed])
  
	SELECT [MANDT]
      ,[INFNR]
      ,[MATNR]
      ,[MATKL]
      ,[LIFNR]
      ,[LOEKZ]
      ,[ERDAT]
      ,[ERNAM]
      ,[TXZ01]
      ,[SORTL]
      ,[MEINS]
      ,[UMREZ]
      ,[UMREN]
      ,[IDNLF]
      ,[VERKF]
      ,[TELF1]
      ,[MAHN1]
      ,[MAHN2]
      ,[MAHN3]
      ,[URZNR]
      ,[URZDT]
      ,[URZLA]
      ,[URZTP]
      ,[URZZT]
      ,[LMEIN]
      ,[REGIO]
      ,[VABME]
      ,[LTSNR]
      ,[LTSSF]
      ,[WGLIF]
      ,[RUECK]
      ,[LIFAB]
      ,[LIFBI]
      ,[KOLIF]
      ,[ANZPU]
      ,[PUNEI]
      ,[RELIF]
      ,[MFRNR]
      ,[DUMMY_EINA_INCL_EEW_PS]
      ,[LASTCHANGEDATETIME]
      ,[ISEOPBLOCKED]
  FROM [CT dwh 01 Stage].[dbo].[tSAP_EINA]
  WITH (NOLOCK)
  */
  
  -- WORKING with Spoon generated table data
  INSERT INTO [CT dwh 03 Intelligence].[dbo].[tPurchasingInfoRecordGeneralData]
           ([Row_ID]
		   ,[MANDT]
           ,[Purchasing info rec.]
		   ,[Points]
		   ,[Ext. Include]
           ,[Created on]
		   ,[Created by]
		   ,[Supplier Material Number]
		   ,[Business Purpose Completed]
		   ,[Prior Supplier]
		   ,[Time Stamp]
		   ,[Available from]
		   ,[Available to]
		   ,[Vendor]
		   ,[Base Unit of Measure]
		   ,[Complete info record]
		   ,[Supplier Subrange]
		   ,[SSR Sort Seq. Number]
		   ,[1st Reminder/Exped.]
           ,[2nd Reminder/Exped.]
           ,[3rd Reminder/Exped.]
		   ,[Material Group]   
		   ,[Material]       
		   ,[Order Unit]
		   ,[Manufacturer]
		   ,[Points unit]
		   ,[Region]
		   ,[Regular Supplier]
		   ,[Return Agreement]
           ,[Sort Term]
		   ,[Telephone]
		   ,[Info Short Text]
		   ,[Denominator]
		   ,[Equal To]
           ,[Valid to]
		   ,[Country of Origin]
		   ,[Certificate Number]
		   ,[Certificate Category]
           ,[Number]
		   ,[Variable Purchase Order Unit]
		   ,[Salesperson]
           ,[Supplier Mat. Group]
		   ,[Valid_From]
		   ,[Valid_To]
		   )
		   
  SELECT 
      [row_id]
	  ,[MANDT]
	  ,[INFNR]
      ,[ANZPU]
      ,[DUMMY_EINA_INCL_EEW_PS]
      ,[ERDAT]
      ,[ERNAM]
      ,[IDNLF]
      ,[ISEOPBLOCKED]
      ,[KOLIF]
      ,[LASTCHANGEDATETIME]
      ,[LIFAB]
      ,[LIFBI]
      ,[LIFNR]
      ,[LMEIN]
      ,[LOEKZ]
      ,[LTSNR]
      ,[LTSSF]
      ,[MAHN1]
      ,[MAHN2]
      ,[MAHN3]
      ,[MATKL]
      ,[MATNR]
      ,[MEINS]
      ,[MFRNR]
      ,[PUNEI]
      ,[REGIO]
      ,[RELIF]
      ,[RUECK]
      ,[SORTL]
      ,[TELF1]
      ,[TXZ01]
      ,[UMREN]
      ,[UMREZ]
      ,[URZDT]
      ,[URZLA]
      ,[URZNR]
      ,[URZTP]
      ,[URZZT]
      ,[VABME]
      ,[VERKF]
      ,[WGLIF]
	  ,[Valid_From]
	  ,[Valid_To]
	FROM [CT dwh 02 Data].[dbo].[tSAPEINA]
	WITH (NOLOCK)
	where MANDT is not null
	and valid_to = '2200-01-01' and is_deleted = 0
	

	TRUNCATE TABLE [CT dwh 03 Intelligence].[dbo].[tPurchasingInfoRecordPurchasingOrganizationData]

	INSERT INTO [CT dwh 03 Intelligence].[dbo].[tPurchasingInfoRecordPurchasingOrganizationData]
	(
			--[Row_ID]
		   --,
		   [MANDT]
           ,[Purchasing info rec.]
           ,[Purch. organization]
           ,[Info record category]
           ,[Plant]
           ,[Purch. org. data]
           ,[Created on]
           ,[Created by]
           ,[Purchasing Group]
           ,[Currency]
           ,[Volume Rebate Ind.]
           ,[Quantity Rebate Ind.]
           ,[Minimum Order Qty]
           ,[Standard PO Quantity]
           ,[Planned Deliv. Time]
           ,[Overdeliv. Tolerance]
           ,[Unltd Overdelivery]
           ,[Underdel. Tolerance]
           ,[Quotation]
           ,[Quotation Valid from]
           ,[RFQ]
           ,[Item_ANFPS]
           ,[Rejection Indicator]
           ,[Amort. period from]
           ,[Amort. period to]
           ,[Amortized plan qty.]
           ,[Amortized plan value]
           ,[Amortized actual qty]
           ,[Amortized act. value]
           ,[Amortization reset]
           ,[Purch. Doc. Category]
           ,[Purchasing Document]
           ,[Item_EBELP]
           ,[Date of Document]
           ,[Net Price]
           ,[Price unit]
           ,[Order Price Unit]
           ,[Valid to]
           ,[Quantity Conversion_BPUMZ]
           ,[Quantity Conversion_BPUMN]
           ,[No Material Text]
           ,[GR-Based Inv. Verif.]
           ,[Effective Price]
           ,[Condition Group]
           ,[No Cash Discount]
           ,[Acknowledgment Reqd]
           ,[Tax Code]
           ,[Valuation Type]
           ,[Settlement Group 1]
           ,[Shipping Instr.]
           ,[Procedure]
           ,[Confirmation Control]
           ,[Pricing Date Control]
           ,[Incoterms]
           ,[Incoterms (Part 2)]
           ,[No ERS]
           ,[Settlement Group 2]
           ,[Settlement Group 3]
           ,[No Subsequent Sett.]
           ,[Min. Rem. Shelf Life]
           ,[Production Version]
           ,[Max. Order Quantity]
           ,[Rounding Profile]
           ,[Unit of Measure Grp]
           ,[NCM Code]
           ,[New PO for inc. Del.]
           ,[Period Ind. for SLED]
           ,[Real-Time Cons.Post.]
           ,[Supplier RMA Number Required]
           ,[Differential Invoicing]
           ,[Incoterms Version]
           ,[Incoterms Location 1]
           ,[Incoterms Location 2]
           ,[Automatic Sourcing]
           ,[Ext. Include]
           ,[Business Purpose Completed]
           ,[Correlate DCI indicator]
           ,[Replenishment Lead Time for Raw Material]
           ,[Manufacturing Lead Time]
           ,[Packing Lead Time]
           ,[Transportation Lead Time]
           ,[Max Retail Price  Relevance]
           ,[Stock Segment Relevant Indicator]
           ,[Transportation Chain]
           ,[Staging Time]
		  -- ,[ValidFrom]
		  -- ,[ValidTo]
	)
	SELECT 
	   --[row_id]
	  --,
	  [MANDT]
      ,[INFNR]
      ,[EKORG]
      ,[ESOKZ]
      ,[WERKS]
      ,[LOEKZ]
      ,[ERDAT]
      ,[ERNAM]
      ,[EKGRP]
      ,[WAERS]
      ,[BONUS]
      ,[MGBON]
      ,[MINBM]
      ,[NORBM]
      ,[APLFZ]
      ,[UEBTO]
      ,[UEBTK]
      ,[UNTTO]
      ,[ANGNR]
      ,[ANGDT]
      ,[ANFNR]
      ,[ANFPS]
      ,[ABSKZ]
      ,[AMODV]
      ,[AMODB]
      ,[AMOBM]
      ,[AMOBW]
      ,[AMOAM]
      ,[AMOAW]
      ,[AMORS]
      ,[BSTYP]
      ,[EBELN]
      ,[EBELP]
      ,[DATLB]
      ,[NETPR]
      ,[PEINH]
      ,[BPRME]
      ,[PRDAT]
      ,[BPUMZ]
      ,[BPUMN]
      ,[MTXNO]
      ,[WEBRE]
      ,[EFFPR]
      ,[EKKOL]
      ,[SKTOF]
      ,[KZABS]
      ,[MWSKZ]
      ,[BWTAR]
      ,[EBONU]
      ,[EVERS]
      ,[EXPRF]
      ,[BSTAE]
      ,[MEPRF]
      ,[INCO1]
      ,[INCO2]
      ,[XERSN]
      ,[EBON2]
      ,[EBON3]
      ,[EBONF]
      ,[MHDRZ]
      ,[VERID]
      ,[BSTMA]
      ,[RDPRF]
      ,[MEGRU]
      ,[J_1BNBM]
      ,[SPE_CRE_REF_DOC]
      ,[IPRKZ]
      ,[CO_ORDER]
      ,[VENDOR_RMA_REQ]
      ,[DIFF_INVOICE]
      ,[INCOV]
      ,[INCO2_L]
      ,[INCO3_L]
      ,[AUT_SOURCE]
      ,[DUMMY_EINE_INCL_EEW_PS]
      ,[ISEOPBLOCKED]
      ,[FSH_DCI_CORR]
      ,[FSH_RLT]
      ,[FSH_MLT]
      ,[FSH_PLT]
      ,[FSH_TLT]
      ,[MRPIND]
      ,[SGT_SSREL]
      ,[TRANSPORT_CHAIN]
      ,[STAGING_TIME]
	  --,[Valid_From]
	 -- ,[Valid_To]
  FROM [CT dwh 01 Stage].[dbo].[tSAP_EINE]
  WITH (NOLOCK)

	-- ArticleMasterData // 16.12.2020 -> https://jira.chal-tec.com/browse/DEVTCK-18055
	TRUNCATE TABLE [CT dwh 03 Intelligence].[dbo].[tArticleMasterData]

	INSERT INTO [CT dwh 03 Intelligence].[dbo].[tArticleMasterData]
	(
			[MANDT]
		  -- MARC
		  ,[Material]
		  ,[Plant]
		 -- ,[Maintenance status]
		  ,[Valuation Category]
		  ,[Batch Management]
		  ,[Plant-sp.matl status]
		  ,[Purchasing Group]
		  ,[MRP Type]
		  ,[MRP Controller]
		  ,[Planned Deliv. Time]
		  ,[GR processing time]
		  ,[Period Indicator]
		  ,[Assembly scrap (%)]
		  ,[Lot Sizing Procedure]
		  ,[Procurement type]
		  ,[Minimum Lot Size]
		  ,[Loading Group]
		  ,[Availability check]
		  ,[Base quantity]
		  ,[Processing time]
		  ,[Commodity Code]
		  ,[Country of origin]
		  ,[Profit Center]
		  ,[Planning Strategy Group]
		  ,[Internal object no.]
		  ,[Storage loc. for EP]
		  ,[Current period]
		  ,[Year current period]
		  ,[Valuated Goods Receipt Blocked Stock]
		  ,[Segmentation Strategy]
		  ,[Seg. Status MRP]
		  --,[Segmentation Strategy Scope]
		  --,[Product]
		  ,[Location Product ID]
		  -- 33 + MANDT
		  -- MARA
		  ,[Created On]
		  ,[Created by]
		  ,[Last Change]
		  ,[Changed by]
		  ,[Compl. maint. status]
		  ,[Maintenance status]
		  ,[DF at client level]
		  ,[Material type]
		  ,[Industry Sector]
		  ,[Material Group]
		  ,[Old material number]
		  ,[Base Unit of Measure]
		  ,[Gross weight]
		  ,[Weight unit]
		  ,[Volume]
		  ,[Volume Unit]
		  ,[Transportation Group]
		  ,[EAN/UPC]
		  ,[EAN category]
		  ,[Length]
		  ,[Width]
		  ,[Height]
		  ,[Unit of Dimension]
		  ,[Product hierarchy]
		  ,[Allowed pkg weight]
		  ,[Allowed pkg volume]
		  ,[X-Plant Matl Status]
		  ,[Qual.f.FreeGoodsDis.]
		  ,[Gen. item cat. grp]
		  ,[Last Changed Time]
		  ,[Segmentation Status]
		  ,[Segmentation Strategy Scope]
		  ,[Segmentation Relevant]
		  ,[Product]
		  ,[Product ID]
		  )
	select 
		 MARC.MANDT
		-- MARC
		,MARC.MATNR	
		,MARC.WERKS	
		--,MARC.PSTAT	
		,MARC.BWTTY	
		,MARC.XCHAR	
		,MARC.MMSTA	
		,MARC.EKGRP	
		,MARC.DISMM	
		,MARC.DISPO	
		,MARC.PLIFZ	
		,MARC.WEBAZ	
		,MARC.PERKZ	
		,MARC.AUSSS	
		,MARC.DISLS	
		,MARC.BESKZ	
		,MARC.BSTMI	
		,MARC.LADGR	
		,MARC.MTVFP	
		,MARC.VBAMG	
		,MARC.VBEAZ	
		,MARC.STAWN	
		,MARC.HERKL	
		,MARC.PRCTR	
		,MARC.STRGR	
		,MARC.CUOBV	
		,MARC.LGFSB	
		,MARC.LFMON	
		,MARC.LFGJA	
		,MARC.BWESB	
		,MARC.SGT_COVS	
		,MARC.SGT_STATC	
		--,MARC.SGT_SCOPE	
		--,MARC.SCM_MATLOCID_GUID16	
		,MARC.SCM_MATLOCID_GUID22
		-- 33 + MANDT
		-- MARA
		,MARA.ERSDA	
		,MARA.ERNAM	
		,MARA.LAEDA	
		,MARA.AENAM	
		,MARA.VPSTA	
		,MARA.PSTAT	
		,MARA.LVORM	
		,MARA.MTART	
		,MARA.MBRSH	
		,MARA.MATKL	
		,MARA.BISMT	
		,MARA.MEINS	
		,MARA.BRGEW	
		,MARA.GEWEI	
		,MARA.VOLUM	
		,MARA.VOLEH	
		,MARA.TRAGR	
		,MARA.EAN11	
		,MARA.NUMTP	
		,MARA.LAENG	
		,MARA.BREIT	
		,MARA.HOEHE	
		,MARA.MEABM	
		,MARA.PRDHA	
		,MARA.ERGEW	
		,MARA.ERVOL	
		,MARA.MSTAE	
		,MARA.NRFHG	
		,MARA.MTPOS_MARA	
		,MARA.LAST_CHANGED_TIME	
		,MARA.SGT_STAT	
		,MARA.SGT_SCOPE	
		,MARA.SGT_REL
		,MARA.SCM_MATID_GUID16
		,MARA.SCM_MATID_GUID22
		-- 35
	from 
		[CT dwh 01 Stage].[dbo].[tSAP_MARC] marc with (nolock)
	inner join 
		[CT dwh 01 Stage].[dbo].[tSAP_MARA] mara with (nolock) 
	on marc.MATNR = mara.MATNR

	-- 16.12.2020/FT: new Kitting Table -> https://jira.chal-tec.com/browse/DEVTCK-18017
	TRUNCATE TABLE [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesKittingTemp]

	;with cte as (
	select OutboundDeliveryNoteDocumentNo as Bel from [CT dwh 03 Intelligence].dbo.vFactPurchasingOrdersTransactions with (nolock) where OutboundDeliveryNoteDocumentType = 'OutboundDeliveryNote' and OutboundDeliveryNoteDocumentNo is not null and [source] = 'SAP'
	union
	select DeliveryNoteDocumentNo as Bel from [CT dwh 03 Intelligence].dbo.vFactPurchasingOrdersTransactions with (nolock) where DeliveryNoteDocumentType = 'DeliveryNote' and DeliveryNoteDocumentNo is not null and [source] = 'SAP'
	)
	INSERT INTO [CT dwh 03 Intelligence].[dbo].[tDeliveryNotesKittingTemp] (
		  [MANDT]
		  ,[Actual_Goods_Movement_Date]
		  ,[Bill_of_Lading_(BOLNR)]
		  ,[Bill_of_Lading_(ZZ_LIEFNR)]
		  ,[Document_Changed_by]
		  ,[Document_Changed_on]
		  ,[Company_ID]
		  ,[Document_created_by]
		  ,[Document_created_on]
		  ,[customer_intercompany_billing_nb]
		  ,[Date_of_unloading]
		  ,[Delivery_Location_Time_Zone]
		  ,[Delivery]
		  ,[Delivery_Date]
		  ,[Delivery_Type]
		  ,[Depreciation_percentage]
		  ,[Distribution_Channel]
		  ,[Document_Currency]
		  ,[Document_Date]
		  ,[ETA_Port]
		  ,[Exchange_rate_stats]
		  ,[External_Delivery_ID]
		  ,[Forwarder_Reference]
		  ,[ID:_Delivery_Split,_Warehouse_No.]
		  ,[Incoterms]
		  ,[Incoterms_(Part_2)]
		  ,[Incoterms_Location_1]
		  ,[Incoterms_Version]
		  ,[Division_for_intercompany_billing]
		  ,[Intercompany_billing_type]
		  ,[Containernumber]
		  ,[Containertype]
		  ,[Net_weight]
		  ,[Order_Combination]
		  ,[Original_document]
		  ,[POD_Confirmation_Time]
		  ,[Procedure]
		  ,[Proof_of_Delivery_Date]
		  ,[Time_zone_of_recipient_location]
		  ,[Receiving_Plant]
		  ,[Sales_organization]
		  ,[Sales_Organization_for_intercmopany_billing]
		  ,[SD_Document_Category]
		  ,[Shipping_Point/Receiving_Pt]
		  ,[Ship-to_party]
		  ,[Statistics_Currency]
		  ,[Status_of_delivery_note]
		  ,[Telex_release]
		  ,[Document_creation_time]
		  ,[Total_Weight]
		  ,[Vendor]
		  ,[Vessel]
		  ,[Total_Volume]
		  ,[Total_Volume_Unit]
		  ,[Warehouse_Number]
		  ,[Total_Weight_Unit]
		  -- LIPS
		  ,[Actual_Delivery_QTY_in_packaging_unit_of_measure]
		  ,[Base_Unit_of_Measure]
		  ,[Batch]
		  ,[Item_changed_on]
		  ,[Item_created_by]
		  ,[Item_created_on]
		  ,[Actual_Delivery_QTY_in_storage_unit]
		  ,[original_delivery_QTY]
		  ,[EAN/UPC]
		  ,[Item_gross_weight]
		  ,[Item]
		  ,[Item_Category]
		  ,[Item_Description]
		  ,[Material]
		  ,[Material_Group]
		  ,[Movement_type]
		  ,[Production_Order]
		  ,[Production_Order_Item_Nb]
		  ,[Plant]
		  ,[Product_hierarchy]
		  ,[Profit_Center]
		  ,[Reference_document]
		  ,[Reference_Item]
		  ,[Storage_location]
		  ,[Item_creation_time]
		  ,[Item_Volume]
		  ,[Item_Volume_Unit]
		  ,[Item_Weight_Unit]
	 )
	SELECT
		 LIKP.MANDT
		,LIKP.WADAT_IST
		,LIKP.BOLNR
		,LIKP.ZZ_LIEFNR
		,LIKP.AENAM
		,LIKP.AEDAT
		,LIKP.VBUND
		,LIKP.ERNAM
		,LIKP.ERDAT
		,LIKP.KUNIV
		,LIKP.ZZ_LOESCHDATE
		,LIKP.TZONIS
		,LIKP.VBELN
		,LIKP.LFDAT
		,LIKP.LFART
		,LIKP.AKPRZ
		,LIKP.VTWIV
		,LIKP.WAERK
		,LIKP.BLDAT
		,LIKP.ZZ_ETAPORT
		,LIKP.STCUR
		,LIKP.LIFEX
		,LIKP.ZZ_SPEDIREFERENZ
		,LIKP.LISPL
		,LIKP.INCO1
		,LIKP.INCO2
		,LIKP.INCO2_L
		,LIKP.INCOV
		,LIKP.SPAIV
		,LIKP.FKAIV
		,LIKP.TRAID
		,LIKP.TRATY
		,LIKP.NTGEW
		,LIKP.KZAZU
		,LIKP.VERUR
		,LIKP.POTIM
		,LIKP.KALSM
		,LIKP.PODAT
		,LIKP.TZONRC
		,LIKP.WERKS
		,LIKP.VKORG
		,LIKP.VKOIV
		,LIKP.VBTYP
		,LIKP.VSTEL
		,LIKP.KUNNR
		,LIKP.STWAE
		,LIKP.VLSTK
		,LIKP.ZZ_TELEXREL
		,LIKP.ERZET
		,LIKP.BTGEW
		,LIKP.LIFNR
		,LIKP.ZZ_SCHIFF
		,LIKP.VOLUM
		,LIKP.VOLEH
		,LIKP.LGNUM
		,LIKP.GEWEI
		-- LIPS
		,LIPS.LGMNG
		,LIPS.MEINS
		,LIPS.CHARG
		,LIPS.AEDAT
		,LIPS.ERNAM
		,LIPS.ERDAT
		,LIPS.LFIMG
		,LIPS.ORMNG
		,LIPS.EAN11
		,LIPS.BRGEW
		,LIPS.POSNR
		,LIPS.PSTYV
		,LIPS.ARKTX
		,LIPS.MATNR
		,LIPS.MATKL
		,LIPS.BWART
		,LIPS.AUFNR
		,LIPS.POSNR_PP
		,LIPS.WERKS
		,LIPS.PRODH
		,LIPS.PRCTR
		,LIPS.VGBEL
		,LIPS.VGPOS
		,LIPS.LGORT
		,LIPS.ERZET
		,LIPS.VOLUM
		,LIPS.VOLEH
		,LIPS.GEWEI
	from 
		[CT dwh 01 Stage].[dbo].[tSAP_LIPS] LIPS WITH (NOLOCK)
	LEFT JOIN
		[CT dwh 01 Stage].[dbo].[tSAP_LIKP] AS LIKP WITH (NOLOCK)
	ON
		LIPS.MANDT     = LIKP.MANDT
		AND LIPS.VBELN = LIKP.VBELN
	left outer join
		cte on cte.Bel = LIPS.VBELN
	where 
		lips.MATNR like '00000000007%'
	-- only show datasets without information in vFactPurchasingOrdersTransactions
	and cte.bel is null

	--###################
	-- 13.01.2021/FT: https://jira.chal-tec.com/browse/DEVTCK-18139
	TRUNCATE TABLE [CT dwh 03 Intelligence].[dbo].tContract
	
	INSERT INTO [CT dwh 03 Intelligence].[dbo].[tContract]
           ([PurchasingDocument]
           ,[Item]
           ,[EffectiveValue]
           ,[PurchOrganization]
           ,[Incoterms]
           ,[IncotermsPart2]
           ,[IncotermsLocation1]
           ,[IncotermsLocation2]
           ,[IncotermsVersion]
           ,[PurchasingInfoRec]
           ,[DocConditionNo]
           ,[ProfitCenter]
           ,[StorageLocation]
           ,[Vendor]
           ,[MaterialGroup]
           ,[Material]
           ,[NetOrderPrice]
           ,[SupplyingPlant]
           ,[CommodityCode]
           ,[DocumentItem]
           ,[VolumeUnit]
           ,[Volume]
           ,[Currency]
           ,[GRMessage]
           ,[Plant]
           ,[ExchangeRate]
           ,[PaymentIn]
           ,[Discpercent2]
           ,[PaymentTerms]
           ,[Kontraktnummer]
           ,[GrossWeight]
           ,[GrossOrderValue]
           ,[PurchDocCategory]
           ,[CompanyCode])
	select 
		 EKPO.EBELN		as PurchasingDocument
		,EKPO.EBELP		as Item
		,EKPO.EFFWR		as EffectiveValue
		,EKKO.EKORG		as PurchOrganization
		,EKPO.INCO1		as Incoterms
		,EKKO.INCO2		as IncotermsPart2
		,EKKO.INCO2_L	as IncotermsLocation1
		,EKKO.INCO3_L	as IncotermsLocation2
		,EKKO.INCOV		as IncotermsVersion
		,EKPO.INFNR		as PurchasingInfoRec
		,EKKO.KNUMV		as DocConditionNo
		,EKPO.KO_PRCTR	as ProfitCenter
		,EKPO.LGORT		as StorageLocation
		,EKKO.LIFNR		as Vendor
		,EKPO.MATKL		as MaterialGroup
		,EKPO.MATNR		as Material
		,EKPO.NETPR		as NetOrderPrice
		,EKKO.RESWK		as SupplyingPlant
		,EKPO.STAWN		as CommodityCode
		,EKPO.UNIQUEID	as DocumentItem
		,EKPO.VOLEH		as VolumeUnit
		,EKPO.VOLUM		as Volume
		,EKKO.WAERS		as Currency
		,EKKO.WEAKT		as GRMessage
		,EKPO.WERKS		as Plant
		,EKKO.WKURS		as ExchangeRate
		,EKKO.ZBD1T		as PaymentIn
		,EKKO.ZBD2P		as Discpercent2
		,EKKO.ZTERM		as PaymentTerms
		,EKKO.ZZKONNR	as Kontraktnummer
		,EKPO.BRGEW		as GrossWeight
		,EKPO.BRTWR		as GrossOrderValue
		,EKKO.BSTYP		as PurchDocCategory
		,EKPO.BUKRS		as CompanyCode 
	from 
		[CT dwh 02 Data].dbo.tSAPEKPO ekpo with (nolock)
	join 
		[CT dwh 02 Data].dbo.tSAPEKKO ekko with (nolock) 
	on 
		ekko.EBELN = ekpo.EBELN
	where 
		ekpo.LOEKZ = '' 
	and ekko.LOEKZ = ''
	and ekko.BSTYP = 'K'
	and ekpo.valid_to = '22000101'
	and ekpo.is_deleted = 0
	and ekko.valid_to = '22000101'
	and ekko.is_deleted = 0
END
GO
/****** Object:  StoredProcedure [dbo].[spLoadFactSalesAlltransactions]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************
** Name: Loads the Data from from the sage tables in the tfactalltransactionssales
** Auth: [Michael Kother]
** Date: 20/08/2020
**************************
** Change History
**************************
** PR   Date		 Author			Description 
** --   --------	 -------		------------------------------------
** 1	14/10/2020	Hbarbosa	      Store Procedure Creation (based on spLoadFactSalesTransactionsVertical)
** 2	05/02/2021	PKumari	      DEVTCK-18382 - Sales channel fallback
** 3	05/02/2021	PKumari	      DEVTCK-18377 - ChannelGroupI basy on fulfillment 
** 4	05/02/2021	HBarbosa      DEVTCK-18376 - Added Storage Location Dimension
** 5	08/02/2021	HBarbosa      DEVTCK-18374 - Update channel fields when intercompany is not null
** 6	08/02/2021	HBarbosa      DEVTCK-18375 - Update fulfillment to PBM in all transactions in a process that has a PBM transaction
** 7	16/02/2021	HBarbosa      DEVTCK-18467 - Update fulfillment to PBM/FBA in all transactions in a process whic orderID from amazon was processed in ther present batch 
** 8	25/02/2021	HBarbosa      DEVTCK-18502 - Create/Update Sales Account Dimension
** 9	04/03/2021	HBarbosa      Added exception for processid 15581848, until a solution is found; there's 2 entries in [KHKVKBelegePositionenLager] for the same position 
** 10	19/03/2021	HBarbosa      DEVTCK-18672 - Datawarehouse Sales MarketplaceOrderID
** 11	19/03/2021	HBarbosa      DEVTCK-18975 - Update Storage fields with latest record updated in Data layer (temp fix)
** 12	11/05/2021	PKumari		  DEVTCK-19064 - adding new field - ItemFamily
** 13	01/06/2021	HBarbosa	  DEVTCK-19230 - renaming fullfilment kali to Lager kali
** 14	07/06/2021	HBarbosa	  DEVTCK-19299 - Add postcode, city and country  (Invoicing data)
*******************************
**************************
** Return Values
**************************
	0  - Success
	-1 - Default
**************************
** Execution Examples
**************************
EXEC spLoadFactSalesAlltransactions --- Executes delta changes
EXEC spLoadFactSalesAlltransactions @dtStartDate = '2020-01-01', @dtEndDate = '2020-01-31',@bUseDeltaLoad =0 --- Executes process for all january transactions
EXEC spLoadFactSalesAlltransactions @bUseDeltaLoad =0 ,@nProcessID = --- Executes process for a specific processid

**/

CREATE PROCEDURE [dbo].[spLoadFactSalesAlltransactions]
	@dtStartDate date = null,
	@dtEndDate date = null,
	@nProcessID as int = 0,
	@bUseDeltaLoad bit = 1,   --- used to process all the transactions from the datalayer to [mdRecordToLoadFlag] = 1
	@bIsLogOn bit= 0
AS

/***********************************************
DECLARE Variables
***********************************************/

DECLARE @nRet INT
DECLARE @tmsg AS NVARCHAR(255)

SET @nRet = -1

SET @tmsg = '[spLoadFactSalesAlltransactions]'
EXEC [CT dwh 00 Meta].dbo.usp_DebugIn @tmsg, @bIsLogOn

Declare @dtExecutionStart as datetime = getdate()
Declare @dtLastExecution as datetime2

/***********************************************
SET dates
***********************************************/

IF(@dtStartDate is null and @nProcessID = 0)
BEGIN
	SET @dtStartDate = cast(getdate()-1 as date)
END
ELSE 
BEGIN
	IF (@nProcessID> 0 )
	BEGIN
		SELECT @dtStartDate = isnull(min(BelegDatum),'2016-01-01') FROM [CT dwh 02 Data].dbo.tErpKHKVKBelege with(nolock) where vorid = @nProcessID
	END
END

IF(@dtEndDate is null)
BEGIN
	SET @dtEndDate = cast(getdate() as date)
END
SET @tmsg = 'Process Dates: Start:['+isnull(cast(@dtStartDate as nvarchar), 'null')+']; End Date['+isnull(cast(@dtEndDate as nvarchar), 'null')+']'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0



IF(@bUseDeltaLoad = 1)
BEGIN
	--- Get the value on the config table for LastSalesExecutionDate
	Select @dtLastExecution = tConfigValue from [CT dwh 00 Meta].dbo.tGlobalConfig where aConfigId = 1
END

BEGIN TRY

/***********************************************
Temp tables declaration
***********************************************/

	CREATE TABLE #TMP_EntriesToLoad
	(
		[VorID] [int] NOT NULL,
		[Mandant] [smallint] NOT NULL,
		[BelID] [int] NOT NULL,
		[PositionId] [int] NOT NULL,
		--ReferenceID nvarchar(150) NOT NULL
	) 


TRUNCATE TABLE [CT dwh 02 Data].[dbo].[FactSales_Staging]	

/***********************************************
Delete BelIDs with deleted positions
***********************************************/
IF(@nProcessID = 0 and @bUseDeltaLoad = 1)
BEGIN


	SET @tmsg = 'START: Mark deleted positions'
	EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
			
			declare @nCountDeleted  int = 0
			--check deleted entries since last execution in Belege
			Select @nCountDeleted =COUNT(*) from [CT dwh 02 Data].dbo.tErpKHKVKBelege with(nolock) where IsDeletedFlag=1 AND mdInsertDate > @dtLastExecution
			--check deleted entries since last execution in Belegepositionen
			Select @nCountDeleted =@nCountDeleted + COUNT(*) from [CT dwh 02 Data].dbo.tErpKHKVKBelegepositionen with(nolock) where IsDeletedFlag=1 AND mdInsertDate > @dtLastExecution
	
	IF(@nCountDeleted > 0)
	BEGIN

		UPDATE Fact
			SET  Fact.bIsDeleted = 1, dtDeleted = getdate(), fact.IsProcessed = 0,fact.LastModified = getdate()
		FROM  [CT dwh 02 Data].[dbo].[tFactAllSalesTransactions] AS Fact 
		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegePositionen AS Pos WITH (NOLOCK)
			ON Fact.CompanyId = Pos.Mandant 
			AND Fact.DocumentLineID = Pos.BelPosID
		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelege AS belege WITH (NOLOCK)
			ON Fact.CompanyId = belege.Mandant 
			AND Fact.DocumentID = belege.BelID
		WHERE (Pos.IsDeletedFlag = 1 or belege.IsDeletedFlag=1)and Fact.bIsDeleted =0
		and (pos.mdInsertDate > @dtLastExecution or belege.mdInsertDate >@dtLastExecution)
			
			SET @tmsg = 'END: Mark deleted positions['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]'
			EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
	END
	ELSE
	BEGIN
		SET @tmsg = 'END: Mark deleted positions[0 rows affected]'
		EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
	END

END



/***********************************************
Get entries to load
***********************************************/
SET @dtExecutionStart = getdate()
SET @tmsg = 'START: Get Entries to Load'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

---if its not a delta execution, we can retrieve the process id's affectedby the date only using the belege table (faster than using the conditions used by the delta query)
IF(@bUseDeltaLoad = 0)
BEGIN
	INSERT INTO #TMP_EntriesToLoad
			(
				VorID
				, Mandant
				,[BelID]
				,PositionId
			)
			SELECT DISTINCT
				Belege.VorID
			  , Belege.Mandant
			  ,BELEGE.belid
			, ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID) AS PositionId
			FROM [CT dwh 02 Data].dbo.tErpKHKVKBelege AS Belege WITH (NOLOCK)
			INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegePositionen AS BelegePositionen WITH(NOLOCK)
					ON Belege.Mandant = BelegePositionen.Mandant
					AND Belege.BelID = BelegePositionen.BelID
					AND BelegePositionen.IsDeletedFlag = 0
			LEFT JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegeStuecklisten AS Stuecklisten WITH(NOLOCK)
				ON BelegePositionen.Mandant = Stuecklisten.Mandant
				AND BelegePositionen.BelPosID = Stuecklisten.BelPosID
				AND Stuecklisten.ArtikelNummer not like '7%'
			WHERE 1 = 1
			AND Belege.Mandant IN (1, 2, 3)
			AND Cast(Belege.Belegdatum as date) between @dtStartDate and @dtEndDate		
			AND (@nProcessID = Belege.VorID OR @nProcessID = 0)
			AND BELEGE.IsDeletedFlag = 0

END
ELSE
BEGIN
	INSERT INTO #TMP_EntriesToLoad
		(
			VorID
			, Mandant
			,[BelID]
			,PositionId
		)
		SELECT DISTINCT
			Belege.VorID
			, Belege.Mandant
			,BELEGE.belid
			, ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID) AS PositionId

		FROM [CT dwh 02 Data].dbo.tErpKHKVKBelege AS Belege WITH (NOLOCK)
		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegePositionen AS BelegePositionen WITH(NOLOCK)
			ON Belege.Mandant = BelegePositionen.Mandant
			AND Belege.BelID = BelegePositionen.BelID
			AND BelegePositionen.IsDeletedFlag = 0
		LEFT JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegeStuecklisten AS Stuecklisten WITH(NOLOCK)
			ON BelegePositionen.Mandant = Stuecklisten.Mandant
			AND BelegePositionen.BelPosID = Stuecklisten.BelPosID
			AND Stuecklisten.ArtikelNummer not like '7%'

		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKArtikel AS Art WITH (NOLOCK)
			ON ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) = Art.Artikelnummer
			AND Belege.Mandant = Art.Mandant
		WHERE 1 = 1
			AND Belege.Mandant IN (1, 2, 3)
			AND (

						Belege.mdInsertDate >= @dtLastExecution
						OR 
						BelegePositionen.mdInsertDate  >= @dtLastExecution
						OR 
						Stuecklisten.mdInsertDate  >= @dtLastExecution
				)
			AND VORID>0
			AND BELEGE.IsDeletedFlag = 0

							
END
		

SET @tmsg = 'END: Get Entries to Load['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
	CREATE INDEX IDX_Entries_VorID_MANDANT ON #TMP_EntriesToLoad(VorID,[Mandant])


/***********************************************
Process Main Data
***********************************************/
---      Probably we can merge the above query selection with the below one to avoid querying the tables again
SET @tmsg = 'START: Get Data into [CT dwh 02 Data].[dbo].[FactSales_Staging]	'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

		INSERT INTO [CT dwh 02 Data].[dbo].[FactSales_Staging]	
		(           
			 [ProcessId]
			, [CompanyId]
			, [TransactionType]
			, [TransactionTypeDetail]
			, [DocumentNo]
			, [DocumentId]
			, [ReferenceDocumentId]
			, [TransactionDate]
			, [ItemNo]
			, [DocumentItemLine]
			, [PositionId]
			, [PositionIdRC]
			, [Quantity]
			, [NetPrice]
			, [ReferenceId]
			, [RC]
			, [DeliveryCountry]
			, ItemNoProduct
			, [Description]
			, [CustomerID]
			, InvoiceCountry
			, Salesman
			, [MEK_WE]
			, [MEK_Hedging]
			, [MEK_Plan]
			,[Nettobetrag]
			,[WKzKursFw]
			,[GesamtpreisInternEW]
			,[ZWInternEW]
			,PositionQuantity
			,Channel
			,[ChannelGroupI]
			,[ChannelGroupII]
			,Intercompany
			,TransactionTypeShort
			,Vertreter
			,Kundengruppe
			,DocumentLineID
			,DocumentLineQty
			,StatistikWirkungUmsatz
			,GruppenTag
			,NetPriceForeignCurrency
			,Currency
			,Steuercode
			,InvoiceZipCode
			,InvoiceCity
		)          

		SELECT 
			Belege.VorID AS ProcessId
			, Belege.Mandant AS CompanyId
			,CASE WHEN TranType.id is null THEN 'Other' ELSE TranType.TransactionType END  TransactionType
			, Belegarten.Bezeichnung AS TransactionTypeDetail
			, Belege.Belegnummer AS DocumentNo
			, Belege.BelID AS DocumentId
			, Belege.ReferenzBelID AS ReferenceDocumentId
			, CAST(Belege.Belegdatum AS DATE) AS TransactionDate
			,  ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) AS ItemNo
			, ISNULL(substring(BelegePositionen.Position,1,1),1) Position
			, ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID) AS PositionId
			,CASE WHEN N.Number is null THEN ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) ELSE 1 END as Quantity-- ROW_NUMBER() OVER (PARTITION BY Belege.VorID, Belege.BelID, Belege.Mandant, ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) ORDER BY ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID)) AS PositionIdRC
			, CASE WHEN N.Number is null THEN ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) ELSE 1 END as Quantity--ISNULL(n.Number, ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)) as Quantity
			, CASE
				WHEN ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0 THEN (ISNULL(Stuecklisten.GesamtPreisInternEW, BelegePositionen.GesamtPreisInternEW) / ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge))	
					ELSE 0
			  END AS NetPrice
			,CAST(CAST(Belege.VorID AS VARCHAR(10)) + '-' +  CAST(Belege.Mandant AS VARCHAR(1)) + '-' + CAST(Belege.BelID AS VARCHAR(10)) + '-' + ISNULL(CAST(Stuecklisten.BelPosStID AS VARCHAR(10)), CAST(BelegePositionen.BelPosID AS VARCHAR(10))) AS NVARCHAR(50))
			,ISNULL(n.Number, ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)) as RC
			, Belege.A1Land		as DeliveryCountry
			, BelegePositionen.Artikelnummer  as ItemNoProduct
			,  CASE  WHEN Stuecklisten.BelPosID IS NULL THEN BelegePositionen.Bezeichnung1 ELSE Stuecklisten.Bezeichnung1 END as [Description]
			, Belege.A0Empfaenger as CustomerID
			, Belege.A0Land
			, Belege.Vertreter
			,abs(round((CASE WHEN (ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '4%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '6%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '7%') 
					and ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0  THEN 
								(isnull(isnull(Stuecklisten.gesamtpreisinternEW,BelegePositionen.gesamtpreisinternEW) ,0) - isnull(isnull(Stuecklisten.roherloes,BelegePositionen.roherloes) ,0))/ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
				ELSE isnull(isnull(ham1.[MEK_WE],ham2.[MEK_WE]) * mAufschlag.[Aufschlag] * CASE WHEN ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '9%' THEN 0 ELSE 1 END,0) 
				END),2))  AS [Wareneinsatz MEK WE nach Retouren]
			,abs(round((CASE WHEN (ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '4%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer)like '6%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '7%') and ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0  THEN (isnull(isnull(Stuecklisten.gesamtpreisinternEW,BelegePositionen.gesamtpreisinternEW),0) - isnull(isnull(Stuecklisten.roherloes,BelegePositionen.roherloes) ,0))/ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
				ELSE isnull(isnull(ham1.[MEK_Hedging],ham2.[MEK_Hedging]) * mAufschlag.[Aufschlag] * CASE WHEN ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '9%' THEN 0 ELSE 1 END,0) 
				END),2)) AS [Wareneinsatz MEK Hedging nach Retouren]
			,abs(round((CASE WHEN (ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '4%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '6%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '7%') and ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0  THEN (isnull(isnull(Stuecklisten.gesamtpreisinternEW,BelegePositionen.gesamtpreisinternEW) ,0) - isnull(isnull(Stuecklisten.roherloes,BelegePositionen.roherloes) ,0))/ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
				ELSE isnull(isnull(ham1.[MEK_Plan_YoY],ham2.[MEK_Plan_YoY]) * mAufschlag.[Aufschlag] * CASE WHEN ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer)like '9%' THEN 0 ELSE 1 END,0) 
				END),2)) AS [Wareneinsatz MEK Plan nach Retouren]
			,Belege.[Nettobetrag]
			,Belege.[WKzKursFw]
			,isnull(Stuecklisten.[GesamtpreisInternEW], BelegePositionen.[GesamtpreisInternEW])
			,Belege.[ZWInternEW]
			,ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
			,ISNULL(Channel.Channel, Gruppen.Bezeichnung) AS Channel		-- DEVTCK-18382 - Sales channel fallback
			,Channel.ChannelGroupI
			,Channel.ChannelGroupII
			,IntCompany.[KG_Bezeichnung] as Intercompany
			,Belege.Belegkennzeichen
			,Belege.Vertreter
			,Belege.Kundengruppe
			,BelegePositionen.belposid
			,BelegePositionen.Menge
			,StatistikWirkungUmsatz
			,Gruppen.Tag
			,CASE
				WHEN ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0 
						THEN (ISNULL(Stuecklisten.GesamtpreisInternEW, BelegePositionen.GesamtpreisIntern ) / ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge))/ Case when Stuecklisten.GesamtpreisInternEW is null then 1 else isnull(WKzKursFw,1) end	
					ELSE 0
			  END AS NetPriceForeign
			,belege.wkz
			,ISNULL(BelegePositionen.Steuercode, Stuecklisten.Steuercode)
			,Belege.A0PLZ
			,Belege.A0Ort
		From
		[CT dwh 02 Data].dbo.tErpKHKVKBelege AS Belege WITH (NOLOCK)
		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegarten AS Belegarten WITH(NOLOCK) 
			ON 	 Belegarten.Kennzeichen = Belege.Belegkennzeichen   
		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegePositionen AS BelegePositionen WITH(NOLOCK)
			ON Belege.Mandant = BelegePositionen.Mandant
			AND Belege.BelID = BelegePositionen.BelID
			AND BelegePositionen.IsDeletedFlag = 0
		LEFT JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegeStuecklisten AS Stuecklisten WITH(NOLOCK)
			ON BelegePositionen.Mandant = Stuecklisten.Mandant
			AND BelegePositionen.BelPosID = Stuecklisten.BelPosID
			AND Stuecklisten.ArtikelNummer not like '7%'
		INNER JOIN #TMP_EntriesToLoad AS EntriesToLoad
			ON Belege.VorID = EntriesToLoad.VorID
			AND Belege.BelID = EntriesToLoad.BelID
			AND Belege.Mandant = EntriesToLoad.Mandant
			AND ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID) = EntriesToLoad.PositionId
		LEFT JOIN [CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSalesOrders] TranType  WITH(NOLOCK)
			ON TranType.TransactionTypeShort = Belege.Belegkennzeichen	
		LEFT JOIN  [CT dwh 00 Meta].[dbo].[Numbers] n WITH(NOLOCK)on n.Number <=  ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
		LEFT JOIN [CT dwh 00 Meta].[dbo].[tChannelAndGroupConfigSales] Channel
			ON Belege.Kundengruppe = Channel.Kundengruppe
			AND Belege.Mandant = Channel.Mandant
		LEFT JOIN [CT dwh 02 Data].[dbo].[tERPKHKGruppen] AS Gruppen WITH(NOLOCK)
			ON  BELEGE.Kundengruppe = gruppen.gruppe
			AND Gruppen.typ = 11
			AND BELEGE.Mandant = Gruppen.Mandant
		LEFT JOIN [CT dwh 02 Data].[dbo].tErpChalTec_Kundennummer_Mapping IntCompany
			ON 
			 Belege.Mandant = IntCompany.Mandant
			AND BELEGE.A0Empfaenger = IntCompany.Kundennummer
		LEFT JOIN [CT dwh 02 Data].[dbo].[tDwhHistorischerArtikelMEK] AS ham1 WITH(NOLOCK)
			ON ham1.[Artikelnummer] = '10' + RIGHT(ISNULL(Stuecklisten.[Artikelnummer],BelegePositionen.[Artikelnummer]),6)
			AND ISNULL(Stuecklisten.[Artikelnummer],BelegePositionen.[Artikelnummer]) LIKE '[15]%'
			AND ham1.[Datum] = CAST(BELEGE.[Belegdatum] AS DATE)
		LEFT JOIN (
				SELECT 
					[Artikelnummer]
					,[MEK_WE]
					,[MEK_Hedging]
					,[MEK_Plan_YoY]
					,rank() over (partition by Artikelnummer order by Datum desc, [MEK_Plan_YoY] desc, Mandant asc) AS Rang
				FROM [CT dwh 02 Data].[dbo].[tDwhHistorischerArtikelMEK]
				WHERE Artikelnummer like '1%'
			) AS ham2
			ON ham2.[Artikelnummer] = '10' + RIGHT(ISNULL(Stuecklisten.[Artikelnummer],BelegePositionen.[Artikelnummer]),6)
			AND ISNULL(Stuecklisten.[Artikelnummer],BelegePositionen.[Artikelnummer]) LIKE '[15]%'
			AND ham2.Rang = 1
		LEFT JOIN (
			SELECT 1 AS [Mandant], CAST(1 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 2 AS [Mandant], CAST(1.3 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 3 AS [Mandant], CAST(1.2 AS MONEY) AS [Aufschlag]
		) AS MAufschlag
			ON MAufschlag.[Mandant] = BELEGE.[Mandant]
	WHERE
		ISNULL(Stuecklisten.Artikelnummer, isnull(BelegePositionen.Artikelnummer,'')) <> ''
		AND BELEGE.IsDeletedFlag = 0
SET @tmsg = 'END: Get Data into [CT dwh 02 Data].[dbo].[FactSales_Staging]	['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
----Update main data table with the transaction id's from the reference table
/*----------------------------------------------------
Item Dimensions
https://jira.chal-tec.com/browse/DEVTCK-17527
-----------------------------------------------------*/

SET @tmsg = 'START: Update Item Dimensions'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET ProductHierarchie1 = art.tProductHierarchie1,
	 ProductHierarchie2 = art.tProductHierarchie2,
	  ProductHierarchie3 = art.tProductHierarchie3,
	  Sourcer = art.tSourcer,
	  Brand = art.tBrand,
	  Categorymanager = art.tCategoryManagement,
	  Weight = art.fWeight,
	  IntrastatCode = art.tIntrastatCode,
	  Matchcode = art.tMatchCode,
	  Disponent = art.tDisponent,
	  EOL = art.nEOL,
	  ItemClass = art.tItemClass,
	  GTSCode = art.tGTSCode,
	  Stuecklistentyp = art.nStuecklistentyp,
	  ItemFamily = art.tItemFamily
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
inner join [CT dwh 03 Intelligence].dbo.tdimarticle art on art.narticlenumber = dm.ItemNo
and art.nCompanyid = dm.CompanyId


SET @tmsg = 'END: Update Item Dimensions ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
/*----------------------------------------------------
Document Footer
-----------------------------------------------------*/

SET @tmsg = 'START: Update GesamtpreisInternEW'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

	Update dm
		SET dm.GesamtpreisInternEW = res.Gesamtpreis
	FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
	INNER JOIN (
			SELECT processid, companyid,documentid,ItemNo,ItemNoProduct,DocumentLineID,SUM(GesamtpreisInternEW/PositionQuantity) Gesamtpreis--,SUM(GesamtpreisInternBrutto/PositionQuantity) Gesamtpreisbrutto
			FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm2
			Where PositionQuantity>0
			Group by processid, companyid,documentid,ItemNo,ItemNoProduct, DocumentLineID
	) res
		on res.companyid = dm.companyid and res.processid = dm.processid and dm.documentid = res.documentid and dm.ItemNo = res.ItemNo and dm.ItemNoProduct = res.ItemNoProduct
		and res.DocumentLineID = dm.DocumentLineID

SET @tmsg = 'END: Update GesamtpreisInternEW['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

SET @tmsg = 'START: Update Document Footer'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET DocumentFooter = CASE WHEN ZWInternEW > 0 THEN Cast((Nettobetrag * isnull(WKzKursFw,1) - [ZWInternEW]) * (GesamtpreisInternEW/ZWInternEW) as decimal(9,4)) / PositionQuantity  ELSE 0 END
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
where PositionQuantity > 0

SET @tmsg = 'END: Update Document Footer ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
-- Add to the netprice
Update dm
	SET NetPrice = isnull(NetPrice,0)+isnull(DocumentFooter,0) 
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm

/*----------------------------------------------------
Gross Values
-----------------------------------------------------*/

Update dm
	SET GrossDocumentFooter = isnull(dm.DocumentFooter,0) * (1 + (ISNULL(Steuer.Steuersatz, 19)/100)),
		GrossPrice = isnull(NetPrice,0) * (1 + (ISNULL(Steuer.Steuersatz, 19)/100)),
		GrossPriceForeignCurrency = isnull(NetPriceForeignCurrency,0) * (1 + (ISNULL(Steuer.Steuersatz, 19)/100)),
		GrossDocumentFooterForeignCurrency = isnull(DocumentFooter,0) * (1 + (ISNULL(Steuer.Steuersatz, 19)/100))/ISNULL(WkzKursFW, 1)
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
LEFT JOIN [tErpKHKSteuertabelle] AS Steuer WITH (NOLOCK)
	ON dm.Steuercode = Steuer.Steuercode


Update dm
	SET MEK_WE = 0,
		MEK_Hedging = 0,
		MEK_Plan = 0
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
Where Quantity = 0

/*----------------------------------------------------
Refund Type-- from Ticket:
https://jira.chal-tec.com/browse/DEVTCK-17678
-----------------------------------------------------*/

SET @tmsg = 'START: Update Refund Type'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET RefundType = CASE 
							WHEN StatistikWirkungUmsatz <> -1 THEN NULL
							WHEN TransactionTypeShort IN ('VFN','VFT','VSY') THEN 'Cancellation/NotInStock'
							WHEN TransactionTypeShort IN ('VFM') AND NOT 
								(left(ItemNo,1) = 9 OR (ref.[Belegkennzeichen] IN ('VSD') AND GruppenTag IN ('Amazon'))) THEN 'CustomerCancellation'
							WHEN TransactionTypeShort IN ('VFS') AND NOT left(ItemNo,1) = 9 THEN 'Correction'
							WHEN left(ItemNo,1) = 9 AND left(dm.Matchcode,6) = 'Kulanz' THEN 'Goodwill'
							WHEN left(ItemNo,2) = 91 THEN 'Goodwill'
							WHEN left(ItemNo,1) = 9 THEN 'Other 9-Item'
							WHEN GruppenTag IN ('SK') AND TransactionTypeShort IN ('VFG') AND zkd.Zahlungskond IN ('NN') THEN 'ManuallyRefundESAS'
					ELSE 'CustomerRefund'
				END
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
Left Join [CT dwh 02 Data].dbo.tErpKHKVKBelege ref
	on ref.belid = dm.ReferenceDocumentId
	and ref.mandant = dm.CompanyId
Left JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelegeZKD] zkd WITH (NOLOCK)
	on zkd.BelID = dm.DocumentId and zkd.Mandant = dm.CompanyId
Where dm.StatistikWirkungUmsatz = -1

SET @tmsg = 'END: Update Refund Type ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

/*----------------------------------------------------
Article Type-- from Ticket:
https://jira.chal-tec.com/browse/DEVTCK-17676
-----------------------------------------------------*/

SET @tmsg = 'START: Update Article Type'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET ArticleType = CASE 
						WHEN left(ItemNoProduct,1) = 1 AND Stuecklistentyp = 2 THEN 'Kitting'
						WHEN left(ItemNoProduct,1) = 1 THEN 'A-Good'
						WHEN left(ItemNoProduct,1) = 3 THEN 'UK Plug-Item'
						WHEN left(ItemNoProduct,1) = 4 THEN 'Accessories'
						WHEN left(ItemNoProduct,1) = 5 THEN 'B-Good'
						WHEN left(ItemNoProduct,1) = 6 THEN 'Set-Item'
						WHEN left(ItemNoProduct,1) = 7 THEN 'Kitting'
						WHEN ItemNoProduct IN ('90000050') THEN 'Voucher'
						WHEN ItemNoProduct IN ('90000028','90000029','90000128') THEN 'Defect-Good'
						WHEN (left(ItemNoProduct,1) = 9 AND left(Matchcode,6) = 'Kulanz') or ItemNoProduct like '91%' THEN 'Goodwill'
						WHEN left(ItemNoProduct,1) = 9 THEN 'Other 9-Item' ELSE 'Other'
				END
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm

SET @tmsg = 'END: Update Article Type ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

/*----------------------------------------------------
Change VFM transactions to Refund when a VSD exists in the process
https://jira.chal-tec.com/browse/DEVTCK-17676
-----------------------------------------------------*/

SET @tmsg = 'START: Update VFM to Refunds'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

;with ProcessVSD as(
	select Processid,CompanyId from [CT dwh 02 Data].[dbo].[FactSales_Staging]	 where TransactionTypeShort ='VSD' and GruppenTag='Amazon' group by ProcessId,CompanyId having count(*) >0
)
Update dm
	SET TransactionType = 'Refund'
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
Inner join ProcessVSD on ProcessVSD.CompanyId = dm.CompanyId and dm.ProcessId=ProcessVSD.ProcessId
WHERE transactiontypeshort ='VFM'
	


SET @tmsg = 'END: Update VFM to Refunds ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
/*----------------------------------------------------
Change intercompany
https://jira.chal-tec.com/browse/DEVTCK-17676
-----------------------------------------------------*/

SET @tmsg = 'START: Update intercompany'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

;with ProcessVSD as(
	select Processid,CompanyId from [CT dwh 02 Data].[dbo].[FactSales_Staging]	 where TransactionTypeShort ='VSD' and GruppenTag='Amazon' group by ProcessId,CompanyId having count(*) >0
)
Update dm
	SET Intercompany = dm.GruppenTag
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
WHERE Intercompany is null and GruppenTag in ('Mandanten','Weiterberechnung')
	


SET @tmsg = 'END: Update intercompany ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

/*----------------------------------------------------
Item First Sale / Days since first sale
https://jira.chal-tec.com/browse/DEVTCK-17527
-----------------------------------------------------*/

SET @tmsg = 'START: Update First sale'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET FirstSale = isnull(dtFirstSale,dm.TransactionDate), DaysSinceFirstSale = DATEDIFF(Day,cast(isnull(art.dtFirstSale,dm.TransactionDate) as date),Cast(TransactionDate as date))
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
Left join (
		Select a.narticlenumber, min(dtFirstSale)dtFirstSale from [CT dwh 03 Intelligence].[dbo].tdimarticle a where dtFirstSale is not null group by narticlenumber
		) art on art.narticlenumber = dm.ItemNo --and a.Mandant = b.mandant


SET @tmsg = 'END:  Update First sale ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

/*----------------------------------------------------
Fulfillment every row with BelId and Mandant have the 
same value for Frachtfuehrer
-----------------------------------------------------*/
SET @tmsg = 'START: Update Fulfillment'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

UPDATE dm
	SET dm.Fulfillment = 
	case 
		When dm.Kundengruppe in ('116') THEN 'Lager KaLi'
		when (dm.Vertreter in ('V0004','V3001','V3002','V3003','V3004','V3005','V3006','V3007') AND dm.CompanyId in (1,3)) OR (dm.Kundengruppe in ('23','24','25','28','35','106','113','207','214','215')) OR dm.CompanyId = 2 THEN 'B2B'
		when TransactionTypeShort in ('VSD') AND dm.GruppenTag in ('Amazon') THEN 'FBA' 
		when amazon.OrderID IS NOT NULL THEN 'PBM'
		else 'Lager KaLi'
	end
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
LEFT JOIN [CT dwh 02 Data].[dbo].[tErpLBAmazonOrders] amazon WITH (NOLOCK) 
	on amazon.KHKBelId = dm.DocumentId and amazon.KHKVorID = dm.ProcessId 
		and amazon.Mandant = dm.CompanyId and amazon.IsPrime = -1



SET @tmsg = 'END: Update Fulfillment ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0


/*----------------------------------------------------
ChannelGroupI -- https://jira.chal-tec.com/browse/DEVTCK-18377
since the information in the Kundengruppe isn't always correct, 
use the "B2B" information from Fulfillment to fill the ChannelGroupI fields. 
-----------------------------------------------------*/
SET @tmsg = 'START: Update ChannelGroupI for Fulfillment B2B'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

UPDATE dm
	SET dm.ChannelGroupI = 'B2B'
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
WHERE dm.Fulfillment = 'B2B'

SET @tmsg = 'END: Update ChannelGroupI for Fulfillment B2B ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
/*----------------------------------------------------
ChannelGroup fields -- https://jira.chal-tec.com/browse/DEVTCK-18374
When the intercompany field is not null, update the channel fields wtiht the intercompany value
-----------------------------------------------------*/
SET @tmsg = 'START: Update Channel Fields for Intercompany'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

UPDATE dm
	SET dm.ChannelGroupI = dm.Intercompany,
		dm.ChannelGroupII = dm.Intercompany,
		dm.Channel = dm.Intercompany
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
WHERE dm.Intercompany is not null

SET @tmsg = 'END: Update Channel Fields for Intercompany ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
/*----------------------------------------------------
Carrier -- https://jira.chal-tec.com/browse/DEVTCK-17167
every row with BelId and Mandant have the same value for Frachtfuehrer
-----------------------------------------------------*/
SET @tmsg = 'START: Update Carrier'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

UPDATE dm  
	SET dm.Carrier = Frachtfuehrer
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging] dm
INNER JOIN 
	(SELECT  DISTINCT Mandant,BelID,Frachtfuehrer FROM [CT dwh 02 Data].[dbo].tErpLBVLogVersanddaten WITH(NOLOCK) )	vlog 
	ON vlog.BelID = dm.DocumentId AND vlog.Mandant = dm.CompanyId
--WHERE 
--	dm.IsProcessed = 0


SET @tmsg = 'END: Update Carrier ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
/*----------------------------------------------------
Payment Method -- from Ticket:
https://jira.chal-tec.com/browse/DEVTCK-17167
after 2017 all datas with BelId and Mandant are distinct
-----------------------------------------------------*/
SET @tmsg = 'START: Update Payment Method'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET PaymentMethod = zkd.Zahlungskond
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging] dm
INNER JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelegeZKD] zkd WITH (NOLOCK)
	on zkd.BelID = dm.DocumentId and zkd.Mandant = dm.CompanyId
--WHERE 
--	dm.IsProcessed = 0


SET @tmsg = 'END: Update Payment Method ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0


/*----------------------------------------------------
Change fulfilment to PBM to all transactions of a process that has at leats on PBM transaction  
https://jira.chal-tec.com/browse/DEVTCK-18375
-----------------------------------------------------*/

SET @tmsg = 'START: Change fulfilment to PBM'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET dm.Fulfillment = a.Fulfillment 
from [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
inner join [CT dwh 02 Data].[dbo].tFactAllSalesTransactions a with(nolock)
		on  a.processid = dm.processid and a.companyid = dm.companyid and a.Fulfillment in ('PBM','FBA')
where isnull(dm.Fulfillment,'')not in ('PBM' ,'FBA')

Update dm
	SET dm.Fulfillment = a.Fulfillment, dm.LastModified = getdate(), IsProcessed =0
from [CT dwh 02 Data].[dbo].tFactAllSalesTransactions 	 dm
inner join [CT dwh 02 Data].[dbo].[FactSales_Staging]  a with(nolock) 
		on  a.processid = dm.processid and a.companyid = dm.companyid and a.Fulfillment in ('PBM','FBA')
where isnull(dm.Fulfillment,'')not in ('PBM' ,'FBA')

SET @tmsg = 'END: Change fulfilment to PBM ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

/*----------------------------------------------------
IncidentFlag-- from Ticket:
https://jira.chal-tec.com/browse/DEVTCK-17168
-----------------------------------------------------*/

SET @tmsg = 'START: Update IncidentFlag'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET IncidentFlag = 1
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging] dm
INNER JOIN [CT dwh 00 Meta].[dbo].[tIncidentFlagConfig] inc WITH (NOLOCK)
	ON inc.[ProcessID] = dm.ProcessId
--WHERE 
--	dm.IsProcessed = 0

Update [CT dwh 02 Data].[dbo].[FactSales_Staging]
	SET IncidentFlag = 0
Where IncidentFlag is null
--AND 
--	IsProcessed = 0

SET @tmsg = 'END: Update IncidentFlag ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
/*----------------------------------------------------
OwnBrand-- from Ticket:
https://jira.chal-tec.com/browse/DEVTCK-17170
-----------------------------------------------------*/

SET @tmsg = 'START: Update OwnBrand'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

--Update [CT dwh 02 Data].[dbo].[FactSales_Staging]
--	SET OwnBrand = 0
--Where Brand Is Not Null
----AND 
----	IsProcessed = 0


Update dm
	SET OwnBrand = 1
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging] dm
INNER JOIN [CT dwh 00 Meta].[dbo].[tOwnBrandsConfig] ob WITH (NOLOCK)
	ON ob.[OwnBrand] = dm.Brand
--Where 
--	dm.IsProcessed = 0


Update [CT dwh 02 Data].[dbo].[FactSales_Staging]
	SET OwnBrand = 0
Where OwnBrand Is Null
--AND 
--	IsProcessed = 0

SET @tmsg = 'END: Update OwnBrand ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

/*----------------------------------------------------
SalesAccount-- from Ticket:
https://jira.chal-tec.com/browse/DEVTCK-18502
---Eventually this mapping will have to be done from the plenty markets feed
-----------------------------------------------------*/

---amazon
SET @tmsg = 'START: Update SalesAccount- Amazon'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

	Update f
		SET f.SalesAccount = a.SalesChannel
			,f.MarketplaceOrderID = a.OrderID
	from [CT dwh 02 Data].[dbo].[FactSales_Staging] f
	inner join [CT dwh 02 Data].[dbo].[tErpLBAmazonOrders] a with(nolock)
		on a.KHKVorID = f.ProcessId and a.Mandant = f.CompanyId


SET @tmsg = 'END: Update SalesAccount- Amazon ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0


---Shop Orders
SET @tmsg = 'START: Update SalesAccount- Amazon'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

		Update f
			SET f.SalesAccount = s.Description,
				f.MarketplaceOrderID = ss.SaleID
		from [CT dwh 02 Data].[dbo].[FactSales_Staging] f
		inner join [CT dwh 02 Data].[dbo].tErpLBShopSales ss
			on ss.KHKDocId = f.DocumentId and  f.CompanyId = 1
		inner join [CT dwh 02 Data].[dbo].tErpLBShop s
			on s.ShopId = ss.ShopId

SET @tmsg = 'END: Update SalesAccount- Amazon ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

/*----------------------------------------------------
Storage Account-- from Ticket:
https://jira.chal-tec.com/browse/DEVTCK-18975
---This is a temporary solution while a more permanent one is created
-----------------------------------------------------*/
;with lagerposition as (
	
	SELECT BelPosID,Mandant,BelPosStID,PlatzID, ROW_NUMBER() over (partition by BelPosID,Mandant,BelPosStID order by mdinsertdate desc) LagerRank
	FROM [CT dwh 02 Data].dbo.[tErpKHKVKBelegePositionenLager] AS lager WITH(NOLOCK)
	Where IsDeletedFlag = 0 AND BelPosID in (select DocumentLineID FROM FactSales_Staging with(nolock))

)
		
		
		Update f
			SET f.StorageID = lager.PlatzID,
				f.StorageLocation = LagerDescription.Platzbezeichnung
		from [CT dwh 02 Data].[dbo].[FactSales_Staging] f
		INNER JOIN lagerposition AS lager WITH(NOLOCK)
				on lager.BelPosID = f.DocumentLineID
				And lager.Mandant = f.CompanyId
				and lager.BelPosStID = ISNULL(CASE WHEN DocumentLineID <> PositionId THEN PositionId ELSE 0 END,0)
				and lager.LagerRank = 1
		 INNER JOIN [CT dwh 02 Data].[dbo].[tErpKHKLagerplaetze] LagerDescription WITH(NOLOCK)
			on lager.PlatzID = LagerDescription.PlatzID and lager.Mandant = LagerDescription.Mandant


/*----------------------------------------------------
Update Existent transactions in the allsales table
-----------------------------------------------------*/
SET @tmsg = 'START: Update Existent Transactions'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

UPDATE fact
	SET Fact.LastModified = getdate(),
		fact.TransactionDate = temp.TransactionDate,
		fact.Quantity = temp.Quantity,
		fact.NetPrice = temp.NetPrice,
		fact.Fulfillment = temp.Fulfillment,
		fact.DeliveryCountry = temp.DeliveryCountry,
		fact.ItemNoProduct = temp.ItemNoProduct,
		fact.Description = temp.Description,
		fact.CustomerID = temp.CustomerID,
		fact.Sourcer = temp.Sourcer,
		fact.ProductHierarchie1 = temp.ProductHierarchie1,
		fact.ProductHierarchie2 = temp.ProductHierarchie2,
		fact.ProductHierarchie3 = temp.ProductHierarchie3,
		fact.Brand = temp.Brand,
		fact.PaymentMethod = temp.PaymentMethod,
		fact.Carrier = temp.Carrier
		,fact.InvoiceCountry = temp.InvoiceCountry
		,fact.Salesman =temp.Salesman
		, fact.Categorymanager = temp.Categorymanager
		, fact.Disponent = temp.Disponent
		, fact.[EOL] = temp.EOL
		, fact.[ItemClass] = temp.[ItemClass]
		, fact.GTSCode = temp. GTSCode
		, fact.IsProcessed = 0
		, fact.MEK_WE = temp.MEK_WE
		, fact.MEK_Hedging = temp.MEK_Hedging
		, fact.MEK_Plan = temp.MEK_Plan
		, fact.IncidentFlag = temp.IncidentFlag
		, fact.OwnBrand = temp.OwnBrand
		, fact.Matchcode = temp.Matchcode
		,fact.DocumentFooter = isnull(temp.DocumentFooter,0)
		,fact.TransactionType = temp.TransactionType
		,fact.Channel = temp.Channel
		,fact.ChannelGroupI = temp.ChannelGroupI
		,fact.ChannelGroupII = temp.ChannelGroupII
		,fact.Intercompany = temp.Intercompany
		,fact.TransactionTypeShort = temp.TransactionTypeShort
		,fact.DocumentLineID = temp.DocumentLineID
		,fact.DocumentLineQty = temp.DocumentLineQty
		,fact.RefundType = temp.RefundType
		,fact.ArticleType = temp.ArticleType
		,fact.GruppenTag = temp.GruppenTag
		,fact.IntrastatCode = temp.IntrastatCode
		,fact.Weight = temp.Weight
		,fact.NetPriceForeignCurrency = temp.NetPriceForeignCurrency
		,fact.Currency = temp.Currency
		,fact.FirstSale = temp.FirstSale
		,fact.DaysSinceFirstSale = temp.DaysSinceFirstSale
		,fact.ChannelID = temp.Kundengruppe
		,fact.StorageID = temp.StorageID
		,fact.StorageLocation = temp.StorageLocation
		,fact.SalesAccount = temp.SalesAccount
		,fact.GrossDocumentFooter = temp.GrossDocumentFooter
		,fact.GrossDocumentFooterForeignCurrency = temp.GrossDocumentFooterForeignCurrency
		,fact.GrossPrice = temp.GrossPrice
		,fact.GrossPriceForeignCurrency = temp.GrossPriceForeignCurrency
		,fact.MarketplaceOrderID = temp.MarketplaceOrderID
		,fact.ItemFamily = temp.ItemFamily
		,fact.InvoiceZipCode = temp.InvoiceZipCode
		,fact.InvoiceCity = temp.InvoiceCity
FROM [CT dwh 02 Data].[dbo].[tFactAllSalesTransactions] fact
INNER JOIN [CT dwh 02 Data].[dbo].[FactSales_Staging]	 temp on fact.[ReferenceId] = temp.[ReferenceId] and temp.RC = fact.RC  --and fact.[bIsDeleted] = 0


SET @tmsg = 'END: Update Existent Transactions ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

----Insert new rows

SET @tmsg = 'START: Insert  New Transactions'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

INSERT INTO [CT dwh 02 Data].[dbo].[tFactAllSalesTransactions]
				(
					 [ProcessId]
					, [CompanyId]
					, [TransactionType]
					, [TransactionTypeDetail]
					, [DocumentNo]
					, [DocumentId]
					, [ReferenceDocumentId]
					, [TransactionDate]
					, [ItemNo]
					, DocumentItemPosition
					, [PositionId]
					, [PositionIdRC]
					, [Quantity]
					, [NetPrice]
					, [ReferenceId]
					, [RC]
					, [Source]
					,IsProcessed
					, [Fulfillment]
					, [DeliveryCountry]
					, ItemNoProduct
					, [Description]
					, [CustomerID]
					, [Sourcer]
					, [ProductHierarchie1]
					, [ProductHierarchie2]
					, [ProductHierarchie3]
					, [Brand]
					, [PaymentMethod]
					, [Carrier]			
					, InvoiceCountry
					, Salesman
					, Categorymanager
					, Disponent
					, [EOL]
					, [ItemClass]
					, GTSCode
					, [MEK_WE]
					, [MEK_Hedging]
					, [MEK_Plan]
					, [IncidentFlag]
					, [OwnBrand]
					, [Matchcode]
					,DocumentFooter
					,Channel
					,[ChannelGroupI]
					,[ChannelGroupII]
					,Intercompany
					,TransactionTypeShort
					,LastModified
					,DocumentLineID
					,DocumentLineQty
					,RefundType
					,ArticleType
					,GruppenTag
					,IntrastatCode
					,Weight
					,NetPriceForeignCurrency
					,Currency
					,FirstSale
				    ,DaysSinceFirstSale
					,ChannelID
					,StorageID
					,StorageLocation
					,SalesAccount
					,GrossDocumentFooter
					,GrossDocumentFooterForeignCurrency 
					,GrossPrice 
					,GrossPriceForeignCurrency 
					,MarketplaceOrderID
					,[ItemFamily]
					,InvoiceZipCode
					,InvoiceCity
				)
SELECT 
				
					 s.[ProcessId]
					, s.[CompanyId]
					, s.[TransactionType]
					, s.[TransactionTypeDetail]
					, s.[DocumentNo]
					, s.[DocumentId]
					, s.[ReferenceDocumentId]
					, s.[TransactionDate]
					, s.[ItemNo]
					, s.DocumentItemLine
					, s.[PositionId]
					, s.[PositionIdRC]
					, s.[Quantity]
					, s.[NetPrice]
					, s.[ReferenceId]
					, s.[RC]
					,'Sage'
					,0
					, s.Fulfillment
					, s.DeliveryCountry
					, s.ItemNoProduct
					, s.Description
					, s.CustomerID
					, s.Sourcer
					, s.ProductHierarchie1
					, s.ProductHierarchie2
					, s.ProductHierarchie3
					, s.Brand
					, s.PaymentMethod
					, s.Carrier
					, s.InvoiceCountry
					, s.Salesman
					, s.Categorymanager
					,s.Disponent
					, s.[EOL]
					, s.[ItemClass]
					, s.GTSCode
					, s.[MEK_WE]
					, s.[MEK_Hedging]
					, s.[MEK_Plan]
					, s.[IncidentFlag]
					, s.[OwnBrand]
					, s.[Matchcode]
					,isnull(s.DocumentFooter,0)
					,s.Channel
					,s.[ChannelGroupI]
					,s.[ChannelGroupII]
					,s.Intercompany
					,s.TransactionTypeShort
					,getdate()
					,s.DocumentLineID
					,s.DocumentLineQty
					,s.RefundType
					,s.ArticleType
					,s.GruppenTag
					,s.IntrastatCode
					,s.Weight
					,s.NetPriceForeignCurrency
					,s.Currency
					,s.FirstSale
				    ,s.DaysSinceFirstSale
					,s.Kundengruppe
					,s.StorageID
					,s.StorageLocation
					,s.SalesAccount
					,s.GrossDocumentFooter
					,s.GrossDocumentFooterForeignCurrency 
					,s.GrossPrice 
					,s.GrossPriceForeignCurrency 
					,s.MarketplaceOrderID
					,s.ItemFamily
					,s.InvoiceZipCode
					,s.InvoiceCity
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 s
LEFT JOIN [CT dwh 02 Data].[dbo].[tFactAllSalesTransactions] v on v.[ReferenceId] = s.[ReferenceId] AND v.RC =s.RC --and v.[bIsDeleted] = 0
Where v.TransactionID is null


SET @tmsg = 'END: Insert  New Transactions ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0


/*----------------------------------------------------
Update deleted field when the positions being updated have less quantity
that records in fact table (quantity was changed to less)
-----------------------------------------------------*/

SET @tmsg = 'START: Update delete Transactions (Changed Quantity)'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

;with PosQty as (
	select distinct ReferenceId,PositionQuantity 
	FROM [CT dwh 02 Data].[dbo].[FactSales_Staging] with(nolock)
)
Update f
	set f.bisdeleted = 1, 
		f.dtDeleted = getdate(),
		f.LastModified = getdate(),
		f.IsProcessed = 0	
FROM [CT dwh 02 Data].[dbo].tFactAllSalesTransactions f
inner join PosQty p on p.ReferenceId = f.ReferenceId
	and p.PositionQuantity < f.rc

SET @tmsg = 'END: Update delete Transactions (Changed Quantity)['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0


/*----------------------------------------------------
Update Company Name
-----------------------------------------------------*/
UPDATE f
	SET CompanyName = c.CompanyName
FROM [CT dwh 02 Data].[dbo].tFactAllSalesTransactions f
inner join [CT dwh 00 Meta].[dbo].tCompanyName c on c.CompanyID = f.CompanyId
WHERE IsProcessed = 0



/*----------------------------------------------------
Fulfillment -- Get the new records from amazon table
and update fulfilment on the process id's affected even 
if they are not in the stage table -DEVTCK-18467
-----------------------------------------------------*/
if(@bUseDeltaLoad =1)
BEGIN
	SET @tmsg = 'START: Update Fulfillment tErpLBAmazonOrders-First Update' 
	EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
	SET @dtExecutionStart = getdate()

	UPDATE dm
		SET dm.Fulfillment = 
		case 
			when TransactionTypeShort in ('VSD') AND dm.GruppenTag in ('Amazon') THEN 'FBA' 
			else 'PBM'
		end,
		dm.LastModified = getdate(),
		IsProcessed = 0	
	FROM [CT dwh 02 Data].[dbo].tFactAllSalesTransactions	 dm
	INNER JOIN [CT dwh 02 Data].[dbo].[tErpLBAmazonOrders] amazon WITH (NOLOCK) 
		on amazon.KHKBelId = dm.DocumentId and amazon.KHKVorID = dm.ProcessId 
			and amazon.Mandant = dm.CompanyId and amazon.IsPrime = -1
	Where amazon.mdInsertDate >= @dtLastExecution
			and dm.Fulfillment not in ('PBM','FBA') and dm.TransactionDate >= '2021-01-01'

	SET @tmsg = 'END: Update Fulfillment tErpLBAmazonOrders - FirstUpdate['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
	EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
	SET @tmsg = 'START: Update Fulfillment tErpLBAmazonOrders-Second Update' 
	EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
	SET @dtExecutionStart = getdate()
	Update dm
		SET dm.Fulfillment = a.Fulfillment, dm.LastModified = getdate(), IsProcessed =0
	from [CT dwh 02 Data].[dbo].tFactAllSalesTransactions 	 dm
	inner join [CT dwh 02 Data].[dbo].tFactAllSalesTransactions  a with(nolock) 
			on  a.processid = dm.processid and a.companyid = dm.companyid and a.Fulfillment in ('PBM','FBA')
			and a.IsProcessed = 0
	where isnull(dm.Fulfillment,'')not in ('PBM' ,'FBA')

	SET @tmsg = 'END: Update Fulfillment tErpLBAmazonOrders-second update ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
	EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
END

IF((Select count(*) from [CT dwh 02 Data].[dbo].[tFactAllSalesTransactions] where IsProcessed = 0)= 0 )
BEGIN
		IF (@@ERROR<>0 OR @nRet<>0)
		BEGIN
			SET @nRet = 100;
			SET @tmsg = 'No rows to process '
			GOTO ExitWithError
		END	
END



	DROP TABLE #TMP_EntriesToLoad


SET @nRet = 0
END TRY

BEGIN CATCH
		SET @nret = -2
		SET @tmsg = 'Error trying to load transactions in the All sales transactions table.Number['+cast(ERROR_NUMBER() as nvarchar(10))+']'+'] Message['+ERROR_MESSAGE()+']'

		GOTO ExitWithError
END CATCH
  


ExitSproc:
	SET @tmsg = '[spLoadFactSalesAlltransactions]'
	EXEC [CT dwh 00 Meta].[dbo].usp_DebugOut @tmsg,@bIsLogOn

	RETURN @nRet

ExitWithError:
	SET @tmsg = @tmsg + 'Sproc Failed with internal error [:'+cast(@nRet AS nvarchar(10))+']'
	EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 1

	SET @tmsg = '[spLoadFactSalesAlltransactions]'
	EXEC [CT dwh 00 Meta].[dbo].usp_DebugOut @tmsg,@bIsLogOn,1
		

	RAISERROR (@tmsg,16,1)
GO
/****** Object:  StoredProcedure [dbo].[spLoadFactSalesAlltransactions_staging]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************
** Name: Loads the Data from from the sage tables in the tfactalltransactionssales
** Auth: [Michael Kother]
** Date: 20/08/2020
**************************
** Change History
**************************
** PR   Date		 Author			Description 
** --   --------	 -------		------------------------------------
** 1	14/10/2020	Hbarbosa	      Store Procedure Creation (based on spLoadFactSalesTransactionsVertical)

*******************************
**************************
** Return Values
**************************
	0  - Success
	-1 - Default
**************************
** Execution Examples
**************************
EXEC spLoadFactSalesAlltransactions --- Executes delta changes
EXEC spLoadFactSalesAlltransactions @dtStartDate = '2020-01-01', @dtEndDate = '2020-01-31',@bUseDeltaLoad =0 --- Executes process for all january transactions
EXEC spLoadFactSalesAlltransactions @bUseDeltaLoad =0 ,@nProcessID = --- Executes process for a specific processid

**/

CREATE PROCEDURE [dbo].[spLoadFactSalesAlltransactions_staging]
	@bIsLogOn bit= 0,
	@dtStartDate date = null,
	@dtEndDate date = null,
	@nProcessID as int = 0,
	@bUseDeltaLoad bit = 1   --- used to process all the transactions from the datalayer to [mdRecordToLoadFlag] = 1
AS

/***********************************************
DECLARE Variables
***********************************************/

DECLARE @nRet INT
DECLARE @tmsg AS NVARCHAR(255)

SET @nRet = -1

SET @tmsg = '[spLoadFactSalesAlltransactions]'
EXEC [CT dwh 00 Meta].dbo.usp_DebugIn @tmsg, @bIsLogOn

Declare @dtExecutionStart as datetime = getdate()

/***********************************************
SET dates
***********************************************/

IF(@dtStartDate is null and @nProcessID = 0)
BEGIN
	SET @dtStartDate = cast(getdate()-1 as date)
END
ELSE 
BEGIN
	IF (@nProcessID> 0 )
	BEGIN
		SELECT @dtStartDate = isnull(min(BelegDatum),'2016-01-01') FROM [CT dwh 02 Data].dbo.tErpKHKVKBelege with(nolock) where vorid = @nProcessID
	END
END

IF(@dtEndDate is null)
BEGIN
	SET @dtEndDate = cast(getdate() as date)
END
SET @tmsg = 'Process Dates: Start:['+isnull(cast(@dtStartDate as nvarchar), 'null')+']; End Date['+isnull(cast(@dtEndDate as nvarchar), 'null')+']'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0


BEGIN TRY

/***********************************************
Temp tables declaration
***********************************************/

	CREATE TABLE #TMP_EntriesToLoad
	(
		[VorID] [int] NOT NULL,
		[Mandant] [smallint] NOT NULL,
		[BelID] [int] NOT NULL,
		[PositionId] [int] NOT NULL,
		--ReferenceID nvarchar(150) NOT NULL
	) 


TRUNCATE TABLE [CT dwh 02 Data].[dbo].[FactSales_Staging]	


/***********************************************
Delete BelIDs with deleted positions
***********************************************/
IF(@nProcessID = 0)
BEGIN
	SET @tmsg = 'START: Mark deleted positions'
	EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

		UPDATE Fact
			SET  Fact.bIsDeleted = 1, dtDeleted = getdate(), fact.IsProcessed = 0
		FROM  [CT dwh 02 Data].[dbo].[tFactAllSalesTransactions] AS Fact 
		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegePositionen AS Pos WITH (NOLOCK)
			ON Fact.CompanyId = Pos.Mandant 
			AND Fact.DocumentLineID = Pos.BelPosID
		WHERE Pos.IsDeletedFlag = 1 and Fact.bIsDeleted =0

	SET @tmsg = 'END: Mark deleted positions['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]'
	EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
END



/***********************************************
Get entries to load
***********************************************/
SET @dtExecutionStart = getdate()
SET @tmsg = 'START: Get Entries to Load'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

---if its not a delta execution, we can retrieve the process id's affectedby the date only using the belege table (faster than using the conditions used by the delta query)
IF(@bUseDeltaLoad = 0)
BEGIN
	INSERT INTO #TMP_EntriesToLoad
			(
				VorID
				, Mandant
				,[BelID]
				,PositionId
			)
			SELECT DISTINCT
				Belege.VorID
			  , Belege.Mandant
			  ,BELEGE.belid
			, ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID) AS PositionId
			FROM [CT dwh 02 Data].dbo.tErpKHKVKBelege AS Belege WITH (NOLOCK)
			INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegePositionen AS BelegePositionen WITH(NOLOCK)
					ON Belege.Mandant = BelegePositionen.Mandant
					AND Belege.BelID = BelegePositionen.BelID
					AND BelegePositionen.IsDeletedFlag = 0
			LEFT JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegeStuecklisten AS Stuecklisten WITH(NOLOCK)
				ON BelegePositionen.Mandant = Stuecklisten.Mandant
				AND BelegePositionen.BelPosID = Stuecklisten.BelPosID
				AND Stuecklisten.ArtikelNummer not like '7%'
			WHERE 1 = 1
			AND Belege.Mandant IN (1, 2, 3)
			AND Cast(Belege.Belegdatum as date) between @dtStartDate and @dtEndDate		
			AND (@nProcessID = Belege.VorID OR @nProcessID = 0)
END
ELSE
BEGIN
	INSERT INTO #TMP_EntriesToLoad
		(
			VorID
			, Mandant
			,[BelID]
			,PositionId
		)
		SELECT DISTINCT
			Belege.VorID
			, Belege.Mandant
			,BELEGE.belid
			, ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID) AS PositionId

		FROM [CT dwh 02 Data].dbo.tErpKHKVKBelege AS Belege WITH (NOLOCK)
		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegePositionen AS BelegePositionen WITH(NOLOCK)
			ON Belege.Mandant = BelegePositionen.Mandant
			AND Belege.BelID = BelegePositionen.BelID
			AND BelegePositionen.IsDeletedFlag = 0
		LEFT JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegeStuecklisten AS Stuecklisten WITH(NOLOCK)
			ON BelegePositionen.Mandant = Stuecklisten.Mandant
			AND BelegePositionen.BelPosID = Stuecklisten.BelPosID
			AND Stuecklisten.ArtikelNummer not like '7%'

		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKArtikel AS Art WITH (NOLOCK)
			ON ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) = Art.Artikelnummer
			AND Belege.Mandant = Art.Mandant
		WHERE 1 = 1
			AND Belege.Mandant IN (1, 2, 3)
			AND (
						Belege.mdRecordToLoadFlag = 1
						OR 
						BelegePositionen.mdRecordToLoadFlag = 1
						OR 
						Stuecklisten.mdRecordToLoadFlag = 1
				)
			AND VORID>0
							
END
		

SET @tmsg = 'END: Get Entries to Load['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
	CREATE INDEX IDX_Entries_VorID_MANDANT ON #TMP_EntriesToLoad(VorID,[Mandant])

/***********************************************
Delete existent data for the process id's to be processed 
***********************************************/
--SET @dtExecutionStart = getdate()
--SET @tmsg = 'START: delete [tFactAllSalesTransactions]'
--EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

--			--DELETE d FROM [CT dwh 02 Data].[dbo].[tFactAllSalesTransactions] d
--			--INNER JOIN #TMP_EntriesToLoad t on t.vorid = d.processid and t.mandant = d.companyid
--				--and t.BelID = d.DocumentID 

--SET @tmsg = 'END: delete [tFactAllSalesTransactions]['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
--EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

--SET @dtExecutionStart = getdate()
--SET @tmsg = 'START: delete [tfactSalesTransactionsVertical]'
--EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

--			--DELETE d FROM [CT dwh 03 Intelligence].dbo.tfactSalesTransactionsVertical d
--			--INNER JOIN #TMP_EntriesToLoad t on t.vorid = d.processid and t.mandant = d.companyid
--			--and t.BelID = d.DocumentID 
--SET @tmsg = 'END: delete [tfactSalesTransactionsVertical]['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
--EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0


--SET @dtExecutionStart = getdate()
--SET @tmsg = 'START: delete [tFactSalesTransactions]'
--EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

--			DELETE d FROM [CT dwh 03 Intelligence].dbo.tFactSalesTransactions	d
--			INNER JOIN #TMP_EntriesToLoad t on t.vorid = d.processid and t.mandant = d.companyid 
--				and (t.BelID = d.OrderDocumentId or 
--				t.BelID = d.GoodwillDocumentId or
--				t.BelID = d.InvoiceDocumentId or
--				t.BelID = d.InvoiceCancellationDocumentId or
--				t.BelID = d.OrderCancellationDocumentId or
--				t.BelID = d.RefundDocumentId )
--SET @tmsg = 'END: delete [tFactSalesTransactions]['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
--EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

/***********************************************
Process Main Data
***********************************************/
---      Probably we can merge the above query selection with the below one to avoid querying the tables again
SET @tmsg = 'START: Get Data into [CT dwh 02 Data].[dbo].[FactSales_Staging]	'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

		INSERT INTO [CT dwh 02 Data].[dbo].[FactSales_Staging]	
		(           
			 [ProcessId]
			, [CompanyId]
			, [TransactionType]
			, [TransactionTypeDetail]
			, [DocumentNo]
			, [DocumentId]
			, [ReferenceDocumentId]
			, [TransactionDate]
			, [ItemNo]
			, [DocumentItemLine]
			, [PositionId]
			, [PositionIdRC]
			, [Quantity]
			, [NetPrice]
			, [ReferenceId]
			, [RC]
			, [DeliveryCountry]
			, ItemNoProduct
			, [Description]
			, [CustomerID]
			, InvoiceCountry
			, Salesman
			, [MEK_WE]
			, [MEK_Hedging]
			, [MEK_Plan]
			,[Nettobetrag]
			,[WKzKursFw]
			,[GesamtpreisInternEW]
			,[ZWInternEW]
			,PositionQuantity
			,Channel
			,[ChannelGroupI]
			,[ChannelGroupII]
			,Intercompany
			,TransactionTypeShort
			,Vertreter
			,Kundengruppe
			,DocumentLineID
			,DocumentLineQty
			,StatistikWirkungUmsatz
			,GruppenTag
			,NetPriceForeignCurrency
			,Currency
		)          

		SELECT 
			Belege.VorID AS ProcessId
			, Belege.Mandant AS CompanyId
			,CASE WHEN TranType.id is null THEN 'Other' ELSE TranType.TransactionType END  TransactionType
			, Belegarten.Bezeichnung AS TransactionTypeDetail
			, Belege.Belegnummer AS DocumentNo
			, Belege.BelID AS DocumentId
			, Belege.ReferenzBelID AS ReferenceDocumentId
			, CAST(Belege.Belegdatum AS DATE) AS TransactionDate
			,  ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) AS ItemNo
			, ISNULL(BelegePositionen.Position,1) Position
			, ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID) AS PositionId
			,CASE WHEN N.Number is null THEN ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) ELSE 1 END as Quantity-- ROW_NUMBER() OVER (PARTITION BY Belege.VorID, Belege.BelID, Belege.Mandant, ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) ORDER BY ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID)) AS PositionIdRC
			, CASE WHEN N.Number is null THEN ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) ELSE 1 END as Quantity--ISNULL(n.Number, ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)) as Quantity
			, CASE
				WHEN ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0 THEN (ISNULL(Stuecklisten.GesamtPreisInternEW, BelegePositionen.GesamtPreisInternEW) / ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge))	
					ELSE 0
			  END AS NetPrice
			,CAST(CAST(Belege.VorID AS VARCHAR(10)) + '-' +  CAST(Belege.Mandant AS VARCHAR(1)) + '-' + CAST(Belege.BelID AS VARCHAR(10)) + '-' + ISNULL(CAST(Stuecklisten.BelPosStID AS VARCHAR(10)), CAST(BelegePositionen.BelPosID AS VARCHAR(10))) AS NVARCHAR(50))
			,ISNULL(n.Number, ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)) as RC
			, Belege.A1Land		as DeliveryCountry
			, BelegePositionen.Artikelnummer  as ItemNoProduct
			,  CASE  WHEN Stuecklisten.BelPosID IS NULL THEN BelegePositionen.Bezeichnung1 ELSE Stuecklisten.Bezeichnung1 END as [Description]
			, Belege.A0Empfaenger as CustomerID
			, Belege.A0Land
			, Belege.Vertreter
			,abs(round((CASE WHEN (ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '4%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '6%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '7%') 
					and ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0  THEN 
								(isnull(isnull(Stuecklisten.gesamtpreisinternEW,BelegePositionen.gesamtpreisinternEW) ,0) - isnull(isnull(Stuecklisten.roherloes,BelegePositionen.roherloes) ,0))/ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
				ELSE isnull(isnull(ham1.[MEK_WE],ham2.[MEK_WE]) * mAufschlag.[Aufschlag] * CASE WHEN ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '9%' THEN 0 ELSE 1 END,0) 
				END),2))  AS [Wareneinsatz MEK WE nach Retouren]
			,abs(round((CASE WHEN (ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '4%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer)like '6%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '7%') and ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0  THEN (isnull(isnull(Stuecklisten.gesamtpreisinternEW,BelegePositionen.gesamtpreisinternEW),0) - isnull(isnull(Stuecklisten.roherloes,BelegePositionen.roherloes) ,0))/ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
				ELSE isnull(isnull(ham1.[MEK_Hedging],ham2.[MEK_Hedging]) * mAufschlag.[Aufschlag] * CASE WHEN ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '9%' THEN 0 ELSE 1 END,0) 
				END),2)) AS [Wareneinsatz MEK Hedging nach Retouren]
			,abs(round((CASE WHEN (ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '4%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '6%' OR ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer) like '7%') and ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0  THEN (isnull(isnull(Stuecklisten.gesamtpreisinternEW,BelegePositionen.gesamtpreisinternEW) ,0) - isnull(isnull(Stuecklisten.roherloes,BelegePositionen.roherloes) ,0))/ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
				ELSE isnull(isnull(ham1.[MEK_Plan_YoY],ham2.[MEK_Plan_YoY]) * mAufschlag.[Aufschlag] * CASE WHEN ISNULL(Stuecklisten.Artikelnummer, BelegePositionen.Artikelnummer)like '9%' THEN 0 ELSE 1 END,0) 
				END),2)) AS [Wareneinsatz MEK Plan nach Retouren]
			--, Art.Matchcode
			,Belege.[Nettobetrag]
			,Belege.[WKzKursFw]
			,isnull(Stuecklisten.[GesamtpreisInternEW], BelegePositionen.[GesamtpreisInternEW])
			,Belege.[ZWInternEW]
			,ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
			,Channel.Channel
			,Channel.ChannelGroupI
			,Channel.ChannelGroupII
			,IntCompany.[KG_Bezeichnung] as Intercompany
			,Belege.Belegkennzeichen
			,Belege.Vertreter
			,Belege.Kundengruppe
			,BelegePositionen.belposid
			,BelegePositionen.Menge
			,StatistikWirkungUmsatz
			,Gruppen.Tag
			,CASE
				WHEN ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge) != 0 THEN (ISNULL(Stuecklisten.Gesamtpreis , BelegePositionen.Gesamtpreis ) / ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge))	
					ELSE 0
			  END AS NetPriceForeign
			,belege.wkz
		From
		[CT dwh 02 Data].dbo.tErpKHKVKBelege AS Belege WITH (NOLOCK)
		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegarten AS Belegarten WITH(NOLOCK) 
			ON 	 Belegarten.Kennzeichen = Belege.Belegkennzeichen   
		INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegePositionen AS BelegePositionen WITH(NOLOCK)
			ON Belege.Mandant = BelegePositionen.Mandant
			AND Belege.BelID = BelegePositionen.BelID
			AND BelegePositionen.IsDeletedFlag = 0
		LEFT JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegeStuecklisten AS Stuecklisten WITH(NOLOCK)
			ON BelegePositionen.Mandant = Stuecklisten.Mandant
			AND BelegePositionen.BelPosID = Stuecklisten.BelPosID
			AND Stuecklisten.ArtikelNummer not like '7%'
		INNER JOIN #TMP_EntriesToLoad AS EntriesToLoad
			ON Belege.VorID = EntriesToLoad.VorID
			AND Belege.BelID = EntriesToLoad.BelID
			AND Belege.Mandant = EntriesToLoad.Mandant
			AND ISNULL(Stuecklisten.BelPosStID, BelegePositionen.BelPosID) = EntriesToLoad.PositionId
		LEFT JOIN [CT dwh 00 Meta].[dbo].[tTransactionTypesConfigSalesOrders] TranType  WITH(NOLOCK)
			ON TranType.TransactionTypeShort = Belege.Belegkennzeichen	
		LEFT JOIN  [CT dwh 00 Meta].[dbo].[Numbers] n WITH(NOLOCK)on n.Number <=  ISNULL(Stuecklisten.MengeBasis, BelegePositionen.Menge)
		LEFT JOIN [CT dwh 00 Meta].[dbo].[tChannelAndGroupConfigSales] Channel
			ON Belege.Kundengruppe = Channel.Kundengruppe
			AND Belege.Mandant = Channel.Mandant
		LEFT JOIN [CT dwh 02 Data].[dbo].[tERPKHKGruppen] AS Gruppen WITH(NOLOCK)
			ON  BELEGE.Kundengruppe = gruppen.gruppe
			AND Gruppen.typ = 11
			AND BELEGE.Mandant = Gruppen.Mandant
		LEFT JOIN [CT dwh 02 Data].[dbo].tErpChalTec_Kundennummer_Mapping IntCompany
			ON 
			 Belege.Mandant = IntCompany.Mandant
			AND BELEGE.A0Empfaenger = IntCompany.Kundennummer
		LEFT JOIN [CT dwh 02 Data].[dbo].[tDwhHistorischerArtikelMEK] AS ham1 WITH(NOLOCK)
			ON ham1.[Artikelnummer] = '10' + RIGHT(ISNULL(Stuecklisten.[Artikelnummer],BelegePositionen.[Artikelnummer]),6)
			AND ISNULL(Stuecklisten.[Artikelnummer],BelegePositionen.[Artikelnummer]) LIKE '[15]%'
			AND ham1.[Datum] = CAST(BELEGE.[Belegdatum] AS DATE)
		LEFT JOIN (
				SELECT 
					[Artikelnummer]
					,[MEK_WE]
					,[MEK_Hedging]
					,[MEK_Plan_YoY]
					,rank() over (partition by Artikelnummer order by Datum desc, [MEK_Plan_YoY] desc, Mandant asc) AS Rang
				FROM [CT dwh 02 Data].[dbo].[tDwhHistorischerArtikelMEK]
				WHERE Artikelnummer like '1%'
			) AS ham2
			ON ham2.[Artikelnummer] = '10' + RIGHT(ISNULL(Stuecklisten.[Artikelnummer],BelegePositionen.[Artikelnummer]),6)
			AND ISNULL(Stuecklisten.[Artikelnummer],BelegePositionen.[Artikelnummer]) LIKE '[15]%'
			AND ham2.Rang = 1
		LEFT JOIN (
			SELECT 1 AS [Mandant], CAST(1 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 2 AS [Mandant], CAST(1.3 AS MONEY) AS [Aufschlag]
			UNION
			SELECT 3 AS [Mandant], CAST(1.2 AS MONEY) AS [Aufschlag]
		) AS MAufschlag
			ON MAufschlag.[Mandant] = BELEGE.[Mandant]
	WHERE
		ISNULL(Stuecklisten.Artikelnummer, isnull(BelegePositionen.Artikelnummer,'')) <> ''


SET @tmsg = 'END: Get Data into [CT dwh 02 Data].[dbo].[FactSales_Staging]	['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
----Update main data table with the transaction id's from the reference table
/*----------------------------------------------------
Item Dimensions
https://jira.chal-tec.com/browse/DEVTCK-17527
-----------------------------------------------------*/

SET @tmsg = 'START: Update Item Dimensions'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET ProductHierarchie1 = art.tProductHierarchie1,
	 ProductHierarchie2 = art.tProductHierarchie2,
	  ProductHierarchie3 = art.tProductHierarchie3,
	  Sourcer = art.tSourcer,
	  Brand = art.tBrand,
	  Categorymanager = art.tCategoryManagement,
	  Weight = art.fWeight,
	  IntrastatCode = art.tIntrastatCode,
	  Matchcode = art.tMatchCode,
	  Disponent = art.tDisponent,
	  EOL = art.nEOL,
	  ItemClass = art.tItemClass,
	  GTSCode = art.tGTSCode,
	  Stuecklistentyp = art.nStuecklistentyp
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
inner join [CT dwh 03 Intelligence].dbo.tdimarticle art on art.narticlenumber = dm.ItemNo
and art.nCompanyid = dm.CompanyId


SET @tmsg = 'END: Update Item Dimensions ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
/*----------------------------------------------------
Document Footer
-----------------------------------------------------*/

SET @tmsg = 'START: Update GesamtpreisInternEW'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET dm.GesamtpreisInternEW = res.Gesamtpreis
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
INNER JOIN (
		SELECT processid, companyid,documentid,ItemNo,ItemNoProduct,DocumentLineID,SUM(GesamtpreisInternEW/PositionQuantity) Gesamtpreis
		FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm2
		Where PositionQuantity>0
		Group by processid, companyid,documentid,ItemNo,ItemNoProduct, DocumentLineID
) res
	on res.companyid = dm.companyid and res.processid = dm.processid and dm.documentid = res.documentid and dm.ItemNo = res.ItemNo and dm.ItemNoProduct = res.ItemNoProduct
	and res.DocumentLineID = dm.DocumentLineID

SET @tmsg = 'END: Update GesamtpreisInternEW['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

SET @tmsg = 'START: Update Document Footer'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET DocumentFooter = CASE WHEN ZWInternEW > 0 THEN Cast((Nettobetrag * isnull(WKzKursFw,1) - [ZWInternEW]) * (GesamtpreisInternEW/ZWInternEW) as decimal(9,4)) / PositionQuantity  ELSE 0 END
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
where PositionQuantity > 0

SET @tmsg = 'END: Update Document Footer ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
-- Add to the netprice
Update dm
	SET NetPrice = isnull(NetPrice,0)+isnull(DocumentFooter,0) 
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm


Update dm
	SET MEK_WE = 0,
		MEK_Hedging = 0,
		MEK_Plan = 0
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
Where Quantity = 0

/*----------------------------------------------------
Refund Type-- from Ticket:
https://jira.chal-tec.com/browse/DEVTCK-17678
-----------------------------------------------------*/

SET @tmsg = 'START: Update Refund Type'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET RefundType = CASE 
							WHEN StatistikWirkungUmsatz <> -1 THEN NULL
							WHEN TransactionTypeShort IN ('VFN','VFT','VSY') THEN 'Cancellation/NotInStock'
							WHEN TransactionTypeShort IN ('VFM') AND NOT 
								(left(ItemNo,1) = 9 OR (ref.[Belegkennzeichen] IN ('VSD') AND GruppenTag IN ('Amazon'))) THEN 'CustomerCancellation'
							WHEN TransactionTypeShort IN ('VFS') AND NOT left(ItemNo,1) = 9 THEN 'Correction'
							WHEN left(ItemNo,1) = 9 AND left(dm.Matchcode,6) = 'Kulanz' THEN 'Goodwill'
							WHEN left(ItemNo,2) = 91 THEN 'Goodwill'
							WHEN left(ItemNo,1) = 9 THEN 'Other 9-Item'
							WHEN GruppenTag IN ('SK') AND TransactionTypeShort IN ('VFG') AND zkd.Zahlungskond IN ('NN') THEN 'ManuallyRefundESAS'
					ELSE 'CustomerRefund'
				END
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
Left Join [CT dwh 02 Data].dbo.tErpKHKVKBelege ref
	on ref.belid = dm.ReferenceDocumentId
	and ref.mandant = dm.CompanyId
Left JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelegeZKD] zkd WITH (NOLOCK)
	on zkd.BelID = dm.DocumentId and zkd.Mandant = dm.CompanyId
Where dm.StatistikWirkungUmsatz = -1

SET @tmsg = 'END: Update Refund Type ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

/*----------------------------------------------------
Article Type-- from Ticket:
https://jira.chal-tec.com/browse/DEVTCK-17676
-----------------------------------------------------*/

SET @tmsg = 'START: Update Article Type'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET ArticleType = CASE 
						WHEN left(ItemNoProduct,1) = 1 AND Stuecklistentyp = 2 THEN 'Kitting'
						WHEN left(ItemNoProduct,1) = 1 THEN 'A-Good'
						WHEN left(ItemNoProduct,1) = 3 THEN 'UK Plug-Item'
						WHEN left(ItemNoProduct,1) = 4 THEN 'Accessories'
						WHEN left(ItemNoProduct,1) = 5 THEN 'B-Ware'
						WHEN left(ItemNoProduct,1) = 6 THEN 'Set-Item'
						WHEN left(ItemNoProduct,1) = 7 THEN 'Kitting'
						WHEN ItemNoProduct IN ('90000050') THEN 'Voucher'
						WHEN ItemNoProduct IN ('90000028','90000029','90000128') THEN 'Defect-Good'
						WHEN (left(ItemNoProduct,1) = 9 AND left(Matchcode,6) = 'Kulanz') or ItemNoProduct like '91%' THEN 'Goodwill'
						WHEN left(ItemNoProduct,1) = 9 THEN 'Other 9-Item' ELSE 'Other'
				END
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm

SET @tmsg = 'END: Update Article Type ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

/*----------------------------------------------------
Change VFM transactions to Refund when a VSD exists in the process
https://jira.chal-tec.com/browse/DEVTCK-17676
-----------------------------------------------------*/

SET @tmsg = 'START: Update VFM to Refunds'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

;with ProcessVSD as(
	select Processid,CompanyId from [CT dwh 02 Data].[dbo].[FactSales_Staging]	 where TransactionTypeShort ='VSD' and GruppenTag='Amazon' group by ProcessId,CompanyId having count(*) >0
)
Update dm
	SET TransactionType = 'Refund'
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
Inner join ProcessVSD on ProcessVSD.CompanyId = dm.CompanyId and dm.ProcessId=ProcessVSD.ProcessId
WHERE transactiontypeshort ='VFM'
	


SET @tmsg = 'END: Update VFM to Refunds ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
/*----------------------------------------------------
Change intercompany
https://jira.chal-tec.com/browse/DEVTCK-17676
-----------------------------------------------------*/

SET @tmsg = 'START: Update intercompany'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

;with ProcessVSD as(
	select Processid,CompanyId from [CT dwh 02 Data].[dbo].[FactSales_Staging]	 where TransactionTypeShort ='VSD' and GruppenTag='Amazon' group by ProcessId,CompanyId having count(*) >0
)
Update dm
	SET Intercompany = dm.GruppenTag
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
WHERE Intercompany is null and GruppenTag in ('Mandanten','Weiterberechnung')
	


SET @tmsg = 'END: Update intercompany ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

/*----------------------------------------------------
Item First Sale / Days since first sale
https://jira.chal-tec.com/browse/DEVTCK-17527
-----------------------------------------------------*/

SET @tmsg = 'START: Update First sale'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET FirstSale = isnull(dtFirstSale,dm.TransactionDate), DaysSinceFirstSale = DATEDIFF(Day,cast(isnull(art.dtFirstSale,dm.TransactionDate) as date),Cast(TransactionDate as date))
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
Left join (
		Select a.narticlenumber, min(dtFirstSale)dtFirstSale from [CT dwh 03 Intelligence].[dbo].tdimarticle a group by narticlenumber
		) art on art.narticlenumber = dm.ItemNo --and a.Mandant = b.mandant


SET @tmsg = 'END:  Update First sale ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

/*----------------------------------------------------
Fulfillment every row with BelId and Mandant have the 
same value for Frachtfuehrer
-----------------------------------------------------*/
SET @tmsg = 'START: Update Fulfillment'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

UPDATE dm
	SET dm.Fulfillment = 
	case 
		When dm.Kundengruppe in ('116') THEN 'KaLi'
		when (dm.Vertreter in ('V0004','V3001','V3002','V3003','V3004','V3005','V3006','V3007') AND dm.CompanyId in (1,3)) OR (dm.Kundengruppe in ('23','24','25','28','35','106','113','207','214','215')) OR dm.CompanyId = 2 THEN 'B2B'
		when TransactionTypeShort in ('VSD') AND dm.GruppenTag in ('Amazon') THEN 'FBA' 
		when amazon.OrderID IS NOT NULL THEN 'PBM'
		else 'KaLi'
	end
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 dm
LEFT JOIN [CT dwh 02 Data].[dbo].[tErpLBAmazonOrders] amazon WITH (NOLOCK) 
	on amazon.KHKBelId = dm.DocumentId and amazon.KHKVorID = dm.ProcessId 
		and amazon.Mandant = dm.CompanyId and amazon.IsPrime = -1



SET @tmsg = 'END: Update Fulfillment ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
/*----------------------------------------------------
Carrier -- https://jira.chal-tec.com/browse/DEVTCK-17167
every row with BelId and Mandant have the same value for Frachtfuehrer
-----------------------------------------------------*/
SET @tmsg = 'START: Update Carrier'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

UPDATE dm  
	SET dm.Carrier = Frachtfuehrer
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging] dm
INNER JOIN 
	(SELECT  DISTINCT Mandant,BelID,Frachtfuehrer FROM [CT dwh 02 Data].[dbo].tErpLBVLogVersanddaten WITH(NOLOCK) )	vlog 
	ON vlog.BelID = dm.DocumentId AND vlog.Mandant = dm.CompanyId
--WHERE 
--	dm.IsProcessed = 0


SET @tmsg = 'END: Update Carrier ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
/*----------------------------------------------------
Payment Method -- from Ticket:
https://jira.chal-tec.com/browse/DEVTCK-17167
after 2017 all datas with BelId and Mandant are distinct
-----------------------------------------------------*/
SET @tmsg = 'START: Update Payment Method'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET PaymentMethod = zkd.Zahlungskond
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging] dm
INNER JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelegeZKD] zkd WITH (NOLOCK)
	on zkd.BelID = dm.DocumentId and zkd.Mandant = dm.CompanyId
--WHERE 
--	dm.IsProcessed = 0


SET @tmsg = 'END: Update Payment Method ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0



/*----------------------------------------------------
IncidentFlag-- from Ticket:
https://jira.chal-tec.com/browse/DEVTCK-17168
-----------------------------------------------------*/

SET @tmsg = 'START: Update IncidentFlag'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

Update dm
	SET IncidentFlag = 1
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging] dm
INNER JOIN [CT dwh 00 Meta].[dbo].[tIncidentFlagConfig] inc WITH (NOLOCK)
	ON inc.[ProcessID] = dm.ProcessId
--WHERE 
--	dm.IsProcessed = 0

Update [CT dwh 02 Data].[dbo].[FactSales_Staging]
	SET IncidentFlag = 0
Where IncidentFlag is null
--AND 
--	IsProcessed = 0

SET @tmsg = 'END: Update IncidentFlag ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
/*----------------------------------------------------
OwnBrand-- from Ticket:
https://jira.chal-tec.com/browse/DEVTCK-17170
-----------------------------------------------------*/

SET @tmsg = 'START: Update OwnBrand'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

--Update [CT dwh 02 Data].[dbo].[FactSales_Staging]
--	SET OwnBrand = 0
--Where Brand Is Not Null
----AND 
----	IsProcessed = 0


Update dm
	SET OwnBrand = 1
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging] dm
INNER JOIN [CT dwh 00 Meta].[dbo].[tOwnBrandsConfig] ob WITH (NOLOCK)
	ON ob.[OwnBrand] = dm.Brand
--Where 
--	dm.IsProcessed = 0


Update [CT dwh 02 Data].[dbo].[FactSales_Staging]
	SET OwnBrand = 0
Where OwnBrand Is Null
--AND 
--	IsProcessed = 0

SET @tmsg = 'END: Update OwnBrand ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
/*----------------------------------------------------
Update Existent transactions in the allsales table
-----------------------------------------------------*/
--CREATE INDEX IDX_MAINDATA_DocumentID_MANDANT ON [CT dwh 02 Data].[dbo].[FactSales_Staging]	([ProcessID],[DocumentId],CompanyID) Include (Vertreter,TransactionTypeShort,Kundengruppe)

SET @tmsg = 'START: Update Existent Transactions'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

UPDATE fact
	SET Fact.LastModified = getdate(),
		fact.TransactionDate = temp.TransactionDate,
		fact.Quantity = temp.Quantity,
		fact.NetPrice = temp.NetPrice,
		fact.Fulfillment = temp.Fulfillment,
		fact.DeliveryCountry = temp.DeliveryCountry,
		fact.ItemNoProduct = temp.ItemNoProduct,
		fact.Description = temp.Description,
		fact.CustomerID = temp.CustomerID,
		fact.Sourcer = temp.Sourcer,
		fact.ProductHierarchie1 = temp.ProductHierarchie1,
		fact.ProductHierarchie2 = temp.ProductHierarchie2,
		fact.ProductHierarchie3 = temp.ProductHierarchie3,
		fact.Brand = temp.Brand,
		fact.PaymentMethod = temp.PaymentMethod,
		fact.Carrier = temp.Carrier
		,fact.InvoiceCountry = temp.InvoiceCountry
		,fact.Salesman =temp.Salesman
		, fact.Categorymanager = temp.Categorymanager
		, fact.Disponent = temp.Disponent
		, fact.[EOL] = temp.EOL
		, fact.[ItemClass] = temp.[ItemClass]
		, fact.GTSCode = temp. GTSCode
		, fact.IsProcessed = 0
		, fact.MEK_WE = temp.MEK_WE
		, fact.MEK_Hedging = temp.MEK_Hedging
		, fact.MEK_Plan = temp.MEK_Plan
		, fact.IncidentFlag = temp.IncidentFlag
		, fact.OwnBrand = temp.OwnBrand
		, fact.Matchcode = temp.Matchcode
		,fact.DocumentFooter = isnull(temp.DocumentFooter,0)
		,fact.TransactionType = temp.TransactionType
		,fact.Channel = temp.Channel
		,fact.ChannelGroupI = temp.ChannelGroupI
		,fact.ChannelGroupII = temp.ChannelGroupII
		,fact.Intercompany = temp.Intercompany
		,fact.TransactionTypeShort = temp.TransactionTypeShort
		,fact.DocumentLineID = temp.DocumentLineID
		,fact.DocumentLineQty = temp.DocumentLineQty
		,fact.RefundType = temp.RefundType
		,fact.ArticleType = temp.ArticleType
		,fact.GruppenTag = temp.GruppenTag
		,fact.IntrastatCode = temp.IntrastatCode
		,fact.Weight = temp.Weight
		,fact.NetPriceForeignCurrency = temp.NetPriceForeignCurrency
		,fact.Currency = temp.Currency
		,fact.FirstSale = temp.FirstSale
		,fact.DaysSinceFirstSale = temp.DaysSinceFirstSale
FROM [CT dwh 02 Data].[dbo].[tFactAllSalesTransactions] fact
INNER JOIN [CT dwh 02 Data].[dbo].[FactSales_Staging]	 temp on fact.[ReferenceId] = temp.[ReferenceId] and temp.RC = fact.RC  --and fact.[bIsDeleted] = 0


SET @tmsg = 'END: Update Existent Transactions ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0

----Insert new rows

SET @tmsg = 'START: Insert  New Transactions'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
SET @dtExecutionStart = getdate()

INSERT INTO [CT dwh 02 Data].[dbo].[tFactAllSalesTransactions]
				(
					 [ProcessId]
					, [CompanyId]
					, [TransactionType]
					, [TransactionTypeDetail]
					, [DocumentNo]
					, [DocumentId]
					, [ReferenceDocumentId]
					, [TransactionDate]
					, [ItemNo]
					, DocumentItemPosition
					, [PositionId]
					, [PositionIdRC]
					, [Quantity]
					, [NetPrice]
					, [ReferenceId]
					, [RC]
					, [Source]
					,IsProcessed
					, [Fulfillment]
					, [DeliveryCountry]
					, ItemNoProduct
					, [Description]
					, [CustomerID]
					, [Sourcer]
					, [ProductHierarchie1]
					, [ProductHierarchie2]
					, [ProductHierarchie3]
					, [Brand]
					, [PaymentMethod]
					, [Carrier]			
					, InvoiceCountry
					, Salesman
					, Categorymanager
					, Disponent
					, [EOL]
					, [ItemClass]
					, GTSCode
					, [MEK_WE]
					, [MEK_Hedging]
					, [MEK_Plan]
					, [IncidentFlag]
					, [OwnBrand]
					, [Matchcode]
					,DocumentFooter
					,Channel
					,[ChannelGroupI]
					,[ChannelGroupII]
					,Intercompany
					,TransactionTypeShort
					,LastModified
					,DocumentLineID
					,DocumentLineQty
					,RefundType
					,ArticleType
					,GruppenTag
					,IntrastatCode
					,Weight
					,NetPriceForeignCurrency
					,Currency
					,FirstSale
				    ,DaysSinceFirstSale
				)
SELECT 
				
					 s.[ProcessId]
					, s.[CompanyId]
					, s.[TransactionType]
					, s.[TransactionTypeDetail]
					, s.[DocumentNo]
					, s.[DocumentId]
					, s.[ReferenceDocumentId]
					, s.[TransactionDate]
					, s.[ItemNo]
					, s.DocumentItemLine
					, s.[PositionId]
					, s.[PositionIdRC]
					, s.[Quantity]
					, s.[NetPrice]
					, s.[ReferenceId]
					, s.[RC]
					,'Sage'
					,0
					, s.Fulfillment
					, s.DeliveryCountry
					, s.ItemNoProduct
					, s.Description
					, s.CustomerID
					, s.Sourcer
					, s.ProductHierarchie1
					, s.ProductHierarchie2
					, s.ProductHierarchie3
					, s.Brand
					, s.PaymentMethod
					, s.Carrier
					, s.InvoiceCountry
					, s.Salesman
					, s.Categorymanager
					,s.Disponent
					, s.[EOL]
					, s.[ItemClass]
					, s.GTSCode
					, s.[MEK_WE]
					, s.[MEK_Hedging]
					, s.[MEK_Plan]
					, s.[IncidentFlag]
					, s.[OwnBrand]
					, s.[Matchcode]
					,isnull(s.DocumentFooter,0)
					,s.Channel
					,s.[ChannelGroupI]
					,s.[ChannelGroupII]
					,s.Intercompany
					,s.TransactionTypeShort
					,getdate()
					,s.DocumentLineID
					,s.DocumentLineQty
					,s.RefundType
					,s.ArticleType
					,s.GruppenTag
					,s.IntrastatCode
					,s.Weight
					,s.NetPriceForeignCurrency
					,s.Currency
					,s.FirstSale
				    ,s.DaysSinceFirstSale
FROM [CT dwh 02 Data].[dbo].[FactSales_Staging]	 s
LEFT JOIN [CT dwh 02 Data].[dbo].[tFactAllSalesTransactions] v on v.[ReferenceId] = s.[ReferenceId] AND v.RC =s.RC --and v.[bIsDeleted] = 0
Where v.TransactionID is null


SET @tmsg = 'END: Insert  New Transactions ['+cast(@@ROWCOUNT as nvarchar(10)) + ' rows affected]['+Cast(DATEDIFF(ss,@dtExecutionStart,getdate()) as nvarchar(20))+' s]'
EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 0
		
IF((Select count(*) from [CT dwh 02 Data].[dbo].[tFactAllSalesTransactions] where IsProcessed = 0)= 0 )
BEGIN
		IF (@@ERROR<>0 OR @nRet<>0)
		BEGIN
			SET @nRet = 100;
			SET @tmsg = 'No rows to process '
			GOTO ExitWithError
		END	
END


/*************************************************************************************************************
Dimension Updates --- Better to do in separated updates than making all the join conditions in the main query
**************************************************************************************************************/






	DROP TABLE #TMP_EntriesToLoad


SET @nRet = 0
END TRY

BEGIN CATCH
		SET @nret = -2
		SET @tmsg = 'Error trying to load transactions in the All sales transactions table.Number['+cast(ERROR_NUMBER() as nvarchar(10))+']'+'] Message['+ERROR_MESSAGE()+']'

		GOTO ExitWithError
END CATCH
  


ExitSproc:
	SET @tmsg = '[spLoadFactSalesAlltransactions]'
	EXEC [CT dwh 00 Meta].[dbo].usp_DebugOut @tmsg,@bIsLogOn

	RETURN @nRet

ExitWithError:
	SET @tmsg = @tmsg + 'Sproc Failed with internal error [:'+cast(@nRet AS nvarchar(10))+']'
	EXEC [CT dwh 00 Meta].[dbo].usp_Debug @tmsg,@bIsLogOn, 1

	SET @tmsg = '[spLoadFactSalesAlltransactions]'
	EXEC [CT dwh 00 Meta].[dbo].usp_DebugOut @tmsg,@bIsLogOn,1
		

	RAISERROR (@tmsg,16,1)
GO
/****** Object:  StoredProcedure [dbo].[spLoadtLogParcellabCourierCodes]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		PKumari
-- Create date: 20/10/2020
-- Description:	Updated the master table [dbo].[tLogParcellab_Courier_Codes] 
--				from [dbo].[tLogParcellab_Tracking_Jobs]
-- =============================================
CREATE PROCEDURE [dbo].[spLoadtLogParcellabCourierCodes]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    DECLARE 
	@CourierID int = 0,
	@ID int = 0,
    @Courier VARCHAR(255), 
    @CourierCode   VARCHAR(255),
	@mdLogId int = 1,
	@mdInsertDate datetime,
	@mdRecordToLoadFlag smallint = 0;

	SET @CourierID = (SELECT MAX(CourierId) FROM [CT dwh 02 Data].[dbo].[tLogParcellab_Courier_Codes])
	SET @ID = (SELECT MAX(ID) FROM [CT dwh 02 Data].[dbo].[tLogParcellab_Courier_Codes])

	DECLARE cursor_courier CURSOR
	FOR SELECT distinct s.OLCarrier, sourceTab.Carrier
		FROM
			(SELECT distinct OLCarrier 
			FROM [CT dwh 02 Data].[dbo].[tLogParcellab_Tracking_Jobs] WITH (NOLOCK)
			) s
		LEFT JOIN [CT dwh 02 Data].[dbo].[tLogParcellab_Courier_Codes] masterTab WITH (NOLOCK)
		ON s.OLCarrier = masterTab.Courier
		INNER JOIN [CT dwh 02 Data].[dbo].[tLogParcellab_Tracking_Jobs] sourceTab WITH (NOLOCK)
		ON s.OLCarrier = sourceTab.OLCarrier
		WHERE masterTab.Courier is null

	OPEN cursor_courier;

	FETCH NEXT FROM cursor_courier INTO 
		@Courier, 
		@CourierCode;

	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @CourierID = @CourierID + 1;
			SET @ID = @ID + 1;
			SET @mdInsertDate = GETDATE();

			--Insert into the master table the new courier and courier code
			INSERT INTO [CT dwh 02 Data].[dbo].[tLogParcellab_Courier_Codes] 
			VALUES (@CourierID, @ID, @Courier, @CourierCode, @mdLogId, @mdInsertDate, @mdRecordToLoadFlag)

			--PRINT Convert(varchar(4),@CourierID )+' '+ Convert(varchar(4),@ID) +' '+ @Courier + ' ' + @CourierCode;
			FETCH NEXT FROM cursor_courier INTO 
				@Courier, 
				@CourierCode;
		END;

	CLOSE cursor_courier;

	DEALLOCATE cursor_courier;

	


END
GO
/****** Object:  StoredProcedure [dbo].[spLoadtSAPZ_MM_A017_KONP]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spLoadtSAPZ_MM_A017_KONP] AS BEGIN

MERGE tSAPZ_MM_A017_KONP tgt USING (
    SELECT * FROM (
        SELECT *,
            ROW_NUMBER() OVER(PARTITION BY KNUMH, KOPOS, KAPPL, KSCHL, LIFNR, MATNR, EKORG, WERKS, ESOKZ, DATBI ORDER BY (SELECT NULL)) row_filter
        FROM [CT dwh 01 Stage]..tSAP_Z_MM_A017_KONP
    )_
    WHERE row_filter = 1
) src
ON  (src.KNUMH = tgt.KNUMH OR src.KNUMH IS NULL AND tgt.KNUMH IS NULL) AND (src.KOPOS = tgt.KOPOS OR src.KOPOS IS NULL AND tgt.KOPOS IS NULL)
AND (src.KAPPL = tgt.KAPPL OR src.KAPPL IS NULL AND tgt.KAPPL IS NULL) AND (src.KSCHL = tgt.KSCHL OR src.KSCHL IS NULL AND tgt.KSCHL IS NULL)
AND (src.LIFNR = tgt.LIFNR OR src.LIFNR IS NULL AND tgt.LIFNR IS NULL) AND (src.MATNR = tgt.MATNR OR src.MATNR IS NULL AND tgt.MATNR IS NULL)
AND (src.EKORG = tgt.EKORG OR src.EKORG IS NULL AND tgt.EKORG IS NULL) AND (src.WERKS = tgt.WERKS OR src.WERKS IS NULL AND tgt.WERKS IS NULL)
AND (src.ESOKZ = tgt.ESOKZ OR src.ESOKZ IS NULL AND tgt.ESOKZ IS NULL) AND (src.DATBI = tgt.DATBI OR src.DATBI IS NULL AND tgt.DATBI IS NULL)
WHEN MATCHED AND NOT (
        (src.DATAB = tgt.DATAB OR src.DATAB IS NULL AND tgt.DATAB IS NULL)                 AND (src.CONDREC = tgt.CONDREC OR src.CONDREC IS NULL AND tgt.CONDREC IS NULL)    
    AND (src.KNUMT = tgt.KNUMT OR src.KNUMT IS NULL AND tgt.KNUMT IS NULL)                 AND (src.STFKZ = tgt.STFKZ OR src.STFKZ IS NULL AND tgt.STFKZ IS NULL)            
    AND (src.KZBZG = tgt.KZBZG OR src.KZBZG IS NULL AND tgt.KZBZG IS NULL)                 AND (src.KSTBM = tgt.KSTBM OR src.KSTBM IS NULL AND tgt.KSTBM IS NULL)            
    AND (src.KONMS = tgt.KONMS OR src.KONMS IS NULL AND tgt.KONMS IS NULL)                 AND (src.KSTBW = tgt.KSTBW OR src.KSTBW IS NULL AND tgt.KSTBW IS NULL)            
    AND (src.KONWS = tgt.KONWS OR src.KONWS IS NULL AND tgt.KONWS IS NULL)                 AND (src.KRECH = tgt.KRECH OR src.KRECH IS NULL AND tgt.KRECH IS NULL)            
    AND (src.KBETR = tgt.KBETR OR src.KBETR IS NULL AND tgt.KBETR IS NULL)                 AND (src.KONWA = tgt.KONWA OR src.KONWA IS NULL AND tgt.KONWA IS NULL)            
    AND (src.KPEIN = tgt.KPEIN OR src.KPEIN IS NULL AND tgt.KPEIN IS NULL)                 AND (src.KMEIN = tgt.KMEIN OR src.KMEIN IS NULL AND tgt.KMEIN IS NULL)            
    AND (src.PRSCH = tgt.PRSCH OR src.PRSCH IS NULL AND tgt.PRSCH IS NULL)                 AND (src.KUMZA = tgt.KUMZA OR src.KUMZA IS NULL AND tgt.KUMZA IS NULL)            
    AND (src.KUMNE = tgt.KUMNE OR src.KUMNE IS NULL AND tgt.KUMNE IS NULL)                 AND (src.MEINS = tgt.MEINS OR src.MEINS IS NULL AND tgt.MEINS IS NULL)            
    AND (src.MXWRT = tgt.MXWRT OR src.MXWRT IS NULL AND tgt.MXWRT IS NULL)                 AND (src.GKWRT = tgt.GKWRT OR src.GKWRT IS NULL AND tgt.GKWRT IS NULL)            
    AND (src.PKWRT = tgt.PKWRT OR src.PKWRT IS NULL AND tgt.PKWRT IS NULL)                 AND (src.FKWRT = tgt.FKWRT OR src.FKWRT IS NULL AND tgt.FKWRT IS NULL)            
    AND (src.RSWRT = tgt.RSWRT OR src.RSWRT IS NULL AND tgt.RSWRT IS NULL)                 AND (src.KWAEH = tgt.KWAEH OR src.KWAEH IS NULL AND tgt.KWAEH IS NULL)            
    AND (src.UKBAS = tgt.UKBAS OR src.UKBAS IS NULL AND tgt.UKBAS IS NULL)                 AND (src.KZNEP = tgt.KZNEP OR src.KZNEP IS NULL AND tgt.KZNEP IS NULL)            
    AND (src.KUNNR = tgt.KUNNR OR src.KUNNR IS NULL AND tgt.KUNNR IS NULL)                 AND (src.VENDOR = tgt.VENDOR OR src.VENDOR IS NULL AND tgt.VENDOR IS NULL)        
    AND (src.MWSK1 = tgt.MWSK1 OR src.MWSK1 IS NULL AND tgt.MWSK1 IS NULL)                 AND (src.LOEVM_KO = tgt.LOEVM_KO OR src.LOEVM_KO IS NULL AND tgt.LOEVM_KO IS NULL)
    AND (src.ZAEHK_IND = tgt.ZAEHK_IND OR src.ZAEHK_IND IS NULL AND tgt.ZAEHK_IND IS NULL) AND (src.BOMAT = tgt.BOMAT OR src.BOMAT IS NULL AND tgt.BOMAT IS NULL)            
    AND (src.KBRUE = tgt.KBRUE OR src.KBRUE IS NULL AND tgt.KBRUE IS NULL)                 AND (src.KSPAE = tgt.KSPAE OR src.KSPAE IS NULL AND tgt.KSPAE IS NULL)            
    AND (src.BOSTA = tgt.BOSTA OR src.BOSTA IS NULL AND tgt.BOSTA IS NULL)                 AND (src.KNUMA_PI = tgt.KNUMA_PI OR src.KNUMA_PI IS NULL AND tgt.KNUMA_PI IS NULL)
    AND (src.KNUMA_AG = tgt.KNUMA_AG OR src.KNUMA_AG IS NULL AND tgt.KNUMA_AG IS NULL)     AND (src.KNUMA_SQ = tgt.KNUMA_SQ OR src.KNUMA_SQ IS NULL AND tgt.KNUMA_SQ IS NULL)
    AND (src.VALTG = tgt.VALTG OR src.VALTG IS NULL AND tgt.VALTG IS NULL)                 AND (src.VALDT = tgt.VALDT OR src.VALDT IS NULL AND tgt.VALDT IS NULL)            
    AND (src.ZTERM = tgt.ZTERM OR src.ZTERM IS NULL AND tgt.ZTERM IS NULL)                 AND (src.ANZAUF = tgt.ANZAUF OR src.ANZAUF IS NULL AND tgt.ANZAUF IS NULL)        
    AND (src.MIKBAS = tgt.MIKBAS OR src.MIKBAS IS NULL AND tgt.MIKBAS IS NULL)             AND (src.MXKBAS = tgt.MXKBAS OR src.MXKBAS IS NULL AND tgt.MXKBAS IS NULL)        
    AND (src.KOMXWRT = tgt.KOMXWRT OR src.KOMXWRT IS NULL AND tgt.KOMXWRT IS NULL)         AND (src.KLF_STG = tgt.KLF_STG OR src.KLF_STG IS NULL AND tgt.KLF_STG IS NULL)    
    AND (src.KLF_KAL = tgt.KLF_KAL OR src.KLF_KAL IS NULL AND tgt.KLF_KAL IS NULL)         AND (src.VKKAL = tgt.VKKAL OR src.VKKAL IS NULL AND tgt.VKKAL IS NULL)            
    AND (src.AKTNR = tgt.AKTNR OR src.AKTNR IS NULL AND tgt.AKTNR IS NULL)                 AND (src.KNUMA_BO = tgt.KNUMA_BO OR src.KNUMA_BO IS NULL AND tgt.KNUMA_BO IS NULL)
    AND (src.MWSK2 = tgt.MWSK2 OR src.MWSK2 IS NULL AND tgt.MWSK2 IS NULL)                 AND (src.VERTT = tgt.VERTT OR src.VERTT IS NULL AND tgt.VERTT IS NULL)            
    AND (src.VERTN = tgt.VERTN OR src.VERTN IS NULL AND tgt.VERTN IS NULL)                 AND (src.VBEWA = tgt.VBEWA OR src.VBEWA IS NULL AND tgt.VBEWA IS NULL)            
    AND (src.MDFLG = tgt.MDFLG OR src.MDFLG IS NULL AND tgt.MDFLG IS NULL)                 AND (src.KFRST = tgt.KFRST OR src.KFRST IS NULL AND tgt.KFRST IS NULL)            
    AND (src.UASTA = tgt.UASTA OR src.UASTA IS NULL AND tgt.UASTA IS NULL)                 AND (src.INFNR = tgt.INFNR OR src.INFNR IS NULL AND tgt.INFNR IS NULL)            
)
THEN UPDATE SET
    tgt.DATAB = src.DATAB      , tgt.CONDREC = src.CONDREC  , tgt.KNUMT = src.KNUMT        , tgt.STFKZ = src.STFKZ      ,
    tgt.KZBZG = src.KZBZG      , tgt.KSTBM = src.KSTBM      , tgt.KONMS = src.KONMS        , tgt.KSTBW = src.KSTBW      ,
    tgt.KONWS = src.KONWS      , tgt.KRECH = src.KRECH      , tgt.KBETR = src.KBETR        , tgt.KONWA = src.KONWA      ,
    tgt.KPEIN = src.KPEIN      , tgt.KMEIN = src.KMEIN      , tgt.PRSCH = src.PRSCH        , tgt.KUMZA = src.KUMZA      ,
    tgt.KUMNE = src.KUMNE      , tgt.MEINS = src.MEINS      , tgt.MXWRT = src.MXWRT        , tgt.GKWRT = src.GKWRT      ,
    tgt.PKWRT = src.PKWRT      , tgt.FKWRT = src.FKWRT      , tgt.RSWRT = src.RSWRT        , tgt.KWAEH = src.KWAEH      ,
    tgt.UKBAS = src.UKBAS      , tgt.KZNEP = src.KZNEP      , tgt.KUNNR = src.KUNNR        , tgt.VENDOR = src.VENDOR    ,
    tgt.MWSK1 = src.MWSK1      , tgt.LOEVM_KO = src.LOEVM_KO, tgt.ZAEHK_IND = src.ZAEHK_IND, tgt.BOMAT = src.BOMAT      ,
    tgt.KBRUE = src.KBRUE      , tgt.KSPAE = src.KSPAE      , tgt.BOSTA = src.BOSTA        , tgt.KNUMA_PI = src.KNUMA_PI,
    tgt.KNUMA_AG = src.KNUMA_AG, tgt.KNUMA_SQ = src.KNUMA_SQ, tgt.VALTG = src.VALTG        , tgt.VALDT = src.VALDT      ,
    tgt.ZTERM = src.ZTERM      , tgt.ANZAUF = src.ANZAUF    , tgt.MIKBAS = src.MIKBAS      , tgt.MXKBAS = src.MXKBAS    ,
    tgt.KOMXWRT = src.KOMXWRT  , tgt.KLF_STG = src.KLF_STG  , tgt.KLF_KAL = src.KLF_KAL    , tgt.VKKAL = src.VKKAL      ,
    tgt.AKTNR = src.AKTNR      , tgt.KNUMA_BO = src.KNUMA_BO, tgt.MWSK2 = src.MWSK2        , tgt.VERTT = src.VERTT      ,
    tgt.VERTN = src.VERTN      , tgt.VBEWA = src.VBEWA      , tgt.MDFLG = src.MDFLG        , tgt.KFRST = src.KFRST      ,
    tgt.UASTA = src.UASTA      , tgt.INFNR = src.INFNR      , tgt.LastUpdate = GETDATE()   , tgt.is_deleted = 0         
WHEN NOT MATCHED BY TARGET THEN
INSERT (
    KNUMH    , KOPOS, KAPPL, KSCHL   , LIFNR     , MATNR   , EKORG   , WERKS   ,
    ESOKZ    , DATBI, DATAB, CONDREC , KNUMT     , STFKZ   , KZBZG   , KSTBM   ,
    KONMS    , KSTBW, KONWS, KRECH   , KBETR     , KONWA   , KPEIN   , KMEIN   ,
    PRSCH    , KUMZA, KUMNE, MEINS   , MXWRT     , GKWRT   , PKWRT   , FKWRT   ,
    RSWRT    , KWAEH, UKBAS, KZNEP   , KUNNR     , VENDOR  , MWSK1   , LOEVM_KO,
    ZAEHK_IND, BOMAT, KBRUE, KSPAE   , BOSTA     , KNUMA_PI, KNUMA_AG, KNUMA_SQ,
    VALTG    , VALDT, ZTERM, ANZAUF  , MIKBAS    , MXKBAS  , KOMXWRT , KLF_STG ,
    KLF_KAL  , VKKAL, AKTNR, KNUMA_BO, MWSK2     , VERTT   , VERTN   , VBEWA   ,
    MDFLG    , KFRST, UASTA, INFNR   , LastUpdate
)
VALUES (
    KNUMH    , KOPOS, KAPPL, KSCHL   , LIFNR    , MATNR   , EKORG   , WERKS   ,
    ESOKZ    , DATBI, DATAB, CONDREC , KNUMT    , STFKZ   , KZBZG   , KSTBM   ,
    KONMS    , KSTBW, KONWS, KRECH   , KBETR    , KONWA   , KPEIN   , KMEIN   ,
    PRSCH    , KUMZA, KUMNE, MEINS   , MXWRT    , GKWRT   , PKWRT   , FKWRT   ,
    RSWRT    , KWAEH, UKBAS, KZNEP   , KUNNR    , VENDOR  , MWSK1   , LOEVM_KO,
    ZAEHK_IND, BOMAT, KBRUE, KSPAE   , BOSTA    , KNUMA_PI, KNUMA_AG, KNUMA_SQ,
    VALTG    , VALDT, ZTERM, ANZAUF  , MIKBAS   , MXKBAS  , KOMXWRT , KLF_STG ,
    KLF_KAL  , VKKAL, AKTNR, KNUMA_BO, MWSK2    , VERTT   , VERTN   , VBEWA   ,
    MDFLG    , KFRST, UASTA, INFNR   , GETDATE()
)
WHEN NOT MATCHED BY SOURCE AND is_deleted = 0 THEN UPDATE SET
    is_deleted = 1, LastUpdate = GETDATE();

END
GO
/****** Object:  StoredProcedure [dbo].[spMktReportDailyRevenueDetailed]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Patrick Hein
-- Create date: 09.10.2017
-- Description:	Function to get the Daily Revenue Report for Marketing / Detailed and for whole month
-- =============================================
CREATE PROCEDURE [dbo].[spMktReportDailyRevenueDetailed] -- Chaltec_Reports_Marketing_Daily_Revenue_Report_Detailed
	@startDate DATE = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

WITH Date_Range AS (
  SELECT IIF(@startDate IS NULL, CASE 
			WHEN CAST(GETDATE() AS DATE) = CAST('01.' + CAST(MONTH(GETDATE()) AS VARCHAR(2)) + '.' + CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE)
			THEN CAST('01.' + CAST(MONTH(DATEADD(MONTH, -1, GETDATE())) AS VARCHAR(2)) + '.' + CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE) -- wenn 1. des Monats, dann einen Monat zurück
			ELSE CAST('01.' + CAST(MONTH(GETDATE()) AS VARCHAR(2)) + '.' + CAST(YEAR(GETDATE()) AS VARCHAR(4)) AS DATE)
		 END, @startDate) AS StartDate
  UNION ALL
  SELECT 
	DATEADD(DD, 1, StartDate)
  FROM 
	Date_Range
  WHERE 
	DATEADD(DD, 1, StartDate) <= CAST(GETDATE() -1 AS DATE))

SELECT 
	StartDate
INTO #TMP
FROM 
	Date_Range

SELECT * from #TMP

END

GO
/****** Object:  StoredProcedure [dbo].[spPriceRankingListBuilding]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spPriceRankingListBuilding] 
@dt date
AS

declare @Temptable table (dt date, itemid int, rnk int, place varchar(20)) 


declare @rlid int = 1, @maxrlid int;


select @maxrlid = MAX(rlid) from vErpPriceRankList

while (@rlid <= @maxrlid)
begin 

;
with RankTable as
(
select Itemid, place, price, ROW_NUMBER() over(partition by ItemId,CompanyId order by price desc, wg ) as rank 
from 
( 
select 'Shop' as place, 3 as wg, ItemId, CompanyId, PriselistId, price 
from tSCDShopPrices where @dt between StartDate and ISNULL(EndDate, cast (DATEADD(yy, DATEDIFF(yy, -1, getdate()), 0) as date))
and PriselistId = (select ShopId from vErpPriceRankList where rlID = @rlid )
union 
select 'Amazon' as place, 2 as wg, ItemId, CompanyId, MarketPlaceId, price 
from tSCDAmazonPrices where @dt between StartDate and ISNULL(EndDate, cast (DATEADD(yy, DATEDIFF(yy, -1, getdate()), 0) as date))
and MarketPlaceId = (select AmazonId from vErpPriceRankList where rlID = @rlid )
union all
select 
'EBay' as place, 1 as wg, ItemId, CompanyId, eBaySiteId, price 
from tSCDEBayPrices where @dt between StartDate and ISNULL(EndDate, cast (DATEADD(yy, DATEDIFF(yy, -1, getdate()), 0) as date))
and eBaySiteId = (select EbayId from vErpPriceRankList where rlID = @rlid )
)q 
)
, 
RankAmount as 
(
select Itemid from RankTable where rank = 2 
), 
ShopList as 
(
select ItemId from RankTable where place = 'Shop'
)
insert into @Temptable (dt, itemid, rnk, place)
select @dt, ItemId, rank, place from RankTable rt 
where ItemId in (select itemid from RankAmount)
and ItemId in (select ItemId from ShopList)


delete tErpPriceRankList
from tErpPriceRankList pl 
join @Temptable t on t.dt = pl.dt and t.itemid = pl.itemid and pl.[RankListId] = @rlid



insert tErpPriceRankList ([dt], [RankListId], [ItemId], [Rank])
select dt, @rlid, itemid, rnk from @Temptable
where place = 'Shop'

set @rlid = @rlid +1

delete @Temptable

end 


GO
/****** Object:  StoredProcedure [dbo].[spSCDAmazonPrices]    Script Date: 17/10/2024 10:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spSCDAmazonPrices] 
AS


declare @table table (id int identity(1,1), commnadtext nvarchar(max))

insert into @table(commnadtext)
select 
'INSERT tSCDAmazonPrices (ItemId, CompanyId, MarketPlaceID, Price, StartDate, EndDate, mdLogId, mdInsertDate) VALUES (' + 
CAST(s.itemid as varchar(50)) + ',' + CAST(s.mandant as varchar(50)) + ',' + CAST(s.Marketplaceid as varchar(50)) + ',' + 
CAST(s.Einzelpreis as varchar(50)) + ', CAST(getdate() as date), NULL, 0, getdate())'
from 
[dbo].[vErpAmazonPrices] s
full join tSCDAmazonPrices d on d.itemid = s.itemid and d.companyid = s.mandant and d.Marketplaceid = s.Marketplaceid
where 
d.itemid is null and d.Enddate is null
union 
select 
'UPDATE tSCDAmazonPrices SET EndDate = cast(dateadd(dd,-1,getdate()) as date), mdInsertDate = getdate() where Itemid = ' + CAST(d.itemid as varchar(50)) 
+ ' AND CompanyId = '+ CAST(d.companyid as varchar(50)) + ' AND MarketPlaceID = '+ CAST(d.Marketplaceid as varchar(50)) + ' and EndDate is null'
from 
[dbo].[vErpAmazonPrices] s
full join tSCDAmazonPrices d on d.itemid = s.itemid and d.companyid = s.mandant and d.Marketplaceid = s.Marketplaceid
where 
s.itemid is null and d.Enddate is null
union
select 
'UPDATE tSCDAmazonPrices SET EndDate = cast(dateadd(dd,-1,getdate()) as date), mdInsertDate = getdate() where Itemid = ' + CAST(d.itemid as varchar(50)) 
+ ' AND CompanyId = '+ CAST(d.companyid as varchar(50)) + ' AND MarketPlaceID = '+ CAST(d.Marketplaceid as varchar(50)) + ' and EndDate is null;' + 
'INSERT tSCDAmazonPrices (ItemId, CompanyId, MarketPlaceID, Price, StartDate, EndDate, mdLogId, mdInsertDate) VALUES (' + 
CAST(s.itemid as varchar(50)) + ',' + CAST(s.mandant as varchar(50)) + ',' + CAST(s.Marketplaceid as varchar(50)) + ',' + 
CAST(s.Einzelpreis as varchar(50)) + ', CAST(getdate() as date), NULL, 0, getdate())'
from 
[dbo].[vErpAmazonPrices] s
full join tSCDAmazonPrices d on d.itemid = s.itemid and d.companyid = s.mandant and d.Marketplaceid = s.Marketplaceid
where 
d.itemid is not null and s.itemid is not null and d.Price <> s.Einzelpreis and d.Enddate is null



declare @i int, @command nvarchar(max) 
select @i = MAX(id) from @table

while @i > 0 
begin 
 select @command = commnadtext from @table where id = @i
 --print  cast (@i as varchar(10)) + '         ' +@command
 EXECUTE sp_executesql @command
 set @i = @i-1

end 


GO
/****** Object:  StoredProcedure [dbo].[spSCDEbayPrices]    Script Date: 17/10/2024 10:58:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spSCDEbayPrices] 
AS


declare @table table (id int identity(1,1), commnadtext nvarchar(max))

insert into @table(commnadtext)
select 
'INSERT tSCDEBayPrices (ItemId, CompanyId, EBaySiteId, Price, StartDate, EndDate, mdLogId, mdInsertDate) VALUES (' + 
CAST(s.itemid as varchar(50)) + ',' + CAST(s.mandant as varchar(50)) + ',' + CAST(s.EBaySiteId as varchar(50)) + ',' + 
CAST(s.Einzelpreis as varchar(50)) + ', CAST(getdate() as date), NULL, 0, getdate())'
from 
[dbo].[vErpEbayPrices] s
full join tSCDEBayPrices d on d.itemid = s.itemid and d.companyid = s.mandant and d.EBaySiteId = s.EBaySiteId
where 
d.itemid is null and d.Enddate is null
union 
select 
'UPDATE tSCDEBayPrices SET EndDate = cast(dateadd(dd,-1,getdate()) as date), mdInsertDate = getdate() where Itemid = ' + CAST(d.itemid as varchar(50)) 
+ ' AND CompanyId = '+ CAST(d.companyid as varchar(50)) + ' AND EBaySiteId = '+ CAST(d.EBaySiteId as varchar(50)) + ' and EndDate is null'
from 
[dbo].[vErpEbayPrices] s
full join tSCDEBayPrices d on d.itemid = s.itemid and d.companyid = s.mandant and d.EBaySiteId = s.EBaySiteId
where 
s.itemid is null and d.Enddate is null
union
select 
'UPDATE tSCDEBayPrices SET EndDate = cast(dateadd(dd,-1,getdate()) as date), mdInsertDate = getdate() where Itemid = ' + CAST(d.itemid as varchar(50)) 
+ ' AND CompanyId = '+ CAST(d.companyid as varchar(50)) + ' AND EBaySiteId = '+ CAST(d.EBaySiteId as varchar(50)) + ' and EndDate is null;' + 
'INSERT tSCDEBayPrices (ItemId, CompanyId, EBaySiteId, Price, StartDate, EndDate, mdLogId, mdInsertDate) VALUES (' + 
CAST(s.itemid as varchar(50)) + ',' + CAST(s.mandant as varchar(50)) + ',' + CAST(s.EBaySiteId as varchar(50)) + ',' + 
CAST(s.Einzelpreis as varchar(50)) + ', CAST(getdate() as date), NULL, 0, getdate())'
from 
[dbo].[vErpEbayPrices] s
full join tSCDEBayPrices d on d.itemid = s.itemid and d.companyid = s.mandant and d.EBaySiteId = s.EBaySiteId
where 
d.itemid is not null and s.itemid is not null and d.Price <> s.Einzelpreis and d.Enddate is null



declare @i int, @command nvarchar(max) 
select @i = MAX(id) from @table

while @i > 0 
begin 
 select @command = commnadtext from @table where id = @i
 --print  cast (@i as varchar(10)) + '         ' +@command
 EXECUTE sp_executesql @command
 set @i = @i-1

end 


GO
/****** Object:  StoredProcedure [dbo].[spScdKHKArtikel]    Script Date: 17/10/2024 10:58:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spScdKHKArtikel] 
AS


delete [tScdKHKArtikel]
from [tScdKHKArtikel] a 
join [CT dwh 02 Data].dbo.tErpKHKArtikel a2 on a.Artikelnummer = a2.Artikelnummer and a.Mandant = a2.Mandant and a.[column_name] = 'USER_garantie' and convert(date, a.ChangeDate) = convert(date, getdate())
join [CT dwh 01 Stage].dbo.tErp_KHKArtikel a1 on a1.Artikelnummer = a2.Artikelnummer and a1.mandant = a2.Mandant
where a1.USER_garantie <> a2.USER_garantie


insert [tScdKHKArtikel] 
([Artikelnummer],[Mandant],	[ChangeDate],[column_name],	[column_value],	[ItemId],[mdLogId],	[mdInsertDate])
select a2.Artikelnummer, a2.Mandant, cast (convert(varchar(10), getdate(), 112) as datetime), 'USER_garantie', convert(varchar(500), a2.USER_garantie), a2.itemid, 0, getdate() 
from [CT dwh 02 Data].dbo.tErpKHKArtikel a2
join [CT dwh 01 Stage].dbo.tErp_KHKArtikel a1 on a1.Artikelnummer = a2.Artikelnummer and a1.mandant = a2.Mandant
where a1.USER_garantie <> a2.USER_garantie


delete [tScdKHKArtikel]
from [tScdKHKArtikel] a 
join [CT dwh 02 Data].dbo.tErpKHKArtikel a2 on a.Artikelnummer = a2.Artikelnummer and a.Mandant = a2.Mandant and a.[column_name] = 'USER_Ruecklieferung' and convert(date, a.ChangeDate) = convert(date, getdate())
join [CT dwh 01 Stage].dbo.tErp_KHKArtikel a1 on a1.Artikelnummer = a2.Artikelnummer and a1.mandant = a2.Mandant
where a1.USER_Ruecklieferung <> a2.USER_Ruecklieferung



insert [tScdKHKArtikel] 
([Artikelnummer],[Mandant],	[ChangeDate],[column_name],	[column_value],	[ItemId],[mdLogId],	[mdInsertDate])
select a2.Artikelnummer, a2.Mandant, cast (convert(varchar(10), getdate(), 112) as datetime), 'USER_Ruecklieferung'
, convert(varchar(500), a2.USER_Ruecklieferung), a2.itemid, 0, getdate() 
from [CT dwh 02 Data].dbo.tErpKHKArtikel a2
join [CT dwh 01 Stage].dbo.tErp_KHKArtikel a1 on a1.Artikelnummer = a2.Artikelnummer and a1.mandant = a2.Mandant
where a1.USER_Ruecklieferung <> a2.USER_Ruecklieferung


delete [tScdKHKArtikel]
from [tScdKHKArtikel] a 
join [CT dwh 02 Data].dbo.tErpKHKArtikel a2 on a.Artikelnummer = a2.Artikelnummer and a.Mandant = a2.Mandant and a.[column_name] = 'USER_RTLager' and convert(date, a.ChangeDate) = convert(date, getdate())
join [CT dwh 01 Stage].dbo.tErp_KHKArtikel a1 on a1.Artikelnummer = a2.Artikelnummer and a1.mandant = a2.Mandant
where a1.USER_Ruecklieferung <> a2.USER_Ruecklieferung


insert [tScdKHKArtikel] 
([Artikelnummer],[Mandant],	[ChangeDate],[column_name],	[column_value],	[ItemId],[mdLogId],	[mdInsertDate])
select a2.Artikelnummer, a2.Mandant, cast (convert(varchar(10), getdate(), 112) as datetime), 'USER_RTLager'
, convert(varchar(500), a2.USER_RTLager), a2.itemid, 0, getdate() 
from [CT dwh 02 Data].dbo.tErpKHKArtikel a2
join [CT dwh 01 Stage].dbo.tErp_KHKArtikel a1 on a1.Artikelnummer = a2.Artikelnummer and a1.mandant = a2.Mandant
where a1.USER_RTLager <> a2.USER_RTLager


GO
/****** Object:  StoredProcedure [dbo].[spSCDShopPrices]    Script Date: 17/10/2024 10:58:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spSCDShopPrices] 
AS


declare @table table (id int identity(1,1), commnadtext nvarchar(max))

insert into @table(commnadtext)
select 
'INSERT tSCDShopPrices (ItemId, CompanyId, PriseListID, Price, StartDate, EndDate, mdLogId, mdInsertDate) VALUES (' + 
CAST(s.itemid as varchar(50)) + ',' + CAST(s.mandant as varchar(50)) + ',' + CAST(s.PriseListID as varchar(50)) + ',' + 
CAST(s.Price as varchar(50)) + ', CAST(getdate() as date), NULL, 0, getdate())'
from 
[dbo].[vErpShopPrices] s
full join tSCDShopPrices d on d.itemid = s.itemid and d.companyid = s.mandant and d.PriseListID = s.PriseListID
where 
d.itemid is null and d.Enddate is null

union 
select 
'UPDATE tSCDShopPrices SET EndDate = cast(dateadd(dd,-1,getdate()) as date), mdInsertDate = getdate() where Itemid = ' + CAST(d.itemid as varchar(50)) 
+ ' AND CompanyId = '+ CAST(d.companyid as varchar(50)) + ' AND PriseListID = '+ CAST(d.PriseListID as varchar(50)) + ' and EndDate is null'
from 
[dbo].[vErpShopPrices] s
full join tSCDShopPrices d on d.itemid = s.itemid and d.companyid = s.mandant and d.PriseListID = s.PriseListID
where 
s.itemid is null and d.Enddate is null
union
select 
'UPDATE tSCDShopPrices SET EndDate = cast(dateadd(dd,-1,getdate()) as date), mdInsertDate = getdate() where Itemid = ' + CAST(d.itemid as varchar(50)) 
+ ' AND CompanyId = '+ CAST(d.companyid as varchar(50)) + ' AND PriseListID = '+ CAST(d.PriseListID as varchar(50)) + 'and EndDate is null;' + 
'INSERT tSCDShopPrices (ItemId, CompanyId, PriseListID, Price, StartDate, EndDate, mdLogId, mdInsertDate) VALUES (' + 
CAST(s.itemid as varchar(50)) + ',' + CAST(s.mandant as varchar(50)) + ',' + CAST(s.PriseListID as varchar(50)) + ',' + 
CAST(s.Price as varchar(50)) + ', CAST(getdate() as date), NULL, 0, getdate())'
from 
[dbo].[vErpShopPrices] s
full join tSCDShopPrices d on d.itemid = s.itemid and d.companyid = s.mandant and d.PriseListID = s.PriseListID
where 
d.itemid is not null and s.itemid is not null and d.Price <> s.Price and d.Enddate is null


declare @i int, @command nvarchar(max) 
select @i = MAX(id) from @table

while @i > 0 
begin 
 select @command = commnadtext from @table where id = @i
 --print  cast (@i as varchar(10)) + '         ' +@command
 EXECUTE sp_executesql @command
 set @i = @i-1

end 


GO
/****** Object:  StoredProcedure [dbo].[spWMSLagerklassifizierung]    Script Date: 17/10/2024 10:58:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Michael Kother
-- Create date: 25.09.2018
-- Description:	Gibt die Lagerklassifizierung zurück, an Hand der Konfiguration in [CT dwh 00 Meta].[dbo].[tWMSKonfigurationABCKlassifizierung]
-- =============================================
CREATE PROCEDURE [dbo].[spWMSLagerklassifizierung]
	-- Add the parameters for the stored procedure here
	@SzenarioId INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

IF @SzenarioId IS NULL
	BEGIN
		SET @SzenarioId = 1
	END


DECLARE @Reichweite INT --= 10
DECLARE @MaxAnzahlPaletten INT --= 1000
DECLARE @MaxGewicht FLOAT-- = 31.5
DECLARE @MaxAbmessung INT --= 120
DECLARE @MultiSchwelle INT --= 30
DECLARE @APlusSchwelle FLOAT --= 0.15
DECLARE @ASchwelle FLOAT --= 0.045
DECLARE @BSchwelle FLOAT --= 0.025
DECLARE @KWsVorwaerts INT --= 4  

DECLARE @StartDate DATE = GETDATE()
DECLARE @PrevMonday DATE = DATEADD(DD,-(DATEPART(DW, @StartDate) - 1), @StartDate) -- Start Kalenderwoche (Montag)
DECLARE @LastSunday DATE --= DATEADD(DD,-(DATEPART(DW, @StartDate) - 7), @StartDate) -- Ende Kalenderwoche (Sonntag)
DECLARE @StartOfWeek TINYINT = 1
DECLARE @AnzahlTage INT --= DATEDIFF(DAY, @PrevMonday, @LastSunday) + 1;
DECLARE @KW INT

-- Konfiguration an Hand des Szenarios

SELECT 
	 @Reichweite = [Reichweite] 
	, @MaxGewicht = [MaxGewichtSpedition]
	, @MaxAbmessung = [MaxAbmessungNichtRegal]
	, @MaxAnzahlPaletten = [MaxAnzahlPalettenBlock]
	, @MultiSchwelle = [MultiSchwelle]
	, @APlusSchwelle = [APlusSchwelle]
	, @ASchwelle = [ASchwelle]
	, @BSchwelle = [BSchwelle]
	, @KWsVorwaerts = [ZeitraumInKWs]
FROM [CT dwh 00 Meta].[dbo].[tWMSKonfigurationABCKlassifizierung] AS Conf WITH (NOLOCK)
WHERE 1 = 1 
	AND SzenarioId = @SzenarioId;


WITH Date_Range 
AS (
		SELECT DISTINCT
			@PrevMonday AS StartDate
		UNION ALL
		SELECT 
			CAST(DATEADD(DAY, 7, StartDate) AS DATE)
		FROM Date_Range
		WHERE 
			CAST(DATEADD(DAY, 7, StartDate) AS DATE) <=  CAST(DATEADD(WEEK, @KWsVorwaerts, @PrevMonday) AS DATE)
	)

SELECT 
	StartDate
	, DATEADD(DD,-(DATEPART(DW, StartDate) - 7), StartDate) AS EndDate
INTO #TMP_Dates 
FROM Date_Range


DECLARE @cursor CURSOR
	SET @cursor = CURSOR FAST_FORWARD
	FOR
		SELECT 
			StartDate
			, EndDate
			, (DATEDIFF(DAY, StartDate, EndDate) + 1) AS CountOfDays
			, DATEPART(WEEK, StartDate) AS WeekNo
		FROM
			#TMP_Dates AS TMP

	OPEN @cursor
	FETCH NEXT FROM @cursor
	INTO @PrevMonday, @LastSunday, @AnzahlTage, @KW
	WHILE @@FETCH_STATUS = 0
	BEGIN


SELECT 
	@PrevMonday AS StartKW
	, @LastSunday AS EndeKW	


	
-- Kalenderwochen aufsplitten

DECLARE @Dates TABLE  
(
	[Date] DATE
	, WeekNumber AS DATEPART(WEEK, [Date])
)

SET DATEFIRST @StartOfWeek

WHILE @PrevMonday <= @LastSunday

BEGIN

  INSERT INTO @Dates ([Date]) 
  SELECT @PrevMonday

  SET @PrevMonday = DATEADD(DD,1,@PrevMonday);

END


SELECT
	WeekNumber
	, [Month]
	, [Year]
	, DATEDIFF(DAY, [Start], [End]) + 1 AS [Days]
	, DAY(EOMONTH([Start])) AS DaysofMonth
INTO #TMP_DaySplit
FROM
(
 
SELECT
	WeekNumber
	, MIN([Date]) AS [Start]
	, MONTH(MIN([Date])) AS [Month]
	, YEAR(MIN([Date])) AS [Year]
	, MAX([Date]) AS [End]
	, DATENAME(WEEKDAY,MIN([Date])) AS StartDay
	, DATENAME(WEEKDAY,MAX([Date])) AS EndDay
FROM @Dates AS Dates
GROUP BY 
	WeekNumber, MONTH([Date])
) AS TMP_Dates

DELETE FROM @Dates

SELECT
	WeekNumber AS KW
	, [Month] AS Monat
	, [Year] AS Jahr
	, [Days] AS TagePerKWMonat
	, DaysofMonth AS AnzahlTageMonat
FROM #TMP_DaySplit



----------------------------------------------------------------------------------------------------------------

-- Ausgabe

SELECT
	@KW AS KW
	, TMP.Artikelnummer
	, TMP.Nichtregal
	, TMP.Kitting
	, CASE 
		WHEN TMP_Multi.Artikelnummer IS NOT NULL THEN 1
			ELSE 0 
	  END AS Multi  
	, TMP.Spedition
	, TMP.Sperrgut
	, TMP.Volumen
	, TMP.Laenge
	, TMP.Hoehe
	, TMP.Breite
	, TMP.Gewicht
	, TMP.IstPalettenbelegung
	, TMP.FC
	, ROUND(((CAST(TMP.FCPerReichweite AS FLOAT) * 100) / CAST(TMP.FCMonatKomplett AS FLOAT)), 4) AS FCErfuellungProzent
	, CASE 
		WHEN TMP.Nichtregal = 1
			THEN 'NichtRegal'
		WHEN TMP.Kitting = 1
			THEN 'Kitting'
		WHEN TMP_Multi.Artikelnummer IS NOT NULL
			THEN 'Multi'
		WHEN TMP.Spedition = 1
			THEN 'Spedition'
		WHEN TMP.Sperrgut = 1
			THEN 'Sperrgut'
		WHEN SUM(CASE 
					WHEN TMP.Nichtregal = 0
						AND TMP.Kitting = 0
						AND TMP_Multi.Artikelnummer IS NULL
						AND TMP.Spedition = 0
						AND TMP.Sperrgut = 0
						THEN TMP.Palettenanzahl
							ELSE 0
					END) OVER (
				ORDER BY CASE 
						WHEN TMP.Nichtregal = 0
							AND TMP.Kitting = 0
							AND TMP_Multi.Artikelnummer IS NULL
							AND TMP.Spedition = 0
							AND TMP.Sperrgut = 0
							THEN TMP.Palettenanzahl
								ELSE 0
						END DESC ROWS UNBOUNDED PRECEDING
				) <= @MaxAnzahlPaletten
			THEN 'Block'
		WHEN ROUND(((CAST(TMP.FCPerReichweite AS FLOAT) * 100) / CAST(TMP.FCMonatKomplett AS FLOAT)), 4) > @APlusSchwelle
			THEN 'A+'
		WHEN ROUND(((CAST(TMP.FCPerReichweite AS FLOAT) * 100) / CAST(TMP.FCMonatKomplett AS FLOAT)), 4) < @APlusSchwelle
			AND ROUND(((CAST(TMP.FCPerReichweite AS FLOAT) * 100) / CAST(TMP.FCMonatKomplett AS FLOAT)), 4) >= @ASchwelle
			THEN 'A'
		WHEN ROUND(((CAST(TMP.FCPerReichweite AS FLOAT) * 100) / CAST(TMP.FCMonatKomplett AS FLOAT)), 4) < @ASchwelle
			AND ROUND(((CAST(TMP.FCPerReichweite AS FLOAT) * 100) / CAST(TMP.FCMonatKomplett AS FLOAT)), 4) >= @BSchwelle
			THEN 'B'
				ELSE 'C'
	  END AS Klassifikation
FROM
(


	SELECT
		Art.Nummer AS Artikelnummer
		, CASE 
			WHEN (CAST(Art.Laenge AS INT) > @MaxAbmessung OR CAST(Art.Hoehe AS INT) > @MaxAbmessung OR CAST(Art.Breite AS INT) > @MaxAbmessung) THEN 1
				ELSE 0
		  END AS Nichtregal
		, CASE 
			WHEN TMP_Kitting.Artikelnummer IS NOT NULL THEN 1
				ELSE 0
		  END AS Kitting
		, CASE 
			WHEN CAST(Art.[Gewicht] / 1000 AS MONEY) > @MaxGewicht THEN 1
				ELSE 0 
		  END AS Spedition
		, Art.Sperrig AS Sperrgut
		, CAST(Art.Volumen AS FLOAT) AS Volumen
		, CAST(Art.Laenge AS INT) AS Laenge
		, CAST(Art.Hoehe AS INT) AS Hoehe
		, CAST(Art.Breite AS INT) AS Breite
		, CAST(Art.[Gewicht] / 1000 AS MONEY) AS Gewicht
		, CAST(ISNULL(Art.MengeProPalette, 0) AS INT) AS IstPalettenbelegung
		, CAST(ISNULL(TMP_Forecast.ForecastMenge, 0) AS INT) AS FC
		, CAST(ISNULL(SUM(TMP_Forecast.ForecastMenge) OVER (), 0) AS INT) AS FCMonatKomplett
		, @Reichweite AS Reichweite
		, CAST(ISNULL(((TMP_Forecast.ForecastMenge / @AnzahlTage) * @Reichweite), 0) AS INT) AS FCPerReichweite
		, CAST(CASE 
			WHEN ISNULL(Art.MengeProPalette, 0) = 0 THEN 0
				ELSE ISNULL(((TMP_Forecast.ForecastMenge / @AnzahlTage) * @Reichweite), 0) / Art.MengeProPalette
		  END AS INT) AS Palettenanzahl
	FROM [CT dwh 02 Data].[dbo].[tWMSArtikelstammReloaded] AS Art WITH (NOLOCK)
	LEFT JOIN
	(
		SELECT DISTINCT
			ArtSt1.Nummer AS Artikelnummer
		FROM [CT dwh 02 Data].[dbo].[tWMSArtikelstammReloaded] AS ArtSt1 WITH (NOLOCK)
		INNER JOIN [CT dwh 02 Data].[dbo].[tWMSArtikelstammReloaded] AS ArtSt2 WITH (NOLOCK)
			ON ArtSt1.Nummer = LEFT(LTRIM(RTRIM(ArtSt2.Nummer)), 8)
		WHERE 1 = 1
			AND LEN(LTRIM(RTRIM(ArtSt2.Nummer))) > 8
			AND LTRIM(RTRIM(ArtSt2.Nummer)) LIKE '%-%'
	) AS TMP_Kitting
	ON Art.Nummer = TMP_Kitting.Artikelnummer
	LEFT JOIN 
	(
			SELECT DISTINCT
				WeekNumber
				, [Artikelnummer]
				, SUM(CAST(ROUND((([ForecastMenge] / TMP.DaysofMonth) * TMP.[Days]), 0) AS INT)) OVER (PARTITION BY TMP.WeekNumber, FC.Artikelnummer ORDER BY FC.Artikelnummer) AS ForecastMenge
			FROM [CT dwh 03 Intelligence].[dbo].[tFactForecast] AS FC WITH (NOLOCK)
			INNER JOIN [CT dwh 03 Intelligence].[dbo].[tDimForecast] AS Dim WITH (NOLOCK)
				ON FC.Forecast_Id = Dim.Id
			CROSS JOIN #TMP_DaySplit AS TMP
			WHERE 1 = 1 
				AND Dim.[Year] = TMP.[Year]
				AND FC.Monat = TMP.[Month]
	) AS TMP_Forecast
	ON Art.Nummer = TMP_Forecast.Artikelnummer	
	WHERE 1 = 1
		AND LTRIM(RTRIM(Art.Nummer)) NOT LIKE '%-%'
) AS TMP
LEFT JOIN
( 
	SELECT
		TMP3.Artikelnummer
		, TMP3.GesamtVerkaufsmenge
		, TMP3.GesamtVerkaufsmengeMulti
		, ((TMP3.GesamtVerkaufsmengeMulti * 100) / TMP3.GesamtVerkaufsmenge) AS MultiProzentanteil
	FROM
	(
	SELECT TMP1.Artikelnummer
		,TMP1.AnzahlAuftraege
		,TMP1.GesamtVerkaufsmenge
		,ISNULL(TMP2.AnzahlAuftraegeMulti, 0) AS AnzahlAuftraegeMulti
		,ISNULL(TMP2.GesamtVerkaufsmengeMulti, 0) AS GesamtVerkaufsmengeMulti
	FROM (
		SELECT ISNULL(stueck.artikelnummer, pos.artikelnummer) AS Artikelnummer
			,COUNT(DISTINCT bel.BelID) AS AnzahlAuftraege
			,SUM(ISNULL(stueck.MengeBasis, pos.Menge)) AS GesamtVerkaufsmenge
		FROM [CT dwh 02 Data].[dbo].[tErpKHKVKBelege] bel WITH (NOLOCK)
		INNER JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelegarten] AS bela WITH (NOLOCK) ON bel.belegkennzeichen = bela.Kennzeichen
		INNER JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelegePositionen] AS pos WITH (NOLOCK) ON bel.belid = pos.belid
			AND bel.mandant = pos.mandant
		LEFT JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelegeStuecklisten] AS stueck WITH (NOLOCK) ON pos.belposid = stueck.belposid
			AND pos.mandant = stueck.mandant
		INNER JOIN [CT dwh 02 Data].[dbo].[tErpKHKArtikel] AS artikel WITH (NOLOCK) ON ISNULL(stueck.artikelnummer, pos.artikelnummer) = artikel.[Artikelnummer]
			AND artikel.mandant = 1
		WHERE CAST(bel.Belegdatum AS DATE) >= CAST(DATEADD(YEAR, - 1, GETDATE()) AS DATE)
			AND artikel.Artikelnummer LIKE '[15]%'
			AND bel.Mandant IN (
				1
				,3
				)
			AND bel.Belegkennzeichen != 'VSD'
			AND (
				(
					bel.[Vertreter] NOT IN (
						'V0004'
						,'V2155'
						,'V3001'
						,'V3002'
						,'V3003'
						)
					AND bel.[Mandant] = 1
					)
				OR (
					bel.[Vertreter] NOT IN (
						'V0004'
						,'V1002'
						,'V3001'
						,'V3002'
						,'V3003'
						)
					AND bel.[Mandant] = 3
					)
				OR (
					bel.[Kundengruppe] NOT IN (
						'24'
						,'25'
						,'35'
						,'106'
						,'113'
						,'207'
						,'214'
						,'215'
						)
					)
				OR (bel.Mandant != 2)
				)
			AND bela.StatistikWirkungUmsatz IN (1)
		GROUP BY ISNULL(stueck.artikelnummer, pos.artikelnummer)
		) AS TMP1
	LEFT JOIN (
		SELECT r.[Artikelnummer]
			,COUNT(DISTINCT r.[BelID]) AS AnzahlAuftraegeMulti
			,SUM(r.[GesamtVerkaufsmengeMulti]) AS [GesamtVerkaufsmengeMulti]
		FROM (
			SELECT TMP_Multi.[BelID]
				,TMP_Multi.[Mandant]
				,ISNULL(stueck.artikelnummer, pos.artikelnummer) AS Artikelnummer
				,ISNULL(stueck.MengeBasis, pos.Menge) AS GesamtVerkaufsmengeMulti
			FROM [CT dwh 02 Data].[dbo].[tErpKHKVKBelege] bel WITH (NOLOCK)
			INNER JOIN (
				SELECT k.[BelID]
					,k.[Mandant]
					,COUNT(DISTINCT ISNULL(ks.[Artikelnummer], kp.[Artikelnummer])) AS [Artikelnummer]
				FROM [CT dwh 02 Data].[dbo].[tErpKHKVKBelege] AS k WITH (NOLOCK)
				INNER JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelegarten] AS kb WITH (NOLOCK) ON k.belegkennzeichen = kb.Kennzeichen
				INNER JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelegePositionen] AS kp WITH (NOLOCK) ON kp.[BelID] = k.[BelID]
					AND kp.[Mandant] = k.[Mandant]
				LEFT JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelegeStuecklisten] AS ks WITH (NOLOCK) ON ks.[BelPosID] = kp.[BelPosID]
					AND ks.[Mandant] = kp.[Mandant]
					AND ks.[BelID] = kp.[BelID]
				WHERE k.[Mandant] = 1
					AND CAST(k.Belegdatum AS DATE) >= CAST(DATEADD(YEAR, - 1, GETDATE()) AS DATE)
					AND ISNULL(ks.[Artikelnummer], kp.[Artikelnummer]) LIKE '[15]%'
					AND k.Belegkennzeichen != 'VSD'
					AND kb.StatistikWirkungUmsatz = 1
					AND (
						(
							k.[Vertreter] NOT IN (
								'V0004'
								,'V2155'
								,'V3001'
								,'V3002'
								,'V3003'
								)
							AND k.[Mandant] = 1
							)
						OR (
							k.[Vertreter] NOT IN (
								'V0004'
								,'V1002'
								,'V3001'
								,'V3002'
								,'V3003'
								)
							AND k.[Mandant] = 3
							)
						OR (
							k.[Kundengruppe] NOT IN (
								'24'
								,'25'
								,'35'
								,'106'
								,'113'
								,'207'
								,'214'
								,'215'
								)
							)
						OR (k.Mandant != 2)
						)
					AND k.Mandant IN (
						1
						,3
						)
				GROUP BY k.[BelID]
					,k.[Mandant]
				HAVING COUNT(DISTINCT ISNULL(ks.[Artikelnummer], kp.[Artikelnummer])) > 1
				) AS TMP_Multi ON bel.BelID = TMP_Multi.BelID
				AND bel.Mandant = TMP_Multi.Mandant
			INNER JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelegePositionen] AS pos WITH (NOLOCK) ON bel.belid = pos.belid
				AND bel.mandant = pos.mandant
			LEFT JOIN [CT dwh 02 Data].[dbo].[tErpKHKVKBelegeStuecklisten] AS stueck WITH (NOLOCK) ON pos.belposid = stueck.belposid
				AND pos.mandant = stueck.mandant
			WHERE ISNULL(stueck.MengeBasis, pos.Menge) > 0
				AND ISNULL(stueck.MengeBasis, pos.Menge) < 4
			) AS r
		GROUP BY r.[Artikelnummer]
		) AS TMP2 ON TMP1.Artikelnummer = TMP2.Artikelnummer

	) AS TMP3
	WHERE ((TMP3.GesamtVerkaufsmengeMulti * 100) / TMP3.GesamtVerkaufsmenge) > @MultiSchwelle
) AS TMP_Multi
ON TMP.Artikelnummer = TMP_Multi.Artikelnummer
ORDER BY
	CASE 
		WHEN TMP.Nichtregal = 1 THEN 1
		WHEN TMP.Kitting = 1 THEN 2
		WHEN TMP_Multi.Artikelnummer IS NOT NULL THEN 3
		WHEN TMP.Spedition = 1 THEN 4
		WHEN TMP.Sperrgut = 1 THEN 5
		WHEN SUM(CASE WHEN TMP.Nichtregal = 0 AND TMP.Kitting = 0 AND TMP_Multi.Artikelnummer IS NULL AND TMP.Spedition = 0 AND TMP.Sperrgut = 0 THEN TMP.Palettenanzahl ELSE 0 END) OVER (ORDER BY CASE WHEN TMP.Nichtregal = 0 AND TMP.Kitting = 0 AND TMP_Multi.Artikelnummer IS NULL AND TMP.Spedition = 0 AND TMP.Sperrgut = 0 THEN TMP.Palettenanzahl ELSE 0 END DESC ROWS UNBOUNDED PRECEDING) <= @MaxAnzahlPaletten THEN 6
		WHEN ROUND(((CAST(TMP.FCPerReichweite AS FLOAT) * 100) / CAST(TMP.FCMonatKomplett AS FLOAT)), 4) > @APlusSchwelle THEN 7
		WHEN ROUND(((CAST(TMP.FCPerReichweite AS FLOAT) * 100) / CAST(TMP.FCMonatKomplett AS FLOAT)), 4) < @APlusSchwelle AND ROUND(((CAST(TMP.FCPerReichweite AS FLOAT) * 100) / CAST(TMP.FCMonatKomplett AS FLOAT)), 4) >= @ASchwelle THEN 8
		WHEN ROUND(((CAST(TMP.FCPerReichweite AS FLOAT) * 100) / CAST(TMP.FCMonatKomplett AS FLOAT)), 4) < @ASchwelle AND ROUND(((CAST(TMP.FCPerReichweite AS FLOAT) * 100) / CAST(TMP.FCMonatKomplett AS FLOAT)), 4) >= @BSchwelle THEN 9
		ELSE 10
	 END


DROP TABLE #TMP_DaySplit


	FETCH NEXT FROM @cursor
		INTO @PrevMonday, @LastSunday, @AnzahlTage, @KW
	
		END 
		CLOSE @cursor
		DEALLOCATE @cursor 

DROP TABLE #TMP_Dates




	
END
GO
/****** Object:  StoredProcedure [dbo].[tempGetNearestCity]    Script Date: 17/10/2024 10:58:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[tempGetNearestCity]
@LATITUDE decimal,
@LONGITUDE decimal, 
@CityId INT OUTPUT
as

--select @CityId = 
--(
SELECT 
top 100 CityId,[CityName]
FROM tMktCityList where isocityid <> -1
ORDER BY (ABS(ABS(LAT)-ABS(@LATITUDE)))+ABS(ABS(LON)-ABS(@LONGITUDE)) 
--)

 
GO
/****** Object:  StoredProcedure [dbo].[tempMapAdressenCityAdd]    Script Date: 17/10/2024 10:58:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE procedure [dbo].[tempMapAdressenCityAdd]
@aid int, 
@formatted_address nvarchar(max),  
@street_number nvarchar(max),  
@route nvarchar(max),  
@locality nvarchar(max),  
@administrative_area_level_1 nvarchar(max),  
@country nvarchar(max),  
@country_code nvarchar(max),  
@postal_code nvarchar(max),  
@request nvarchar(max),  
@lat float, 
@lon float, 
@result nvarchar(max), 
@proxyaddr nvarchar(max), 
@proxyport int, 
@apikey nvarchar(max), 
@responseXML nvarchar(max)

as


update [dbo].[tempMapAdressenCity] 
set 
[street_number] = @street_number, 
[route] = @route,
[locality] = @locality,
[administrative_area_level_1] = @administrative_area_level_1,
[country] = @country,
[country_code] = @country_code, 
[postal_code] = @postal_code, 
[request] = @request, 
[lat] = @lat,
[lon] = @lon, 
[result] = @result, 
[proxyaddr] = @proxyaddr, 
[proxyport] = @proxyport, 
[mdInsertDate] = getdate(),
[responseXML] = @responseXML
where addressid = @aid and apikey = @apikey 

/*
insert into [dbo].[tempMapAdressenCity] 
([addressid],[formatted_address],[street_number],[route],[locality],[administrative_area_level_1],
[country],[country_code], [postal_code],[request], [lat],[lon], [result], [proxyaddr], [proxyport], [mdInsertDate], [apikey], [responseXML])
values
(@aid,@formatted_address,@street_number,@route,@locality,@administrative_area_level_1,@country,@country_code, @postal_code, 
@request, @lat,@lon, @result, @proxyaddr, @proxyport, getdate(), @apikey, @responseXML)

*/




GO
/****** Object:  StoredProcedure [dbo].[tempPop]    Script Date: 17/10/2024 10:58:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[tempPop]
@aid int, 
@cid int
as 
update tempMapAdressenCity set CityId = @cid where AddressId = @aid
GO
/****** Object:  StoredProcedure [dbo].[tempReturnAddress]    Script Date: 17/10/2024 10:58:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  procedure [dbo].[tempReturnAddress]
@apikey nvarchar(max), 
@retstr nvarchar(max) output, 
@aid int output
as
-- AIzaSyDpHGDGZcz4n4_6cZ055zxk0vusGHa0zhI 
--AIzaSyAFLDNDR1y0RUS2xY0m0SeP5UNMhsALzKI   --d.fedorov
--AIzaSyA9wfzAQaJguedyJF-3ikafGGKK1SMnR-I   -- marketing

--AIzaSyB2giSzcQJ71EZlSbo_KIJcP9JWIXcNPmg admimmcc

select @aid = 
(
select top 1  
a.AddressId
from tErpKHKAdressen a  
left join  tempMapAdressenCity c on c.addressid = a.addressid 
where c.addressid is null 
order by a.AddressId desc
)

select @retstr = (
select top 1  
replace('https://maps.googleapis.com/maps/api/geocode/xml?address=' + isnull(a.LieferStrasse, '')  + ',' + isnull(a.LieferOrt,'') 
+ ' ' + isnull(a.lieferPLZ,'') + ', ' + isnull(a.LieferLand,'') +
'&language=en&key=' + @apikey , ' ', '+') 
from  tErpKHKAdressen a where AddressId = @aid 
)

insert into tempMapAdressenCity(addressid, formatted_address, APIkey) values (@aid, @retstr, @apikey)




GO
/****** Object:  StoredProcedure [dbo].[usp_HistoricalSalesUpdate]    Script Date: 17/10/2024 10:58:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[usp_HistoricalSalesUpdate]
	@Year int =0, @month int =0
AS


/*----------------------------------------------------
article dimensions -- Allsales table
-----------------------------------------------------*/
		--Update dm
		--	SET 
		--	  ProductHierarchie1 = art.tProductHierarchie1,
		--	  ProductHierarchie2 = art.tProductHierarchie2,
		--	  ProductHierarchie3 = art.tProductHierarchie3,
		--	  Sourcer = art.tSourcer,
		--	  Brand = art.tBrand,
		--	  Categorymanager = art.tCategoryManagement,
		--	  Weight = art.fWeight,
		--	  IntrastatCode = art.tIntrastatCode,
		--	  Matchcode = art.tMatchCode,
		--	  Disponent = art.tDisponent,
		--	  EOL = art.nEOL,
		--	  ItemClass = art.tItemClass,
		--	  GTSCode = art.tGTSCode,
		--	  dm.LastModified = getdate()--,
		----	  IsProcessed = 0
		--FROM  [CT dwh 02 Data].dbo.tFactAllSalesTransactions	 dm
		--inner join [CT dwh 03 Intelligence].dbo.tdimarticle art on art.narticlenumber = dm.ItemNo
		--and art.nCompanyid = dm.CompanyId and art.[dtLastModified] >= '2021-01-01' and dm.bisdeleted = 0
		--and year(dm.TransactionDate) = @Year --and  month(dm.TransactionDate)  = @month

Update dm
	SET 
	GrossDocumentFooter = isnull(dm.DocumentFooter,0) * (1 + (ISNULL(Steuer.Steuersatz, 19)/100)),
		GrossPrice = isnull(NetPrice,0) * (1 + (ISNULL(Steuer.Steuersatz, 19)/100)),
		GrossPriceForeignCurrency = isnull(NetPriceForeignCurrency,0) * (1 + (ISNULL(Steuer.Steuersatz, 19)/100)),
		GrossDocumentFooterForeignCurrency = isnull(DocumentFooter,0) * (1 + (ISNULL(Steuer.Steuersatz, 19)/100))/ISNULL(WkzKursFW, 1)
FROM [CT dwh 03 Intelligence].dbo.tfactSalesTransactionsVertical	 dm
inner join 	[CT dwh 02 Data].dbo.tErpKHKVKBelege AS Belege WITH (NOLOCK)
	on Belege.BelID = dm.DocumentId
	and Belege.Mandant = dm.CompanyId
	and Belege.VorID = dm.ProcessId
INNER JOIN [CT dwh 02 Data].dbo.tErpKHKVKBelegePositionen AS BelegePositionen WITH(NOLOCK)
	ON dm.companyid = BelegePositionen.Mandant
			AND dm.DocumentId = BelegePositionen.BelID
			AND BelegePositionen.IsDeletedFlag = 0
			ANd ItemNoProduct = BelegePositionen.Artikelnummer
LEFT JOIN [CT dwh 02 Data].dbo.[tErpKHKSteuertabelle] AS Steuer WITH (NOLOCK)
	ON BelegePositionen.Steuercode = Steuer.Steuercode
where YEAR(TransactionDate) = @Year
and GrossPrice is null

/*----------------------------------------------------
SalesAccount -- Update Vertical table
-----------------------------------------------------*/


		
		--Update dm
		--	SET 
		--	  ProductHierarchie1 = art.tProductHierarchie1,
		--	  ProductHierarchie2 = art.tProductHierarchie2,
		--	  ProductHierarchie3 = art.tProductHierarchie3,
		--	  Sourcer = art.tSourcer,
		--	  Brand = art.tBrand,
		--	  Categorymanager = art.tCategoryManagement,
		--	  Weight = art.fWeight,
		--	  IntrastatCode = art.tIntrastatCode,
		--	  Matchcode = art.tMatchCode,
		--	  Disponent = art.tDisponent,
		--	  EOL = art.nEOL,
		--	  ItemClass = art.tItemClass,
		--	  GTSCode = art.tGTSCode,
		--	  dm.LastModified = getdate()
		--FROM  [CT dwh 03 Intelligence].dbo.tfactSalesTransactionsVertical	 dm
		--inner join [CT dwh 03 Intelligence].dbo.tdimarticle art on art.narticlenumber = dm.ItemNo
		--and art.nCompanyid = dm.CompanyId and art.[dtLastModified] >= '2021-01-01' --and dm.bisdeleted = 0
		--and year(dm.TransactionDate) = @Year --and  month(dm.TransactionDate)  = @month


	--UPDATE fac
	--	SET 
	--	   fac.ProductHierarchie1 = v.ProductHierarchie1
	--	  ,fac.ProductHierarchie2 =v.ProductHierarchie2
	--	  ,fac.ProductHierarchie3= v.ProductHierarchie3
	--	  ,fac.Sourcer= v.Sourcer
	--	  ,fac.Brand= v.Brand
	--	  ,fac.Categorymanager= v.Categorymanager
	--	  ,fac.Weight = v.Weight
	--	  ,fac.IntrastatCode = v.IntrastatCode
	--	  ,fac.Matchcode = v.Matchcode
	--	  ,fac.Disponent = v.Disponent
	--	  ,fac.EOL = v.EOL
	--	  ,fac.ItemClass = v.ItemClass
	--	  ,fac.GTSCode = v.GTSCode
	--	  ,fac.LastModified = getdate()
	--FROM [CT dwh 03 Intelligence].dbo.[tFactSalesTransactionsVertical] fac
	--Inner join  [CT dwh 02 Data].dbo.[tFactAllSalesTransactions] v with(nolock)
	--ON v.ReferenceID = fac.referenceID and v.rc = fac.rc AND v.bIsDeleted = 0 and v.IsProcessed =0
/*----------------------------------------------------
SalesAccount -- Update isprocessfield
-----------------------------------------------------*/


--Update fac
--      SET fac.IsProcessed = 1
--FROM   [CT dwh 02 Data].dbo.[tFactAllSalesTransactions] fac
--where IsProcessed = 0
GO
