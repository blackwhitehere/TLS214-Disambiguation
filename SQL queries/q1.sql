use patstat

select *
into #tmp1
from sample_unique
where npl_biblio like '%,%'

select *
into #tmp2
from sample_unique
where npl_biblio like '%;%'

select *
from #tmp1 as a join #tmp2 as b on a.npl_publn_id=b.npl_publn_id
--10772

