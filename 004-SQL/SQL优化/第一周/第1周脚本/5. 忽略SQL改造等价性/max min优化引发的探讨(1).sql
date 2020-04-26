--MAX/MIN 的索引优化

drop table t purge;
create table t as select * from dba_objects;
alter table t add constraint pk1_object_id primary key (OBJECT_ID);
set autotrace on
set linesize 1000

select min(object_id),max(object_id) from t;

和这个分开写有差别吗
select max(object_id) from t;
select min(object_id) from t;



--参考
 select max, min  
    from (select max(object_id) max from t ) a,(select min(object_id) min from t) b;