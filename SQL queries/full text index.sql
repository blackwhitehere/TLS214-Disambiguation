drop fulltext index on tls214_npl_publn
go
drop fulltext catalog tls214_npl_publn_catalog
go
create fulltext catalog tls214_npl_publn_catalog
go
create fulltext index on tls214_npl_publn(npl_biblio)
key index pk_npl_publn_id on tls214_npl_publn_catalog
with stoplist off, change_tracking off, no population
go
