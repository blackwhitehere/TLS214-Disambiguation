use patstat

select count(*) from rule_11
go

select a.new_id1,z.npl_publn_id, x.npl_biblio, a.new_id2, sg.npl_publn_id, st.npl_biblio
from rule_11 as a
join sample_glue	as z on a.new_id1=z.new_id
join sample_table	as x on z.npl_publn_id=x.npl_publn_id

join sample_glue	as sg on a.new_id2=sg.new_id
join sample_table	as st on sg.npl_publn_id=st.npl_publn_id
