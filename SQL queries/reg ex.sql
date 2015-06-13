go
use patstat
go
sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

CREATE ASSEMBLY 
--assembly name for references from SQL script
SqlRegularExpressions 
-- assembly name and full path to assembly dll,
-- SqlRegularExpressions in this case
from 'd:\Projects\SqlRegularExpressions\SqlRegularExpressions\bin\Release\SqlRegularExpressions.dll' 
WITH PERMISSION_SET = SAFE
go

go
drop assembly 
--assembly name for references from SQL script
SqlRegularExpressions
go

--function signature
CREATE FUNCTION RegExpLike(@Text nvarchar(max), @Pattern nvarchar(255)) RETURNS BIT
--function external name
AS EXTERNAL NAME SqlRegularExpressions.SqlRegularExpressions.[Like]
go

go
select * from sample_table as sa
where 1 = dbo.RegExpLike(sa.npl_biblio, '\b(A\S+)')
go

CREATE FUNCTION 
--function signature
RegExpMatches(@text nvarchar(max), @pattern nvarchar(255))
RETURNS TABLE 
([Index] int, [Length] int, [Value] nvarchar(255))
AS 
--external name
EXTERNAL NAME SqlRegularExpressions.SqlRegularExpressions.GetMatches
GO

-- RegExpMatches sample
DECLARE @Text nvarchar(max);
DECLARE @Pattern nvarchar(255);
 
SET @Text = 
'This is comprehensive compendium provides a broad and thorough investigation of all '
+ 'aspects of programming with ASP.Net. Entirely revised and updated for the 2.0 '
+ 'Release of .Net, this book will give you the information you need to master ASP.Net '
+ 'and build a dynamic, successful, enterprise Web application.';
SET @Pattern = '\b(a\S+)';   --get all words that start from 'a'

select *
from dbo.RegExpMatches(@Text, @Pattern)
GO

select *
from sample_table