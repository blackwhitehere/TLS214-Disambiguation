--View new_ids that correspond to npl_biblio duplicates
drop table #tmp1
select a.new_id, count(new_id) as freq
into #tmp1
from sample_glue as a
group by new_id

select * from #tmp1
where freq>2

--e.g.5725

select a.*, b.npl_biblio
from sample_glue as a
join sample_table as b on a.npl_publn_id=b.npl_publn_id
where a.new_id=5725
