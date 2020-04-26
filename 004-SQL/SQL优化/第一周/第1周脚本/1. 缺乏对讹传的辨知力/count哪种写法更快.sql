--做个试验，看看到底谁更快？
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

--看来count(列)比count(*) 更快是谣传，明明是一样快嘛，真相是这样吗？
---NO!NO!NO!请继续往下看


--来来，建个索引看看
create index idx_object_id on t(object_id);
select count(*) from t;
/


select count(object_id) from t;
/

--哇，原来真的是用COUNT(列）比COUNT(*)要快啊，因为COUNT(*)不能用到索引，而COUNT(列)可以，真相真是如此吗？

--NONONO!还请看官继续往下看

alter table T modify object_id  not  null;

select count(*) from t;
/
select count(object_id) from t;
/
 
--看来count(列)和count(*)其实一样快，如果索引列是非空的，count(*)可用到索引，此时一样快！真相真是如此吗？

---NONONO!其实两者根本没有可比性，性能比较首先要考虑写法等价，这两个语句根本就不等价！！！