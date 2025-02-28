/**************************************************
** Check for the AD groups and ad them if not exists
**************************************************/

IF EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sg-BBG-DWH-Finance-Reader-DEV-L0'
)
BEGIN
	CREATE USER [sg-BBG-DWH-Finance-Reader-DEV-L0] FROM EXTERNAL PROVIDER;
END



IF EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sg-BBG-DWH-Finance-Reader-DEV-L1'
)
BEGIN
	CREATE USER [sg-BBG-DWH-Finance-Reader-DEV-L1] FROM EXTERNAL PROVIDER;
END


IF EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'sg-BBG-DWH-Finance-Reader-DEV-PL'
)
BEGIN
	CREATE USER [sg-BBG-DWH-Finance-Reader-DEV-PL] FROM EXTERNAL PROVIDER;
END

GO;

/**************************************************
** Check for the database roles for the fin schemas
**************************************************/
IF EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'fin_reader_l0'
)
BEGIN
	CREATE ROLE fin_reader_l0 AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::L0_FIN TO fin_reader_l0;
	GRANT SELECT ON SCHEMA::WR_FIN TO fin_reader_l0;
	EXEC sp_addrolemember N'fin_reader_l0', N'sg-BBG-DWH-Finance-Reader-DEV-L0'

END

IF EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'fin_reader_l1'
)
BEGIN
	CREATE ROLE fin_reader_l1 AUTHORIZATION [dbo]
	GRANT SELECT ON SCHEMA::L1_FIN TO fin_reader_l1
	EXEC sp_addrolemember N'fin_reader_l1', N'sg-BBG-DWH-Finance-Reader-DEV-L1'

END

IF EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'fin_reader_pl'
)
BEGIN
	CREATE ROLE fin_reader_pl AUTHORIZATION [dbo];
	GRANT SELECT ON SCHEMA::PL_FIN TO fin_reader_pl
	EXEC sp_addrolemember N'fin_reader_pl', N'sg-BBG-DWH-Finance-Reader-DEV-PL'

END


--revoke read permissions to other AD groups
REVOKE SELECT ON SCHEMA::L0_FIN TO [sg-BBG-DWH-DataEngineers-DEV]
REVOKE SELECT ON SCHEMA::L1_FIN TO [sg-BBG-DWH-DataEngineers-DEV]
REVOKE SELECT ON SCHEMA::PL_FIN TO [sg-BBG-DWH-DataEngineers-DEV]

REVOKE SELECT ON SCHEMA::L0_FIN TO [sg-BBG-DWH-DataScientists-DEV-Fin]
REVOKE SELECT ON SCHEMA::L1_FIN TO [sg-BBG-DWH-DataScientists-DEV-Fin]
REVOKE SELECT ON SCHEMA::PL_FIN TO [sg-BBG-DWH-DataScientists-DEV-Fin]

REVOKE SELECT ON SCHEMA::L0_FIN TO [sg-BBG-DWH-DataScientists-DEV]
REVOKE SELECT ON SCHEMA::L1_FIN TO [sg-BBG-DWH-DataScientists-DEV]
REVOKE SELECT ON SCHEMA::PL_FIN TO [sg-BBG-DWH-DataScientists-DEV]

REVOKE SELECT ON SCHEMA::L0_FIN TO [sg-BBG-DWH-DataAnalysts-DEV-Fin]
REVOKE SELECT ON SCHEMA::L1_FIN TO [sg-BBG-DWH-DataAnalysts-DEV-Fin]
REVOKE SELECT ON SCHEMA::PL_FIN TO [sg-BBG-DWH-DataAnalysts-DEV-Fin]

REVOKE SELECT ON SCHEMA::L0_FIN TO [sg-BBG-DWH-DataAnalysts-DEV]
REVOKE SELECT ON SCHEMA::L1_FIN TO [sg-BBG-DWH-DataAnalysts-DEV]
REVOKE SELECT ON SCHEMA::PL_FIN TO [sg-BBG-DWH-DataAnalysts-DEV]



-- sg-BBG-DWH-DataAnalysts-DEV-Fin
-- sg-BBG-DWH-DataEngineers-DEV-Fin
-- sg-BBG-DWH-DataEngineers-PROD-Fin
-- sg-BBG-DWH-DataScientists-PROD-Fin
-- sg-BBG-DWH-DataAnalysts-PROD-Fin
-- sg-BBG-DWH-PBIAnalysts-PROD-Fin



SELECT u.[name] AS [UserName],
       r.[name] AS RoleName 
FROM sys.database_principals u
     JOIN sys.database_role_members drm ON u.principal_id = drm.member_principal_id
     JOIN sys.database_principals r ON  drm.role_principal_id = r.principal_id
WHERE u.[type] IN ('S','U') --SQL User or Windows User


SELECT 
    USER_NAME(grantee_principal_id) AS 'User'
  , state_desc AS 'Permission'
  , permission_name AS 'Action'
  , CASE class
      WHEN 0 THEN 'Database::' + DB_NAME()
      WHEN 1 THEN OBJECT_NAME(major_id)
      WHEN 3 THEN 'Schema::' + SCHEMA_NAME(major_id) END AS 'Securable'
FROM sys.database_permissions dp
WHERE class IN (0, 1, 3)
AND minor_id = 0
and USER_NAME(grantee_principal_id) = 'sg-BBG-DWH-DataAnalysts-DEV'
 

 SELECT *,SCHEMA_NAME(major_id)
FROM sys.database_permissions
WHERE grantee_principal_id = DATABASE_PRINCIPAL_ID('sg-BBG-DWH-DataAnalysts-DEV')
 -- AND class_desc = 'SCHEMA'
  AND permission_name = 'SELECT';


