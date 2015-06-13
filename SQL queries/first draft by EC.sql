/*
Authors : Emiel, Jos
Date    : June 27, 2014
Description : Cleaning patstat data, [tls214_npl_publn] table
*/
use userdb_emiel
go

-----------------------------------------------------------------
drop function dbo.getnumeric -- returns only numeric values of the bibilio?

create function dbo.getnumeric -- obtains biblio without numbers
(@stralphanumeric varchar(256)) --? npl_biblio is longer than 256
returns varchar(256)
as
begin

	declare @intalpha int
	set @intalpha = patindex('%[^0-9]%', @stralphanumeric) --position of first non-digit in biblio
	begin
		while @intalpha > 0 --how do you escape loop? - when expression non found
		begin
		set @stralphanumeric = stuff(@stralphanumeric, @intalpha, 1, '' ) -- replace non-digit with empty string
		set @intalpha = patindex('%[^0-9]%', @stralphanumeric ) --go to next digit
		end
	end
	return isnull(@stralphanumeric,0) --nulls are replaced with 0

end

go

--test function
select top 100000 npl_biblio, dbo.getnumeric(npl_biblio) as npl_biblio_num
from [tls214_npl_publn_unique]

-----------------------------------------------------------------

--remove double spaces
--

drop table [tls214_npl_publn_unique]
create table [tls214_npl_publn_unique](
	npl_publn_id int identity(1,1) not null, --copy with seed and increament
	npl_biblio nvarchar(max) not null -- for unicode
constraint pk_npl_publn_id primary key (npl_publn_id)) --pk?
go

--initial cleaning a [change to lowercase, remove leading and lagging blanks, double spaces removed]
drop table #tmp1
select npl_publn_id, lower(rtrim(ltrim(replace(npl_biblio,'  ',' ')))) as npl_biblio
into #tmp1
from [patstat_2014spring]..[tls214_npl_publn] p

--initial cleaning b [if biblio ends with a dot remove it, else leave as is]
drop table #tmp2
select npl_publn_id, iif((substring(npl_biblio, len(npl_biblio), 1) = '.'), left(npl_biblio, len(npl_biblio) - 1) ,npl_biblio) as npl_biblio
into #tmp2
from #tmp1

drop table #tmp1

--populate table
insert into tls214_npl_publn_unique(npl_biblio)
select distinct npl_biblio --already some repeated tables can be found
from #tmp2
order by npl_biblio

--make copy of this table
drop table [tls214_npl_publn_unique_copy]
select *
into [tls214_npl_publn_unique_copy]
from [tls214_npl_publn_unique]

--use copy if needed
--drop table tls214_npl_publn_unique
--select *
--into tls214_npl_publn_unique
--from [tls214_npl_publn_unique_copy]

--alter table tls214_npl_publn_unique
--add constraint pk_npl_publn_id primary key (npl_publn_id)

--glue table (koppeltabel)
drop table npl_biblio_glue -- relation between original and so far cleaned biblio through publn_id
select a.npl_publn_id as npl_publn_id_new, b.npl_publn_id
into npl_biblio_glue -- needs to be created?
from tls214_npl_publn_unique as a
join #tmp2 as b on a.npl_biblio = b.npl_biblio --results of temp cleaning are dumpted to unique table. why not left outer join?- can be updated

--create table with org patterns
if object_id('cleaning_patterns') is not null drop table cleaning_patterns
create table cleaning_patterns
				(step int not null,
				cleaning_pattern varchar(100) not null,
				cleaning_source varchar(100) not null,
				cleaning_label varchar(100) not null)
go

--pages
insert into cleaning_patterns select 1, '% pp. %',  ' pp. ', ' pages ' --'%*pp %'
insert into cleaning_patterns select 1, '%,pp. %',  ',pp. ', ', pages ' --'%*pp.%' 
insert into cleaning_patterns select 1, '% page %', ' page ', ' pages '
insert into cleaning_patterns select 1, '%,page %', ',page ', ', pages '
insert into cleaning_patterns select 1, '%,pages %', ',pages ', ', pages '
insert into cleaning_patterns select 1, '% page(s) %', ' page(s) ',  ' pages '
insert into cleaning_patterns select 1, '% pages.%', ' pages.',  ' pages'
insert into cleaning_patterns select 1, '% seiten %', ' seiten ', ' pages '
insert into cleaning_patterns select 1, '% seiten.%', ' seiten.', ' pages'
insert into cleaning_patterns select 1, '% seite %', ' seite ', ' pages '
insert into cleaning_patterns select 1, '% feuilles %', ' feuilles ', ' pages '

insert into cleaning_patterns select 2, '% p. [0-9]%', ' p. ', ' pages '
insert into cleaning_patterns select 2, '%,p. [0-9]%', ',p. ', ', pages '

insert into cleaning_patterns select 3, '% bd. %', ' bd. ' ,' vol '
insert into cleaning_patterns select 3, '% vol. %',' vol. ',' vol '
insert into cleaning_patterns select 3, '%,vol. %',',vol. ',', vol '
insert into cleaning_patterns select 3, '% v. [0-9]%',' v. ',' vol '
insert into cleaning_patterns select 3, '% volume [0-9]%',' volume ',' vol '
insert into cleaning_patterns select 3, '% b. [0-9]%', ' b. ', ' vol '

--issue
insert into cleaning_patterns select 4, '% no. %', ' no. ', ' no '
insert into cleaning_patterns select 4, '%,no. %', ',no. ', ', no '
insert into cleaning_patterns select 4, '% nr. %', ' nr. ',' no '
insert into cleaning_patterns select 4, '%,nr. %', ',nr. ',', no '
insert into cleaning_patterns select 4, '% n. [0-9]%', ' n. ', ' no '
insert into cleaning_patterns select 4, '% heft %', ' heft ',' no '

--proceedings
insert into cleaning_patterns select 5, '% proc. %', ' proc. ', ' proc '
insert into cleaning_patterns select 5, '% proceedings %', ' proceedings ', ' proc '

--science
insert into cleaning_patterns select 6, '% sci. %', ' sci. ', ' science '

--et al.
insert into cleaning_patterns select 7, '% et al.%', ' et al.', ' et al'

--chemical
insert into cleaning_patterns select 8, '% chemical %', ' chemical ', ' chem. '
insert into cleaning_patterns select 8, '% chem %', ' chem ', ' chem. '

--national
insert into cleaning_patterns select 9, '% national %', ' national ', ' natl. '
insert into cleaning_patterns select 9, '% natl %', ' natl ', ' natl. '

--[ - ]
insert into cleaning_patterns select 10, '%[0-9] - [0-9]%', ' - ', '-'

--months
insert into cleaning_patterns select 11, '% jan. %', ' jan. ', ' jan ' -- is this case sensitive?
insert into cleaning_patterns select 11, '% january %', ' january ', ' jan '
insert into cleaning_patterns select 11, '% feb. %', ' feb. ', ' feb '
insert into cleaning_patterns select 11, '% february %', ' february ', ' feb '
insert into cleaning_patterns select 11, '% mar. %', ' mar. ', ' mar '
insert into cleaning_patterns select 11, '% march %', ' march ', ' mar '
insert into cleaning_patterns select 11, '% apr. %', ' apr. ', ' apr '
insert into cleaning_patterns select 11, '% april %', ' april ', ' apr '
insert into cleaning_patterns select 11, '% jun. %', ' jun. ', ' jun '
insert into cleaning_patterns select 11, '% june %', ' june ', ' jun '
insert into cleaning_patterns select 11, '% jul. %', ' jul. ', ' jul '
insert into cleaning_patterns select 11, '% july %', ' july ', ' jul '
insert into cleaning_patterns select 11, '% aug. %', ' aug. ', ' aug '
insert into cleaning_patterns select 11, '% augustus %', ' augustus ', ' aug '
insert into cleaning_patterns select 11, '% sep. %', ' sep. ', ' sep '
insert into cleaning_patterns select 11, '% sept. %', ' sept. ', ' sep '
insert into cleaning_patterns select 11, '% september %', ' september ', ' sep '
insert into cleaning_patterns select 11, '% oct. %', ' oct. ', ' oct '
insert into cleaning_patterns select 11, '% october %', ' october ', ' oct '
insert into cleaning_patterns select 11, '% nov. %', ' nov. ', ' nov '
insert into cleaning_patterns select 11, '% november %', ' november ', ' nov '
insert into cleaning_patterns select 11, '% dec. %', ' dec. ', ' dec '
insert into cleaning_patterns select 11, '% december %', ' december ', ' dec '

--add index
create index idx_cleaning_patterns on cleaning_patterns(cleaning_pattern)

--initialization
declare @loopcounter int = 1
declare @loopmax int = (select max(step) from cleaning_patterns)

--loop - if a pattern is found on a step, replace it
while (@loopcounter <= @loopmax)
begin
    
	update a
	set a.npl_biblio = replace(a.npl_biblio, b.cleaning_source, b.cleaning_label)  
	from [tls214_npl_publn_unique] as a -- specific purpose of []?
	join cleaning_patterns as b on patindex(b.cleaning_pattern, a.npl_biblio) <> 0  --what is the common attribute of the tables? why combine?
	where step = @loopcounter

	set @loopcounter += 1

end

select count(*)
from [tls214_npl_publn_unique]
--16 879 032

------------------------------------------------------------------------------------

select * from pattern_years

select count(distinct npl_biblio_clean)
from #tls214_npl_publn_unique_clean
from [tls214_npl_publn_unique]
--16 834 228
--16 833 798
--16 879 200
--16 813 096
--16 553 286

select top 100 *
from #tls214_npl_publn_unique_clean

drop table #tls214_npl_publn_unique_clean2
select min(npl_publn_id) as npl_publin_id, npl_biblio_clean as npl_biblio
into #tls214_npl_publn_unique_clean2
from #tls214_npl_publn_unique_clean
group by npl_biblio_clean

--npl_biblio_clean

--oorzaak spaties, leestekens, etc (bijna 2 uur, 1 ur 40)
drop table #tls214_npl_publn_unique_clean
select npl_publn_id, userdb_emiel.dbo.fn_cleanstring(npl_biblio) as npl_biblio_clean
into #tls214_npl_publn_unique_clean
from [tls214_npl_publn_unique]

drop table tls214_npl_publn_unique_clean2
select npl_publn_id, rtrim(ltrim(replace(replace(replace(replace(npl_biblio_clean,'  ',' '), '  ',' '),'  ',' '),'  ',' '))) as npl_biblio_clean --why 4 replace
into tls214_npl_publn_unique_clean2
from tls214_npl_publn_unique_clean


--select top 10000 * from tls214_npl_publn_unique_clean2
--16 859 330

select count(distinct npl_biblio_clean) from tls214_npl_publn_unique_clean2
--15 720 494
--

alter table [tls214_npl_publn_unique_clean2] add constraint pk_npl_publn_id3 primary key (npl_publn_id)

drop table tls214_npl_publn_unique_clean3
select min(npl_publn_id) as npl_publn_id, npl_biblio_clean as npl_biblio
into tls214_npl_publn_unique_clean3
from tls214_npl_publn_unique_clean2
group by npl_biblio_clean

select top 100 * from tls214_npl_publn_unique_clean3
where npl_biblio is null

alter table [tls214_npl_publn_unique_clean3] add constraint pk_npl_publn_id4 primary key (npl_publn_id)

alter table [tls214_npl_publn_unique_clean3] 
alter column [npl_publn_id] int not null;

--full text
drop fulltext index on tls214_npl_publn_unique_clean
go
drop fulltext catalog tls214_npl_publn_unique_clean_catalog
go

create fulltext catalog tls214_npl_publn_unique_clean_catalog
go

create fulltext index on tls214_npl_publn_unique_clean3(npl_biblio)
key index pk_npl_publn_id4 on tls214_npl_publn_unique_clean_catalog
with stoplist off, change_tracking off, no population
go

alter fulltext index on tls214_npl_publn_unique_clean3
start full population
go


--
--create table
if object_id('results_years') is not null drop table results_years
create table results_years(npl_publn_id int not null, years varchar(4)) --table for storing info about biblio year

declare @searchword varchar(6)
declare @row int = 1
declare @max int = (select max(row) from pattern_years)

--set @row = 0

while (@row <= @max)
--while (@row <= 1)
begin -- result_years contains ids and years that are appear in biblio

	set @searchword = (select years from pattern_years where row = @row)
	insert results_years
	select npl_publn_id, years = substring(@searchword, 2, 4)-- 2nd cause after a comma, 4 length
	from tls214_npl_publn_unique_clean3
	where contains(npl_biblio, @searchword)

	set @row = @row + 1

end

go


--create table
if object_id('results_months') is not null drop table results_months
create table results_months(npl_publn_id int not null, months varchar(3))

declare @searchword varchar(5)
declare @row int = 1
declare @max int = (select max(row) from pattern_months)

--set @row = 0

while (@row <= @max)
--while (@row <= 1)
begin -- same for months as for years

	set @searchword = (select months from pattern_months where row = @row)
	insert results_months
	select npl_publn_id, months = substring(@searchword, 2, 3)
	from tls214_npl_publn_unique_clean3
	where contains(npl_biblio, @searchword)

	set @row = @row + 1

end

drop table #single_results_years
select npl_publn_id, max(years) as year
into #single_results_years
from results_years
group by npl_publn_id


--12 245 767
--803805

drop table #single_results_num
select npl_publn_id, max(num) as num
into #single_results_num
from results_months as a
join year_num as b on a.months = b.[month]
group by npl_publn_id


--5740064
--6100487CONVERT(INT, YourVarcharCol)

drop table tls214_npl_publn_unique_clean_year_month --broken up biblio
select a.npl_publn_id, npl_biblio, left(npl_biblio, 8) as fp, right(npl_biblio, 2) as lp, convert(int, [year]) as [year], num
into tls214_npl_publn_unique_clean_year_month
from tls214_npl_publn_unique_clean3 as a
join #single_results_years as b on a.npl_publn_id = b.npl_publn_id
join #single_results_num as c on a.npl_publn_id = c.npl_publn_id

--select * from tls214_npl_publn_unique_clean_year_month

alter table [tls214_npl_publn_unique_clean_year_month] add constraint pk_npl_publn_id5 primary key (npl_publn_id)

create index idx_fp on tls214_npl_publn_unique_clean_year_month(fp)
create index idx_lp on tls214_npl_publn_unique_clean_year_month(lp)
create index idx_year on tls214_npl_publn_unique_clean_year_month([year])
create index idx_num on tls214_npl_publn_unique_clean_year_month(num)
create index idx_all on tls214_npl_publn_unique_clean_year_month(fp, lp, [year], num)


if object_id('LD') is not null drop table LD
create table LD
(
	npl_publn_id1 int not null,
	npl_publn_id2 int not null,
	[year] int not null,
	LD_perc decimal(10,2) not null
)

declare @batch_year int;
declare @max_year int;
declare @message varchar(60);
set @batch_year = (select min([year]) from tls214_npl_publn_unique_clean_year_month)
set @max_year = (select max([year]) from tls214_npl_publn_unique_clean_year_month)

--process batches
while (@batch_year <= @max_year)
begin
														
    --information about current year
	set @message = 'Year: ' + cast(@batch_year as varchar(4)) + ' Date: ' + convert(varchar(34), getdate())
	raiserror (@message , 0, 1) with nowait 

	insert LD
	select a.npl_publn_id, b.npl_publn_id, a.[year], userdb_emiel.dbo.Compute_LD_perc(a.npl_biblio, b.npl_biblio) 
	from tls214_npl_publn_unique_clean_year_month as a
	join tls214_npl_publn_unique_clean_year_month as b on a.fp = b.fp and a.lp = b.lp and a.[year] = b.[year] and a.num = b.num --front, back and year (batch) the same
	where a.npl_publn_id <> b.npl_publn_id and 
	--where a.npl_publn_id < b.npl_publn_id and
    userdb_emiel.dbo.Compute_LD_perc(a.npl_biblio, b.npl_biblio) >= 0.90 and -- middle part L. distance is high
	a.[year] = @batch_year

	set @batch_year += 1;

end

--add tables together (target table is LD)
insert LD
select *
from LD2


--test
select top 1000 b.*, a.*, c.*
from LD as a
join tls214_npl_publn_unique_clean_year_month as b on a.npl_publn_id1 = b.npl_publn_id
join tls214_npl_publn_unique_clean_year_month as c on a.npl_publn_id2 = c.npl_publn_id --why double?
order by b.npl_publn_id

--clustering

--