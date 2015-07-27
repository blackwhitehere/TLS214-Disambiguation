use patstat
go

select count(*)
from evaluated_patterns as a
where
(
a.bibliographic_type is not null
or (a.pages_start is not null and a.issue is not null and a.volume is not null and d_year is not null and d_month is not null)
or (a.pages_start is not null and (a.issn is not null or a.isbn is not null))
or ((a.aetal is not null or a.name is not null) and a.volume is not null and a.issue is not null)
or ((a.aetal is not null or a.name is not null) and a.pages_start is not null and a.d_year is not null and a.d_month is not null)
or (a.sum_of_numbers is not null and a.count_of_numbers is not null and a.d_year is not null and a.d_month is not null)
or (a.xp_number is not null or a.url is not null)
)
and (a.useless is null and a.useless2 is null)
--5% with label rules