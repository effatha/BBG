/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [CD_PLANT]
      ,[ID_ITEM]
      ,[CD_ITEM_TYPE]
	  ---MBEW
      ,[VL_HEP_TOTAL_STOCK] -- ItemStockQuantity
      ,[AMT_HEP_TOTAL_VALUE_HEDGED_EUR] --ItemStockValueEUR
      ,[AMT_HEP_PRICE_HEDGED_EUR] -- MekHedging  --
	  --
      ,[AMT_MEK_MATERIAL_VALUE_EUR] -- TotalStockFOBPrice
      ,[AMT_MEK_FREIGHT_VALUE_EUR] -- TotalStockFreightValue
      ,[AMT_MEK_CUSTOM_VALUE_EUR]  -- TotalStockCustomsValue    
	  ,[AMT_MEK_HEDGING_VALUE_EUR] -- TotalMekHedging (FX/Hedging)? -- TotalStockFXEffect

      ,[AMT_MEK_MATERIAL_PRICE_EUR] -- ItemAVGFOBPrice 
      ,[AMT_MEK_FREIGHT_PRICE_EUR] -- ItemAVGFreightPrice
      ,[AMT_MEK_CUSTOM_PRICE_EUR] -- ItemAVGCustomsPrice
      ,[AMT_MEK_HEDGING_PRICE_EUR] -- ItemAVGFXEffect
      

	  ,[D_EFFECTIVE]
      ,[DT_DWH_CREATED]
      ,[DT_DWH_UPDATED]
      ,[BELNR]
      ,[DOCLN]
      ,[timestamp]
      ,[MATNR]
      ,[ROW_NUM_DATE]
      ,[MEK_Material_Price_Adjusted]
      ,[MEK_Material_Value_Adjusted]
      ,[CHECK_VALUES]
      ,[CHECK_PRICE]
  FROM [TEST].[L1_FACT_F_MEK]



SELECT distinct
      [ItemType]
      
  FROM [PL].[PL_V_KITTING_NON_A_GOODS_SALES]