drop table t1 cascade constraints purge;
drop table t2 cascade constraints  purge;
create table t1 as select * from dba_objects;
create table t2 as select * from dba_objects where rownum<=10000;
update t1 set object_id=rownum ;
update t2 set object_id=rownum ;
commit;

create or replace view v_t1_join_t2 
as select t2.object_id,t2.object_name,t1.object_type,t1.owner from t1,t2 
where t1.object_id=t2.object_id;

set autotrace traceonly
set linesize 1000
select * from v_t1_join_t2;
select object_id,object_name from v_t1_join_t2;

--×ö¸öÊÔÑé
alter table T1 add constraint pk_object_id primary key (OBJECT_ID);
alter table T2 add constraint fk_objecdt_id foreign key (OBJECT_ID) references t1 (OBJECT_ID);

select * from v_t1_join_t2;
select object_id,object_name from v_t1_join_t2;

----------------------------------------------------------------------------------------------------------------------------