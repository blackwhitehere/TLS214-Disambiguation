use patstat
-- Create a table for specifing patterns for change
if object_id('cleaning_patterns') is not null drop table cleaning_patterns
create table cleaning_patterns
				(step int not null,
				cleaning_pattern nvarchar(max) not null,
				cleaning_source varchar(100) not null,
				cleaning_label nvarchar(max) not null,
				id_counter int identity(1,1) not null
				)
go

--pages
insert into cleaning_patterns select 1, '% pp. %',  ' pp. ', ' pages '
insert into cleaning_patterns select 1, '%,pp. %',  ',pp. ', ', pages ' 
insert into cleaning_patterns select 1, '% page %', ' page ', ' pages '
insert into cleaning_patterns select 1, '%,page %', ',page ', ', pages '
insert into cleaning_patterns select 1, '%,pages %', ',pages ', ', pages '
insert into cleaning_patterns select 1, '% page(s) %', ' page(s) ',  ' pages '
insert into cleaning_patterns select 1, '% pages.%', ' pages.',  ' pages'
--Ger+Fr
insert into cleaning_patterns select 1, '% seiten %', ' seiten ', ' pages '
insert into cleaning_patterns select 1, '% seiten.%', ' seiten.', ' pages'
insert into cleaning_patterns select 1, '% pg. %',  ' pg. ', ' pages '
insert into cleaning_patterns select 1, '% pgs %',  ' pgs ', ' pages '
insert into cleaning_patterns select 1, '% pgs. %',  ' pgs. ', ' pages '
insert into cleaning_patterns select 1, '%,pg. %',  ',pg. ', ' pages '
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
insert into cleaning_patterns select 4, '% no. %', ' no. ', ' no ' --add Number, Issue, Numbers, No.
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
insert into cleaning_patterns select 6, '% Wissenschaft %', ' Wissenschaft ', ' science '

--et al.
insert into cleaning_patterns select 7, '% et al.%', ' et al.', ' et. al'
insert into cleaning_patterns select 7, '% et. al.%', ' et. al.', ' et. al'

--chemical
insert into cleaning_patterns select 8, '% chemical %', ' chemical ', ' chem. '
insert into cleaning_patterns select 8, '% chem %', ' chem ', ' chem. '

--national
insert into cleaning_patterns select 9, '% national %', ' national ', ' natl. '
insert into cleaning_patterns select 9, '% natl %', ' natl ', ' natl. '

--[ - ] on single digits
insert into cleaning_patterns select 10, '%[0-9] - [0-9]%', ' - ', '-'

--months
insert into cleaning_patterns select 11, '% jan. %', ' jan. ', ' jan '
insert into cleaning_patterns select 11, '% january %', ' january ', ' jan '
insert into cleaning_patterns select 11, '% januer %', ' januer ', ' jan '
insert into cleaning_patterns select 11, '% januier %', ' januier ', ' jan '
insert into cleaning_patterns select 11, '% feb. %', ' feb. ', ' feb '
insert into cleaning_patterns select 11, '% february %', ' february ', ' feb '
insert into cleaning_patterns select 11, '% februar %', ' februar ', ' feb '
insert into cleaning_patterns select 11, '% février %', ' février ', ' feb '
insert into cleaning_patterns select 11, '% mar. %', ' mar. ', ' mar '
insert into cleaning_patterns select 11, '% march %', ' march ', ' mar '
insert into cleaning_patterns select 11, '% märz %', ' märz ', ' mar '
insert into cleaning_patterns select 11, '% mars %', ' mars ', ' mar '
insert into cleaning_patterns select 11, '% apr. %', ' apr. ', ' apr '
insert into cleaning_patterns select 11, '% april %', ' april ', ' apr '
insert into cleaning_patterns select 11, '% avril %', ' avril ', ' apr '
insert into cleaning_patterns select 11, '% mai %', ' mai ', ' may '
insert into cleaning_patterns select 11, '% jun. %', ' jun. ', ' jun '
insert into cleaning_patterns select 11, '% june %', ' june ', ' jun '
insert into cleaning_patterns select 11, '% juni %', ' juni ', ' jun '
insert into cleaning_patterns select 11, '% juin %', ' juin ', ' jun '
insert into cleaning_patterns select 11, '% jul. %', ' jul. ', ' jul '
insert into cleaning_patterns select 11, '% july %', ' july ', ' jul '
insert into cleaning_patterns select 11, '% juli %', ' juli ', ' jul '
insert into cleaning_patterns select 11, '% juilliet %', ' juilliet ', ' jul '
insert into cleaning_patterns select 11, '% aug. %', ' aug. ', ' aug '
insert into cleaning_patterns select 11, '% augustus %', ' augustus ', ' aug '
insert into cleaning_patterns select 11, '% août %', ' août ', ' aug '
insert into cleaning_patterns select 11, '% sep. %', ' sep. ', ' sep '
insert into cleaning_patterns select 11, '% sept. %', ' sept. ', ' sep '
insert into cleaning_patterns select 11, '% september %', ' september ', ' sep '
insert into cleaning_patterns select 11, '% oct. %', ' oct. ', ' oct '
insert into cleaning_patterns select 11, '% october %', ' october ', ' oct '
insert into cleaning_patterns select 11, '% oktober %', ' oktober ', ' oct '
insert into cleaning_patterns select 11, '% octobre %', ' octobre ', ' oct '
insert into cleaning_patterns select 11, '% nov. %', ' nov. ', ' nov '
insert into cleaning_patterns select 11, '% november %', ' november ', ' nov '
insert into cleaning_patterns select 11, '% novembre %', ' novembre ', ' nov '
insert into cleaning_patterns select 11, '% dec. %', ' dec. ', ' dec '
insert into cleaning_patterns select 11, '% december %', ' december ', ' dec '
insert into cleaning_patterns select 11, '% dezember %', ' dezember ', ' dec '
insert into cleaning_patterns select 11, '% décembre %', ' décembre ', ' dec '

--add index
--create index idx_cleaning_patterns on cleaning_patterns(cleaning_pattern)

-------------------
-- 4.3b Execute the changes specified in the cleaning table

--initialization
declare @loopcounter int = 1
declare @loopmax int = (select max(step) from cleaning_patterns)


while (@loopcounter <= @loopmax)
begin
	update a
	set a.npl_biblio = replace(a.npl_biblio, b.cleaning_source, b.cleaning_label) -- replace biblio's substring with its label 
	from sample_unique as a
	join cleaning_patterns as b on patindex(b.cleaning_pattern, a.npl_biblio) <> 0 --provided a pattern is found
	where step = @loopcounter
	set @loopcounter += 1
end
go
