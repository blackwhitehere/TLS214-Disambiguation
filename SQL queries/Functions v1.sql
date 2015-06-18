--SQL & CLR USER DEFINED FUNCTIONS
use patstat
go
--CLR

--Enable CLR
sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO

--drop functions and assembly

if object_id('fn_StripCharacters') is not null drop function dbo.fn_StripCharacters
go
if object_id('ComputeDistance') is not null drop function dbo.ComputeDistance
go
if object_id('ComputeDistancePerc') is not null drop function dbo.ComputeDistancePerc
go
if object_id('SpecialCharacterRemover') is not null drop function dbo.SpecialCharacterRemover
go
if object_id('SumOfNum') is not null drop function dbo.SumOfNum
go
if object_id('RegexGetPart') is not null drop function dbo.RegexGetPart
go
drop assembly RegExp
go

-- Create assembly

CREATE ASSEMBLY RegExp 
from 'C:\Users\stan\Documents\GitHub\TLS214-Disambiguation\VS\Disambiguation\Sample\bin\Debug\Sample.dll' 
WITH PERMISSION_SET = SAFE
go

--SQL

--fn A - StripCharacters
if object_id('fn_StripCharacters') is not null drop function [dbo].[fn_StripCharacters]
go

create function [dbo].[fn_StripCharacters]
(
    @string nvarchar(max), 
    @matchexpression varchar(255)
)
returns nvarchar(max)
as
begin
    set @matchexpression =  '%['+@matchexpression+']%'

    while patindex(@matchexpression, @string) > 0
        set @string = stuff(@string, patindex(@matchexpression, @string), 1, '') --deletes found expression from string

    return @string -- opposite of matched expression is returned

end
go

--F1 - Levenshtein distance
CREATE FUNCTION	ComputeDistance (@string1 nvarchar(max), @string2 nvarchar(max))
RETURNS	int
AS EXTERNAL NAME RegExp.UserDefinedFunctions.ComputeDistance;
go

--F2 - Levenshtein distance Percentage
CREATE FUNCTION	ComputeDistancePerc (@string1 nvarchar(max), @string2 nvarchar(max))
RETURNS	float
AS EXTERNAL NAME RegExp.UserDefinedFunctions.ComputeDistancePerc;
go

--F3 - Special Character Remover - Deletes special characters from input
CREATE FUNCTION	SpecialCharacterRemover (@string1 nvarchar(max))
RETURNS nvarchar(max)
AS EXTERNAL NAME RegExp.UserDefinedFunctions.SpecialCharacterRemover;
go

--F4 - SumOfNum - Calculates sum of numbers statitic per each biblio
CREATE FUNCTION SumOfNum (@input nvarchar(max))
RETURNS bigint
AS EXTERNAL NAME RegExp.UserDefinedFunctions.SumOfNum
go

--F5 - RegexGetPart
--Obtains specified part of the input which was split on a RegExp
CREATE FUNCTION RegexGetPart (@input nvarchar(max), @pattern nvarchar(max), @part int)
RETURNS nvarchar(max)
AS EXTERNAL NAME RegExp.UserDefinedFunctions.RegexGetPart
go

--test if functions work

select dbo.ComputeDistance('sample','hellllllo') as ComputeDistance
select dbo.ComputeDistancePerc('hello','helko') as ComputeDistancePerc
select dbo.SpecialCharacterRemover('sample_^^^table') as SpecialCharacterRemover
select dbo.SumOfNum('bleble9bleble 90 1 [150]4') as SumOfNum
select dbo.RegexGetPart('ble, blo, be', ',', 1) as RegexGetPart
go