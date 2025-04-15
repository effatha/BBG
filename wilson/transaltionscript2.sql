IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '1.ReturnInspectionAction' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('1.ReturnInspectionAction'
           ,'Transferencia de mercancías a BBG-Stock'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '2.ReturnInspectionAction' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('2.ReturnInspectionAction'
           ,'No hay caso de uso ahora'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '3.ReturnInspectionAction' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('3.ReturnInspectionAction'
           ,'Sigue siendo propiedad del cliente.'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '4.ReturnInspectionAction' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('4.ReturnInspectionAction'
           ,'Artículo negro'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '1.ReturnInspectionCompensation' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('1.ReturnInspectionCompensation'
           ,'Reparar'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '2.ReturnInspectionCompensation' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('2.ReturnInspectionCompensation'
           ,'Reemplazo'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '3.ReturnInspectionCompensation' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('3.ReturnInspectionCompensation'
           ,'Reembolso'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
--------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '4.ReturnInspectionCompensation' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('4.ReturnInspectionCompensation'
           ,'Conjunto/Equipado (Compensación manual)'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '5.ReturnInspectionCompensation' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('5.ReturnInspectionCompensation'
           ,'Sin compensación'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------


IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '1.OnOffTest' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('1.OnOffTest'
           ,'Positivo'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '2.OnOffTest' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('2.OnOffTest'
           ,'Negativo'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------


IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '3.OnOffTest' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('3.OnOffTest'
           ,'No hecho'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '4.OnOffTest' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('4.OnOffTest'
           ,'No es necesario'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------


IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '1.TechnicalCheckResult' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('1.TechnicalCheckResult'
           ,'Defecto'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '2.TechnicalCheckResult' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('2.TechnicalCheckResult'
           ,'Sin defecto'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '3.TechnicalCheckResult' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('3.TechnicalCheckResult'
           ,'No marcado'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------


IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '1.RepairResult' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('1.RepairResult'
           ,'No reparado'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '2.RepairResult' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('2.RepairResult'
           ,'No procesado'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '3.RepairResult' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('3.RepairResult'
           ,'reparado'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------


IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '1.RefurbishResult' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('1.RefurbishResult'
           ,'No reformado'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------

IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '2.RefurbishResult' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('2.RefurbishResult'
           ,'No procesado'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END
-----------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM [dbo].[LocalizationRecords] 
    WHERE [Key] = '3.RefurbishResult' 
    AND [LocalizationCulture] = 'es-ES'
)
BEGIN
    INSERT INTO [dbo].[LocalizationRecords]
           ([Key]
           ,[Text]
           ,[LocalizationCulture]
           ,[ResourceKey]
           ,[UpdatedTimestamp])
     VALUES
           ('3.RefurbishResult'
           ,'Renovar'
           ,'es-ES'
           ,'Wilson.Api.Resources.LookupResource'
           ,GETDATE())
END