--CLEANING
/*
This stage alters data stored in the npl_biblio in order to harmonize string patterns into consistent format.
Normalization of popular tags allows to use less complicated Regular Expression rules in the Label Extraction process.
*/

use patstat
go

-- Create a table for specifing patterns for change
if object_id('cleaning_patterns') is not null drop table cleaning_patterns
create table cleaning_patterns
				(step int not null,
				cleaning_pattern nvarchar(max) not null
				,cleaning_label nvarchar(max) not null
				,step_counter int identity(1,1) not null
				,count_affected int
				constraint pk_cleaning_patterns_id primary key (step_counter)
				)
go

--delimiter
insert into cleaning_patterns select 1, ';', ',',''
--pages
insert into cleaning_patterns select 2, '(?i)((?<=\b)(((p(p\.?|gs?)\.?)|page\(?s?\)?\.?)(?=\s?\d+))|((?<=\b)(seiten?\.?)(?=\s?\d+)))|(((?<=\d+\s?)(((p(p\.?|gs?)\.?)|page\(?s?\)?\.?)(?=\b))|((?<=\d+\s?)(seiten?\.?)(?=\b))))', 'pages',''
insert into cleaning_patterns select 3, '(?i)(?<=\s|,)(p\.?(?=(\s?\d+(\b|[-,./]))))', ' pages ',''

--volume
insert into cleaning_patterns select 4, '(?i)((?<=\b)((v(ol)?\.?(olume(s|n)?)?|bd?\.?|tome)(?=\s?\d+)))|((?<=\d+\s?)((v(ol)?\.?(olume(s|n)?)?|bd?\.?|tome)(?=\s?,)))', ' vol ',''
--issue
insert into cleaning_patterns select 5, '(?i)(?<=\b)((((n(o|r)?\.?)|heft|issue)([:,.])?)(?=\s?\d+))', 'no ',''
--et. al
insert into cleaning_patterns select 6, '(?i)(?<=\b)((et\.?\s?al)(?=(\s|\.|:)))', 'et. al',''
--proceedings
insert into cleaning_patterns select 7, '(?i)(?<=\b)((proc(eedings)?)(?=(\s|\.)))', 'proc',''
--science
insert into cleaning_patterns select 7, '(?i)(?<=\b)((sci|wissenschaft)(?=(\s|\.)))', 'science',''
--chem
insert into cleaning_patterns select 7, '(?i)(?<=\b)((chem(ical)?)(?=(\s|\.)))', 'chem',''
--natl
insert into cleaning_patterns select 7, '(?i)(?<=\b)((nat(l|ional))(?=(\s|\.)))', 'natl',''
--appl
insert into cleaning_patterns select 7, '(?i)(?<=\b)((appl(\.|n|ication))(?=(\s|\.)))', 'appln',''
--publ
insert into cleaning_patterns select 7, '(?i)(?<=\b)((publ(n|ication))(?=(\s|\.)))', 'publn',''
--artl
insert into cleaning_patterns select 7, '(?i)(?<=\b)((art(l|icle))(?=(\s|\.)))', 'artl',''
--artl
insert into cleaning_patterns select 7, '(?i)(?<=\b)((abstr(act)?)(?=(\s|\.)))', 'abstract',''
--artl
insert into cleaning_patterns select 7, '(?i)(?<=\b)((mag(azine)?)(?=(\s|\.)))', 'magazine',''
--jour
insert into cleaning_patterns select 7, '(?i)(?<=\b)((jour(nal)?)(?=(\s|\.)))', 'jour',''
--pct
insert into cleaning_patterns select 7, '(?i)(?<=\b)(pct)(?=([\s\./\-,]))', 'pct',''
--issn
insert into cleaning_patterns select 7, '(?<=\b)(issn)(?=([\s\./\-,:0-9]))', 'ISSN',''
--isbn
insert into cleaning_patterns select 7, '(?<=\b)(isbn)(?=([\s\./\-,:0-9]))', 'ISBN',''
--xp
insert into cleaning_patterns select 7, '(?<=\b)(isbn)(?=([\s\./\-,:0-9]))', 'XP',''
--\w-\w
insert into cleaning_patterns select 8, '\s?(-)\s?', '$1',''


--months
insert into cleaning_patterns select 12, '(?i)\bjan.?(\s|\b)', ' jan ',''
insert into cleaning_patterns select 13, '(?i)\bjanuary\b', ' jan ',''
insert into cleaning_patterns select 14, '(?i)\bjanuer\b', ' jan ',''
insert into cleaning_patterns select 15, '(?i)\bjanuier\b', ' jan ',''
insert into cleaning_patterns select 16, '(?i)\bfeb.?(\s|\b)', ' feb ',''
insert into cleaning_patterns select 17, '(?i)\bfebruary\b', ' feb ',''
insert into cleaning_patterns select 18, '(?i)\bfebruar\b', ' feb ',''
insert into cleaning_patterns select 19, '(?i)\bfévrier\b', ' feb ',''
insert into cleaning_patterns select 20, '(?i)\bmar.?(\s|\b)', ' mar ',''
insert into cleaning_patterns select 21, '(?i)\bmarch\b', ' mar ',''
insert into cleaning_patterns select 22, '(?i)\bmärz\b', ' mar ',''
insert into cleaning_patterns select 23, '(?i)\bmars\b', ' mar ',''
insert into cleaning_patterns select 24, '(?i)\bapr.?(\s|\b)', ' apr ',''
insert into cleaning_patterns select 25, '(?i)\bapril\b', ' apr ',''
insert into cleaning_patterns select 26, '(?i)\bavril\b', ' apr ',''
insert into cleaning_patterns select 27, '(?i)\bmai\b', ' may ',''
insert into cleaning_patterns select 28, '(?i)\bjun.?(\s|\b)', ' jun ',''
insert into cleaning_patterns select 29, '(?i)\bjune\b', ' jun ',''
insert into cleaning_patterns select 30, '(?i)\bjuni\b', ' jun ',''
insert into cleaning_patterns select 31, '(?i)\bjuin\b', ' jun ',''
insert into cleaning_patterns select 32, '(?i)\bjul.?(\s|\b)', ' jul ',''
insert into cleaning_patterns select 33, '(?i)\bjuly\b', ' jul ',''
insert into cleaning_patterns select 34, '(?i)\bjuli\b', ' jul ',''
insert into cleaning_patterns select 35, '(?i)\bjuilliet\b', ' jul ',''
insert into cleaning_patterns select 36, '(?i)\baug.?(\s|\b)', ' aug ',''
insert into cleaning_patterns select 37, '(?i)\baugust(us)?\b', ' aug ',''
insert into cleaning_patterns select 38, '(?i)\baoût\b', ' aug ',''
insert into cleaning_patterns select 39, '(?i)\bsep.?(\s|\b)', ' sep ',''
insert into cleaning_patterns select 40, '(?i)\bsept.?(\s|\b)', ' sep ',''
insert into cleaning_patterns select 41, '(?i)\bseptember\b', ' sep ',''
insert into cleaning_patterns select 42, '(?i)\boct.?(\s|\b)', ' oct ',''
insert into cleaning_patterns select 43, '(?i)\boctober\b', ' oct ',''
insert into cleaning_patterns select 44, '(?i)\boktober\b', ' oct ',''
insert into cleaning_patterns select 45, '(?i)\boctobre\b', ' oct ',''
insert into cleaning_patterns select 46, '(?i)\bnov.?(\s|\b)', ' nov ',''
insert into cleaning_patterns select 47, '(?i)\bnovember\b', ' nov ',''
insert into cleaning_patterns select 48, '(?i)\bnovembre\b', ' nov ',''
insert into cleaning_patterns select 49, '(?i)\bdec.?(\s|\b)', ' dec ',''
insert into cleaning_patterns select 50, '(?i)\bdecember\b', ' dec ',''
insert into cleaning_patterns select 51, '(?i)\bdezember\b', ' dec ',''
insert into cleaning_patterns select 52, '(?i)\bdécembre\b', ' dec ',''


--Initialization
declare @loopcounter int = 1
declare @loopmax int = (select max(step_counter) from cleaning_patterns)

--Loop
while (@loopcounter <= @loopmax)
begin
	update	a
	set		a.npl_biblio = dbo.RegexReplace(a.npl_biblio, b.cleaning_pattern, b.cleaning_label) -- replace npl_biblio's substring with its label
	from	sample_unique as a
	join	cleaning_patterns as b
			on dbo.IsMatch(a.npl_biblio, b.cleaning_pattern) <> 0 --provided a pattern is found
	where	step_counter = @loopcounter

	set		@loopcounter += 1
end
go

-- Bring spacing patterns to a common format
update	a
set		npl_biblio = rtrim(ltrim(dbo.RegexReplace(npl_biblio,' {2,}',' ')))
from	sample_unique as a
go

--display results
select * from sample_unique