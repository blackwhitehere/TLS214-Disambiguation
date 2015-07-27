--N1W1 b

declare @sql nvarchar(max) = 'select distinct a.new_id as new_id1, b.new_id as new_id2
into rule_'+@counter+'
from evaluated_patterns as a
join evaluated_patterns as b on '+@join_condition+' where a.new_id < b.new_id and '+@where_condition+' '
exec (@sql)
