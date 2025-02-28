/***************************************************************************************************
** Security Model: Create a database role per schema and assign it to each AD group needed/ approved
*****************************************************************************************************
	ROLES:
		rl_l0_reader (includes l0 and wr)
		rl_l1_reader
		rl_pl_reader
		rl_ex_reader
		rl_l0_fin_reader
		rl_l1_fin_reader
		rl_pl_fin_reader

	AD Groups
	-- sg-BBG-DWH-DataAnalysts-PROD        | rl_l0_reader;rl_l1_reader;rl_pl_reader;rl_ex_reader
	-- sg-BBG-DWH-DataEngineers-PROD		  | rl_l0_reader;rl_l1_reader;rl_pl_reader;rl_ex_reader
	-- sg-BBG-DWH-DataScientists-PROD	  | only Data lake?? maybe export layer rl_ex_reader
	-- sg-BBG-DWH-PBIAnalysts-PROD		  | rl_pl_reader; rl_ex_reader

	-- sg-BBG-DWH-DataAnalysts-PROD-Fin    | rl_l0_fin_reader;rl_l1_fin_reader;rl_pl_fin_reader;rl_ex_fin_reader  
	-- sg-BBG-DWH-DataEngineers-PROD-Fin   | rl_l0_fin_reader;rl_l1_fin_reader;rl_pl_fin_reader;rl_ex_fin_reader  
	-- sg-BBG-DWH-DataScientists-PROD-Fin  | only Data lake?? 
	-- sg-BBG-DWH-PBIAnalysts-PROD-Fin	  | rl_pl_fin_reader

	*****GET Roles/Ad group assigments****
	
			SELECT 
				dp1.name AS UserName,
				 dp1.type_desc,
				dp2.name AS RoleName
			FROM 
				sys.database_role_members AS drm
			JOIN 
				sys.database_principals AS dp1
				ON drm.member_principal_id = dp1.principal_id
			JOIN 
				sys.database_principals AS dp2
				ON drm.role_principal_id = dp2.principal_id
			ORDER BY 
				UserName, RoleName;

UserName	type_desc	RoleName
dbo	SQL_USER	db_owner
pview-bbg-weu-dwh-prd-01	EXTERNAL_USER	db_datareader
sg-BBG-DWH-BusAnalysts-PROD	EXTERNAL_GROUP	rl_ex_reader
sg-BBG-DWH-BusAnalysts-PROD	EXTERNAL_GROUP	rl_pl_reader
sg-BBG-DWH-DataAnalysts-PROD	EXTERNAL_GROUP	db_datareader
sg-BBG-DWH-DataEngineers-PROD	EXTERNAL_GROUP	db_datareader
sg-BBG-DWH-DataEngineers-PROD	EXTERNAL_GROUP	db_datawriter
sg-BBG-DWH-PBIAnalysts-PROD	EXTERNAL_GROUP	db_datareader
sp-BBG-DWH-DIOCT@go-bbg.com	EXTERNAL_USER	rl_ex_reader
svc-pbi-reader-prod@go-bbg.com	EXTERNAL_USER	dq_reader
svc-pbi-reader-prod@go-bbg.com	EXTERNAL_USER	l1_reader
svc-pbi-reader-prod@go-bbg.com	EXTERNAL_USER	mediumrc
svc-pbi-reader-prod@go-bbg.com	EXTERNAL_USER	pl_reader
synw-bbg-dwh-sql-deploy@go-bbg.com	EXTERNAL_USER	db_owner


****************************************************************************************/

/************************************
** Remove access
************************************/
	EXEC sp_droprolemember  N'db_datareader', N'sg-BBG-DWH-DataAnalysts-PROD'
	EXEC sp_droprolemember  N'db_datawriter', N'sg-BBG-DWH-DataEngineers-PROD'
	EXEC sp_droprolemember  N'db_datareader', N'sg-BBG-DWH-DataEngineers-PROD'
	EXEC sp_droprolemember  N'db_datareader', N'sg-BBG-DWH-PBIAnalysts-PROD'

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sg-BBG-DWH-DataAnalysts-PROD-Fin'
)
BEGIN
	CREATE USER [AZLNPYQA01] FROM EXTERNAL PROVIDER;

		CREATE USER [m.zhou.extern] FROM EXTERNAL PROVIDER;

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sg-BBG-DWH-DataEngineers-PROD-Fin'
)
BEGIN
	CREATE USER [sg-BBG-DWH-DataEngineers-PROD-Fin] FROM EXTERNAL PROVIDER;
END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sg-BBG-DWH-PBIAnalysts-PROD-Fin'
)
BEGIN
	CREATE USER [sg-BBG-DWH-PBIAnalysts-PROD-Fin] FROM EXTERNAL PROVIDER;
END
/**************************************************
** Check for the database roles 
**************************************************/
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_l0_reader'
)
BEGIN
	CREATE ROLE rl_l0_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::L0 TO rl_l0_reader;
	GRANT SELECT ON SCHEMA::WR TO rl_l0_reader;
	GRANT SELECT ON SCHEMA::MD TO rl_l0_reader;
	GRANT SELECT ON SCHEMA::DQ TO rl_l0_reader;
	GRANT INSERT ON SCHEMA::MD TO rl_l0_reader;
	GRANT UPDATE ON SCHEMA::MD TO rl_l0_reader;
	GRANT EXECUTE ON SCHEMA::WR TO rl_l0_reader;
	GRANT DELETE ON SCHEMA::MD TO rl_l0_reader;
	GRANT DELETE ON SCHEMA::WR TO rl_l0_reader;
	GRANT INSERT ON SCHEMA::WR TO rl_l0_reader;
	GRANT UPDATE ON SCHEMA::WR TO rl_l0_reader;
	

	AZLNPYQA01

	EXEC sp_addrolemember N'rl_l0_reader', N'AZLNPYQA01'
	EXEC sp_addrolemember N'rl_l0_reader', N'AZLNPYQA01'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_l1_reader'
)
BEGIN
	CREATE ROLE rl_l1_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::L1 TO rl_l1_reader;
		GRANT SELECT ON SCHEMA::DQ TO rl_l1_reader;

	--GRANT EXECUTE ON SCHEMA::L1 TO rl_l1_reader;
	--GRANT DELETE ON SCHEMA::L1 TO rl_l0_reader;
	--GRANT INSERT ON SCHEMA::L1 TO rl_l0_reader;
	--GRANT UPDATE ON SCHEMA::L1 TO rl_l0_reader;

	EXEC sp_addrolemember N'rl_l1_reader', N'sg-BBG-DWH-DataEngineers-PROD'
	EXEC sp_addrolemember N'rl_l1_reader', N'sg-BBG-DWH-DataAnalysts-PROD'
	EXEC sp_addrolemember N'rl_l1_reader', N'sg-BBG-DWH-PBIAnalysts-PROD'
	EXEC sp_addrolemember N'rl_l1_reader', N'sg-BBG-DWH-BusAnalysts-PROD'
			EXEC sp_addrolemember N'rl_l1_reader', N'synw-sql-login-prd'


END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_pl_reader'
)
BEGIN
	CREATE ROLE rl_pl_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::PL TO rl_pl_reader;
	EXEC sp_addrolemember N'rl_pl_reader', N'sg-BBG-DWH-DataEngineers-PROD'
	EXEC sp_addrolemember N'rl_pl_reader', N'sg-BBG-DWH-DataAnalysts-PROD'
	EXEC sp_addrolemember N'rl_pl_reader', N'sg-BBG-DWH-PBIAnalysts-PROD'
	EXEC sp_addrolemember N'rl_pl_reader', N'sg-BBG-DWH-BusAnalysts-PROD'
		EXEC sp_addrolemember N'rl_pl_reader', N'synw-sql-login-prd'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_ex_reader'
)
BEGIN
	CREATE ROLE rl_ex_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::EX TO rl_ex_reader;
	EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-DataEngineers-PROD'
	EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-DataAnalysts-PROD'
	EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-PBIAnalysts-PROD'
--	EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-DataScientists-PROD'
	EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-BusAnalysts-PROD'

END



/***********************************
** FIN
************************************/


IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_l0_fin_reader'
)
BEGIN
	CREATE ROLE rl_l0_fin_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::L0_FIN TO rl_l0_fin_reader;
	GRANT SELECT ON SCHEMA::WR_FIN TO rl_l0_fin_reader;
	EXEC sp_addrolemember N'rl_l0_fin_reader', N'sg-BBG-DWH-DataEngineers-PROD-Fin'
	EXEC sp_addrolemember N'rl_l0_fin_reader', N'sg-BBG-DWH-DataAnalysts-PROD-Fin'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_l1_fin_reader'
)
BEGIN
	CREATE ROLE rl_l1_fin_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::L1_FIN TO rl_l1_fin_reader;
	EXEC sp_addrolemember N'rl_l1_fin_reader', N'sg-BBG-DWH-DataEngineers-PROD-Fin'
	EXEC sp_addrolemember N'rl_l1_fin_reader', N'sg-BBG-DWH-DataAnalysts-PROD-Fin'
	EXEC sp_addrolemember N'rl_l1_fin_reader', N'sg-BBG-DWH-PBIAnalysts-PROD-Fin'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_pl_fin_reader'
)
BEGIN
	CREATE ROLE rl_pl_fin_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::PL_FIN TO rl_pl_fin_reader;
	EXEC sp_addrolemember N'rl_pl_fin_reader', N'sg-BBG-DWH-DataEngineers-PROD-Fin'
	EXEC sp_addrolemember N'rl_pl_fin_reader', N'sg-BBG-DWH-DataAnalysts-PROD-Fin'
	EXEC sp_addrolemember N'rl_pl_fin_reader', N'sg-BBG-DWH-PBIAnalysts-PROD-Fin'

END

EXEC sp_addrolemember N'rl_l1_fin_reader', N'svc-pbi-reader-prod@go-bbg.com'


/***********************************
**  Export layer permissions
************************************/

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sg-BBG-DWH-BusAnalysts-PROD'
)
BEGIN
	CREATE USER [sg-BBG-DWH-BusAnalysts-PROD] FROM EXTERNAL PROVIDER;
END


IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sp-BBG-DWH-DIOCT'
)
BEGIN
	CREATE USER [sp-BBG-DWH-DIOCT] FROM EXTERNAL PROVIDER;

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sp-BBG-DWH-PPCAuto'
)
BEGIN
	CREATE USER [sp-BBG-DWH-PPCAuto] FROM EXTERNAL PROVIDER;

END


EXEC sp_addrolemember N'rl_ex_reader', N'sp-BBG-DWH-PPCAuto'

GRANT SELECT ON EX.EX_V_ITEM TO sp-BBG-DWH-PPCAuto;



------------------------------------------------------
-- BAINE USER PERMISSIONS
-------------------------------------------------------
		CREATE USER [m.zhou.extern@go-bbg.com] FROM EXTERNAL PROVIDER;


	GRANT SELECT ON SCHEMA::L0 TO [m.zhou.extern@go-bbg.com];

	GRANT SELECT ON PL.PL_V_AMAZON_PERFORMANCE_METRICS TO [m.zhou.extern@go-bbg.com]
	GRANT SELECT ON L1.L1_FACT_A_SALES_TRANSACTION_KPI TO [m.zhou.extern@go-bbg.com]
	GRANT SELECT ON L1.L1_DIM_A_SALES_TRANSACTION_TYPE TO [m.zhou.extern@go-bbg.com]
	GRANT SELECT ON L1.L1_DIM_A_SALES_CHANNEL TO [m.zhou.extern@go-bbg.com]
	
	GRANT SELECT ON [L1].[L1_FACT_F_AMAZON_PRODUCT_DETAIL] TO [m.zhou.extern@go-bbg.com]
	GRANT SELECT ON L1.L1_FACT_A_AMAZON_SALES_TRAFFIC TO [m.zhou.extern@go-bbg.com]
	
	GRANT SELECT ON L1.L1_FACT_A_AMAZON_ITEM_ATTRIBUTION TO [m.zhou.extern@go-bbg.com]
	GRANT SELECT ON L1.L1_DIM_A_MARKETING_ACCOUNT TO [m.zhou.extern@go-bbg.com]
	GRANT SELECT ON L1.L1_DIM_A_ITEM TO [m.zhou.extern@go-bbg.com]
	GRANT SELECT ON L1.L1_FACT_A_COUNTRY_VAT TO [m.zhou.extern@go-bbg.com]
	GRANT SELECT ON L1.L1_FACT_A_AMAZON_SALES_TRAFFIC TO [m.zhou.extern@go-bbg.com]
	GRANT SELECT ON L1.L1_FACT_A_AMAZON_SALES_TRAFFIC TO [m.zhou.extern@go-bbg.com]


	EXEC sp_addrolemember N'largerc', N'sg-BBG-DWH-DataEngineers-PROD'
