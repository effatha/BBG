SELECT 
cd_country,
d_report,
t_shop_name,
fl_magazine,
t_device,
t_landing_page,
count(distinct t_query) as queries,
sum(cnt_clicks) as cnt_clicks,
sum(cnt_impressions) as cnt_impressions,
avg(vl_position) as avg_vl_position
INTO TEST.L1_FACT_A_GSC_PAGE_QUERY_HB
FROM L1.L1_FACT_A_GSC_PAGE_QUERY
WHERE d_report >= DATEADD(D, -450, getdate())
GROUP BY 
cd_country,
d_report,
t_shop_name,
fl_magazine,
t_device,
t_landing_page



