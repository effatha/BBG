--CREATE TABLE TEST.L0_AKENEO_ATTRIBUTE_LABELS
--(
--    T_ATTRIBUTE_NAME VARCHAR(50),
--    CD_ATTRIBUTE VARCHAR(50),
--    T_ATTRIBUTE_LABEL VARCHAR(150),
--    CD_LANGUAGE  VARCHAR(50)
--  )


--INSERT INTO TEST.L0_AKENEO_ATTRIBUTE_LABELS (T_ATTRIBUTE_NAME,CD_ATTRIBUTE,T_ATTRIBUTE_LABEL,CD_LANGUAGE)
--SELECT 'item_status', 'active_uk_only','Active - UK exclusively','de-DE'
--UNION
--SELECT 'item_status', 'complience_blacklist','Compliance & Blacklist','de-DE'
--UNION
--SELECT 'item_status', 'new_launch_cohort_2025_design','New Launch Cohort 2025 - Design Series','de-DE'
--UNION
--SELECT 'item_status', 'phase_out_1','Phase-Out 1','de-DE'
--UNION
--SELECT 'item_status', 'status_active','Active','de-DE'
--UNION
--SELECT 'item_status', 'status_on_hold','Worst Offenders (High Refunds - On Hold)','de-DE'
--UNION
--SELECT 'item_status', 'new_launch_cohort_2025','New Launch Cohort 2025','de-DE'
--UNION
--SELECT 'item_status', 'status_eol','EOL','de-DE'
--UNION
--SELECT 'item_status', 'phase_out_2','Phase-Out 2','de-DE'
--UNION
--SELECT 'item_status', 'phase_out_3','Phase-Out 3','de-DE'
--UNION
--SELECT 'item_status', 'new_launch_cohort_2026','New Launch Cohort 2026','de-DE'
--UNION
--SELECT 'item_status', 'new_launch_cohort_2024','New Launch Cohort 2024','de-DE'


;with cte_item_status as
(

    select T_SKU, T_ATTRIBUTE,T_ATTRIBUTE_LABEL
     from L0.L0_AKENEO_PRODUCTS prod
     INNER JOIN TEST.L0_AKENEO_ATTRIBUTE_LABELS lbl
        on lbl.CD_ATTRIBUTE = T_ATTRIBUTE
    WHERe
        prod.t_attribute_name = 'item_status'

)
SELECT
    it.*
    ,AkeneoItemStatus = ak.T_ATTRIBUTE_LABEL
    ,it.ItemStatus
FROM PL.PL_V_ITEM it
LEFT JOIN cte_item_status ak
    on ak.T_SKU =cast(it.ItemNo as varchar(50))
WHERE
    ItemNo like '10%'