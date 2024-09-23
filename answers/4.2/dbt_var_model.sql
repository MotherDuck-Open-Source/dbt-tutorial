{{
    config(
        pre_hook="""
            SET VARIABLE my_files = (
                select ARRAY_AGG(file)
                from glob('s3://us-prd-motherduck-open-datasets/stocks/**/*') )
        """
    )
}}

SELECT UNNEST(getvariable('my_files')) AS files
