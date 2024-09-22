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

# 2. Handling Duplicate Data

## The Inevitability of Duplicate Data

In any data warehouse, the presence of duplicate data is almost inevitable. This can occur due to various reasons, but that doesn't make it any less painful.

- **Data Integration**: When combining data from multiple sources, inconsistencies and overlaps can lead to duplicates.
- **REST API sources**: Many data sources don't allow for incremental updates, which means that every time you get new data, it difficult or impossible to handle it with creating duplicates.

## Ingesting Additional Data - with some duplicates

There is multiple datasets in the s3 bucket, partitioned by date. Unfortunately, these datasets are not incremental, so they must be loaded and then deduplicated. We can use the `glob()` function to get a list of files in the s3 bucket.

Thanks to some jupyter & duckdb magic, we can explore this data right in the notebook.

```{code-cell}
!pip install --upgrade duckdb magic-duckdb --quiet
%load_ext magic_duckdb
```

```{code-cell}
%%dql
select * 
from glob('s3://us-prd-motherduck-open-datasets/stocks/**/*.csv');
```

To create a dbt model with duplicates, we can use this same path, like this:

```sql
select *
from read_csv('s3://us-prd-motherduck-open-datasets/stocks/**/ticker_history_*.csv',
  filename = true)
```

We can now easily load data from multiple source files into MotherDuck!

```{admonition} Exercise 2.1
Update at least one model to pull in even more data from s3.

hint: consider this type of pattern in your read_csv: stocks/**/ticker_history_*.csv
```

## De-duping with a window function

There is some temptation to handle this de-duplication in this stage. Instead lets add another folder called `prep` that handles the deduplication.

Inside this folder, add a new model called `prep_{my_model}.sql`. We can use a traditional de-duplication method here - window functions.

Most Modern OLAP databases support `QUALIFY`, which is SQL Syntax sugar that allows you to filter the results of a window function directly in the query. This can be particularly useful for de-duplication. Here is an example of how you might use `QUALIFY` to remove duplicates:

```sql
SELECT
  *,
  ROW_NUMBER() OVER (PARTITION BY unique_key ORDER BY created_at DESC) AS row_num
FROM
  raw_data
QUALIFY
  row_num = 1;
```

In this example, we partition the data by a unique key and order it by a timestamp. The `ROW_NUMBER()` function assigns a unique number to each row within the partition, starting at 1 for the most recent entry. The `QUALIFY` clause then filters the results to include only the first row in each partition, effectively removing duplicates.

## A better way to De-duplicate data: ARG_MAX()

DuckDB contains a function called [ARG_MAX()](https://duckdb.org/docs/sql/functions/aggregates.html#arg_maxarg-val), which allows users to pass a table reference and a numeric column (including dates & timestamps) and returns a single row as a [`STRUCT`](https://www.w3schools.com/c/c_structs.php). Since it returns this datatype, we have to also use [`UNNEST()`](https://duckdb.org/docs/sql/query_syntax/unnest.html) in order to get a single row from the `ARG_MAX()` function.

```{admonition} Exercise 2.2
Implement ARG_MAX() on top of your models in the `prep` folder.

hint: you will need to find a way to get the timestamp from the filename (or use the `read_blob()` function to enrich your dataset.)
```

```{admonition} Exercise 2.3
Add dbt tests to your `schema.yml` file that tests for uniqueness on each model.
```

