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

# 5. Handling race conditions

The models as built thus far can run into race conditions where files are added or removed from the s3 bucket during exection. We can reduce the likelihood of this type of failure by