ĳ�գ�ĳĳ����ϵͳ��Ȼ��־�������ع���Ҳ������ϵͳIOѹ��Ҳ����......
������Ϸ����Ų���֣�ԭ����ϵͳ�������ϵĳ���ģ�����������delete from t_mid �ļ�ɾ������Ȼ�ڶ̶�ʱ���ڱ�ִ���˼�ʮ��
�Σ��������Աȷ�Ϻ���ͣ�˸ó����о������߼����ָ�t_mid����ʵΪһ���м������������м���ʱ����ȴ����������������Ϳ�
������ˡ�
Ŷ����������������Ҫ������ͣ��ȥdelete ��ɾ���Ŀ����ܴ��һ�ռ�ô����Ļع��κͲ���������־���ܷ�Ҫɾ���أ��ҿ�����ȫ��
��ʱ�������

--�������SESSION��ȫ����ʱ���˳�session�ñ��¼�ͻ��Զ���գ�
drop table ljb_tmp_session;
create global temporary table ljb_tmp_session on commit preserve rows as select  * from dba_objects where 1=2;
select table_name,temporary,duration from user_tables  where table_name='LJB_TMP_SESSION';

--������������ȫ����ʱ��(commit�ύ�󣬲����˳�session���ڸñ��¼�ͻ��Զ���գ�
drop table  ljb_tmp_transaction;
create global temporary table ljb_tmp_transaction on commit delete rows as select * from dba_objects where 1=2;
select table_name, temporary, DURATION from user_tables  where table_name='LJB_TMP_TRANSACTION';

insert all 
   into  ljb_tmp_transaction
   into  ljb_tmp_session
select * from dba_objects;

select session_cnt,transaction_cnt from (select count(*) session_cnt from ljb_tmp_session),
 (select count(*) transaction_cnt from ljb_tmp_transaction);

commit;
 
select session_cnt,transaction_cnt from (select count(*) session_cnt from ljb_tmp_session),
(select count(*) transaction_cnt from ljb_tmp_transaction);

disconnect
connect ljb/ljb
  
select session_cnt,transaction_cnt from (select count(*) session_cnt from ljb_tmp_session),
(select count(*) transaction_cnt from ljb_tmp_transaction);




















--



SQL> drop table ljb_tmp_session;

drop table ljb_tmp_session

ORA-14452: ��ͼ����, ���Ļ�ɾ������ʹ�õ���ʱ���е�����

SQL> 