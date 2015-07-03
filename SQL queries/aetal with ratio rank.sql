use patstat
go

select *, dbo.StringLength(npl_biblio) as string_length, dbo.IsMatchIndex(npl_biblio, '(\bet(\.\s|\.|\s)?al)') as et_al
into #tmp1
from sample_unique
go

select *
into #tmp2
from #tmp1
where et_al is not null 
go

alter table #tmp2 add sl_d decimal(10,4)
alter table #tmp2 add etal_d decimal(10,4)
alter table #tmp2 add ratio decimal(4,4)
go

update #tmp2 set sl_d = convert(decimal(10,4), string_length)
update #tmp2 set etal_d = convert(decimal(10,4), et_al)
update #tmp2 set ratio = (etal_d/sl_d)
go

select *
from #tmp2
order by ratio
--20% cutoff

drop table #tmp1
drop table #tmp2