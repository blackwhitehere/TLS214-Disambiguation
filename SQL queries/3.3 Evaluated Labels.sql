--EVALUATED PATTERNS
/*
This stage uses the information extracted in the tls214_extracted_patterns to obtain the most reliable labels.
*/

use patstat
go

-----------------------------------
--tls214_extracted_patterns updates
-----------------------------------

--Month date harmonization

update	a
set		a.month_date_day=
		(case
		when (dbo.IsMatch(a.month_date,'(\b[0-9]\b|\b1[0-9]\b|\b2[0-9]\b|\b3[0-1\b])')=1) then (convert(int, dbo.IsMatchValue(a.month_date,'\d+')))
		end
		)
		,a.month_date_month = 
		(
		case
			when (dbo.IsMatch(a.month_date,'jan')=1) then 1
			when (dbo.IsMatch(a.month_date,'feb')=1) then 2
			when (dbo.IsMatch(a.month_date,'mar')=1) then 3
			when (dbo.IsMatch(a.month_date,'apr')=1) then 4
			when (dbo.IsMatch(a.month_date,'may')=1) then 5
			when (dbo.IsMatch(a.month_date,'jun')=1) then 6
			when (dbo.IsMatch(a.month_date,'jul')=1) then 7
			when (dbo.IsMatch(a.month_date,'aug')=1) then 8
			when (dbo.IsMatch(a.month_date,'sep')=1) then 9
			when (dbo.IsMatch(a.month_date,'oct')=1) then 10
			when (dbo.IsMatch(a.month_date,'nov')=1) then 11
			when (dbo.IsMatch(a.month_date,'dec')=1) then 12
		end
		)
		,a.month_date_year=
		(
		case
		when (dbo.IsMatch(a.month_date,'(18[5-9][0-9])|(19[0-9][0-9])|(200[0-9])|(201[0-5])')=1) then (convert(int, dbo.IsMatchValue(a.month_date,'\d+')))
		end
		)
from	tls214_extracted_patterns as a
where	a.month_date is not null
go

--ISSN & ISBN

update	a
set		a.easy_issn=dbo.RegexReplace(a.easy_issn, '[\s:-_]','')
from	tls214_extracted_patterns as a
where	a.easy_issn is not null
go

update	a
set		a.easy_isbn=dbo.RegexReplace(a.easy_isbn, '[\s:-_]','')
from	tls214_extracted_patterns as a
where	a.easy_isbn is not null
go

------------------
--Evaluated Labels
------------------

--Create table with unique attributes

if object_id('evaluated_patterns') is not null drop table evaluated_patterns
create table evaluated_patterns
(
	new_id int not null
	--date
	,d_day int
	,d_month int
	,d_year int
	--source
	,pages_start nvarchar(50)
	,pages_end nvarchar(50)
	,volume nvarchar(50) --int
	,issue nvarchar(50) --int
	,xp_number int
	,issn nvarchar(50)
	,isbn nvarchar(50)
	,appln_no nvarchar (100)
	--other
	,bibliographic_type nvarchar(50)
	,url nvarchar(500)
	,s_start nchar(12)
	,s_end nchar(12)
	,bib_numeric nvarchar(3000)
	,bib_alphabetic nvarchar(3000)
	,bib_alphanumeric nvarchar(3000)
	,b_length int
	,sum_of_numbers bigint
	,count_of_numbers int
	--name
	,aetal nvarchar(500)
	,name nvarchar(500)
	--special
	,residual nvarchar(3000)
	,res_numeric nvarchar(3000)
	,res_alphabetic nvarchar(3000)
	,useless nvarchar(100)
	,useless2 nvarchar(100)

	,constraint pk_evaluated_patterns_id primary key (new_id)
)
go

--insert the evaluated patterns table with non altered labels from tls214 extracted patterns

insert into evaluated_patterns
(
	new_id
	,volume --
	,issue --
	,xp_number--
	,issn--
	,isbn--
	,appln_no--
	,bibliographic_type--
	,url--
	,s_start
	,s_end
	,bib_numeric--
	,bib_alphabetic--
	,bib_alphanumeric--
	,b_length--
	,sum_of_numbers--
	,count_of_numbers--
	,useless--
	,useless2--
)
select
	new_id
	,easy_volume--
	,easy_no--
	,xp_number--
	,easy_issn--
	,easy_isbn--
	,easy_appln_no--
	,easy_bibliographic_type--
	,easy_url--
	,s_start
	,s_end
	,bib_numeric--
	,bib_alphabetic--
	,bib_alphanumeric--
	,npl_biblio_length--
	,sum_of_numbers--
	,count_of_numbers--
	,useless--
	,useless2--
from tls214_extracted_patterns
go

--Consolidate date labels into 3 labels: day, month and year based on accuracy of extraction technique.

update	b
set		b.d_year=
		(
		case
			when a.sys_year is not null then a.sys_year
			when a.month_date_year is not null and a. sys_year is null then a.month_date_year
			when a.tentative_easy_year is not null and a.month_date_year is null and a.sys_year is null then a.tentative_easy_year
		end
		)
		,b.d_month=
		(
		case
			when a.sys_month is not null then a.sys_month
			when a.month_date_month is not null and a. sys_month is null then a.month_date_month
		end
		)
		,b.d_day=
		(
		case
			when a.sys_day is not null then a.sys_day
			when a.month_date_day is not null and a. sys_day is null then a.month_date_day
		end
		)
from tls214_extracted_patterns as a
join evaluated_patterns as b on a.new_id=b.new_id
go

--Consolidate A,B,C,D,E name formats into single, cleaned label and clean aetal

update	b
set		b.name=
		(
		case
			--if A1 is detected A is the most reliable name
			when a.nameA is not null
			and	a.nameA1 is not null then	(
											select	lower(ltrim(dbo.RegexReplace(a.nameA,'([^a-zA-Z\s])|(\s{2,})+','')))
											where	a.nameA is not null
											)
			
			--if A1 is not detected nameE is used
			when a.nameE is not null
			and a.nameA1 is null
			then	(
					select	lower(ltrim(dbo.RegexReplace(a.nameE,'([^a-zA-Z\s])|(\s{2,})+','')))
					where	a.nameE is not null
					)

			--if A and E can not be used, use B in case C also can not be used.
			when a.nameB is not null
			and a.nameB1 is not null
			and a.nameC1 is null
			and a.nameA1 is null
			and a.nameE is null
			then	(
					select lower(ltrim(dbo.RegexReplace(a.nameB,'([^a-zA-Z\s])|(\s{2,})+','')))
					where a.nameB is not null
					)
		
			--if A and E can not be used, use C in case B also can not be used
			when a.nameC is not null
			and a.nameC1 is not null
			and a.nameB1 is null
			and a.nameA1 is null
			and a.nameE is null
			then	(
					select lower(ltrim(dbo.RegexReplace(a.nameC,'([,.])|(\s{2,})+','')))
					where a.nameC is not null
					)

			--if A and E cannot be used and both B and C can be used, use the longer one.
			when a.nameC1 is not null
			and a.nameB1 is not null
			and a.nameA1 is null
			and a.nameE is null
			and a.nameC is not null
			and (len(a.nameC)>len(a.nameB))
			then	(
					select lower(ltrim(dbo.RegexReplace(a.nameC,'([,.])|(\s{2,})+','')))
					where a.nameC is not null
					)

			when a.nameC1 is not null
			and a.nameB1 is not null
			and a.nameA1 is null
			and a.nameE is null
			and a.nameB is not null
			and (len(a.nameC)<len(a.nameB))
			then	(
					select lower(ltrim(dbo.RegexReplace(a.nameB,'([^a-zA-Z\s])|(\s{2,})+','')))
					where a.nameB is not null
					)

			--if all else can not be used, use D

			when a.nameD is not null
			and a.nameE is null
			and a.nameA1 is null
			and a.nameB1 is null
			and a.nameC1 is null
			then	(
					select lower(ltrim(dbo.RegexReplace(a.nameD,'([^a-zA-Z\s])|(\s{2,})+','')))
					where a.nameD is not null
					)
		end
		)

		--Clean easy et. al

		,b.aetal=	(
					select (lower(ltrim(dbo.RegexReplace(a.easy_aetal,'([^a-zA-Z\s])|(\s{2,})+',''))))
					where a.easy_aetal is not null
					)

from	tls214_extracted_patterns as a
join	evaluated_patterns as b
		on a.new_id=b.new_id
go

--Remove tags from names
update	a
set		a.name=dbo.RegexReplace(a.name,'et\sal','')
from	evaluated_patterns as a
where	a.name is not null
go

--Separate pages into start and ending if needed

update	b
set		b.pages_start=dbo.IsMatchesValue(a.easy_pages,'\b\d+',1)
		,b.pages_end=
		(
		case
			when dbo.IsMatchesValue(a.easy_pages,'\b\d+',2)!='' then (dbo.IsMatchesValue(a.easy_pages,'\b\d+',2))
		end
		)
from	tls214_extracted_patterns as a
join	evaluated_patterns as b on a.new_id=b.new_id
where	a.easy_pages is not null
go

--Clean residual

	--Remove tags from residuals
	update	a
	set		a.residual=dbo.RegexReplace(b.residual,'(vol)|(no)|(pag(es)?)|(et\sal)','')
	from	evaluated_patterns as a
	join	tls214_extracted_patterns as b on a.new_id=b.new_id
	where	b.residual is not null
	go

	--Lower, Remove all chars that are not letters or numbers, remove excess spaces
	update	a
	set		a.residual=lower(rtrim(ltrim(dbo.RegexReplace(dbo.RegexReplace(a.residual,'[^A-z0-9\s]+',''),'\s{2,}',''))))
	from	evaluated_patterns as a
	where	a.residual is not null
	go

	--Set to null if empty
	update	a
	set		a.residual=null
	from	evaluated_patterns as a
	where	a.residual like ''
	go

--Separate numbers and alphabet from residual
update	a
set		a.res_numeric=lower(rtrim(ltrim(dbo.RegexReplace(dbo.RegexReplace(a.residual,'[^0-9]+',''),'\s{2,}',''))))
		,a.res_alphabetic=lower(rtrim(ltrim(dbo.RegexReplace(dbo.RegexReplace(a.residual,'[^A-z\s]+',''),'\s{2,}',''))))
from	evaluated_patterns as a
where	a.residual is not null

--Harmonize s_start, s_end
update	a
set		a.s_start=lower(rtrim(ltrim(dbo.RegexReplace(a.s_start,'\s{2,}',''))))
from	evaluated_patterns as a
where	a.s_start is not null
go

update	a
set		a.s_end=lower(rtrim(ltrim(dbo.RegexReplace(a.s_end,'\s{2,}',''))))
from	evaluated_patterns as a
where	a.s_end is not null
go

--Harmonize bib_numeric, bib_alphabetic, bib_alphanumeric

update	a
set		a.bib_numeric=lower(rtrim(ltrim(dbo.RegexReplace(a.bib_numeric,'\s{2,}',''))))
from	evaluated_patterns as a
where	a.bib_numeric is not null
go

update	a
set		a.bib_alphabetic=lower(rtrim(ltrim(dbo.RegexReplace(a.bib_alphabetic,'\s{2,}',''))))
from	evaluated_patterns as a
where	a.bib_alphabetic is not null
go

update	a
set		a.bib_alphanumeric=lower(rtrim(ltrim(dbo.RegexReplace(a.bib_alphanumeric,'\s{2,}',''))))
from	evaluated_patterns as a
where	a.bib_alphanumeric is not null
go

--Set res_numeric to null if empty
update	a
set		a.res_numeric=null
from	evaluated_patterns as a
where	a.res_numeric like ''
go

--Set res_alphabetic to null if empty
update	a
set		a.res_alphabetic=null
from	evaluated_patterns as a
where	a.res_alphabetic like ''
go

--Set bib_numeric to null if empty
update	a
set		a.bib_numeric=null
from	evaluated_patterns as a
where	a.bib_numeric like ''
go

--Set bib_numeric to null if empty
update	a
set		a.bib_alphabetic=null
from	evaluated_patterns as a
where	a.bib_alphabetic like ''
go
		
---------
--Inspect
---------

select * from evaluated_patterns