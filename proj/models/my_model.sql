select *
from {{ source('my_new_csv','my_new_csv') }}