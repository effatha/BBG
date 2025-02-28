/***************************************************************************************************
** Security Model: Create a database role per schema and assign it to each AD group needed/ approved
****************************************************************************************************/
DECLARE @enviroment


		rl_l0_reader (includes l0 and wr)
		rl_l1_reader
		rl_pl_reader
		rl_ex_reader
		rl_l0_fin_reader
		rl_l1_fin_reader
		rl_pl_fin_reader
		rl_test_write
CREATE TABLE #Roles
AS
(
	DBRole nvarchar(10),
	SchemaName nvarchar(50)
)

INSERT INTO #Roles(DBRole,SchemaName)
SELECT 'rl_l0_reader','L0'
UNION
SELECT 'rl_l0_reader','WR'
UNION
SELECT 'rl_l1_reader','L1'
UNION
SELECT 'rl_pl_reader','PL'
UNION
SELECT 'rl_ex_reader','EX'
UNION
SELECT 'rl_l0_fin_reader','L0'
UNION
SELECT 'rl_l0_fin_reader','WR'
UNION
SELECT 'rl_l1_fin_reader','L1'
UNION
SELECT 'rl_pl_fin_reader','PL'
