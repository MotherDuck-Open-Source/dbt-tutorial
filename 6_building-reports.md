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

# 6. Building Reports & Analytics

Now that we have a nice set of data, the next step is to create usable analytics. Ideally, if we have done enough work in the prep stage, doing the analysis that we want is fairly easy. dbt doesn't take a position in terms _how_ you should model your data, so approaches from Kimball or Inmon or others are all just fine. 

Regardless of how you think about how your data matures through your transformation layer, it is important to keep it well organized. In the case of this project, its recommended to create a `models/reporting` folder to keep your final analysis. As this matures, it can be split into domain specific areas, for example. Because dbt is so flexible, it less important to follow a prescribed pattern and more important to have a repeatable approach that scales as the analytics needs of your organization grows.

## Metrics?

We aren't going to spend much time talking about Metrics in this workshop. Obviously, solutions abound in this space! But it seems like market has not yet settled into what the pattern will be like here longer term. It is made more complex by the current BI market leaders (Salesforce/Tableau and Microsoft/Power BI) having their own suggested patterns for metrics! 

## Materialization in the reporting layer

In general, I've found it is better to do full table rebuilds in your final layer, although depending on the complexity of the data chain leading up to it, views can also be used. And of course, for particularly large tables, like events, you will often want to use views downstream of the "final", deduplicated table. That is to say, much of this "depends". It is made more complex by multiple query interfaces that can interact with your data warehouse. Ad-hoc reporting, vs canned BI interactions, vs BI tool caches, vs Data Applications, all have different considerations in terms of perfomance and acceptable latency to serve.

In this case, we are going to serve data into `plotly` and `dash`, and the data set is very small. So using views is totally fine to get nice performance in the serving layer.

```{admonition} Exercise 6.1
Inspect your dataset using the Column Explorer in the MotherDuck UI. Write a query of Market Cap over time by Company.

hint: Market Cap = Shares Outstanding X Stock Price
```

```{admonition} Exercise 6.2
Create a `reporting` area in your `models` folder and translate the previous query into a dbt model.
```