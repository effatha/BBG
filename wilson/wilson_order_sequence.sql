----------------------------------------------------------
--- CREATE ARCHIVE TABLE
----------------------------------------------------------

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = 'OrderItemSequence_Archive')
BEGIN
   
		CREATE TABLE [dbo].[OrderItemSequence_Archive](
			[Id] INT NOT NULL,
			[IsDeleted] [bit] NOT NULL,
			[CreatedOn] [datetime2](7) NOT NULL,
			[ModifiedOn] [datetime2](7) NULL,
			[CreatedBy] [nvarchar](max) NULL,
			[ModifiedBy] [nvarchar](max) NULL,
			[OrderId] [bigint] NOT NULL,
			[SapOrderId] [nvarchar](450) NULL,
			[ArticleNumber] [nvarchar](30) NULL,
			[ArticleDescription] [nvarchar](100) NULL,
			[UnitPriceGrossForeignCurrency] [decimal](18, 2) NOT NULL,
			[UnitPriceNetForeignCurrency] [decimal](18, 2) NOT NULL,
			[UnitPriceGrossLocalCurrency] [decimal](18, 2) NOT NULL,
			[UnitPriceNetLocalCurrency] [decimal](18, 2) NOT NULL,
			[SetKittingUnitPriceGrossForeignCurrency] [decimal](18, 2) NOT NULL,
			[SetKittingUnitPriceNetForeignCurrency] [decimal](18, 2) NOT NULL,
			[SetKittingUnitPriceGrossLocalCurrency] [decimal](18, 2) NOT NULL,
			[SetKittingUnitPriceNetLocalCurrency] [decimal](18, 2) NOT NULL,
			[TaxAmountForeignCurrency] [decimal](18, 4) NOT NULL,
			[TaxAmountLocalCurrency] [decimal](18, 2) NOT NULL,
			[Quantity] [int] NOT NULL,
			[Condition] [nvarchar](2) NULL,
			[ArticleReceivedSKU] [nvarchar](30) NULL,
			[EAN] [nvarchar](30) NULL,
			[MEK] [nvarchar](max) NULL,
			[OrderPosition] [nvarchar](10) NULL,
			[UePos] [nvarchar](10) NULL,
			ArchiveDate datetime2 not null default (getdate())
		)
END

----------------------------------------------------------
--- CREATE Store Procedure to move data to the archive table
----------------------------------------------------------
GO ;

IF OBJECT_ID('[dbo].[usp_ArchiveOrderItemSequence]', 'P') IS NULL
BEGIN


		CREATE PROCEDURE [dbo].[usp_ArchiveOrderItemSequence]
		AS
		BEGIN
		
		---declare the number of years for retention period for data in [usp_ArchiveOrderItemSequence]

		DECLARE @NUM_RETENTION_YEARS AS INT 
		SET @NUM_RETENTION_YEARS = 2

			-- Move data older than 2 years to the archive table
			INSERT INTO [dbo].[OrderItemSequence_Archive]
           (
				[Id]
			   ,[IsDeleted]
			   ,[CreatedOn]
			   ,[ModifiedOn]
			   ,[CreatedBy]
			   ,[ModifiedBy]
			   ,[OrderId]
			   ,[SapOrderId]
			   ,[ArticleNumber]
			   ,[ArticleDescription]
			   ,[UnitPriceGrossForeignCurrency]
			   ,[UnitPriceNetForeignCurrency]
			   ,[UnitPriceGrossLocalCurrency]
			   ,[UnitPriceNetLocalCurrency]
			   ,[SetKittingUnitPriceGrossForeignCurrency]
			   ,[SetKittingUnitPriceNetForeignCurrency]
			   ,[SetKittingUnitPriceGrossLocalCurrency]
			   ,[SetKittingUnitPriceNetLocalCurrency]
			   ,[TaxAmountForeignCurrency]
			   ,[TaxAmountLocalCurrency]
			   ,[Quantity]
			   ,[Condition]
			   ,[ArticleReceivedSKU]
			   ,[EAN]
			   ,[MEK]
			   ,[OrderPosition]
			   ,[UePos]
		   )
			SELECT [Id]
				   ,[IsDeleted]
				   ,[CreatedOn]
				   ,[ModifiedOn]
				   ,[CreatedBy]
				   ,[ModifiedBy]
				   ,[OrderId]
				   ,[SapOrderId]
				   ,[ArticleNumber]
				   ,[ArticleDescription]
				   ,[UnitPriceGrossForeignCurrency]
				   ,[UnitPriceNetForeignCurrency]
				   ,[UnitPriceGrossLocalCurrency]
				   ,[UnitPriceNetLocalCurrency]
				   ,[SetKittingUnitPriceGrossForeignCurrency]
				   ,[SetKittingUnitPriceNetForeignCurrency]
				   ,[SetKittingUnitPriceGrossLocalCurrency]
				   ,[SetKittingUnitPriceNetLocalCurrency]
				   ,[TaxAmountForeignCurrency]
				   ,[TaxAmountLocalCurrency]
				   ,[Quantity]
				   ,[Condition]
				   ,[ArticleReceivedSKU]
				   ,[EAN]
				   ,[MEK]
				   ,[OrderPosition]
				   ,[UePos]
			select count(*)
			FROM [dbo].[OrderItemSequence] with(nolock)
			WHERE [ModifiedOn] < '2024-01-01' DATEADD(YEAR,@NUM_RETENTION_YEARS, GETDATE());

			-- Delete the moved data from the main table
			--DELETE FROM [dbo].[OrderItemSequence]
			--WHERE [ModifiedOn] < DATEADD(YEAR, @NUM_RETENTION_YEARS, GETDATE());
		END;
END

----------------------------------------------------------
--- CREATE JOB
----------------------------------------------------------
GO ;


IF NOT EXISTS (
    SELECT 1 
    FROM msdb.dbo.sysjobs 
    WHERE name = 'ArchiveOrderItemSequenceJob'
)
BEGIN
-- Create the SQL Agent job to execute the stored procedure every month
	EXEC msdb.dbo.sp_add_job 
		@job_name = N'ArchiveOrderItemSequenceJob';

	EXEC msdb.dbo.sp_add_jobstep 
		@job_name = N'ArchiveOrderItemSequenceJob',
		@step_name = N'Execute Archive Procedure',
		@subsystem = N'TSQL',
		@command = N'EXEC [dbo].[usp_ArchiveOrderItemSequence]',
		@retry_attempts = 1,
		@retry_interval = 5;

	EXEC msdb.dbo.sp_add_schedule 
		@schedule_name = N'MonthlySchedule', 
		@freq_type = 8,  -- Monthly
		@freq_interval = 1,  -- Every month
		@active_start_time = 010000;  -- 1:00 AM

	EXEC msdb.dbo.sp_attach_schedule 
		@job_name = N'ArchiveOrderItemSequenceJob', 
		@schedule_name = N'MonthlySchedule';

	EXEC msdb.dbo.sp_add_jobserver 
		@job_name = N'ArchiveOrderItemSequenceJob';

END