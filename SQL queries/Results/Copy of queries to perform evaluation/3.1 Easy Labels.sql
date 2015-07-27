--EASY LABELS EXTRACTION PATTERNS

/*
So called "easy labels" are obtained based on existance of "tags" or "flags" within the npl_biblio.
E.g. the flag "pages" obtained in the Cleaning stage is used to extract digits (presumed page numbers) that are following the flag.
*/

use patstat_performance
go

-- Create a table for specifing patterns for change
if object_id('extraction_patterns') is not null drop table extraction_patterns
create table extraction_patterns
				(
				step int not null
				,extraction_label varchar(100) not null
				,extraction_pattern varchar(200) not null
				,reg_exp_id int identity(1,1) not null
				constraint pk_extraction_patterns_id primary key (reg_exp_id)
				)
go

--Populate table

--dates
insert into extraction_patterns select 1,	'month_date',				'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\s\d+'
insert into extraction_patterns select 4,	'tentative_easy_year',		'(18[5-9][0-9])|(19[0-9][0-9])|(200[0-9])|(201[0-5])'
insert into extraction_patterns select 5,	'date_american',			'\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.]((?:19|20)?[0-9]{2})\b'
insert into extraction_patterns select 6,	'date_european',			'\b(0?[1-9]|[12][0-9]|3[01])[- /.](0?[1-9]|1[012])[- /.]((?:19|20)?[0-9]{2})\b'
insert into extraction_patterns select 7,	'date_japan',				'\b((?:19|20)?[0-9]{2})[- /.](0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])\b'
--source info
insert into extraction_patterns select 10,	'easy_pages',				'((?<=(\bpages\s))(\d+)((?:(\s(?:to\s)?|-|/))?)(\d*))|(((\b\d*(\s(to\s)?|-|/))?(\d+))(?=\spages))'
insert into extraction_patterns select 11,	'easy_volume',				'((?<=(\bvol\s?))(\d+\w*))|(\d+(?=\svol\b))'
insert into extraction_patterns select 12,	'easy_no',					'(?<=(\bno\s))([\d/]+)'
insert into extraction_patterns select 13,	'easy_xp',					'XP(\s|:)?(:|-)?(\s?)(\d){4,9}\b'
insert into extraction_patterns select 14,	'easy_issn',				'ISSN(:|\s)?(\s|:)?\s?(\d{4})(-|\s)?(-\s)?(([\dX]){3,4})\b'
insert into extraction_patterns select 15,	'easy_isbn',				'ISBN(\s|:)?(\s)?([0-9-x\s_]{10,17})\b'
insert into extraction_patterns select 16,	'easy_appln_no',			'(?<=(\bappln\sno\s))([\d/,a-zA-Z]+)'
insert into extraction_patterns select 20,	'easy_bibliographic_type',	'magazine|abstract|article|(\bjour\b)|appln|(\bproc\b)|publn|science|(\bchem\b)|natl|(\bpct\b)'
--et. al
insert into extraction_patterns select 24,	'easy_aetal',				'(\b[a-zA-Z,.]+\s){1,4}(?=\bet\.\sal)'
--special
insert into extraction_patterns select 101,	'xp_number',				'^[0]+'
insert into extraction_patterns select 103, 'useless',					'See\s(also\s)?references\sof\s(EP|WP|WO)'
insert into extraction_patterns select 104, 'useless2',					'(?i)(&#x)|(\bpct\b)|(\b(appln|publn)\s(serial)?\s?(n(o|0)\.?|pct))'

--Also available if needed:
--easy hyphen - things between hyphens
--easy brackets - things between brackets
--easy company - few abbreviations for company types
--easy country - few 3 letter country codes for global economies
--easy science - few field of science names

--Potentialy useful:
--capital letters only: if part of biblio is not capitalize, capital letters decode important info, like author or title

--add index
create index idx_extraction_patterns on extraction_patterns(step)

--Create a table with initials columns for each of the extracted labels
if object_id('tls214_extracted_patterns') is not null drop table tls214_extracted_patterns
create table tls214_extracted_patterns
	(
		new_id int not null,
	--Sub expressions
		--dates
		month_date_day int,
		month_date_month int,
		month_date_year int,
		sys_day int,
		sys_month int,
		sys_year int,
	--Residual
		residual nvarchar (max)

	constraint pk_tls214_extracted_patterns_id primary key (new_id)
	)			
go

--Add new columns to the extraction_patterns table to store results of regular expressions

declare @counter int = 1
declare @count_max int = (select count(*) from extraction_patterns)


while (@counter<=@count_max)
begin
	declare @label nvarchar(max)=(select extraction_label from extraction_patterns where reg_exp_id=@counter)
	declare	@sql nvarchar(max) ='alter table tls214_extracted_patterns add '+@label+' nvarchar(max) '
	exec	(@sql)
	set		@label=''
	set		@counter=@counter+1
end
go

--Populate table with new_ids and npl_biblio into residual field
insert into tls214_extracted_patterns(new_id, residual)
select new_id, npl_biblio
from [dbo].[sample_unique]

--------
--DATES:
--------

--month_date

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 1)
update	a
set		a.month_date = b.month_date
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,'  &&&  ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as month_date									
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--tentative_easy_year

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 4)
update a
set		a.tentative_easy_year = b.tentative_easy_year
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	
		tls214_extracted_patterns as a
join	(
		select new_id
		,convert(int, dbo.IsMatchValue(npl_biblio, @pattern)) as tentative_easy_year
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--date_american

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 5)
update a
set		a.date_american = b.date_american
		,a.sys_day=b.a_day
		,a.sys_month=b.a_month
		,a.sys_year=b.a_year
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	
		tls214_extracted_patterns as a
join	(
		select new_id
		,dbo.IsMatchValue(npl_biblio, @pattern) as date_american
		,dbo.GetGroups(npl_biblio, @pattern, 1)	as a_month
		,dbo.GetGroups(npl_biblio, @pattern, 2) as a_day
		,dbo.GetGroups(npl_biblio, @pattern, 3) as a_year
		
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--date_european

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 6)
update a
set		a.date_european = b.date_european
		,a.sys_day=b.e_day
		,a.sys_month=b.e_month
		,a.sys_year=b.e_year
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id
		,dbo.IsMatchValue(npl_biblio, @pattern) as date_european
		,dbo.GetGroups(npl_biblio, @pattern,1)	as e_day
		,dbo.GetGroups(npl_biblio, @pattern, 2) as e_month
		,dbo.GetGroups(npl_biblio, @pattern, 3) as e_year
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--date_japan

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 7)
update a
set		a.date_japan = b.date_japan
		,a.sys_day=b.j_day
		,a.sys_month=b.j_month
		,a.sys_year=b.j_year
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id
		,dbo.IsMatchValue(npl_biblio, @pattern) as date_japan,
		dbo.GetGroups(npl_biblio, @pattern,1)	as j_year,
		dbo.GetGroups(npl_biblio, @pattern, 2)	as j_month,
		dbo.GetGroups(npl_biblio, @pattern, 3)	as j_day
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--source

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 10)
update a
set		a.easy_pages = b.easy_pages
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_pages
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--volume
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 11)
update a
set		a.easy_volume = b.easy_volume
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_volume
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--issue

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 12)
update a
set		a.easy_no = b.easy_no
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_no
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--easy xp

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 13)

--Remove patterns between 'XP' and the number: ' ','-',':'

if object_id('tempdb.dbo.#tmp') is not null drop table #tmp
select new_id,
upper	(
			ltrim --check
			(
				replace
				(
					replace
					(
						replace
						(
							dbo.IsMatchValue(npl_biblio, @pattern)
						,' ', ''
						)
					,'-',''
					)
				,':',''
				)
			)
		) as easy_xp
into #tmp
from [dbo].[sample_unique]
where dbo.IsMatchValue(npl_biblio, @pattern) <> ''

--Harmonization: Convert matches to format with leading zeros.

if object_id('tempdb.dbo.#tmp2') is not null drop table #tmp2
select new_id, 
  case
	when len(easy_xp) = 11 then easy_xp
	when len(easy_xp) = 9 and substring(easy_xp, 3, 1) <> 0 then ('XP' + '00' + right(easy_xp, 7))
	when len(easy_xp) = 8 and substring(easy_xp, 3, 1) <> 0 then ('XP' + '000' + right(easy_xp, 6))
	when len(easy_xp) = 7 and substring(easy_xp, 3, 1) <> 0 then ('XP' + '0000' + right(easy_xp, 5))
	when len(easy_xp) = 6 and substring(easy_xp, 3, 1) <> 0 then ('XP' + '00000' + right(easy_xp, 4))
  end as easy_xp
into #tmp2
from #tmp
where easy_xp is not null --isn't this enforced by "where dbo.IsMatchValue(npl_biblio, @pattern) <> ''"?


--Update tls214_extracted_patterns with harmonized XP numbers

update	a
set		a.easy_xp = b.easy_xp
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, easy_xp
		from #tmp2
		where easy_xp is not null
		)
		as b on a.new_id = b.new_id
go

--Pure XP number: extracts only numeric characters, converts to int (and removes leading zeros)

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 101)
update	a
set		a.xp_number = b.xp_number
from	tls214_extracted_patterns as a
join	(
		select new_id, convert(int, dbo.RegexReplace((right(easy_xp, 9)), @pattern,'')) as xp_number 
		from #tmp2
		where easy_xp is not null
		)
		as b on a.new_id = b.new_id
go

--Clean up
if object_id('tempdb.dbo.#tmp') is not null drop table #tmp
if object_id('tempdb.dbo.#tmp2') is not null drop table #tmp2
go

--easy_issn

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 14)
update a
set		a.easy_issn = b.easy_issn
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_issn
		
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--easy_isbn

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 15)
update a
set		a.easy_isbn = b.easy_isbn
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_isbn
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--appln no

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 16)
update a
set		a.easy_appln_no = b.easy_appln_no
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_appln_no
		
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--other

--easy_bibliographic_type
				 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 20)
update a
set		a.easy_bibliographic_type = b.easy_bibliographic_type
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_bibliographic_type 
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--et. al
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 24)
update a
set		a.easy_aetal = b.easy_aetal
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,'&&&')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_aetal
		--from [dbo].[tls214_npl_publn_unique]
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--useless

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 103)
update a
set		a.useless  = b.useless
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatch(npl_biblio, @pattern) as useless
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern)<>''
		)
		as b on a.new_id = b.new_id
go

--useless2

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns where step = 104)
update a
set		a.useless2  = b.useless2
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatch(npl_biblio, @pattern) as useless2
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern)<>''
		)
		as b on a.new_id = b.new_id
go


--add index, last step
create index idx_tls214_extracted_patterns on tls214_extracted_patterns(new_id)
go

--insepct
select * 
from tls214_extracted_patterns