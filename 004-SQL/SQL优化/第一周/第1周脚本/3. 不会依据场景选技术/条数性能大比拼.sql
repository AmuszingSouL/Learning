--最慢速度(无索引）
drop table t purge;
create table t as  select * from dba_objects;
alter table T modify OBJECT_NAME not null;
select count(*) from t;
set autotrace traceonly
set linesize 1000
set timing on 
select COUNT(*) FROM T; 
/


--快了一点（有普通索引）
drop table t purge;
create table t as  select * from dba_objects;
alter table T modify OBJECT_NAME not null;
create  index idx_object_name on t(object_name);
set autotrace traceonly
set timing on 
select count(*) from t;
/


--又快一点（有了一个合适的位图索引）
drop table t purge;
create table t as  select * from dba_objects;
 Update t  Set object_name='abc'; 
 Update t Set object_name='evf' Where rownum<=20000;
create bitmap index idx_object_name on t(object_name);
set autotrace traceonly
set timing on
select count(*) from t;
/
注：如果记录数不重复或者说重复度很低，ORACLE会选择全表扫描，如果用
来强制，可以发现性能很低下。
alter session set statistics_level=all ;
set linesize 1000
set pagesize 1
select /*+index(t,idx_object_name)*/ count(*) from test t;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



--再快一点（物化视图，注意使用的场景）

drop materialized view MV_COUNT_T;
drop table t purge;
create table t as  select * from dba_objects;
 Update t  Set object_name='abc'; 
 Update t Set object_name='evf' Where rownum<=20000;

create  materialized view  mv_count_t
                    build immediate
                    refresh on commit
                    enable query rewrite
                    as
                    select count(*) FROM T;

set autotrace traceonly
set linesize 1000
select COUNT(*) FROM T; 
/

--又再快一点（缓存结果集，也是要注意使用的场景）
drop table t purge;
create table t as  select * from dba_objects;
select count(*) from t;
set linesize 1000
set autotrace traceonly
select /*+ result_cache */ count(*) from t;
/


--速度之王来咯！（原来需求才是王道）
select count(*) from t where rownum=1;



 
