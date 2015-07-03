use patstat
go

-- Create a table for specifing patterns for change
if object_id('extraction_patterns') is not null drop table extraction_patterns
create table extraction_patterns
				(step int not null,
				extraction_label varchar(100) not null,
				extraction_pattern varchar(200) not null)
go

--populate table 
insert into extraction_patterns select 1, 'month_date', '\b(?<Month>Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)(\s|\.|\.\s)?(?<Date>\d+)'
insert into extraction_patterns select 2, 'tentative easy_year', '(18[5-9][0-9])|(19[0-9][0-9])|(20(0|1)[1-5])'
insert into extraction_patterns select 3, 'date_american', '\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2}\b'
insert into extraction_patterns select 4, 'date_european', '\b(0?[1-9]|[12][0-9]|3[01])[- /.](0?[1-9]|1[012])[- /.](19|20)?[0-9]{2}\b'
insert into extraction_patterns select 5, 'date_japan', '\b(19|20)?[0-9]{2}[- /.](0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])\b'
insert into extraction_patterns select 6, 'easy_pages', '(?<=(\bpages\b(\.|,)?\s*))(\d+)((?:(\s(?:to\s)?(?:-\s)?|-|/))?)(\d*)'
insert into extraction_patterns select 7, 'easy_volume', '(?<=(\bvol\s*))(\d+)'
insert into extraction_patterns select 8, 'easy_no', '(?<=(\bNo(\.|,|\.;)?\s*))(\d+)'
insert into extraction_patterns select 9, 'easy_xp', 'XP(\s|:)?(:|-)?(\s?)(\d){4,9}\b'
insert into extraction_patterns select 10, 'easy_issn', 'ISSN(:|\s)?(\s|:)?\s?(\d{4})(-|\s)?(-\s)?(\d{3,4})(\w?)\b'
insert into extraction_patterns select 11, 'easy_isbn', 'ISBN(\s|:)?(\s)?([0-9-x\s_]{10,17})\b'
insert into extraction_patterns select 12, 'easy_bibliographic_type', 'Journal|Magazine|Abstract|Article'
insert into extraction_patterns select 13, 'easy_aetal', '[a-zA-Z,.\s]+(?=\s?et(\.\s|\.|\s)?al)'
insert into extraction_patterns select 14, 'easy_url', '\b(https?|ftp|file)://[A-Z0-9+&@#/%?=~_|$!:,.;-]*[A-Z0-9+&@#/%=~_|$]'
insert into extraction_patterns select 15, 'easy_email', '\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}\b'
--etc

declare @columns varchar(max) = '['+(select extraction_label from extraction_patterns where step=1) +']'
declare @step_counter int = 2
declare @step_max int = (select count (*) from extraction_patterns)
while (@step_counter <= @step_max)
	declare @label varchar(max) = (select extraction_label from extraction_patterns where step=@step_counter)
	set @columns = @columns + ',' + '['+ @label + ']'
	set @step_counter = @step_counter + 1

DECLARE @query  AS NVARCHAR(MAX)
set @query = 'SELECT ' + @columns + ' ' + 'from (select extraction_label,extraction_pattern from extraction_patterns) pivot (extraction_pattern for extraction_label in ('+@columns+'))'
exec sp_executesql @query;