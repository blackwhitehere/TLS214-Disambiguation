-------
--NOTES
-------

/*
After Cleaning stage obvious duplicates can be detected in line of the detecetion performed in the Pre Cleaning stage.
Additional stage can be added that strips npl_biblio of special characters.
After such a deduplication npl_biblio with special characters is reverted back to be used in the further analysis just like lowercase was in PreCleaning. 
There is no implementation of this step.
*/

/*
-- 3. StripCharacters function [Can output numeric, alphabetic and alphanumeric characters]

if object_id('#tmp') is not null drop table #tmp
select npl_publn_id, npl_biblio, 
           dbo.fn_StripCharacters(npl_biblio, '^a-z0-9') as bib_alphanumeric --spaces removed
		   --,dbo.fn_StripCharacters(npl_biblio, '^0-9') as bib_numeric
		   --,dbo.fn_StripCharacters(npl_biblio, '^a-z') as bib_alphabetic
into #tmp
from sample_unique
go

if object_id('sample_unique2') is not null drop table sample_unique2
create table sample_unique2(
	npl_publn_id int identity(1,1) not null,
	npl_biblio nvarchar(max) not null
constraint pk_sample_unique2_id primary key (npl_publn_id))
go

--Populate table with distinct values for npl_biblio
insert into sample_unique2(npl_biblio)
select distinct bib_alphanumeric
from sample_unique
order by bib_alphanumeric
go

--Fill glue table 
if object_id('sample_glue2') is not null drop table sample_glue2
select a.npl_publn_id as npl_publn_id_new, b.npl_publn_id
into sample_glue2
from sample_unique2 as a
join sample_unique as b on a.npl_biblio = b.npl_biblio
go

*/

------------------------------------------------------------
--TESTING -- IN PROCESS

--Special Character Remover Test
if object_id('#tmp1') is not null drop table #tmp1
go

select npl_publn_id, npl_biblio, dbo.SpecialCharacterRemover(npl_biblio) as scr_biblio -- spaces left
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

