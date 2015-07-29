--EDA, STATISTICS AND REPORTING QUERIES

use patstat
go

-------------------------------------------------
-- Create FULLTEXT on sample_table, sample_unique
-------------------------------------------------

--FULLTEXT

if object_id('tls214_npl_publn') is not null drop fulltext index on tls214_npl_publn
if object_id('sample_unique') is not null drop fulltext index on sample_unique
if object_id('sample_table') is not null drop fulltext index on sample_table
go

create fulltext index on tls214_npl_publn(npl_biblio)
key index pk_npl_publn_id on sample_table_catalog
with stoplist off, change_tracking off, no population
go

create fulltext index on sample_unique(npl_biblio)
key index pk_sample_unique_id on sample_table_catalog
with stoplist off, change_tracking off, no population
go

create fulltext index on sample_table(npl_biblio)
key index pk_sample_table_id on sample_table_catalog
with stoplist off, change_tracking off, no population
go

--turn the index on tls214_npl_publn
alter fulltext index on tls214_npl_publn
start full population
go

--turn the index on sample_unique
alter fulltext index on sample_unique
start full population
go

--turn the index on sample_table
alter fulltext index on sample_table
start full population
go


select count(*) from tls214_npl_publn as a where contains (a.npl_biblio, '"et al"')

/*
--Test fulltext:

--Count amount of XP numbers with fulltext search
select *
from sample_table_unique as sa
where contains (npl_biblio, '"XP*" OR "XP"')

--Use of "like" is much slower
select *
from sample_table_unique
where npl_biblio like '% XP%' 
union 
select *
from sample_table_unique
where npl_biblio like '% XP %' 
*/

-------------
--Preliminary
-------------

--Whole dataset tuple count

select count(*)
from tls214_npl_publn

--Sample set tuple count
select count(*)
from sample_table

--Count of distinct records
select count(distinct npl_biblio) 
from sample_table

------------------
--Text statictics:
------------------

--AVG length of a biblio. Due to CLT, avg on a sample approximates real average
select AVG(b_length)
from evaluated_patterns

--AVG count of digits
select AVG(count_of_numbers)
from evaluated_patterns

--AVG Count of alphanumeric words
select AVG(dbo.GetMatchesCount(a.npl_biblio,'\w+'))
from sample_table as a

--AVG Count of capital letters
select AVG(dbo.GetMatchesCount(a.npl_biblio,'[A-Z]'))
from sample_table as a

--AVG Count of special characters
select AVG(dbo.GetMatchesCount(a.npl_biblio,'[^A-Za-z0-9]'))
from sample_table as a

--AVG Count of punctuation
select AVG(dbo.GetMatchesCount(a.npl_biblio,'[,.:;]'))
from sample_table as a

---------------------
--Content (mentions):
---------------------

--et al
select count(*)
from sample_table as a
where contains (a.npl_biblio, ' "et al"')

--None
select count(*)
from sample_table as a
where contains (a.npl_biblio, ' "None"')

--page
select count(*)
from sample_table as a
where contains (a.npl_biblio, ' "page"')

--volume
select count(*)
from sample_table as a
where contains (a.npl_biblio, ' "volume"')

--issue
select count(*)
from sample_table as a
where contains (a.npl_biblio, ' "issue"')

--http
select count(*)
from sample_table as a
where contains (a.npl_biblio, ' "http*"')

--See reference of EP
select count(*)
from sample_table as a
where contains (a.npl_biblio, '" of EP"')

--&#X
select count(*)
from sample_table as a
where contains (a.npl_biblio, '"&#X*"')

--DIN
select count(*)
from sample_table as a
where contains (a.npl_biblio, '"DIN"')

--ERMITTELT
select count(*)
from sample_table as a
where contains (a.npl_biblio, '"ERMITTELT"')

--German and French month names
select count(*)
from sample_table as a
where contains (a.npl_biblio, 'januer OR januier OR februar OR février OR märz OR mars OR avril OR mai OR juni OR juin OR juli OR juilliet OR août OR oktober OR octobre OR novembre OR dezember OR décembre')

--bib type
select count(*)
from sample_table as a
where contains (a.npl_biblio, 'journal OR magazine OR article')

--bib type 2
select count(*)
from sample_table as a
where contains (a.npl_biblio, 'abstract OR application OR publication')

---------------
--Abbreviations
---------------
--English month names
select count(*)
from sample_table as a
where contains (a.npl_biblio, 'jan OR feb OR mar OR apr OR may OR jun OR jul OR aug OR sep OR sept OR oct OR nov OR dec')

--pp or p. or pgs
select count(*)
from sample_table as a
where contains (a.npl_biblio, 'pp OR p. OR pgs')

--vol or vol.
select count(*)
from sample_table as a
where contains (a.npl_biblio, 'vol OR vol.')

--no or no.
select count(*)
from sample_table as a
where contains (a.npl_biblio, 'no OR no.')

--------------------
--Unique Identifiers
--------------------

--xp number
select count(*)
from sample_table as a
where contains (a.npl_biblio, ' "XP*"')

--ISSN
select count(*) 
from sample_table as a
where contains (a.npl_biblio, ' "ISSN*"')

--ISBN
select count(*) 
from sample_table as a
where contains (a.npl_biblio, ' "ISBN*"')
go

--DOI
select count(*) 
from sample_table as a
where contains (a.npl_biblio, ' "DOI*"')
go

-------
--Other
-------

select count(*) 
from sample_table as a
where contains (a.npl_biblio, '&')
go

----------------
--CLEANING STATS
----------------

declare @loopcounter int = 1
declare @loopmax int = (select max(step_counter) from cleaning_patterns)

--Loop
while (@loopcounter <= @loopmax)
begin
	select	count(*)
	from	sample_table as a
	join	cleaning_patterns as b
			on dbo.IsMatch(a.npl_biblio, b.cleaning_pattern) <> 0 --provided a pattern is found
	where	step_counter = @loopcounter

	set		@loopcounter += 1
end
go

------------------
--EXTRACTION STATS
------------------

--count extracted easy labels
declare @counter int = 1
declare @count_max int = (select count(*) from extraction_patterns)


while (@counter<=@count_max)
begin
	declare @label nvarchar(max)=(select extraction_label from extraction_patterns where reg_exp_id=@counter)
	declare	@sql nvarchar(max) ='select count(*) as '+@label+' from tls214_extracted_patterns where '+@label+' is not null '
	exec	(@sql)
	set		@label=''
	set		@counter=@counter+1
end
go

--count extracted format labels
declare @counter int = 1
declare @count_max int = (select count(*) from extraction_patterns_format)


while (@counter<=@count_max)
begin
	declare @label nvarchar(max)=(select extraction_label from extraction_patterns_format where reg_exp_id=@counter)
	declare	@sql nvarchar(max) ='select count(*) as '+@label+' from tls214_extracted_patterns where '+@label+' is not null '
	exec	(@sql)
	set		@label=''
	set		@counter=@counter+1
end
go

--count evaluated labels
select count(*) as d_day from evaluated_patterns where d_day is not null
select count(*) as d_month from evaluated_patterns where d_month is not null
select count(*) as d_year from evaluated_patterns where d_year is not null
select count(*) as pages_start from evaluated_patterns where pages_start is not null
select count(*) as pages_end from evaluated_patterns where pages_end is not null

------------
--PAIR STATS
------------

--select count(*) as count_ruleA
--from rule_A
--go

--N1
select count(*) as rule_N1W1a
from rule_N1W1a
go
select count(*) as rule_N1W1b
from rule_N1W1b
go
select count(*) as rule_N1W2a
from rule_N1W2a
go
select count(*) as rule_N1W2b
from rule_N1W2b
go
select count(*) as rule_N1W3a
from rule_N1W3a
go
select count(*) as rule_N1W3b
from rule_N1W3b
go
select count(*) as rule_N1W4
from rule_N1W4
go
select count(*) as rule_N1W5a
from rule_N1W5a
go
select count(*) as rule_N1W5b
from rule_N1W5b
go

--N2
select count(*) as rule_N2_pages
from rule_N2_pages
go
--select count(*) as rule_N2W1a
--from rule_N2W1a
--go
--select count(*) as rule_N2W1b
--from rule_N2W1b
--go
select count(*) as rule_N2W2a
from rule_N2W2a
go
select count(*) as rule_N2W2b
from rule_N2W2b
go
select count(*) as rule_N2W3a
from rule_N2W3a
go
--select count(*) as rule_N2W3b
--from rule_N2W3b
--go
--select count(*) as rule_N2W4
--from rule_N2W4
--go
--select count(*) as rule_N2W5a
--from rule_N2W5a
--go
--select count(*) as rule_N2W5b
--from rule_N2W5b
--go

--N3a
select count(*) as rule_N3aW1a
from rule_N3aW1a
go
select count(*) as rule_N3aW1b
from rule_N3aW1b
go
select count(*) as rule_N3aW2a
from rule_N3aW2a
go
select count(*) as rule_N3aW2b
from rule_N3aW2b
go
select count(*) as rule_N3aW3a
from rule_N3aW3a
go
select count(*) as rule_N3aW3b
from rule_N3aW3b
go
select count(*) as rule_N3aW4
from rule_N3aW4
go
select count(*) as rule_N3aW5a
from rule_N3aW5a
go
select count(*) as rule_N3aW5b
from rule_N3aW5b
go

--N3b
select count(*) as rule_N3bW1a
from rule_N3bW1a
go
select count(*) as rule_N3bW1b
from rule_N3bW1b
go
select count(*) as rule_N3bW2a
from rule_N3bW2a
go
select count(*) as rule_N3bW2b
from rule_N3bW2b
go
select count(*) as rule_N3bW3a
from rule_N3bW3a
go
select count(*) as rule_N3bW3b
from rule_N3bW3b
go

--N4
select count(*) as rule_N4W1a
from rule_N4W1a
go
select count(*) as rule_N4W1b
from rule_N4W1b
go
select count(*) as rule_N4W2a
from rule_N4W2a
go
select count(*) as rule_N4W2b
from rule_N4W2b
go
select count(*) as rule_N4W3a
from rule_N4W3a
go
--select count(*) as rule_N4W3b
--from rule_N4W3b
--go

--3x

select count(*) as rule_N1W4W5a
from rule_N1W4W5a
go
select count(*) as rule_N1W4W5b
from rule_N1W4W5b
go
select count(*) as rule_N1W3bW4
from rule_N1W3bW4
go
select count(*) as rule_N1W2bW5b
from rule_N1W2bW5b
go
select count(*) as rule_N2W3bW4
from rule_N2W3bW4
go
--select count(*) as rule_N2W3bW5b
--from rule_N2W3bW5b
--go
select count(*) as rule_W1bN3bW4
from rule_W1bN3bW4
go
select count(*) as rule_W2aN3bW4
from rule_W2aN3bW4
go
select count(*) as rule_W1aN3aN4
from rule_W1aN3aN4
go
select count(*) as rule_W1bN3aN4
from rule_W1bN3aN4
go
select count(*) as rule_W2aN3aN4
from rule_W2aN3aN4
go
select count(*) as rule_W3aN3aN4
from rule_W3aN3aN4
go

--TOTALS
select count(*) as publn_pairs_A
from publn_pairs_A
go
select count(*) as publn_pairs_AB
from publn_pairs_AB
go
select count(*) as publn_pairs_AB3x
from publn_pairs_AB3x
go

-----------------
--CLUSTER DENSITY
-----------------

select max(cluster) from npl_publn_clusters
--1936+1 - 0 cluster

if object_id('#tmp_freq') is not null drop table #tmp_freq
select cluster, count(cluster) as freq
into #tmp_freq
from npl_publn_clusters
group by cluster
order by freq desc
go

select * from #tmp_freq

if object_id('#tmp_freq2') is not null drop table #tmp_freq2
select freq, count(freq) as cluster_density
into #tmp_freq2
from #tmp_freq
group by freq
order by cluster_density desc

select * from #tmp_freq2
order by cluster_density, freq

select sum(cluster_density)
from #tmp_freq2
go

-----------
--XP number
-----------

select count(*) from tls214_extracted_patterns where easy_xp is not null
--5651

select a.new_id, c.npl_publn_id, c.npl_biblio, dbo.IsMatchValue(c.npl_biblio,'XP(\s|:)?(:|-)?(\s?)(\d){4,9}\b') as xp_check
into #tmp1
from tls214_extracted_patterns as a
join sample_glue as b on a.new_id=b.new_id
join sample_table as c on b.npl_publn_id=c.npl_publn_id
where dbo.IsMatch(c.npl_biblio,'XP(\s|:)?(:|-)?(\s?)(\d){4,9}\b') <> 0
go

select * from #tmp1 where npl_publn_id<950000001
--5689
go

select * into #tmp2 from #tmp1 where xp_check is not null
--5721
go

select * into #tmp3 from #tmp1 where npl_publn_id<950000001 and xp_check is not null
--5689

select * from #tmp2 except (select * from #tmp3)
--32

select *, dbo.RegexReplace(a.xp_check, '[^0-9]','') as xp_check2
into #tmp4
from #tmp3 as a
go

select * from #tmp4 where xp_check2!=npl_publn_id
--15
go
drop table #tmp1
drop table #tmp2
drop table #tmp3
drop table #tmp4
go