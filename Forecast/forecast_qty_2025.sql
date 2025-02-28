SELECT distinct art.artikelnummer,
--kat1.bezeichnung as Haupartikelgruppe, kat2.bezeichnung as Vaterartikelgruppe, kat3.bezeichnung as Artikelgruppe,
--art.matchcode as 'Description', user_markenklasse as 'Markenklasse',
 
 
--case when user_markenklasse = 7 then 'M&A' else 'Non M&A' end 'Item type',
--art.user_categorymanagement as CM, USER_Sourcer  as 'PM', art.isteinmalartikel as EOL, user_einkaeufer as 'Disponent',
 
--user_gstcode1 as 'Supplier',
--user_vkmarke as 'Brand',
--user_mabrand as 'M&A brand',
--pp.PP 'PP',
 
 
 
 

fcdata.Jan24,
fcdata.Feb24,
fcdata.Mar24,
fcdata.Apr24,
fcdata.May24,
fcdata.Jun24,
fcdata.JUl24,
fcdata.Aug24,
fcdata.Sep24,
fcdata.Oct24,
fcdata.Nov24,
fcdata.Dec24,

fcdata.Jan25,
fcdata.Feb25,
fcdata.Mar25,
fcdata.Apr25,
fcdata.May25,
fcdata.Jun25,
fcdata.JUl25,
fcdata.Aug25,
fcdata.Sep25,
fcdata.Oct25,
fcdata.Nov25,
fcdata.Dec25
--lastadj.Updated 'Last_adjt_date',
 
--lastadj.Grund3
--dio.dioship_final, stock.verfuegbar
 
 
from OLReweAbf.dbo.KHKArtikel art
 
 
------------------Artikelgruppen------------------
left outer join [OLReweAbf].[dbo].[KHKArtikelgruppen] Kat3 WITH(NOLOCK)
on art.artikelgruppe = Kat3.artikelgruppe
and Kat3.mandant = 1
and len(Kat3.artikelgruppe) = 9
 
left outer join [OLReweAbf].[dbo].[KHKArtikelgruppen] Kat2 WITH(NOLOCK)
on art.vaterartikelgruppe = Kat2.artikelgruppe
and Kat2.mandant = 1
and len(Kat2.artikelgruppe) = 9
 
left outer join [OLReweAbf].[dbo].[KHKArtikelgruppen] Kat1 WITH(NOLOCK)
on art.Hauptartikelgruppe = Kat1.artikelgruppe
and Kat1.mandant = 1
and len(Kat1.artikelgruppe) = 9
 
--------- JOIN WITH FC Table --------------------
 
 
left join (
 
select art.artikelnummer,
 
fc2024.january                    Jan24,
fc2024.february					  Feb24,
fc2024.march					  Mar24,
fc2024.april                      Apr24,
fc2024.may                        May24,
fc2024.Juni                       Jun24,
fc2024.July                       JUl24,
fc2024.August                     Aug24,
fc2024.September				  Sep24,
fc2024.October                    Oct24,
fc2024.November                   Nov24,
fc2024.December                   Dec24,

fc2025.january                    Jan25,
fc2025.february					  Feb25,
fc2025.march                      Mar25,
fc2025.april                      Apr25,
fc2025.may                        May25,
fc2025.Juni                       Jun25,
fc2025.July                       JUl25,
fc2025.August					  Aug25,
fc2025.September				  Sep25,
fc2025.October                    Oct25,
fc2025.November                   Nov25,
fc2025.December                   Dec25 
from OLReweAbf.dbo.KHKArtikel art
 
 
 -- FC 2024 --
 
 left join (select artikelnummer, January, February, March, April, May, Juni, July, august, september, october, november, december
 
 from [ChalTecDWH].[dbo].[ForecastResult] 
 
 where forecast_id = 9 ) fc2024 on fc2024.artikelnummer = art.artikelnummer
 
  -- FC 2025 --
 
 left join (select artikelnummer, January, February, March, April, May, Juni, July, august, september, october, november, december
 
 from [ChalTecDWH].[dbo].[ForecastResult] 
 
 where forecast_id = 10 ) fc2025 on fc2025.artikelnummer = art.artikelnummer
 
 
) Fcdata on Fcdata.Artikelnummer = art.Artikelnummer
 
 
------ Left join PP ----
 
left join (
 
SELECT main.Artikelnummer, isnull(pp23.Einzelpreis,pp22.Einzelpreis) PP
 
 
 FROM [OLReweAbf].[dbo].[KHKArtikel] main
 
 
 left join [OLReweAbf].[dbo].[LBSysPreise]PP22 on PP22.artikelnummer = main.artikelnummer
 
 and pp22.ListeId = 272
 
 
 left join [OLReweAbf].[dbo].[LBSysPreise]PP23 on PP23.artikelnummer = main.artikelnummer
 
 and PP23.ListeId = 278
 
 
where main.Mandant = 1
 
and main.Artikelnummer like '1%' ) PP on pp.Artikelnummer = art.Artikelnummer
 
 
 
 
--- last adjustment ----
 
 
left join (
 
select *
 
from
 
(
 
select dp.artikelnummer, firstname, updated, grund3, rank () over ( partition by  dp.artikelnummer  order by updated desc ) rang
 
 
from [ChalTecDWH].[dbo].[ForecastResult_Dataport] dp
 
 
left join [ChalTecDataPort].[dbo].[ChalTecDataPort_AuthenticatedUser] erst
 
on dp.Ersteller = erst.UserId
 
left join OLReweAbf.dbo.KHKArtikel art
 
on dp.Artikelnummer = art.Artikelnummer
 
 
where StatusId = 4
 
---and cast(updated as date) = '2022.06.23'
 
and art.Mandant = 1
 
--and FirstName <> 'Antonio'
 
--and dp.Artikelnummer = '10036220'
 
--and art.USER_Markenklasse = 7
 
---order by updated desc
 
 
 
) finalrank where finalrank.rang = 1
 
) lastadj on lastadj.Artikelnummer = art.Artikelnummer
 
 
 
 
 
where art.Artikelnummer like '1%'
 
and art.Mandant = 1
 
--and not ( EOL = -1 and Verfuegbar <= 0 )