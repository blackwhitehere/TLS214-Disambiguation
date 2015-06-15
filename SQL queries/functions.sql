use patstat

declare @dummy int
create function [dbo].[bool_double_space] (@biblio nvarchar(max))
returns bit
as
	set @dummy = replace(biblio,'  ',' ')
	if (@dummy==@biblio) return 1
	else 0

end