---哇，是不是很眼熟啊！

--drop table ljb_tmp_session;
create global temporary table ljb_tmp_session on commit preserve rows as select  * from dba_objects where 1=2;
select table_name,temporary,duration from user_tables  where table_name='LJB_TMP_SESSION';
--drop table  ljb_tmp_transaction;
create global temporary table ljb_tmp_transaction on commit delete rows as select * from dba_objects where 1=2;
select table_name, temporary, DURATION from user_tables  where table_name='LJB_TMP_TRANSACTION';

insert all 
   into  ljb_tmp_transaction
   into  ljb_tmp_session
select * from dba_objects;

与下面语句等价吗？

insert  into  ljb_tmp_transaction as select * from dba_objects;
insert  into  jb_tmp_session as select * from dba_objects;