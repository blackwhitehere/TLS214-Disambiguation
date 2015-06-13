go
use patstat
go

sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

--drop all the functions

drop function LD;
drop function LDPerc;
drop function SCR;
drop function SumOfNum;
go

--drop the assembly
Drop assembly RegExp
go

--create the assembly

CREATE ASSEMBLY RegExp 
from 'C:\Users\stan\Documents\GitHub\TLS214-Disambiguation\VS\Disambiguation\Sample\bin\Debug\Sample.dll' 
WITH PERMISSION_SET = SAFE
go

--create functions

CREATE FUNCTION	LD (@string1 nvarchar(max), @string2 nvarchar(max))
RETURNS	int
AS EXTERNAL NAME RegExp.UserDefinedFunctions.ComputeDistance;
go

CREATE FUNCTION	LDPerc (@string1 nvarchar(max), @string2 nvarchar(max))
RETURNS	float
AS EXTERNAL NAME RegExp.UserDefinedFunctions.ComputeDistancePerc;
go

CREATE FUNCTION	SCR (@string1 nvarchar(max))
RETURNS nvarchar(max)
AS EXTERNAL NAME RegExp.UserDefinedFunctions.SpecialCharacterRemover;
go

CREATE FUNCTION RegExpLike (@input nvarchar(max), @pattern nvarchar(max))
RETURNS Bit
AS EXTERNAL NAME RegExp.UserDefinedFunctions.RegExpLike;
go

CREATE FUNCTION SumOfNum (@input nvarchar(max))
RETURNS bigint
AS EXTERNAL NAME RegExp.UserDefinedFunctions.SumOfNum
go

--test if functions work

select dbo.LD('sample','hellllllo')
select dbo.LDPerc('hello','helko')
select dbo.SCR('sample_^^^table')
select dbo.SumOfNum('bleble9bleble 90 1 [150]4')

go

--apply functions

drop table #tmp1
go

select npl_publn_id, npl_biblio, dbo.SCR(npl_biblio) as scr_biblio
into #tmp1
from sample_table

select count(distinct npl_biblio)
from #tmp1
--98553

select count(distinct scr_biblio)
from #tmp1
--95793

go

select npl_publn_id, scr_biblio, dbo.SumOfNum(scr_biblio) as NSM
into #tmp2
from #tmp1

select NSM, count(NSM) as freq
from #tmp2
group by NSM
order by freq desc
go
--65291 distinct numcheck
