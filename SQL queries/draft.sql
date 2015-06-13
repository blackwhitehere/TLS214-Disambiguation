--General Project Page
--Data Cleansing and Disambiguation of PATSTAT TLS214 

--use db with tls214 tableuse patstat 
go
---------------------
-- 1. SAMPLE TABLE:
-- Final step will replace all use of sample_table with tls214_npl_publn
/*drop sample_table:
create table sample_table (
		npl_publn_id int identity(1,1) not null,
		npl_biblio nvarchar(max) not null,
		constraint pk_sample_id primary key (npl_publn_id)
		)
*/
if object_id('sample_table') is not null drop table sample_table 
go

--load sample_table with 100'000 sample records from the original table
select * 
into sample_table
from tls214_npl_publn
tablesample (100000 ROWS)
go

-- makes sample_table identical to original table
alter table sample_table ADD constraint pk_sample_id primary key (npl_publn_id)
go

---------------------
-- 2. BASIC TESTS:

--count n of records (different on each run)
select count(distinct npl_biblio) 
from sample_table
go
--96160

--count amount of ISSN numbers with a crude like statement
select count(*) 
from sample_table as sa
where sa.npl_biblio like '%ISSN%'
go
--2%

--count amount of ISBN numbers with a crude like statement
select count(*) 
from sample_table as sa
where sa.npl_biblio like '%ISBN%'
go
--0,5%

----------------------
-- 3. FULLTEXT:

--drop index and catalog & create new
if object_id('sample_table') is not null drop fulltext index on sample_table
go

if object_id('sample_table_catalog') is not null drop fulltext catalog sample_table_catalog
go

create fulltext catalog sample_table_catalog
go

create fulltext index on sample_table(npl_biblio)
key index pk_npl_publn_id on sample_table_catalog
with stoplist off, change_tracking off, no population
go

--turn the index on
alter fulltext index on sample_table
start full population
go

--Test fulltext:
--count amount of XP numbers with fulltext search
select *
from sample_table as sa
where contains (sa.npl_biblio, '"XP*" OR XP')
go

select *
from sample_table 
where contains (npl_biblio, 'Codd')
go

-----------------------
-- 4. CLEANSING

-- 4.1. PRECLEANING:
-- Step:

--1
--change to lowercase, remove leading and lagging blanks, double spaces removed
if object_id('#tmp1') is not null drop table #tmp1
go

select npl_publn_id,
	lower(
		rtrim(
			ltrim(
				replace(npl_biblio,'  ',' ')
				)
			)
		)
	as npl_biblio
into #tmp1 --1st tmp
from sample_table
go

--2
--if biblio ends with a dot remove the dot, else leave as is

if object_id('#tmp2') is not null drop table #tmp2
select npl_publn_id,
	iif(
	(substring(npl_biblio, len(npl_biblio), 1) = '.'), left(npl_biblio, len(npl_biblio) - 1), npl_biblio)
	as npl_biblio
into #tmp2 --2nd tmp
from #tmp1

/* -- This can be done with regular expressions
--3
--remove diacritics from string
if object_id('#tmp3') is not null drop table #tmp3
select npl_publn_id, cast([npl_biblio] as varchar(max)) collate SQL_Latin1_General_CP1253_CI_AI as npl_biblio
into #tmp3 --3rd tmp
from #tmp2
go

drop table #tmp2
go
*/
go

--4
--remove multiple spaces
while exists (select * from #tmp2 where (npl_biblio like '%  %'))
begin
  update #tmp2
  set npl_biblio=replace(npl_biblio,'  ',' ')
  where (npl_biblio like '%  %')
end
go

---drop not needed temp tables
drop table #tmp1
--...
go
--------------------------
-- 4.2 Glue Table
--After the pre-cleaning we can work with a smaller table

--Create new table to store precleaned data
if object_id('sample_unique') is not null drop table sample_unique
create table sample_unique(
	npl_publn_id int identity(1,1) not null,
	npl_biblio nvarchar(max) not null
constraint pk_sample_unique_id primary key (npl_publn_id))
go

--Populate table with distinct values for npl_biblio
insert into sample_unique(npl_biblio)
select distinct npl_biblio
from #tmp2
order by npl_biblio
go

--Fill glue table 
if object_id('sample_glue') is not null drop table sample_glue
select a.npl_publn_id as npl_publn_id_new, b.npl_publn_id
into sample_glue
from sample_unique as a
join #tmp2 as b on a.npl_biblio = b.npl_biblio
go

-- Drop not needed tmp table
drop table #tmp2
go

-----------------------------------
-- 4.3a CLEANING [PATTERNS]

-- Create a table for specifing patterns for change
if object_id('cleaning_patterns') is not null drop table cleaning_patterns
create table cleaning_patterns
				(step int not null,
				cleaning_pattern varchar(100) not null,
				cleaning_source varchar(100) not null,
				cleaning_label varchar(100) not null)
go

--pages
insert into cleaning_patterns select 1, '% pp. %',  ' pp. ', ' pages ' --'%*pp %'
insert into cleaning_patterns select 1, '%,pp. %',  ',pp. ', ', pages ' --'%*pp.%' 
insert into cleaning_patterns select 1, '% page %', ' page ', ' pages '
insert into cleaning_patterns select 1, '%,page %', ',page ', ', pages '
insert into cleaning_patterns select 1, '%,pages %', ',pages ', ', pages '
insert into cleaning_patterns select 1, '% page(s) %', ' page(s) ',  ' pages '
insert into cleaning_patterns select 1, '% pages.%', ' pages.',  ' pages'
insert into cleaning_patterns select 1, '% seiten %', ' seiten ', ' pages '
insert into cleaning_patterns select 1, '% seiten.%', ' seiten.', ' pages'
insert into cleaning_patterns select 1, '% seite %', ' seite ', ' pages '
insert into cleaning_patterns select 1, '% feuilles %', ' feuilles ', ' pages '

insert into cleaning_patterns select 2, '% p. [0-9]%', ' p. ', ' pages '
insert into cleaning_patterns select 2, '%,p. [0-9]%', ',p. ', ', pages '

insert into cleaning_patterns select 3, '% bd. %', ' bd. ' ,' vol '
insert into cleaning_patterns select 3, '% vol. %',' vol. ',' vol '
insert into cleaning_patterns select 3, '%,vol. %',',vol. ',', vol '
insert into cleaning_patterns select 3, '% v. [0-9]%',' v. ',' vol '
insert into cleaning_patterns select 3, '% volume [0-9]%',' volume ',' vol '
insert into cleaning_patterns select 3, '% b. [0-9]%', ' b. ', ' vol '

--issue
insert into cleaning_patterns select 4, '% no. %', ' no. ', ' no '
insert into cleaning_patterns select 4, '%,no. %', ',no. ', ', no '
insert into cleaning_patterns select 4, '% nr. %', ' nr. ',' no '
insert into cleaning_patterns select 4, '%,nr. %', ',nr. ',', no '
insert into cleaning_patterns select 4, '% n. [0-9]%', ' n. ', ' no '
insert into cleaning_patterns select 4, '% heft %', ' heft ',' no '

--proceedings
insert into cleaning_patterns select 5, '% proc. %', ' proc. ', ' proc '
insert into cleaning_patterns select 5, '% proceedings %', ' proceedings ', ' proc '

--science
insert into cleaning_patterns select 6, '% sci. %', ' sci. ', ' science '

--et al.
insert into cleaning_patterns select 7, '% et al.%', ' et al.', ' et. al'
insert into cleaning_patterns select 7, '% et. al.%', ' et. al.', ' et. al'

--chemical
insert into cleaning_patterns select 8, '% chemical %', ' chemical ', ' chem. '
insert into cleaning_patterns select 8, '% chem %', ' chem ', ' chem. '

--national
insert into cleaning_patterns select 9, '% national %', ' national ', ' natl. '
insert into cleaning_patterns select 9, '% natl %', ' natl ', ' natl. '

--[ - ]
insert into cleaning_patterns select 10, '%[0-9] - [0-9]%', ' - ', '-'

--months
insert into cleaning_patterns select 11, '% jan. %', ' jan. ', ' jan ' -- is this case sensitive?
insert into cleaning_patterns select 11, '% january %', ' january ', ' jan '
insert into cleaning_patterns select 11, '% feb. %', ' feb. ', ' feb '
insert into cleaning_patterns select 11, '% february %', ' february ', ' feb '
insert into cleaning_patterns select 11, '% mar. %', ' mar. ', ' mar '
insert into cleaning_patterns select 11, '% march %', ' march ', ' mar '
insert into cleaning_patterns select 11, '% apr. %', ' apr. ', ' apr '
insert into cleaning_patterns select 11, '% april %', ' april ', ' apr '
insert into cleaning_patterns select 11, '% jun. %', ' jun. ', ' jun '
insert into cleaning_patterns select 11, '% june %', ' june ', ' jun '
insert into cleaning_patterns select 11, '% jul. %', ' jul. ', ' jul '
insert into cleaning_patterns select 11, '% july %', ' july ', ' jul '
insert into cleaning_patterns select 11, '% aug. %', ' aug. ', ' aug '
insert into cleaning_patterns select 11, '% augustus %', ' augustus ', ' aug '
insert into cleaning_patterns select 11, '% sep. %', ' sep. ', ' sep '
insert into cleaning_patterns select 11, '% sept. %', ' sept. ', ' sep '
insert into cleaning_patterns select 11, '% september %', ' september ', ' sep '
insert into cleaning_patterns select 11, '% oct. %', ' oct. ', ' oct '
insert into cleaning_patterns select 11, '% october %', ' october ', ' oct '
insert into cleaning_patterns select 11, '% nov. %', ' nov. ', ' nov '
insert into cleaning_patterns select 11, '% november %', ' november ', ' nov '
insert into cleaning_patterns select 11, '% dec. %', ' dec. ', ' dec '
insert into cleaning_patterns select 11, '% december %', ' december ', ' dec '

--add index
create index idx_cleaning_patterns on cleaning_patterns(cleaning_pattern)

-------------------
-- 4.3b Execute the changes specified in the cleaning table

--initialization
declare @loopcounter int = 1
declare @loopmax int = (select max(step) from cleaning_patterns)

--loop - if a pattern is found on a step, replace it
while (@loopcounter <= @loopmax)
begin
    
	update a
	set a.npl_biblio = replace(a.npl_biblio, b.cleaning_source, b.cleaning_label) -- replace biblio's substring with its label 
	from sample_unique as a
	join cleaning_patterns as b on patindex(b.cleaning_pattern, a.npl_biblio) <> 0 --provided a pattern is found
	where step = @loopcounter
	set @loopcounter += 1
end
go

-----------------------
-- 4.3c FULLTEXT on sample_unique 

--Test for achieved reduction in distinct records in pre-sampling stage
select count(distinct a.npl_biblio)
from sample_unique as a
go
--3%

--FULLTEXT
if object_id('sample_unique') is not null drop fulltext index on sample_unique
go

create fulltext index on sample_unique(npl_biblio)
key index pk_sample_unique_id on sample_table_catalog
with stoplist off, change_tracking off, no population
go

--turn the index on
alter fulltext index on sample_table
start full population
go

--Test fulltext:
--check for approx. amount of XP numbers 
select count(*)
from sample_unique as su
where contains (su.npl_biblio, '"XP*"')
go
--9%

------------------------
-- 4.4 SQL & CLR USER DEFINED FUNCTIONS

-- 4.4.1 -- StipCharacters
if object_id('fn_StripCharacters') is not null drop function [dbo].[fn_StripCharacters]
go

create function [dbo].[fn_StripCharacters]
(
    @string nvarchar(max), 
    @matchexpression varchar(255)
)
returns nvarchar(max)
as
begin
    set @matchexpression =  '%['+@matchexpression+']%'

    while patindex(@matchexpression, @string) > 0
        set @string = stuff(@string, patindex(@matchexpression, @string), 1, '') --deletes found expression from string

    return @string -- opposite of matched expression is returned

end
go

--F0 - StripCharacters function
-- Outputs numeric, alphabetic and alphanumeric characters only
if object_id('#tmp') is not null drop table #tmp
go

select top 10000 npl_publn_id, npl_biblio, 
           dbo.fn_StripCharacters(npl_biblio, '^a-z0-9') as bib_alphanumeric,
		   dbo.fn_StripCharacters(npl_biblio, '^0-9') as bib_numeric,
		   dbo.fn_StripCharacters(npl_biblio, '^a-z') as bib_alphabetic
into #tmp
from sample_unique
go

-- 4.4.2 -- CLR

--Enable CLR
sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

--Drop assembly
if object_id('RegExp') is not null drop assembly RegExp --TODO: change conditional to correct form
go

-- Creste assembly
CREATE ASSEMBLY RegExp 
from 'C:\Users\stan\Documents\GitHub\TLS214-Disambiguation\VS\Disambiguation\Sample\bin\Debug\Sample.dll' 
WITH PERMISSION_SET = SAFE
go

--F1 - Levenshtein distance
if object_id('LD') is not null drop function LD
go

CREATE FUNCTION	LD (@string1 nvarchar(max), @string2 nvarchar(max))
RETURNS	int
AS EXTERNAL NAME RegExp.UserDefinedFunctions.ComputeDistance;
go

--F2 - Levenshtein distance Percentage
if object_id('LDPerc') is not null drop function LDPerc
go

CREATE FUNCTION	LDPerc (@string1 nvarchar(max), @string2 nvarchar(max))
RETURNS	float
AS EXTERNAL NAME RegExp.UserDefinedFunctions.ComputeDistancePerc;
go

--F3 - Special Character Removes
--Can replace/delete a specified RegExp expression in npl_biblio

if object_id('SCR') is not null drop function SCR
go

CREATE FUNCTION	SCR (@string1 nvarchar(max))
RETURNS nvarchar(max)
AS EXTERNAL NAME RegExp.UserDefinedFunctions.SpecialCharacterRemover;
go

--F4 - SumOfNum - Calculates sum of numbers statitic per each biblio
if object_id('SumOfNum') is not null drop function SumOfNum
go

CREATE FUNCTION SumOfNum (@input nvarchar(max))
RETURNS bigint
AS EXTERNAL NAME RegExp.UserDefinedFunctions.SumOfNum
go

--test if functions work

select dbo.LD('sample','hellllllo')
select dbo.LDPerc('hello','helko')
select dbo.SCR('sample_^^^table')
select dbo.SumOfNum('bleble9bleble 90 1 [150]4')
go

-- Test
if object_id('#tmp1') is not null drop table #tmp1
go

select npl_publn_id, npl_biblio, dbo.SCR(npl_biblio) as scr_biblio
into #tmp1
from sample_unique

select npl_publn_id, scr_biblio, dbo.SumOfNum(scr_biblio) as NSM
into #tmp2
from #tmp1

select NSM, count(NSM) as freq
from #tmp2
group by NSM
order by freq desc
go


------------------------------------------------------------
--TESTING -- IN PROCESS

---------
--Find Labels

create function fn_RE (@biblio nvarchar(max), @pattern nvarchar(max))
returns table (match_index int, match_length int, match_value nvarchar(max))
external name RegExp.UserDefinedFunctions.GetMatches
go

if OBJECT_id('RegExpTank') is not null drop table RegExpTank
go
create table RegExpTank (regexp_id int, pattern nvarchar(max))
go

insert into RegExpTank select 1, '(19|20)[0-9]{2}[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])'
--and so on
go

if OBJECT_id('RegExpSMatches') is not null drop table RegExpSMatches
go
create table RegExpSMatches (
				tuple_id int identity(1,1) not null,
				su_id int not null,
				regexp_id int,
				match_index int,
				match_length int, 
				match_value nvarchar(max),
				constraint pk_REsM_id primary key (tuple_id))
go
--initialization

declare @counter_tuples int = 1
declare @maxcounter_tuples int = (select count(*) from sample_unique) --or (select max(npl_publn_id) from sample_unique)
declare @maxtank_steps int = (select count(*) from RegExpTank)
declare @tank_steps int = 1

--2 stage RegExp search
while (@counter_tuples <= @maxcounter_tuples)
begin
	while (@tank_steps <= @maxtank_steps)
	begin
		set @tank_steps = 1

		if object_id('#tmp') is not null drop table #tmp

		select dbo.fn_RE(npl_biblio, pattern) -- returns matches for current reg exp and biblio
		into #tmp
		from sample_unique as su join RegExpTank as ret on su.npl_publn_id=@counter_tuples --the idea is to use cartesian product
		where ret.regexp_id=@tank_steps  

		alter table #tmp add su_id int
		alter table #tmp add regexp_id int
		update #tmp set su_id=@counter_tuples;
		update #tmp set regexp_id=@tank_steps;

		insert into RegExpSMatches (su_id, regexp_id, match_index, match_length, match_value)
		select * from #tmp;

		set @tank_steps += 1;
	end
	set @counter_tuples += 1;
end
go

-------