select UNNEST(ARG_MAX(ph,"filename")) 
from {{ ref( 'price_history')}} as ph
group by symbol, "date"


-- note: same query but runnable from CLI
/*
select UNNEST(ARG_MAX(ph,"filename")) 
from (select *
from read_csv('s3://us-prd-motherduck-open-datasets/stocks/**/ticker_history_*.csv',
    filename = true)) as ph
group by symbol, "date";
*/
