---看官们，续集来这瞧瞧如下试验

drop table t purge;
create table t as select * from dba_objects;
update t set object_id =null where rownum<=2;
set autotrace off
select count(*) from t;
select count(object_id) from t;

--哎呀我的天，两个语句不等价，又如何谈性能呢，所以我们不能说必须要用COUNT(列）代替COUNT(*)，因为两者并不等价。
--记住，调优改写，要是等价改写！
 