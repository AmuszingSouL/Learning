drop table t purge;
create table t as select * from dba_objects;
create index idx_object_id on t(object_id,object_type);

set linesize 1000
set autotrace traceonly
select object_id,object_type from t where object_id=28;
/


select * from t where object_id=28;
/