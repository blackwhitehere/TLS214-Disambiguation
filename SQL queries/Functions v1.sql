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
if object_id('GetGroups') is not null drop function dbo.GetGroups
go
if object_id('RegexSplit') is not null drop function dbo.RegexSplit
go
if object_id('IsMatchValue') is not null drop function dbo.IsMatchValue	
go
if object_id('RegexReplace') is not null drop function dbo.RegexReplace	
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

--CLR Fn

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

--F6 - GetGroups
--Obtains groups of a well formed RegExp
CREATE FUNCTION GetGroups (@input nvarchar(max), @pattern nvarchar(max), @group_number int)
RETURNS nvarchar(max)
AS EXTERNAL NAME RegExp.UserDefinedFunctions.GetGroups
go

--F7 - RegexSplit
--Obtains string
CREATE FUNCTION RegexSplit (@input nvarchar(max), @pattern nvarchar(max))
RETURNS nvarchar(max)
AS EXTERNAL NAME RegExp.UserDefinedFunctions.RegexSplit
go

--F8 --IsMatchValue
--Get Value of a match
CREATE FUNCTION IsMatchValue (@input nvarchar(max), @pattern nvarchar(max))
RETURNS nvarchar(max)
AS EXTERNAL NAME RegExp.UserDefinedFunctions.IsMatchValue
go

--F9 --RegexReplace
--Replaces a regexp with corresponding regexp
CREATE FUNCTION RegexReplace (@input nvarchar(max), @pattern nvarchar(max), @replacement_regexp nvarchar(max))
RETURNS nvarchar(max)
AS EXTERNAL NAME RegExp.UserDefinedFunctions.RegexReplace
go

--test if functions work

select dbo.ComputeDistance('sample','hellllllo') as ComputeDistance
select dbo.ComputeDistancePerc('hello','helko') as ComputeDistancePerc
select dbo.SpecialCharacterRemover('sample_^^^table') as SpecialCharacterRemover
select dbo.SumOfNum('bleble9bleble 90 1 [150]4') as SumOfNum
select dbo.RegexGetPart('ble, blo, be', ',', 1) as RegexGetPart
select dbo.GetGroups('blelble 02/03/2012 blelel', '(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.]((19|20)[0-9]{2})', 2) as GetGroups
select dbo.RegexSplit('blelble 02/03/2012 blelel', '0[1-9]|[12][0-9]|3[01](-|/|.)0[1-9]|1[012](-|/|.)(19|20)[0-9]{2}') as RegexSplit
select dbo.IsMatchValue('ble, blo, be', ', be') as IsMatchValue
select dbo.RegexReplace('15 - 42 5- 4 4- 5, glrelel- ofjfj', '\s?(-)\s?', '$1') as RegexReplace
go