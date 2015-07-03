use patstat
go



if OBJECT_id('RegExpTank') is not null drop table RegExpTank
go
create table RegExpTank (	regexp_id int,
							label nvarchar(max),
							pattern nvarchar(max))
go

insert into RegExpTank select 1, 'year','(19|20)[0-9]{2}[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])'
--and so on
go

if OBJECT_id('RegExpSMatches') is not null drop table RegExpSMatches
go
create table RegExpSMatches (
				tuple_id int identity(1,1) not null,
				su_id int not null,
				regexp_id int,
				match_index int,
				match_length int, 
				match_value nvarchar(max),
				constraint pk_REsM_id primary key (tuple_id))
go
--initialization

declare @maxtank_steps int = (select count(*) from RegExpTank)
declare @tank_step int = 1

--Create tmp table for each label of RegExp tank tuple

while (@tank_step <= @maxtank_steps)
	begin
		if object_id('#tmp') is not null drop table #tmp

		declare @biblio nvarchar(max)=''
		declare @pattern nvarchar(max)=''
		declare @label nvarchar(max)=''
		set @label = (select label from RegExpTank where regexp_id=@tank_step)
		set @biblio = (select npl_biblio from sample_unique as su where su.npl_publn_id=@counter_tuples)
		set @pattern = (select pattern from RegExpTank as a where a.regexp_id=@tank_step)

		select *  -- returns matches for current reg exp and biblio
		into #@label
		from dbo.GetMatches(@biblio, @pattern)

		alter table #tmp add su_id int
		alter table #tmp add regexp_id int
		set @tank_step += 1;
	end
go

--

declare @counter_tuples int = 1
declare @maxcounter_tuples int = (select count(*) from sample_unique) --or (select max(npl_publn_id) from sample_unique)
declare @maxtank_steps int = (select count(*) from RegExpTank)
declare @tank_step int = 1

while (@counter_tuples <= @maxcounter_tuples)

begin
	while (@tank_step <= @maxtank_steps)
		begin
			update #tmp set su_id=@counter_tuples;
			update #tmp set regexp_id=@tank_step;

			insert into RegExpSMatches (su_id, regexp_id, match_index, match_length, match_value)
			select * from #tmp;

			set @tank_step += 1;
		end
	set @counter_tuples += 1;
end

go
