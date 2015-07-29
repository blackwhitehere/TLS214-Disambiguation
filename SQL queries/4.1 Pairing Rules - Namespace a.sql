---------------
--PAIRING RULES
---------------

use patstat
go

/*
Namespace: "a" pairs.
For rules that use the N3a constraint, their "b" queries (otherwise optional) are presered here,
since the pairs obtained from those rules may not be double scored by rules that use the N3b constraint [N3b is a superset of N3a].
Except statement is used to prevent this.
Commented rules are valid, but are omitted due to performance issues or their hit ratio (few records contain the rules' arguments)
*/

----------------
--Negative rules
----------------
/*
if object_id('rule_A') is not null drop table rule_A
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_A
from evaluated_patterns as a
join evaluated_patterns as b on
	a.useless is not null
	--or b.useless is not null ??
	or a.useless2 is not null
	--or b.useless2 is not null ??
where a.new_id < b.new_id
go
*/

/*
select count(*) as count_ruleA
from rule_A
go
*/

/*
if object_id('rule_B') is not null drop table rule_B
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_B
from evaluated_patterns as a
join evaluated_patterns as b on
	a.xp_number is not null
	and b.xp_number is not null
	and a.pages_start is not null
	and a.pages_end is not null
	and b.pages_end is not null
	and a.pages_start!=b.pages_start
	and a.pages_end!=b.pages_end
	and a.xp_number!=b.xp_number
where a.new_id < b.new_id
go

--and so on for every rule with Score>threshold (issn+pages).
--If a pair has attributes but they do not match, score negative
--However, there are  ((N+1)*N)/2 (sum arithmetic series) of possible pairs, thus making scoring all of them with negative rules impractical.

*/


---------------------------------------------------------
--Strong N1 + Strong: W1a, W2a; Middle: W3a; Low: W4, W5a
---------------------------------------------------------

--N1W1a + UNIQUE ID
--N1W1 constraint is merged into one attribute that also use original ordering - bib_alphanumeric.
--Later on, W1a and W1b use just the bib_alphabetic field for comparisons.

if object_id('rule_N1W1a') is not null drop table rule_N1W1a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N1W1a
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_alphanumeric=b.bib_alphanumeric
	or a.xp_number=b.xp_number --UNIQUE ID
where a.new_id < b.new_id
go

--N1W2a
if object_id('rule_N1W2a') is not null drop table rule_N1W2a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N1W2a
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_numeric=b.bib_numeric
	and a.aetal=b.aetal
where a.new_id < b.new_id
go

--N1W3a
if object_id('rule_N1W3a') is not null drop table rule_N1W3a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N1W3a
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_numeric=b.bib_numeric
	and a.name=b.name
where a.new_id < b.new_id
	and a.aetal is null
	and b.aetal is null
go

--N1W4
if object_id('rule_N1W4') is not null drop table rule_N1W4
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N1W4
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_numeric=b.bib_numeric
	and a.bibliographic_type=b.bibliographic_type
where a.new_id < b.new_id
go

/*
--N1W5a
if object_id('rule_N1W5a') is not null drop table rule_N1W5a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N1W5a
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_numeric=b.bib_numeric
	and a.residual=b.residual
where a.new_id < b.new_id
go
*/

-------------------------------------------------------------------------------------------
--Strong N2 + Special: pages_start & pages_end, Strong: W1a, W2a; Middle: W3a; Low: W4, W5a

--N2 + pages

if object_id('rule_N2_pages') is not null drop table rule_N2_pages
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N2_pages
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.issn=b.issn
	or a.isbn=b.isbn)
	and a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
where a.new_id < b.new_id
go

/*
--N2W1a
if object_id('rule_N2W1a') is not null drop table rule_N2W1a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N2W1a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.issn=b.issn
	or a.isbn=b.isbn)
	and a.bib_alphabetic=b.bib_alphabetic
where a.new_id < b.new_id
go
*/

--N2W2a
if object_id('rule_N2W2a') is not null drop table rule_N2W2a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N2W2a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.issn=b.issn
	or a.isbn=b.isbn)
	and a.aetal=b.aetal
where a.new_id < b.new_id
go

/*
--N2W3a
if object_id('rule_N2W3a') is not null drop table rule_N2W3a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N2W3a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.issn=b.issn
	or a.isbn=b.isbn)
	and a.name=b.name
where a.new_id < b.new_id
	and a.aetal is null
	and b.aetal is null
go
*/

/*
--N2W4 - Large FP rate
if object_id('rule_N2W4') is not null drop table rule_N2W4
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N2W4
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.issn=b.issn
	or a.isbn=b.isbn)
	and a.bibliographic_type=b.bibliographic_type
where a.new_id < b.new_id
go

--N2W5a
if object_id('rule_N2W5a') is not null drop table rule_N2W5a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N2W5a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.issn=b.issn
	or a.isbn=b.isbn)
	and a.residual=b.residual
where a.new_id < b.new_id
go
*/

----------------------------------------------------------------------------
--Namespace "b" queries are included to properly use "N3bW{1,2,3}a" section.
--Middle N3a + Strong: W1a, W1b, W2a, W2b; Middle: W3a, W3b; Low: W4a, W5a

--N3aW1a
if object_id('rule_N3aW1a') is not null drop table rule_N3aW1a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3aW1a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
	and a.volume=b.volume
	and a.issue=b.issue
	and a.d_year=b.d_year
	and a.d_month=b.d_month)
	and a.bib_alphabetic=b.bib_alphabetic
where a.new_id < b.new_id
go

--N3aW1b !!!
if object_id('rule_N3aW1b') is not null drop table rule_N3aW1b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3aW1b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.s_start = b.s_start
	and a.s_end = b.s_end
	and (a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
	and a.volume=b.volume
	and a.issue=b.issue
	and a.d_year=b.d_year
	and a.d_month=b.d_month)
where a.new_id < b.new_id
	and a.bib_alphabetic is not null
	and b.bib_alphabetic is not null
	and len(a.bib_alphabetic)>=10
	and len(b.bib_alphabetic)>=10
	and dbo.ComputeDistancePerc(substring(a.bib_alphabetic, ((len(a.bib_alphabetic)/2)-5),10), substring(b.bib_alphabetic, ((len(a.bib_alphabetic)/2)-5),10)) >= 0.70
except (select * from rule_N3aW1a)
go

--N3aW2a
if object_id('rule_N3aW2a') is not null drop table rule_N3aW2a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3aW2a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
	and a.volume=b.volume
	and a.issue=b.issue
	and a.d_year=b.d_year
	and a.d_month=b.d_month)
	and a.aetal=b.aetal
where a.new_id < b.new_id
go

--N3aW2b !!!
if object_id('rule_N3aW2b') is not null drop table rule_N3aW2b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3aW2b
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
	and a.volume=b.volume
	and a.issue=b.issue
	and a.d_year=b.d_year
	and a.d_month=b.d_month)
where a.new_id < b.new_id
	and a.aetal is not null
	and b.aetal is not null
	and dbo.ComputeDistancePerc(a.aetal, b.aetal) >= 0.70
go

--N3aW3a
if object_id('rule_N3aW3a') is not null drop table rule_N3aW3a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3aW3a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
	and a.volume=b.volume
	and a.issue=b.issue
	and a.d_year=b.d_year
	and a.d_month=b.d_month)
	and a.name=b.name
where a.new_id < b.new_id
	and a.aetal is null
	and b.aetal is null
go

--N3aW3b !!!
if object_id('rule_N3aW3b') is not null drop table rule_N3aW3b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3aW3b
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
	and a.volume=b.volume
	and a.issue=b.issue
	and a.d_year=b.d_year
	and a.d_month=b.d_month)
where a.new_id < b.new_id
	and a.name is not null
	and b.name is not null
	and a.aetal is null
	and b.aetal is null
	and dbo.ComputeDistancePerc(a.name, b.name) >= 0.70
go

--N3aW4
if object_id('rule_N3aW4') is not null drop table rule_N3aW4
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3aW4
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
	and a.volume=b.volume
	and a.issue=b.issue
	and a.d_year=b.d_year
	and a.d_month=b.d_month)
	and a.bibliographic_type=b.bibliographic_type
where a.new_id < b.new_id
go

--N3aW5a
if object_id('rule_N3aW5a') is not null drop table rule_N3aW5a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3aW5a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
	and a.volume=b.volume
	and a.issue=b.issue
	and a.d_year=b.d_year
	and a.d_month=b.d_month)
	and a.residual=b.residual
where a.new_id < b.new_id
go


/*
--N3aW5b !!!
if object_id('rule_N3aW5b') is not null drop table rule_N3aW5b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3aW5b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.res_numeric = b.res_numeric
	(a.pages_start=b.pages_start
	and a.pages_end=b.pages_end
	and a.volume=b.volume
	and a.issue=b.issue
	and a.d_year=b.d_year
	and a.d_month=b.d_month)
where a.new_id < b.new_id
	and a.residual is not null
	and b.residual is not null
	and len(a.residual)>=10
	and len(b.residual)>=10
	and dbo.ComputeDistancePerc(substring(a.residual, ((len(a.residual)/2)-5),10), substring(b.residual, ((len(b.residual)/2)-5),10)) >= 0.70
go
*/

------------------------------------------
--Weak N3b + Strong: W1a, W2a; Middle: W3a

--N3bW1a
if object_id('rule_N3bW1a') is not null drop table rule_N3bW1a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3bW1a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start
	and a.volume=b.volume
	and a.d_year=b.d_year)
	--and a.pages_end is null --alternative to except?
	--and b.pages_end is null
	--and a.d_month is null
	--and b.d_month is null
	--and a.issue is null
	--and b.issue is null
	and a.bib_alphabetic=b.bib_alphabetic
where a.new_id < b.new_id
except (select * from rule_N3aW1b)
go

--N3bW2a
if object_id('rule_N3bW2a') is not null drop table rule_N3bW2a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3bW2a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start
	and a.volume=b.volume
	and a.d_year=b.d_year)
	and a.aetal=b.aetal
where a.new_id < b.new_id
except (select * from rule_N3aW2b)
go

--N3bW3a
if object_id('rule_N3bW3a') is not null drop table rule_N3bW3a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3bW3a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start
	and a.volume=b.volume
	and a.d_year=b.d_year)
	and a.name=b.name
where a.new_id < b.new_id
	and a.aetal is null
	and b.aetal is null
except (select * from rule_N3aW3b)
go

------------------------------------------
--Weak N4 + Strong: W1a, W2a & Middle: W3a
/*
--N4W1a
if object_id('rule_N4W1a') is not null drop table rule_N4W1a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N4W1a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.count_of_numbers=b.count_of_numbers
	and a.sum_of_numbers=b.sum_of_numbers
	and a.count_of_numbers>6
	and b.count_of_numbers>6)
	and a.bib_alphabetic=b.bib_alphabetic
where a.new_id < b.new_id
go
*/

--N4W2a
if object_id('rule_N4W2a') is not null drop table rule_N4W2a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N4W2a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.count_of_numbers=b.count_of_numbers
	and a.sum_of_numbers=b.sum_of_numbers
	and a.count_of_numbers>6
	and b.count_of_numbers>6)
	and a.aetal=b.aetal
where a.new_id < b.new_id
go

--N4W3a
if object_id('rule_N4W3a') is not null drop table rule_N4W3a
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N4W3a
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.count_of_numbers=b.count_of_numbers
	and a.sum_of_numbers=b.sum_of_numbers
	and a.count_of_numbers>6
	and b.count_of_numbers>6)
	and a.name=b.name
where a.new_id < b.new_id
	and a.aetal is null
	and b.aetal is null
go

--SCORE PAIRS
if object_id('pairs_tmp') is not null drop table pairs_tmp
if object_id('publn_pairs_A') is not null drop table publn_pairs_A
go

--Neg rule vars
declare @threshold int = 7 -- this is a minimal score double "a" rule can achieve. 14 is the threshold if no other rules are applied.
declare @neg_pairs_pass_points int = 18 --36

--Score points
declare @score_N1 int = 9
declare @score_N2 int = 7
declare @score_N3a int = 6
declare @score_N3b int = 3
declare @score_N4 int = 1

declare @score_W1a int = 9
declare @score_W1b int = 8
declare @score_W2a int = 7
declare @score_W3a int = 6
declare @score_W2b int = 5
declare @score_W3b int = 4
declare @score_W4 int = 3
declare @score_W5a int = 2
declare @score_W5b int = 1

declare @pages_bonus int = 2
declare @bib_alphanumeric_bonus int = 3

select a.new_id1, a.new_id2, score = sum(a.score) 
into pairs_tmp
from 
(
	select new_id1, new_id2, (-(@neg_pairs_pass_points-@threshold)) as score from rule_A
	union all
	select new_id1, new_id2, (@score_N1+@score_W1a+@bib_alphanumeric_bonus) as score from rule_N1W1a
	union all
	select new_id1, new_id2, (@score_N1+@score_W2a) as score from rule_N1W2a
	union all
	select new_id1, new_id2, (@score_N1+@score_W3a) as score from rule_N1W3a
	union all
	select new_id1, new_id2, (@score_N1+@score_W4) as score from rule_N1W4
	union all
	--select new_id1, new_id2, (@score_N1+@score_W5a) as score from rule_N1W5a
	--union all
	select new_id1, new_id2, (@score_N2+@pages_bonus) as score from rule_N2_pages
	union all
	--select new_id1, new_id2, (@score_N2+@score_W1a) as score from rule_N2W1a
	--union all
	select new_id1, new_id2, (@score_N2+@score_W2a) as score from rule_N2W2a
	union all
	--select new_id1, new_id2, (@score_N2+@score_W3a) as score from rule_N2W3a
	--union all
	--select new_id1, new_id2, (@score_N2+@score_W4) as score from rule_N2W4
	--union all
	--select new_id1, new_id2, (@score_N2+@score_W5a) as score from rule_N2W5a
	--union all
	select new_id1, new_id2, (@score_N3a+@score_W1a) as score from rule_N3aW1a
	union all
	select new_id1, new_id2, (@score_N3a+@score_W1b) as score from rule_N3aW1b
	union all
	select new_id1, new_id2, (@score_N3a+@score_W2a) as score from rule_N3aW2a
	union all
	select new_id1, new_id2, (@score_N3a+@score_W2b) as score from rule_N3aW2b
	union all
	select new_id1, new_id2, (@score_N3a+@score_W3a) as score from rule_N3aW3a
	union all
	select new_id1, new_id2, (@score_N3a+@score_W3b) as score from rule_N3aW3b
	union all
	select new_id1, new_id2, (@score_N3a+@score_W4) as score from rule_N3aW4
	union all
	select new_id1, new_id2, (@score_N3a+@score_W5a) as score from rule_N3aW5a
	union all
	--select new_id1, new_id2, (@score_N3a+@score_W5b) as score from rule_N3aW5b
	--union all
	select new_id1, new_id2, (@score_N3b+@score_W1a) as score from rule_N3bW1a
	union all
	select new_id1, new_id2, (@score_N3b+@score_W2a) as score from rule_N3bW2a
	union all
	select new_id1, new_id2, (@score_N3b+@score_W3a) as score from rule_N3bW3a
	union all
	--select new_id1, new_id2, (@score_N4+@score_W1a) as score from rule_N4W1a --too liberal, many records have the same syntax, different numbers
	--union all
	select new_id1, new_id2, (@score_N4+@score_W2a) as score from rule_N4W2a
	union all
	select new_id1, new_id2, (@score_N4+@score_W3a) as score from rule_N4W3a
) as a
group by a.new_id1, a.new_id2


--Prepare table for clustering algorithm or further rules
select *
into publn_pairs_A
from pairs_tmp as a
where a.score>=@threshold
go

--Clean up
if object_id('pairs_tmp') is not null drop table pairs_tmp
go

---------
--Inspect
---------

select a.new_id1, d.npl_biblio as npl_biblio1, a.new_id2, e.npl_biblio as npl_biblio2, a.score
from publn_pairs_A as a
join sample_glue	as b on a.new_id1 = b.new_id
join sample_glue	as c on a.new_id2 = c.new_id
join sample_table	as d on b.npl_publn_id = d.npl_publn_id
join sample_table	as e on c.npl_publn_id = e.npl_publn_id
order by a.score desc
go