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
		rl_test_write

	AD Groups
	-- sg-BBG-DWH-DataAnalysts-DEV        | rl_l0_reader;rl_l1_reader;rl_pl_reader;rl_ex_reader
	-- sg-BBG-DWH-DataEngineers-DEV		  | rl_l0_reader;rl_l1_reader;rl_pl_reader;rl_ex_reader
	-- sg-BBG-DWH-DataScientists-DEV	  | only Data lake?? maybe export layer rl_ex_reader
	-- sg-BBG-DWH-PBIAnalysts-DEV		  | rl_pl_reader; rl_ex_reader

	-- sg-BBG-DWH-DataAnalysts-DEV-Fin    | rl_l0_fin_reader;rl_l1_fin_reader;rl_pl_fin_reader;rl_ex_fin_reader  
	-- sg-BBG-DWH-DataEngineers-DEV-Fin   | rl_l0_fin_reader;rl_l1_fin_reader;rl_pl_fin_reader;rl_ex_fin_reader  
	-- sg-BBG-DWH-DataScientists-DEV-Fin  | only Data lake?? 
	-- sg-BBG-DWH-PBIAnalysts-DEV-Fin	  | rl_pl_fin_reader



	Notes:
		-  Currently permissions will be reset; (sg-BBG-DWH-DataEngineers-DEV no longer have access to all schemas by default) 
		-  No write permissions for these AD groups (except test schema in dev; in QA and prod there will be no test schema)

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
sg-BBG-DWH-DataAnalysts-PROD	EXTERNAL_GROUP	db_datareader
sg-BBG-DWH-DataEngineers-PROD	EXTERNAL_GROUP	db_datareader
sg-BBG-DWH-DataEngineers-PROD	EXTERNAL_GROUP	db_datawriter
sg-BBG-DWH-PBIAnalysts-PROD	EXTERNAL_GROUP	db_datareader
svc-pbi-reader-prod@go-bbg.com	EXTERNAL_USER	dq_reader
svc-pbi-reader-prod@go-bbg.com	EXTERNAL_USER	l1_reader
svc-pbi-reader-prod@go-bbg.com	EXTERNAL_USER	mediumrc
svc-pbi-reader-prod@go-bbg.com	EXTERNAL_USER	pl_reader
synw-bbg-dwh-sql-deploy@go-bbg.com	EXTERNAL_USER	db_owner

****************************************************************************************/

/************************************
** Remove access
************************************/
	EXEC sp_droprolemember  N'db_datareader', N'sg-BBG-DWH-DataAnalysts-QA'
	EXEC sp_droprolemember  N'db_datawriter', N'sg-BBG-DWH-DataAnalysts-QA'
	EXEC sp_droprolemember  N'db_datareader', N'sg-BBG-DWH-DataEngineers-QA'
	EXEC sp_droprolemember  N'db_datawriter', N'sg-BBG-DWH-DataEngineers-QA'
	EXEC sp_droprolemember  N'db_datareader', N'sg-BBG-DWH-PBIAnalysts-QA'
	EXEC sp_droprolemember  N'db_datareader', N'sg-BBG-DWH-Users'
	EXEC sp_droprolemember  N'xlargerc', N'sql-bbg-dwh-syndpbbgdwh01-qa'



IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sg-BBG-DWH-DataAnalysts-QA-Fin'
)
BEGIN
	CREATE USER [sg-BBG-DWH-DataAnalysts-QA-Fin] FROM EXTERNAL PROVIDER;
END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sg-BBG-DWH-DataEngineers-QA-Fin'
)
BEGIN
	CREATE USER [sg-BBG-DWH-DataEngineers-QA-Fin] FROM EXTERNAL PROVIDER;
END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sg-BBG-DWH-PBIAnalysts-QA-Fin'
)
BEGIN
	CREATE USER [sg-BBG-DWH-PBIAnalysts-QA-Fin] FROM EXTERNAL PROVIDER;
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
	GRANT INSERT ON SCHEMA::MD TO rl_l0_reader;
	GRANT UPDATE ON SCHEMA::MD TO rl_l0_reader;
	GRANT EXECUTE ON SCHEMA::WR TO rl_l0_reader;
	GRANT DELETE ON SCHEMA::MD TO rl_l0_reader;
	GRANT DELETE ON SCHEMA::WR TO rl_l0_reader;
	GRANT INSERT ON SCHEMA::WR TO rl_l0_reader;
	GRANT UPDATE ON SCHEMA::WR TO rl_l0_reader;


	EXEC sp_addrolemember N'rl_l0_reader', N'sg-BBG-DWH-DataEngineers-QA'
	EXEC sp_addrolemember N'rl_l0_reader', N'sg-BBG-DWH-DataAnalysts-QA'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_l1_reader'
)
BEGIN
	CREATE ROLE rl_l1_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::L1 TO rl_l1_reader;
	GRANT EXECUTE ON SCHEMA::L1 TO rl_l1_reader;
	GRANT DELETE ON SCHEMA::L1 TO rl_l0_reader;
	GRANT INSERT ON SCHEMA::L1 TO rl_l0_reader;
	GRANT UPDATE ON SCHEMA::L1 TO rl_l0_reader;

	EXEC sp_addrolemember N'rl_l1_reader', N'sg-BBG-DWH-DataEngineers-QA'
	EXEC sp_addrolemember N'rl_l1_reader', N'sg-BBG-DWH-DataAnalysts-QA'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_pl_reader'
)
BEGIN
	CREATE ROLE rl_pl_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::PL TO rl_pl_reader;
	EXEC sp_addrolemember N'rl_pl_reader', N'sg-BBG-DWH-DataEngineers-QA'
	EXEC sp_addrolemember N'rl_pl_reader', N'sg-BBG-DWH-DataAnalysts-QA'
	EXEC sp_addrolemember N'rl_pl_reader', N'sg-BBG-DWH-PBIAnalysts-QA'
	EXEC sp_addrolemember N'rl_pl_reader', N'sg-BBG-DWH-BusAnalysts-PROD'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_ex_reader'
)
BEGIN
	CREATE ROLE rl_ex_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::EX TO rl_ex_reader;
	--EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-DataEngineers-QA'
	--EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-DataAnalysts-QA'
	--EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-PBIAnalysts-QA'
	--EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-DataScientists-QA'
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
	EXEC sp_addrolemember N'rl_l0_fin_reader', N'sg-BBG-DWH-DataEngineers-QA-Fin'
	EXEC sp_addrolemember N'rl_l0_fin_reader', N'sg-BBG-DWH-DataAnalysts-QA-Fin'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_l1_fin_reader'
)
BEGIN
	CREATE ROLE rl_l1_fin_reader AUTHORIZATION [dbo];
	GRANT EXECUTE ON SCHEMA::L1_FIN TO rl_l1_fin_reader;
	EXEC sp_addrolemember N'rl_l1_fin_reader', N'sg-BBG-DWH-DataEngineers-QA-Fin'
	EXEC sp_addrolemember N'rl_l1_fin_reader', N'sg-BBG-DWH-DataAnalysts-QA-Fin'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_pl_fin_reader'
)
BEGIN
	CREATE ROLE rl_pl_fin_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::PL_FIN TO rl_pl_fin_reader;
	EXEC sp_addrolemember N'rl_pl_fin_reader', N'sg-BBG-DWH-DataEngineers-QA-Fin'
	EXEC sp_addrolemember N'rl_pl_fin_reader', N'sg-BBG-DWH-DataAnalysts-QA-Fin'
	EXEC sp_addrolemember N'rl_pl_fin_reader', N'sg-BBG-DWH-PBIAnalysts-QA-Fin'

END



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





---GRANT  SELECT, INSERT, UPDATE, DELETE  ON SCHEMA::WR_FIN TO rl_l1_fin_reader;