Select distinct Source,1000 CompanyID,DocumentNo,TransactionDate

from pl.pl_v_sales_transactions
where transactiondate = '2025-05-28'
and ReasonForRejections = 'Sage Order'
and transactiontypeshort in ('ZAA','ZKE','ZAZ')



