--PAIRING RULES

use patstat
go

/*
This step uses the labels extracted in the step 3 to find pairs of tuples that agree on certain criteria.
Those pairs represent semantic duplicates of the same bibliographic entity.
A table with two columns that store npl_biblios' ids (i.e. pairs) is the final output which is used in the clustering stage.
*/

if object_id('rule_A') is not null drop table rule_A
select distinct a.new_id as new_id1, b.new_id as new_id2, 0 as score
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
-- 1. Records agree after applying lowercase, removing spaces and special characters.

if object_id('rule_1') is not null drop table rule_1
select distinct a.new_id as new_id1, b.new_id as new_id2, 1000 as score
into rule_1
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_alphanumeric=b.bib_alphanumeric
where a.new_id < b.new_id
go

--2. Bib_numeric and bib_alphabetic match.
if object_id('rule_2') is not null drop table rule_2
select distinct a.new_id as new_id1, b.new_id as new_id2, 950 as score
into rule_2
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_numeric = b.bib_numeric
	and a.bib_alphabetic= b.bib_alphabetic
where a.new_id < b.new_id
go

--3. Sum of Num, Count of Numbers and bib_alphabetic agree.
if object_id('rule_3') is not null drop table rule_3
select distinct a.new_id as new_id1, b.new_id as new_id2, 800 as score
into rule_3
from evaluated_patterns as a
join evaluated_patterns as b on
	a.sum_of_numbers = b.sum_of_numbers
	and a.count_of_numbers= b.count_of_numbers
	and a.bib_alphabetic = b.bib_alphabetic
	and a.d_year=b.d_year
where a.new_id < b.new_id
except
(select c.new_id1,c.new_id2, 800 as score
from rule_A as c)
go

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

--5. pages and isbn or issn agree. compared to 4. year, month, length can vary

if object_id('rule_5') is not null drop table rule_5
select distinct a.new_id as new_id1, b.new_id as new_id2, 850 as score
into rule_5
from evaluated_patterns as a
join evaluated_patterns as b on
	a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
	and (a.issn=b.issn or a.isbn=b.isbn)
where a.new_id < b.new_id
except
(select c.new_id1,c.new_id2, 850 as score
from rule_A as c
)
go

--6. aetal, year, volume, issue, pages_start
if object_id('rule_6') is not null drop table rule_6
select distinct a.new_id as new_id1, b.new_id as new_id2, 820 as score
into rule_6
from evaluated_patterns as a
join evaluated_patterns as b on
	a.aetal = b.aetal
	and a.d_year=b.d_year
	and a.volume=b.volume
	and a.issue=b.issue
	and a.pages_start=b.pages_start
where a.new_id < b.new_id
except
(select c.new_id1,c.new_id2, 820 as score
from rule_A as c)
go

--7. aetal, year, month, pages

if object_id('rule_7') is not null drop table rule_7
select distinct a.new_id as new_id1, b.new_id as new_id2, 750 as score
into rule_7
from evaluated_patterns as a
join evaluated_patterns as b on
	a.aetal = b.aetal
	and a.d_year = b.d_year
	and a.d_month = b.d_month
	and a.pages_start=b.pages_start
where a.new_id < b.new_id
except
(select c.new_id1,c.new_id2, 750 as score
from rule_A as c)
go

--8. aetal, vol, issue

if object_id('rule_8') is not null drop table rule_8
select distinct a.new_id as new_id1, b.new_id as new_id2, 600 as score
into rule_8
from evaluated_patterns as a
join evaluated_patterns as b on
	a.aetal = b.aetal
	and a.volume = b.volume
	and a.issue = b.issue
where a.new_id < b.new_id
except
(select c.new_id1,c.new_id2, 600 as score
from rule_A as c
union
select d.new_id1, d.new_id2, 600 as score
from rule_6 as d)
go

--9. type and bib_numeric !!!!!!!!!!!! SO NICE

if object_id('rule_9') is not null drop table rule_9
select distinct a.new_id as new_id1, b.new_id as new_id2, 850 as score
into rule_9
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bibliographic_type = b.bibliographic_type
	and a.bib_numeric = b.bib_numeric
	and a.count_of_numbers>6
	and b.count_of_numbers>6
where a.new_id < b.new_id
except
(select c.new_id1,c.new_id2, 850 as score
from rule_A as c
union
select d.new_id2,d.new_id1, 850 as score
from rule_2 as d)
go

--10. type, sum of num, count of num, year, month

if object_id('rule_10') is not null drop table rule_10
select distinct a.new_id as new_id1, b.new_id as new_id2, 700 as score
into rule_10
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bibliographic_type = b.bibliographic_type
	and a.sum_of_numbers = b.sum_of_numbers
	and a.count_of_numbers = b.count_of_numbers
	and a.count_of_numbers>6
	and b.count_of_numbers>6
	and a.d_year=b.d_year
	and a.d_month=b.d_month
where a.new_id < b.new_id
except
(select c.new_id1,c.new_id2, 700 as score
from rule_A as c
union
select d.new_id2,d.new_id1, 700 as score
from rule_3 as d)
go

--11. xp number or url

if object_id('rule_11') is not null drop table rule_11
select distinct a.new_id as new_id1, b.new_id as new_id2, 900 as score
into rule_11
from evaluated_patterns as a
join evaluated_patterns as b on
	a.xp_number = b.xp_number
	or a.url=b.url
where a.new_id < b.new_id
except
(select c.new_id1,c.new_id2, 900 as score
from rule_A as c)
go

--12. LD v1

if object_id('rule_12') is not null drop table rule_12
select distinct a.new_id as new_id1, b.new_id as new_id2, 850 as score
into rule_12
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
except
(select c.new_id1,c.new_id2, 850 as score
from rule_A as c)
go

--12.a LD v1a

if object_id('rule_12a') is not null drop table rule_12a
select distinct a.new_id as new_id1, b.new_id as new_id2, 800 as score
into rule_12a
from evaluated_patterns as a
join evaluated_patterns as b on
	a.s_start = b.s_start
	and (a.bib_numeric=b.bib_numeric
	or a.s_end=b.s_end)
where a.new_id < b.new_id
	and a.bib_alphanumeric is not null
	and b.bib_alphanumeric is not null
	and len(a.bib_alphanumeric)>=10
	and len(b.bib_alphanumeric)>=10
	and dbo.ComputeDistancePerc(substring(a.bib_alphanumeric, ((a.b_length/2)-5),10), substring(b.bib_alphanumeric, ((b.b_length/2)-5),10)) >= 0.70
except
(select c.new_id1,c.new_id2, 800 as score
from rule_A as c)
go

--13. LD v2

if object_id('rule_13') is not null drop table rule_13
select distinct a.new_id as new_id1, b.new_id as new_id2, 800 as score
into rule_13
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_numeric=b.bib_numeric
	and a.d_year=b.d_year
where a.new_id < b.new_id
	and a.bib_alphanumeric is not null
	and b.bib_alphanumeric is not null
	and len(a.bib_alphanumeric)>=10
	and len(b.bib_alphanumeric)>=10
	and dbo.ComputeDistancePerc(substring(a.bib_alphanumeric, ((a.b_length/2)-5),10), substring(b.bib_alphanumeric, ((b.b_length/2)-5),10)) >= 0.75
except
(select c.new_id1,c.new_id2, 750 as score
from rule_A as c)
go

--14. LD v3

if object_id('rule_14') is not null drop table rule_14
select distinct a.new_id as new_id1, b.new_id as new_id2, 650 as score
into rule_14
from evaluated_patterns as a
join evaluated_patterns as b on
	a.sum_of_numbers=b.sum_of_numbers
	and a.count_of_numbers=b.count_of_numbers
	and a.d_year=b.d_year
	and (a.pages_start=b.pages_start or a.issue=b.issue or a.volume=b.volume or a.aetal=b.aetal)
where a.new_id < b.new_id
	and a.bib_alphanumeric is not null
	and b.bib_alphanumeric is not null
	and len(a.bib_alphanumeric)>=10
	and len(b.bib_alphanumeric)>=10
	and dbo.ComputeDistancePerc(substring(a.bib_alphanumeric, ((a.b_length/2)-5),10), substring(b.bib_alphanumeric, ((b.b_length/2)-5),10)) >= 0.80
except
(select c.new_id1,c.new_id2, 650 as score
from rule_A as c)
go

--15. LD v4 w/ residuals

if object_id('rule_15') is not null drop table rule_15
select distinct a.new_id as new_id1, b.new_id as new_id2, 550 as score
into rule_15
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_numeric=b.bib_numeric
	and a.d_year=b.d_year
	and (a.pages_start=b.pages_start or a.issue=b.issue or a.volume=b.volume or a.aetal=b.aetal)
where a.new_id < b.new_id
	and a.bib_numeric is not null
	and b.bib_numeric is not null
	and a.res_alphabetic is not null
	and b.res_alphabetic is not null
	and len(a.res_alphabetic)>=10
	and len(b.res_alphabetic)>=10
and dbo.ComputeDistancePerc(substring(a.res_alphabetic, ((len(a.res_alphabetic)/2)-5),10), substring(b.res_alphabetic, (((len(b.res_alphabetic))/2)-5),10)) >= 0.75
except
(select c.new_id1,c.new_id2, 550 as score
from rule_A as c)
go

--15b. LD v4 w/ residuals

if object_id('rule_15b') is not null drop table rule_15b
select distinct a.new_id as new_id1, b.new_id as new_id2, 500 as score
into rule_15b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.sum_of_numbers=b.sum_of_numbers
	and a.count_of_numbers=b.count_of_numbers
	and a.d_year=b.d_year
	and (a.pages_start=b.pages_start or a.issue=b.issue or a.volume=b.volume or a.aetal=b.aetal)
where a.new_id < b.new_id
	and a.sum_of_numbers is not null
	and b.sum_of_numbers is not null
	and a.count_of_numbers is not null
	and b.count_of_numbers is not null
	and a.res_alphabetic is not null
	and b.res_alphabetic is not null
	and len(a.res_alphabetic)>=10
	and len(b.res_alphabetic)>=10
and dbo.ComputeDistancePerc(substring(a.res_alphabetic, ((len(a.res_alphabetic)/2)-5),10), substring(b.res_alphabetic, (((len(b.res_alphabetic))/2)-5),10)) >= 0.80
except
(select c.new_id1, c.new_id2, 500 as score
from rule_A as c
union
select d.new_id1, d.new_id2, 500 as score
from rule_15 as d)
go

--16. LD(name), year, volume, issue
if object_id('rule_16') is not null drop table rule_16
select distinct a.new_id as new_id1, b.new_id as new_id2, 700 as score
into rule_16
from evaluated_patterns as a
join evaluated_patterns as b on
	a.d_year=b.d_year
	and a.volume = b.volume
	and a.issue = b.issue
where a.new_id < b.new_id
and a.name is not null and b.name is not null
and dbo.ComputeDistancePerc(a.name, b.name) >= 0.85
except
(select c.new_id1, c.new_id2, 700 as score
from rule_A as c
union
select d.new_id1, d.new_id2, 700 as score
from rule_6 as d)
go

--17. LD(name), year, month, pages

if object_id('rule_17') is not null drop table rule_17
select distinct a.new_id as new_id1, b.new_id as new_id2, 700 as score
into rule_17
from evaluated_patterns as a
join evaluated_patterns as b on
	a.d_year = b.d_year
	and a.d_month = b.d_month
	and a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
where a.new_id < b.new_id
and a.name is not null and b.name is not null
and dbo.ComputeDistancePerc(a.name, b.name) >= 0.85
except
(select c.new_id1, c.new_id2, 700 as score
from rule_A as c
union
select d.new_id1, d.new_id2, 700 as score
from rule_7 as d)
go

--18. LD(name), vol, issue

if object_id('rule_18') is not null drop table rule_18
select distinct a.new_id as new_id1, b.new_id as new_id2, 550 as score
into rule_18
from evaluated_patterns as a
join evaluated_patterns as b on
	a.volume = b.volume
	and a.issue = b.issue
where a.new_id < b.new_id
and a.name is not null and b.name is not null
and dbo.ComputeDistancePerc(a.name, b.name) >= 0.80
except
(select c.new_id1, c.new_id2, 550 as score
from rule_A as c
union
select d.new_id1, d.new_id2, 550 as score
from rule_8 as d)
go

/*
--for testing
select *
from rule_18 as a
join sample_unique as b on a.new_id1  = b.new_id 
join sample_unique as c on a.new_id2  = c.new_id 
go
*/

--Obtain all pairs from rules

if object_id('#tmp1') is not null drop table #tmp1
go

select new_id1, new_id2, score into #tmp1
from rule_1
union all
select new_id1, new_id2, score from rule_2
union all
select new_id1, new_id2, score from rule_3
union all
select new_id1, new_id2, score from rule_4
union all
select new_id1, new_id2, score from rule_5
union all
select new_id1, new_id2, score from rule_6
union all
select new_id1, new_id2, score from rule_7
union all
select new_id1, new_id2, score from rule_8
union all
select new_id1, new_id2, score from rule_9
union all
select new_id1, new_id2, score from rule_10
union all
select new_id1, new_id2, score from rule_11
union all
select new_id1, new_id2, score from rule_12
union all
select new_id1, new_id2, score from rule_12a
union all
select new_id1, new_id2, score from rule_13
union all
select new_id1, new_id2, score from rule_14
union all
select new_id1, new_id2, score from rule_15
union all
select new_id1, new_id2, score from rule_15b
union all
select new_id1, new_id2, score from rule_16
union all
select new_id1, new_id2, score from rule_17
union all
select new_id1, new_id2, score from rule_18
go

select a.new_id1, b.npl_biblio,a.new_id2,c.npl_biblio, a.score
from #tmp1 as a
join sample_unique as b on a.new_id1 = b.new_id
join sample_unique as c on a.new_id2 = c.new_id
go

--Prepare table for clustering algorithm
if object_id('publn_pairs') is not null drop table publn_pairs
go
select a.new_id1, a.new_id2
into publn_pairs
from #tmp1 as a
go

--Clean up

if object_id('#tmp1') is not null drop table #tmp1
go