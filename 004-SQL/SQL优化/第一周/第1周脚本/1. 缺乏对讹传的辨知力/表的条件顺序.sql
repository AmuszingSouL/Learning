
--这次居然连基于规则的试验都没有模拟出这个结论：（有过滤条件的WHERE要放在后面）
drop table t1 purge;
drop table t2 purge;
create table t1 as select * from dba_objects;
create table t2 as select rownum id ,dbms_random.string('b', 50) n ,data_object_id data_id from dba_objects where rownum<=10000;
set autotrace traceonly
set linesize 1000
set timing on
select /*+rule*/ * from t1,t2 where t1.object_id=29 and t2.data_id>8;
select /*+rule*/ * from t1,t2 where t2.data_id>8 and t1.object_id=29 ;


加个关联条件看看，看看
select /*+rule*/ * from t1,t2 where t1.object_id=t2.id and t1.object_id=29 and t2.data_id>8;
select /*+rule*/ * from t1,t2 where t1.object_id=t2.id and t2.data_id>8 and t1.object_id=29 ;