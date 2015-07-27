--REGULAR EXPRESSION FORMAT PATTERNS

/*
This stage focuses on format labels.
In particular format based Regular Expression name search is performed.
RegExp are based on Name Transcription Arity model.
Due to high computational capacity this extraction is seperate.

n		- "Abcde" word class
N		- "ABCDE" word class
[nN]	- Either n of N word class
I		- Initial - One Capital letter word class
{x,y}	- Class Quantifier capturing between x and y time, as much times as possible
A		-[nN]{1,3}I{1,3}[nN]{1,3}
A1		-[nN]I[nN]
B		-[nN]{1,3}I{1,3}
B1		-[nN]I
C		-I{1,3}[nN]{1,3}
C1		-I[nN]
D		-[nN]{2,3}
*/

use patstat
go

-- Create a table for specifing patterns
if object_id('extraction_patterns_format') is not null drop table extraction_patterns_format
create table extraction_patterns_format
				(
				step				int not null
				,extraction_label	varchar(100) not null
				,extraction_pattern varchar(200) not null
				,reg_exp_id			int identity(1,1) not null
				)
go

--Names

insert into extraction_patterns_format select 16, 'nameA',		'([A-Z][a-z]+(?:\s|-)|[A-Z]+(\s|-)){1,3}([A-Z]\.?){1,3}\s([A-Z][a-z]+(\s|-)?|[A-Z]+(?:\s|-)?){1,3}'
insert into extraction_patterns_format select 17, 'nameA1',		'\b([A-Z][a-z]+|[A-Z]{3,})(?:\s|-)([A-Z]\.?)(?:\s|-)([A-Z][a-z]+|[A-Z]{3,})'
insert into extraction_patterns_format select 18, 'nameB',		'\b([A-Z](\.\s?)?){1,3}\s([A-Z][a-z]+(\s|-)?|[A-Z]{3,}(\s|-)?){1,3}\b'
insert into extraction_patterns_format select 19, 'nameB1',		'(\b([A-Z](\.\s?|\s))([A-Z]{3,})\b)|(\b([A-Z](\.\s?|\s))([A-Z][a-z]+)\b)'
insert into extraction_patterns_format select 20, 'nameC',		'\b([A-Z][a-z,]+(\s|-)|[A-Z,]{3,}(\s|-)){1,3}([A-Z](\.|\s|\.\s)?){1,3}\b'
insert into extraction_patterns_format select 21, 'nameC1',		'(\b([A-Z](\.\s?|\s)){3}([A-Z]{3,}))|(\b([A-Z](\.\s?|\s)){3}([A-Z][a-z]+))'
insert into extraction_patterns_format select 22, 'nameD',		'(((([A-Z][a-z]+)|([A-Z]{3,}))(?:\s|,|\b)){2,3})(?=,|;)'
insert into extraction_patterns_format select 23, 'nameE',		'^[a-zA-Z.\s]+(,|:)'
--Other
insert into extraction_patterns_format select 24, 'easy_url',	'\b(?<=((https?|ftp|file)(://)|www\.))[A-Z0-9+&@#/%?=~_|$!:,.;-]*[A-Z0-9+&@#/%=~_|$]'
--String
insert into extraction_patterns_format select 99,	's_start',					'^(.){8}'
insert into extraction_patterns_format select 100,	's_end',					'(.){8}$'
insert into extraction_patterns_format select 101,	'bib_numeric',				'[^0-9]+'
insert into extraction_patterns_format select 102,	'bib_alphabetic',			'[^A-z ]+'
insert into extraction_patterns_format select 103,	'bib_alphanumeric',			'[^A-z0-9 ]+'
insert into extraction_patterns_format select 104,	'npl_biblio_length',		''
insert into extraction_patterns_format select 105,	'sum_of_numbers',			''
insert into extraction_patterns_format select 106,	'count_of_numbers',			''
go

--Add new columns to the tls214_extracted_patterns table to store results of regular expressions

declare @counter int = 1
declare @count_max int = (select count(*) from extraction_patterns_format)


while (@counter<=@count_max)
begin
	declare @label nvarchar(max)=(select extraction_label from extraction_patterns_format where reg_exp_id=@counter)
	declare @sql nvarchar(max) ='alter table tls214_extracted_patterns add '+@label+' nvarchar(max) '
	exec	(@sql)
	set		@label=''
	set		@counter=@counter+1
end
go

--Names

--nameA
	 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 16)
update	a
set		a.nameA = b.nameA
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,'&&&')
from	tls214_extracted_patterns as a
join	(
		select	new_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameA
		from	[dbo].[sample_unique]
		where	dbo.GetMatchesCSV(npl_biblio, @pattern) <> ''
		) as b on a.new_id = b.new_id
go

--nameA1
		 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 17)
update	a
set		a.nameA1 = b.nameA1
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,'&&&')
from	tls214_extracted_patterns as a
join	(
		select	new_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameA1
		from	[dbo].[sample_unique]
		where	dbo.GetMatchesCSV(npl_biblio, @pattern) <> ''
		) as b on a.new_id = b.new_id
go

--nameB
	 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 18)
update	a
set		a.nameB = b.nameB
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,'&&&')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameB
		from [dbo].[sample_unique]
		where dbo.GetMatchesCSV(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--nameB1
		 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 19)
update	a
set		a.nameB1 = b.nameB1
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,'&&&')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameB1
		from [dbo].[sample_unique]
		where dbo.GetMatchesCSV(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--nameC
			 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 20)
update	a
set		a.nameC = b.nameC
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,'&&&')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameC
		from [dbo].[sample_unique]
		where dbo.GetMatchesCSV(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--nameC1
	 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 21)
update	a
set		a.nameC1 = b.nameC1
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,'&&&')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameC1
		from [dbo].[sample_unique]
		where dbo.GetMatchesCSV(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--nameD
			 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 22)
update	a
set		a.nameD = b.nameD
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,'&&&')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.GetMatchesCSV(npl_biblio, @pattern) as nameD
		from [dbo].[sample_unique]
		where dbo.GetMatchesCSV(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--nameE

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 23)
update	a
set		a.nameE = b.nameE
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,'&&&')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as nameE
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

/*
--url			 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 24)
update a
set		a.easy_url  = lower(b.easy_url)
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as easy_url 
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		) as b on a.new_id = b.new_id
go

*/

--Special

--s_start	
	 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 99)
update	a
set		a.s_start  = b.s_start
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as s_start 
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go	

--s_end		
 
declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 100)
update	a
set		a.s_end  = b.s_end
		,a.residual=dbo.RegexReplace(a.residual, @pattern ,' &&& ')
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.IsMatchValue(npl_biblio, @pattern) as s_end 
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go

--numeric

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 101)
update	a
set		a.bib_numeric  = b.bib_numeric 
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.RegexReplace(npl_biblio, @pattern,'') as bib_numeric
		from [dbo].[sample_unique]
		where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
		)
		as b on a.new_id = b.new_id
go				     

--alphabetic

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 102)
update	a
set		a.bib_alphabetic  = b.bib_alphabetic 
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.RegexReplace(npl_biblio, @pattern,'') as bib_alphabetic
		from [dbo].[sample_unique]
		)
		as b on a.new_id = b.new_id
go

--alphanumeric

declare @pattern varchar(200) = (select extraction_pattern from extraction_patterns_format where step = 103)
update	a
set		a.bib_alphanumeric  = b.bib_alphanumeric
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.RegexReplace(npl_biblio, @pattern,'') as bib_alphanumeric
		from [dbo].[sample_unique]
		)
		as b on a.new_id = b.new_id
go

--Biblio length

update	a
set		a.npl_biblio_length  = b.npl_biblio_length 
from	tls214_extracted_patterns as a
join	(
		select new_id, len(npl_biblio) as npl_biblio_length 
		from [dbo].[sample_unique]
		where len(npl_biblio)> 0
		)
		as b on a.new_id = b.new_id
go

--Sum of Numbers

update	a
set		a.sum_of_numbers  = b.sum_of_numbers
from	tls214_extracted_patterns as a
join	(
		select new_id, dbo.SumIntDigits(bib_numeric) as sum_of_numbers
		from tls214_extracted_patterns
		where bib_numeric is not null
		)
		as b on a.new_id = b.new_id
go

--Count of numbers

update	a
set		a.count_of_numbers  = b.count_of_numbers
from	tls214_extracted_patterns as a
join	(
		select new_id, len(bib_numeric) as count_of_numbers
		from tls214_extracted_patterns
		where len(bib_numeric)> 0
		)
		as b on a.new_id = b.new_id
go

---------
--Inspect
---------

select	*
from	tls214_extracted_patterns as a
go