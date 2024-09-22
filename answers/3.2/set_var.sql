SET VARIABLE my_files = (select ARRAY_AGG(file)
from glob('s3://us-prd-motherduck-open-datasets/stocks/**/*'));

-- simple list
SELECT getvariable('my_files');

-- return column
SELECT UNNEST(getvariable('my_files'));