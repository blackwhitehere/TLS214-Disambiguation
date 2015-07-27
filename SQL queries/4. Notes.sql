--4. pages, volume, issue, month, year, similar length

if object_id('rule_4') is not null drop table rule_4
select distinct a.new_id as new_id1, b.new_id as new_id2, 700 as score
into rule_4
from evaluated_patterns as a
join evaluated_patterns as b on
	a.pages_start=b.pages_start
	and a.volume=b.volume
	and a.issue=b.issue
	and a.d_year=b.d_year
	and a.d_month=b.d_month
	and ((convert(decimal(10,4), a.b_length))/(convert(decimal(10,4),b.b_length)))>=0.8	
where a.new_id < b.new_id
except
(select c.new_id1,c.new_id2, 700 as score
from rule_A as c)
go

--1p bonus
if object_id('rule_0a') is not null drop table rule_0a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_0a
from evaluated_patterns as a
join evaluated_patterns as b on
	a.pages_start=b.pages_start
	or a.d_year=b.d_year
	or a.volume=b.volume
	or a.issue=b.issue
	or a.bibliographic_type=b.bibliographic_type
	or a.b_length=b.b_length
	or (a.count_of_numbers=b.count_of_numbers and a.count_of_numbers>6 and b.count_of_numbers>6)
	or a.sum_of_numbers=b.sum_of_numbers
	or a.name=b.name
	or a.aetal=b.aetal
	or (a.b_length>10 and b.b_length>10)
where a.new_id < b.new_id
go

--2p bonus

if object_id('rule_0b') is not null drop table rule_0b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_0b
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start and a.pages_end=b.pages_end)
	or (a.d_year=b.d_year and a.d_month=b.d_month)
	or (a.volume=b.volume and a.issue=b.issue)
	or (a.b_length=b.b_length and (a.name=b.name or a.aetal=b.aetal))
	or (a.count_of_numbers=b.count_of_numbers and a.count_of_numbers>6 and b.count_of_numbers>6 and a.sum_of_numbers=b.sum_of_numbers)
	or (a.bib_numeric=b.bib_numeric)
	or (a.s_start=b.s_start and a.s_end=b.s_end)
where a.new_id < b.new_id
except
(select * from rule_0a)
go