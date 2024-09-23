select *
from my_db.ticker_history
where symbol = 'AAPL'
order by "date" desc
limit 10;