IDEP的SQL语句。
该语句存在性能问题，执行非常缓慢，极耗CPU，为了实现行列转换的需求，具体如下：
select distinct to_char(a.svcctx_id),
                to_char(0),
                to_char(nvl((select peer_id
                              from dcc_ne_config
                             where peer_name = a.peer),
                            0)),
                to_char(a.priority),
                to_char(nvl((select peer_id
                              from dcc_ne_config
                             where peer_name = b.peer),
                            0)),
                to_char(b.priority),
                to_char(nvl((select peer_id
                              from dcc_ne_config
                             where peer_name = c.peer),
                            0)),
                to_char(c.priority)
  from (select hopbyhop,
               svcctx_id,
               substr(cause,
                      instr(cause, 'Host = ') + 7,
                      instr(cause, 'Priority = ') - instr(cause, 'Host = ') - 11) peer,
               substr(cause,
                      instr(cause, 'Priority = ') + 11,
                      instr(cause, 'reachable = ') -
                      instr(cause, 'Priority = ') - 13) priority
          from dcc_sys_log
         where cause like '%SC路由应答%'
           and hopbyhop in (select distinct hopbyhop from dcc_sys_log)) a,
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
         where cause like '%SC路由应答%'
           and hopbyhop in (select distinct hopbyhop from dcc_sys_log)) b,
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
         where cause like '%SC路由应答%'
           and hopbyhop in (select distinct hopbyhop from dcc_sys_log)) c
 where a.hopbyhop = b.hopbyhop
   and a.hopbyhop = c.hopbyhop
   and a.peer <> b.peer
   and a.peer <> c.peer
   and b.peer <> c.peer
   and a.priority <> b.priority
   and a.priority <> c.priority
   and b.priority <> c.priority

执行计划：

Execution Plan
----------------------------------------------------------
Plan hash value: 408096778

--------------------------------------------------------------------------------------------------
| Id  | Operation                | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT         |               |  1941 |   159K|       |    18E(100)|999:59:59 |
|*  1 |  TABLE ACCESS FULL       | DCC_NE_CONFIG |     1 |    28 |       |     3   (0)| 00:00:01 |
|*  2 |  TABLE ACCESS FULL       | DCC_NE_CONFIG |     1 |    28 |       |     3   (0)| 00:00:01 |
|*  3 |  TABLE ACCESS FULL       | DCC_NE_CONFIG |     1 |    28 |       |     3   (0)| 00:00:01 |
|   4 |  HASH UNIQUE             |               |  1941 |   159K|       |    18E(100)|999:59:59 |
|   5 |   MERGE JOIN             |               |    18E|    15E|       |    18E(100)|999:59:59 |
|   6 |    MERGE JOIN            |               |    18E|    15E|       |    32P(100)|999:59:59 |
|   7 |     MERGE JOIN           |               |  1147T|    79P|       |  1018T(100)|999:59:59 |
|   8 |      SORT JOIN           |               |   746T|    36P|    85P|   101G (95)|999:59:59 |
|*  9 |       HASH JOIN          |               |   746T|    36P|    70M|  4143M(100)|999:59:59 |
|  10 |        TABLE ACCESS FULL | DCC_SYS_LOG   |  4939K|    14M|       | 14325   (1)| 00:02:52 |
|* 11 |        HASH JOIN         |               |   151M|  7530M|  8448K|   366K (93)| 01:13:19 |
|* 12 |         TABLE ACCESS FULL| DCC_SYS_LOG   |   246K|  5547K|       | 14352   (2)| 00:02:53 |
|* 13 |         TABLE ACCESS FULL| DCC_SYS_LOG   |   246K|  6994K|       | 14352   (2)| 00:02:53 |
|* 14 |      FILTER              |               |       |       |       |            |          |
|* 15 |       SORT JOIN          |               |   246K|  5547K|    15M| 16046   (2)| 00:03:13 |
|* 16 |        TABLE ACCESS FULL | DCC_SYS_LOG   |   246K|  5547K|       | 14352   (2)| 00:02:53 |
|* 17 |     SORT JOIN            |               |  4939K|    14M|   113M| 27667   (2)| 00:05:32 |
|  18 |      TABLE ACCESS FULL   | DCC_SYS_LOG   |  4939K|    14M|       | 14325   (1)| 00:02:52 |
|* 19 |    SORT JOIN             |               |  4939K|    14M|   113M| 27667   (2)| 00:05:32 |
|  20 |     TABLE ACCESS FULL    | DCC_SYS_LOG   |  4939K|    14M|       | 14325   (1)| 00:02:52 |
--------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("PEER_NAME"=SUBSTR(:B1,INSTR(:B2,'Host = ')+7,INSTR(:B3,'Priority =
              ')-INSTR(:B4,'Host = ')-11))
   2 - filter("PEER_NAME"=SUBSTR(:B1,INSTR(:B2,'Host = ')+7,INSTR(:B3,'Priority =
              ')-INSTR(:B4,'Host = ')-11))
   3 - filter("PEER_NAME"=SUBSTR(:B1,INSTR(:B2,'Host = ')+7,INSTR(:B3,'Priority =
              ')-INSTR(:B4,'Host = ')-11))
   9 - access("HOPBYHOP"="HOPBYHOP")
  11 - access("HOPBYHOP"="HOPBYHOP")
       filter(SUBSTR("CAUSE",INSTR("CAUSE",'Host = ')+7,INSTR("CAUSE",'Priority =
              ')-INSTR("CAUSE",'Host = ')-11)<>SUBSTR("CAUSE",INSTR("CAUSE",'Host =
              ')+7,INSTR("CAUSE",'Priority = ')-INSTR("CAUSE",'Host = ')-11) AND
              SUBSTR("CAUSE",INSTR("CAUSE",'Priority = ')+11,INSTR("CAUSE",'reachable =
              ')-INSTR("CAUSE",'Priority = ')-13)<>SUBSTR("CAUSE",INSTR("CAUSE",'Priority =
              ')+11,INSTR("CAUSE",'reachable = ')-INSTR("CAUSE",'Priority = ')-13))
  12 - filter("CAUSE" LIKE '%SC路由应答%')
  13 - filter("CAUSE" LIKE '%SC路由应答%')
  14 - filter(SUBSTR("CAUSE",INSTR("CAUSE",'Host = ')+7,INSTR("CAUSE",'Priority =
              ')-INSTR("CAUSE",'Host = ')-11)<>SUBSTR("CAUSE",INSTR("CAUSE",'Host =
              ')+7,INSTR("CAUSE",'Priority = ')-INSTR("CAUSE",'Host = ')-11) AND
              SUBSTR("CAUSE",INSTR("CAUSE",'Host = ')+7,INSTR("CAUSE",'Priority =
              ')-INSTR("CAUSE",'Host = ')-11)<>SUBSTR("CAUSE",INSTR("CAUSE",'Host =
              ')+7,INSTR("CAUSE",'Priority = ')-INSTR("CAUSE",'Host = ')-11) AND
              SUBSTR("CAUSE",INSTR("CAUSE",'Priority = ')+11,INSTR("CAUSE",'reachable =
              ')-INSTR("CAUSE",'Priority = ')-13)<>SUBSTR("CAUSE",INSTR("CAUSE",'Priority =
              ')+11,INSTR("CAUSE",'reachable = ')-INSTR("CAUSE",'Priority = ')-13) AND
              SUBSTR("CAUSE",INSTR("CAUSE",'Priority = ')+11,INSTR("CAUSE",'reachable =
              ')-INSTR("CAUSE",'Priority = ')-13)<>SUBSTR("CAUSE",INSTR("CAUSE",'Priority =
              ')+11,INSTR("CAUSE",'reachable = ')-INSTR("CAUSE",'Priority = ')-13))
  15 - access("HOPBYHOP"="HOPBYHOP")
       filter("HOPBYHOP"="HOPBYHOP")
  16 - filter("CAUSE" LIKE '%SC路由应答%')
  17 - access("HOPBYHOP"="HOPBYHOP")
       filter("HOPBYHOP"="HOPBYHOP")
  19 - access("HOPBYHOP"="HOPBYHOP")
       filter("HOPBYHOP"="HOPBYHOP")


Statistics
----------------------------------------------------------
         54  recursive calls
          0  db block gets
     128904  consistent gets
       5549  physical reads
          0  redo size
       1017  bytes sent via SQL*Net to client
       1422  bytes received via SQL*Net from client
          1  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
          0  rows processed	
	
------	
with t as 
  (select hopbyhop,
               svcctx_id,
               substr(cause,
                      instr(cause, 'Host = ') + 7,
                      instr(cause, 'Priority = ') - instr(cause, 'Host = ') - 11) peer,
               substr(cause,
                      instr(cause, 'Priority = ') + 11,
                      instr(cause, 'reachable = ') -
                      instr(cause, 'Priority = ') - 13)

selet * from t1,t2, t
where t....

		  
		  

