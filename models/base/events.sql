select *
from snowplow.event
where domain_userid is not null
