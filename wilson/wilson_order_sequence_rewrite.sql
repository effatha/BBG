DECLARE @cnt INT = 0;
DECLARE @total INT = 0;
DECLARE @PageSize INT = 10000;
----------------------------------------------------------
--- DECLARE VARIABLE for handling the incremental uopdate (we can also store the last executed timestamp inna config table)
----------------------------------------------------------
Declare  @LastExecution as datetime2
SET @LastExecution = getdate()-1
DECLARE @OrderSequenceItems as TABLE (OrderSequenceItemID bigint )
----------------------------------------------------------
--- GET ALL ORDERITEMSEQUENCE NEEDED
----------------------------------------------------------

select @total=count(id)  from [dbo].[OrderItemSequence] with (nolock) Where IsDeleted=0

--first all the id's that were changed since last execution
INSERT INTO @OrderSequenceItems(OrderSequenceItemID)
SELECT id from [dbo].[OrderItemSequence] with (nolock) Where IsDeleted=0 and ModifiedOn>=@LastExecution


----------------------------------------------------------
--- UPDATE ORDERITEMSEQUENCE TABLE 
----------------------------------------------------------
update ois
	set OrderId=o.Id
from [Order] o 
Inner join OrderItemSequence ois on Ois.SapOrderId=o.OrderId
Inner join @OrderSequenceItems vois on Ois.id= vois.OrderSequenceItemID
where
	ISNULL(ois.OrderId,0) = 0
	AND
	ois.id in (select distinct OrderSequenceItemID from @OrderSequenceItems)