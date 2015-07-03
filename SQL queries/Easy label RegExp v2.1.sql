use patstat
go

-- Create a table for specifing patterns for change
if object_id('extraction_patterns') is not null drop table extraction_patterns
create table extraction_patterns
				(step int not null,
				extraction_label nvarchar(max) not null,
				extraction_pattern nvarchar(max) not null,
				)
go

--populate table 
insert into extraction_patterns select 1, 'month_date', '\b(?<Month>Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)(\s|\.|\.\s)?(?<Date>\d+)'
insert into extraction_patterns select 2, 'easy_year', '(18[5-9][0-9])|(19[0-9][0-9])|(20(0|1)[1-5])'
--insert into extraction_patterns select 3, 'date_american', '\b(0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])[- /.](19|20)?[0-9]{2}\b','month','day','year',3
--insert into extraction_patterns select 4, 'date_european', '\b(0?[1-9]|[12][0-9]|3[01])[- /.](0?[1-9]|1[012])[- /.](19|20)?[0-9]{2}\b','day','month','year',3
--insert into extraction_patterns select 5, 'date_japan', '\b(19|20)?[0-9]{2}[- /.](0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])\b','year','month','day',3
--insert into extraction_patterns select 6, 'easy_pages', '(?<=(\bpages\b(\.|,)?\s*))(\d+)((?:(\s(?:to\s)?(?:-\s)?|-|/))?)(\d*)'
--insert into extraction_patterns select 7, 'easy_volume', '(?<=(\bvol\s*))(\d+)'
--insert into extraction_patterns select 8, 'easy_no', '(?<=(\bNo(\.|,|\.;)?\s*))(\d+)'
--insert into extraction_patterns select 9, 'easy_xp', 'XP(\s|:)?(:|-)?(\s?)(\d){4,9}\b'
--insert into extraction_patterns select 10, 'easy_issn', 'ISSN(:|\s)?(\s|:)?\s?(\d{4})(-|\s)?(-\s)?(\d{3,4})(\w?)\b'
--insert into extraction_patterns select 11, 'easy_isbn', 'ISBN(\s|:)?(\s)?([0-9-x\s_]{10,17})\b'
--insert into extraction_patterns select 12, 'easy_bibliographic_type', 'Journal|Magazine|Abstract|Article'
--insert into extraction_patterns select 13, 'easy_aetal', '[a-zA-Z,.\s]+(?=\s?et(\.\s|\.|\s)?al)'
--insert into extraction_patterns select 14, 'easy_url', '\b(https?|ftp|file)://[A-Z0-9+&@#/%?=~_|$!:,.;-]*[A-Z0-9+&@#/%=~_|$]'
--insert into extraction_patterns select 15, 'easy_email', '\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}\b'
--etc

--add index
create index idx_extraction_patterns on extraction_patterns(step)

--table definition

if object_id('su_extracted_patterns') is not null drop table su_extracted_patterns
create table su_extracted_patterns
				(npl_publn_id int not null)
go

--populate table with npl_publn_ids
insert into su_extracted_patterns(npl_publn_id)
select npl_publn_id
from [dbo].[sample_unique]
go

--append all new columns to su_extracted_patterns
declare @step_counter int = 1
declare @step_max int = (select count (*) from extraction_patterns)
declare @label nvarchar(max)=''
declare @pattern nvarchar(max)=''

while (@step_counter <= @step_max)
begin
	set @label = (select extraction_label from extraction_patterns where step=@step_counter)

	declare @sql1 nvarchar(max)=''
	set @sql1 = 'alter table su_extracted_patterns add '+@label+' nvarchar(max) '
	exec(@sql1)
	
	set @label=''
	
	set @step_counter = @step_counter + 1
end;

go

--lookup regexps and append results to su_extracted patterns.
declare @step_counter int = 1
declare @step_max int = (select count (*) from extraction_patterns)
declare @label nvarchar(max)=''
declare @pattern nvarchar(max)=''
set @step_counter=1
while (@step_counter <= @step_max)
begin
	set @label = (select extraction_label from extraction_patterns where step=@step_counter)
	set @pattern = (select extraction_pattern from extraction_patterns where step = @step_counter)

	select npl_publn_id, dbo.IsMatchValue(npl_biblio, @pattern) as [@label]
	into #tmp1
	from dbo.sample_unique where dbo.IsMatchValue(npl_biblio, @pattern) <> ''
	
	declare @sql3 varchar(max)=''
	set @sql3='update su_extracted_patterns set su_extracted_patterns.'+@label+'=#tmp1.'+@label+' from su_extracted_patterns left join #tmp1 on a.npl_publn_id = b.npl_publn_id '
	execute (@sql3)

	set @label=''
	set @pattern=''
	drop table #tmp1
	set @step_counter = @step_counter + 1
end
go

--test
/*
declare @test nvarchar(max)=''
declare @sql nvarchar(max)=''
set @test='month_date'
set @sql = 'select '+@test+' from su_extracted_patterns'
exec (@sql)


Loop 2:
while(step counter <= step max && n_of_capturing_g is not null)
	while (g_counter<=max_g_count)
	update su_extracted_patterns
	set a.
 */
