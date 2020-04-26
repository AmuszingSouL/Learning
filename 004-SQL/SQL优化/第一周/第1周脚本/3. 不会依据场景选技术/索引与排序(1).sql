set linesize 266
drop table t purge;
create table t as select * from dba_objects;

select t1.name, t1.STATISTIC#, t2.VALUE
  from v$statname t1, v$mystat t2
 where t1.STATISTIC# = t2.STATISTIC#
   and t1.name like '%sort%';

create index idx_object_id on t(object_id);

select t1.name, t1.STATISTIC#, t2.VALUE
  from v$statname t1, v$mystat t2
 where t1.STATISTIC# = t2.STATISTIC#
   and t1.name like '%sort%';

 
