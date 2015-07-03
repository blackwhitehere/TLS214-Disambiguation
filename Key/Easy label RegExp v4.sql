use patstat
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
--dates
/*
insert into extraction_patterns select 1, 'month_date', '\b(?<Month>Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)(\s|\.|\.\s)?(?<Date>\d+)'
insert into extraction_patterns select 2, 'tentative_easy_year', '(18[5-9][0-9])|(19[0-9][0-9])|(20(0|1)[1-5])'
insert into extraction_patterns select 3, 'date_american', '\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.]((?:19|20)?[0-9]{2})\b'
insert into extraction_patterns select 4, 'date_european', '\b(0?[1-9]|[12][0-9]|3[01])[- /.](0?[1-9]|1[012])[- /.]((?:19|20)?[0-9]{2})\b'
insert into extraction_patterns select 5, 'date_japan', '\b((?:19|20)?[0-9]{2})[- /.](0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])\b'
--source info
insert into extraction_patterns select 6, 'easy_pages', '(?<=(\bpages\b(\.|,)?\s*))(\d+)((?:(\s(?:to\s)?(?:-\s)?|-|/))?)(\d*)'
insert into extraction_patterns select 7, 'easy_volume', '(?<=(\bvol\s*))(\d+)'
insert into extraction_patterns select 8, 'easy_no', '(?<=(\bNo(\.|,|\.;)?\s*))(\d+)'
insert into extraction_patterns select 9, 'easy_xp', 'XP(\s|:)?(:|-)?(\s?)(\d){4,9}\b'
insert into extraction_patterns select 10, 'easy_issn', 'ISSN(:|\s)?(\s|:)?\s?(\d{4})(-|\s)?(-\s)?(\d{3,4})(\w?)\b'
insert into extraction_patterns select 11, 'easy_isbn', 'ISBN(\s|:)?(\s)?([0-9-x\s_]{10,17})\b'
--other
insert into extraction_patterns select 12, 'easy_bibliographic_type', 'Journal|Magazine|Abstract|Article'
insert into extraction_patterns select 13, 'easy_url', '\b(https?|ftp|file)://[A-Z0-9+&@#/%?=~_|$!:,.;-]*[A-Z0-9+&@#/%=~_|$]'
insert into extraction_patterns select 14, 'easy_email', '\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}\b'
insert into extraction_patterns select 15, 'bib_numeric', '[^0-9]+'
insert into extraction_patterns select 16, 'bib_alphabetic', '[^A-z ]+'
*/
--author
insert into extraction_patterns select 17, 'easy_aetal', '(([a-zA-Z,.]+\s?){1,4})(?=\bet(\.\s|\.|\s)?al)'
insert into extraction_patterns select 18, 'nameA', '([A-Z][a-z]+(?:\s|-)|[A-Z]+(\s|-)){1,3}([A-Z]\.?){1,3}\s([A-Z][a-z]+(\s|-)?|[A-Z]+(?:\s|-)?){1,3}'
insert into extraction_patterns select 19, 'nameA1', '\b([A-Z][a-z]+|[A-Z]{3,})(?:\s|-)([A-Z]\.?)(?:\s|-)([A-Z][a-z]+|[A-Z]{3,})'
insert into extraction_patterns select 20, 'nameB', '\b([A-Z](\.\s?)?){1,3}\s([A-Z][a-z]+(\s|-)?|[A-Z]{3,}(\s|-)?){1,3}\b'
insert into extraction_patterns select 21, 'nameB1', '(\b([A-Z](\.\s?|\s))([A-Z]{3,})\b)|(\b([A-Z](\.\s?|\s))([A-Z][a-z]+)\b)'
insert into extraction_patterns select 22, 'nameC', '\b([A-Z][a-z]+(\s|-)|[A-Z]{3,}(\s|-)){1,3}([A-Z](\.|\s|\.\s)?){1,3}\b'
insert into extraction_patterns select 23, 'nameC1', '(\b([A-Z](\.\s?|\s)){3}([A-Z]{3,}))|(\b([A-Z](\.\s?|\s)){3}([A-Z][a-z]+))'
insert into extraction_patterns select 24, 'nameD', '(((([A-Z][a-z]+)|([A-Z]{3,}))(?:\s|,|\b)){2,3})(?=,|;)'

--add index
create index idx_extraction_patterns on extraction_patterns(step)

--this table needs a column for each extracted pattern
if object_id('tls214_extracted_patterns') is not null drop table tls214_extracted_patterns
create table tls214_extracted_patterns
				(
				 npl_publn_id int not null,
				 --dates
				 month_date varchar(200),
				 tentative_easy_year varchar(200),
				 date_american varchar(200),
				 date_european varchar(200),
				 date_japan varchar(200),
				 sys_day int,
				 sys_month int,
				 sys_year int,
				 --source
				 easy_pages varchar(200),
				 easy_volume varchar(200),
				 easy_no varchar(200),
				 easy_xp varchar(200),
				 easy_issn varchar(200),
				 easy_isbn varchar(200),
				 --other
			     easy_bibliographic_type varchar(200),
			     easy_url varchar(400),
			     easy_email varchar(200),
				 bib_numeric varchar(1000),
                 bib_alphabetic varchar(max),
				 npl_biblio_length int,
				 sum_of_numbers int,
				 count_of_numbers int,
				 --author
				 easy_aetal nvarchar(400),
				 nameA nvarchar(400),
				 nameA1 nvarchar(400),
				 nameB nvarchar(400),
				 nameB1 nvarchar(400),
				 nameC nvarchar(400),
				 nameC1 nvarchar(400),
				 nameD nvarchar(400),
				 				 
				--etc
				)			
go

--populate table with npl_publn_ids
insert into tls214_extracted_patterns(npl_publn_id)
select npl_publn_id
--from [dbo].[tls214_npl_publn_unique]
from [dbo].[sample_unique]


--dates

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 1)
--in one go
update a
set a.month_date = b.month_date
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as month_date
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 2)
update a
set a.tentative_easy_year = b.tentative_easy_year
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as tentative_easy_year
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 3)
update a
set a.date_american = b.date_american, a.sys_day=b.a_day, a.sys_month=b.a_month, a.sys_year=b.a_year
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as date_american,
		dbo.GetGroups(npl_biblio, @pattern,1) as a_month,
		dbo.GetGroups(npl_biblio, @pattern, 2) as a_day,
		dbo.GetGroups(npl_biblio, @pattern, 3) as a_year
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id

go
--does this have results other than date american?
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 4)
update a
set a.date_european = b.date_european, a.sys_day=b.e_day, a.sys_month=b.e_month, a.sys_year=b.e_year
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as date_european,
		dbo.GetGroups(npl_biblio, @pattern,1) as e_day,
		dbo.GetGroups(npl_biblio, @pattern, 2) as e_month,
		dbo.GetGroups(npl_biblio, @pattern, 3) as e_year
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 5)
update a
set a.date_japan = b.date_japan, a.sys_day=b.j_day, a.sys_month=b.j_month, a.sys_year=b.j_year
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as date_japan,
		dbo.GetGroups(npl_biblio, @pattern,1) as j_year,
		dbo.GetGroups(npl_biblio, @pattern, 2) as j_month,
		dbo.GetGroups(npl_biblio, @pattern, 3) as j_day
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

--source

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 6)
update a
set a.easy_pages = b.easy_pages
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_pages
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

--
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 7)
update a
set a.easy_volume = b.easy_volume
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_volume
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 8)
update a
set a.easy_no = b.easy_no
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_no
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 9)
update a
set a.easy_xp = b.easy_xp
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_xp
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go
 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 10)
update a
set a.easy_issn = b.easy_issn
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_issn
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go				 

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 11)
update a
set a.easy_isbn = b.easy_isbn
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_isbn
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go	

--other
				 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 12)
update a
set a.easy_bibliographic_type = b.easy_bibliographic_type
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_bibliographic_type
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go		     

--error, 200 too small (right sie?)				 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 13)
update a
set a.easy_url  = b.easy_url 
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_url 
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go	

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 14)
update a
set a.easy_email  = b.easy_email 
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_email 
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go				     

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 15)
update a
set a.bib_numeric  = b.bib_numeric 
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.RegexReplace(dbo.RegexReplace(npl_biblio, @pattern,''), ' ', '') as bib_numeric
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go				     

--
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 16)
update a
set a.bib_alphabetic  = b.bib_alphabetic 
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.RegexReplace(npl_biblio, @pattern,'') as bib_alphabetic
	  --from [dbo].[tls214_npl_publn_unique]CharacterRemover
	  from [dbo].[sample_unique])
	  as b on a.npl_publn_id = b.npl_publn_id
go

--note 953459086
--not mutual exclusive

update a
set a.npl_biblio_length  = b.npl_biblio_length 
from tls214_extracted_patterns as a
join (select npl_publn_id, len(npl_biblio) as npl_biblio_length 
	  from [dbo].[sample_unique]
      where len(npl_biblio)> 0 ) as b on a.npl_publn_id = b.npl_publn_id
go

/*update a
set a.sum_of_numbers  = b.sum_of_numbers
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.SumIntDigits(bib_numeric) as sum_of_numbers
	  from tls214_extracted_patterns
      where bib_numeric is not null) as b on a.npl_publn_id = b.npl_publn_id */
go

update a
set a.count_of_numbers  = b.count_of_numbers
from tls214_extracted_patterns as a
join (select npl_publn_id, len(bib_numeric) as count_of_numbers
	  from tls214_extracted_patterns
      where len(bib_numeric)> 0) as b on a.npl_publn_id = b.npl_publn_id
go

--author

--error, defined too small?
			 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 17)
update a
set a.easy_aetal = b.easy_aetal
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_aetal
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.IsMatchValue(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go
			 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 18)
update a
set a.nameA = b.nameA
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameA
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.GetMatchesCSV(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go
			 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 19)
update a
set a.nameA1 = b.nameA1
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameA1
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.GetMatchesCSV(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go
			 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 20)
update a
set a.nameB = b.nameB
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameB
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.GetMatchesCSV(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go
			 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 21)
update a
set a.nameB1 = b.nameB1
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameB1
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.GetMatchesCSV(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go
			 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 22)
update a
set a.nameC = b.nameC
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameC
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.GetMatchesCSV(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go
			 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 23)
update a
set a.nameC1 = b.nameC1
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameC1
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.GetMatchesCSV(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go
			 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 24)
update a
set a.nameD = b.nameD
from tls214_extracted_patterns as a
join (select npl_publn_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameD
	  --from [dbo].[tls214_npl_publn_unique]
	  from [dbo].[sample_unique]
      where dbo.GetMatchesCSV(npl_biblio, @pattern) <> '') as b on a.npl_publn_id = b.npl_publn_id
go
			 

select easy_aetal, nameA, nameA1, nameB, nameB1, nameC, nameC1, nameD 
from tls214_extracted_patterns


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


--for testing
select top 100000 * 
from result_rule_2 as a
join sample_table as b on a.npl_publn_id1  = b.npl_publn_id 
join sample_table as c on a.npl_publn_id2  = c.npl_publn_id 

--PROC