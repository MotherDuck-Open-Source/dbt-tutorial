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

# 8. Futher Reading

## Sharing Data in MotherDuck
In order to run a data warehouse in production with Motherduck, it is important to understand how "database sharing" works. You can [learn more here](https://motherduck.com/docs/key-tasks/sharing-data/managing-shares/).

## Arg_max() - Why is it so fast?

The short answer is that is it an implementation of [Radix sort](https://duckdb.org/2021/08/27/external-sorting.html#radix-sort). From Wikipedia:
> In computer science, radix sort is a non-comparative sorting algorithm. It avoids comparison by creating and distributing elements into buckets according to their radix.

## Other notes about DuckDB as a data warehouse

- [advanced dbt tips](https://docs.getdbt.com/docs/build/dbt-tips)