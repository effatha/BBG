USE [CT dwh 01 Stage]
GO

/****** Object:  View [dbo].[vSAP_EKBE]    Script Date: 27/11/2025 11:10:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vSAP_EKET]
AS

		SELECT DISTINCT  
					EINDT,
					MANDT,
					EBELN,
					EBELP,
					[ETENR]
		FROM [CT dwh 01 Stage].dbo.[tSAP_EKET_FULL]



GO



    --select MANDT,EBELN
    --FROM [CT dwh 01 Stage].[dbo].[vSAP_EKKO]
    --group by  MANDT,EBELN
    --having count(*) > 1
