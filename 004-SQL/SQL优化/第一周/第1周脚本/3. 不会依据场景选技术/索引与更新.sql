drop table test1 purge;
drop table test2 purge;
drop table test3 purge;
drop table t purge;
create table t as select * from dba_objects;
create table test1 as select * from t;
create table test2 as select * from t;
create table test3 as select * from t;
create index idx_owner on test1(owner);
create index idx_object_name on test1(object_name);
create index idx_data_obj_id on test1(data_object_id);
create index idx_created on test1(created);
create index idx_last_ddl_time on test1(last_ddl_time);
create index idx_status on test1(status);
create index idx_t2_sta on test2(status);
create index idx_t2_objid on test2(object_id);
set timing on 
--语句1(test1表有6个索引）
insert into test1 select * from t;
commit;
--语句2(test2表有2个索引）
insert into test2 select * from t;
commit;
--语句3(test3表有无索引）
insert into test3 select * from t;
commit;

-------------------------------------------------------------------------------------------------------------------------------

一次与出账相关的小故事
drop table t purge;
create table t as select * from dba_objects;
insert into t select * from t;
insert into t select * from t;
commit;
--请从这里开始注意累加的时间（从建索引到插入记录完毕）
set timing on 
create index idx_t_owner on t(owner);
create index idx_t_obj_name on t(object_name);
create index idx_t_data_obj_id on t(data_object_id);
create index idx_t_created on t(created);
create index idx_t_last_ddl on t(last_ddl_time);

--语句1(t表有6个索引）
insert into t select * from t;
commit;
 

--以下进行试验2
drop table t purge;
create table t as select * from dba_objects;
insert into t select * from t;
insert into t select * from t;
commit;

---也从这里开始这里开始注意累加的时间（从插入记录完毕到建索引完毕）

set timing on 

--语句1(t表有6个索引,此时先不建）
insert into t select * from t;


create index idx_t_owner on t(owner);
create index idx_t_obj_name on t(object_name);
create index idx_t_data_obj_id on t(data_object_id);
create index idx_t_created on t(created);
create index idx_t_last_ddl on t(last_ddl_time);
