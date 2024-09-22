select
    "file",
    case
        when "file" like '%/option_%' then 'stock'
        when "file" like '%/ticker_history_%' then 'price'
        when "file" like '%/ticker_info_%' then 'info'
        else 'unknown'
    end as entity,
    strptime(regexp_extract("file", '_(\d+)\.csv', 1), '%Y%m%d%H%M%S') as timestamp
from glob('s3://us-prd-motherduck-open-datasets/stocks/**/*')

-- alternative solution using read_blob to get timestamp

select
    "file",
    case
        when "file" like '%/option_%' then 'stock'
        when "file" like '%/ticker_history_%' then 'price'
        when "file" like '%/ticker_info_%' then 'info'
        else 'unknown'
    end as entity,
    meta_data.last_modified as last_modified_ts
from glob('s3://us-prd-motherduck-open-datasets/stocks/**/*') files
left join read_blob('s3://us-prd-motherduck-open-datasets/stocks/**/*') meta_data
    on meta_data."filename" = files."file"