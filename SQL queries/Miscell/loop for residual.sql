use patstat
go


declare @step int = 1
declare @step_max int = (select count(*) from extraction_patterns) - (select count(*) from extraction_patterns where step>=99)
declare @pattern nvarchar(max)
declare @label nvarchar(max)
declare @match nvarchar(max)
declare @tuple_counter int = 1
declare @tuple_max int = (select count(*) from sample_unique)
declare @omitted_patterns int =1 -- number of pattern that were commented in extraction patterns reg exp tank

while (@tuple_counter<=@tuple_max)
begin
	while (@step<=(@step_max+@omitted_patterns))
	begin
		set @pattern = (select extraction_pattern from extraction_patterns where step=@step) --@step=1 --> @pattern=\b(?<Month>Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)(\s|\.|\.\s)?(?<Date>\d+)
		
		update a
		set a.residual = dbo.RegexReplace(a.residual, @pattern, '')
		from tls214_extracted_patterns as a
		where npl_publn_id=@tuple_counter

		set @step=@step+1
	end

set @tuple_counter=@tuple_counter+1
end

select * from tls214_extracted_patterns
