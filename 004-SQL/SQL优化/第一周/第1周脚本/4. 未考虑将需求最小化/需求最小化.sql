���SQL�����ʵ��Ϊ��ʵ������ת��������Ч�ʷǳ��ͣ�ɨ����Σ��������ս��Ҳ����ȷ��

��ν��з����أ�   

1.�����˽������������ʲô�����˽⣬�������£�
DROP TABLE TEST;
CREATE TABLE TEST ( ID1 NUMBER,ID2 NUMBER,VALUE1 VARCHAR2(20),VALUE2 VARCHAR2(20));
INSERT INTO TEST VALUES (1,2,'A','B');
INSERT INTO TEST VALUES (1,2,'C','D');
INSERT INTO TEST VALUES (1,2,'E','F');
INSERT INTO TEST VALUES (1,2,'G','H');
INSERT INTO TEST VALUES (3,8,'I','J');
INSERT INTO TEST VALUES (3,8,'K','L');
INSERT INTO TEST VALUES (3,8,'M','N');
INSERT INTO TEST VALUES (8,9,'O','P');
INSERT INTO TEST VALUES (8,9,'Q','R');
INSERT INTO TEST VALUES (11,12,'S','T');
COMMIT;
SQL> SELECT * FROM TEST; 
       ID1        ID2 VALUE1               VALUE2
---------- ---------- -------------------- --------------------
         1          2 A                    B
         1          2 C                    D
         1          2 E                    F
         1          2 G                    H
         3          8 I                    J
         3          8 K                    L
         3          8 M                    N
         8          9 O                    P
         8          9 Q                    R
        11         12 S                    T
10 rows selected 
Ҫ��Ϊ(����ת��������3����ֻȡ����������3�����ÿո������У�
ID1        ID2 VALUE1               VALUE2  VALUE3               VALUE4  VALUE5               VALUE6 
---------- ---------- -------------------- -------------------------------------------------------------
1           2    A                    B      C                    D        E                   F
3           8    I                    J      K                    L        M                   N
8           9    O                    P      Q                    R        NULL                NULL
11         12    S                    T      NULL                 NULL     NULL                NULL


���ǿ���ͨ��MAX+��������ʵ�����£�
SELECT ID1,ID2
      ,MAX(DECODE(RN,1,VALUE1))
      ,MAX(DECODE(RN,1,VALUE2))
      ,MAX(DECODE(RN,2,VALUE1))
      ,MAX(DECODE(RN,2,VALUE2))
      ,MAX(DECODE(RN,3,VALUE1))
      ,MAX(DECODE(RN,3,VALUE2))
  FROM (SELECT TEST.*, ROW_NUMBER() OVER(PARTITION BY ID1,ID2 ORDER BY VALUE1,VALUE2) RN FROM TEST) T
WHERE RN<=3
GROUP BY ID1,ID2;


���ǿ��Խ�SQL����Ϊ���£���������佫��ɨ����ԭ����3�ν���Ϊ1�Σ�������������ܣ�����ԭ�ȵ���仹�����߼��ϵĴ���
WITH T AS 
(select hopbyhop,
               svcctx_id,
               substr(cause,
                      instr(cause, 'Host = ') + 7,
                      instr(cause, 'Priority = ') - instr(cause, 'Host = ') - 11) peer,
               substr(cause,
                      instr(cause, 'Priority = ') + 11,
                      instr(cause, 'reachable = ') -
                      instr(cause, 'Priority = ') - 13) priority
          from dcc_sys_log
         where cause like '%SC·��Ӧ��%'
           and hopbyhop in (select distinct hopbyhop from dcc_sys_log))---�˴����࣡
SELECT hopbyhop,svcctx_id,
       MAX(DECODE(RN,1,PEER)) PEER1
      ,MAX(DECODE(RN,1,PRIORITY)) PRIORITY1
      ,MAX(DECODE(RN,2,PEER))  PEER2
      ,MAX(DECODE(RN,2,PRIORITY))  PRIORITY2
      ,MAX(DECODE(RN,3,PEER)) PEER3
      ,MAX(DECODE(RN,3,PRIORITY)) PRIORITY3
 FROM (SELECT T.*, ROW_NUMBER() OVER(PARTITION BY hopbyhop,svcctx_id ORDER BY PEER,PRIORITY) RN FROM T) 
WHERE RN<=3
GROUP BY hopbyhop,svcctx_id;







ע���漰����������ʹ�õ�ʱ�򣬾�����WITH�Ӿ䣬�����ٴ��룬��������ά�������WITH�Ӿ䴦�Ĵ����߼����£�
ֻ��Ϊ��ȡ��Host = ��ֵ��Priority = ��ֵ

SQL>  SELECT substr('SC·��Ӧ��Host = SR2@001.ChinaTelecom.com, Priority = 1, reachable = true',
  2                        instr('SC·��Ӧ��Host = SR2@001.ChinaTelecom.com, Priority = 1, reachable = true', 'Host = ') + 7,
  3                        instr('SC·��Ӧ��Host = SR2@001.ChinaTelecom.com, Priority = 1, reachable = true', 'Priority = ') - instr('SC·��Ӧ��Host = SR2@001.ChinaTelecom.com, Priority = 1, reachable = true', 'Host = ') - 11) peer,
  4                 substr('SC·��Ӧ��Host = SR2@001.ChinaTelecom.com, Priority = 1, reachable = true',
  5                        instr('SC·��Ӧ��Host = SR2@001.ChinaTelecom.com, Priority = 1, reachable = true', 'Priority = ') + 11,
  6                        instr('SC·��Ӧ��Host = SR2@001.ChinaTelecom.com, Priority = 1, reachable = true', 'reachable = ') -
  7                        instr('SC·��Ӧ��Host = SR2@001.ChinaTelecom.com, Priority = 1, reachable = true', 'Priority = ') - 13) priority
  8  from dual;
 
PEER                   PRIORITY
---------------------- --------
SR2@001.ChinaTelecom.c 1
 
 
д�����ȱȽϲ���ѧ����һ���ݱ仯�ˣ�ֵ�ʹ����ˣ�д���λ��Ҳ�Ƚϼ򵥣�ֻҪ�ܽ���η�������Եļ򵥣�
with data as (SELECT 'SC·��Ӧ��Host = SR2@001.ChinaTelecom.com, Priority = 1, reachable = true' as str 
                    ,'Host = ' k1
                    ,'Priority = ' k2
               FROM DUAL)
,data2 AS (SELECT data.*,INSTR(str,k1) p1,INSTR(str,k2) p2 FROM data)
select SUBSTR(str,p1+LENGTH(k1),INSTR(str,',',p1+1)-p1-LENGTH(k1))
      ,SUBSTR(str,p2+LENGTH(k2),INSTR(str,',',p2+1)-p2-LENGTH(k2))
  from data2;





��˱������Ĵ���Ӧ��Ϊ���£�

with data as (select hopbyhop,
               svcctx_id,
               cause as str,
               'Host = ' k1,
               'Priority = ' k2 
               from dcc_sys_log  where cause like '%SC·��Ӧ��%')
,data2 as (select data.*,instr(str,k1) p1, instr(str,k2) p2 from data)
,data3 as 
(select hopbyhop,
       svcctx_id,
       SUBSTR(str,p1+LENGTH(k1),INSTR(str,',',p1+1)-p1-LENGTH(k1)) peer
      ,SUBSTR(str,p2+LENGTH(k2),INSTR(str,',',p2+1)-p2-LENGTH(k2)) PRIORITY
  from data2)
SELECT hopbyhop,svcctx_id,
       MAX(DECODE(RN,1,PEER)) PEER1
      ,MAX(DECODE(RN,1,PRIORITY)) PRIORITY1
      ,MAX(DECODE(RN,2,PEER))  PEER2
      ,MAX(DECODE(RN,2,PRIORITY))  PRIORITY2
      ,MAX(DECODE(RN,3,PEER)) PEER3
      ,MAX(DECODE(RN,3,PRIORITY)) PRIORITY3
 FROM (SELECT data3.*, ROW_NUMBER() OVER(PARTITION BY hopbyhop,svcctx_id ORDER BY PEER,PRIORITY) RN FROM data3) 
WHERE RN<=3
GROUP BY hopbyhop,svcctx_id;

ִ�мƻ���
Execution Plan
----------------------------------------------------------
Plan hash value: 3725476352

-------------------------------------------------------------------------------------------------
| Id  | Operation                 | Name        | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT          |             |    13 |  6838 |       | 16295   (1)| 00:03:16 |
|   1 |  SORT GROUP BY NOSORT     |             |    13 |  6838 |       | 16295   (1)| 00:03:16 |
|*  2 |   VIEW                    |             |   246K|   123M|       | 16295   (1)| 00:03:16 |
|*  3 |    WINDOW SORT PUSHED RANK|             |   246K|  6994K|    18M| 16295   (1)| 00:03:16 |
|*  4 |     TABLE ACCESS FULL     | DCC_SYS_LOG |   246K|  6994K|       | 14321   (1)| 00:02:52 |
-------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("RN"<=3)
   3 - filter(ROW_NUMBER() OVER ( PARTITION BY "HOPBYHOP","SVCCTX_ID" ORDER BY
              SUBSTR("CAUSE",INSTR("CAUSE",'Host = ')+7,INSTR("CAUSE",',',INSTR("CAUSE",'Host =
              ')+1)-INSTR("CAUSE",'Host = ')-7),SUBSTR("CAUSE",INSTR("CAUSE",'Priority =
              ')+11,INSTR("CAUSE",',',INSTR("CAUSE",'Priority = ')+1)-INSTR("CAUSE",'Priority =
              ')-11))<=3)
   4 - filter("CAUSE" LIKE '%SC·��Ӧ��%')


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
      64452  consistent gets
          0  physical reads
          0  redo size
        782  bytes sent via SQL*Net to client
        481  bytes received via SQL*Net from client
          1  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
          0  rows processed

SQL> 



���մ���Ϊ

select distinct to_char(svcctx_id),
                to_char(0),
                to_char(nvl((select peer_id
                              from dcc_ne_config
                             where peer_name = PEER1),
                            0)),
                to_char(priority1),
                to_char(nvl((select peer_id
                              from dcc_ne_config
                             where peer_name =PEER2),
                            0)),
                to_char(priority2),
                to_char(nvl((select peer_id
                              from dcc_ne_config
                             where peer_name = PEER3),
                            0)),
                to_char(priority3)
  from
(with data as (select hopbyhop,
               svcctx_id,
               cause as str,
               'Host = ' k1,
               'Priority = ' k2 
               from dcc_sys_log  where cause like '%SC·��Ӧ��%')
,data2 as (select data.*,instr(str,k1) p1, instr(str,k2) p2 from data)
,data3 as 
(select hopbyhop,
       svcctx_id,
       SUBSTR(str,p1+LENGTH(k1),INSTR(str,',',p1+1)-p1-LENGTH(k1)) peer
      ,SUBSTR(str,p2+LENGTH(k2),INSTR(str,',',p2+1)-p2-LENGTH(k2)) PRIORITY
  from data2)
SELECT hopbyhop,svcctx_id,
       MAX(DECODE(RN,1,PEER)) PEER1
      ,MAX(DECODE(RN,1,PRIORITY)) PRIORITY1
      ,MAX(DECODE(RN,2,PEER))  PEER2
      ,MAX(DECODE(RN,2,PRIORITY))  PRIORITY2
      ,MAX(DECODE(RN,3,PEER)) PEER3
      ,MAX(DECODE(RN,3,PRIORITY)) PRIORITY3
 FROM (SELECT data3.*, ROW_NUMBER() OVER(PARTITION BY hopbyhop,svcctx_id ORDER BY PEER,PRIORITY) RN FROM data3) 
WHERE RN<=3
GROUP BY hopbyhop,svcctx_id) t2
