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

# 3. SQL Variables

## `VARIABLE` statements

DuckDB 1.1 has introduced a new set of features of around variables, which allows SQL-level variables. These variables can only be scalar values.
- Variables are set using `SET VARIABLE`.
- Variables are accesed with the `getvariable()` function.
- Variables are unset using `RESET VARIABLE`.

Consider how the following SQL statement would resolve:

```sql
SET VARIABLE today = (SELECT (NOW() AT TIME ZONE 'UTC')::date);

SELECT SUM(amount) as sales_amt
FROM fact_sales
WHERE sale_date = getvariable('today');

RESET VARIABLE today;
```

This is great functionality for passing single values between SQL statements without having to use `TEMP TABLES` or other SQL constructs. Unfortunately, because only scalar values are supported, we cannot store tables or even single columns with multiple values in a `VARIABLE`.

Unless?

## A single `STRUCT` is a scalar value

As you recall from the previous lessons, `STRUCT` type data supports many types of values in a single scalar value. This means we can pack whatever we want into a `STRUCT` and then save it as variable. You hopefully also recall that the `glob()` function returns a list of files. Unfortunately, this is list is a table so we cannot store it in a variable directly.

Fortunately for us, DuckDB also has a function called [`array_agg()`](https://duckdb.org/docs/sql/functions/aggregates.html#array_aggarg) that turns a single column into a `LIST`.  Of course, a `LIST` is closely related to a `STRUCT` and thus can be set as a variable in DuckDB.

```{admonition} Exercise 3.1
Use MotherDuck to get a list of all files in your S3 Bucket.
```

```{admonition} Exercise 3.2
Set the list from Exercise 3.1 as a variable, then print the list with a `SELECT` query.
```

