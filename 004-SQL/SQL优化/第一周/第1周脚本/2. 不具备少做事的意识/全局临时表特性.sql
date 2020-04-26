某日，某某生产系统忽然日志暴增，回滚段也暴增，系统IO压力也增大......
经过诊断分析排查后发现，原来是系统昨晚新上的程序模块里出现类似delete from t_mid 的简单删除语句居然在短短时间内被执行了几十万
次，和相关人员确认后暂停了该程序。研究代码逻辑发现该t_mid表其实为一张中间表，程序的运算中间临时结果先存在这里，运算结束，就可
以清除了。
哦，这样的需求，真需要这样不停的去delete 吗？删除的开销很大且会占用大量的回滚段和产生大量日志，能否不要删除呢？且看下面全局
临时表的例子

--构造基于SESSION的全局临时表（退出session该表记录就会自动清空）
drop table ljb_tmp_session;
create global temporary table ljb_tmp_session on commit preserve rows as select  * from dba_objects where 1=2;
select table_name,temporary,duration from user_tables  where table_name='LJB_TMP_SESSION';

--构造基于事务的全局临时表(commit提交后，不等退出session，在该表记录就会自动清空）
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

ORA-14452: 试图创建, 更改或删除正在使用的临时表中的索引

SQL> 