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

A sample of this dataset can be found here.
```{code-cell}
%%dql
FROM 's3://us-prd-motherduck-open-datasets/stocks/ticker_history_20240920085944.csv' limit 10;
```

## Using ReadCSV and set Parameters

Duckdb contains a function for ReadCSV with some params

## Models in dbt

SQL queries in dbt are called "models". 

## Reading other file types

In addition to reading CSV files, DuckDB can read many other file types:
- JSON
- Parquet
- Delta
- Iceberg

It can also read list of files and file meta-data with the `glob()` and [`read_text()`](https://duckdb.org/docs/guides/file_formats/read_file) functions.

## Exercise - build your own dbt model

You can add a model to dbt in your `/models/raw` folder. Create a new file called `{my_file}.sql`.

```sql
select * from read_csv('s3//:{blablah}/my_file_*.csv', filename = true)
```

Once you have added the model, we have a couple options here.
1. Press `Cmd+Enter` to run the file against motherduck. (Ctrl+Enter on Windows)
2. Run the same query in duckdb CLI or MotherDuck UI.
   
Now that your model is confirmed as runnable, you can run `dbt build` from your terminal.

Once this has been completed, check back into the MotherDuck UI - you should see your model. You can then run a simple select against it - `select * from my_model`.