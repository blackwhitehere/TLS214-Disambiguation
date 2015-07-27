use patstat_performance
go

if object_id('#tmp2') is not null drop table #tmp2
select b.npl_publn_id, a.name, a.aetal, a.res_alphabetic, a.d_year
into #tmp2
from evaluated_patterns as a
join sample_glue as b on a.new_id=b.new_id
go

if object_id('#tmp1') is not null drop table #tmp1
select npl_publn_id, npl_bibiographic_info_TLS214 as npl_biblio, first_author_from_WOS as author, pub_title_from_WOS as title, publication_year_from_WOS as d_year
into #tmp1
from test_set
go

--ld aetal
if object_id('#tmp3') is not null drop table #tmp3
select		a.npl_publn_id
			,dbo.ComputeDistancePerc(a.aetal,lower(b.author)) as aetal_to_WOS_LD_Perc
into		#tmp3
from		#tmp1 as b
join		#tmp2 as a
			on a.npl_publn_id=b.npl_publn_id
where		a.aetal is not null
and			b.author is not null
order by	aetal_to_WOS_LD_Perc desc
go

--ld name
select		a.npl_publn_id
			,dbo.ComputeDistancePerc(a.name, lower(b.author)) as name_to_WOS_LD_Perc
into		#tmp4
from		#tmp1 as b
join		#tmp2 as a
			on a.npl_publn_id=b.npl_publn_id
where		a.name is not null
and			b.author is not null
order by	name_to_WOS_LD_Perc desc
go

--ld title

select		a.npl_publn_id
			,dbo.ComputeDistancePerc(a.res_alphabetic, lower(b.title)) as proxy_title_to_WOS_LD_Perc
into		#tmp5
from		#tmp1 as b
join		#tmp2 as a
			on a.npl_publn_id=b.npl_publn_id
where		a.res_alphabetic is not null
and			b.title is not null
order by	proxy_title_to_WOS_LD_Perc desc
go

--rest

select		b.npl_publn_id
			,a.name as mined_name
			,a.aetal as mined_name2
			,b.author as wos_name
			,a.res_alphabetic as proxy_title
			,b.title
			,a.d_year as mined_year
			,b.d_year
into		#tmp6
from		#tmp1 as b
join		#tmp2 as a
			on a.npl_publn_id=b.npl_publn_id
go

if object_id('extraction_evaluation') is not null drop table extraction_evaluation
select a.*, b.proxy_title_to_WOS_LD_Perc, c.name_to_WOS_LD_Perc, d.aetal_to_WOS_LD_Perc
into extraction_evaluation
from #tmp1 as x
left join #tmp6 as a on x.npl_publn_id=a.npl_publn_id
left join #tmp5 as b on a.npl_publn_id=b.npl_publn_id
left join #tmp4 as c on b.npl_publn_id=c.npl_publn_id
left join #tmp3 as d on c.npl_publn_id=d.npl_publn_id
go

--1276
select distinct a.npl_publn_id
,a.mined_name
,a.mined_name2
,a.wos_name
,a.name_to_WOS_LD_Perc
,a.aetal_to_WOS_LD_Perc
,a.mined_year
,a.d_year
,a.proxy_title
,a.title
,a.proxy_title_to_WOS_LD_Perc
from extraction_evaluation as a
order by proxy_title_to_WOS_LD_Perc desc


drop table #tmp1
drop table #tmp2
drop table #tmp3
drop table #tmp4
drop table #tmp5
drop table #tmp6