--PRE-CLEANING

use patstat
go

-----------------------
--SAMPLE

/*
Sample namespace is used to speed up development and testing.
If one needs to perform the analysis on the full dataset delete the row 'tablesample (X rows)' in the select statement below.
*/

--Load a 'sample_table' with X sample records from the original table

if object_id('sample_table') is not null drop table sample_table

select * 
into sample_table
from tls214_npl_publn
tablesample (100000 rows)

--Create a referencial integrity constraint
alter table sample_table add constraint pk_sample_id primary key (npl_publn_id)

-----------------------
--CLEANSING

/*
Four basic, string related cleaning modifications are applied to npl records.
The aim is not to interfere with the information content.
*/

--1. Remove leading & lagging whitespaces, multiple whitespaces and diacritics

if object_id('#tmp1') is not null drop table #tmp1
go
select npl_publn_id,
		rtrim(
			ltrim
				(
				dbo.RemoveDiacritics(dbo.RegexReplace(npl_biblio,' {2,}',' '))
				)
			)
	as npl_biblio
into #tmp1 --1st tmp
from sample_table
go

--2. If biblio ends with a dot remove the dot, else leave as is

if object_id('#tmp2') is not null drop table #tmp2
select npl_publn_id,
	iif(
	(substring(npl_biblio, len(npl_biblio), 1) = '.'), left(npl_biblio, len(npl_biblio) - 1), npl_biblio)
	as npl_biblio
into #tmp2 --2nd tmp
from #tmp1
go

---Drop not needed temp tables

drop table #tmp1
go

--3. Apply lowercase
if object_id('#tmp3') is not null drop table #tmp3
select npl_publn_id, lower(npl_biblio) as npl_biblio
into #tmp3 --3rd tmp
from #tmp2
go


-----------------------
-- SAMPLE_UNIQUE AND GLUE_TABLE

/*
At this step duplicates are detected.
Distinct records are passed on to sample_unique table.
Sample_unique uses a new ID - "new_id" to avoid confusion with using original values of npl_publn_id.
"new_id" can be viewed as a unique identifier of a group of duplicates.
References to the original ID - npl_biblio_id are saved in the glue_table.
Duplicates from sample_table are assigned a single new_id - i.e. a single new_id can be paired with multiple npl_biblio_id(s)
As a result, in the post-processing stage all duplicates that are deteced in the sample_table
can be appended to a cluster that contains a new_id record.
*/

--Create new table to store pre-cleaned data

if object_id('sample_unique') is not null drop table sample_unique
create table sample_unique
	(
	new_id int identity(1,1) not null
	,npl_biblio nvarchar(3100) not null
	constraint pk_sample_unique_id primary key (new_id)
	)
go


--Create an index on npl_biblio

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'index_sample_unique_npl_biblio')
    DROP INDEX index_sample_unique_npl_biblio ON tls214_npl_publn;
GO
create index index_sample_table_npl_biblio on tls214_npl_publn (npl_biblio) online = on
go

--Populate table with distinct values of npl_biblio

insert into		sample_unique(npl_biblio)
select distinct npl_biblio
from			#tmp3
order by		npl_biblio
go

--Save references of duplicated records to the sample_table

if object_id('sample_glue') is not null drop table sample_glue
select	a.new_id, b.npl_publn_id
into	sample_glue
from	sample_unique	as a
join	#tmp3			as b on a.npl_biblio = b.npl_biblio
go

--Add PK
alter table sample_glue add constraint pk_sample_glue primary key (new_id, npl_publn_id)
go

--Restore original capitalization after removing duplicates without capitalization patterns

update	a
set		a.npl_biblio = c.npl_biblio
from	sample_unique	as a
join	sample_glue		as b on a.new_id=b.new_id
join	#tmp2			as c on b.npl_publn_id=c.npl_publn_id --#tmp2 is a table that stores precleaned results one step before applying lowercase

-- Drop not needed tmp tables

drop table #tmp2
drop table #tmp3
go

--Visualize

select * from sample_unique