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

# 4. Handling even larger data sets

So far in this workshop, every `dbt build` would rebuild all models from S3 from the underlying data. While this is fine for very small data sets, length of time it takes to run any suitable large model (say in the range of a few million rows) across hundreds or thousands of files. How do we make this _just work_?

## dbt incremental materializations

dbt has the notion of "Incremental Materailizations" - models that are handled in a different flow and require more explicit definition, and thus can be built incrementally.

1. Incremental models usually require a `unique_key`, if no key is provided, the model is treated as "append only". 
2. Incremental models must define which pieces of the model run incrementally.

When invoked in normal `dbt build` or `dbt run`, incremental models will do the following:

1. Insert new data into a temp table based on the defined increment.
2. Delete any data from the existing model that matches the `unique_key` defined in the `config` block.
3. Insert data from the temp table into the existing model.

This obviously means that changes to the schema of your model need to be carefully considered - new columns mean that the model must be rebuilt entirely. A rebuild of the model is called a "full refresh" in dbt can be invoked with the `full-refresh` flag in the CLI. 

You can read more about this in the [dbt docs](https://docs.getdbt.com/docs/build/incremental-models#configure-incremental-materializations).

## Example of incremental materialization

In the previous example, we pulled a list of files from S3 and returned it as a list. Using this same method, we can pass that list to a `read_csv()` function and ingest all of those files. We can then use that in CTE (or sub-query) to filter our data set for incremental loading.

```sql
SET VARIABLE my_list =
    select array_agg(*)
    from glob(3://us-prd-motherduck-open-datasets/stocks/**/ticker_history_*.csv);
```

Then we can use that list in sql query.

```sql
select *
from read_csv(getvariable('my_list'), filename = true) as model
{% if is_incremental() %}
    where model.filename 
        not in (select distinct filename 
            from {{ this }} )
{% endif %}
```

This also introduces the concept of `{{ this }}`, which is a dbt relation and allows us to reference the the current model.

The full model, including the config, looks something like this:

```sql
{{
    config(
        materialized="incremental",
        unique_key="id",
    )
}}

select
    info.symbol || '-' || info.filename as id,
    info.*,
    now() at time zone 'UTC' as updated_at
from read_csv('s3://us-prd-motherduck-open-datasets/stocks/**/ticker_info_*.csv',
    filename = true) as info
{% if is_incremental() %}
    where not exists (select 1 from {{ this }} ck where ck.filename = info.filename)
{% endif %}
```

```{admonition} Exercise 4.1
Update your model `ticker_info.sql` to be an incremental model instead.
```
