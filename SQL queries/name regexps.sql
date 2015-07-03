use patstat
go

--Name: Arrity(n:I)=1:1. Order:I:n. I-names, n-surnames
select *, dbo.GetMatchesCSV(npl_biblio, '(\b([A-Z](\.\s?|\s))([A-Z]{3,}))|(\b([A-Z](\.\s?|\s))([A-Z][a-z]+))') as name11
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.name1 not like ''
--go
--
select *
into #tmp2
from #tmp1 as t
where t.name11 not like ''

select npl_publn_id, name11
into #name11
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--Name: Arrity(n:I)=1:2. Order:I:n. I-names, n-surnames
select *, dbo.GetMatchesCSV(npl_biblio, '(\b([A-Z](\.\s?|\s)){2}([A-Z]{3,}))|(\b([A-Z](\.\s?|\s)){2}([A-Z][a-z]+))') as name12
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.name1 not like ''
--go
--
select *
into #tmp2
from #tmp1 as t
where t.name12 not like ''

select npl_publn_id, name12
into #name12
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--Name: Arrity(n:I)=2:1. Order:I:n. I-names, n-surnames
select *,
dbo.GetMatchesCSV(npl_biblio, '\b[A-Z]\.?(\s)(([A-Z][a-z]{2,})|([A-Z]){2,})(\s|-)(([A-Z][a-z]{2,})|([A-Z]){2,})') as name21
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.name1 not like ''
--go
--
select *
into #tmp2
from #tmp1 as t
where t.name21 not like ''

select npl_publn_id, name21
into #name21
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--Name: Arrity(n:I)=2:2. Order:I:n. I-names, n-surnames
select *,
dbo.GetMatchesCSV(npl_biblio, '\b[A-Z]\.?\s?[A-Z]\.?\s(([A-Z][a-z]{2,})|([A-Z]){2,})(\s|-)(([A-Z][a-z]{2,})|([A-Z]){2,})') as name22
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.name1 not like ''
--go
--
select *
into #tmp2
from #tmp1 as t
where t.name22 not like ''

select npl_publn_id, name22
into #name22
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--Name: Example of 1/4 Table 3rd Schema. Natural.
select *, dbo.GetMatchesCSV(npl_biblio, '(\b([A-Z](\.|\s|\.\s)?){1,3}\s([A-Z][a-z]+(\s|-)?|[A-Z]+(\s|-)?){1,3})') as nameALL
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.name1 not like ''
--go
--
select *
into #tmp2
from #tmp1 as t
where t.nameALL not like ''

select npl_publn_id, nameALL
into #nameALL
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--Name: Arrity(n:I)=1:1. Order:I:n. Inverse
select *, dbo.GetMatchesCSV(npl_biblio, '(\b[A-Z][a-z]+,?\s[A-Z]\b)|(\b[A-Z]{2,},?\s[A-Z]\b)') as name11inv
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.name1 not like ''
--go
--
select *
into #tmp2
from #tmp1 as t
where t.name11inv not like ''

select npl_publn_id, name11inv
into #name11inv
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--Name: Arrity(n:I)=2:1|2. Order: n(II)?n. Alternative schema e.g Schema 6:[nN]:F,S & I:F.
select *, dbo.GetMatchesCSV(npl_biblio, '(([A-Z][a-z]+(\s|-)|[A-Z]+(\s|-)){1}([A-Z]\.?){0,2}\s([A-Z][a-z]+(\s|-)?|[A-Z]+(\s|-)?){1})') as name_nIIn
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.name1 not like ''
--go
--
select *
into #tmp2
from #tmp1 as t
where t.name_nIIn not like ''

select npl_publn_id, name_nIIn
into #name_nIIn
from #tmp2

go
drop table #tmp1
drop table #tmp2
go



--etal + rank
select npl_publn_id,
dbo.StringLength(npl_biblio) as string_length,
dbo.IsMatchIndex(npl_biblio, '(\bet(\.\s|\.|\s)?al)') as et_al_index,
dbo.IsMatchValue(npl_biblio, '(([a-zA-Z,.]+\s?){1,4})(?=\bet(\.\s|\.|\s)?al)') as easy_aetal
into #tmp1
from sample_unique
go

select *
into #tmp2
from #tmp1
where easy_aetal is not null 

alter table #tmp2 add string_length_d decimal(8,4)
alter table #tmp2 add et_al_index_d decimal(8,4)
alter table #tmp2 add ratio decimal(4,4)


update #tmp2 set string_length_d = convert(decimal(8,4), string_length)
update #tmp2 set et_al_index_d = convert(decimal(8,4), et_al_index)
update #tmp2 set ratio = (et_al_index_d/string_length_d)
go

select *
into #easy_aetal
from #tmp2
where easy_aetal not like ''
go

--select *
--from #tmp2
--order by ratio
--20% cutoff


select su.npl_publn_id, su.npl_biblio, a.easy_aetal, a.ratio, b.name11, c.name12, d.name21, e.name22, f.nameALL, g.name11inv, h.name_nIIn
into #final
from sample_unique as su
left join #easy_aetal as a on su.npl_publn_id=a.npl_publn_id
left join #name11 as b on su.npl_publn_id=b.npl_publn_id
left join #name12 as c on su.npl_publn_id=c.npl_publn_id
left join #name21 as d on su.npl_publn_id=d.npl_publn_id
left join #name22 as e on su.npl_publn_id=e.npl_publn_id
left join #nameALL as f on su.npl_publn_id=f.npl_publn_id
left join #name11inv as g on su.npl_publn_id=g.npl_publn_id
left join #name_nIIn as h on su.npl_publn_id=h.npl_publn_id
go

drop table #easy_aetal
drop table #name11
drop table #name12
drop table #name21
drop table #name22
drop table #nameALL
drop table #tmp1
drop table #tmp2
go

select *
from #final as f

--2874/5256
go

--drop table #final