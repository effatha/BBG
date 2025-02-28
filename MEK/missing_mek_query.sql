with cte_info as (
	SELECT MAX([Purchasing info rec.]) info_rec
      ,[Material]
  FROM [CT dwh 03 Intelligence].[dbo].[tPurchasingInfoRecordGeneralData]
  where cast([Material] as bigint) in 
  (
'10046175'
,'10046176'
,'10046177'
,'10046178'
,'10046179'
,'10046180'
,'10046181'
,'10046500'
,'10046501'
,'10046502'
,'10046735'
,'10046736'
,'10046758'
,'10046759'
,'10046760'
,'10046761'
,'10046820'
,'10046821'
,'10046822'
,'10046823'
,'10046824'
,'10046825'

  )
group by [Material]
)
SELECT Material,[Purchasing info rec.],Plant,Currency,[Net Price]
from [dbo].[tPurchasingInfoRecordPurchasingOrganizationData] od
INNER JOIN cte_info as cte on cte.info_rec = od.[Purchasing info rec.]

--where [Purchasing info rec.] ='5300023470'


