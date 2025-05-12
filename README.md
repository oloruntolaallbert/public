# public
Monitor ingestion
Operation
| where OperationCategory == "Ingestion"
| where TimeGenerated > ago(1h)
