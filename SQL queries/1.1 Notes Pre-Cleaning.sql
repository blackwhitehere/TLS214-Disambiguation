/*
--3. Remove multiple spaces - Inefficient method

while exists (select * from #tmp2 where (npl_biblio like '%  %'))
begin
  update #tmp2
  set npl_biblio=replace(npl_biblio,'  ',' ')
  where (npl_biblio like '%  %')
end
go


--3. Remove diacritics from string - Creates problems when joining tables
if object_id('#tmp3') is not null drop table #tmp3
select npl_publn_id, cast([npl_biblio] as varchar(max)) collate SQL_Latin1_General_CP1253_CI_AI as npl_biblio
into #tmp3 --3rd tmp
from #tmp2
go

*/

-------------------------------------
/*
--SAMPLE UNIQUE v.2 - does not provide good method to append duplicates to clusters in post processing

/*
Given npl_publn_id is a unique identifier, using the "group by" clause will remove duplicates of npl_biblio by 
grouping one distinct value of npl_biblio per its corresponding lowest npl_publn_id
*/

if object_id('#tmp4') is not null drop table #tmp4
select min(npl_publn_id) as npl_publn_id
into #tmp4
from #tmp3
group by npl_biblio

/*
"Results_pre_cleaning" is a set of duplicates obtained by calculating a difference between original set and a
set that contains only distinct values. 
These duplicate records have to be added to the clusters later
*/

if object_id('results_pre_cleaning') is not null drop table results_pre_cleaning
select npl_publn_id
into results_pre_cleaning
from #tmp3
except
select npl_publn_id
from #tmp4

--Restore original capitalization after removing duplicates based on capitalization
if object_id('sample_unique') is not null drop table sample_unique
select a.*
into sample_unique
from #tmp2 as a --last step before applying lowercase function
join #tmp4 as b on a.npl_publn_id = b.npl_publn_id

--Create a referencial integrity constraint
alter table sample_unique add constraint pk_sample_unique_id primary key (npl_publn_id)

*/
