use patstat
go
/*

Additional Pairing rules:
Namespace: "b" pairs and their respective queries.
Those queries use less reliable labels and use more computationally intensive comparisons (i.e. LD).
As a result those pairs can be used if enough computational capacity is available or accuracy of disambiguation is highly preferred than speed of obtaining results.

Except statements are used to prevent double scoring of rules.
Alternatively, constraint on LD!=1 is equivalent.
N3aW(x)b queries are missing as explained in the 4.1 File.
*/

----------------------------------------------
--Strong: N1 + Strong W1b, W2b; Weak: W3b, W5b

--N1W1b
if object_id('rule_N1W1b') is not null drop table rule_N1W1b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N1W1b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.s_start = b.s_start
	and a.s_end = b.s_end
where a.new_id < b.new_id
	and a.bib_alphanumeric is not null
	and b.bib_alphanumeric is not null
	and len(a.bib_alphanumeric)>=10
	and len(b.bib_alphanumeric)>=10
	and dbo.ComputeDistancePerc(substring(a.bib_alphanumeric, ((a.b_length/2)-5),10), substring(b.bib_alphanumeric, ((b.b_length/2)-5),10)) >= 0.70
	and dbo.ComputeDistancePerc(substring(a.bib_alphanumeric, ((a.b_length/2)-5),10), substring(b.bib_alphanumeric, ((b.b_length/2)-5),10)) != 1.00
--except (select * from rule_N1W1a)
go

--N1W2b
if object_id('rule_N1W2b') is not null drop table rule_N1W2b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N1W2b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_numeric=b.bib_numeric
where a.new_id < b.new_id
	and a.aetal is not null
	and b.aetal is not null
	and dbo.ComputeDistancePerc(a.aetal, b.aetal) >= 0.70
	and dbo.ComputeDistancePerc(a.aetal, b.aetal) != 1.0
--or -- except (select * from rule_N1W2a)
go

--N1W3b
if object_id('rule_N1W3b') is not null drop table rule_N1W3b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N1W3b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_numeric=b.bib_numeric
where a.new_id < b.new_id
	and a.name is not null
	and b.name is not null
	and a.aetal is null
	and b.aetal is null
	and dbo.ComputeDistancePerc(a.name, b.name) >= 0.70
except (select * from rule_N1W3a)
go

--N1W5b
if object_id('rule_N1W5b') is not null drop table rule_N1W5b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N1W5b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.bib_numeric=b.bib_numeric
	and a.res_numeric=b.res_numeric
	and a.residual is not null
	and b.residual is not null
	and (len(a.residual))>=10
	and (len(b.residual))>=10
where a.new_id < b.new_id
	and dbo.ComputeDistancePerc(substring(a.residual, ((len(a.residual)/2)-5), 10), substring(b.residual, ((len(b.residual)/2)-5), 10)) >= 0.70
except (select * from rule_N1W5a)
go

---------------------------------------------
--Strong N2 + Strong W1b, W2b; Weak: W3b, W5b

/*
--N2W1b
if object_id('rule_N2W1b') is not null drop table rule_N2W1b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N2W1b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.s_start = b.s_start
	and a.s_end = b.s_end
	and (a.issn=b.issn
	or a.isbn=b.isbn)
where a.new_id < b.new_id
	and a.bib_alphabetic is not null
	and b.bib_alphabetic is not null
	and len(a.bib_alphabetic)>=10
	and len(b.bib_alphabetic)>=10
	and dbo.ComputeDistancePerc(substring(a.bib_alphabetic, ((len(a.bib_alphabetic)/2)-5),10), substring(b.bib_alphabetic, ((len(a.bib_alphabetic)/2)-5),10)) >= 0.70
except (select * from rule_N2W1a)
go
*/

--N2W2b
if object_id('rule_N2W2b') is not null drop table rule_N2W2b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N2W2b
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.issn=b.issn
	or a.isbn=b.isbn)
where a.new_id < b.new_id
	and a.aetal is not null
	and b.aetal is not null
	and dbo.ComputeDistancePerc(a.aetal, b.aetal) >= 0.70
except (select * from rule_N2W2a)
go

/*
--N2W3b
if object_id('rule_N2W3b') is not null drop table rule_N2W3b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N2W3b
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.issn=b.issn
	or a.isbn=b.isbn)
where a.new_id < b.new_id
	and a.name is not null
	and b.name is not null
	and a.aetal is null
	and b.aetal is null
	and dbo.ComputeDistancePerc(a.name, b.name) >= 0.70
except (select * from rule_N2W3a)
go
*/

/*
--N2W5b
if object_id('rule_N2W5b') is not null drop table rule_N2W5b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N2W5b
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.issn=b.issn
	or a.isbn=b.isbn)
where a.new_id < b.new_id
	and a.residual is not null
	and b.residual is not null
	and len(a.residual)>=10
	and len(b.residual)>=10
	and dbo.ComputeDistancePerc(substring(a.residual, ((len(a.residual)/2)-5),10), substring(b.residual, ((len(b.residual)/2)-5),10)) >= 0.70
except (select * from rule_N2W5a)
go
*/

-------------
--Middle: N3a

--Not allowed. See description of 4.1 File.

-----------------------------------
--Weak: N3b + Strong: W1b, W2b, W3b

--N3bW1b
if object_id('rule_N3bW1b') is not null drop table rule_N3bW1b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3bW1b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.s_start = b.s_start
	and a.s_end = b.s_end
	and (a.pages_start=b.pages_start
	and a.volume=b.volume
	and a.d_year=b.d_year)
where a.new_id < b.new_id
	and a.bib_alphabetic is not null
	and b.bib_alphabetic is not null
	and len(a.bib_alphabetic)>=10
	and len(b.bib_alphabetic)>=10
	and dbo.ComputeDistancePerc(substring(a.bib_alphabetic, ((len(a.bib_alphabetic)/2)-5),10), substring(b.bib_alphabetic, ((len(a.bib_alphabetic)/2)-5),10)) >= 0.70
except (select * from rule_N3bW1a)
go

--N3bW2b
if object_id('rule_N3bW2b') is not null drop table rule_N3bW2b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3bW2b
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start
	and a.volume=b.volume
	and a.d_year=b.d_year)
where a.new_id < b.new_id
	and a.aetal is not null
	and b.aetal is not null
	and dbo.ComputeDistancePerc(a.aetal, b.aetal) >= 0.70
except (select * from rule_N3aW2a)
go

--N3bW3b
if object_id('rule_N3bW3b') is not null drop table rule_N3bW3b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N3bW3b
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.pages_start=b.pages_start
	and a.volume=b.volume
	and a.d_year=b.d_year)
where a.new_id < b.new_id
	and a.name is not null
	and b.name is not null
	and a.aetal is null
	and b.aetal is null
	and dbo.ComputeDistancePerc(a.name, b.name) >= 0.70
except (select * from rule_N3bW3a)
go

---------------------------------
--Weak N4 + Strong: W1b, W2b, W3b

--N4W1b
if object_id('rule_N4W1b') is not null drop table rule_N4W1b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N4W1b
from evaluated_patterns as a
join evaluated_patterns as b on
	a.s_start = b.s_start
	and a.s_end = b.s_end
	and (a.count_of_numbers=b.count_of_numbers
	and a.sum_of_numbers=b.sum_of_numbers
	and a.count_of_numbers>6
	and b.count_of_numbers>6)
	and a.bib_alphabetic is not null
	and b.bib_alphabetic is not null
	and len(a.bib_alphabetic)>=10
	and len(b.bib_alphabetic)>=10
where a.new_id < b.new_id
	and dbo.ComputeDistancePerc(substring(a.bib_alphabetic, ((len(a.bib_alphabetic)/2)-5),10), substring(b.bib_alphabetic, ((len(a.bib_alphabetic)/2)-5),10)) >= 0.70
except (select * from rule_N4W1a)
go

--N4W2b
if object_id('rule_N4W2b') is not null drop table rule_N4W2b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N4W2b
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.count_of_numbers=b.count_of_numbers
	and a.sum_of_numbers=b.sum_of_numbers
	and a.count_of_numbers>6
	and b.count_of_numbers>6)
where a.new_id < b.new_id
	and a.aetal is not null
	and b.aetal is not null
	and dbo.ComputeDistancePerc(a.aetal, b.aetal) >= 0.70
except (select * from rule_N4W2a)
go

/*
--N4W3b
if object_id('rule_N4W3b') is not null drop table rule_N4W3b
select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_N4W3b
from evaluated_patterns as a
join evaluated_patterns as b on
	(a.count_of_numbers=b.count_of_numbers
	and a.sum_of_numbers=b.sum_of_numbers
	and a.count_of_numbers>6
	and b.count_of_numbers>6)
where a.new_id < b.new_id
	and a.name is not null
	and b.name is not null
	and a.aetal is null
	and b.aetal is null
	and dbo.ComputeDistancePerc(a.name, b.name) >= 0.70
except (select * from rule_N4W3a)
go
*/

--Score pairs
if object_id('pairs_tmp') is not null drop table pairs_tmp
if object_id('publn_pairs_AB') is not null drop table publn_pairs_AB
go

--Neg rule vars
declare @threshold int = 14  --14 is approx threshold if no other rules are used.
declare @neg_pairs_pass_points int = 15 -- it gets added to the last used neg_pair_pass_points
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

select a.new_id1, a.new_id2, score = sum(a.score) 
into pairs_tmp
from 
(
	select * from publn_pairs_A
	union all
	select new_id1, new_id2, (-(@neg_pairs_pass_points-@threshold)) as score from rule_A
	union all
	select new_id1, new_id2, (@score_N1+@score_W1b) as score from rule_N1W1b
	union all
	select new_id1, new_id2, (@score_N1+@score_W2b) as score from rule_N1W2b
	union all
	select new_id1, new_id2, (@score_N1+@score_W3b) as score from rule_N1W3b
	union all
	select new_id1, new_id2, (@score_N1+@score_W5a) as score from rule_N1W5b
	union all
	--select new_id1, new_id2, (@score_N2+@score_W1b) as score from rule_N2W1b
	--union all
	select new_id1, new_id2, (@score_N2+@score_W2b) as score from rule_N2W2b
	union all
	--select new_id1, new_id2, (@score_N2+@score_W3b) as score from rule_N2W3b
	--union all
	--select new_id1, new_id2, (@score_N2+@score_W5b) as score from rule_N2W5b
	--union all
	select new_id1, new_id2, (@score_N3b+@score_W1b) as score from rule_N3bW1b
	union all
	select new_id1, new_id2, (@score_N3b+@score_W2b) as score from rule_N3bW2b
	union all
	select new_id1, new_id2, (@score_N3b+@score_W3b) as score from rule_N3bW3b
	union all
	select new_id1, new_id2, (@score_N4+@score_W1b) as score from rule_N4W1b
	union all
	select new_id1, new_id2, (@score_N4+@score_W2b) as score from rule_N4W2b
	--union all
	--select new_id1, new_id2, (@score_N4+@score_W3b) as score from rule_N4W3b
) as a
group by a.new_id1, a.new_id2


--Prepare table for clustering algorithm

select *
into publn_pairs_AB
from pairs_tmp as a
where a.score>=@threshold
go

--Inspect
select a.new_id1, d.npl_biblio, a.new_id2, e.npl_biblio, a.score
from publn_pairs_AB as a
join sample_glue	as b on a.new_id1 = b.new_id
join sample_glue	as c on a.new_id2 = c.new_id
join sample_table	as d on b.npl_publn_id = d.npl_publn_id
join sample_table	as e on c.npl_publn_id = e.npl_publn_id
order by a.score desc
go

--Clean up

if object_id('pairs_tmp') is not null drop table pairs_tmp
go
