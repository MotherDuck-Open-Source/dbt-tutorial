select *
from read_csv('s3://us-prd-motherduck-open-datasets/stocks/**/ticker_history_*.csv',
    filename = true)