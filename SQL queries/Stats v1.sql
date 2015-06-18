--DISAMBIGUATION SOLUTION
--EDA, STATISTICS AND REPORTING QUERIES

use patstat
go

/*
I think it is best to put this in a separate file, where
all kind of relevant statistics are produced
- ISSN
- ISBN
- Journal
... and so on
*/

---------------------
-- 2. BASIC TESTS:

--count n of records (different on each run)
select count(distinct npl_biblio) 
from sample_table
--96160

--count amount of ISSN numbers with a crude like statement
select count(*) 
from sample_table as sa
where sa.npl_biblio like '%ISSN%'
--2%

--count amount of ISBN numbers with a crude like statement
select count(*) 
from sample_table as sa
where sa.npl_biblio like '%ISBN%'
go
--0,5%

/*
to use fulltext indexing, you need unique appearances of npl_biblio, this is not the case in the sample
*/
----------------------
-- 3. FULLTEXT:

drop table sample_table_unique
select min(npl_publn_id) as npl_publn_id, npl_biblio as npl_biblio
into sample_table_unique
from sample_table
group by npl_biblio
--98095 records

--prim. key cannot be nullable
alter table [sample_table_unique] 
alter column [npl_publn_id] int not null;

--add prim. key
alter table [sample_table_unique] add constraint pk_npl_publn_id primary key (npl_publn_id)

--drop index and catalog & create new
if object_id('sample_table') is not null drop fulltext index on sample_table
go

if object_id('sample_table_catalog') is not null drop fulltext catalog sample_table_catalog
go

create fulltext catalog sample_table_catalog
go

create fulltext index on sample_table_unique(npl_biblio)
key index pk_npl_publn_id on sample_table_catalog
with stoplist off, change_tracking off, no population
go

--turn the index on
alter fulltext index on sample_table_unique
start full population
go

--Test fulltext:
--count amount of XP numbers with fulltext search
select *
from sample_table_unique as sa
where contains (npl_biblio, '"XP*" OR "XP"')
--5342 records

--something like this would be the alternative, much slower, 
select *
from sample_table_unique
where npl_biblio like '% XP%' 
union 
select *
from sample_table_unique
where npl_biblio like '% XP %' 

select *
from sample_table_unique 
where contains (npl_biblio, 'Codd')
--2 records

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