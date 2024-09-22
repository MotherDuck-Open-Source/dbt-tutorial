select *
from read_csv('s3://us-prd-motherduck-open-datasets/stocks/ticker_history_20240920085944.csv')
where symbol = 'AAPL'
order by "date" desc
limit 10;