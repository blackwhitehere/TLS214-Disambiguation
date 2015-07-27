/*
Authors : Emiel, Stanislaw
Date    : June 4, 2015
Description : Pre-cleaning patstat's non-patent literature data, i.e. the [tls214_npl_publn] table
*/

use patstat
go

--1
--remove spaces at begin and end of string
--replacing double spaces by single space
drop table #tmp1
select npl_publn_id, lower(rtrim(ltrim(replace(npl_biblio,'  ',' ')))) as npl_biblio
into #tmp1
from [tls214_npl_publn]


--2
--initial cleaning b
--remove '.'  on last position of string
drop table #tmp2
select npl_publn_id, iif((substring(npl_biblio, len(npl_biblio), 1) = '.'), left(npl_biblio, len(npl_biblio) - 1) ,npl_biblio) as npl_biblio
into #tmp2
from #tmp1

drop table #tmp1

--3
--remove diacritics from string
drop table #tmp3
select npl_publn_id, cast([npl_biblio] as varchar(max)) collate SQL_Latin1_General_CP1253_CI_AI as npl_biblio
into #tmp3
from #tmp2

drop table #tmp2

--4
--remove multiple spaces
while exists (select * from #tmp3 where (npl_biblio like '%  %'))
begin
  update #tmp3
  set npl_biblio=replace(npl_biblio,'  ',' ')
  where (npl_biblio like '%  %')
end
go

----------------------------------------------------------------------------------------------------------------
/**
After the prec cleaning we can work with a smaller table
*/
--store unique npl_publn in a new table
drop table [tls214_npl_publn_unique]
create table [tls214_npl_publn_unique](
	npl_publn_id int identity(1,1) not null,
	npl_biblio nvarchar(max) collate Latin1_General_CI_AS not null
constraint pk_npl_publn_id2 primary key (npl_publn_id))
go

--populate table with distinct values for npl_biblio
insert into tls214_npl_publn_unique(npl_biblio)
select distinct npl_biblio
from #tmp3
order by npl_biblio

--glue table 
drop table npl_biblio_glue
select a.npl_publn_id as npl_publn_id_new, b.npl_publn_id
into npl_biblio_glue
from tls214_npl_publn_unique as a
join #tmp3 as b on a.npl_biblio = b.npl_biblio

drop table #tmp3




----------------------------------------------------------------------------------------------------------------
/*
- I still need to check this part
- After the first cleaning we can harmonize the strings 
- Check for matching
*/

--create table with org patterns
if object_id('cleaning_patterns') is not null drop table cleaning_patterns
create table cleaning_patterns(step int not null, cleaning_pattern varchar(100) not null, cleaning_source varchar(100) not null, cleaning_label varchar(100) not null)
go

--select * from cleaning_patterns

--pages
--rule with journal convert to j.???
insert into cleaning_patterns select 1, '% pp. %',  ' pp. ', ' pages '
insert into cleaning_patterns select 1, '%,pp. %',  ',pp. ', ', pages '
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
insert into cleaning_patterns select 11, '% jan. %', ' jan. ', ' jan '
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

--loop
while (@loopcounter <= @loopmax)
begin
    
	update a
	set a.npl_biblio = replace(a.npl_biblio, b.cleaning_source, b.cleaning_label)  
	from [tls214_npl_publn_unique] as a
	join cleaning_patterns as b on patindex(b.cleaning_pattern, a.npl_biblio) <> 0  
	where step = @loopcounter

	set @loopcounter += 1

end


----------------------------------------------------------------------------------------------------------------
/* 
I want to use this function to strip characters
I have some ideas for this function
*/
go
--drop function [dbo].[fn_stripcharacters]
create function [dbo].[fn_stripcharacters]
(
    @string nvarchar(max), 
    @matchexpression varchar(255)
)
returns nvarchar(max)
as
begin
    set @matchexpression =  '%['+@matchexpression+']%'

    while patindex(@matchexpression, @string) > 0
        set @string = stuff(@string, patindex(@matchexpression, @string), 1, '') --deletes found expression from string

    return @string -- opposite of matched expression is returned

end
go
--strip values
drop table #tmp
select top 10000 npl_publn_id, npl_biblio, 
           dbo.fn_StripCharacters(npl_biblio, '^a-z0-9') as bib_alphanumeric,
		   dbo.fn_StripCharacters(npl_biblio, '^0-9') as bib_numeric,
		   dbo.fn_StripCharacters(npl_biblio, '^a-z') as bib_alphabetic
into #tmp
from [tls214_npl_publn_unique] 



