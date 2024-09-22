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

# 4. Handling race conditions

The models as built thus far can run into race conditions where files are added or removed from the s3 bucket during exection. We can reduce the likelihood of this type of failure by materializing our list of files. While this does not prevent deletion of files from impacting our `dbt run`, it importantly will make sure that no new files are injected into our dbt process.

The data flow will look like this:

![Data Flow](img/data_flow.png)

Because we are materializing our list of files, we can be a bit more sophisticated with how we pass this file inventory into our dbt models, for example, we can now categorize our files and persist some meta-data, like modified timestamps. While typically files in object storage are treated as write once, if the file timestamp updates, we may also want to handle that as an incremental update.

```{admonition} Exercise 4.1
Build a dbt model that gets all files from an s3 path, applies some categorization, and persists the timestamp.
```

## Referencing our files model from our other models

Now that we have a list of files with some meta-data, we can re-implement our models that are load data from S3 to be fully incremental. In order to do this, we want to:

1. Create a list of all files that match certain meta-data filters in a `pre_hook`.
2. Pass that list to a `read_csv()` function so that DuckDB knows which files to process.
3. Make sure the `is_incremental` bits and the `unique_key` match your desired behavior.

### Pre-hooks in two sentences
In order to get the SQL variable `my_list` in the context for the subsequent query, we have to also invoke it with a [`pre_hook`](https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook). A `pre_hook` is simply a SQL statement that is executed before the model runs, while a `post_hook` runs immediately after. 

```{admonition} Exercise 4.2
Update all of your raw models to build incrementally.
```