---�����ǣ���������������������

drop table t purge;
create table t as select * from dba_objects;
update t set object_id =null where rownum<=2;
set autotrace off
select count(*) from t;
select count(object_id) from t;

--��ѽ�ҵ��죬������䲻�ȼۣ������̸�����أ��������ǲ���˵����Ҫ��COUNT(�У�����COUNT(*)����Ϊ���߲����ȼۡ�
--��ס�����Ÿ�д��Ҫ�ǵȼ۸�д��
 