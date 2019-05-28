-- convert_timezone
create function convert_timezone(
    in_tzname text,
    out_tzname text,
    in_t timestamptz
    ) returns timestamptz
as $$
declare
begin
  return in_t at time zone out_tzname at time zone in_tzname;
end;
$$ language plpgsql;

-- datediff
create or replace function datediff(
    units varchar(30),
    start_t timestamp,
    end_t timestamp) returns int
as $$
declare
    diff_interval interval; 
    diff int = 0;
    years_diff int = 0;
begin
    if units in ('yy', 'yyyy', 'year', 'mm', 'm', 'month') then
        years_diff = date_part('year', end_t) - date_part('year', start_t);

        if units in ('yy', 'yyyy', 'year') then
            -- sql server does not count full years passed (only difference between year parts)
            return years_diff;
        else
            -- if end month is less than start month it will subtracted
            return years_diff * 12 + (date_part('month', end_t) - date_part('month', start_t)); 
        end if;
    end if;

    -- Minus operator returns interval 'DDD days HH:MI:SS'  
    diff_interval = end_t - start_t;

    diff = diff + date_part('day', diff_interval);

    if units in ('wk', 'ww', 'week') then
        diff = diff/7;
        return diff;
    end if;

    if units in ('dd', 'd', 'day') then
        return diff;
    end if;

    diff = diff * 24 + date_part('hour', diff_interval); 

    if units in ('hh', 'hour') then
        return diff;
    end if;

    diff = diff * 60 + date_part('minute', diff_interval);

    if units in ('mi', 'n', 'minute') then
        return diff;
    end if;

    diff = diff * 60 + date_part('second', diff_interval);

    return diff;
end;
$$ language plpgsql;