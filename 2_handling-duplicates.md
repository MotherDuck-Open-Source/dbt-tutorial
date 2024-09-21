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

we can get add duplicates by updating our file path to X.

```sql
select * from read_csv(dupes)
```

Now our raw model has duplicates in it! There is some temptation to handle this de-duplication in this stage. Instead lets add another folder called `prep` that handles the deduplication.

Inside this folder, add a new model called `prep_{my_model}.sql`. We can use a traditional de-duplication method here - window functions.

```{admonition} Exercise 2.1
Create a `prep` folder and update at least one model to pull in even more data from s3.
```

## De-duping with a window function

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

DuckDB contains a function called [ARG_MAX()](https://duckdb.org/docs/sql/functions/aggregates.html#arg_maxarg-val), which allows users to pass a table reference and a numeric column (including dates & timestamps) and returns a single row as a `STRUCT`. Since it returns this datatype, we have to also use `UNNEST()` in 

```{admonition} Exercise 2.2
Implement ARG_MAX() on top of your models in the `prep` folder
```

