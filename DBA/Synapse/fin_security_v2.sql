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
BEFORE:

UserName							type_desc	RoleName
aa-bbg-weu-dwh-prd-01				EXTERNAL_USER	db_datareader
bbgdwhdatamodeler					SQL_USER	db_ddladmin
dbo	SQL_USER						db_owner
pview-bbg-weu-dwh-dev-01			EXTERNAL_USER	db_datareader
sg-BBG-DWH-DataAnalysts-DEV			EXTERNAL_GROUP	db_datareader
sg-BBG-DWH-DataAnalysts-DEV			EXTERNAL_GROUP	db_datawriter
sg-BBG-DWH-DataEngineers-DEV		EXTERNAL_GROUP	db_datareader
sg-BBG-DWH-DataEngineers-DEV		EXTERNAL_GROUP	db_datawriter
sg-BBG-DWH-DataEngineers-DEV		EXTERNAL_GROUP	db_owner
sg-BBG-DWH-PBIAnalysts-DEV			EXTERNAL_GROUP	db_datareader
sg-BBG-DWH-Users					EXTERNAL_GROUP	db_datareader
synw-bbg-dwh-sql-deploy@go-bbg.com	EXTERNAL_USER	db_owner
synw-bbg-dwh-weu-dev-01				EXTERNAL_USER	db_exporter
synw-sql-login-dev					SQL_USER	db_datawriter
synw-sql-login-dev					SQL_USER	xlargerc
****************************************************************************************/

/************************************
** Remove access
************************************/
	EXEC sp_droprolemember  N'db_datawriter', N'sg-BBG-DWH-DataAnalysts-DEV'
	EXEC sp_droprolemember  N'db_datawriter', N'sg-BBG-DWH-DataEngineers-DEV'
	EXEC sp_droprolemember  N'db_datawriter', N'synw-sql-login-dev'

	EXEC sp_droprolemember  N'db_datareader', N'sg-BBG-DWH-DataAnalysts-DEV'
	EXEC sp_droprolemember  N'db_datareader', N'sg-BBG-DWH-DataEngineers-DEV'
	EXEC sp_droprolemember  N'db_datareader', N'sg-BBG-DWH-PBIAnalysts-DEV'
	EXEC sp_droprolemember  N'db_datareader', N'sg-BBG-DWH-Users'

	EXEC sp_droprolemember  N'xlargerc', N'synw-sql-login-dev'
	EXEC sp_droprolemember  N'db_owner', N'sg-BBG-DWH-DataEngineers-DEV'

	EXEC sp_droprolemember  N'db_ddladmin', N'bbgdwhdatamodeler'
	EXEC sp_droprolemember  N'db_datareader', N'sg-BBG-DWH-Users'


IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sg-BBG-DWH-DataAnalysts-DEV-Fin'
)
BEGIN
	CREATE USER [sg-BBG-DWH-DataAnalysts-DEV-Fin] FROM EXTERNAL PROVIDER;
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
	EXEC sp_addrolemember N'rl_l0_reader', N'sg-BBG-DWH-DataEngineers-DEV'
	EXEC sp_addrolemember N'rl_l0_reader', N'sg-BBG-DWH-DataAnalysts-DEV'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_l1_reader'
)
BEGIN
	CREATE ROLE rl_l1_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::L1 TO rl_l1_reader;
	EXEC sp_addrolemember N'rl_l1_reader', N'sg-BBG-DWH-DataEngineers-DEV'
	EXEC sp_addrolemember N'rl_l1_reader', N'sg-BBG-DWH-DataAnalysts-DEV'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_pl_reader'
)
BEGIN
	CREATE ROLE rl_pl_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::PL TO rl_pl_reader;
	EXEC sp_addrolemember N'rl_pl_reader', N'sg-BBG-DWH-DataEngineers-DEV'
	EXEC sp_addrolemember N'rl_pl_reader', N'sg-BBG-DWH-DataAnalysts-DEV'
	EXEC sp_addrolemember N'rl_pl_reader', N'sg-BBG-DWH-PBIAnalysts-DEV'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_ex_reader'
)
BEGIN
	CREATE ROLE rl_ex_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::EX TO rl_ex_reader;
	EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-DataEngineers-DEV'
	EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-DataAnalysts-DEV'
	EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-PBIAnalysts-DEV'
	EXEC sp_addrolemember N'rl_ex_reader', N'sg-BBG-DWH-DataScientists-DEV'

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
	EXEC sp_addrolemember N'rl_l0_fin_reader', N'sg-BBG-DWH-DataEngineers-DEV-Fin'
	EXEC sp_addrolemember N'rl_l0_fin_reader', N'sg-BBG-DWH-DataAnalysts-DEV-Fin'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_l1_fin_reader'
)
BEGIN
	CREATE ROLE rl_l1_fin_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::L1_FIN TO rl_l1_fin_reader;
	EXEC sp_addrolemember N'rl_l1_fin_reader', N'sg-BBG-DWH-DataEngineers-DEV-Fin'
--	EXEC sp_addrolemember N'rl_l1_fin_reader', N'sg-BBG-DWH-DataAnalysts-DEV-Fin'

END

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_pl_fin_reader'
)
BEGIN
	CREATE ROLE rl_pl_fin_reader AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::PL_FIN TO rl_pl_fin_reader;
	EXEC sp_addrolemember N'rl_pl_fin_reader', N'sg-BBG-DWH-DataEngineers-DEV-Fin'
--	EXEC sp_addrolemember N'rl_pl_fin_reader', N'sg-BBG-DWH-DataAnalysts-DEV-Fin'
--	EXEC sp_addrolemember N'rl_pl_fin_reader', N'sg-BBG-DWH-PBIAnalysts-DEV-Fin'

END




/***********************************
** TEST
************************************/
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rl_test_writer'
)
BEGIN
	CREATE ROLE rl_test_writer AUTHORIZATION [dbo];
	ALTER AUTHORIZATION ON SCHEMA::TEST to rl_test_writer;

	GRANT SELECT ON SCHEMA::TEST TO rl_test_writer;
	GRANT CREATE TABLE, CREATE VIEW, CREATE PROCEDURE TO rl_test_writer;
	EXEC sp_addrolemember N'rl_test_writer', N'sg-BBG-DWH-DataEngineers-DEV'
	EXEC sp_addrolemember N'rl_test_writer', N'sg-BBG-DWH-PBIAnalysts-DEV'

END








