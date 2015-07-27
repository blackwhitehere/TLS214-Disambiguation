--PAIRING RULES

use patstat
go

/*
This step uses the labels extracted in the step 3 to find pairs of tuples that agree on certain criteria.
Those pairs represent semantic duplicates of the same bibliographic entity.
A table with two columns that store npl_biblios' ids (i.e. pairs) is the final output which is used in the clustering stage.
*/

if object_id('rule_A') is not null drop table rule_A
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_A
from evaluated_patterns as a
join evaluated_patterns as b on
	a.useless is not null
	or b.useless is not null
	or a.useless2 is not null
	or b.useless2 is not null
where a.new_id < b.new_id
go

--MATCHING RULES

-- 1. Deterministic. Records agree after applying lowercase, removing spaces and special characters. XP number duplicates are captured as well.

if object_id('rule_1') is not null drop table rule_1
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_1
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_alphanumeric=b.bib_alphanumeric
	or a.xp_number=b.xp_number
where a.new_id < b.new_id
go

--2. Bib_numeric and bib_alphabetic match.

if object_id('rule_2') is not null drop table rule_2
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_2
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_numeric = b.bib_numeric
	and a.bib_alphabetic= b.bib_alphabetic
where a.new_id < b.new_id
except (select * from rule_1)
go

--3. Sum of Num, Count of Numbers and bib_alphabetic agree.

if object_id('rule_3') is not null drop table rule_3
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_3
from evaluated_patterns as a
join evaluated_patterns as b on
	a.sum_of_numbers = b.sum_of_numbers
	and a.count_of_numbers= b.count_of_numbers
	and a.bib_alphabetic = b.bib_alphabetic
	and a.count_of_numbers>6
	and b.count_of_numbers>6
where a.new_id < b.new_id
except (select * from rule_2 union select * from rule_1)
go

--4a. pages and isbn or issn agree.

if object_id('rule_4a') is not null drop table rule_4a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_4a
from evaluated_patterns as a
join evaluated_patterns as b on
	a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
	and (a.issn=b.issn or a.isbn=b.isbn)
where a.new_id < b.new_id
go

--4b. pages, volume, year, month, issue, similar length

if object_id('rule_4b') is not null drop table rule_4b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_4b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.pages_start=b.pages_start
	and a.volume=b.volume
	and a.issue=b.issue
	and a.d_year=b.d_year
	and a.d_month=b.d_month
	and ((convert(decimal(10,4), a.b_length))/(convert(decimal(10,4),b.b_length)))>=0.8	
where a.new_id < b.new_id
except (select * from rule_4a)
go

--5a type and bib_numeric, count_of_numbers>6

if object_id('rule_5a') is not null drop table rule_5a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_5a
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bibliographic_type = b.bibliographic_type
	and a.bib_numeric = b.bib_numeric
	and a.count_of_numbers>6
	and b.count_of_numbers>6
where a.new_id < b.new_id
go

--5b.

if object_id('rule_5b') is not null drop table rule_5b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_5b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.d_year=b.d_year
	and a.bibliographic_type = b.bibliographic_type
	and a.sum_of_numbers = b.sum_of_numbers
	and a.count_of_numbers = b.count_of_numbers
	and a.count_of_numbers>6
	and b.count_of_numbers>6
	and ((convert(decimal(10,4), a.b_length))/(convert(decimal(10,4),b.b_length)))>=0.8	
where a.new_id < b.new_id
except (select * from rule_5a)
go

--6a. aetal, year, (volume or month), pages_start

if object_id('rule_6a') is not null drop table rule_6a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_6a
from evaluated_patterns as a
join evaluated_patterns as b on
	a.aetal = b.aetal
	and a.d_year=b.d_year
	and (a.volume=b.volume or a.d_month=b.d_month)
	and a.pages_start=b.pages_start
where a.new_id < b.new_id
go

--6b. LD(name), year, (volume or month), pages_start


if object_id('rule_6b') is not null drop table rule_6b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_6b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.d_year=b.d_year
	and (a.volume=b.volume or a.d_month=b.d_month)
	and a.pages_start=b.pages_start
where a.new_id < b.new_id
and a.name is not null and b.name is not null
and dbo.ComputeDistancePerc(a.name, b.name) >= 0.60
except (select d.new_id1, d.new_id2
from rule_6a as d)
go

--7a


if object_id('rule_7a') is not null drop table rule_7a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_7a
from evaluated_patterns as a
join evaluated_patterns as b on
	a.d_year=b.d_year
	and a.pages_start=b.pages_start
	and a.volume=b.volume
where a.new_id < b.new_id
and a.aetal is not null and b.aetal is not null
and dbo.ComputeDistancePerc(a.aetal, b.aetal) >= 0.70
go

--7b.


if object_id('rule_7b') is not null drop table rule_7b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_7b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.d_year=b.d_year
	and a.pages_start=b.pages_start
	and a.volume=b.volume
where a.new_id < b.new_id
and a.name is not null
and b.name is not null
and a.aetal is null
and b.aetal is null
and dbo.ComputeDistancePerc(a.name, b.name) >= 0.70
except (select d.new_id1, d.new_id2
from rule_7a as d)
go

--8a. LD biblio v1


if object_id('rule_8a') is not null drop table rule_8a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_8a
from evaluated_patterns as a
join evaluated_patterns as b on
	a.s_start = b.s_start
	and a.s_end = b.s_end
	and a.bib_numeric=b.bib_numeric
where a.new_id < b.new_id
	and a.bib_alphanumeric is not null
	and b.bib_alphanumeric is not null
	and len(a.bib_alphanumeric)>=10
	and len(b.bib_alphanumeric)>=10
	and dbo.ComputeDistancePerc(substring(a.bib_alphanumeric, ((a.b_length/2)-5),10), substring(b.bib_alphanumeric, ((b.b_length/2)-5),10)) >= 0.75
go

--8b - LD v2


if object_id('rule_8b') is not null drop table rule_8b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_8b
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.s_start = b.s_start
	and a.s_end=b.s_end)
	or a.bib_numeric=b.bib_numeric
where a.new_id < b.new_id
	and a.bib_alphanumeric is not null
	and b.bib_alphanumeric is not null
	and len(a.bib_alphanumeric)>=10
	and len(b.bib_alphanumeric)>=10
	and dbo.ComputeDistancePerc(substring(a.bib_alphanumeric, ((a.b_length/2)-5),10), substring(b.bib_alphanumeric, ((b.b_length/2)-5),10)) >= 0.70
except (select * from rule_8a)
go

--8c. LD v4

if object_id('rule_8c') is not null drop table rule_8c
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_8c
from evaluated_patterns as a
join evaluated_patterns as b on
	a.sum_of_numbers=b.sum_of_numbers
	and a.count_of_numbers=b.count_of_numbers
	and a.d_year=b.d_year
	and (a.pages_start=b.pages_start or a.issue=b.issue or a.volume=b.volume or a.aetal=b.aetal)
where a.new_id < b.new_id
	and a.bib_alphanumeric is not null
	and b.bib_alphanumeric is not null
	and len(a.bib_alphanumeric)>=20
	and len(b.bib_alphanumeric)>=20
	and dbo.ComputeDistancePerc(substring(a.bib_alphanumeric, ((a.b_length/2)-10),20), substring(b.bib_alphanumeric, ((b.b_length/2)-10),20)) >= 0.75
except (select * from rule_8a union select * from rule_8b)
go

--9a. LD w/ residuals


if object_id('rule_9a') is not null drop table rule_9a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_9a
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_numeric=b.bib_numeric
where a.new_id < b.new_id
	and a.bib_numeric is not null
	and b.bib_numeric is not null
	and a.res_alphabetic is not null
	and b.res_alphabetic is not null
	and len(a.res_alphabetic)>=20
	and len(b.res_alphabetic)>=20
and dbo.ComputeDistancePerc(substring(a.res_alphabetic, ((len(a.res_alphabetic)/2)-10),20), substring(b.res_alphabetic, (((len(b.res_alphabetic))/2)-10),20)) >= 0.75
go

--9b. LD v4 w/ residuals


if object_id('rule_9b') is not null drop table rule_9b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_9b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.sum_of_numbers=b.sum_of_numbers
	and a.count_of_numbers=b.count_of_numbers
where a.new_id < b.new_id
	and a.sum_of_numbers is not null
	and b.sum_of_numbers is not null
	and a.count_of_numbers is not null
	and b.count_of_numbers is not null
	and a.count_of_numbers >6
	and b.count_of_numbers >6
	and a.res_alphabetic is not null
	and b.res_alphabetic is not null
	and len(a.res_alphabetic)>=20
	and len(b.res_alphabetic)>=20
and dbo.ComputeDistancePerc(substring(a.res_alphabetic, ((len(a.res_alphabetic)/2)-10),20), substring(b.res_alphabetic, (((len(b.res_alphabetic))/2)-10),20)) >= 0.70
except (select * from rule_9a)
go



--for testing
select *
from rule_3 as a
join sample_unique as b on a.new_id1  = b.new_id 
join sample_unique as c on a.new_id2  = c.new_id 
go
*/

--Obtain all pairs from rules

if object_id('pairs_tmp') is not null drop table pairs_tmp
if object_id('publn_pairs') is not null drop table publn_pairs
go

declare @threshold int =8
select a.new_id1, a.new_id2, score = sum(a.score) 
into pairs_tmp
from 
(
	select new_id1, new_id2, (-(32-@threshold)) as score from rule_A
	union all
	select new_id1, new_id2, 64 as score from rule_1
	union all
	select new_id1, new_id2, 32 as score from rule_2
	union all
	select new_id1, new_id2, 8 as score from rule_3
	union all
	select new_id1, new_id2, 32 as score from rule_4a
	union all
	select new_id1, new_id2, 16 as score from rule_4b
	union all
	select new_id1, new_id2, 4 as score from rule_5a
	union all
	select new_id1, new_id2, 1 as score from rule_5b
	union all
	select new_id1, new_id2, 16 as score from rule_6a
	union all
	select new_id1, new_id2, 8 as score from rule_6b
	union all
	select new_id1, new_id2, 4 as score from rule_7a
	union all
	select new_id1, new_id2, 2 as score from rule_7b
	union all
	select new_id1, new_id2, 32 as score from rule_8a
	union all
	select new_id1, new_id2, 16 as score from rule_8b
	union all
	select new_id1, new_id2, 8 as score from rule_8c
	union all
	select new_id1, new_id2, 2 as score from rule_9a
	union all
	select new_id1, new_id2, 1 as score from rule_9b
) as a
group by a.new_id1, a.new_id2


--Prepare table for clustering algorithm


select *
into publn_pairs
from pairs_tmp as a
where a.score>=@threshold
go

--Clean up

if object_id('pairs_tmp') is not null drop table pairs_tmp
go


select a.new_id1, b.npl_biblio, a.new_id2, c.npl_biblio, a.score
from publn_pairs as a
join sample_unique as b on a.new_id1 = b.new_id
join sample_unique as c on a.new_id2 = c.new_id
order by a.score desc
go
