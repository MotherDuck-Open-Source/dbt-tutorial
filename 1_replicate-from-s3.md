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

# 1. Replicating data into MotherDuck from S3

DuckDB supports reading/writing/globbing files on object storage servers using the S3 API. S3 offers a standard API to read and write to remote files. Furthermore, DuckDB & MotherDuck support Secrets in SQL, so that private buckets can be accessed directly from SQL. In the examples below, we will be using public S3 buckets. To learn more Secret Management, click [here](https://duckdb.org/docs/extensions/httpfs/s3api.html#config-provider).

```sql
SELECT *
FROM 's3://my-bucket/file.parquet';
```

For the purpose of this workshop, some sample datasets can be found `s3://us-prd-motherduck-open-datasets/stocks/`. 

```sql
select *
from read_csv('s3://us-prd-motherduck-open-datasets/stocks/ticker_history_20240920085944.csv')
limit 10;
```

## Using ReadCSV and set Parameters

Duckdb contains a set of [CSV functions](https://duckdb.org/docs/data/csv/overview#csv-functions) that are used to handle CSV files.

The `read_csv()` function automatically attempts to figure out the correct configuration of the CSV reader using the CSV sniffer. It also automatically deduces types of columns. If the CSV file has a header, it will use the names found in that header to name the columns. Otherwise, the columns will be named `column0, column1, column2, ...`.

Additionally, the `read_csv()` function supports some parameters that are useful for data pipelines as well. For the purpose of this tutorial, we will cover the following:
- `union_by_name` (default value `false`) which attempts to match column names across multiple CSVs.
- `filename` (default value `false`) which will add a column with the file name to the tabular data set returned in the `from` clause.

## Models in dbt

SQL queries in dbt are called "models". 

[From the dbt website](https://docs.getdbt.com/docs/build/models):

> Models are where your developers spend most of their time within a dbt environment. Models are primarily written as a `select` statement and saved as a `.sql` file. While the definition is straightforward, the complexity of the execution will vary from environment to environment. Models will be written and rewritten as needs evolve and your organization finds new ways to maximize efficiency.

## Reading other file types

In addition to reading CSV files, DuckDB can read [many other file types](https://duckdb.org/docs/guides/file_formats/overview):
- JSON
- Parquet
- Excel
- Postgres
- Sqlite
- Other DuckDB databases
- Delta
- Iceberg

It can also read list of files and file meta-data with the `glob()` and [`read_text()`](https://duckdb.org/docs/guides/file_formats/read_file) functions.

## Building your first dbt model

You can add a model to dbt in your `/models/raw` folder. Create a new file called `{my_file}.sql`.

```sql
select * from read_csv('s3//:{blablah}/my_file_*.csv', filename = true)
```

Once you have added the model, we have a couple options here.
1. Press `Cmd+Enter` to run the sql query against motherduck directly from vs code. (Ctrl+Enter on Windows)
2. Run the same query in duckdb CLI or MotherDuck UI.
   
Now that your model is confirmed as runnable, you can run `dbt build` from your terminal.

Once this has been completed, check back into the MotherDuck UI - you should see your model. You can then run a simple select against it - `select * from my_model`.

```{admonition} Exercise 1.1
Create a model for each file in the `stocks` S3 bucket.
```

```{admonition} Exercise 1.2
Write a query using MotherDuck to select the 10 latest rows in the `ticker_history` file for symbol AAPL.

**extra credit**: write the same query against your dbt models, instead of S3.
```