--�������飬��������˭���죿
drop table t purge;
create table t as select * from dba_objects;
--alter table T modify object_id  null;
update t set object_id =rownum ;
set timing on 
set linesize 1000
set autotrace on 

select count(*) from t;
/
select count(object_id) from t;
/

--����count(��)��count(*) ������ҥ����������һ�����������������
---NO!NO!NO!��������¿�


--������������������
create index idx_object_id on t(object_id);
select count(*) from t;
/


select count(object_id) from t;
/

--�ۣ�ԭ���������COUNT(�У���COUNT(*)Ҫ�찡����ΪCOUNT(*)�����õ���������COUNT(��)���ԣ��������������

--NONONO!���뿴�ټ������¿�

alter table T modify object_id  not  null;

select count(*) from t;
/
select count(object_id) from t;
/
 
--����count(��)��count(*)��ʵһ���죬����������Ƿǿյģ�count(*)���õ���������ʱһ���죡�������������

---NONONO!��ʵ���߸���û�пɱ��ԣ����ܱȽ�����Ҫ����д���ȼۣ��������������Ͳ��ȼۣ�����