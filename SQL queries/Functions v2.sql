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
if object_id('GetMatchesCount') is not null drop function dbo.GetMatchesCount	
go
if object_id('fn_delimiter') is not null drop function dbo.fn_delimiter	
go
if object_id('GetMatchesCSV') is not null drop function dbo.GetMatchesCSV
go
if object_id('GetMatches') is not null drop function dbo.GetMatches	
go
if object_id('IsMatchLength') is not null drop function dbo.IsMatchLength	
go
if object_id('StringLength') is not null drop function dbo.StringLength	
go
if object_id('IsMatchIndex') is not null drop function dbo.IsMatchIndex	
go
if object_id('SumIntDigits') is not null drop function dbo.SumIntDigits	
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

-------


create function dbo.fn_delimiter
(
	@input nvarchar(max)
)
returns bit
begin
	declare @c_comma int = 0
	declare @c_semicolon int = 0
	declare @test bit
	set @c_comma = dbo.GetMatchesCount(@input, '(?<!;),(?<!;)')
	set @c_semicolon =dbo.GetMatchesCount(@input, '(?<!,);(?<!,)')
	if @c_comma>@c_semicolon set @test=1;
	if @c_comma<@c_semicolon set @test=0;
	if @c_comma=@c_semicolon set @test=0;
	return @test;
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
--Replaces a regexp with corresponding string
CREATE FUNCTION RegexReplace (@input nvarchar(max), @pattern nvarchar(max), @replacement_regexp nvarchar(max))
RETURNS nvarchar(max)
AS EXTERNAL NAME RegExp.UserDefinedFunctions.RegexReplace
go

--F10 --GetMatchesCount
--Counts number of regexps in a string
CREATE FUNCTION GetMatchesCount (@input nvarchar(max), @pattern nvarchar(max))
RETURNS int
AS EXTERNAL NAME RegExp.UserDefinedFunctions.GetMatchesCount
go

--F11 --GetMatchesCSV

CREATE FUNCTION GetMatchesCSV (@input nvarchar(max), @pattern nvarchar(max))
RETURNS nvarchar(max)
AS EXTERNAL NAME RegExp.UserDefinedFunctions.GetMatchesCSV
go

--F12 --GetMatches

CREATE FUNCTION GetMatches (@input nvarchar(max), @pattern nvarchar(max))
RETURNS TABLE ([match_index] int, [match_length] int, [match_value] nvarchar(max))
AS EXTERNAL NAME RegExp.UserDefinedFunctions.GetMatches
go

--F13 --IsMatchLength

CREATE FUNCTION IsMatchLength (@input nvarchar(max), @pattern nvarchar(max))
RETURNS int
AS EXTERNAL NAME RegExp.UserDefinedFunctions.IsMatchLength
go

--F14 --StringLength

CREATE FUNCTION StringLength (@input nvarchar(max))
RETURNS int
AS EXTERNAL NAME RegExp.UserDefinedFunctions.StringLength
go

--F15 --IsMatchIndex

CREATE FUNCTION IsMatchIndex (@input nvarchar(max), @pattern nvarchar(max))
RETURNS int
AS EXTERNAL NAME RegExp.UserDefinedFunctions.IsMatchIndex
go

--F4 - SumOfNum - Calculates sum of numbers statitic per each biblio

CREATE FUNCTION SumIntDigits (@input nvarchar(max))
RETURNS int
AS EXTERNAL NAME RegExp.UserDefinedFunctions.SumIntDigits
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
select dbo.GetMatchesCount('bleble, blebbb, bleb. gg; 65-98, 2006', '(?<=[^;]),') as GetMatchesCount
select dbo.fn_delimiter('bleble; blebbb; bleb. gg; dd; 65(98)56-69, 2006')
select dbo.GetMatchesCSV('bleble; blebbb; bleb. gg; dd; 65(98)56-69', 'bl') as GetMatchesCSV
select * from dbo.GetMatches('bleble; blebbb; bleb. gg; dd; 65(98)56-69', 'bl')
select dbo.IsMatchLength('bleble; blebbb', 'bleble; blebbb') as IsMatchLength
select dbo.StringLength('bleble; blebbb') as StringLength
select dbo.IsMatchIndex('bleble; blebbb', 'le') as index_value
select dbo.SumIntDigits('55 ghghg 7 ghghgh') as SumIntDigits

