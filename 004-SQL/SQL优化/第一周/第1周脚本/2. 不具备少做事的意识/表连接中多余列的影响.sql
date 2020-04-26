--环境构造
--研究Nested Loops Join访问次数前准备工作
DROP TABLE t1 CASCADE CONSTRAINTS PURGE; 
DROP TABLE t2 CASCADE CONSTRAINTS PURGE; 
CREATE TABLE t1 (
     id NUMBER NOT NULL,
     n NUMBER,
     contents VARCHAR2(4000)
   )
   ; 
CREATE TABLE t2 (
     id NUMBER NOT NULL,
     t1_id NUMBER NOT NULL,
     n NUMBER,
     contents VARCHAR2(4000)
   )
   ; 
execute dbms_random.seed(0); 
INSERT INTO t1
     SELECT  rownum,  rownum, dbms_random.string('a', 50)
       FROM dual
     CONNECT BY level <= 100
      ORDER BY dbms_random.random; 
INSERT INTO t2 SELECT rownum, rownum, rownum, dbms_random.string('b', 50) FROM dual CONNECT BY level <= 100000
    ORDER BY dbms_random.random; 
COMMIT; 
select count(*) from t1;
select count(*) from t2;



--Merge Sort Join取所有字段的情况
alter session set statistics_level=all ;
set linesize 1000
SELECT /*+ leading(t2) use_merge(t1)*/ *
FROM t1, t2
WHERE t1.id = t2.t1_id;

select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));



---Merge Sort Join取部分字段的情况
SELECT /*+ leading(t2) use_merge(t1)*/ t1.id
FROM t1, t2
WHERE t1.id = t2.t1_id;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));