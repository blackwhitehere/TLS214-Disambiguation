use patstat

--month_date
select *, dbo.IsMatchValue(npl_biblio, '\b(?<Month>Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)(\s|\.|\.\s)?(?<Date>\d+)') as month_date
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.month_date not like ''
--go
--38979 -- 39%
select *
into #tmp2
from #tmp1 as t
where t.month_date not like ''

select npl_publn_id, month_date
into #month_date
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--tentative easy_year
select *, dbo.IsMatchValue(npl_biblio, '(18[5-9][0-9])|(19[0-9][0-9])|(200[0-9])|(201[0-5])') as easy_year
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.easy_year not like ''
--go
--71592 --71,6%
select *
into #tmp2
from #tmp1 as t
where t.easy_year not like ''

select npl_publn_id, easy_year
into #easy_year
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--d_american

select *, dbo.IsMatchValue(npl_biblio,'\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2}\b') as d_american,
dbo.GetGroups(npl_biblio, '\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2}\b', 1) as a_month,
dbo.GetGroups(npl_biblio, '\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2}\b', 2) as a_day,
dbo.GetGroups(npl_biblio, '\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2}\b', 3) as a_year
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.d_american not like ''
--go
--555 - 0,5%
select *
into #tmp2
from #tmp1 as t
where t.d_american not like ''

select npl_publn_id, d_american, a_day, a_month, a_year
into #d_american
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--d_europe

select *, dbo.IsMatchValue(npl_biblio,'\b(0?[1-9]|[12][0-9]|3[01])[- /.](0?[1-9]|1[012])[- /.](19|20)?[0-9]{2}\b') as d_europe,
dbo.GetGroups(npl_biblio, '\b(0?[1-9]|[12][0-9]|3[01])[- /.](0?[1-9]|1[012])[- /.](19|20)?[0-9]{2}\b', 1) as e_month,
dbo.GetGroups(npl_biblio, '\b(0?[1-9]|[12][0-9]|3[01])[- /.](0?[1-9]|1[012])[- /.](19|20)?[0-9]{2}\b', 2) as e_day,
dbo.GetGroups(npl_biblio, '\b(0?[1-9]|[12][0-9]|3[01])[- /.](0?[1-9]|1[012])[- /.](19|20)?[0-9]{2}\b', 3) as e_year
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.d_europe not like ''
--go
--868
select *
into #tmp2
from #tmp1 as t
where t.d_europe not like ''

select npl_publn_id, d_europe, e_day, e_month, e_year
into #d_europe
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--d_japan

select *, dbo.IsMatchValue(npl_biblio,'\b(19|20)?[0-9]{2}[- /.](0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])\b') as d_japan,
dbo.GetGroups(npl_biblio, '\b(19|20)?[0-9]{2}[- /.](0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])\b', 1) as j_month,
dbo.GetGroups(npl_biblio, '\b(19|20)?[0-9]{2}[- /.](0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])\b', 2) as j_day,
dbo.GetGroups(npl_biblio, '\b(19|20)?[0-9]{2}[- /.](0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])\b', 3) as j_year
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.d_japan not like ''
--
--3605 - 3,6%
select *
into #tmp2
from #tmp1 as t
where t.d_japan not like ''

select npl_publn_id, d_japan, j_day, j_month, j_year
into #d_japan
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--consilidate d/m/y from definitive dates into one table
create table #date_sys
(
	npl_publn_id int,
	d_sys int,
	m_sys int,
	y_sys int
)

insert into #date_sys(npl_publn_id,d_sys, m_sys, y_sys) (select npl_publn_id, a_day, a_month, a_year from #d_american)

insert into #date_sys(npl_publn_id, d_sys, m_sys, y_sys) (select npl_publn_id, e_day, e_month, e_year from #d_europe)

insert into #date_sys(npl_publn_id,d_sys, m_sys, y_sys) (select npl_publn_id, j_day, j_month, j_year from #d_japan)

select * from #date_sys

--easy_pages
select *, dbo.IsMatchValue(npl_biblio, '(?<=(\bpages\b(\.|,)?\s*))(\d+)((?:(\s(?:to\s)?(?:-\s)?|-|/))?)(\d*)') as easy_pages
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.easy_pages not like ''
--go
--35744 35,7%
select *
into #tmp2
from #tmp1 as t
where t.easy_pages not like ''

select npl_publn_id, easy_pages
into #easy_pages
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--easy_vol
select *, dbo.IsMatchValue(npl_biblio, '(?<=(\bvol\s*))(\d+)') as easy_vol
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.easy_vol not like ''
--go
--27613 - 27,6%
select *
into #tmp2
from #tmp1 as t
where t.easy_vol not like ''

select npl_publn_id, easy_vol
into #easy_vol
from #tmp2

go
drop table #tmp1
drop table #tmp2
go


--easy_no
select *, dbo.IsMatchValue(npl_biblio, '(?<=(\bNo(\.|,|\.;)?\s*))(\d+)') as easy_no
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.easy_no not like ''
--go
--25074 - 25%
select *
into #tmp2
from #tmp1 as t
where t.easy_no not like ''

select npl_publn_id, easy_no
into #easy_no
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--easy_xp
select *, dbo.IsMatchValue(npl_biblio, 'XP(\s|:)?(:|-)?(\s?)(\d){4,9}\b') as easy_xp
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.easy_xp not like ''
--go
--5707 -- 5,7%
select *
into #tmp2
from #tmp1 as t
where t.easy_xp not like ''

select npl_publn_id, easy_xp
into #easy_xp
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--easy_issn
select *, dbo.IsMatchValue(npl_biblio, 'ISSN(:|\s)?(\s|:)?\s?(\d{4})(-|\s)?(-\s)?(\d{3,4})(\w?)\b') as easy_issn
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.easy_issn not like ''
--go
--2276 - 2,3%
select *
into #tmp2
from #tmp1 as t
where t.easy_issn not like ''

select npl_publn_id, easy_issn
into #easy_issn
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--easy isbn
select *, dbo.IsMatchValue(npl_biblio, 'ISBN(\s|:)?(\s)?([0-9-x\s_]{10,17})\b') as easy_isbn
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.easy_isbn not like ''
--go
--371 -- 0,4%
select *
into #tmp2
from #tmp1 as t
where t.easy_isbn not like ''

select npl_publn_id, easy_isbn
into #easy_isbn
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--easy type
select *, dbo.IsMatchValue(npl_biblio, 'Journal|Magazine|Abstract|Article|Publication|Application|Note') as easy_type
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.easy_type not like ''
--go
--12846 - 12,8%
select *
into #tmp2
from #tmp1 as t
where t.easy_type not like ''

select npl_publn_id, easy_type
into #easy_type
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--easy a_etal
select *, dbo.IsMatchValue(npl_biblio, '[a-zA-Z,.\s]+(?=\s?et(\.\s|\.|\s)?al)') as easy_aetal
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.easy_aetal not like ''
--go
--41738 --41,7%
select *
into #tmp2
from #tmp1 as t
where t.easy_aetal not like ''

select npl_publn_id, easy_aetal
into #easy_aetal
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--easy url
select *, dbo.IsMatchValue(npl_biblio, '\b(https?|ftp|file)://[A-Z0-9+&@#/%?=~_|$!:,.;-]*[A-Z0-9+&@#/%=~_|$]') as easy_url
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.easy_url not like ''
--go
--2792 - 2,7%
select *
into #tmp2
from #tmp1 as t
where t.easy_url not like ''

select npl_publn_id, easy_url
into #easy_url
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--easy useless

select *,
dbo.GetGroups(npl_biblio, '(^None$)|(^NICHT\sERMITTELT$)|(&#x)|(^See\sreferences\sof)', 1) as useless1,
dbo.GetGroups(npl_biblio, '(^None$)|(^NICHT\sERMITTELT$)|(&#x)|(^See\sreferences\sof)', 2) as useless2,
dbo.GetGroups(npl_biblio, '(^None$)|(^NICHT\sERMITTELT$)|(&#x)|(^See\sreferences\sof)', 3) as useless3,
dbo.GetGroups(npl_biblio, '(^None$)|(^NICHT\sERMITTELT$)|(&#x)|(^See\sreferences\sof)', 4) as useless4
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.useless1 not like '' or t.useless2 not like '' or t.useless3 not like '' or t.useless4 not like ''
--go
--3807 - 3,8%
select *
into #tmp2
from #tmp1 as t
where t.useless1 not like '' or t.useless2 not like '' or t.useless3 not like '' or t.useless4 not like ''

select npl_publn_id, useless1, useless2, useless3, useless4
into #easy_useless
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

--easy email

select *, dbo.IsMatchValue(npl_biblio, '\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}\b') as easy_email
into #tmp1
from sample_unique
go
--select count(*) from #tmp1 as t where t.easy_email not like ''
--go
--14 0,01%
select *
into #tmp2
from #tmp1 as t
where t.easy_email not like ''

select npl_publn_id, easy_email
into #easy_email
from #tmp2

go
drop table #tmp1
drop table #tmp2
go

-------------------------------
select su.npl_publn_id, a.month_date, b.easy_year, c.d_american, d.d_europe, e.d_japan, f.easy_pages, g.easy_vol,
h.easy_no, i.easy_xp, j.easy_issn, k.easy_isbn, l.easy_type, m.easy_aetal, n.easy_url, o.useless1, o.useless2, o.useless3, o.useless4
into #easy_labels
from sample_unique as su left join #month_date as a on su.npl_publn_id=a.npl_publn_id
left join #easy_year as b on su.npl_publn_id=b.npl_publn_id
left join #d_american as c on su.npl_publn_id=c.npl_publn_id
left join #d_europe as d on su.npl_publn_id=d.npl_publn_id
left join #d_japan as e on su.npl_publn_id=e.npl_publn_id
left join #easy_pages as f on su.npl_publn_id=f.npl_publn_id
left join #easy_vol as g on su.npl_publn_id=g.npl_publn_id
left join #easy_no as h on su.npl_publn_id=h.npl_publn_id
left join #easy_xp as i on su.npl_publn_id=i.npl_publn_id
left join #easy_issn as j on su.npl_publn_id=j.npl_publn_id
left join #easy_isbn as k on su.npl_publn_id=k.npl_publn_id
left join #easy_type as l on su.npl_publn_id=l.npl_publn_id
left join #easy_aetal as m on su.npl_publn_id=m.npl_publn_id
left join #easy_url as n on su.npl_publn_id=n.npl_publn_id
left join #easy_useless as o on su.npl_publn_id=o.npl_publn_id


go

drop table #month_date
drop table #easy_year
drop table #d_europe
drop table #d_japan
drop table #d_american
drop table #easy_pages
drop table #easy_vol
drop table #easy_no
drop table #easy_xp
drop table #easy_issn
drop table #easy_isbn
drop table #easy_type
drop table #easy_aetal
drop table #easy_url
drop table #easy_useless
drop table #easy_email
drop table #date_sys


--time to complete on 96500 records, i5 760, 4gb ram: 1:27 --> 16.5M records t>4h

select *
from #easy_labels
where month_date like NULL and easy_year like Null and d_american like Null and d_europe like null and d_japan like null
and easy_pages like NULL and easy_vol like null and easy_no like null and easy_xp like null and easy_issn like null
and easy_isbn like null and easy_type like null and easy_aetal like null and easy_url like null

--drop table #easy_labels