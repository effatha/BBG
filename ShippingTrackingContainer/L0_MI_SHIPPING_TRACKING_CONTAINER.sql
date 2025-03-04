:connect [synw-bbg-dwh-weu-dev-01.sql.azuresynapse.net]
USE syndpbbgdwh01;


CREATE TABLE L0.L0_MI_SHIPPING_TRACKING_CONTAINER
(
	[MONTH]   DATE,
    [CHANNELGROUP3]    VARCHAR(50),
	[MARKETINGRATE]     DECIMAL(19,4),
    [LOAD_TIMESTAMP]      datetime2
)
WITH (
    DISTRIBUTION = REPLICATE,
    HEAP
)