
--Example negative rule
if object_id('result_rule_1') is not null drop table result_rule_1
select distinct a.npl_publn_id as npl_publn_id1, b.npl_publn_id as npl_publn_id2
into result_rule_1
from tls214_extracted_patterns as a
join tls214_extracted_patterns as b on
a.tentative_easy_year = b.tentative_easy_year
and a.month1 = b.month1
and a.bib_alphabetic= b.bib_alphabetic
where a.npl_publn_id <> b.npl_publn_id and a.bib_numeric <> b.bib_numeric


--Example rule with use of levenshtein, excluding results from negatieve rule
if object_id('result_rule_2') is not null drop table result_rule_2
select distinct a.npl_publn_id as npl_publn_id1, b.npl_publn_id as npl_publn_id2
into result_rule_1
from tls214_extracted_patterns as a
join tls214_extracted_patterns as b on
a.tentative_easy_year = b.tentative_easy_year
and a.month1 = b.month1
and a.first_part = b.first_part --and a.last_part = b.last_part
where a.npl_publn_id <> b.npl_publn_id
and patstat_clean.dbo.Compute_LD_perc(a.bib_alpha_numeric, b.bib_alpha_numeric) >= 0.90
and a.bib_numeric <> b.bib_numeric
except
select *
from result_rule_1


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