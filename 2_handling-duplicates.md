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

There is multiple datasets in the s3 bucket, partitioned by date fetched. Unfortunately, these datasets are not incremental, so they must be loaded and then deduplicated. Thankfully, DuckDB supports reading multiple files with "glob syntax". You can learn [more about it here](https://duckdb.org/docs/data/multiple_files/overview.html). We can use this "glob syntax" + the `glob()` function to get a list of files in the s3 bucket. The `glob()` function returns a list of files that match the specified pattern.

Thanks to some jupyter & duckdb magic, we can explore this data right in the notebook.

```{code-cell}
!pip install --upgrade duckdb magic-duckdb --quiet
%load_ext magic_duckdb
```

```{code-cell}
%%dql
select * 
from glob('s3://us-prd-motherduck-open-datasets/stocks/**/ticker_info*.csv');
```

Armed with this knowledge, we can use this same path pattern to create a model that loads all in all of `ticker_history`, with some duplication:

```sql
select *
from read_csv('s3://us-prd-motherduck-open-datasets/stocks/**/ticker_history_*.csv',
  filename = true)
```

We can now easily load data from multiple source files into MotherDuck!

```{admonition} Exercise 2.1
Update your dbt models to pull in even more data using the glob syntax and add the filename as column.

Hint: consider this type of pattern in your read_csv: stocks/**/ticker_history_*.csv
```

## Linking models with dbt ref

One of the core dbt abstraction is [`ref`](https://docs.getdbt.com/reference/dbt-jinja-functions/ref). This function allows you to dynmically link models together. You can do this very simply, for example:

```sql
select * from {{ ref( "option_history" ) }}
```

This simple bit of linking means that:
1. "option history" will run before this query.
2. we can define materialization at the model level, which can really matter for performance.

## De-duping with a window function

There is some temptation to handle this de-duplication in this stage. Instead lets add another folder in your `modules` folder called `prep` that handles the deduplication.

Inside this folder, add a new model called `prep_ticker_info.sql`. We can use a traditional de-duplication method here - window functions.

Most Modern OLAP databases support `QUALIFY`, which is SQL Syntax sugar that allows you to filter the results of a window function directly in the query. This can be particularly useful for de-duplication. Here is an example of how you might use `QUALIFY` to remove duplicates:

```sql
SELECT
  *,
  ROW_NUMBER() OVER (PARTITION BY symbol ORDER BY "filename" DESC) AS row_num
FROM
  ticker_info
QUALIFY
  row_num = 1;
```

In this example, we partition the data by a unique key and order it by a timestamp. The `ROW_NUMBER()` function assigns a unique number to each row within the partition, starting at 1 for the most recent entry. The `QUALIFY` clause then filters the results to include only the first row in each partition, effectively removing duplicates.

## A better way to De-duplicate data: ARG_MAX()

DuckDB contains a function called [ARG_MAX()](https://duckdb.org/docs/sql/functions/aggregates.html#arg_maxarg-val), which allows users to pass a table reference and a numeric column (including dates & timestamps) and returns a single row as a [`STRUCT`](https://www.w3schools.com/c/c_structs.php). Since it returns this datatype, we have to also use [`UNNEST()`](https://duckdb.org/docs/sql/query_syntax/unnest.html) in order to get a single row from the `ARG_MAX()` function.

## Why is ARG_MAX() so fast?

The short answer is that ARG_MAX() uses Radix sort, which leverages SQL `group by` to identify the groups in which to find the max. The time complexity of Radix sort is _O (n k)_, where as comparison- based sorting algorithms have _O (n_ log _n)_ time complexity. 

```{admonition} Exercise 2.2
Implement ARG_MAX() on top of your models in the `prep` folder.

As a starter, here is a runable query from the MotherDuck UI (or CLI):
select UNNEST(ARG_MAX(ticker_history,"filename")) 
from (select *
from read_csv('s3://us-prd-motherduck-open-datasets/stocks/**/ticker_history_*.csv',
    filename = true)) as ticker_history
group by symbol, "date";
```

## Enforcing Uniqueness

In OLTP databases, we can enforce uniquness with `constraints` such as Primary Key. In OLAP, this behavior is often undesired, since we are often versioning records over time, or treating tables as append only (among other use cases). dbt has built functionality called ["data tests"](https://docs.getdbt.com/docs/build/data-tests) which allow us to check certain conditions after a model is built. There are is handful of out-of-the-box tests, including `unique` which assures the count of each key in a dataset is 1. By default, these tests fail if more than 0 rows are returned in the test query. These tests interact with a the DAG generated by dbt in a few ways.
- When running `dbt build`, failed tests will skip any downstream models.
- When running `dbt run`, tests are ignored. (Editor's note: I prefer not to use `dbt run` as a result but it can be unavoidable in larger DAGs)
- When running `dbt test`, only the tests are invoked.

Tests can be added in various ways, but the easiest way to get started with them is to create a `schema.yml` file that contains table definitions, which is a great place to also add tests. See the example below.

```yaml
version: 2

models:
  - name: prep_ticker_info
    columns:
      - name: symbol
        data_tests:
          - unique
```

```{admonition} Exercise 2.3
Add dbt tests to your `schema.yml` file that tests for uniqueness on each model.
```
