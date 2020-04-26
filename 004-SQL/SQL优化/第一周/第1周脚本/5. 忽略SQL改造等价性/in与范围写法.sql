drop table t purge;
create table t as select * from dba_objects;
create index idx_object_id on t(object_id,object_type);
UPDATE t SET OBJECT_ID=20 WHERE ROWNUM<=26000;
UPDATE t SET OBJECT_ID=21 WHERE OBJECT_ID<>20;
COMMIT;
set linesize 266
set pagesize 1
alter session set statistics_level=all ;


select  /*+index(t,idx_object_id)*/ * from t  where object_TYPE='TABLE'  AND OBJECT_ID >= 20 AND OBJECT_ID<= 21;
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));
-------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
-------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |      1 |        |   2925 |00:00:00.03 |    1103 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T             |      1 |   2126 |   2925 |00:00:00.03 |    1103 |
|*  2 |   INDEX RANGE SCAN          | IDX_OBJECT_ID |      1 |    320 |   2925 |00:00:00.02 |     730 |
-------------------------------------------------------------------------------------------------------

select  /*+index(t,idx_object_id)*/ * from t t where object_TYPE='TABLE'  AND  OBJECT_ID IN (20,21);
select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));
---------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
---------------------------------------------------------------------------------------------------------
|   1 |  INLIST ITERATOR             |                |      1 |        |   2920 |00:00:00.01 |     563 |
|   2 |   TABLE ACCESS BY INDEX ROWID| t              |      2 |   2592 |   2920 |00:00:00.01 |     563 |
|*  3 |    INDEX RANGE SCAN          | IDX1_OBJECT_ID |      2 |      1 |   2920 |00:00:00.01 |     214 |
--------------------------------------------------------------------------------------------------------