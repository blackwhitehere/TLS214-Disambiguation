--use patstat
--go

use patstat_sample
go

---------------------------------------------------------------------------------------------
-- EXTRACTION
---------------------------------------------------------------------------------------------

-- Create a table for specifing patterns for change
if object_id('extraction_patterns') is not null drop table extraction_patterns
create table extraction_patterns
				(step int not null,
				extraction_label varchar(100) not null,
				extraction_pattern varchar(200) not null
				--etc
				)
go

--populate table 
insert into extraction_patterns select 1, 'month_date', '\b(?<Month>Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)(\s|\.|\.\s)?(?<Date>\d+)'
insert into extraction_patterns select 18, 'month1', '\b(?<Month>Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)(\s|\.|\.)'
insert into extraction_patterns select 2, 'tentative_easy_year', '(18[5-9][0-9])|(19[0-9][0-9])|(20(0|1)[1-5])'
--best not to discriminate between different dates?
insert into extraction_patterns select 3, 'date_american', '\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2}\b'
insert into extraction_patterns select 4, 'date_european', '\b(0?[1-9]|[12][0-9]|3[01])[- /.](0?[1-9]|1[012])[- /.](19|20)?[0-9]{2}\b'
insert into extraction_patterns select 5, 'date_japan', '\b(19|20)?[0-9]{2}[- /.](0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])\b'
insert into extraction_patterns select 6, 'easy_pages', '(?<=(\bpages\b(\.|,)?\s*))(\d+)((?:(\s(?:to\s)?(?:-\s)?|-|/))?)(\d*)'
insert into extraction_patterns select 7, 'easy_volume', '(?<=(\bvol\s*))(\d+)'
insert into extraction_patterns select 8, 'easy_no', '(?<=(\bNo(\.|,|\.;)?\s*))(\d+)'
insert into extraction_patterns select 9, 'easy_xp', 'XP(\s|:)?(:|-)?(\s?)(\d){4,9}\b'
insert into extraction_patterns select 10, 'easy_issn', 'ISSN(:|\s)?(\s|:)?\s?(\d{4})(-|\s)?(-\s)?(\d{3,4})(\w?)\b'
insert into extraction_patterns select 11, 'easy_isbn', 'ISBN(\s|:)?(\s)?([0-9-x\s_]{10,17})\b'
insert into extraction_patterns select 12, 'easy_bibliographic_type', 'Journal|Magazine|Abstract|Article|proc '
--duurt lang (8 minuten)
insert into extraction_patterns select 13, 'easy_aetal', '(([a-zA-Z,.]+\s?){1,4})(?=\bet(\.\s|\.|\s)?al)'

insert into extraction_patterns select 14, 'easy_url', '\b(https?|ftp|file)://[A-Z0-9+&@#/%?=~_|$!:,.;-]*[A-Z0-9+&@#/%=~_|$]'
insert into extraction_patterns select 15, 'easy_email', '\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}\b'
insert into extraction_patterns select 16, 'bib_numeric', '[^0-9]+'
insert into extraction_patterns select 17, 'bib_alphabetic', '[^A-z ]+'
insert into extraction_patterns select 19, 'xp_number', '^[0]+'

--add index
create index idx_extraction_patterns on extraction_patterns(step)

--this table needs a column for each extracted pattern
if object_id('tls214_extracted_patterns') is not null drop table tls214_extracted_patterns
create table tls214_extracted_patterns
				(npl_publn_id int not null,
				 --dates
				 month_date varchar(200),
				 month1 varchar(100),
				 --tentative_easy_year varchar(200),
				 tentative_easy_year int,
				 --date_all varchar(200),
				 date_american varchar(200),
				 date_european varchar(200),
				 date_japan varchar(200),
				 --sources
				 easy_pages varchar(200),
				 easy_volume varchar(200),
				 easy_no varchar(200),
				 easy_xp varchar(200),
				 xp_number int,
				 easy_issn varchar(200),
				 easy_isbn varchar(200),
			     easy_bibliographic_type varchar(200),
				 easy_aetal varchar(400),
			     easy_url varchar(400),
			     easy_email varchar(200),
				 --general
				 bib_numeric varchar(1000),
                 bib_alphabetic varchar(max),
				 npl_biblio_length int,
				 sum_of_numbers int,
				 count_of_numbers int,
				 )
				 --extended
go

--populate table with npl_publn_ids
insert into tls214_extracted_patterns(npl_publn_id)
select npl_publn_id
--from [dbo].[tls214_npl_publn_unique]
from [dbo].[sample_table]

--test, updating with or without index
create index idx_tls214_extracted_patterns on tls214_extracted_patterns(npl_publn_id)

--
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 1)
--in one go
update a
set a.month_date = b.month_date
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) as month_date
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 2)
update a
set a.tentative_easy_year = b.tentative_easy_year
from tls214_extracted_patterns as a
join (select npl_publn_id, convert(int, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern)) as tentative_easy_year
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 3)
update a
set a.date_american = b.date_american
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) as date_american
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

--does this have results other than date american?
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 4)
update a
set a.date_european = b.date_european
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) as date_european
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 5)
update a
set a.date_japan = b.date_japan
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) as date_japan
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

--does this have results other than date american?
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 6)
update a
set a.easy_pages = b.easy_pages
from tls214_extracted_patterns as a
join (select npl_publn_id, replace(patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern), ' ', '') as easy_pages
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

--
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 7)
update a
set a.easy_volume = b.easy_volume
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) as easy_volume
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 8)
update a
set a.easy_no = b.easy_no
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) as easy_no
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

----extra cleaning on xp numbers
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 9)

--temp table 
if object_id('tempdb.dbo.#tmp') is not null drop table #tmp
select npl_publn_id, upper(ltrim(replace(replace(patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern), ' ', ''), '-',''))) as easy_xp
into #tmp
--from [dbo].[tls214_npl_publn_unique]
from [dbo].[sample_unique]
where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> ''

--harmonization
if object_id('tempdb.dbo.#tmp2') is not null drop table #tmp2
select npl_publn_id, 
  case
	when len(easy_xp) = 11 then easy_xp
	when len(easy_xp) = 9 and substring(easy_xp, 3, 1) <> 0 then ('XP' + '00' + right(easy_xp, 7))
	when len(easy_xp) = 8 and substring(easy_xp, 3, 1) <> 0 then ('XP' + '000' + right(easy_xp, 6))
	when len(easy_xp) = 7 and substring(easy_xp, 3, 1) <> 0 then ('XP' + '0000' + right(easy_xp, 5))
	when len(easy_xp) = 6 and substring(easy_xp, 3, 1) <> 0 then ('XP' + '00000' + right(easy_xp, 4))
	--can be extended
  end as easy_xp
into #tmp2
from #tmp
where easy_xp is not null

--easy xp
update a
set a.easy_xp = b.easy_xp
from tls214_extracted_patterns as a
join (select npl_publn_id, easy_xp
	  from #tmp2
	  where easy_xp is not null) as b on a.npl_publn_id = b.npl_publn_id
go

--does this have results other than date american?
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 19)

--xp number
update a
set a.xp_number = b.xp_number
from tls214_extracted_patterns as a
join (select npl_publn_id, convert(int, patstat_clean.dbo.RegexReplace((right(easy_xp, 9)), @pattern,'')) as xp_number 
	  from #tmp2
	  where easy_xp is not null) as b on a.npl_publn_id = b.npl_publn_id
go

--clean up 9
if object_id('tempdb.dbo.#tmp') is not null drop table #tmp
if object_id('tempdb.dbo.#tmp2') is not null drop table #tmp2


--10
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 10)
update a
set a.easy_issn = b.easy_issn
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) as easy_issn
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go				 

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 11)
update a
set a.easy_isbn = b.easy_isbn
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) as easy_isbn
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go	
				 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 12)
update a
set a.easy_bibliographic_type = b.easy_bibliographic_type
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) as easy_bibliographic_type
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go				 

--error, defined too small?			 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 13)
update a
set a.easy_aetal = b.easy_aetal
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) as easy_aetal
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go				     

--error, 200 too small (right sie?)				 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 14)
update a
set a.easy_url  = b.easy_url 
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) as easy_url 
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go	

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 15)
update a
set a.easy_email  = b.easy_email 
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) as easy_email 
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go				     

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 16)
update a
set a.bib_numeric  = b.bib_numeric 
from tls214_extracted_patterns as a
join (select npl_publn_id, rtrim(patstat_clean.dbo.RegexReplace(npl_biblio, @pattern,'')) as bib_numeric
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
      where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go				     

--
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 17)
update a
set a.bib_alphabetic  = b.bib_alphabetic 
from tls214_extracted_patterns as a
join (select npl_publn_id, ltrim(rtrim(patstat_clean.dbo.RegexReplace(patstat_clean.dbo.RegexReplace(npl_biblio, @pattern,''),' {2,}' ,' '))) as bib_alphabetic
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table])
	  as b on a.npl_publn_id = b.npl_publn_id
go

--18
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 18)
update a
set a.month1 = b.month1
from tls214_extracted_patterns as a
join (select npl_publn_id, left(lower(patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern)),3) as month1
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_table]
	  where patstat_clean.dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go


--note 953459086
--not mutual exclusive

update a
set a.npl_biblio_length  = b.npl_biblio_length 
from tls214_extracted_patterns as a
join (select npl_publn_id, len(npl_biblio) as npl_biblio_length 
	  from [dbo].[sample_table]
      where len(npl_biblio)> 0 ) as b on a.npl_publn_id = b.npl_publn_id
go

update a
set a.sum_of_numbers  = b.sum_of_numbers
from tls214_extracted_patterns as a
join (select npl_publn_id, patstat_clean.dbo.SumIntDigits(bib_numeric) as sum_of_numbers
	  from tls214_extracted_patterns
      where bib_numeric is not null) as b on a.npl_publn_id = b.npl_publn_id
go

update a
set a.count_of_numbers  = b.count_of_numbers
from tls214_extracted_patterns as a
join (select npl_publn_id, len(bib_numeric) as count_of_numbers
	  from tls214_extracted_patterns
      where len(bib_numeric)> 0) as b on a.npl_publn_id = b.npl_publn_id
go

select * 
from tls214_extracted_patterns
where tentative_easy_year is null and date_japan is not null


--select *, dbo.IsMatchValue(npl_biblio,'\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2}\b') as d_american,
--dbo.GetGroups(npl_biblio, '\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2}\b', 1) as a_month,
--dbo.GetGroups(npl_biblio, '\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2}\b', 2) as a_day,
--dbo.GetGroups(npl_biblio, '\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2}\b', 3) as a_year
--into #tmp1
--from sample_unique


--add index, last step
create index idx_tls214_extracted_patterns on tls214_extracted_patterns(npl_publn_id)

---------------------------------------------------------------------------------------------
-- RULES
---------------------------------------------------------------------------------------------


--just some tries
--example rule 1
if object_id('result_rule_1') is not null drop table result_rule_1
select distinct a.npl_publn_id as npl_publn_id1, b.npl_publn_id as npl_publn_id2
into result_rule_1
from tls214_extracted_patterns as a
join tls214_extracted_patterns as b on a.bib_numeric = b.bib_numeric and a.tentative_easy_year = b.tentative_easy_year and a.bib_alphabetic= b.bib_alphabetic
where a.npl_publn_id < b.npl_publn_id

--example rule 2
if object_id('result_rule_2') is not null drop table result_rule_2
select distinct a.npl_publn_id as npl_publn_id1, b.npl_publn_id as npl_publn_id2
into result_rule_2
from tls214_extracted_patterns as a
join tls214_extracted_patterns as b on a.sum_of_numbers = b.sum_of_numbers and a.bib_alphabetic= b.bib_alphabetic
where a.npl_publn_id < b.npl_publn_id

--example rule 3
if object_id('result_rule_3') is not null drop table result_rule_3
select distinct a.npl_publn_id as npl_publn_id1, b.npl_publn_id as npl_publn_id2
into result_rule_3
from tls214_extracted_patterns as a
join tls214_extracted_patterns as b on a.easy_isbn = b.easy_isbn and a.easy_aetal = b.easy_aetal
where a.npl_publn_id < b.npl_publn_id and a.easy_isbn is not null


--example rule 4
if object_id('result_rule_4') is not null drop table result_rule_4
select distinct a.npl_publn_id as npl_publn_id1, b.npl_publn_id as npl_publn_id2
into result_rule_4
from tls214_extracted_patterns as a
join tls214_extracted_patterns as b on a.bib_numeric = b.bib_numeric and a.tentative_easy_year = b.tentative_easy_year and a.month1 = b.month1
where a.npl_publn_id < b.npl_publn_id 


--query for testing
select top 10000 a.npl_publn_id1, b.npl_biblio, a.npl_publn_id2, c.npl_biblio 
from result_rule_4 as a
join sample_table as b on a.npl_publn_id1  = b.npl_publn_id 
join sample_table as c on a.npl_publn_id2  = c.npl_publn_id 

--PROC


--drop table tls214_npl_publn_unique_clean_year_month
--select a.npl_publn_id, npl_biblio, left(npl_biblio, 8) as fp, right(npl_biblio, 2) as lp, convert(int, [year]) as [year], num
--into tls214_npl_publn_unique_clean_year_month
--from tls214_npl_publn_unique_clean3 as a
--join #single_results_years as b on a.npl_publn_id = b.npl_publn_id
--join #single_results_num as c on a.npl_publn_id = c.npl_publn_id

----select * from tls214_npl_publn_unique_clean_year_month

--alter table [tls214_npl_publn_unique_clean_year_month] add constraint pk_npl_publn_id5 primary key (npl_publn_id)

--create index idx_fp on tls214_npl_publn_unique_clean_year_month(fp)
--create index idx_lp on tls214_npl_publn_unique_clean_year_month(lp)
--create index idx_year on tls214_npl_publn_unique_clean_year_month([year])
--create index idx_num on tls214_npl_publn_unique_clean_year_month(num)
--create index idx_all on tls214_npl_publn_unique_clean_year_month(fp, lp, [year], num)


--if object_id('ld') is not null drop table ld
--create table ld
--(
--	npl_publn_id1 int not null,
--	npl_publn_id2 int not null,
--	[year] int not null,
--	ld_perc decimal(10,2) not null
--)

--declare @batch_year int;
--declare @max_year int;
--declare @message varchar(60);
--set @batch_year = (select min([year]) from tls214_npl_publn_unique_clean_year_month)
--set @max_year = (select max([year]) from tls214_npl_publn_unique_clean_year_month)

----process batches
--while (@batch_year <= @max_year)
--begin
														
--    --information about current year
--	set @message = 'year: ' + cast(@batch_year as varchar(4)) + ' date: ' + convert(varchar(34), getdate())
--	raiserror (@message , 0, 1) with nowait 

--	insert ld
--	select a.npl_publn_id, b.npl_publn_id, a.[year], userdb_emiel.dbo.compute_ld_perc(a.npl_biblio, b.npl_biblio) 
--	from tls214_npl_publn_unique_clean_year_month as a
--	join tls214_npl_publn_unique_clean_year_month as b on a.fp = b.fp and a.lp = b.lp and a.[year] = b.[year] and a.num = b.num
--	where a.npl_publn_id <> b.npl_publn_id and 
--	--where a.npl_publn_id < b.npl_publn_id and
--    userdb_emiel.dbo.compute_ld_perc(a.npl_biblio, b.npl_biblio) >= 0.90 and 
--	a.[year] = @batch_year

--	set @batch_year += 1;

--end

----add tables together (target table is ld)
--insert ld
--select *
--from ld2


----test
--select top 1000 b.*, a.*, c.*
--from ld as a
--join tls214_npl_publn_unique_clean_year_month as b on a.npl_publn_id1 = b.npl_publn_id
--join tls214_npl_publn_unique_clean_year_month as c on a.npl_publn_id2 = c.npl_publn_id
--order by b.npl_publn_id

----clustering