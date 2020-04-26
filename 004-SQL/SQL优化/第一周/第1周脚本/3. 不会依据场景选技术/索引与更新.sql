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
--���1(test1����6��������
insert into test1 select * from t;
commit;
--���2(test2����2��������
insert into test2 select * from t;
commit;
--���3(test3������������
insert into test3 select * from t;
commit;

-------------------------------------------------------------------------------------------------------------------------------

һ���������ص�С����
drop table t purge;
create table t as select * from dba_objects;
insert into t select * from t;
insert into t select * from t;
commit;
--������￪ʼע���ۼӵ�ʱ�䣨�ӽ������������¼��ϣ�
set timing on 
create index idx_t_owner on t(owner);
create index idx_t_obj_name on t(object_name);
create index idx_t_data_obj_id on t(data_object_id);
create index idx_t_created on t(created);
create index idx_t_last_ddl on t(last_ddl_time);

--���1(t����6��������
insert into t select * from t;
commit;
 

--���½�������2
drop table t purge;
create table t as select * from dba_objects;
insert into t select * from t;
insert into t select * from t;
commit;

---Ҳ�����￪ʼ���￪ʼע���ۼӵ�ʱ�䣨�Ӳ����¼��ϵ���������ϣ�

set timing on 

--���1(t����6������,��ʱ�Ȳ�����
insert into t select * from t;


create index idx_t_owner on t(owner);
create index idx_t_obj_name on t(object_name);
create index idx_t_data_obj_id on t(data_object_id);
create index idx_t_created on t(created);
create index idx_t_last_ddl on t(last_ddl_time);
