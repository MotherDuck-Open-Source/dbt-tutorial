---
jupytext:
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.11.5
kernelspec:
  display_name: Python 3
  language: python
  name: python3
---

# 7. Adding interactive Data Viz

Now that we have a nice reporting data set, lets get this into a chart. There are obviously many ways to serve data into BI or data apps, but in the the spirit of using python, we will keep it pythonic with `ploty`. Of course, we can then create a webpage and spin that up into a webserver with `dash`.

## Passing data from MotherDuck into `plotly`

We can use DuckDB's python APIs to create a dataframe. This means we can simply use SQL to pass data into the front end.

```py
import os

# Get the secret and load it into python
load_dotenv()
MOTHERDUCK_TOKEN = os.getenv('MOTHERDUCK_TOKEN')

# Connect to DuckDB using the MotherDuck token
conn = duckdb.connect(f'md:?MOTHERDUCK_TOKEN={MOTHERDUCK_TOKEN}')

# query your database from python and return a data frame
market_cap_df = conn.execute(f'''
    SELECT Date, market_cap
    FROM stocks_dev.main.market_cap_by_day
    WHERE symbol = 'AAPL'
''').df()
```

Since the SQL interface is somewhat trivial, the rest of the work in python is to define the plots and then shape it into a little bit of HTML. 

An example script can be [found here](https://github.com/matsonj/stocks/blob/main/viz/line_chart.py).

I've built out a end-to-end repo that extracts, loads, de-duplicates, and models this dataset [over here](https://github.com/matsonj/stocks).

```{admonition} Extra Credit
Ship the result chart using GitHub pages. Then set up a GitHub action to run every 5 minutes and update with the latest stock price and publish the changes to your MotherDuck database.
```
